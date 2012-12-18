/*
 * soft-clip a signal within -1 to 1 using a Ghugen
 */
public class SoftClipper extends Chugen {
	fun float
	tick(float in)
	{
		return Math.atan(in*2)/(Math.PI/2);
	}
}
