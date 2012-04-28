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
/* FIXME: custom nanoKONTROL events */
if (me.args() > 1)
	me.exit();

/* first param: scene number */
0 => int on_channel;
if (me.args() > 0)
	(me.arg(0) => Std.atoi)-1 => on_channel;
if (on_channel < 0 || on_channel > 3)
	me.exit();

MidiIn min;

/* always open MIDI Through port, actual connection is done by Jack */
if (!min.open(0))
	me.exit();
<<< "MIDI device:", min.num(), " -> ", min.name() >>>;

while (min => now) {
	while (MidiMsg msg => min.recv) {
		msg.data1 & 0x0F => int channel;
		msg.data1 & 0xF0 => int cmd;
		(msg.data3 $ float)/127 => float value;

		if (channel == on_channel && cmd == 0xB0) {
			<<< "Channel:", channel, "Command:", cmd, "Controller:", msg.data2, "Value:", value >>>;

			if (msg.data2 == 22) {
				value => rev.gain;
			} else if (msg.data2 == 13) {
				100 + value*900 => base.next;
				/* base freq slider is sample rate for SampOsc */
				value*2 => (lfo[2] $ SampOsc).rate;
			} else if (msg.data2 == 12) {
				value*100 => lfo_gain.gain;
			} else if (msg.data2 == 21) {
				/* setting lfo_freq does not influence SampOsc! */
				value*20 => lfo_freq.next => (lfo[2] $ SampOsc).freq;
			} else if (msg.data2 == 31) {
				if (value $ int)
					0 => change_lfo;
			} else if (msg.data2 == 41) {
				if (value $ int)
					1 => change_lfo;
			} else if (msg.data2 == 30) {
				if (value $ int)
					2 => change_lfo;
			} else if (msg.data2 == 40) {
				if (value $ int)
					1 => change_osc;
				else
					0 => change_osc;
			} else if (msg.data2 == 9) {
				value*second => rev.delay;
			}
			/*else if (msg.data2 == 9)
				value $ int => lfo.harmonics;*/
		}
	}
}
