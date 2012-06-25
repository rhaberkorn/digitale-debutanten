/*
 * Version of LiSa that supports reading in files (like a SndBuf)
 */
public class LiSaX extends LiSa {
	fun void
	read(string file)
	{
		SndBuf buf;

		file => buf.read;
		buf.samples()::samp => duration;

		for (0 => int i; i < buf.samples(); i++)
			valueAt(i => buf.valueAt, i::samp);
	}
}
