#version 450

#define HEIGHT 400

uniform sampler2D tex;
in vec2 texCoord;
in vec4 color;
out vec4 FragColor;

void main() {
	float tile = 1;
	float y = texCoord.y / HEIGHT;
	vec4 noise = texture(tex, texCoord/5) * color;

	vec4 landNoise = texture(tex, vec2(texCoord.x/5,0));

	if (noise.r < .3) {
		tile = 2;
	}
	if (noise.r > .7) {
		tile = 3;
	}
	if (noise.g < .3) {
		tile = 4;
	}
	if (noise.b < .2) {
		tile = 0;
	}

	// float landy = 10./HEIGHT + landNoise.r*30./HEIGHT;
	// float dirty = landy + (landNoise.g*10.)/HEIGHT;
	// if (y < landy + 20./HEIGHT) {
	// 	tile = 7;
	// }
	// if (y < dirty + 6./HEIGHT) {
	// 	tile = 6;
	// }
	// if (y < landy) {
	// 	tile = 0;
	// }
	
	FragColor = vec4(tile/255,0,0,1);
}