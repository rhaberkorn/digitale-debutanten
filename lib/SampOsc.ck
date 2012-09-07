/*
 * Sample based oscillator
 */
public class SampOsc extends Chubgraph {
	static string @__sourceDir; /* pseudo-private */

	inlet => blackhole;
	inlet.last() => float __last_in; /* pseudo-private */
	1 => float __freq; /* pseudo-private */
	SndBuf __buf => outlet; /* pseudo-private */

	fun float
	freq(float f)
	{
		return f => __freq;
	}
	fun float
	freq()
	{
		if (inlet.last() != __last_in)
			inlet.last() => __last_in => __freq;
		return __freq;
	}

	/*
	 * __buf shortcuts
	 */
	fun void
	read(string file)
	{
		file => __buf.read;
	}
	fun float
	rate(float v)
	{
		return v => __buf.rate;
	}
	fun float
	rate()
	{
		return __buf.rate();
	}

	/*
	 * Wait till next loop point but no longer than `max_latency',
	 * so frequency changes get applied with a maximum of 100::ms latency.
	 * NOTE: Due to a ChucK bug (?), simply killing and restarting the shred
	 * does not work very well.
	 */
	100::ms => dur max_latency;

	fun void
	__loop() /* pseudo-private */
	{
		now => time last_trigger;

		while (second/freq() => dur interval) {
			if (last_trigger+interval - now > max_latency) {
				max_latency => now;
			} else {
				interval +=> last_trigger;
				if (last_trigger > now)
					last_trigger => now;
				0 => __buf.pos;
			}
		}

		/* never reached */
	}
	spork ~ __loop();

	__sourceDir+"/pulse.wav" => read;
	1 => rate;
}
/* static initialization */
me.sourceDir() => SampOsc.__sourceDir;
/* BUG WORKAROUND: me.sourceDir() == "" if VM is started with --loop */
if (SampOsc.__sourceDir == "")
	"lib" => SampOsc.__sourceDir;
