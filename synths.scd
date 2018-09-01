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
