/*
 * dac master wave recorder
 * arguments: <filename> (default: auto)
 */

if (me.args() > 1)
	me.exit();

"special:auto" => string filename;
if (me.args() > 0)
	me.arg(0) => filename;

WvOut2 out => blackhole;
"recordings/recording" => out.autoPrefix;
filename => out.wavFilename;

/* pull samples from the dac */
dac.chan(0) => out.chan(0);
dac.chan(1) => out.chan(1);

/* keep recording as long as shred is running */
null @=> out; /* BUG WORKAROUND: dereference "out" on shred exit */
while (day => now);
