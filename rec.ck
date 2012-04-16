// chuck this with other shreds to record to file
// example> chuck foo.ck bar.ck rec (see also rec2.ck)

// FIXME: stereo recording

// arguments: rec:<filename>

// get name
me.arg(0) => string filename;
if (!filename.length())
	"foo.wav" => filename;

// pull samples from the dac
dac => Gain g => WvOut w => blackhole;
// this is the output file name
filename => w.wavFilename;
<<<"writing to file:", "'" + w.filename() + "'">>>;

// any gain you want for the output
//.5 => g.gain;

// infinite time loop...
// ctrl-c will stop it, or modify to desired duration
while (day => now);
