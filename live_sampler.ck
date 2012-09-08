/*
 * Live (and stock) sampler based on LiSaX (LiSa)
 * in-port: Bus.channels[0]
 */

LiSaX lisa[7];
Gain amp => Bus.out_left;
amp => Bus.out_right;

/* stock samples */
"samples/stier_loop.wav" => lisa[0].read;

for (0 => int i; i < lisa.cap(); i++) {
	if (lisa[i].duration() == 0::samp) {
		30::second => lisa[i].duration;
	} else {
		lisa[i].duration() => lisa[i].loopEnd;
		lisa[i].duration() => lisa[i].loopEndRec;
	}
	0 => lisa[i].loop;
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
		if (nanoev.getBool()) {
			if (!currentSample.loop() ||
			    currentSample.loopEndRec() == 0::samp) {
				currentSample.duration() => currentSample.loopEndRec;
				currentSample.clear();
			} else {
				currentSample.loopEnd() => currentSample.loopEndRec;
			}
			0::samp => currentSample.recPos;
		} else if (!currentSample.loopRec() ||
			   currentSample.loopEnd() == 0::samp) {
			currentSample.recPos() => currentSample.loopEnd;
		}

		if (currentSample.loop()) {
			nanoev.getBool() => currentSample.loopRec;
		} else
			nanoev.getBool() => currentSample.record;
	} else if ("playButton" => nanoev.isControl) {
		if (nanoev.getBool()) {
			0::samp => currentSample.playPos;
			1 => currentSample.play;
		}
	} else if ("stopButton" => nanoev.isControl) {
		if (nanoev.getBool())
			0 => currentSample.play;
	} else if ("loopToggle" => nanoev.isControl) {
		nanoev.getBool() => currentSample.loop;
	} else if ("samplerVolumeKnob" => nanoev.isControl) {
		nanoev.getFloat(10) => currentSample.gain;
	} else if ("samplerPitchSlider" => nanoev.isControl) {
		nanoev.getFloat(2) => currentSample.rate;
	} else if (nanoev.CCId >= 23 && nanoev.CCId <= 29) {
		/* chooseSampleButton#CCId pressed */
		lisa[nanoev.CCId - 23] @=> currentSample;
	}
}
