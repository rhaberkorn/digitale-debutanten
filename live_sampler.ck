/*
 * Live (and stock) sampler based on LiSaX (LiSa)
 * in-port: Bus.channels[0]
 */

/* default buffer size (for banks without stock sample) */
30::second => dur default_size;

LiSaX lisa[7];
Gain amp => Bus.out_left;
amp => Bus.out_right;

fun void
read(int i, string file)
{
	chout <= "Loading \"" <= file <= "\" into sample bank " <= i <= "... ";
	chout.flush();
	file => lisa[i].read;
	chout <= "Done!" <= IO.newline();
}

/* stock samples */
read(0, "samples/stier_loop_stereo.wav");

for (0 => int i; i < lisa.cap(); i++) {
	if (lisa[i].duration() == 0::samp) {
		/* empty sample bank */
		default_size => lisa[i].duration;
		/* loop start, end and recording end are initialized! */
		0::samp => lisa[i].loopEnd;
	}

	/* setting this to 1 if we only need one voice improves performance */
	1 => lisa[i].maxVoices;

	/* patch */
	/*
	 * NOTE: for multichannel LiSa it's more efficient to only chuck
	 * channel 0: lisa[i].chan(0) => amp;
	 */
	Bus.channels[0] => lisa[i] => amp;
}

lisa[0] @=> LiSaX @currentSample;

/*
 * Sampler configuration
 */
"primary" => NanoEvent.init @=> NanoEvent @nanoev;

while (nanoev => now) {
	if ("recordToggle" => nanoev.isControl) {
		if (currentSample.loop()) {
			/* loop recording */
			nanoev.getBool() => currentSample.loopRec;
			if (currentSample.loopEnd() == 0::samp &&
			    !nanoev.getBool())
				currentSample.recPos() => currentSample.loopEndRec
						       => currentSample.loopEnd;
		} else if (!(nanoev.getBool() => currentSample.record)) {
			/* normal recording (overwrite buffer) */
			currentSample.recPos() => currentSample.loopEnd
					       => currentSample.loopEndRec;
		}

		if (nanoev.getBool())
			0::samp => currentSample.recPos;
	} else if ("playButton" => nanoev.isControl) {
		if (nanoev.getBool()) {
			0::samp => currentSample.playPos;
			true => currentSample.play;
		}
	} else if ("stopButton" => nanoev.isControl) {
		if (nanoev.getBool())
			false => currentSample.play;
	} else if ("loopToggle" => nanoev.isControl) {
		/* toggles loop playing AND loop recording */
		nanoev.getBool() => currentSample.loop;
	} else if ("samplerVolumeKnob" => nanoev.isControl) {
		nanoev.getFloat(10) => currentSample.gain;
	} else if ("samplerPitchSlider" => nanoev.isControl) {
		nanoev.getFloat(-2, 2) => currentSample.rate;
	} else if (nanoev.CCId >= 23 && nanoev.CCId <= 29) {
		/* chooseSampleButton#CCId pressed */
		lisa[nanoev.CCId - 23] @=> currentSample;
	}
}
