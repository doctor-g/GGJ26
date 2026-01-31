shader_type canvas_item;

uniform vec4 color1 : source_color;
uniform vec4 color2  : source_color;
uniform vec2 center = vec2(0.5);
uniform float beam_count = 12.0;
uniform float beam_sharpness = 5.0;  // Higher = thinner beams
uniform float rotation_speed = 0.01;

void fragment() {
	vec2 uv = UV - center;
	float angle = atan(uv.y, uv.x) + TIME * rotation_speed;
	
	// Create repeating beams using sine
    float beams = abs(sin(angle * beam_count));

    // Sharpen beams
    beams = pow(beams, beam_sharpness);

    // Final color: white beams on black
    COLOR = mix(
		color1,
		color2, 
		clamp(beams, 0, 1.0)
	);
}
