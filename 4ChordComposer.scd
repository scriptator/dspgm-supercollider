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

// some global definitions
(
~dur = [0,2,4,5,7,9,11];
~moll = [0,2,3,5,7,8,10];
~startOctave = 4;

// number of times the verse and chorus will be repeated before the bridge
~numRepetitions = 2;

// these are the available chord progressions for four chord songs
~harmonies = [[0,2,-2,3], [0,5,3,4], [0,-2,-4,-3], [0,-3,-2,-4]];
)

// function definitions
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
	// multiply by four to make the quarter note the base unit
	[melody, rhythm * 4];
};

~playSongPart = {
	|scale, bassNotes, arpeggioNotes, arpeggioRhythm, melodyNotes, melodyRhythm, clock|

	var bassRow = Pbind(
		\scale, scale,
		\degree, bassNotes,
		\octave, ~startOctave - 1,
		\dur, 4,
		\instrument, \default,
		\amp, 0.25
	);

	var arpeggioRow = Pbind(
		\scale, scale,
		\degree, arpeggioNotes,
		\octave, ~startOctave,
		\dur, arpeggioRhythm,
		\amp, 0.15,
		\instrument, \sinegrain
	);
	var arpeggioChordProgression = Paddp(\degree, bassNotes, arpeggioRow);

	var melodyRow = Pbind(
		\scale, scale,
		\degree, melodyNotes,
		\octave, ~startOctave + 1,
		\dur, melodyRhythm,
		\amp, 0.125,
		\instrument, \default
	);

	bassRow.play(clock);
	melodyRow.play(clock);
	arpeggioChordProgression.play(clock);
};
)

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

// further declarations, to be defined below
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

// Server.default.record;

// play verse and chorus
"Calling Play for Verse and Chorus".postln;
~playSongPart.(
	scale: shiftedScale,
	bassNotes: Pseq([Pseq(verseHarmony, 2), Pseq(chorusHarmony, 2)], ~numRepetitions),
	arpeggioNotes: Pseq(arpeggio),
	arpeggioRhythm: arpeggioRhythm,
	melodyNotes: Pseq([Pseq(verse[0], 2), Pseq(chorus[0], 2)], ~numRepetitions),
	melodyRhythm: Pseq([Pseq(verse[1], 2), Pseq(chorus[1], 2)], ~numRepetitions),
	clock: clock
);

// after 16 measures with optional repetitions: play bridge
clock.schedAbs(clock.nextTimeOnGrid(4 * 16 * ~numRepetitions, -0.001), {
	"Calling Play for Bridge".postln;
	~playSongPart.(
		scale: shiftedBridgeScale,
		bassNotes: Pseq(bridgeHarmony, 2),
		arpeggioNotes: Pseq(arpeggio),
		arpeggioRhythm: arpeggioRhythm,
		melodyNotes: Pseq(bridge[0]),
		melodyRhythm: Pseq(bridge[1]),
		clock: clock
	);
});

// after the bridge (another 8 measures): play 2 times the chorus
clock.schedAbs(clock.nextTimeOnGrid(4 * (16 * ~numRepetitions + 8), -0.001), {
	"Calling Play for Outro".postln;
	~playSongPart.(
		scale: shiftedScale,
		bassNotes: Pseq(chorusHarmony, 4),
		arpeggioNotes: Pseq(arpeggio),
		arpeggioRhythm: arpeggioRhythm,
		melodyNotes: Pseq(chorus[0], 4),
		melodyRhythm: Pseq(chorus[1], 4),
		clock: clock
	);
});

// when song finishes --> stop recording
clock.schedAbs(clock.nextTimeOnGrid(4 * (16 * ~numRepetitions + 26), -0.001), {
	Server.default.stopRecording;
});
)
