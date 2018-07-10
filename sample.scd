(
"foo".postln();
"foo bar".postln();
)

Integer.dumpFullInterface;

SinOsc;
SinOsc.ar;

3.sqrt;
sqrt(3);

// error because Integer is only the class and not an instance
Integer.sqrt;

// keywords
arg, var, classvar
super, this

this
true, false, Nan, inf, pi, nil

// literals

1; 1.4;
2r1001; // binary
3r200;  // ternary
16rEFA0;
2pi;
"astring";
'asymbol';
\alsoasymbol;
$w; // character

// raute macht unveränderbar
#[1,2,3,4]

// no operator precedence!
2 + (2*3);
2 + 2*3;

(3..10)
a = (blah: 1, blub:2); // key-value store, Event
a['blah']
a.blah

// Brackets
a = [1,2,3,4] // Array
a[2] // indexing

// curly braces
{} // a function
{arg x, y; x*y;}.value(2,3)
{arg x, y; x*y;}.(2,3)
a = {arg x, y; x*y;};

// Crazy things
[1,2,3] * [1,2,3];
[1,2,3] *.t  [1,2,3] // helpfile adverbs for binary operators

//
// Functions
{arg x,y; postln(x); x*y;}.(2,3)
{2+2}.()

a = {arg x=4,y=2; postln(x); x-y;};
a.(2,3);
a.(x:2);
{arg x,y; x+y;}.("hello ", "world")
{arg x,y; x+y;}.("hello ", 2)

//
// variables
(
var xyz; // must be at beginning of scope, var only works inside scopes
xyz = 2;
)

// in a function
{
	var blah;
	blah = 4;
	blah*blah
}

~env_var = 3; // global variable
a = 3; // global helper variables := pseudo variable
b = 2; // ...
s // server handle, don't touch
x // non existing global variable

//
// Sound
s = Server.default;
s.boot;
s.dumpOSC(true); // dump server commands
s.quit;

// stopping all sound: ctrl+.

{SinOsc.ar}.play // wrap it into a function in order to be able to call play
x = {SinOsc.ar(
	LFNoise0.kr(
		LFNoise1.kr(0.5, 10, 12),
		500,
		LFNoise1.kr(0.3, 500, 1000)
	)
)}.play;

// stop only this synth again
x.run(false);

y = {arg freq; SinOsc.ar(freq);}.play;
y.set(\freq, 420)
y.run(false)


/*
2.4 Signal-Generatoren
*/

// factory methods
{SinOsc.ar} // every sample
{SinOsc.kr} // for controlling parameters, not for playing directly


// Oscilloscope
{SinOsc.ar(300*(SinOsc.kr(1) + 1))}.scope

x = {arg mul; SinOsc.ar(freq: SinOsc.kr(freq: 1, add: 2, mul:300), mul: mul)}.scope
x.set(\mul, 0.5)

// acht geben auf bandbegrenzte vs. nicht bandbegrenzte UGens
p = {Pulse.ar}.plot // Bandbegrenzt braucht man um aliasing zu vermeiden
p = {LFPulse.ar}.plot // LF ist oft nicht bandbegrenzt und eher für Steuerung verwendet


/*
3 Tour of UGens (see help page)
*/


/*
4 Control structures
*/

// functional if/else
(
{arg x;
	if(x==5) {postln("true")} {postln("false")}
}.value(5)
)

// using variables
(
~foo = {arg x;
	var ret = if(x==5) {"true"} {"false"};
	ret + "!"
}.value(5);
~foo;
)

r = (4 > 5).if{"true"}{"false"};

// switch-case-default
(
x = 12;
switch(
	x,
	1, {"1"},
	12, {"zwoelf"},
	{"NIX"}
);
)

// loops
for(2, 6, {|i| postln(i);});
2.for(6, {|i| postln(i);});   // syntactic sugar for the above ... wtf!

forBy(2, 26, 5, {|i| postln(i);}) // in steps

(
var test = 0;
while(
	{test < 5},             // curly braces for condition!
	{
		postln(test);
		test = test + 1;
	}
)
)

(
t = 0;
{t < 5}.while({postln("hi"); t = t + 1})
)



/* 5 Data structures */

// many superclasses
Array.superclasses;
Array.dumpFullInterface;

a = Array.new();
a = [1,2,3];
a.add("blah");

// caveat: only two default slots, need to use assignment
a = [];
a.add("blah");
a = a.add("blub");
a = a.add("foo");

