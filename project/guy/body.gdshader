shader_type canvas_item;

uniform vec4 origin:source_color;
uniform vec4 replacement:source_color;

void fragment() {
	vec4 current_pixel = texture(TEXTURE, UV);
	
	if (current_pixel == origin)
		COLOR = replacement;
	else
		COLOR = current_pixel;
}