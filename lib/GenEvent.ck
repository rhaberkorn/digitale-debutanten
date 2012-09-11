/*
 * Base class for controller events
 */
public class GenEvent extends Event {
	class Port extends Step {
		fun void
		update(GenEvent @ev, string control)
		{
			while (ev => now)
				if (control => ev.isControl)
					ev.getFloat(-1, 1) => next;
			/* never reached */
		}
	}

	/* symbolic control name */
	string control;
	/* normalized control value between [0, 1] */
	float value;

	fun int
	isControl(string c)
	{
		return control == c;
	}

	/*
	 * Create and return UGen that generates a control's value,
	 * normalized between [-1, 1]
	 */
	fun Step @
	getPort(string control)
	{
		Port p;
		spork ~ p.update(this, control);

		return p;
	}

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