// access
a.at(0);
a[1];
a[2];

// Filling Arrays
a = Array.fill(4,5);
a = Array.fill(4, {100.rand;});
5.dup(4)
5!4

// filling with sinus
~table_size = 1024;
a = Array.fill(~table_size, {arg i; sin(2 * pi * i / ~table_size)})
a.plot();

// primes
a = Array.fill(16, {|i| i.nthPrime})

// series
a = Array.fill(10, {|i| i});
a = Array.series(10, 0, 2);
a = Array.geom(10, 1, 2);
a = Array.fib(10, 2, 3);
(1..10)

// choosing randomly
a = [1,2,3,4];
a.choose;  // mit zurücklegen
a.removeAt(a.size.rand) // ohne zurücklegen

[1,2,3,4].wchoose([1,3,5,9].normalizeSum)

// diverse
[1,2,3,4].scramble
[1,2,3,4].scramble.sort
[1,2,3,4].reverse
[1,2,3,4].mirror
[1,2,3,4].mirror1
[1,2,3,4].mirror2
[1,2,3,4].stutter
[1,2,3,4].rotate(2)

10.do({|i| [1,2,3,4].pyramid(i+1).postln});
10.do({|i| [1,2,3,4].pyramidg(i+1).postln});

[1,2,3] + [2,3,4] // sum element-wise
[[1,2,3], [2,3,4]].flatten // concatenate
[[1,2,3], [2,3,4]].lace // zip

// permutations
a = [1,2,3];
a.size.factorial.do({|i| a.permute(i).postln});

x = [[1,2,3], [10,20,30]]
x.allTuples
[1,2,3].powerset



/* Maths */

[1,2,3,4] * 2
[1,2,3,4] / 2

[1,2,3] * [4,5,6,10,24] // periodische fortsetzung
[1,2,3] *.s [4,5,6,10,24]
[1,2,3] *.f [4,5,6,10,24]

// MIDI conversion
[60,64,78].midicps
440.cpsmidi

// normalizations
[1,2,3,4].normalize
[1,2,3,4].normalizeSum

// diverse
[1,2,3,4].reciprocal
[1,2,3,4].integrate
[1,2,3,4].differentiate

// loops over arrays
(10..20).do({|i, idx| [i*10, idx].postln})
(10..20).collect({|i, idx| [i*10, idx]})
10000.collect({(1..10).choose}).histo(10).plot

// 12-tone row
~pitch_classes = (0..11)
~row = ~pitch_classes.scramble
~base_note = 60
~notes = ~row + ~base_note
~freqs = ~notes.midicps

// umkehr, krebs, krebsumkehr HOMEWORK



/* 6 SYNTHS and SYNTHDEFS */

x = {arg freq; SinOsc.ar(freq);}.play
x.set(\freq, 445)

(
SynthDef(\mysynth, {
	|freq=400, amp=0.125|
	Out.ar(0, {SinOsc.ar(freq, mul:amp)}.dup(2))
});
).add

x = Synth(\mysynth);
x.set(\freq, 445)
x.run(true)
x.run(false)

SynthDescLib.global.read.browse
s.queryAllNodes

// default synthesizer

x = Synth(\default, [\freq, 69.midicps, \amp, 0.1, \gate, 0])
x.set(\gate, 0)


/**
8 - ENVELOPES
*/

s.boot;

(
SynthDef(\mysynth, {
	|freq=400, amp=0.5, gate=1|
	var sig = SinOsc.ar(freq, mul:amp);
	var env = EnvGen.kr(Env.perc, gate, doneAction:2);
	Out.ar(0, sig * env);
}).add
)

x = Synth(\mysynth);
x.set(\freq, 445);

// not working because of doneAction=2 (cleanup)
x.run(true);
x.run(false);

// EnvGen
// fix duration
Env.linen(2, 1, 1, 0.5).plot
Env.perc().test

// gated envelopes
Env.adsr().test(0.1).plot


(
SynthDef(\adsr, {
	|freq=400, amp=0.5, gate=0|
	var sig = SinOsc.ar(freq, mul:amp);
	var env = EnvGen.kr(Env.adsr, gate, doneAction:0);
	Out.ar(0, sig * env);
}).add
)

x = Synth(\adsr);
x.set(\gate, 1);
x.set(\gate, 0);


/**
7 ZEITLICHE ABLÄUFE
*/

// 7.1 Routine

r = Routine({
	60.midicps.yield;
	75.midicps.yield;
	80.midicps.yield;
});

