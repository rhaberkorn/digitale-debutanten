/*
 * Configurable LFOs
 */
UGen @lfo[3]; // FIXME: ChucK bug prevents elegant initialization with [new ..., ...]
new SinOsc @=> lfo[0];
new PulseOsc @=> lfo[1];
new SampOsc @=> lfo[2];
10 => lfo[2].gain; /* preamp, to get value range 0 to 1000 */

Step lfo_freq;
for (0 => int i; i < 2 /*lfo.cap()*/; i++)
	lfo_freq => lfo[i];

0 => int cur_lfo;

/* s.freq = lfo.freq*lfo.gain + base.value */
lfo[cur_lfo] => Gain lfo_gain => SawOsc s => JCRev rev => Bus.out_left;
rev => Bus.out_right;
Step base => s;

//50::ms => echo.delay;
//.3 => echo.mix;

0.1 => rev.mix;
0.2 => rev.gain;

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

/*
 * LFO configuration via MIDI (Channel/Scene 0)
 */
/* FIXME: custom nanoKONTROL events */
if (me.args() > 1)
	me.exit();

1 => int device;
if (me.args() == 1)
	me.arg(0) => Std.atoi => device;

MidiIn min;

if (!min.open(device))
	me.exit();
<<< "MIDI device:", min.num(), " -> ", min.name() >>>;

while (min => now) {
	while (MidiMsg msg => min.recv) {
		msg.data1 & 0x0F => int channel;
		msg.data1 & 0xF0 => int cmd;
		(msg.data3 $ float)/127 => float value;

		if (channel == 0 && cmd == 0xB0) {
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
				change_lfo(0);
			} else if (msg.data2 == 41) {
				change_lfo(1);
			} else if (msg.data2 == 30) {
				change_lfo(2);
			}
			/*else if (msg.data2 == 9)
				value $ int => lfo.harmonics;*/
		}
	}
}
