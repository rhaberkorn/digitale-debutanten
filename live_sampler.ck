/*
 * Live (and stock) sampler based on LiSa
 */
LiSaX lisa[7];

/* stock samples */
"samples/stier_loop.wav" => lisa[0].read;

for (0 => int i; i < lisa.cap(); i++) {
	if (lisa[i].duration() == 0::samp)
		10::second => lisa[i].duration;
	lisa[i].duration() => lisa[i].loopEnd;
	lisa[i].duration() => lisa[i].loopEndRec;
	0 => lisa[i].loop;
}

for (0 => int i; i < lisa.cap(); i++) {
	Bus.channels[0] => lisa[i] => Bus.out_left;
	lisa[i] => Bus.out_right;
}

lisa[0] @=> LiSaX @currentSample;

/*
 * Sampler configuration
 */
"primary" => NanoEvent.init @=> NanoEvent @nanoev;

while (nanoev => now) {
	if ("recordToggle" => nanoev.isControl) {
		if (nanoev.getBool()) {
			currentSample.loop() => currentSample.loopRec;
			currentSample.loopEnd() => currentSample.loopEndRec;
			0::samp => currentSample.recPos;
		} else if (!currentSample.loopRec() ||
			   currentSample.loopEnd() == 0::samp) {
			currentSample.recPos() => currentSample.loopEnd;
		}
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
	} else if (nanoev.CCId >= 23 && nanoev.CCId <= 29) {
		/* chooseSampleButton#CCId pressed */
		lisa[nanoev.CCId - 23] @=> currentSample;
	}
}
