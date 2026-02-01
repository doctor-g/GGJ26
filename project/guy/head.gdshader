shader_type canvas_item;

uniform bool enabled = false;
uniform vec4 origin:source_color = vec4(0.0,0.0,0.0,1.0);
uniform vec4 replacement:source_color = vec4(1.0,0.0,0.0,1.0);

void fragment() {
	if (enabled) {
		vec4 current_pixel = texture(TEXTURE, UV);
		
		if (current_pixel == origin)
			COLOR = mix(origin, replacement, abs(sin(TIME * 10.0)));
		else
			COLOR = current_pixel;
	}
}