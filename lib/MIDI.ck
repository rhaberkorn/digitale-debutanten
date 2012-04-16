/*
 * Global MIDI tools
 */
public class MIDI {
	static int channels;

	static int noteOff;
	static int noteOn;

	fun static int
	isCmd(int data, int cmd)
	{
		return data >= cmd && data < cmd + channels;
	}
}
0x10 => MIDI.channels;
0x80 => MIDI.noteOff;
0x90 => MIDI.noteOn;
