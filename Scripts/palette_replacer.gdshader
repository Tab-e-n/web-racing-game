shader_type canvas_item;

uniform bool active;
uniform vec3[11] palette;
uniform vec3 dim = vec3(1, 1, 1);
const float[11] replace = {
	0.0,
	0.10196078431373,
	0.2,
	0.30196078431373,
	0.4,
	0.50196078431373,
	0.6,
	0.70196078431373,
	0.8,
	0.90196078431373,
	1.0
};

void fragment() {
	if(active){
		for(int i = 0; i<11; i++){
			if(COLOR.rgb == vec3(replace[i], replace[i], replace[i])){
				COLOR.rgb = palette[i] * dim;
				break;
			}
		}
	}
}
