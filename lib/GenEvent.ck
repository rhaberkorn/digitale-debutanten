/*
 * Base class for controller events
 */
public class GenEvent extends Event {
	/* normalized value between [0, 1] */
	float value;

	/*
	 * Getter functions to scale `value'
	 */
	fun float
	getFloat()
	{
		return value;
	}
	fun float
	getFloat(float max)
	{
		return max*value;
	}
	fun float
	getFloat(float min, float max)
	{
		return min + (max - min)*value;
	}

	fun dur
	getDur(dur max)
	{
		return max*value;
	}
	fun dur
	getDur(dur min, dur max)
	{
		return min + (max - min)*value;
	}

	fun int
	getBool()
	{
		return value $ int;
	}
}
