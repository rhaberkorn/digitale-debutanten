class RecEvent {
	dur pit;
	MidiMsg @msg;
}
Queue buffer;

/* FIXME: custom nanoKONTROL events */
if (me.args() > 0)
	me.exit();

MidiOut mout;
MidiIn min;

/* always open MIDI Through port, actual connection is done by Jack */
if (!min.open(0))
	me.exit();
if (!mout.open(0))
	me.exit();

<<< "MIDI device:", min.num(), " -> ", min.name() >>>;

1 => int on_channel; /* Scene 2 */

false => int recording;
time start;

false => int looping;

fun void
do_playback(int looping)
{
	if (buffer.peek() == null)
		return;

	while (true) {
		for (buffer.head.next @=> Element @cur; cur != null; cur.next @=> cur) {
			cur.payload $ RecEvent @=> RecEvent @recev;

			recev.pit => now;
			recev.msg => mout.send;

			<<< "PLAY Channel:", recev.msg.data1 & 0x0F,
			    "Command:", recev.msg.data1 & 0xF0,
			    "Controller:", recev.msg.data2,
			    "Value:", (recev.msg.data3 $ float)/127 >>>;
		}

		if (!looping)
			break;
	}

	<<< "PLAY FIN", 1 >>>;
}
Shred @playback_shred;

while (min => now) {
	while (MidiMsg msg => min.recv) {
		msg.data1 & 0x0F => int channel;
		msg.data1 & 0xF0 => int cmd;
		(msg.data3 $ float)/127 => float value;
		//<<< "Channel:", channel, "Command:", cmd, "Controller:", msg.data2, "Value:", value >>>;

		channel == on_channel && cmd == 0xB0 => int is_cmd;

		if (is_cmd && msg.data2 == 44) {
			if (value $ int => recording) {
				now => start;
				buffer.flush();
			}
		} else if (is_cmd && msg.data2 == 45) {
			if (value $ int) {
				if (playback_shred != null)
					playback_shred.exit();
				spork ~ do_playback(looping) @=> playback_shred;
			}
		} else if (is_cmd && msg.data2 == 46) {
			if (value $ int && playback_shred != null) {
				playback_shred.exit();
				null @=> playback_shred;
			}
		} else if (is_cmd && msg.data2 == 49) {
			value $ int => looping;
		} else if (recording) {
			<<< "REC Channel:", channel, "Command:", cmd, "Controller:", msg.data2, "Value:", value >>>;

			RecEvent recev => buffer.push;
			now - start => recev.pit;
			msg @=> recev.msg;

			now => start;
		}
	}
}