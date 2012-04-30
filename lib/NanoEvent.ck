/*
 * nanoKONTROL event class
 */
public class NanoEvent extends Event {
	/* map channel (0-15) to scene name */
	static string @channelToScene[];
	/* map scene name and control id (0-255) to control name */
	static string @controlToName[][];

	string wantScene;

	string scene;
	string control;
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
				channelToScene[msg.data1 & 0x0F] @=> scene;
				if (scene == null) {
					<<< "Unknown channel", msg.data & 0x0F >>>;
					msg.data1 & 0x0F => Std.itoa @=> scene;
				}

				msg.data1 & 0xF0 => int cmd;

				controlToName[scene][msg.data2] @=> control;
				if (control == null) {
					<<< "Unknown controller", msg.data2 >>>;
					msg.data2 => Std.itoa @=> control;
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
	new(string scene)
	{
		NanoEvent obj;

		scene @=> obj.wantScene;

		return obj;
	}

	fun static void
	registerScene(int channel, string name)
	{
		name @=> channelToScene[channel];
	}

	fun static void
	registerControl(string sceneName, int id, string controlName)
	{
		controlName @=> controlToName[sceneName][id];
	}
}
/* static initialization */
new string[0x0F] @=> NanoEvent.channelToScene;
new string[0][0xFF] @=> NanoEvent.controlToName;

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

NanoEvent.registerControl("secondary", 44, "recordToggle");
NanoEvent.registerControl("secondary", 45, "playButton");
NanoEvent.registerControl("secondary", 46, "stopButton");
NanoEvent.registerControl("secondary", 49, "loopToggle");

NanoEvent.registerControl("oscope", 67, "modeToggle");
NanoEvent.registerControl("oscope", 76, "fillToggle");
NanoEvent.registerControl("oscope", 42, "frameSlider");
NanoEvent.registerControl("oscope", 57, "delayKnob");
