package;

import lime.app.Application;
import lime.math.Vector4;
import lime.ui.Window;
import lime.ui.WindowAttributes;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.Image;
import lime.graphics.RenderContext;
import lime.utils.Assets;

class Main extends Application {
	private var image:Image;
	private var texture:Texture;
	private var mario:Texture;

	private var fps:Framerate;
	private var imageCount:Int = 10;
	private var renderer:Renderer;

	public function new() {
		super();

		fps = new Framerate();
		renderer = new Renderer();
	}

	public override function createWindow(attributes:WindowAttributes):Window {
		super.createWindow(attributes);
		renderer.onWindowCreated(window);

		var context = window.context;
		renderer.clearColor = {
			r: ((context.attributes.background >> 16) & 0xFF) / 0xFF,
			g: ((context.attributes.background >> 8) & 0xFF) / 0xFF,
			b: (context.attributes.background & 0xFF) / 0xFF,
			a: ((context.attributes.background >> 24) & 0xFF) / 0xFF,
		};

		window.onKeyDown.add((code:KeyCode, modifier:KeyModifier) -> {
			if (code == KeyCode.LEFT) {
				imageCount = Math.floor(Math.max(0, imageCount - 5));
				Sys.println(imageCount);
			}

			if (code == KeyCode.RIGHT) {
				imageCount = Math.floor(Math.max(0, imageCount + 5));
				Sys.println(imageCount);
			}
		});

		return window;
	}

	public override function onPreloadComplete():Void {
		super.onPreloadComplete();
		image = Assets.getImage("assets/lime.png");
		texture = Texture.fromImage(image);
		mario = Texture.fromImage(Assets.getImage("assets/gameplay.png"));
	}

	public override function onWindowResize(width:Int, height:Int):Void {
		super.onWindowResize(width, height);
		renderer.onWindowResize(width, height);
	}

	public override function render(context:RenderContext):Void {
		if (!preloader.complete) {
			return;
		}

		switch (context.type) {
			case OPENGL, OPENGLES, WEBGL:
				renderer.queue({
					transform: new Vector4(0.0, 0.0, 0.0, 0.0),
					z: 0.0,
					rotation: 0.0,
					texture: texture,
				});

				for (i in 0...imageCount) {
					renderer.queue({
						transform: new Vector4(0.0, 0.0, mario.width * 0.25, mario.height * 0.25),
						z: 0.0,
						rotation: i + (Sys.time() * 90.0),
						texture: mario,
					});
				}

				renderer.render();
			default:
		}

		fps.report();

	}


}