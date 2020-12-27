shader_type canvas_item;

uniform bool single_color = false;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 target_color = vec4(1.0, 1.0, 1.0, (previous_color.a));
	vec4 new_color = previous_color;
	if (single_color == true) { new_color = target_color; }
	COLOR = new_color;
}