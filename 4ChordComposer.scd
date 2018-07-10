// Initialization
s.boot
// TODO more?


/**
Part 1: Synthesizer Definitions
*/

(
SynthDef(\ploink, {
	|freq=400, amp=0.5|
	var sig = SinOsc.ar(freq, mul:amp);
	var env = EnvGen.kr(Env.perc, doneAction:2);
	Out.ar(0, sig * env);
}).add
)

// need a compatible version of the SC plugins from
// https://github.com/supercollider/sc3-plugins/releases
(
SynthDef(\piano, {
	|freq=400, amp=0.5|
	var sig = MdaPiano.ar(freq, mul:amp);
	Out.ar(0, sig);
}).add
)

x = Synth(\piano);
x.set(\freq, 445)
x.run(true)
x.run(false)


// TODO create electric bass
// e.g. https://www.youtube.com/watch?v=ejCRgdZAKCE


/**
Part 2: Generate melodies for the song parts
*/


/**
Part 3: Generate the song
*/


