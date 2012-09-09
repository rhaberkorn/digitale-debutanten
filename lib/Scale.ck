/*
 * Scale input samples in configurable range to configurable output range
 */
public class Scale extends Chubgraph {
	inlet => outlet;
	Step __base => outlet;	/* pseudo-private */

	-1 => float __in_from;	/* pseudo-private */
	1 => float __in_to;	/* pseudo-private */

	-1 => float __out_from;	/* pseudo-private */
	1 => float __out_to;	/* pseudo-private */

	fun void
	__update() /* pseudo-private */
	{
		(__out_to-__out_from)/(__in_to-__in_from) => inlet.gain;
		__out_from - __in_from*inlet.gain() => __base.next;
	}

	fun float
	in(float from, float to)
	{
		from => __in_from;
		to => __in_to;
		__update();

		return to;
	}
	fun float
	in(float to)
	{
		return in(0, to);
	}

	fun float
	out(float from, float to)
	{
		from => __out_from;
		to => __out_to;
		__update();

		return to;
	}
	fun float
	out(float to)
	{
		return out(0, to);
	}

	/* not strictly necessary with current default values */
	__update();
}
