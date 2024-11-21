shader_type canvas_item;

uniform bool enable_damage = false; // Activador de efecto plateado
uniform vec4 silver_color = vec4(0.8, 0.0, 0.0, 1.0); // Color plateado

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (enable_damage) {
        float avg = (tex_color.r + tex_color.g + tex_color.b) / 3.0; // Escala de grises
        vec4 tinted_silver = vec4(silver_color.rgb * avg, silver_color.a); // Plateado aplicado con intensidad
        COLOR = tinted_silver * tex_color.a; // Mezcla según alfa
    } else {
        COLOR = mix(tex_color, vec4(0.1, 0.1, 0.2, 1.0), 2) * tex_color.a;
    }
}