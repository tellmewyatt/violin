(
~samples = (
	snow: Buffer.readChannel(s, "snow.flac".resolveRelative, channels: [0]),
	violinScore: Buffer.readChannel(s, "Violin I-Violin.flac".resolveRelative)
);
SynthDef(\snow, { | bufnum, amp=0.1, out=0, ringDecayTime=0.1, freq=400, freqLagTime=1, bwr=1, resonzAmp = 4, resonzAmpLagTime = 4, gate=1 |
	var env = EnvGen.kr(Env.asr(0.1, 1, 1), gate, doneAction: 2);
	var trigger = Impulse.kr(2);
	var sig = GrainBuf.ar(2, trigger, 2, bufnum, BufRateScale.kr(bufnum), TRand.ar(0, 1, trigger), 2, TRand.ar(-0.5, 0.5, trigger));
	sig = sig * env;
	ringDecayTime = ringDecayTime.max(0.00001).min(5);
	Out.ar(
		out,
		Resonz.ar(sig, freq.lag(0.2), bwr) *  resonzAmp.lag(resonzAmpLagTime) + (sig * amp)
	);
}).add;
SynthDef(\sinFmHit, { | freq = 200, modIndex = 10, cmRatio=2.31, pan=0, out=0, releaseTime=2, amp=0.2 |
	var env = EnvGen.kr(Env.perc(0, releaseTime), doneAction: 2);
	var sig;
	modIndex = EnvGen.kr(Env.perc(0,releaseTime), 1, modIndex);
	sig = Pan2.ar(SinOsc.ar(freq + SinOsc.ar(cmRatio * freq, 0.2, modIndex * cmRatio * freq), 0.5pi, 0.5) * env, pan);
	sig = FreeVerb2.ar(sig[0], sig[1], 0.7);
	Out.ar(out,
		sig * amp
	);

}).add;
SynthDef(\mysteriousPad, { | out=0, freq = 900, amp =0.1, pan=0, gate=1, freqSpreadSemitones=0.3, releaseTime=1, ampMod=1.0, ampModMul=1, bpfRQAdd = 0, attack=2 |
	var env, sig, filterEnv, diminuendoEnv;
	ampMod = (ampMod * ampModMul).max(0).min(1);
	env = EnvGen.kr(Env.adsr(attack, attack, 0.7, releaseTime), gate, doneAction: 2);
	sig = Mix.ar(20.collect { | i |
		var lfo = SinOsc.ar(Rand(0.1, 1), 0, 1);
		var spread = (lfo * Rand(freqSpreadSemitones.neg, freqSpreadSemitones)).midiratio;
		Saw.ar(
			freq * spread,
			Rand(0.1, 1))
	});
	filterEnv = EnvGen.kr(Env.triangle(8));
	sig = BPF.ar(sig, freq, 0.2 + filterEnv + bpfRQAdd);
	sig = sig + Mix.ar(
		SinOsc.ar([freq, freq * 2], 0, 0.1)
	);
	sig = FreeVerb.ar(sig, 0.8, 0.9);
	Out.ar(
		out,
		Pan2.ar(sig , pan, amp * env * ampMod )
	);

}).add;
)
~samples.violinScore.play;
(
~seq = (
	0: {
		r {
			~padSynths = [69, 71, 72, 74, 76].midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0, \pan, rrand(-1.0, 1)]) };
			~snowSynths = [69, 71, 72, 74, 76].midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \resonzAmp, 0, \freq, freq, \resonzAmp, 0])
			};
			5.wait;
			r {
				var snowFadeIn = Env([0, 100], [20], 1);
				var stream = snowFadeIn.asStream;
				var dt = 0.1;
				(snowFadeIn.duration / dt + 1).do {
					~snowSynths.collect { | synth | synth.set(\resonzAmp, stream.next ) };
					0.1.wait;

				};
			}.play;
			20.wait;
			r {
				var snowFadeIn = Env([0, 0.1], [10], 1);
				var stream = snowFadeIn.asStream;
				var dt = 0.1;
				(snowFadeIn.duration / dt + 1).do {
					~padSynths.collect { | synth | synth.set(\amp, stream.next) };
					0.1.wait;

				};
			}.play;
			10.wait;

		}.play;
	},
	1: {
		~padSynths[0].set(\freq, 67.midicps);
		~snowSynths[0].set(\freq, 67.midicps);
	},
	2: {
		~padSynths[0].set(\freq, 65.midicps);
		~snowSynths[0].set(\freq, 65.midicps);
	},
	3: {
		var notes = [40, 52, 62, 67, 69, 71, 74];
		~snowSynths.collect { | s |  s.release };
		~snowSynths.collect { | s | s.release };
		~padSynths = notes.midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.2, \pan, rrand(-1.0, 1)]) };
		~snowSynths = notes.midicps.collect { | freq |
			Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \resonzAmp, 100, \freq, freq])
		};
		Synth(\sinFmHit, [\freq, notes[0].midicps, \cmRatio, 5, \releaseTime, 10, \amp, 0.6, \modIndex, 1.3, \pan, -1]);
		Synth(\sinFmHit, [\freq, (notes[0] - 12).midicps, \cmRatio, 5, \releaseTime, 10, \amp, 0.2, \modIndex, 1.3, \pan, 1]);
	},
	4: {
		var notes = [38, 50, 62, 65, 67, 69, 72];
		~snowSynths.collect { | s |  s.release };
		~padSynths.collect { | s | s.release };
		~padSynths = notes.midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.2, \pan, rrand(-1.0, 1)]) };
		~snowSynths = notes.midicps.collect { | freq |
			Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \resonzAmp, 100, \freq, freq])
		};

		Synth(\sinFmHit, [\freq, notes[0].midicps, \cmRatio, 5, \releaseTime, 10, \amp, 0.6, \modIndex, 1.3, \pan, -1]);
		Synth(\sinFmHit, [\freq, (notes[0] - 12).midicps, \cmRatio, 5, \releaseTime, 10, \amp, 0.2, \modIndex, 1.3, \pan, 1]);
	},
	5: {
		var freq = 71.midicps;
		~padSynths.last.set(\freq, freq);
		Synth(\sinFmHit, [\freq, freq, \cmRatio, 2, \releaseTime, 10, \amp, 0.1, \modIndex, 2, \pan, 0.5]);
	},
)
)