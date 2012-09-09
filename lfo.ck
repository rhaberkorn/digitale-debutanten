/*
 * Configurable LFOs
 */
[new SinOsc, new PulseOsc, new SampOsc] @=> UGen @lfo[];
lfo[0] @=> UGen @cur_lfo;

//lfo[2] => Bus.oscope[0];
//0.1 => Bus.oscope[0].gain;

[new SawOsc, new PulseOsc] @=> UGen @osc[];
osc[0] @=> UGen @cur_osc;

Step lfo_freq => cur_lfo => Scale lfo_scale => cur_osc => Echo rev => Bus.out_left;
rev => Bus.out_right;

//50::ms => echo.delay;
//.3 => echo.mix;

0 => rev.gain;
1::second => rev.max;
500::ms => rev.delay;
0.5 => rev.mix;

10 => lfo_freq.next;
320 => float lfo_pitch;
80 => float lfo_depth;

lfo_scale.out(lfo_pitch, lfo_pitch+lfo_depth);

//10 => lfo.harmonics;

fun void
change_lfo(int new_lfo)
{
	/* unchuck current lfo */
	lfo_freq =< cur_lfo =< lfo_scale;
	/* chuck new lfo */
	lfo_freq => lfo[new_lfo] @=> cur_lfo => lfo_scale;

	if (new_lfo == 2 /* SampOsc */) {
		lfo_scale.in(0, 1);
		10 => lfo_scale.gain; /* value range [0, 1000] if pitch == 0 */
	} else {
		lfo_scale.in(-1, 1);
		1 => lfo_scale.gain;
	}
}

fun void
change_osc(int new_osc)
{
	/* unchuck current oscillator */
	lfo_scale =< cur_osc =< rev;
	/* chuck new oscillator */
	lfo_scale => osc[new_osc] @=> cur_osc => rev;
}

/*
 * LFO configuration via MIDI
 */
if (me.args() > 1)
	me.exit();

NanoEvent nanoev;

/* first param: scene name */
"primary" @=> nanoev.wantScene;
if (me.args() > 0)
	me.arg(0) @=> nanoev.wantScene;

while (nanoev => now) {
	if ("lfoVolumeKnob" => nanoev.isControl) {
		nanoev.getFloat() => rev.gain;
	} else if ("lfoPitchSlider" => nanoev.isControl) {
		nanoev.getFloat(0, 1000) => lfo_pitch;
		lfo_scale.out(lfo_pitch, lfo_pitch+lfo_depth);
	} else if ("lfoDepthSlider" => nanoev.isControl) {
		nanoev.getFloat(100) => lfo_depth;
		lfo_scale.out(lfo_pitch, lfo_pitch+lfo_depth);
	} else if ("lfoFreqKnob" => nanoev.isControl) {
		nanoev.getFloat(20) => lfo_freq.next;
	} else if ("lfoRateKnob" => nanoev.isControl) {
		/* sample rate for SampOsc */
		nanoev.getFloat(2) => (lfo[2] $ SampOsc).rate;
	} else if ("lfoSinOscButton" => nanoev.isControl) {
		if (nanoev.getBool())
			0 => change_lfo;
	} else if ("lfoPulseOscButton" => nanoev.isControl) {
		if (nanoev.getBool())
			1 => change_lfo;
	} else if ("lfoSampOscButton" => nanoev.isControl) {
		if (nanoev.getBool())
			2 => change_lfo;
	} else if ("lfoWaveToggle" => nanoev.isControl) {
		if (nanoev.getBool())
			1 => change_osc;
		else
			0 => change_osc;
	} else if ("lfoEchoSlider" => nanoev.isControl) {
		nanoev.getDur(second) => rev.delay;
	}
}
