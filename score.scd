~getPatchAtM49 = { | i |
	var routine;
	var chords = [
		[59 - 24, 59 - 12, 56, 59, 61, 63, 70],
		[61 - 24, 61 -12, 56, 58, 61, 63, 68],
		[63 - 24, 63 -12, 54, 58, 61, 65, 68],
		[65 - 24, 65 -12, 54, 58, 61, 65, 68],
		[66 - 24, 66 -12, 54, 58, 61, 65, 68]
	];
	var finalChords = [
		[67 - 24, 67 -12, 65 - 12, 57, 60, 63, 67],
		[67 - 24, 67 -12, 65 - 12, 57, 60, 63, 67] -2,
		[67 - 24, 67 -12, 65 - 12, 57, 60, 63, 67] -4
	];
	var amp = 0.05;
	var resonzAmp = 25;
	var patches = [
		{
			routine = r {
				// m. 38
				~snowSynths = chords[0].midicps.collect { | freq |
					Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \freq, freq, \resonzAmp, resonzAmp, \attack, 2, \release, 2, \amp, amp, \freqLagTime, 0])
				};

				Synth(\snowFall, [\amp, 1, \grainRate, 3, \dur, 4, \startFreq, 5000, \endFreq, 100]);
				Synth(\snowFall, [\amp, 1, \grainRate, 3, \dur, 4, \endFreq, 10000, \startFreq, 100, \direction, -1]);
				4.wait;
				if(~config.demoViolin) {
					x = Synth(\playSample, [\bufnum, ~samples.score[3], \amp, 2]);
				};
			};
			routine.play;
		},
		{
			chords[1].midicps.collect { | freq, i |
				~snowSynths[i].set(\freq, freq);
			};
		},
		{
			routine = r {
				chords[2].midicps.collect { | freq, i |
					~snowSynths[i].set(\freq, freq);
				};
				1.5.wait;

				// m. 41
				chords[3].midicps.collect { | freq, i |
					~snowSynths[i].set(\freq, freq);
				};
				0.5.wait;
				chords[4].midicps.collect { | freq, i |
					~snowSynths[i].set(\freq, freq);
				};
				0.75.wait;


				chords[0].midicps.collect { | freq, i |
					~snowSynths[i].set(\freq, freq);
				};
			};
			routine.play;
		},
		{
			chords[1].midicps.collect { | freq, i |
				~snowSynths[i].set(\freq, freq);
			};
		},
		{
			routine = r {
				chords[2].midicps.collect { | freq, i |
					~snowSynths[i].set(\freq, freq);
				};
				1.5.wait;
				chords[3].midicps.collect { | freq, i |
					~snowSynths[i].set(\freq, freq);
				};
				0.5.wait;
				chords[4].midicps.collect { | freq, i |
					~snowSynths[i].set(\freq, freq);
				};
				0.75.wait;
				// Final descent
				finalChords[0].midicps.collect { | freq, i |
					~snowSynths[i].set(\freq, freq);
				};
				3.5.wait;

			};
			routine.play;
		},
		{
			~snowSynths.collect { | s | s.release; };
		},
		{
			~snowSynths = finalChords[1].midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \freq, freq, \resonzAmp, resonzAmp, \attack, 2, \release, 2, \amp, amp, \freqLagTime, 0])
			};
		},
		{
			// m. 47
			~snowSynths = finalChords[2].midicps.collect { | freq, i |
				~snowSynths[i].set(\freq, freq);
			};
		},
		{
			~snowSynths.collect { | s | s.release; };
		},
		{
			// m. 49
			~snowSynths = finalChords[2].midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \freq, freq, \resonzAmp, resonzAmp, \attack, 2, \release, 2, \amp, amp])
			};
		},
		{
			~snowSynths.collect { | s | s.release; };
		},
		{
			~snowSynths = finalChords[2].midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \freq, freq, \resonzAmp, resonzAmp, \attack, 2, \release, 2, \amp, amp, \freqLagTime, 0])
			};
		},
		{
			var fadeOut = Env([1, 0], [4], 1).asStream;
			routine = r {
				(6.2 / 0.05).do {
					var value = fadeOut.next;
					~snowSynths.collect { | s |
						s.set(\amp, value * amp);
						s.set(\resonzAmp, value * resonzAmp);
					};
					0.05.wait;
				};
				~snowSynths.collect { | s | s.release };
			};
			routine.play;
		}
	];
	{
		TempoClock.tempo = 38/60;
		patches[i].();
		{
			x.release;
			routine.stop;
			~snowSynths.collect { | s | s.release; };
		}
	};
};
~getPatchAtG = { | i |
	var chords = [
		[41, 53, 62, 65, 67, 69, 76],
		[43, 55, 62, 64, 67, 69, 74],
		[45, 57, 60, 64, 67, 71, 74],
		[47, 59, 60, 64, 67, 71, 74],
		[48, 60, 64, 67, 71, 74, 77],
		[50, 62, 64, 67, 71, 74, 77],
		[52, 64, 67, 71, 74, 77, 81],
		[53, 65, 67, 71, 74, 77, 81],
		[55, 67, 67, 71, 74, 77, 81]
	];
	var patches = [
		{
			~snowSynths.collect { | s |  s.release };
			~padSynths.collect { | s | s.release };
			Synth(\noiseFall);
			~padSynths = chords[0].midicps.collect { | freq | Synth(\mysteriousTremolo, [\freq, freq, \amp, 0.25, \pan, 0, \tremoloRateMul, 1]) };
			if(~config.demoViolin) {
				x = Synth(\playSample, [\bufnum, ~samples.score[1], \amp, 2]);
			}
		},
		// m. 16
		{
			chords[1].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 3);
				~padSynths[i].set(\width, 2.5);
				~padSynths[i].set(\spread, 0.1);
			};
		},
		// m. 17
		{
			chords[2].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 2);
			};

		},
		// m. 18
		{
			Synth(\playSample, [\bufnum, ~samples.violin2, \amp, 0.2, \pan, -0.5, \width, 4, \reverbOut, ~busses.reverb, \reverbAmp, ~config.reverb.recordedViolinAmp, \reverbDelay, 0]);
			chords[3].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 4);
				~padSynths[i].set(\spread, 0.2);
			};

		},
		// m. 19
		{
			chords[4].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 5);
				~padSynths[i].set(\bpfRQAdd, 1);
				~padSynths[i].set(\spread, 0.3);
				~padSynths[i].set(\width, 3);
			};
		},
		// m. 20
		{
			chords[5].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 6);
				~padSynths[i].set(\bpfRQAdd, 2);
				~padSynths[i].set(\spread, 0.4);
			};
		},
		// m. 21
		{

			Synth(\playSample, [\bufnum, ~samples.violin3, \amp, 0.2, \pan, 0.5, \width, 4, \reverbOut, ~busses.reverb, \reverbAmp, ~config.reverb.recordedViolinAmp, \reverbDelay, 0.05]);
			chords[6].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 7);
				~padSynths[i].set(\bpfRQAdd, 3);
				~padSynths[i].set(\amp, 0.3);
				~padSynths[i].set(\spread, 0.5);
				~padSynths[i].set(\width, 3.5);
			};
		},
		// m. 22
		{
			chords[7].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 8);
				~padSynths[i].set(\bpfRQAdd, 4);
				~padSynths[i].set(\amp, 0.35);
				~padSynths[i].set(\spread, 0.7);
			};
		},
		// m. 23
		{
			TempoClock.tempo = 60/60;
			r {
				chords[8].midicps.collect { | freq, i |
					~padSynths[i].set(\freq, freq);
					~padSynths[i].set(\tremoloRateMul, 9);
					~padSynths[i].set(\bpfRQAdd, 8);
					~padSynths[i].set(\amp, 0.4);
					~padSynths[i].set(\spread, 1);
					~padSynths[i].set(\width, 4);
					~padSynths[i].set(\release, 2);
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
			}.play;
		}
	];
	{
		patches[i].();
		{
			~padSynths.collect  { | synth | synth.release; };
			~snowSynths.collect  { | synth | synth.release; };
			x.release;
		}
	};
};
~createSnowPercussion = { | freqs, pan=1, dur=45 |
	var durs = [
		10,
		25,
		10
	].normalizeSum * dur;
	var release = 5;
	var stream = Pmono(
		\snowPerc,
		\bufnum, ~samples.snow,
		\pan, pan,
		\dur, 0.1,
		\percAmp, Pseg([0, 4, 4, 4], durs),
		\playbackRate, Pseg([1, 1, 0.1, 0.1], durs),
		\combAmp, Pseg([0, 0.7, 0.7, 0.7], durs),
		\amp, 0.4,
		\width, 4,
		\release, Pfunc({ release })
	).play;
	{
		r {
			release = 1;
			0.11.wait;
			stream.stop;
		}.play;
	};
};
~score = (
	a: {
		var snowPercCleanup;
		var routine = r {
			// Insert tapping
			// Col Legno Battuto
			// Maybe some harmonc trills? Flautando - ask about playing a low A with touch harmonics
			/*snowPercCleanup = ~createSnowPercussion.(57 - 12);
			30.wait;*/
			~padSynths = [69, 71, 72, 74, 76].midicps.collect { | freq | Synth(\mysteriousPad, [\freq, freq, \amp, 0, \pan, rrand(-1.0, 1)]) };
			~snowSynths = [69, 71, 72, 74, 76].midicps.collect { | freq |
				Synth(\snow, [\bufnum, ~samples.snow, \bwr, 0.01, \resonzAmp, 0, \freq, freq])
			};
			15.wait;
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
			10.wait;
			if(~config.demoViolin) {
				x = Synth(\playSample, [\bufnum, ~samples.score[0], \amp, 2]);
			}

		};
		routine.play;
		// Cleanup function
		{
			"Cleaning up a".postln;
			routine.stop;
			snowPercCleanup.();
			~padSynths.collect  { | synth | synth.release; };
			~snowSynths.collect  { | synth | synth.release; };
			if(~config.demoViolin) {
				x.release;
			};
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
		var routine, release;
		TempoClock.tempo = 1;
		routine = r {
			~padSynths.last.set(\freq, 71.midicps);
			Synth(\sinFmHit, [\freq, 71.midicps, \cmRatio, 2, \release, 10, \amp, 0.1, \modIndex, 2, \pan, 0.5]);
			4.wait;
			release = ~getPatchAtG.(0).();
			4.wait;
			release = ~getPatchAtG.(1).();
			4.wait;
			release = ~getPatchAtG.(2).();
			4.wait;
			release = ~getPatchAtG.(3).();
			4.wait;
			release = ~getPatchAtG.(4).();
			4.wait;
			release = ~getPatchAtG.(5).();
			4.wait;
			release = ~getPatchAtG.(6).();
			4.wait;
			release = ~getPatchAtG.(7).();
			8.wait;
			release = ~getPatchAtG.(8).();
			6.wait;
			release.();
		};
		routine.play;
		{
			release.();
			routine.stop;
		};
	},
	g: {
		var voices = (
			1: (
				notes: [66, 62, 66, 64, 61, 59, 57,  54, 52, 50, 50] + 24,
				durs: [4, 4, 4, 4, 4, 4, 3, 2, 2, 1, 4]
			),
			2: (
				// From start
				notes: [76, 64, 66, 59, 59, 57, 57, 57, 50] + 12,
				durs: [8, 4, 12, 3, 2, 2, 1, 4]
			),
			3: ( // Lowest note, but swaps to bottom of treble clef at m. 35
				notes: [67 + 12, 69 + 12, 67 + 12, 69 +12, 71, 64, 64, 62, 62, 57],
				durs: [4, 4, 4, 4, 4, 4, 3, 2, 2, 1, 4]
			),
			4: ( // Starts on  d in m. 33. 3rd from bottom in treble chords
				notes: [\r, 62 + 12, 71, 71, 69, 69, 69, 62],
				durs: [16, 8, 3, 2, 2, 1, 4]
			),
			5: ( // Starts on A at m. 34 in treble clef
				notes: [\r, 66+12, 64+12, 61+12, 61+12, 66],
				durs: [20, 4, 3, 2, 2, 1, 4]
			),
			6: ( // starts at n, 34 on a
				notes: [\r, 69, 55, 57, 59, 61],
				durs: [21, 3, 2, 2, 2, 6]
			),
			7: (
				notes: [\r, 69, 67, 66, 64, 62, 61] - 24,
				durs: [32, 4/5,4/5,4/5,4/5,4/5]
			)
		);
		var bellVoice = (
			notes: [\r, 69, 67, 66, 64, 62, 61] - 24,
			durs: [32, 4/5,4/5,4/5,4/5,4/5, 2],
		);
		var totalDur = bellVoice.durs.sum;
		var items = [];
		var allRoutine;
		~busses.m29Amp.set(0);
		~busses.bpfRQAdd.set(0);
		TempoClock.tempo = 54 / 60;
		items = items.add(Pbind(
			\instrument, \sinFmHit,
			\freq, Pseq(bellVoice.notes.midicps),
			\dur, Pseq(bellVoice.durs),
			\cmRatio, 5,
			\release, 4,
			\amp, Pseq([0.25, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5]),
			\modIndex, 1.3
		));
		voices.collect { | v |
			var pbind = Pbind(
				\instrument, \m29Pad,
				\freqLag, 0.01,
				\attack, 4,
				\dur, Pseq(v.durs),
				\freq, Pseq(v.notes.midicps),
				\bpfRQAdd, Pseq(v.durs.size.collect { | i | i * 0.25 }),
				\ampBus, ~busses.m29Amp,
				\bpfRQAddBus, ~busses.bpfRQAdd,
				\pan, rrand(-1.0, 1),
				\release, 2,
				\legato, 1
			);
			items = items.add(pbind);
		};
		items = items.add(r {
			(totalDur / 0.1).do { | i |
				var amt = i * 0.1 / totalDur;
				~busses.m29Amp.set(amt * 0.075);
				~busses.bpfRQAdd.set(amt * 4);
				0.1.wait;
			}
		});
		allRoutine = r {
			if(~config.demoViolin) {
				TempoClock.tempo = 60 / 60;
				x = Synth(\playSample, [\bufnum, ~samples.score[2], \amp, 2]);
				12.wait;
			};
			TempoClock.tempo = 54 / 60;
			items.collect { | i | i.play; };
		}.play;
		{
			x.release;
			allRoutine.stop;
			items.collect { | item | item.stop; };
		}
	},
	h: {
		var routine, dynamicRoutine;
		var mysteriousTremoloAmp = 1;
		var bassSwellAmp = 0.5;
		var phraseLength = 10 * 4;
		var bassSwellAmpEnv = Env([1/3, 2/3], [32], -4);
		var mysteriousTremoloAmpEnv = Env([0.5, 1], [32], -4);
		var bassSwellStream;
		var mysteriousTremoloStream;
		TempoClock.tempo = 54 / 60;
		bassSwellStream = bassSwellAmpEnv.asStream;
		mysteriousTremoloStream = mysteriousTremoloAmpEnv.asStream;
		dynamicRoutine = r {
			(phraseLength / 0.1).do {
				bassSwellAmp = bassSwellStream.next;
				mysteriousTremoloAmp = mysteriousTremoloStream.next;
				0.1.wait;
			};
		};
		routine = r {
			var release = 0;
			var commonArgs = { [\amp, mysteriousTremoloAmp, \pan, rrand(-1.0, 1), \tremoloRateMul, 0.5, \bpfRQAdd, 4, \release, release, \curve, 1, \attack, 2 / TempoClock.tempo] };
			var chords = [
				[37, 49, 58, 61, 63, 65, 72],
				[39, 51, 58, 60, 63, 65, 70],
				[41, 53, 56, 60, 63, 67, 70],
				[43, 55, 56, 60, 63, 67, 70],
			];
			// m. 27
			~basses = [Synth(\bouncyBass, [\freq, chords[0][0].midicps, \amp, 0.15, \pan, 0.5]), Synth(\bouncyBass, [\freq, chords[0][0].midicps / 2, \amp, 0.15, \pan, 0])];
			Synth(\noiseFall, [\direction, -1]);
			~padSynths = chords[0].midicps.collect { | freq |
				Synth(\sinFmHit, [\freq, freq, \cmRatio, 2, \release, 5, \amp, 0.05, \modIndex, 10, \pan, rrand(-1.0,1)]);
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[0][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			0.5.wait;
			~basses.collect { | synth | synth.release };
			1.5.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[1].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[1][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			2.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[2].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[2][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			2.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[3].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 4 / TempoClock.tempo, \freq, (chords[3][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			4.wait;


			// m. 29.5
			~padSynths.collect { | s | s.release };
			~padSynths = chords[0].midicps.collect { | freq |
				Synth(\sinFmHit, [\freq / 2, freq, \cmRatio, 2, \release, 5, \amp, 0.1, \modIndex, 10, \pan, rrand(-1.0,1)]);
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[0][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			2.wait;
			~padSynths.collect { | s | s.release };
			~basses = [Synth(\bouncyBass, [\freq, chords[1][0].midicps, \amp, 0.25, \pan, 0.5])];
			~padSynths = chords[1].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[1][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			0.5.wait;
			~basses.collect { | synth | synth.release };
			1.5.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[2].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[2][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			2.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[3].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 2 / TempoClock.tempo, \freq, (chords[3][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			2.wait;
			// Change the attack time
			commonArgs = { [\amp, mysteriousTremoloAmp, \pan, rrand(-1.0, 1), \tremoloRateMul, 0.5, \bpfRQAdd, 4, \release, release, \curve, 1, \attack, 1.5 / TempoClock.tempo] };


			// m. 31.5
			~padSynths.collect { | s | s.release };
			Synth(\bassDrum, [\freq, 30, \attack, 0.02, \release, 2]);
			Synth(\noiseFall, [\direction, 1, \startFreq, 1000, \endFreq, 5000, \dur, 8, \release, 0]);
			~padSynths = chords[0].midicps.collect { | freq |
				Synth(\sinFmHit, [\freq / 2, freq, \cmRatio, 2, \release, 5, \amp, 0.1, \modIndex, 10, \pan, rrand(-1.0,1)]);
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[0][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			1.5.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[1].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[1][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			1.5.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[2].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[2][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			1.5.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[3].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 3.5 / TempoClock.tempo, \freq, (chords[3][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			3.5.wait;


			// m. 33.5
			~padSynths.collect { | s | s.release };
			Synth(\bassDrum, [\freq, 30, \attack, 0.02, \release, 2]);
			~padSynths = chords[0].midicps.collect { | freq |
				Synth(\sinFmHit, [\freq / 2, freq, \cmRatio, 2, \release, 5, \amp, 0.1, \modIndex, 10, \pan, rrand(-1.0,1)]);
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[0][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);

			1.5.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[1].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[1][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			1.5.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[2].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.())
			};
			Synth(\sinFmHit, [\release, 0.1, \attack, 1.5 / TempoClock.tempo, \freq, (chords[2][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,4, \cmRatio, 1, \modIndexCurve, 4, \reverbMix, 0.2, \width, 4]);
			1.5.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[3].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.() ++ [\release, 1])
			};
			Synth(\sinFmHit, [\release, 5, \attack, 5 / TempoClock.tempo, \freq, (chords[3][0]-12).midicps, \amp, bassSwellAmp, \modIndex, 5, \curve,0, \cmRatio, 1, \modIndexCurve, 0, \reverbMix, 0.2, \width, 4]);
			5.wait;
			~padSynths.collect { | s | s.release };
			~padSynths = chords[3].midicps.collect { | freq |
				Synth(\mysteriousTremolo, [\freq, freq] ++ commonArgs.() ++ [\release, 5, \curve, -4, \attack, 1 / TempoClock.tempo])
			};
			5.wait;
			~padSynths.collect { | s | s.release };

		};
		routine.play;
		dynamicRoutine.play;
		{
			dynamicRoutine.stop;
			routine.stop;
			~basses.collect { | s | s.release; };
			~padSynths.collect { | s | s.release };
		}
	},
	i: {
		var cleanups = [];
		var synth;
		var routine = r {
			synth = Synth(\superNoisy, [\amp, 1.5, \dur, 30]);
			7.wait;
			~createSnowPercussion.(
			[59 - 24, 59 - 12, 56, 59, 61, 63, 70].midicps, 0, 30);
		};
		routine.play;
		{
			routine.stop;
				synth.release;
			cleanups.collect { | cleanup | cleanup.() };
		};
	},
	j: ~getPatchAtM49.(0),
	k: ~getPatchAtM49.(1),
	l: ~getPatchAtM49.(2),
	m: ~getPatchAtM49.(3),
	n: ~getPatchAtM49.(4),
	o: ~getPatchAtM49.(5),
	p: ~getPatchAtM49.(6),
	q: ~getPatchAtM49.(7),
	r: ~getPatchAtM49.(8),
	s: ~getPatchAtM49.(9),
	t: ~getPatchAtM49.(10),
	u: ~getPatchAtM49.(11),
	v: ~getPatchAtM49.(12)
)