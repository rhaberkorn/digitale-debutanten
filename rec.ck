/*
 * dac master wave recorder
 * arguments: <filename> (default: auto)
 */

if (me.args() > 1)
	me.exit();

"special:auto" => string filename;
if (me.args() > 0)
	me.arg(0) => filename;

/* pull samples from the dac */
WvOut2 out => blackhole;
"recording" => out.autoPrefix;
filename => out.wavFilename;

dac.chan(0) => out.left();
dac.chan(1) => out.right();

/* keep recording as long as shred is running */
null @=> out; /* BUG WORKAROUND: dereference "out" on shred exit */
while (day => now);
