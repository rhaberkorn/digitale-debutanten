/*
 * BUG WORKAROUND:
 * Base class for all Chubgraphs,
 * necessary because some default methods are unimplemented in the
 * Chubgraph class
 */
public class ChubgraphStd extends Chubgraph {
	fun float
	gain(float g)
	{
		return g => outlet.gain;
	}

	fun float
	gain()
	{
		return outlet.gain();
	}

	fun float
	last()
	{
		return outlet.last();
	}
}
