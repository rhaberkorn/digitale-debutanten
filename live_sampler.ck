/*
 * Live (and stock) sampler based on LiSaX (LiSa)
 * in-port: Bus.channels[0]
 */
class Bank extends Chubgraph {
	/*
	 * NOTE: for multichannel LiSa it's more efficient to only chuck
	 * channel 0: LiSaX lisa.chan(0) => PitShift pitch
	 */
	inlet => LiSaX lisa => PitShift pitch => outlet;

	/* default buffer size, if no stock sample is read in */
	30::second => lisa.duration;
	/* loop start, end and recording end are initialized after allocation! */

	/* setting this to 1 if we only need one voice improves performance */
	1 => lisa.maxVoices;

	.8 => pitch.mix;
	1 => pitch.shift;

	lisa.rate() => float lisaRate;
	0::samp => dur lisaLoopEnd; /* empty bank */

	fun void
	load(int i, string file)
	{
		chout <= "Loading \"" <= file <= "\" into sample bank " <= i <= "... ";
		chout.flush();

		file => lisa.read;
		lisa.loopEnd() => lisaLoopEnd;

		chout <= "Done!" <= IO.newline();
	}
}

/* patch */
Bank banks[7];
Gain amp => Bus.out_left; amp => Bus.out_right;

for (0 => int i; i < banks.cap(); i++)
	Bus.channels[0] => banks[i] => amp;

/* stock samples */
banks[0].load(0, "samples/stier_loop_stereo.wav");

banks[0] @=> Bank @currentBank;

/*
 * Sampler configuration: Gamepad
 */
fun void
rumble_loop()
{
	RumbleEvent rumblev;

	false => int rep;
	500::ms => dur maxLoopDur => dur loopDur;

	while (rumblev => now) {
		if ("axisButtonLeft" => rumblev.isControl) {
			rumblev.getDur(maxLoopDur, ms) => loopDur;
		} else if ("joystickRightX" => rumblev.isControl) {
			rumblev.getFloat(-1, 1) + currentBank.lisaRate =>
							currentBank.lisa.rate;
		} else if ("joystickRightY" => rumblev.isControl) {
			rumblev.getFloat(2, 0) => currentBank.pitch.shift;
		} else if ("buttonLeft" => rumblev.isControl) {
			if (rumblev.getBool() => rep) {
				currentBank.lisa.playPos() => currentBank.lisa.loopEnd;
			} else {
				0::samp => currentBank.lisa.loopStart;
				currentBank.lisaLoopEnd => currentBank.lisa.loopEnd;
			}
		}

		if (rep)
			currentBank.lisa.loopEnd() - loopDur => currentBank.lisa.loopStart;
	}
	/* not reached */
}
spork ~ rumble_loop();

/*
 * Sampler configuration: MIDI
 */
"primary" => NanoEvent.init @=> NanoEvent @nanoev;

while (nanoev => now) {
	if ("recordToggle" => nanoev.isControl) {
		if (currentBank.lisa.loop()) {
			/* loop recording */
			nanoev.getBool() => currentBank.lisa.loopRec;
			if (currentBank.lisaLoopEnd == 0::samp &&
			    !nanoev.getBool())
				currentBank.lisa.recPos() => currentBank.lisaLoopEnd
							  => currentBank.lisa.loopEndRec
							  => currentBank.lisa.loopEnd;
		} else if (!(nanoev.getBool() => currentBank.lisa.record)) {
			/* normal recording (overwrite buffer) */
			currentBank.lisa.recPos() => currentBank.lisaLoopEnd
						  => currentBank.lisa.loopEnd
						  => currentBank.lisa.loopEndRec;
		}

		if (nanoev.getBool())
			0::samp => currentBank.lisa.recPos;
	} else if ("playButton" => nanoev.isControl) {
		if (nanoev.getBool()) {
			0::samp => currentBank.lisa.playPos;
			true => currentBank.lisa.play;
		}
	} else if ("stopButton" => nanoev.isControl) {
		if (nanoev.getBool())
			false => currentBank.lisa.play;
	} else if ("loopToggle" => nanoev.isControl) {
		/* toggles loop playing AND loop recording */
		nanoev.getBool() => currentBank.lisa.loop;
	} else if ("samplerVolumeKnob" => nanoev.isControl) {
		nanoev.getFloat(1) => currentBank.gain;
	} else if ("samplerPitchSlider" => nanoev.isControl) {
		nanoev.getFloat(-2, 2) => currentBank.lisaRate
				       => currentBank.lisa.rate;
	} else if (nanoev.CCId >= 23 && nanoev.CCId <= 29) {
		/* chooseSampleButton#CCId pressed */
		nanoev.CCId - 23 => int id;
		banks[id] @=> currentBank;

		chout <= "Sample bank #" <= id <= " selected." <= IO.newline();
	}
}
