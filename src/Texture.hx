package;

import lime.graphics.Image;
import lime.graphics.opengl.GLTexture;

class Texture {
	public var width:Float;
	public var height:Float;

	private var image:Image;
	private var glTexture:GLTexture;

	public function new() {
		glTexture = Renderer.gl.createTexture();
	}

	public static function fromImage(image:Image):Texture {
		var gl = Renderer.gl;
		var texture:Texture = new Texture();
		texture.bind();

		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.buffer.width, image.buffer.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);

		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
		gl.bindTexture(gl.TEXTURE_2D, null);

		texture.width = image.width;
		texture.height = image.height;

		return texture;
	}

	public function bind():Void {
		Renderer.gl.bindTexture(Renderer.gl.TEXTURE_2D, glTexture);
	}
}