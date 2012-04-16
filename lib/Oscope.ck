/*
 * Oscilloscope (jack.scope) helpers
 */
public class Oscope {
	static OscSend @jack_scope;

	/*
	 * "signal" or "embed"
	 */
	fun static void
	mode(string m)
	{
		jack_scope.startMsg("/mode", "s");
		m => jack_scope.addString;
	}

	/*
	 * "dot", "fill" or "line"
	 */
	fun static void
	style(string s)
	{
		jack_scope.startMsg("/style", "s");
		s => jack_scope.addString;
	}

	fun static void
	frames(dur f)
	{
		// <<< "set frame size:", (f / samp) $ int >>>;
		jack_scope.startMsg("/frames", "i");
		(f / samp) $ int => jack_scope.addInt;
	}

	fun static void
	delay(dur d)
	{
		// <<< "set delay length:", d / ms >>>;
		jack_scope.startMsg("/delay", "f");
		d / ms => jack_scope.addFloat;
	}

	/*
	 * "sample delay" in "embed" mode
	 * Can this be a ChucK duration???
	 */
	fun static void
	embed(int em)
	{
		jack_scope.startMsg("/embed", "i");
		em => jack_scope.addInt;
	}

	fun static void
	incr(float i)
	{
		jack_scope.startMsg("/incr", "f");
		i => jack_scope.addFloat;
	}
}
/* initialization */
new OscSend @=> Oscope.jack_scope;
Oscope.jack_scope.setHost("localhost", 57140);

"signal" => Oscope.mode;
"line" => Oscope.style;
512::samp => Oscope.frames;
100::ms => Oscope.delay;

/*
 * connect oscilloscope Bus channels to dedicated output ports that are patched
 * to jack.scope
 */
for (0 => int i; i < Bus.oscope.cap(); i++)
	Bus.oscope[i] => dac.chan(4 + i);

/*
 * jack.scope configuration via MIDI (Channel/Scene 1)
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

		if (channel == 1 && cmd == 0xB0) {
			<<< "Channel:", channel, "Command:", cmd, "Controller:", msg.data2, "Value:", value >>>;

			if (msg.data2 == 67) {
				if (value $ int)
					"embed" => Oscope.mode;
				else
					"signal" => Oscope.mode;
			} else if (msg.data2 == 76) {
				if (value $ int)
					"fill" => Oscope.style;
				else
					"line" => Oscope.style;
			} else if (msg.data2 == 42) {
				512::samp + value*2::second => Oscope.frames;
			} else if (msg.data2 == 57) {
				50::ms + value*second => Oscope.delay;
			}
		}
	}
}
