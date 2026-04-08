(
"./config.scd".loadRelative;
s.options.memSize = ~config.memSize;
s.options.numOutputBusChannels = ~config.numOutputBusChannels;
s.reboot;
~createEffects = {
	~busses = (
		reverb: Bus.audio(s, s.options.numOutputBusChannels);
	);
	~reverb = Synth.tail(s, \reverb, [\in, ~busses.reverb, \amp, 1, \size, 0.9, \damp, 0.5]);
};
s.waitForBoot {
	r {
		~samples = (
			snow: Buffer.readChannel(s, "./audio/snow.flac".resolveRelative, channels: [0]),
			score: (1..4).collect { | i |
				Buffer.readChannel(s, ("./audio/violin-score-0" ++ i.asString ++ ".wav").resolveRelative, channels: [0])
			},
			violin2: Buffer.readChannel(s, "./audio/violin-2.flac".resolveRelative, channels: [0]),
			violin3: Buffer.readChannel(s, "./audio/violin-3.flac".resolveRelative, channels: [0]),
		);
		"./synthdefs.scd".loadRelative;
		s.sync;
		~createEffects.();
		"./score.scd".loadRelative;
	}.play;
	"./gui.scd".loadRelative;
	s.meter;
}
)
x = Synth(\playSample, [\bufnum, ~samples.score[0], \amp, 2])
x = Synth(\playSample, [\bufnum, ~samples.score[1], \amp, 2])
x = Synth(\playSample, [\bufnum, ~samples.score[2], \amp, 2])
x = Synth(\playSample, [\bufnum, ~samples.score[3], \amp, 2])