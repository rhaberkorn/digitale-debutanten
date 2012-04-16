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

	/* FIXME: not independant from cwd when instantiated */
	"lib/pulse.wav" => read;
	1 => rate;

	fun void __loop() /* pseudo-private */
	{
		while (second/__freq => now)
			0 => pos;
	}
	spork ~ __loop();
}
