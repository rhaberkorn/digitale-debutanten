/*
 * ChucK is so buggy, it hurts...
 * You just cannot declare plain static string arrays, so
 * we must wrap them in "real" objects
 */
class String {
	string v;
}
class StringArray {
	String @v[];
}

/*
 * nanoKONTROL event class
 */
public class NanoEvent extends Event {
	/* map channel (0-15) to scene name */
	static String @__channelToScene[]; /* pseudo-private */
	/* map scene name and control id (0-255) to control name */
	static StringArray @__controlToName[]; /* pseudo-private */

	string wantScene;

	string scene;
	string control;
	int CCId;
	float value;

	fun int
	isScene(string s)
	{
		return scene == s;
	}
	fun int
	isControl(string c)
	{
		return control == c;
	}

	fun float
	getFloat()
	{
		return value;
	}
	fun float
	getFloat(float max)
	{
		return max*value;
	}
	fun float
	getFloat(float min, float max)
	{
		return min + (max - min)*value;
	}

	fun dur
	getDur(dur max)
	{
		return max*value;
	}
	fun dur
	getDur(dur min, dur max)
	{
		return min + (max - min)*value;
	}

	fun int
	getBool()
	{
		return value $ int;
	}

	fun void
	__midi_loop(int device) /* pseudo-private */
	{
		MidiIn min;

		if (!min.open(device)) {
			<<< "Cannot open MIDI device", device >>>;
			me.exit();
		}

		while (min => now) {
			while (MidiMsg msg => min.recv) {
				__channelToScene[msg.data1 & 0x0F].v @=> scene;
				if (scene == null) {
					<<< "Unknown channel", msg.data1 & 0x0F >>>;
					msg.data1 & 0x0F => Std.itoa @=> scene;
				}

				msg.data1 & 0xF0 => int cmd;
				msg.data2 => CCId;

				__controlToName[scene].v[CCId].v @=> control;
				if (control == null) {
					<<< "Unknown controller", CCId >>>;
					CCId => Std.itoa @=> control;
				}

				(msg.data3 $ float)/127 => value;

				if (cmd == 0xB0 && (wantScene == null || scene == wantScene))
				    	broadcast();
			}
		}
	}
	/* always open MIDI Through port, actual connection is done by Jack */
	spork ~ __midi_loop(0);

	fun static NanoEvent @
	init(string scene) /* pseudo-constructor */
	{
		NanoEvent obj;

		scene @=> obj.wantScene;

		return obj;
	}

	fun static void
	registerScene(int channel, string name)
	{
		name @=> __channelToScene[channel].v;
		new StringArray @=> __controlToName[name];
		new String[0x100] @=> __controlToName[name].v;
	}

	fun static void
	registerControl(string sceneName, int id, string controlName)
	{
		controlName @=> __controlToName[sceneName].v[id].v;
	}
}
/* static initialization */
new String[0x10] @=> NanoEvent.__channelToScene;
new StringArray[0] @=> NanoEvent.__controlToName;

/*
 * global mappings
 */

NanoEvent.registerScene(0, "primary");
NanoEvent.registerScene(1, "secondary");
NanoEvent.registerScene(3, "oscope");

NanoEvent.registerControl("primary", 14, "feedbackDistKnob");
NanoEvent.registerControl("primary", 02, "feedbackPitchSlider");
NanoEvent.registerControl("primary", 03, "feedbackPregainSlider");
NanoEvent.registerControl("primary", 15, "feedbackGainKnob");

for (23 => int i; i <= 29; i++)
	NanoEvent.registerControl("primary", i, "chooseSampleButton#"+i);

fun void
registerLFO(string scene)
{
	NanoEvent.registerControl(scene, 22, "lfoVolumeKnob");
	NanoEvent.registerControl(scene, 13, "lfoPitchSlider");
	NanoEvent.registerControl(scene, 12, "lfoDepthSlider");
	NanoEvent.registerControl(scene, 21, "lfoFreqKnob");
	NanoEvent.registerControl(scene, 31, "lfoSinOscButton");
	NanoEvent.registerControl(scene, 41, "lfoPulseOscButton");
	NanoEvent.registerControl(scene, 30, "lfoSampOscButton");
	NanoEvent.registerControl(scene, 40, "lfoWaveToggle");
	NanoEvent.registerControl(scene, 09, "lfoEchoSlider");
}
"primary" => registerLFO;
"secondary" => registerLFO;

fun void
registerTransport(string scene)
{
	NanoEvent.registerControl(scene, 44, "recordToggle");
	NanoEvent.registerControl(scene, 45, "playButton");
	NanoEvent.registerControl(scene, 46, "stopButton");
	NanoEvent.registerControl(scene, 49, "loopToggle");
}
"primary" => registerTransport;
"secondary" => registerTransport;

NanoEvent.registerControl("oscope", 67, "modeToggle");
NanoEvent.registerControl("oscope", 76, "fillToggle");
NanoEvent.registerControl("oscope", 42, "frameSlider");
NanoEvent.registerControl("oscope", 57, "delayKnob");
