shader_type canvas_item;
uniform int color_count = 4;
uniform float posterization_levels = 4.0;

uniform vec4 color1 : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Красный
uniform vec4 color2 : source_color = vec4(0.0, 1.0, 0.0, 1.0); // Зеленый
uniform vec4 color3 : source_color = vec4(0.0, 0.0, 1.0, 1.0); // Синий
uniform vec4 color4 : source_color = vec4(1.0, 1.0, 0.0, 1.0); // Желтый

// Настройки смешивания
uniform float blend_amount = 0.5; // Сила смешивания цветов
uniform float edge_smoothness = 0.1; // Сглаживание переходов
float color_distance(vec3 c1, vec3 c2) {
    vec3 diff = c1 - c2;
    return dot(diff, diff);
}

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    vec3 rgb = original_color.rgb;
    vec3 posterized = floor(rgb * posterization_levels + 0.5) / posterization_levels;
    
    vec3 palette[4];
    palette[0] = color1.rgb;
    palette[1] = color2.rgb;
    palette[2] = color3.rgb;
    palette[3] = color4.rgb;
    
    float min_dist1 = 1e10;
    float min_dist2 = 1e10;
    int idx1 = 0;
    int idx2 = 1;
    
    for (int i = 0; i < color_count; i++) {
        float dist = color_distance(posterized, palette[i]);
        if (dist < min_dist1) {
            min_dist2 = min_dist1;
            idx2 = idx1;
            min_dist1 = dist;
            idx1 = i;
        } else if (dist < min_dist2) {
            min_dist2 = dist;
            idx2 = i;
        }
    }
    float total = min_dist1 + min_dist2;
    float ratio = (total > 0.0) ? (min_dist2 / total) : 0.5;
    ratio = smoothstep(0.5 - edge_smoothness, 0.5 + edge_smoothness, ratio);
    vec3 result_color = mix(palette[idx1], palette[idx2], ratio * blend_amount);
    COLOR = vec4(result_color, original_color.a);
}