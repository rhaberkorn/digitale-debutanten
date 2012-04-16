/*
 * Public data bus
 */
public class Bus {
	static Gain @out_left;
	static Gain @out_right;

	/* chucked in Oscope.ck */
	static Gain @oscope[];

	static Gain @channels[];
}
/* initialization */
new Gain @=> Bus.out_left;
new Gain @=> Bus.out_right;
new Gain[3] @=> Bus.oscope;
new Gain[8] @=> Bus.channels;

/* limiting and clipping for main stereo outputs */
Clipper clipper1;
Bus.out_left => Dyno dyn1 => clipper1.input;
clipper1.output => dac.chan(0);
dyn1.limit();

Clipper clipper2;
Bus.out_right => Dyno dyn2 => clipper2.input;
clipper2.output => dac.chan(1);
dyn2.limit();

/*
 * NOTE: need to keep shred running, probably because of the constructed patch
 * (ChucK bug)
 */
while (day => now);
