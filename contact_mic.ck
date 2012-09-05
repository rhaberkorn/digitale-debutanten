/*
 * contact mic
 * digital feedback loop
 */
adc.chan(0) => Gain pregain => Echo echo => Gain amp => Clipper clipper;
clipper => Delay del => amp;
clipper => Gain master => Bus.out_left; master => Bus.out_right;
clipper => Bus.channels[0]; // live-sampler

0.5 => master.gain;

// mic pre-amplification - don't contribute to feedback loop
6 => pregain.gain;

1::second => echo.max;
100::ms => echo.delay;
0.8 => echo.mix;

// feedback loop amp
3 => amp.gain;

// delay line: delay influences feedback pitch
1::second => del.max;
1::ms => del.delay;

// simulate speaker<->mic distance
0.324 => del.gain;

/*
 * record player
 */
adc.chan(1) => Bus.out_left;
adc.chan(1) => Bus.out_right;

/*
 * Mic/effect configuration via MIDI
 */

"primary" => NanoEvent.init @=> NanoEvent @nanoev;

while (nanoev => now) {
	if ("feedbackDistKnob" => nanoev.isControl) {
		nanoev.getFloat(0.1, 0.5) => del.gain;
	} else if ("feedbackPitchSlider" => nanoev.isControl) {
		nanoev.getDur(10::ms) => del.delay;
	} else if ("feedbackPregainSlider" => nanoev.isControl) {
		nanoev.getFloat(1, 10) => pregain.gain;
	} else if ("feedbackGainKnob" => nanoev.isControl) {
		nanoev.getFloat(1, 5) => amp.gain;
	}
}
