/*
 * Sample based oscillator
 * NOTE: may not be frequency-synced!
 */
public class SampOsc extends SndBuf {
	1 => float __freq; /* pseudo-private */

	fun float freq(float f)
	{
		return f => __freq;
	}
	fun float freq()
	{
		return __freq;
	}

	/*
	 * Wait till next loop point but no longer than 100::ms,
	 * so frequency changes get applied with a maximum of 100::ms latency.
	 * NOTE: Due to a ChucK bug, simply killing and restarting the shred
	 * does not work very well.
	 */
	fun void __loop() /* pseudo-private */
	{
		now => time last_trigger;

		while (second/__freq => dur interval) {
			if (last_trigger+interval - now > 100::ms) {
				100::ms => now;
			} else {
				interval +=> last_trigger;
				if (last_trigger >= now)
					last_trigger => now;
				0 => pos;
			}
		}
	}
	spork ~ __loop();

	/* FIXME: not independant from cwd when instantiated */
	"lib/pulse.wav" => read;
	1 => rate;
}
