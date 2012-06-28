/*
 * Version of LiSa that supports reading in files (like a SndBuf)
 */
public class LiSaX extends LiSa {
	fun void
	read(string file)
	{
		SndBuf buf;

		file => buf.read;
		/* buf.samples() returns number of frames (or samples in one channel) */
		buf.samples()::samp => duration;

		for (0 => int i; i < buf.samples(); i++)
			/*
			 * Only get the first channel's data.
			 * Still broken for stereo files probably because a
			 * ChucK bug prevents buf.valueAt(i) to work for
			 * i > buf.samples()
			 */
			valueAt(i * buf.channels() => buf.valueAt, i::samp);
	}
}
