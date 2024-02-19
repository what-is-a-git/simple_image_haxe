package;

import lime.utils.Float32Array;
import lime.utils.UInt32Array;
import lime.math.Matrix4;
import lime.math.Vector4;
import lime.graphics.RenderContext;
import lime.graphics.WebGLRenderContext;
import lime.ui.Window;
import lime.graphics.opengl.GLBuffer;
import lime.app.Application;

class Renderer {
	public static var gl:WebGLRenderContext;

	private var baseMatrix:Matrix4;
	private var rotationAxis:Vector4;
	private var imageShader:Shader;
	private var arrayBuffer:GLBuffer;
	private var elementBuffer:GLBuffer;
	private var vertexAttrib:Int;

	public var clearColor(default, set):Color = { r: 0, g: 0, b: 0, a: 1 };

	private function set_clearColor(color:Color):Color {
		gl.clearColor(color.r, color.g, color.b, color.a);
		return clearColor = color;
	}

	public var renderQueue:Array<DrawCall> = [];
	private var lastTexture:Texture;
	private var lastWidth:Float = 0.0;
	private var lastHeight:Float = 0.0;

	public function new() {
		baseMatrix = new Matrix4();
		rotationAxis = new Vector4(0.0, 0.0, 1.0);
	}

	public function onWindowCreated(window:Window):Void {
		gl = window.context.webgl;
		imageShader = Shader.fromFile("assets/image");
		imageShader.setUniformInt("uImage0", 0);

		initGL();

		baseMatrix.createOrtho(0, window.width, window.height, 0, -1, 1);
	}

	public function initGL():Void {
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
		gl.enable(gl.BLEND);

		var data = [
		   0.5,  0.5, 1.0, 1.0,  // top right
		   0.5, -0.5, 1.0, 0.0,  // bottom right
		  -0.5, -0.5, 0.0, 0.0,  // bottom left
		  -0.5,  0.5, 0.0, 1.0,  // top left 
		];
		arrayBuffer = gl.createBuffer();

		gl.bindBuffer(gl.ARRAY_BUFFER, arrayBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data), gl.STATIC_DRAW);

		var indices = [
			0, 1, 3,
			1, 2, 3,
		];
		elementBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, elementBuffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new UInt32Array(indices), gl.STATIC_DRAW);

		vertexAttrib = imageShader.getAttribLocation("aData");
		gl.vertexAttribPointer(vertexAttrib, 4, gl.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 0);
		gl.enableVertexAttribArray(vertexAttrib);
	}

	public function onWindowResize(width:Int, height:Int):Void {
		gl.viewport(0, 0, width, height);
	}

	public function clear():Void {
		gl.clear(gl.COLOR_BUFFER_BIT);
	}

	public function render():Void {
		clear();

		if (renderQueue.length > 0) {
			// Sys.println("Render Queue started");

			imageShader.use();
			imageShader.setUniformMatrix4("uMatrix", baseMatrix);

			gl.activeTexture(gl.TEXTURE0);
			gl.enable(gl.TEXTURE_2D);

			for (call in renderQueue) {
				if (!processCall(call)) {
					Sys.println("Error processing draw call");
				}
			}

			// Sys.println("Render Queue finished");

			renderQueue = [];
		}

		lastTexture = null;
	}

	public function processCall(call:DrawCall):Bool {
		var width:Float = call.transform.z;
		var height:Float = call.transform.w;

		if (call.texture != null) {
			if (lastTexture != call.texture) {
				call.texture.bind();
			}

			if (call.transform.z == 0 && call.transform.w == 0) {
				width = call.texture.width;
				height = call.texture.height;

				lastWidth = width;
				lastHeight = height;
			}

			lastTexture = call.texture;
		} else {
			lastTexture = null;
		}

		var matrix:Matrix4 = new Matrix4();
		matrix.appendTranslation(call.transform.x, call.transform.y, call.z);
		matrix[0] *= width;
		matrix[5] *= height;

		if (call.rotation != 0) {
			matrix.appendRotation(call.rotation, rotationAxis);
		}

		matrix.appendTranslation(width * 0.5, height * 0.5, 1.0);

		imageShader.setUniformMatrix4("uProjection", matrix);

		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, elementBuffer);
		gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, 0);

		return true;
	}

	public function queue(call:DrawCall):Void {
		renderQueue.push(call);
	}
}

typedef DrawCall = {
	var transform:Vector4;
	var z:Float;
	var rotation:Float;
	var ?texture:Texture;
}

typedef Color = {
	var r:Float;
	var g:Float;
	var b:Float;
	var a:Float;
}