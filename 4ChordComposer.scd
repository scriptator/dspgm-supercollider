// Initialization
s.boot

/**
Part 1: Synthesizer Definitions
*/

(
SynthDef(\ploink, {
	|freq=400, amp=0.5|
	var sig = SinOsc.ar(freq, mul:amp);
	var env = EnvGen.kr(Env.perc, doneAction:2);
	Out.ar(0, sig * env);
}).add;


// need a compatible version of the SC plugins from
// https://github.com/supercollider/sc3-plugins/releases
SynthDef(\piano, {
	|freq=400, amp=0.5|
	var sig = MdaPiano.ar(freq, mul:amp);
	Out.ar(0, sig);
}).add;

// drums taken from Pattern Guide Cookbook 07: Rhythmic Variations

SynthDef(\kik, { |basefreq = 50, ratio = 7, sweeptime = 0.05, preamp = 1, amp = 1,
        decay1 = 0.3, decay1L = 0.8, decay2 = 0.15, out|
    var    fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
        env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: Done.freeSelf),
        sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env * amp;
    Out.ar(out, sig ! 2)
}).add;

SynthDef(\kraftySnr, { |amp = 1, freq = 2000, rq = 3, decay = 0.3, pan, out|
    var    sig = PinkNoise.ar(amp),
        env = EnvGen.kr(Env.perc(0.01, decay), doneAction: Done.freeSelf);
    sig = BPF.ar(sig, freq, rq, env);
    Out.ar(out, Pan2.ar(sig, pan))
}).add;

// electric bass inspired from https://www.youtube.com/watch?v=ejCRgdZAKCE
SynthDef(\ebass, {
	|freq=200, amp=1.5, cutoff=350, decay=1|
	var env, audio;
	env = EnvGen.kr(Env.new([0,1,0], [0.001,2], [3,-50]), doneAction:2);
	audio = RLPF.ar(Saw.ar(freq, amp), cutoff) * env;
	audio = CombC.ar(audio, 0.125, 0.125, 1);
	Out.ar([0,1], audio);
}).add;
)

// bass example
(
var clock = TempoClock.new;
b = Pbind(
	\midinote, Pseq([35, 47, 35, 45, 47], 4),
	\dur, Pseq([3, 2, 1, 1, 1].normalizeSum, inf),
	\instrument, \ebass
);
b.play(clock)
)


/**
Part 2: Generate melodies for the song parts
*/

~intervalRow = [0, -1, -5, -1, -1, -1, -2, -3, -1, -2, -5, -6].integrate;

/**
Part 3: Generate the song
*/

// scales
~dur = [0,2,4,5,7,9,11];
~moll = [0,2,3,5,7,8,10];

(
b = Pbind(
	\scale, ~dur,
	\degree, Pseq((0..7)),
	\octave, 5,
	\dur, 0.25
);
b.play
)

(
b = Pbind(
	\scale, ~moll,
	\degree, Pseq((0..7)),
	\octave, 5,
	\dur, 0.25,
);
b.play
)

// generate chords

~scale = ~dur;
~startOctave = 4;

~harmony = [0,2,-1,3];
~harmony = [0,5,3,4];
~harmony = [7,5,3,4];

~arpeggio = [1,3,5,8] - 1;

// as a function
(
var startPitch;
var shiftedScale;
var bpm = (100..200).choose;
var clock = TempoClock.new;
clock.tempo_(bpm/60);

startPitch = (0..7).choose;
shiftedScale = ~scale + startPitch;

~arpeggioRow = Pbind(
	\scale, shiftedScale,
	\degree, Pseq(~arpeggio),
	\octave, ~startOctave,
);

~arpeggioChordProgression = Paddp(\degree, Pseq(~harmony, inf), ~arpeggioRow);
~arpeggioChordProgression.play(clock);

~bassRow = Pbind(
	\scale, shiftedScale,
	\degree, Pseq(~harmony, inf),
	\octave, ~startOctave - 2,
	\dur, 4,
	\instrument, \ebass,
	\amp, 0.6
);
~bassRow.play(clock)
)

