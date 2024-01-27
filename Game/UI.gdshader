shader_type canvas_item;

uniform vec2 light_position : hint_range(-1, 1) = vec2(0.5, 0.5); // Light position in UV coordinates

void vertex() {
    // Transform vertex position to screen coordinates
    vec2 screen_pos = vec2(SCREEN_MATRIX * vec4(VERTEX, 0.0, 1.0));
    
    // Calculate the distance from the light position to the vertex in screen coordinates
    vec2 light_dist = abs(light_position - screen_pos);
    
    // Map the distance to a value between 0 and 1
    float shadow_strength = 1.0 - min(1.0, length(light_dist) * 2.0);
    
    // Apply the shadow strength to the vertex position
    VERTEX += normalize(light_dist) * shadow_strength * 10.0;
}

void fragment() {
    // Output a simple color, you can modify this to use textures or more complex shading
    COLOR = vec4(1.0, 1.0, 1.0, 1.0);
}
