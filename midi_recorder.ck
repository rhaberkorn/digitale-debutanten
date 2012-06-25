class RecEvent {
	dur pit;
	MidiMsg @msg;

	fun static RecEvent @
	new(dur pit, MidiMsg @msg)
	{
		RecEvent obj;

		pit => obj.pit;
		msg @=> obj.msg;

		return obj;
	}
}
List buffer;

MidiOut mout;
MidiIn min;

/* always open MIDI Through port, actual connection is done by Jack */
if (!min.open(0))
	me.exit();
if (!mout.open(0))
	me.exit();
<<< "MIDI device:", min.num(), " -> ", min.name() >>>;

false => int looping;

fun void
do_recording()
{
	buffer.flush();
	now => time start;

	while (min => now) {
		while (MidiMsg msg => min.recv) {
			<<< "REC Channel:", recev.msg.data1 & 0x0F,
			    "Command:", recev.msg.data1 & 0xF0,
			    "Controller:", recev.msg.data2,
			    "Value:", (recev.msg.data3 $ float)/127 >>>;

			RecEvent.new(now - start, msg) => buffer.put;
			now => start;
		}
	}
}
Shred @recording_shred;

fun void
do_playback(int looping)
{
	if (buffer.getHead() == null)
		return;

	while (true) {
		for (buffer.head.next @=> Element @cur; cur != null; cur.next @=> cur) {
			cur.payload $ RecEvent @=> RecEvent @recev;

			recev.pit => now;
			recev.msg => mout.send;

			<<< "PLAY Channel:", recev.msg.data1 & 0x0F,
			    "Command:", recev.msg.data1 & 0xF0,
			    "Controller:", recev.msg.data2,
			    "Value:", (recev.msg.data3 $ float)/127 >>>;
		}

		if (!looping)
			break;
	}
}
Shred @playback_shred;

/*
 * Recorder configuration via MIDI
 */
"secondary" => NanoEvent.init @=> NanoEvent @nanoev;

while (nanoev => now) {
	if ("recordToggle" => nanoev.isControl) {
		if (nanoev.getBool()) {
			if (recording_shred != null)
				recording_shred.exit();
			spork ~ do_recording() @=> recording_shred;
		} else if (recording_shred != null) {
			recording_shred.exit();
			null @=> recording_shred;

			/* remove recordToggle event from buffer queue */
			buffer.pop();
		}
	} else if ("playButton" => nanoev.isControl) {
		if (nanoev.getBool()) {
			if (playback_shred != null)
				playback_shred.exit();
			spork ~ do_playback(looping) @=> playback_shred;
		}
	} else if ("stopButton" => nanoev.isControl) {
		if (nanoev.getBool() && playback_shred != null) {
			playback_shred.exit();
			null @=> playback_shred;
		}
	} else if ("loopToggle" => nanoev.isControl) {
		nanoev.getBool() => looping;
	}
}
