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
Bus.out_left => Dyno dyn1 => Clipper clipper1 => dac.chan(0);
dyn1.limit();

Bus.out_right => Dyno dyn2 => Clipper clipper2 => dac.chan(1);
dyn2.limit();

/* keep shred running, so the graph persists */
while (day => now);
