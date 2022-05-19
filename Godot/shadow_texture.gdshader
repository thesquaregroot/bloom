shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float averageValue = (color.r + color.g + color.b) / 3.0;
	if (color.a > 0.5 && averageValue < 0.1) {
		color.rgba = vec4(0.0, 0.0, 0.0, 1.0);
	}
	else {
		color.rgb = vec3(0.1);
		color.a = max(0.0, color.a / 5.0);
	}
	COLOR = color;
}