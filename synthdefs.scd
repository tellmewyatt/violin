// Evenly pans a signal over the specified number of channels, matching the orientation of the CECM studio
~createPanner = {
	var orientation = if(s.options.numOutputBusChannels == 8, { 0 },
		{ 0.5 });
	var nchans = s.options.numOutputBusChannels;
	var channelMaps = ~config.channelMaps;
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
// Evenly pans a signal over specified number of channels and allows for splaying the signal as well.
~createSplayer = {
	var orientation = if(s.options.numOutputBusChannels == 8, { 0 },
		{ 0.5 });
	var nchans = s.options.numOutputBusChannels;
	var channelMaps = ~config.channelMaps;
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
// Plays white noise signal across each channel
~testPanner = {
	var sig = WhiteNoise.ar(0.05) * EnvGen.kr(Env.perc, Impulse.kr(1));
	var pan = Latch.ar(LFSaw.kr(1/8, 0, 1), Impulse.ar(1));
	~panEvenly.(sig, pan)
};
SynthDef(\snow, { |
	bufnum,
	amp=0.05,
	out=0,
	ringDecayTime=0.1,
	freq=400,
	freqLagTime=0.2,
	bwr=1,
	resonzAmp = 4,
	resonzAmpLagTime = 4,
	gate=1,
	attack=0.1,
	release=5,
	grainDur=2,
	grainRate=2 |
	var env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
	var trigger = Impulse.kr(grainRate);
	var sig = GrainBuf.ar(s.options.numOutputBusChannels, trigger, grainDur, bufnum, BufRateScale.kr(bufnum), TRand.ar(0, 1, trigger), 2, TRand.ar(-0.5, 0.5, trigger));
	ringDecayTime = ringDecayTime.max(0.00001).min(5);
	sig = Resonz.ar(sig, freq.lag(freqLagTime), bwr) *  resonzAmp.lag(resonzAmpLagTime) + (sig * amp);
	sig = sig * env;
	Out.ar(
		out,
		sig.equi(EQuiParams(24.0, -11.25, 0.6, 2573.0, 0.25, 1.0, 49.0, 4.25, 2.41, 3500.0, 0.0, 1.0, 6000.0, 0.0, 1.0))
	);
}).add;
SynthDef(\sinFmHit, { | freq = 200, modIndex = 10, cmRatio=2.31, pan=0, width=2, out=0, release=2, attack=0, amp=0.1, curve= -4, modIndexCurve= -4, reverbMix= 0.7  |
	var env = EnvGen.kr(Env.perc(attack, release, curve: curve), doneAction: 2);
	var sig;
	modIndex = EnvGen.kr(Env.perc(attack,release, curve: modIndexCurve), 1, modIndex);
	sig = ~panEvenly.(SinOsc.ar(freq + SinOsc.ar(cmRatio * freq, 0.2, modIndex * cmRatio * freq), 0.5pi, 0.5), pan, width=2);
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
SynthDef(\mysteriousPad, { | out=0, freq = 900, amp =0.05, pan=0, gate=1, freqSpreadSemitones=0.3, release=5, ampMod=1.0, ampModMul=1, bpfRQAdd = 0, attack=2, freqLag=0 |
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
SynthDef(\m29Pad, { | out=0, freq = 900, pan=0, gate=1, freqSpreadSemitones=0.3, release=5, attack=2, freqLag=0, ampLag=4, bpfRQAddLag=4, ampBus, bpfRQAddBus |
	var env, sig, filterEnv, diminuendoEnv;
	var amp = In.kr(ampBus, 1);
	var bpfRQAdd = In.kr(bpfRQAddBus, 1);
	freq.lag(freqLag);
	env = EnvGen.kr(Env.adsr(attack, attack, 0.9, release), gate, doneAction: 2);
	sig = Mix.ar(20.collect { | i |
		var lfo = SinOsc.ar(Rand(0.1, 1), 0, 1);
		var spread = (lfo * Rand(freqSpreadSemitones.neg, freqSpreadSemitones)).midiratio;
		Saw.ar(
			freq * spread,
			Rand(0.1, 1))
	});
	sig = BPF.ar(sig, freq, 0.2 + bpfRQAdd.lag(bpfRQAddLag));
	sig = sig + Mix.ar(
		SinOsc.ar([freq, freq * 2], 0, 0.1)
	);
	sig = FreeVerb.ar(sig, 0.8, 0.9);
	Out.ar(
		out,
		~panEvenly.(sig * amp.lag(ampLag) * env, pan)
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
SynthDef(\playSample, { | out=0, bufnum, pan, width=2, amp=1, reverbOut, reverbAmp=0, reverbDelay=0 |
	var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, doneAction: 2) * amp;
	sig = ~panEvenly.(sig, pan, width);
	Out.ar(reverbOut, DelayL.ar(sig, 0.5, reverbDelay, reverbAmp));
	Out.ar(out, sig);
}).add;
SynthDef(\reverb, { | out=0, in, room=0.5, damp=0.5, amp=1 |
	Out.ar(out, FreeVerb.ar(In.ar(in, s.options.numOutputBusChannels), 1, room, damp, amp));
}).add;
SynthDef(\bassDrum, { | freq = 40, amp = 1, out=0, release=1, attack=0.05 |
	var sig = ~panEvenly.(
		SinOsc.ar(Rand(1, 4! 20) * freq, 0.5*pi) * amp * EnvGen.kr(Env.perc(attack, release),
			1, doneAction: 2) * 0.3,
		0, // pan
		2, // width (Each signal is spread over how many channels?)
		1 // spread // How far the signals are spread from each other
	);
	Out.ar(out, sig);
}).add;