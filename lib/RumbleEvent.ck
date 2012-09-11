/*
 * "Logitech Rumble Gamepad" event class
 */
public class RumbleEvent extends GenEvent {
	static string @__axisToName[];		/* pseudo-private */
	static string @__buttonToName[];	/* pseudo-private */

	class Port extends Step {
		fun void
		fetch(int device, string wantControl)
		{
			Hid hid;

			if (!hid.openJoystick(device)) {
				cherr <= "Cannot open joystick device " <= device
				      <= IO.newline();
				me.exit();
			}
			chout <= "Opened joystick device " <= device <= " (" <= hid.name() <= ")"
			      <= IO.newline();

			while (hid => now) {
				while (HidMsg msg => hid.recv) {
					string control;
					float value;

					if (msg.isAxisMotion()) {
						RumbleEvent.__axisToName[msg.which] => control;
						msg.axisPosition => value;
					} else if (msg.isButtonDown()) {
						RumbleEvent.__buttonToName[msg.which] => control;
						1 => value;
					} else if (msg.isButtonUp()) {
						RumbleEvent.__buttonToName[msg.which] => control;
						-1 => value;
					}

					if (control == wantControl)
						value => next;
				}
			}
			/* never reached */
		}
	}

	/* should be "Generic X-Box pad" */
	0 => int device;

	string control;

	fun int
	isControl(string c)
	{
		return control == c;
	}

	fun Step @
	getPort(string control)
	{
		Port p;
		spork ~ p.fetch(device, control);
		return p;
	}

	fun void
	__hid_loop() /* pseudo-private */
	{
		Hid hid;

		if (!hid.openJoystick(device)) {
			cherr <= "Cannot open joystick device " <= device
			      <= IO.newline();
			me.exit();
		}
		chout <= "Opened joystick device " <= device <= " (" <= hid.name() <= ")"
		      <= IO.newline();

		while (hid => now) {
			while (HidMsg msg => hid.recv) {
				if (msg.isAxisMotion()) {
					__axisToName[msg.which] => control;
					(msg.axisPosition+1)/2 => value;
				} else if (msg.isButtonDown()) {
					__buttonToName[msg.which] => control;
					true => value;
				} else if (msg.isButtonUp()) {
					__buttonToName[msg.which] => control;
					false => value;
				}

				if (control != "")
					broadcast();
			}
		}
		/* never reached */
	}
	spork ~ __hid_loop();
}
/* static initialization */
["leftJoystickX", "leftJoystickY", "leftButton",
 "rightJoystickX", "rightJoystickY", "rightButton",
 "cursorX", "cursorY"] @=> RumbleEvent.__axisToName;
["buttonA", "buttonB", "buttonX", "buttonY",
 "buttonLB", "buttonRB",
 "buttonStart", "buttonBack"] @=> RumbleEvent.__buttonToName;
