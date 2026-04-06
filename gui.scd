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
	cleanupFunction = ~score[~currentPatch].();
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
				var orderedSeq = ~score.keys.asArray.sort;
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