/*
 * dac master wave recorder
 * arguments: <base_filename> (default "out")
 * will write <base_filename>_left.wav, <base_filename>_right.wav
 */

if (me.args() > 1)
	me.exit();

"out" => string filename;
if (me.args() > 0)
	me.arg(0) => filename;

// pull samples from the dac
dac.chan(0) => WvOut out_left => blackhole;
dac.chan(1) => WvOut out_right => blackhole;

filename+"_left.wav" => out_left.wavFilename;
filename+"_right.wav" => out_right.wavFilename;

<<< "writing to files:", out_left.filename(), out_right.filename() >>>;

while (day => now);
