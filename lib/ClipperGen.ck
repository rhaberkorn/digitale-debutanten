/*
 * clip signal using a Ghugen
 */
public class ClipperGen extends Chugen {
	fun float
	tick(float in)
	{
		return Math.max(Math.min(in, 1), -1);
	}
}
