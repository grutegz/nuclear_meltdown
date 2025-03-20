shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 color = vec4(1.0, 0.5, 0.2, 1.0);
uniform float intensity : hint_range(0.0, 2.0);
uniform float speed : hint_range(0.1, 10.0);
uniform float alpha : hint_range(0.0, 1.0);

float rand(vec3 co) {
    return fract(sin(dot(co,vec3(12.9898, 78.233, 45.164)))*43758.5453);
}
void vertex() {
    float dynamic_seed = floor(TIME * speed);
    float noise_x = rand(VERTEX + vec3(dynamic_seed)) * 2.0 - 1.0;
    float noise_y = rand(VERTEX.yzx + vec3(dynamic_seed)) * 2.0 - 1.0;
    float noise_z = rand(VERTEX.zxy + vec3(dynamic_seed)) * 2.0 - 1.0;
    vec3 noise_offset = vec3(noise_x, noise_y, noise_z) * intensity;
    VERTEX += noise_offset;
}
void fragment() {
    vec4 final_color = color;
    final_color.a *= alpha;
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
}