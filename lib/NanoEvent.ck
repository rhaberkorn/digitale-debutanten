/*
 * nanoKONTROL event class
 */
public class NanoEvent extends Event {
	/* map channel (0-15) to scene name */
	static string @__channelToScene[]; /* pseudo-private */
	/* map scene name and control id (0-255) to control name */
	static string @__controlToName[][]; /* pseudo-private */

	class Port extends Step {
		fun void
		fetch(int device, string scene, string control)
		{
			MidiIn min;

			if (!min.open(device)) {
				cherr <= "Cannot open MIDI device " <= device
				      <= IO.newline();
				me.exit();
			}
			chout <= "Opened MIDI device " <= device <= " (" <= min.name() <= ")"
			      <= IO.newline();

			while (min => now) {
				while (MidiMsg msg => min.recv) {
					if (NanoEvent.__channelToScene[msg.data1 & 0x0F] == scene &&
					    NanoEvent.__controlToName[scene] != null &&
					    NanoEvent.__controlToName[scene][msg.data2] == control)
						msg.data3*2/127.0 - 1 => next;
				}
			}
			/* not reached */
		}
	}

	/* by default open MIDI Through port, actual connection is done by Jack */
	0 => int device;
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

	fun Step @
	getPort(string control)
	{
		if (wantScene == "")
			return null;

		Port p;
		spork ~ p.fetch(device, wantScene, control);
		return p;
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
	__midi_loop() /* pseudo-private */
	{
		MidiIn min;

		if (!min.open(device)) {
			cherr <= "Cannot open MIDI device " <= device
			      <= IO.newline();
			me.exit();
		}
		chout <= "Opened MIDI device " <= device <= " (" <= min.name() <= ")"
		      <= IO.newline();

		while (min => now) {
			while (MidiMsg msg => min.recv) {
				__channelToScene[msg.data1 & 0x0F] @=> scene;
				if (scene == "") {
					cherr <= "Unknown channel "
					      <= (msg.data1 & 0x0F)
					      <= IO.newline();
					msg.data1 & 0x0F => Std.itoa @=> scene;
				}

				msg.data1 & 0xF0 => int cmd;
				msg.data2 => CCId;

				if (__controlToName[scene] != null)
					__controlToName[scene][CCId] @=> control;
				else
					"" @=> control;
				if (control == "") {
					cherr <= "Unknown controller " <= CCId
					      <= IO.newline();
					CCId => Std.itoa @=> control;
				}

				msg.data3/127.0 => value;

				if (cmd == 0xB0 &&
				    (wantScene == "" || scene == wantScene))
				    	broadcast();
			}
		}
	}
	spork ~ __midi_loop();

	fun static NanoEvent @
	init(int device, string scene) /* pseudo-constructor */
	{
		NanoEvent obj;

		device => obj.device;
		scene @=> obj.wantScene;

		return obj;
	}
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
		if (__channelToScene[channel] != "")
			cherr <= "Warning: Already registered channel "
			      <= channel <= IO.newline();
		if (__controlToName[name] != null)
			cherr <= "Warning: Already registered scene name \""
			      <= name <= "\"" <= IO.newline();

		name @=> __channelToScene[channel];
		new string[0x100] @=> __controlToName[name];
	}

	fun static void
	registerControl(string sceneName, int id, string controlName)
	{
		if (__controlToName[sceneName][id] != "")
			cherr <= "Warning: Already registered control " <= id
			      <= " on scene \"" <= sceneName <= "\""
			      <= IO.newline();

		controlName @=> __controlToName[sceneName][id];
	}
}
/* static initialization */
new string[0x10] @=> NanoEvent.__channelToScene;
new string[0][0x100] @=> NanoEvent.__controlToName;

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
	NanoEvent.registerControl("primary", i, "samplerBankButton#"+i);
NanoEvent.registerControl("primary", 19, "samplerVolumeKnob");
NanoEvent.registerControl("primary", 08, "samplerPitchSlider");

fun void
registerLFO(string scene)
{
	NanoEvent.registerControl(scene, 22, "lfoVolumeKnob");
	NanoEvent.registerControl(scene, 13, "lfoPitchSlider");
	NanoEvent.registerControl(scene, 12, "lfoDepthSlider");
	NanoEvent.registerControl(scene, 21, "lfoFreqKnob");
	NanoEvent.registerControl(scene, 20, "lfoRateKnob");
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
