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


// From PAddp documentation
SynthDef(\sinegrain,
    { arg out=0, freq=440, sustain=0.02;
        var env;
        env = EnvGen.kr(Env.perc(0.001, sustain), 1, doneAction: Done.freeSelf);
        Out.ar(out, SinOsc.ar(freq, 0, env * 0.1))
    }).add;
)

/**
Part 2: Generate the song
*/

// scales
// definitions
(
~dur = [0,2,4,5,7,9,11];
~moll = [0,2,3,5,7,8,10];
~startOctave = 4;
~harmonies = [[0,2,-2,3], [0,5,3,4], [0,-2,-4,-3], [0,-3,-2,-4]];
)

// Test dur and moll scales
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

// choose a random scale type and any of the 12 positions of the scale
var scale = [~dur, ~moll].choose;
var startPitch = (0..11).choose + 5;
var shiftedScale = scale + startPitch;

// further declarations
var arpeggioRow, arpeggioChordProgression, bassRow, melody, melodyRow;

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

/**
Part 3: Play it!
*/

// Server.default.record;
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