r.next;
r.reset;

(
SynthDef(\ploink, {
	|freq=400, amp=0.5|
	var sig = SinOsc.ar(freq, mul:amp);
	var env = EnvGen.kr(Env.perc, doneAction:2);
	Out.ar(0, sig * env);
}).add
)

x = Synth(\ploink, [\freq, r.next]);

r = Routine({
	Synth(\ploink, [\freq, 80.midicps]);
	0.5.wait;
	Synth(\ploink, [\freq, 75.midicps]);
	0.5.wait;
	Synth(\ploink, [\freq, 72.midicps]);
});
r.play

// better

~pitches = Routine({
	80.yield;
	75.yield;
	72.yield;
});

~player = Routine({
	3.do({
		var synth = Synth(\ploink, [\freq, ~pitches.next.midicps]);
		0.5.wait;
	});
});
~player.play


// Task: A pausable Routine

~player = Task({
	3.do({
		var synth = Synth(\ploink, [\freq, ~pitches.next.midicps]);
		2.wait;
	});
});

~pitches.reset;
~player.play;
~player.pause;
~player.resume;
~player.stop;

// 7.2 clocks

c = TempoClock(6); // beats per second
t = Task({inf.do({Synth(\ploink); 1.wait})});
t.play(c);
t.stop


/**
11. Patterns & Events
*/

// das Pattern
p = Pseq([1,2,3,4], 2, 1);

// mach eine Routine draus
r = p.asStream;
r.next;
r.reset;

// verschachteln
p = Pseq([Pseq([1,2,3], 2), Pseq([10,11], 2)], 3);
r = p.asStream;
r.nextN(10)
r.reset

// more Patterns --> see "Pattern Guide" in help window


// Events, eventStreamPatterns

// sollte eigentlich die Messages an den Server printen...
s.dumpOSC(1);

b = Pbind(\freq, Pseq((60..72).midicps));
x = b.play;
x.stop

(
b = Pbind(
	\freq, Pseq((60..72).midicps),
	\amp, Pseq(Array.geom(20, 1, 1.2).reciprocal),
	\dur, 0.25)
))
b.play


// can also use midinote and custom synth

(
SynthDef(\ploink, {
	|freq=400, amp=0.5|
	var sig = SinOsc.ar(freq, mul:amp);
	var env = EnvGen.kr(Env.perc, doneAction:2);
	Out.ar(0, sig * env);
}).add
)

(
b = Pbind(
	\midinote, Pseq((60..72)),
	\amp, Pseq(Array.geom(20, 1, 1.2).reciprocal, inf),
	\dur, Pseq([0.3, 0.1], inf),
	\instrument, \ploink
))
b.play

// degree, scale and octave
(
b = Pbind(
	\scale, [0,2,4,5,7,9,11],
	\degree, Pseq((0..8)),
	\octave, 5
	\dur, 0.25
))
b.play


// Serielle Musik

~intervalRow = [0, -1, -5, -1, -1, -1, -2, -3, -1, -2, -5, -6].integrate;
~startPitch = 3;
~startOctave = 8;

~ampSteps = (0,6..42).neg.dbamp;
~ampRow = ~ampSteps@[7,7,2,3,4,2,3,4,2,6,2,5];

~deltas = (1..12);
~baseDur = 0.125;

(
~simpleRow = Pbind(
	\scale, (0..11),
	// \midinote, Pseq(~intervalRow+~startPitch+(12*~startOctave))
	\degree, Pseq(~intervalRow),
	\octave, ~startOctave,
	\dur, Pseq(~deltas*~baseDur),
	\amp, Pseq(~ampRow)
))
~simpleRow.play

// as a function
(
~playRow = {
	arg startPitch = 3, octave = 9, repeats = 1;
	var row = Pbind(
		\scale, (0..11),
		\degree, Pseq(~intervalRow + startPitch, repeats),
		\octave, octave,
		\dur, Pseq(~deltas*~baseDur, inf),
		\amp, Pseq(~ampRow, inf)
	);
	row.play
};

~composer = {
	arg repeats = 2, density = 30;  // = rows per minute
	Task{
		var waitTime = 5;

		var timeStep = 0.25;
		var chanceForNewRow = timeStep * density / 60;

		inf.do{
			if(chanceForNewRow.coin, {
				~playRow.(startPitch:12.rand, octave:4+5.rand, repeats:repeats);
			});
			timeStep.wait;
		};
	};
};
~composer.(3,60).play
)