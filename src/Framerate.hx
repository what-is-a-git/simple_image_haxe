package;

import Sys;

class Framerate {
	public var framerate:Int = 0;
	private var frames:Int = 0;

	public var time:Float = 0.0;
	private var lastTime:Float = 0.0;

	public function new() {
		time = Sys.time();
		lastTime = Sys.time();
	}

	public function report() {
		time = Sys.time();
		frames++;

		if (time - lastTime >= 1.0) {
			framerate = frames;
			Sys.println(framerate + ' FPS');
			frames = 0;
			lastTime = time;
		}
	}
}