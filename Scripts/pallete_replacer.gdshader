shader_type canvas_item;

uniform bool active;
uniform vec3[11] pallete;
const vec3[11] replacing = {
	vec3(0, 0, 0),
	vec3(0.102, 0.102, 0.102),
	vec3(0.2, 0.2, 0.2),
	vec3(0.302, 0.302, 0.302),
	vec3(0.4, 0.4, 0.4),
	vec3(0.502, 0.502, 0.502),
	vec3(0.6, 0.6, 0.6),
	vec3(0.702, 0.702, 0.702),
	vec3(0.8, 0.8, 0.8),
	vec3(0.902, 0.902, 0.902),
	vec3(1, 1, 1)
};

void fragment() {
	if(active){
		for(int i = 0; i<11; i++){
			if(COLOR.rgb == replacing[i]){
				COLOR.rgb = pallete[i];
			}
		}
	}
}
