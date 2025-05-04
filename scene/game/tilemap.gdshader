shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

int check(vec2 uv, vec2 pixel, float offset_x, float offset_y) {
	if (texture(screen_texture, uv + vec2(offset_x, offset_y) * pixel).a > 0.0001) {
		return 1;
	} else {
		return 0;
	}
}

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);

	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}

	COLOR *= c;

	int neighbors =
		check(SCREEN_UV, SCREEN_PIXEL_SIZE, 1, 0)
		+ check(SCREEN_UV, SCREEN_PIXEL_SIZE, -1, 0)
		+ check(SCREEN_UV, SCREEN_PIXEL_SIZE, 0, 1)
		+ check(SCREEN_UV, SCREEN_PIXEL_SIZE, 0, -1)
		+ check(SCREEN_UV, SCREEN_PIXEL_SIZE, 1, 1)
		+ check(SCREEN_UV, SCREEN_PIXEL_SIZE, -1, 1)
		+ check(SCREEN_UV, SCREEN_PIXEL_SIZE, 1, -1)
		+ check(SCREEN_UV, SCREEN_PIXEL_SIZE, -1, -1);
	if (neighbors < 5) {
		COLOR.a = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
