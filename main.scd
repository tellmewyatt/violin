(
"./config.scd".loadRelative;
s.options.memSize = ~config.memSize;
s.options.numOutputBusChannels = ~config.numOutputBusChannels;
s.reboot;
~createEffects = {
	~busses = (
		reverb: Bus.audio(s, s.options.numOutputBusChannels),
		bpfRQAdd: Bus.control(s, 1),
		m29Amp: Bus.control(s, 1)
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
			paperCrumple:
			plasticCrumple: Buffer.readChannel(s,
				"./audio/plastic-bag-crumple.wav".resolveRelative, channels:[0])
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
/* Does it need to do reverse envelope every time at q = 54?
Is there more needed at q = 54
Maybe one more?
How to make less locked
q = 44 perhaps extend Ab
Purcell - Dido and Aeneas - Trevor Pinnock?
cantabile at end with mute? Try
Cues at q = 44
I'll follow you
Spend more time on the Eb at 43 and on F
plit up m. 15 at cues?
extend at m. 26 - keep going into the sky?
extend at m. 36 descent
Maybe rework 27 to have less low end
Maybe remove last G before harmonic at 51 - I think no, keep in
Map out proportions
*/
x = Synth(\playSample, [\bufnum, ~samples.score[0], \amp, 2])
x = Synth(\playSample, [\bufnum, ~samples.score[1], \amp, 2])
x = Synth(\playSample, [\bufnum, ~samples.score[2], \amp, 2])
x = Synth(\playSample, [\bufnum, ~samples.score[3], \amp, 2])