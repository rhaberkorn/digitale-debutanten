/*
 * clip signal within -1 to 1 using a Ghugen
 */
public class Clipper extends Chugen {
	fun float
	tick(float in)
	{
		return Math.max(Math.min(in, 1), -1);
	}
}
