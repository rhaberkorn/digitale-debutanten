/*
 * Configurable LFOs
 */
UGen @lfo[3]; // FIXME: ChucK bug prevents elegant initialization with [new ..., ...]
new SinOsc @=> lfo[0];
new PulseOsc @=> lfo[1];
new SampOsc @=> lfo[2];
10 => lfo[2].gain; /* preamp, to get value range 0 to 1000 */

//lfo[2] => Bus.oscope[0];
//0.1 => Bus.oscope[0].gain;

Step lfo_freq;
for (0 => int i; i < 2 /*lfo.cap()*/; i++)
	lfo_freq => lfo[i];

0 => int cur_lfo;

UGen @osc[2];
new SawOsc @=> osc[0];
new PulseOsc @=> osc[1];

0 => int cur_osc;

/* s.freq = lfo.freq*lfo.gain + base.value */
lfo[cur_lfo] => Gain lfo_gain => Gain lfo_dummy => osc[cur_osc] => Echo rev => Bus.out_left;
rev => Bus.out_right;
Step base => lfo_dummy;

//50::ms => echo.delay;
//.3 => echo.mix;

1::second => rev.max;
500::ms => rev.delay;
0.5 => rev.mix;

10 => lfo_freq.next;
400 => base.next;
80 => lfo_gain.gain;

//10 => lfo.harmonics;

fun void
change_lfo(int new_lfo)
{
	/* unchuck lfo */
	lfo[cur_lfo] =< lfo_gain;
	/* rechuck lfo */
	lfo[new_lfo => cur_lfo] => lfo_gain;

	if (cur_lfo == 2 /* SampOsc */) {
		/* switch off base freq */
		0 => base.gain;
	} else {
		1 => base.gain;
	}
}

fun void
change_osc(int new_osc)
{
	lfo_dummy =< osc[cur_osc] =< rev;
	lfo_dummy => osc[new_osc => cur_osc] => rev;
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
		nanoev.getFloat(100, 1000) => base.next;
		/* base freq slider is sample rate for SampOsc */
		nanoev.getFloat(2) => (lfo[2] $ SampOsc).rate;
	} else if ("lfoDepthSlider" => nanoev.isControl) {
		nanoev.getFloat(100) => lfo_gain.gain;
	} else if ("lfoFreqKnob" => nanoev.isControl) {
		/* setting lfo_freq does not influence SampOsc! */
		nanoev.getFloat(20) => lfo_freq.next => (lfo[2] $ SampOsc).freq;
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
