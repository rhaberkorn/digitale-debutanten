/*
 * contact mic
 * digital feedback loop
 */
Clipper clipper;
adc.chan(0) => Gain pregain => Echo echo => Gain amp => clipper.input;
clipper.output => Bus.out_left;
clipper.output => Bus.out_right;
clipper.output => Delay del => amp;

// mic pre-amplification - don't contribute to feedback loop
6 => pregain.gain;

1::second => echo.max;
100::ms => echo.delay;
0.8 => echo.mix;

// feedback loop amp
3 => amp.gain;

// delay line: delay influences feedback pitch
1::second => del.max;
1::ms => del.delay;

// simulate speaker<->mic distance
0.324 => del.gain;

/*
 * record player
 */
adc.chan(1) => Bus.out_left;
adc.chan(1) => Bus.out_right;

while (day => now);
