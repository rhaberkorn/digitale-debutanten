/*
 * contact mic
 * digital feedback loop
 */
Clipper clipper;
adc.chan(0) => Gain pregain => Echo echo => Gain amp => clipper.input;
clipper.output => Bus.out_left;
clipper.output => Bus.out_right;
clipper.output => Delay del => amp;

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
/* FIXME: custom nanoKONTROL events */
if (me.args() > 0)
	me.exit();

/* fixed to Scene 1 */
0 => int on_channel;

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

			if (msg.data2 == 14) {
				value*0.4 + 0.1 => del.gain;
			} else if (msg.data2 == 2) {
				value*10::ms => del.delay;
			} else if (msg.data2 == 3) {
				value*10 + 1 => pregain.gain;
			} else if (msg.data2 == 15) {
				value*4 + 1 => amp.gain;
			}
		}
	}
}