shader_type spatial;

render_mode depth_prepass_alpha,cull_disabled,shadows_disabled;
uniform float amount: hint_range(0.0, 1.0) = 0.01;
uniform float period: hint_range(0.0, 1.0) = 0.04;
uniform float duration: hint_range(0.0, 1.0) = 0.1;

uniform sampler2D albedo_texture : source_color, filter_nearest;

float rand(float seed) {
    return fract(sin(seed) * 43758.5453);
}

void vertex() {
    float time_in_period = mod(TIME, period);
    bool is_jitter = time_in_period < duration;
    if (is_jitter) {
        float seed = floor(TIME / period);
        vec3 offset = amount * (vec3(
            rand(seed),
            rand(seed + 1.0),
            rand(seed + 2.0)
        ) - 0.5);
        VERTEX += offset;
    }
}
void fragment() {
    ALBEDO = texture(albedo_texture, UV).rgb;
}
