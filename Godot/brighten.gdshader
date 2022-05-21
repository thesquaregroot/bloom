shader_type canvas_item;

uniform bool isActive = false;
uniform vec4 activeColor : hint_color = vec4(1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float averageValue = (color.r + color.g + color.b) / 3.0;
	if (isActive && color.a > 0.0 && averageValue > 0.1) {
		color.rgb = mix(color.rgb, activeColor.rgb, 0.5);
	}
	COLOR = color;
}