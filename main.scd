(

s.options.memSize = 8192 * 40;
s.options.numOutputBusChannels = 8;
s.reboot;
~channelMaps = (
	2:(
		0: 0,
		1: 1
	),
	4: (
		0: 0,
		1: 1,
		2: 3,
		3: 2
	),
	8: (
		0: 0,
		1: 4,
		2: 1,
		3: 3,
		4: 7,
		5: 5,
		6: 6,
		7: 2
	)
);
// Evenly pans a signal over the specified number of channels, matching the oreination of the CECM studio
~createPanner = {
	var orientation = if(s.options.numOutputBusChannels == 8, { 0 },
		{ 0.5 });
	var nchans = s.options.numOutputBusChannels;
	var channelMaps = ~channelMaps;
	var getInvertedAsArray = { | map |
		var inverted = map.invert;
		inverted.order.collect { | i | inverted[i]; };
	};
	var map = getInvertedAsArray.(channelMaps[nchans]);
	var offset = if(nchans == 8, { 0.25 }, { 0 });
	{ | sig, pos=0, width=2 |
		sig = PanAz.ar(nchans, sig, pos + offset, 1, width, orientation);
		map.collect { | i | sig[i]; }
	};
};
~createSplayer = {
	var orientation = if(s.options.numOutputBusChannels == 8, { 0 },
		{ 0.5 });
	var nchans = s.options.numOutputBusChannels;
	var channelMaps = ~channelMaps;
	var getInvertedAsArray = { | map |
		var inverted = map.invert;
		inverted.order.collect { | i | inverted[i]; };
	};
	var map = getInvertedAsArray.(channelMaps[nchans]);
	var offset = if(nchans == 8, { 0.25 }, { 0 });
	{ | sig, pos=0, width=2, spread=1 |
		sig = SplayAz.ar(nchans, sig, spread, 1, width, pos + offset, orientation);
		map.collect { | i | sig[i]; }
	};
};
~panEvenly = ~createSplayer.();
~testPanner = {
	var sig = WhiteNoise.ar(0.05) * EnvGen.kr(Env.perc, Impulse.kr(1));
	var pan = LFSaw.kr(1/8, 0, 1);
	~panEvenly.(sig, pan)
};
~loadSynthsAndSamples = {
	~samples = (
		snow: Buffer.readChannel(s, "snow.flac".resolveRelative, channels: [0]),
		//violinScore: Buffer.readChannel(s, "Violin I.flac".resolveRelative),
		//pizzes: Buffer.readChannel(s, "pizzes.flac".resolveRelative, channels: [0])
	);
	SynthDef(\snow, { | bufnum, amp=0.05, out=0, ringDecayTime=0.1, freq=400, freqLagTime=1, bwr=1, resonzAmp = 4, resonzAmpLagTime = 4, gate=1, attack=0.1, release=5, grainDur=2, grainRate=2 |
		var env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
		var trigger = Impulse.kr(grainRate);
		var sig = GrainBuf.ar(s.options.numOutputBusChannels, trigger, grainDur, bufnum, BufRateScale.kr(bufnum), TRand.ar(0, 1, trigger), 2, TRand.ar(-0.5, 0.5, trigger));
		ringDecayTime = ringDecayTime.max(0.00001).min(5);
		sig = Resonz.ar(sig, freq.lag(0.2), bwr) *  resonzAmp.lag(resonzAmpLagTime) + (sig * amp);
		sig = sig * env;
		Out.ar(
			out,
			sig
		);
	}).add;
	SynthDef(\sinFmHit, { | freq = 200, modIndex = 10, cmRatio=2.31, pan=0, out=0, release=2, attack=0, amp=0.1, curve= -4, modIndexCurve= -4, reverbMix= 0.7  |
		var env = EnvGen.kr(Env.perc(attack, release, curve: curve), doneAction: 2);
		var sig;
		modIndex = EnvGen.kr(Env.perc(attack,release, curve: modIndexCurve), 1, modIndex);
		sig = ~panEvenly.(SinOsc.ar(freq + SinOsc.ar(cmRatio * freq, 0.2, modIndex * cmRatio * freq), 0.5pi, 0.5), pan);
		sig = FreeVerb.ar(sig, reverbMix);
		Out.ar(out,
			sig * amp * env
		);
	}).add;
	SynthDef(\fmSynth, { | freq = 200, modIndex = 10, cmRatio=2.31, pan=0, out=0, release=2, attack=0, decay=0.3, sustain=0.8, amp=0.1, gate=1 |
		var env = EnvGen.kr(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
		var sig;
		sig = ~panEvenly.(SinOsc.ar(freq + SinOsc.ar(cmRatio * freq, 0.2, modIndex * cmRatio * freq), 0.5pi, 0.5) * env, pan);
		Out.ar(out,
			sig * amp
		);
	}).add;
	SynthDef(\mysteriousPad, { | out=0, freq = 900, amp =0.05, pan=0, gate=1, freqSpreadSemitones=0.3, release=5, ampMod=1.0, ampModMul=1, bpfRQAdd = 0, attack=2 |
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
			~panEvenly.(sig * amp * env * ampMod, pan)
		);

	}).add;
	SynthDef(\mysteriousTremolo, { |
		out=0,
		freq = 900,
		amp =0.05,
		pan=0,
		width=2,
		spread=0,
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
		curve= -4,
		lagTime = 4
		|
		var env, sig, filterEnv, diminuendoEnv;
		ampMod = (ampMod * ampModMul).max(0).min(1);
		env = EnvGen.kr(Env.adsr(attack, attack, 1, release, 1, curve), gate, doneAction: 2);
		sig = ~panEvenly.(20.collect { | i |
			var lfo = SinOsc.ar(Rand(0.1, 1), 0, 1);
			var spread = (lfo * Rand(freqSpreadSemitones.neg, freqSpreadSemitones)).midiratio;
			var trem = LFPulse.ar(Rand(1, 2) * tremoloRateMul, Rand(0, 1));
			var sig = Saw.ar(
				freq.lag(Rand(0,1)) * spread,
				Rand(0.1, 1));
			sig * trem;
		}, pan.lag(lagTime), width.lag(lagTime), spread.lag(lagTime));
		sig = BPF.ar(sig, freq, 0.2 + Lag3.kr(bpfRQAdd, lagTime));
		sig = FreeVerb.ar(sig, reverbMix, roomSize);
		Out.ar(
			out,
			sig * Lag3.kr(amp, lagTime) * env * ampMod
		);

	}).add;
	SynthDef(\noiseFall, { | dur = 10, amp = 0.25, out=0, gate=1, release=2, direction=1, startFreq=4000, endFreq=100 |
		var env = EnvGen.kr(Env([0, 1, 1,0], [0.01, dur, release]), gate, doneAction: 2);
		var sig = ~panEvenly.(
			BPF.ar(
				WhiteNoise.ar(0.2),
				EnvGen.kr(Env([startFreq, startFreq, endFreq], [dur/4, 3 * dur / 4], \sine)),
				0.2
			),
			Line.kr(1,-1, dur) * direction
		) * amp;
		var delayTime = 0;
		sig = sig + Mix.ar(2.collect {
			delayTime = delayTime + Rand(0.1, 1);
			DelayN.ar(sig, delayTime, delayTime);
		});

		Out.ar(out, sig * env);
	}).add;
	SynthDef(\snowFall, { | dur = 10, amp = 0.25, out=0, gate=1, release=2, direction=1, startFreq=4000, endFreq=100, grainRate=4, grainDur=4, bufnum |
		var env = EnvGen.kr(Env([0, 1, 1,0], [0.01, dur, release]), gate, doneAction: 2);
		var trigger = Impulse.kr(grainRate);
		var sig = ~panEvenly.(
			BPF.ar(
				GrainBuf.ar(1, trigger, grainDur, bufnum, BufRateScale.kr(bufnum), TRand.ar(0, 1, trigger), 2, TRand.ar(-0.5, 0.5, trigger)),
				EnvGen.kr(Env([startFreq, startFreq, endFreq], [dur/4, 3 * dur / 4], \sine)),
				0.2
			),
			Line.kr(1,-1, dur) * direction
		) * amp;

		var delayTime = 0;
		sig = sig + Mix.ar(2.collect {
			delayTime = delayTime + Rand(0.1, 1);
			DelayN.ar(sig, delayTime, delayTime);
		});

		Out.ar(out, sig * env);
	}).add;
	SynthDef(\bouncyBass, { | out = 0, freq = 60, gate = 1, amp = 0.1, pan=0.25 |
		var env = EnvGen.kr(Env.asr(0, 1, 0), gate, doneAction: 2);
		var bounceEnv = LPF.ar(LFPulse.ar(EnvGen.ar(Env([20, 0], [0.5]), gate)), 600);
		var modEnv = EnvGen.kr(Env([0, 1, 0], [0.2, 0.1]), gate);
		var sig = bounceEnv * SinOsc.ar(freq + SinOsc.ar(freq * 2, 0, modEnv * (freq * 10), freq)) * 0.2 * env;
		Out.ar(out, ~panEvenly.(sig, pan, amp));
	}).add;
	SynthDef(\bassDrum, { | freq = 40, amp = 1.5, out=0, release=1, attack=0.001 |
		var sig = SplayAz.ar(
			s.options.numOutputBusChannels,
			SinOsc.ar(Rand(1, 4! 20) * freq, 0.5*pi) * amp * EnvGen.kr(Env.perc(attack, release), 1, doneAction: 2) * 0.3);
		Out.ar(out, sig);
	}).add;
	NN.load(\ravePercussion, "./percussion.ts".resolveRelative);
	SynthDef(\snowPerc, { | bufnum, out=0, percAmp=0, freq=50, playbackRate=1, combAmp=0.5, gate=1, amp=0.25, pan= -1, release=10, attack=5 |
		var sig, insig, env, pannedSig;
		// Create the envelope
		var soundIn = Limiter.ar(HPF.ar(SoundIn.ar(0), 100), 0.9);
		env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
		// Input signal is a looped buffer
		insig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * playbackRate.lag(0.2), loop: 1) + soundIn;
		// Put this through the neural network
		sig = NN(\ravePercussion, \forward).ar(insig) * percAmp.lag(0.1);
		// Through comb filter
		sig = sig + CombC.ar(LPF.ar(sig, 600), 0.2, 1/freq, 10, combAmp.lag(0.1));
		sig = sig + (insig * 0.5);
		// Add compression
		sig = Compander.ar(sig, sig, 0.5, 1, 0.3) * 1.2;
		// Fix DC offset
		sig = LeakDC.ar(sig);
		sig  = sig * env * amp;
		sig = Limiter.ar(sig, 0.9);
		pannedSig = ~panEvenly.(sig, pan, 4, 0.5);
		Out.ar(out, pannedSig);
	}).add;
	SynthDef(\violinDelayIn, { | out, auxOut |
		var sig = SoundIn.ar(0);
		var combSig = Splay.ar(
			CombC.ar(
				sig, 1, Rand(0.1, 1 ! 10), 4)
		);
		Out.ar(out, combSig);
		Out.ar(auxOut, sig);

	}).add;
	/*SynthDef(\score, { | out=0, amp=2 |
		Out.ar(out, PlayBuf.ar(2, ~samples.violinScore, BufRateScale.kr(~samples.violinScore), 1))
	}).add;*/
};
~createSnowPercussion = { | notenum, pan=1 |
	var synth;
	var routine = r {
		synth = Synth(\snowPerc, [\bufnum, b, \freq, (notenum).midicps, \pan, pan]);
		'playing'.postln;
		10.do { | i |
			synth.set(\percAmp, 6 * (i / 10));
			1.wait;
		};
		25.do { | i |
			synth.set(\playbackRate, 0.1 + (0.9  * (25 - i) / 25));
			synth.set(\combAmp, 0.5 + (0.2 * i / 25));
			1.wait;
		};
		10.wait;
		synth.release;
	};
	routine.play;
	// Cleanup function
	{
		synth.set(\release, 1);
		synth.release;
		routine.stop;
	};

};
~createSeq = {
	~seq = (
		a: {
			var snowPercCleanup;
			var routine = r {
				// Insert tapping
				// Col Legno Battuto
				// Maybe some harmonc trills? Flautando - ask about playing a low A with touch harmonics
				snowPercCleanup = ~createSnowPercussion.(57 - 12);
				30.wait;
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
					var snowFadeIn = Env([0, 0.05], [10], 1);
					var stream = snowFadeIn.asStream;
					var dt = 0.1;
					(snowFadeIn.duration / dt + 1).do {
						~padSynths.collect { | synth | synth.set(\amp, stream.next) };
						0.1.wait;

					};
				}.play;

			};
			routine.play;
			// Cleanup function
			{
				"Cleaning up a".postln;
				routine.stop;
				snowPercCleanup.();
				~padSynths.collect  { | synth | synth.release; };
				~snowSynths.collect  { | synth | synth.release; };
			}
		},
		b: {
			~padSynths.collect  { | synth | synth.release; };
			~snowSynths.collect  { | synth | synth.release; };
			~padSynths = [67, 71, 72, 74, 76].midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.05, \pan, rrand(-1.0, 1), \attack, 10, \release, 10]) };
			~snowSynths = [67, 71, 72, 74, 76].midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \freq, freq, \resonzAmp, 100, \attack, 10, \release, 10])
			};
			{
				~padSynths.collect  { | synth | synth.release; };
				~snowSynths.collect  { | synth | synth.release; };
			}
		},
		c: {
			~padSynths.collect  { | synth | synth.release; };
			~snowSynths.collect  { | synth | synth.release; };
			~padSynths = [65, 71, 72, 74, 76].midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.05, \pan, rrand(-1.0, 1), \attack, 10, \release, 10]) };
			~snowSynths = [65, 71, 72, 74, 76].midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \freq, freq, \resonzAmp, 100, \attack, 10, \release, 10])
			};
			{
				~padSynths.collect  { | synth | synth.release; };
				~snowSynths.collect  { | synth | synth.release; };
			}
		},
		d: {
			var notes = [40, 52, 62, 67, 69, 71, 74];
			~snowSynths.collect { | synth |  synth.release };
			~padSynths.collect { | synth |  synth.release };
			~padSynths = notes.midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.15, \pan, rrand(-1.0, 1)]) };
			~snowSynths = notes.midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \resonzAmp, 100, \freq, freq])
			};
			Synth(\sinFmHit, [\freq, notes[0].midicps, \cmRatio, 5, \release, 10, \amp, 0.7, \modIndex, 1.3, \pan, -1]);
			Synth(\sinFmHit, [\freq, (notes[0] - 12).midicps, \cmRatio, 5, \release, 10, \amp, 0.15, \modIndex, 1.3, \pan, 1]);
			{
				~padSynths.collect  { | synth | synth.release; };
				~snowSynths.collect  { | synth | synth.release; };
			}
		},
		e: {
			var notes = [38, 50, 62, 65, 67, 69, 72];
			~snowSynths.collect { | s |  s.release };
			~padSynths.collect { | s | s.release };
			~padSynths = notes.midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0.15, \pan, rrand(-1.0, 1)]) };
			~snowSynths = notes.midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \resonzAmp, 100, \freq, freq])
			};

			Synth(\sinFmHit, [\freq, notes[0].midicps, \cmRatio, 5, \release, 10, \amp, 0.45, \modIndex, 1.3, \pan, -1]);
			Synth(\sinFmHit, [\freq, (notes[0] - 12).midicps, \cmRatio, 5, \release, 10, \amp, 0.15, \modIndex, 1.3, \pan, 1]);
			{
				~padSynths.collect  { | synth | synth.release; };
				~snowSynths.collect  { | synth | synth.release; };
			}
		},
		f: {
			var freq = 71.midicps;
			~padSynths.last.set(\freq, freq);
			Synth(\sinFmHit, [\freq, freq, \cmRatio, 2, \release, 10, \amp, 0.1, \modIndex, 2, \pan, 0.5]);
			{
				~padSynths.collect  { | synth | synth.release; };
				~snowSynths.collect  { | synth | synth.release; };
			}
		},
		g: {
			var notes = [41, 53, 62, 65, 67, 69, 76];
			~snowSynths.collect { | s |  s.release };
			~padSynths.collect { | s | s.release };
			Synth(\noiseFall);
			~padSynths = notes.midicps.collect { | freq | Synth(\mysteriousTremolo, [\freq, freq, \amp, 0.25, \pan, 0, \tremoloRateMul, 1]) };
			{
				~padSynths.collect  { | synth | synth.release; };
			}
		},
		h: {
			var notes = [43, 55, 62, 64, 67, 69, 74];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 2);
			};
			{
				~padSynths.collect  { | synth | synth.release; };
			}
		},
		i: {
			var notes = [45, 57, 60, 64, 67, 71, 74];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 3);
				~padSynths[i].set(\width, 2.5);
				~padSynths[i].set(\spread, 0.1);
			};
			{
				~padSynths.collect  { | synth | synth.release; };
			}
		},
		// m. 18
		j: {
			var notes = [47, 59, 60, 64, 67, 71, 74];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 4);
				~padSynths[i].set(\spread, 0.2);
			};
			{
				~padSynths.collect  { | synth | synth.release; };
			}
		},
		k: {
			var notes = [48, 60, 64, 67, 71, 74, 77];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 5);
				~padSynths[i].set(\bpfRQAdd, 1);
				~padSynths[i].set(\spread, 0.3);
				~padSynths[i].set(\width, 3);
			};
			{
				~padSynths.collect  { | synth | synth.release; };
			}
		},
		l: {
			var notes = [50, 62, 64, 67, 71, 74, 77];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 6);
				~padSynths[i].set(\bpfRQAdd, 2);
				~padSynths[i].set(\spread, 0.4);
			};
			{
				~padSynths.collect  { | synth | synth.release; };
			}
		},
		m: {
			var notes = [52, 64, 67, 71, 74, 77, 81];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 7);
				~padSynths[i].set(\bpfRQAdd, 3);
				~padSynths[i].set(\amp, 0.3);
				~padSynths[i].set(\spread, 0.5);
				~padSynths[i].set(\width, 3.5);
			};
			{
				~padSynths.collect  { | synth | synth.release; };
			}
		},
		n: {
			var notes = [53, 65, 67, 71, 74, 77, 81];
			notes.midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 8);
				~padSynths[i].set(\bpfRQAdd, 4);
				~padSynths[i].set(\amp, 0.35);
				~padSynths[i].set(\spread, 0.7);
			};
			{
				~padSynths.collect  { | synth | synth.release; };
			}
		},
		// m. 23
		o: {
			var routine = r {
				var notes = [55, 67, 67, 71, 74, 77, 81];
				notes.midicps.collect { | freq, i |
					~padSynths[i].set(\freq, freq);
					~padSynths[i].set(\tremoloRateMul, 9);
					~padSynths[i].set(\bpfRQAdd, 8);
					~padSynths[i].set(\amp, 0.4);
					~padSynths[i].set(\spread, 1);
					~padSynths[i].set(\width, 4);
				};
				1.wait;
				5.do { | i |
					~padSynths.collect { | s |
						s.set(\bpfRQAdd, (5 - i));
						~padSynths[i].set(\tremoloRateMul, 9 * (5 - i) / 5 + 1);
					};
					1.wait;
				};
				~padSynths.collect { | s |
					s.release;
				};
			};
			routine.play;
			{
				routine.stop;
				~padSynths.collect  { | synth | synth.release; };
			}
		},
		p: {
			var routine, bassBellRoutine;
			TempoClock.tempo = 54 / 60;
			routine = r {
				var release = 0;
				var commonArgs = { [\amp, 1, \pan, rrand(-1.0, 1), \tremoloRateMul, 0.5, \bpfRQAdd, 4, \release, release, \curve, 1, \attack, 2 / TempoClock.tempo] };
				var bassSwellAmp = 0.5;
				var chords = [
					[37, 49, 58, 61, 63, 65, 72],
					[39, 51, 58, 60, 63, 65, 70],
					[41, 53, 56, 60, 63, 67, 70],
					[43, 55, 56, 60, 63, 67, 70],
				];


				// m. 27
				~basses = [Synth(\bouncyBass, [\freq, chords[0][0].midicps, \amp, 0.25, \pan, 0.5]), Synth(\bouncyBass, [\freq, chords[0][0].midicps / 2, \amp, 0.25, \pan, 0])];
				Synth(\noiseFall, [\direction, -1]);
				~padSynths = chords[0].midicps.collect { | freq |
					Synth(\sinFmHit, [\freq, freq, \cmRatio, 2, \release, 5, \amp, 0.05, \modIndex, 10, \pan, rrand(-1.0,1)]);
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[0][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				0.5.wait;
				~basses.collect { | synth | synth.release };
				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[1].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[1][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				2.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[2].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[2][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				2.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[3].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 4 / TempoClock.tempo, \freq, (chords[3][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				4.wait;


				// m. 29.5
				~padSynths.collect { | s | s.release };
				~padSynths = chords[0].midicps.collect { | freq |
					Synth(\sinFmHit, [\freq / 2, freq, \cmRatio, 2, \release, 5, \amp, 0.1, \modIndex, 10, \pan, rrand(-1.0,1)]);
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[0][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				2.wait;
				~padSynths.collect { | s | s.release };
				~basses = [Synth(\bouncyBass, [\freq, chords[1][0].midicps, \amp, 0.25, \pan, 0.5])];
				~padSynths = chords[1].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[1][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				0.5.wait;
				~basses.collect { | synth | synth.release };
				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[2].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[2][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				2.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[3].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[3][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				2.wait;
				// Change the attack time
				commonArgs = { [\amp, 1, \pan, rrand(-1.0, 1), \tremoloRateMul, 0.5, \bpfRQAdd, 4, \release, release, \curve, 1, \attack, 1.5 / TempoClock.tempo] };


				// m. 31.5
				~padSynths.collect { | s | s.release };
				Synth(\bassDrum, [\freq, 30, \attack, 0.02, \release, 2]);
				Synth(\noiseFall, [\direction, 1, \startFreq, 1000, \endFreq, 5000, \dur, 8, \release, 0]);
				~padSynths = chords[0].midicps.collect { | freq |
					Synth(\sinFmHit, [\freq / 2, freq, \cmRatio, 2, \release, 5, \amp, 0.1, \modIndex, 10, \pan, rrand(-1.0,1)]);
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[0][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[1].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[1][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[2].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[2][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[3].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 3.5 / TempoClock.tempo, \freq, (chords[3][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				3.5.wait;


				// m. 33.5
				~padSynths.collect { | s | s.release };
				Synth(\bassDrum, [\freq, 30, \attack, 0.02, \release, 2]);
				~padSynths = chords[0].midicps.collect { | freq |
					Synth(\sinFmHit, [\freq / 2, freq, \cmRatio, 2, \release, 5, \amp, 0.1, \modIndex, 10, \pan, rrand(-1.0,1)]);
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[0][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);

				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[1].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[1][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[2].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
				};
				Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[2][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2]);
				1.5.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[3].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.() ++ [\release, 1])
				};
				Synth(\sinFmHit, [\release, 2, \attack, 2 / TempoClock.tempo, \freq, (chords[3][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,0, \cmRatio, 1, \modIndexCurve, 0, \reverbMix, 0.2]);
				2.wait;
				~padSynths.collect { | s | s.release };
				~padSynths = chords[3].midicps.collect { | freq |
					Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.() ++ [\release, 5, \curve, -4, \attack, 1 / TempoClock.tempo])
				};
				2.wait;
				~padSynths.collect { | s | s.release };

			};
			routine.play;
			{
				routine.stop;
				~basses.collect { | s | s.release; };
				~padSynths.collect { | s | s.release };
			}
		},
		q: {
			var cleanups = [];
			var routine = r {
				cleanups = cleanups.addAll([
					~createSnowPercussion.(37),
					~createSnowPercussion.(49, 0)
				]);
				cleanups.postln;
				15.wait;
				cleanups = cleanups.add(~createSnowPercussion.(35));
			};
			routine.play;
			{
				routine.stop;
				cleanups.collect { | cleanup | cleanup.() };
			};
		},
		r: {
			var routine;
			TempoClock.tempo = 45/60;
			routine = r {
				~sinSynths = [59 - 24, 59 - 12, 57, 59, 61, 63, 20].midicps.collect { | freq | Synth(\fmSynth, [\modIndex, 0.2, \cmRatio, 2, \attack, 1, \release, 1, \pan, 0.25, \freq, freq, \amp, 0.025, \sustain, 1]) };
				Synth(\snowFall, [\amp, 1, \grainRate, 3, \dur, 40, \startFreq, 500, \endFreq, 100]);
				10.wait;
				~sinSynths.collect { | s | s.release; };
			};
			routine.play;
			{
				routine.stop;
				~sinSynths.collect { | s | s.release; };
			}
		}
	)
};
~createGui = {
	var label;
	var isFullScreen=true;
	var cleanupFunction = {};
	var doubleCueInterval = 1.5; // How many seconds before you can click a patch again
	var canPlayNext = true;
	~currentPatch = nil;
	Window.closeAll;
	w = Window("Score", Rect(200, 200, 400, 400));
	label = StaticText(w, Rect(0, 0, 400, 400));
	label.string = ~currentPatch;
	label.font_(Font(Font.default, 400/2));
	label.align = \center;
	w.front;
	~playPatch = { | patchName |
		~currentPatch = patchName.asSymbol;
		label.string = ~currentPatch;
		cleanupFunction = ~seq[~currentPatch].();
	};
	w.view.keyDownAction = { | doc, char, mod, unicode, keycode, key |
		unicode.postln;
		// Letters a-z are patches
		if((unicode >= 97) && (unicode <= 122)) {
			if((cleanupFunction == nil) || (char.asSymbol != ~currentPatch)) {
				~playPatch.(char);
			}
		};
		// Escape stops the patch
		if(unicode == 27) {
			"Cleaning Up".postln;
			cleanupFunction.();
			cleanupFunction = nil;
		};
		// Enter enters and exits fullscreen
		if(unicode == 13) {
			if(isFullScreen) {
				w.endFullScreen; isFullScreen=false;
				label.bounds = Rect(0, 0, 400, 400);
				label.font_(Font(Font.default, 400/2));

			} {
				w.fullScreen; isFullScreen=true;
				label.bounds = Rect(0,0, Window.availableBounds.width, Window.availableBounds.height);
				label.font_(Font(Font.default, Window.availableBounds.height/2));
			}
		};
		// Space increments the sequence
		if(unicode == 32) {
			if(canPlayNext) {
				if(~currentPatch != nil) {
					var orderedSeq = ~seq.keys.asArray.sort;
					var next = orderedSeq.indexOf(~currentPatch) + 1;
					~playPatch.(orderedSeq[next]);
				} {
					~playPatch.(\a);
				};
				canPlayNext = false;
				r {
					doubleCueInterval.wait;
					canPlayNext = true;
				}.play;
			} {
				"Next patch is locked!".postln;
			}

		};
	};
};
s.waitForBoot {
	r {
		~loadSynthsAndSamples.();
		s.sync;
		~createSeq.();
	}.play;
	~createGui.();
	s.meter;
}
)