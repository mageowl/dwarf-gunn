shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture;
uniform int number_of_colors = 32;
uniform sampler2D palette;
uniform sampler2D dither_texture : repeat_enable, filter_linear;

const float palette_size = 32.;

float sqlen(vec3 vec) {
	return vec.x * vec.x + vec.y * vec.y + vec.z * vec.z;
}

vec3 color(int index) {
	float offset = 1.0 / (float(number_of_colors) * 2.0);
	vec2 uv = vec2(float(index) / float(number_of_colors) + offset, 0.5);
	return texture(palette, uv).rgb;
}

vec3 nearest_color(vec3 in_color) {
	int nearest_color = 0;
	float nearest_dist = 100.0;

	for (int i = 0; i < number_of_colors; i++) {
		vec3 i_color = color(i);
		float dist = length(in_color - i_color);
		if (dist < nearest_dist) {
			nearest_color = i;
			nearest_dist = dist;
		}
	}

	return color(nearest_color);
}

void fragment() {
	vec3 color = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;
	vec4 dither = texture(dither_texture, SCREEN_UV / (SCREEN_PIXEL_SIZE * 8.));
	color = mix(color, dither.rgb, dither.a * (1./32.));
	//color *= palette_size;
	//color = floor(color);
	//color.b += 1./palette_size;
	//color /= palette_size;
	//COLOR = texture(palette, vec2(color.r, color.g / palette_size + color.b));
	COLOR.rgb = nearest_color(color);
	//COLOR = dither;
}
