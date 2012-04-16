/*
 * clip signal within -1 to 1 with simple UGens
 */
public class Clipper {
	Gain input; // chuck input signal to this
	Gain output; // chuck this out to have the result

	Step one; 1 => one.next;
	input => HalfRect a;
	one => a; // calculate a from HalfRect(input + 1)
	one => Gain two; 2 => two.gain;
	-1 => a.gain;
	a => HalfRect b;
	two => b; // calculate b from HalfRect(2 - HalfRect(input + 1))
	-1 => b.gain;
	one => output;
	b => output; // the result we want: 1 - HalfRect(2 - HalfRect(input + 1))
}
