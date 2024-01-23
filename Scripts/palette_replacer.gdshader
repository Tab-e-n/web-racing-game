shader_type canvas_item;

uniform bool active;
uniform vec3[11] palette;
uniform vec3 dim = vec3(1, 1, 1);
global uniform sampler2D palette_replacing;

vec3 get_palette_color(float position) {
	return texture(palette_replacing, vec2(position, 0.5)).rgb;
}

void fragment() {
	if(active){
		for(int i = 0; i<11; i++){
			if(COLOR.rgb == get_palette_color(float(i)/11.0 + 1.0/22.0)){
				COLOR.rgb = palette[i] * dim;
				break;
			}
		}
	}
}