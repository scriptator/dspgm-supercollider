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
// definitions
(
~dur = [0,2,4,5,7,9,11];
~moll = [0,2,3,5,7,8,10];
~startOctave = 5;
~harmonies = [[0,2,-2,3], [0,5,3,4], [7,5,3,4], [0,-3,-2,-4]];
)

// Test dur an moll scales
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

// as a function
(
var bpm = (120..180).choose;
var clock = TempoClock.new;
var harmony = ~harmonies.choose;
var arpeggio = Array.fill(8, {[0,2,4,7].choose;});

var scale = [~dur, ~moll].choose;
var startPitch = (-3..4).choose;
var shiftedScale = scale + startPitch;

// further declarations
var arpeggioRow, arpeggioChordProgression, bassRow, melody, melodyRow;

// temporarily fix the scale
// harmony = [0,-3,-2,-4];

// first try to do a melody
melody = {
	var melody = [];
	harmony.size.do{|i|
		var probs = [3,1,3,1,3,1,1].rotate(harmony[i]);
		var newMeasure = Array.fill(8, {(0..6).wchoose(probs.normalizeSum)});
		melody = melody ++ newMeasure;
	};
	melody;
}.();

clock.tempo_(bpm/60);

arpeggioRow = Pbind(
	\scale, shiftedScale,
	\degree, Pseq(arpeggio),
	\octave, ~startOctave,
	\dur, 0.5,
	\amp, 0.125,
	\instrument, \sinegrain
);


// play all the stuff
Server.default.record;
arpeggioChordProgression = Paddp(\degree, Pseq(harmony, inf), arpeggioRow);
arpeggioChordProgression.play(clock);

bassRow = Pbind(
	\scale, shiftedScale,
	\degree, Pseq(harmony, inf),
	\octave, ~startOctave - 1,
	\dur, 4,
	\instrument, \default,
	\amp, 0.25
);
bassRow.play(clock);

melodyRow = Pbind(
	\scale, shiftedScale,
	\degree, Pseq(melody),
	\octave, ~startOctave + 1,
	\dur, 0.5,
	\amp, 0.125,
	\instrument, \default
);
melodyRow.play(clock);
Server.default.stopRecording;
)

