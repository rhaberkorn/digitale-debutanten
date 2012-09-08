/*
 * Version of LiSa that supports reading in files (like a SndBuf)
 * LiSa supports only one channel so mixing can be performed
 */
public class LiSaX extends LiSa {
	/*
	 * Read in file, mixing its channels using a gain vector
	 * mix == null means to mix all of the channels with gain 1/channels
	 */
	fun void
	read(string file, float mix[])
	{
		SndBuf buf;

		file => buf.read;
		/*
		 * buf.samples() returns number of frames
		 * (i.e. samples in one channel)
		 */
		buf.samples()::samp => duration;

		for (0 => int frame; frame < buf.samples(); frame++) {
			0 => float v;

			for (0 => int c; c < buf.channels(); c++) {
				float g;

				if (mix == null)
					1.0/buf.channels() => g;
				else
					mix[c] => g;
				buf.valueAt(frame*buf.channels() + c)*g +=> v;
			}

			valueAt(v, frame::samp);
		}
	}

	/*
	 * Read in file, mixing its channels equally
	 */
	fun void
	read(string file)
	{
		read(file, null);
	}
}
