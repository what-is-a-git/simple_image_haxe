attribute vec4 aData;
varying vec2 vTexCoord;

uniform mat4 uProjection;
uniform mat4 uMatrix;

void main(void) {
	vTexCoord = aData.zw;
	gl_Position = uMatrix * uProjection * vec4(aData.xy, 0.0, 1.0);
}