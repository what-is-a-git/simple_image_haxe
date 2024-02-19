package;

import lime.math.Matrix4;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;
import haxe.ds.StringMap;
import sys.FileSystem;
import sys.io.File;

class Shader {
	private var program:GLProgram;
	private var locationCache:StringMap<GLUniformLocation>;

	public function new(fragmentSource:String, vertexSource:String) {
		locationCache = new StringMap<GLUniformLocation>();
		program = GLProgram.fromSources(Renderer.gl, vertexSource, fragmentSource);
	}

	public static function fromFile(path:String):Shader {
		if (!(FileSystem.exists(path + '.frag') && FileSystem.exists(path + '.vert'))) {
			return null;
		}

		return new Shader(File.getContent(path + '.frag'), File.getContent(path + '.vert'));
	}

	public function getAttribLocation(attrib:String):Int {
		return Renderer.gl.getAttribLocation(program, attrib);
	}

	public function setUniformInt(uniform:String, value:Int):Void {
		if (!locationCache.exists(uniform)) {
			locationCache.set(uniform, Renderer.gl.getUniformLocation(program, uniform));
		}

		Renderer.gl.uniform1i(locationCache.get(uniform), value);
	}

	public function setUniformMatrix4(uniform:String, value:Matrix4):Void {
		if (!locationCache.exists(uniform)) {
			locationCache.set(uniform, Renderer.gl.getUniformLocation(program, uniform));
		}

		Renderer.gl.uniformMatrix4fv(locationCache.get(uniform), false, value);
	}

	public function use():Void {
		Renderer.gl.useProgram(program);
	}
}