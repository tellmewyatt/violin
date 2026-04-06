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
~score = (
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
		var routine = r {
			var freq = 71.midicps;
			~padSynths.last.set(\freq, freq);
			Synth(\sinFmHit, [\freq, freq, \cmRatio, 2, \release, 10, \amp, 0.1, \modIndex, 2, \pan, 0.5]);
			4.wait;
			// m. 15
			~snowSynths.collect { | s |  s.release };
			~padSynths.collect { | s | s.release };
			Synth(\noiseFall);
			~padSynths = chords[0].midicps.collect { | freq | Synth(\mysteriousTremolo, [\freq, freq, \amp, 0.25, \pan, 0, \tremoloRateMul, 1]) };
			4.wait;
			// m. 16
			chords[1].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 3);
				~padSynths[i].set(\width, 2.5);
				~padSynths[i].set(\spread, 0.1);
			};
			4.wait;
			// m. 17
			chords[2].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 2);
			};
			4.wait;
			// m. 18
			Synth(\playSample, [\bufnum, ~samples.violin2, \amp, 0.2, \pan, -0.5, \width, 4, \reverbOut, ~busses.reverb, \reverbAmp, ~config.reverb.recordedViolinAmp, \reverbDelay, 0]);
			chords[3].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 4);
				~padSynths[i].set(\spread, 0.2);
			};
			4.wait;
			// m. 19
			chords[4].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 5);
				~padSynths[i].set(\bpfRQAdd, 1);
				~padSynths[i].set(\spread, 0.3);
				~padSynths[i].set(\width, 3);
			};
			4.wait;
			// m. 20
			chords[5].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 6);
				~padSynths[i].set(\bpfRQAdd, 2);
				~padSynths[i].set(\spread, 0.4);
			};
			4.wait;
			// m. 21
			Synth(\playSample, [\bufnum, ~samples.violin3, \amp, 0.2, \pan, 0.5, \width, 4, \reverbOut, ~busses.reverb, \reverbAmp, ~config.reverb.recordedViolinAmp, \reverbDelay, 0.05]);
			chords[6].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 7);
				~padSynths[i].set(\bpfRQAdd, 3);
				~padSynths[i].set(\amp, 0.3);
				~padSynths[i].set(\spread, 0.5);
				~padSynths[i].set(\width, 3.5);
			};
			4.wait;
			// m. 22
			chords[7].midicps.collect { | freq, i |
				~padSynths[i].set(\freq, freq);
				~padSynths[i].set(\tremoloRateMul, 8);
				~padSynths[i].set(\bpfRQAdd, 4);
				~padSynths[i].set(\amp, 0.35);
				~padSynths[i].set(\spread, 0.7);
			};
			8.wait;
			// m. 23
			chords[8].midicps.collect { | freq, i |
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
		TempoClock.tempo = 60 / 60;
		routine.play;
		{
			routine.stop;
			~padSynths.collect  { | synth | synth.release; };
			~snowSynths.collect  { | synth | synth.release; };
		}
	},
	g: {
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
	h: {
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
	i: {
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
		var commonArgs = [
			\modIndex, 4,
			\cmRatio, 2,
			\attack, 0.01,
			\release, 1,
			\pan, 0.25,
			\amp, 0.05,
			\sustain, 1
		];
		TempoClock.tempo = 44/60;
		routine = r {
			// m. 38
			~sinSynths = chords[0].midicps.collect { | freq |
				Synth(\fmSynth, [\freq, freq] ++ commonArgs)
			};
			Synth(\snowFall, [\amp, 1, \grainRate, 3, \dur, 40, \startFreq, 500, \endFreq, 100]);
			6.wait;
			chords[1].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			4.5.wait;
			chords[2].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			1.5.wait;

			// m. 41
			chords[3].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			0.5.wait;
			chords[4].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			0.75.wait;


			chords[0].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			6.wait;
			chords[1].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			4.5.wait;
			chords[2].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			1.5.wait;
			chords[3].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			0.5.wait;
			chords[4].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			0.75.wait;

			// Final descent
			finalChords[0].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			4.5.wait;
			~sinSynths.collect { | s | s.release; };
			1.wait;
			~sinSynths = finalChords[1].midicps.collect { | freq |
				Synth(\fmSynth, [\freq, freq] ++ commonArgs)
			};
			5.wait;

			// m. 47
			~sinSynths = finalChords[2].midicps.collect { | freq, i |
				~sinSynths[i].set(\freq, freq);
			};
			7.wait;
			~sinSynths.collect { | s | s.release; };
			1.wait;

			// m. 49
			~sinSynths = finalChords[2].midicps.collect { | freq |
				Synth(\fmSynth, [\freq, freq] ++ commonArgs)
			};
			2.wait;
			~sinSynths.collect { | s | s.release; };
			2.wait;
			~sinSynths = finalChords[2].midicps.collect { | freq |
				Synth(\fmSynth, [\freq, freq] ++ commonArgs)
			};
			6.wait;
			~sinSynths.release;
		};
		routine.play;
		{
			routine.stop;
			~sinSynths.collect { | s | s.release; };
		}
	}
)