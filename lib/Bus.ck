/*
 * Public data bus
 */
public class Bus {
	static Gain @out_left;
	static Gain @out_right;

	static Gain @monitor_left;
	static Gain @monitor_right;

	/* chucked in Oscope.ck */
	static Gain @oscope[];

	static Gain @channels[];
}
/* initialization */
new Gain @=> Bus.out_left;
new Gain @=> Bus.out_right;
new Gain @=> Bus.monitor_left;
new Gain @=> Bus.monitor_right;
new Gain[3] @=> Bus.oscope;
new Gain[8] @=> Bus.channels;

/* limiting and clipping for main stereo outputs */
Bus.out_left => Dyno dyn1 => Clipper clipper1 => dac.chan(0);
dyn1.limit();

Bus.out_right => Dyno dyn2 => Clipper clipper2 => dac.chan(1);
dyn2.limit();

/* monitor output */
Bus.monitor_left => Clipper clipper3 => dac.chan(2);
Bus.monitor_right => Clipper clipper4 => dac.chan(3);

/* keep shred running, so the graph persists */
while (day => now);
