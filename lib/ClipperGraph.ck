/*
 * clip signal within -1 to 1 with simple UGens
 */
public class Clipper extends Chubgraph {
	/* calculate a from HalfRect(inlet + 1) */
	Step __one; 1 => __one.next;
	inlet => HalfRect __a;
	__one => __a;

	/* calculate b from HalfRect(2 - HalfRect(inlet + 1)) */
	Step __two; 2 => __two.next;
	-1 => __a.gain;
	__a => HalfRect __b;
	__two => __b;

	/* the result we want: 1 - HalfRect(2 - HalfRect(inlet + 1)) */
	-1 => __b.gain;
	__one => outlet;
	__b => outlet;
}
