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
~numRepetitions = 2;
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

(
~generateMelody = {
	|harmony, probs, numPhrases=1, octaveProbability=0.5|
	var melody = [];
	var rhythm = [];

	// note values of a 4 measure phrase: 2 means 1/2, 8 means 1/8
	var rhythmBase = [2, 2, 4, 4, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8].reciprocal;

	numPhrases.do{
		// scramble the note values of a 4 measure phrase
		var curRhythm = rhythmBase.scramble;

		// determine the number of notes in each measure
		var numNotesInMeasures = {
			var sum = 0;
			var res = [];
			curRhythm.do({ |note, i| sum = sum + note; if (sum.trunc > res.size) {res = res.add(i+1)}});
			res.differentiate;
		}.();
		rhythm = rhythm ++ curRhythm;

		// for each measure, select notes which fit with a high probability to the current chord
		harmony.size.do{|i|
			var curProbs = probs.rotate(harmony[i]);
			var newMeasure = Array.fill(numNotesInMeasures[i], {(0..6).wchoose(curProbs.normalizeSum)});
			newMeasure.do({ |note, i|
				switch (note,
					0, {if (i > 0) {
							// if current note is root and note before was at >= the 4th degree, use the root note one octave higher
							if ((newMeasure[i-1] > 0) && (newMeasure[i-1] < 4) && (octaveProbability.coin)) {
								newMeasure[i] = 7;
							}
						}
					// always play the 8th degree after a seventh
					}, 6, {if (i < (newMeasure.size - 1)) {newMeasure[i+1] = 7}}
				);
			});
			melody = melody ++ newMeasure;
		};
	};
	[melody, rhythm];
})

// as a function
(
var bpm = 180; // (100..130).choose;
var clock = TempoClock.new;

// choose three chord progressions for the three parts of the song
var harmonies = ~harmonies.scramble;
var verseHarmony = harmonies[0];
var chorusHarmony = harmonies[1];
var bridgeHarmony = harmonies[2];

// choose verse and chorus melodies - build song based on them
var verse = ~generateMelody.(verseHarmony, numPhrases: 1, probs: [3,1,3,1,3,1,0.5]);
var chorus = ~generateMelody.(chorusHarmony, numPhrases: 1, probs: [4,0,3,1,4,1,0]);
var bridge = ~generateMelody.(bridgeHarmony, numPhrases: 2, probs: [3,1,3,1,3,1,0.5]);

var arpeggio = Array.fill(6, {[0,2,4,7].choose;});
var arpeggioRhythm = Pseq([1,1,0.5,0.5,0.5,0.5].scramble);


// further declarations
var arpeggioRow, arpeggioChordProgression, bassRow, melodyRow;
var scale, bridgeScale, shiftedScale, shiftedBridgeScale;

// choose a random start pitch – defines the starting point of the scale
var startPitch = (0..11).choose + 5;

if (0.5.coin) {
	scale = ~dur;
	bridgeScale = ~moll - 3;  // go to parallel moll scale
} /*else*/ {
	scale = ~moll;
	bridgeScale = ~dur + 3;  // go to parallel dur scale
};
shiftedScale = scale + startPitch;
shiftedBridgeScale = bridgeScale + startPitch;

clock.tempo_(bpm/60);

/**
Part 3: Play it!
*/

Server.default.record;

// play verse and chorus

arpeggioRow = Pbind(
	\scale, shiftedScale,
	\degree, Pseq(arpeggio),
	\octave, ~startOctave,
	\dur, arpeggioRhythm,
	\amp, 0.15,
	\instrument, \sinegrain
);

arpeggioChordProgression = Paddp(
	\degree, Pseq([Pseq(verseHarmony, 2), Pseq(chorusHarmony, 2)], ~numRepetitions),
	arpeggioRow);
arpeggioChordProgression.play(clock);

~bassRow = Pbind(
	\scale, shiftedScale,
	\degree, Pseq([Pseq(verseHarmony, 2), Pseq(chorusHarmony, 2)], ~numRepetitions),
	\octave, ~startOctave - 1,
	\dur, 4,
	\instrument, \default,
	\amp, 0.25
);
~bassRow.play(clock);

melodyRow = Pbind(
	\scale, shiftedScale,
	\degree, Pseq([Pseq(verse[0], 2), Pseq(chorus[0], 2)], ~numRepetitions),
	\octave, ~startOctave + 1,
	\dur, Pseq([Pseq(verse[1], 2), Pseq(chorus[1], 2)] * 4, ~numRepetitions),
	\amp, 0.125,
	\instrument, \default
);
melodyRow.play(clock);

//  (TODO remove code repetition)

// after 16 measures with optional repetitions: play bridge
clock.schedAbs(clock.nextTimeOnGrid(4 * 16 * ~numRepetitions, -0.001), {
    Pbind(\scale, shiftedBridgeScale,
		\degree, Pseq(bridgeHarmony, 2),
		\octave, ~startOctave - 1,
		\dur, 4,
		\instrument, \default,
		\amp, 0.25).play(clock);

	arpeggioRow = Pbind(
	\scale, shiftedBridgeScale,
	\degree, Pseq(arpeggio),
	\octave, ~startOctave,
	\dur, arpeggioRhythm,
	\amp, 0.15,
	\instrument, \sinegrain
	);

	arpeggioChordProgression = Paddp(
		\degree, Pseq(bridgeHarmony, 2),
		arpeggioRow);
	arpeggioChordProgression.play(clock);

	// play bridge melody
	Pbind(
		\scale, shiftedBridgeScale,
		\degree, Pseq(bridge[0]),
		\octave, ~startOctave + 1,
		\dur, Pseq(bridge[1] * 4),
		\amp, 0.125,
		\instrument, \default
	).play(clock);
});

// after the bridge (another 8 measures): play 2 times the chorus
clock.schedAbs(clock.nextTimeOnGrid(4 * (16 * ~numRepetitions + 8), -0.001), {
	~bassRow = Pbind(
		\scale, shiftedScale,
		\degree, Pseq([Pseq(chorusHarmony, 4), chorusHarmony[0]]),
		\octave, ~startOctave - 1,
		\dur, 4,
		\instrument, \default,
		\amp, 0.25
	);
	~bassRow.play(clock);

	arpeggioRow = Pbind(
		\scale, shiftedScale,
		\degree, Pseq(arpeggio),
		\octave, ~startOctave,
		\dur, arpeggioRhythm,
		\amp, 0.15,
		\instrument, \sinegrain
	);

	arpeggioChordProgression = Paddp(
		\degree, Pseq(chorusHarmony, 4),
		arpeggioRow);
	arpeggioChordProgression.play(clock);

	melodyRow = Pbind(
		\scale, shiftedScale,
		\degree, Pseq(chorus[0], 4),
		\octave, ~startOctave + 1,
		\dur, Pseq(chorus[1] * 4, 4),
		\amp, 0.125,
		\instrument, \default
	);
	melodyRow.play(clock);
});

// when song finishes --> stop recording
clock.schedAbs(clock.nextTimeOnGrid(4 * (16 * ~numRepetitions + 26), -0.001), {
	Server.default.stopRecording;
});
)
