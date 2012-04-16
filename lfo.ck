/*
 * Configurable LFOs
 */
UGen @lfo[2]; // FIXME: ChucK bug prevents elegant initialization
new SinOsc @=> lfo[0];
new PulseOsc @=> lfo[1];

Step lfo_freq;
for (0 => int i; i < lfo.cap(); i++)
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

			if (msg.data2 == 22)
				value => rev.gain;
			else if (msg.data2 == 13)
				100 + value*900 => base.next;
			else if (msg.data2 == 12)
				value*100 => lfo_gain.gain;
			else if (msg.data2 == 21)
				value*20 => lfo_freq.next;
			else if (msg.data2 == 31)
				change_lfo(0);
			else if (msg.data2 == 41)
				change_lfo(1);
			/*else if (msg.data2 == 9)
				value $ int => lfo.harmonics;*/
		}
	}
}
