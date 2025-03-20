shader_type spatial;

render_mode depth_prepass_alpha, cull_disabled, shadows_disabled;

uniform float amount: hint_range(0.0, 1.0) = 0.01;
uniform float period: hint_range(0.0, 1.0) = 0.04;
uniform float duration: hint_range(0.0, 1.0) = 0.1;
uniform float seed1: hint_range(0.0, 10.0) = 1.0;

uniform sampler2D albedo_texture : source_color, filter_nearest;

float rand(float seed) {
    return fract(sin(seed) * 43758.5453);
}

void vertex() {
    float time_in_period = mod(TIME, period);
    bool is_jitter = time_in_period < duration;
    if (is_jitter) {
        float base_seed = floor(TIME / period) + seed1 * 10.0;
        vec3 random_factors = vec3(
            rand(base_seed),
            rand(base_seed + 1.0),
            rand(base_seed + 2.0)
        );

        vec3 offset = amount * (random_factors - 0.5) * (rand(seed1) + 0.5);
        VERTEX += offset;
    }
}

void fragment() {
    ALBEDO = texture(albedo_texture, UV).rgb;
}