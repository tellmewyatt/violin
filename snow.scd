(
s.boot;
~loadSynthsAndSamples = {
	~samples = (
		snow: Buffer.readChannel(s, "snow.flac".resolveRelative, channels: [0]),
		violinScore: Buffer.readChannel(s, "Violin I-Violin.flac".resolveRelative)
	);
	SynthDef(\snow, { | bufnum, amp=0.1, out=0, ringDecayTime=0.1, freq=400, freqLagTime=1, bwr=1, resonzAmp = 4, resonzAmpLagTime = 4, gate=1, attack=0.1, release=5 |
		var env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
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
	SynthDef(\mysteriousPad, { | out=0, freq = 900, amp =0.1, pan=0, gate=1, freqSpreadSemitones=0.3, release=5, ampMod=1.0, ampModMul=1, bpfRQAdd = 0, attack=2 |
		var env, sig, filterEnv, diminuendoEnv;
		ampMod = (ampMod * ampModMul).max(0).min(1);
		env = EnvGen.kr(Env.adsr(attack, attack, 0.9, release), gate, doneAction: 2);
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
	SynthDef(\mysteriousTremolo, { |
		out=0,
		freq = 900,
		amp =0.1,
		pan=0,
		gate=1,
		freqSpreadSemitones=0.3,
		release=5,
		ampMod=1.0,
		ampModMul=1,
		bpfRQAdd = 1,
		attack=2,
		tremoloRateMul=20,
		reverbMix=0.5,
		roomSize=0.5,
		curve= -4
		|
		var env, sig, filterEnv, diminuendoEnv;
		ampMod = (ampMod * ampModMul).max(0).min(1);
		env = EnvGen.kr(Env.adsr(attack, attack, 1, release, 1, curve), gate, doneAction: 2);
		sig = Splay.ar(20.collect { | i |
			var lfo = SinOsc.ar(Rand(0.1, 1), 0, 1);
			var spread = (lfo * Rand(freqSpreadSemitones.neg, freqSpreadSemitones)).midiratio;
			var trem = LFPulse.ar(Rand(1, 2) * tremoloRateMul, Rand(0, 1));
			var sig = Saw.ar(
				freq.lag(Rand(0,1)) * spread,
				Rand(0.1, 1));
			sig * trem;
		});
		sig = BPF.ar(sig, freq, 0.2 + Lag3.kr(bpfRQAdd, 2));
		sig = FreeVerb.ar(sig, reverbMix, roomSize);
		Out.ar(
			out,
			sig * Lag3.kr(amp, 2) * env * ampMod
		);

	}).add;
	SynthDef(\noiseFall, { | dur = 10, amp = 0.5, out=0, gate=1, release=2, direction=1 |
		var env = EnvGen.kr(Env([0, 1, 1,0], [0.01, dur, release]), gate, doneAction: 2);
		var sig = Pan2.ar(
			BPF.ar(
				WhiteNoise.ar(0.2),
				EnvGen.kr(Env([4000, 4000, 100], [dur/4, 3 * dur / 4], \sine)),
				0.2
			),
			Line.kr(1,-1, dur) * direction
		) * amp;
		var delayTime = 0;
		sig = sig + Mix.ar(2.collect {
			delayTime = delayTime + Rand(0.1, 1);
			DelayN.ar(sig, delayTime, delayTime);
		});

		Out.ar(out, sig);
	}).add;
	SynthDef(\bouncyBass, { | out = 0, freq = 60, gate = 1, amp = 0.2, pan=0.25 |
		var env = EnvGen.kr(Env.asr(0, 1, 0), gate, doneAction: 2);
		var bounceEnv = LPF.ar(LFPulse.ar(EnvGen.ar(Env([20, 0], [0.5]), gate)), 600);
		var modEnv = EnvGen.kr(Env([0, 1, 0], [0.2, 0.1]), gate);
		var sig = bounceEnv * SinOsc.ar(freq + SinOsc.ar(freq * 2, 0, modEnv * (freq * 10), freq)) * 0.2 * env;
		Out.ar(out, Pan2.ar(sig, pan, amp));
	}).add;
	SynthDef(\bassDrum, { | freq = 40, amp = 1, out=0, release=1, attack=0.001 |
		var sig = SplayAz.ar(
			s.options.numOutputBusChannels,
			SinOsc.ar(Rand(1, 4! 20) * freq, 0.5*pi) * amp * EnvGen.kr(Env.perc(attack, release), 1, doneAction: 2) * 0.3);
		Out.ar(out, sig);
	}).add;
};
~createSeq = {
	~seq = (
		0: {
			r {
				~padSynths = [69, 71, 72, 74, 76].midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0, \pan, rrand(-1.0, 1)]) };
				~snowSynths = [69, 71, 72, 74, 76].midicps.collect { | freq |
					Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \resonzAmp, 0, \freq, freq])
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
			~padSynths.collect  { | synth | synth.release; };
			~snowSynths.collect  { | synth | synth.release; };
			~padSynths = [67, 71, 72, 74, 76].midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.1, \pan, rrand(-1.0, 1), \attack, 10, \release, 10]) };
			~snowSynths = [67, 71, 72, 74, 76].midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \freq, freq, \resonzAmp, 100, \attack, 10, \release, 10])
			};
		},
		2: {
			~padSynths.collect  { | synth | synth.release; };
			~snowSynths.collect  { | synth | synth.release; };
			~padSynths = [65, 71, 72, 74, 76].midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.1, \pan, rrand(-1.0, 1), \attack, 10, \release, 10]) };
			~snowSynths = [65, 71, 72, 74, 76].midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \freq, freq, \resonzAmp, 100, \attack, 10, \release, 10])
			};
		},
		3: {
			var notes = [40, 52, 62, 67, 69, 71, 74];
			~snowSynths.collect { | s |  s.release };
			~snowSynths.collect { | s | s.release };
			~padSynths = notes.midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.3, \pan, rrand(-1.0, 1)]) };
			~snowSynths = notes.midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \resonzAmp, 100, \freq, freq])
			};
			Synth(\sinFmHit, [\freq, notes[0].midicps, \cmRatio, 5, \releaseTime, 10, \amp, 0.7, \modIndex, 1.3, \pan, -1]);
			Synth(\sinFmHit, [\freq, (notes[0] - 12).midicps, \cmRatio, 5, \releaseTime, 10, \amp, 0.3, \modIndex, 1.3, \pan, 1]);
		},
		4: {
			var notes = [38, 50, 62, 65, 67, 69, 72];
			~snowSynths.collect { | s |  s.release };
			~padSynths.collect { | s | s.release };
			~padSynths = notes.midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.3, \pan, rrand(-1.0, 1)]) };
			~snowSynths = notes.midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \resonzAmp, 100, \freq, freq])
			};

			Synth(\sinFmHit, [\freq, notes[0].midicps, \cmRatio, 5, \releaseTime, 10, \amp, 0.7, \modIndex, 1.3, \pan, -1]);
			Synth(\sinFmHit, [\freq, (notes[0] - 12).midicps, \cmRatio, 5, \releaseTime, 10, \amp, 0.3, \modIndex, 1.3, \pan, 1]);
		},
		5: {
			var freq = 71.midicps;
			~padSynths.last.set(\freq, freq);
			Synth(\sinFmHit, [\freq, freq, \cmRatio, 2, \releaseTime, 10, \amp, 0.1, \modIndex, 2, \pan, 0.5]);
		},
		6: {
			var notes = [41, 53, 62, 65, 67, 69, 76];
			~snowSynths.collect { | s |  s.release };
			~padSynths.collect { | s | s.release };
			Synth(\noiseFall);
			~padSynths = notes.midicps.collect { | freq | Synth(\mysteriousTremolo, [\freq, freq, \amp, 0.5, \pan, rrand(-1.0, 1), \tremoloRateMul, 3]) };
		},
		6: {
			var notes = [41, 53, 62, 65, 67, 69, 76];
			~snowSynths.collect { | s |  s.release };
			~padSynths.collect { | s | s.release };
			Synth(\noiseFall);
			~padSynths = notes.midicps.collect { | freq | Synth(\mysteriousTremolo, [\freq, freq, \amp, 0.5, \pan, rrand(-1.0, 1), \tremoloRateMul, 1]) };
		},
		7: {
			var notes = [43, 55, 62, 64, 67, 69, 74];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 2);
			};
		},
		8: {
			var notes = [45, 57, 60, 64, 67, 71, 74];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 3);
			};
		},
		// m. 18
		9: {
			var notes = [47, 59, 60, 64, 67, 71, 74];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 4);
			};
		},
		10: {
			var notes = [48, 60, 64, 67, 71, 74, 77];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 5);
				~padSynths[i].set(\bpfRQAdd, 1);
			};
		},
		11: {
			var notes = [50, 62, 64, 67, 71, 74, 77];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 6);
				~padSynths[i].set(\bpfRQAdd, 2);
			};
		},
		12: {
			var notes = [52, 64, 67, 71, 74, 77, 81];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 7);
				~padSynths[i].set(\bpfRQAdd, 3);
				~padSynths[i].set(\amp, 0.6);
			};
		},
		13: {
			var notes = [53, 65, 67, 71, 74, 77, 81];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 8);
				~padSynths[i].set(\bpfRQAdd, 4);
				~padSynths[i].set(\amp, 0.7);
			};
		},
		// m. 23
		14: {
			var notes = [55, 67, 67, 71, 74, 77, 81];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 9);
				~padSynths[i].set(\bpfRQAdd, 8);
				~padSynths[i].set(\amp, 0.8);
			};
		},
		15: {
			r {
				var releaseTime = 0;
				var commonArgs = [\amp, 0.5, \pan, rrand(-1.0, 1), \tremoloRateMul, 0.5, \bpfRQAdd, 4, \release, releaseTime, \curve, 1];
				var chords = [
					[37, 49, 58, 61, 63, 65, 72],
					[39, 51, 58, 60, 63, 65, 70],
					[41, 53, 56, 60, 63, 67, 70],
					[43, 55, 56, 60, 63, 67, 70],
				];
				// m. 27
				~basses = [Synth(\bouncyBass, [\freq, chords[0][0].midicps, \amp, 0.5, \pan, 0.5]), Synth(\bouncyBass, [\freq, chords[0][0].midicps / 2, \amp, 1, \pan, 0])];
				Synth(\noiseFall, [\direction, -1]);
				~padSynths = chords[0].midicps.collect { | freq |
					Synth(\sinFmHit, [\freq, freq, \cmRatio, 2, \releaseTime, 5, \amp, 0.05, \modIndex, 10, \pan, rrand(-1.0,1)]);
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs)
				};
				0.5.wait;
				~basses.collect { | synth | synth.release };
				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[1].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs)
				};
				2.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[2].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs)
				};
				2.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[3].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs)
				};
				4.wait;
				// m. 29.5
				~padSynths.collect { | s | s.release };
				~padSynths = chords[0].midicps.collect { | freq |
					Synth(\sinFmHit, [\freq, freq, \cmRatio, 2, \releaseTime, 5, \amp, 0.05, \modIndex, 10, \pan, rrand(-1.0,1)]);
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs)
				};

				2.wait;
				~padSynths.collect { | s | s.release };
				~basses = [Synth(\bouncyBass, [\freq, chords[1][0].midicps, \amp, 0.5, \pan, 0.5])];
				~padSynths = chords[1].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs)
				};
				0.5.wait;
				~basses.collect { | synth | synth.release };
				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[2].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs)
				};
				2.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[3].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs)
				};
				2.wait;
				// m. 31.5
				~padSynths.collect { | s | s.release };
				Synth(\bassDrum, [\freq, 30, \attack, 0.02, \release, 2])


			}.play;
		},
	)
};
s.waitForBoot {
	r {
		~loadSynthsAndSamples.();
		s.sync;
		~seq = ~createSeq.();
	}.play;
}
)
Synth(\noiseFall)
~createSeq.();
~seq
~seq[15].();
~seq[16].();
x = Synth(\mysteriousTremolo, [\tremoloRateMul, 100])
x.set(\tremoloRateMul, 300);
x = [1,2]
y = [1, ... x]