/*
 * "Logitech Rumble Gamepad" event class
 */
public class RumbleEvent extends GenEvent {
	static string @__axisToName[];		/* pseudo-private */
	static string @__buttonToName[];	/* pseudo-private */

	/*
	 * Should be "Generic X-Box pad"
	 * Can be changed by constructor since __hid_loop() starts only
	 * when constructing shred passes time
	 */
	0 => int device;

	fun void
	__hid_loop() /* pseudo-private */
	{
		Hid hid;

		if (!hid.openJoystick(device)) {
			cherr <= "Cannot open joystick device " <= device
			      <= IO.newline();
			me.exit();
		}
		chout <= "Opened joystick device " <= hid.num()
		      <= " (" <= hid.name() <= ")" <= IO.newline();

		while (hid => now) {
			while (HidMsg msg => hid.recv) {
				if (msg.isAxisMotion()) {
					__axisToName[msg.which] => control;
					/* normalize value [-1, 1] to [0, 1] */
					(msg.axisPosition+1)/2 => value;
				} else if (msg.isButtonDown() || msg.isButtonUp()) {
					__buttonToName[msg.which] => control;
					msg.isButtonDown() => value;
				}

				if (control == "") {
					cherr <= "Unknown joystick controller " <= msg.which
					      <= " (isAxisMotion=" <= msg.isAxisMotion() <= ")"
					      <= IO.newline();
				} else {
					broadcast();
					/*
					 * ensure that shreds waiting on the event
					 * process it before it is overwritten
					 * by the next message in the queue
					 */
					me.yield();
				}
			}
		}
		/* never reached */
	}
	spork ~ __hid_loop();
}
/* static initialization */
["joystickLeftX", "joystickLeftY", "axisButtonLeft",
 "joystickRightX", "joystickRightY", "axisButtonRight",
 "cursorX", "cursorY"] @=> RumbleEvent.__axisToName;

["buttonA", "buttonB", "buttonX", "buttonY",
 "buttonLeft", "buttonRight",
 "buttonStart", "buttonLogitech",
 "buttonJoystickLeft", "buttonJoystickRight",
 "buttonBack"] @=> RumbleEvent.__buttonToName;
