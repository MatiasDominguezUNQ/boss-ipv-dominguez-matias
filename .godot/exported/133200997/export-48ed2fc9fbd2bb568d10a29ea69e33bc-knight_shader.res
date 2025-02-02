RSRC                    Shader            ��������                                                  resource_local_to_scene    resource_name    code    script        4   res://src/entities/player/knight/knight_shader.tres �          Shader          ^  shader_type canvas_item;

uniform bool enable_silver = false; // Activador de efecto plateado
uniform vec4 silver_color = vec4(0.8, 0.0, 0.0, 1.0); // Color plateado

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    if (enable_silver) {
        float avg = (tex_color.r + tex_color.g + tex_color.b) / 3.0; // Escala de grises
        vec4 tinted_silver = vec4(silver_color.rgb * avg, silver_color.a); // Plateado aplicado con intensidad
        COLOR = mix(tex_color, tinted_silver, tinted_silver.a) * tex_color.a; // Mezcla según alfa
    } else {
        COLOR = tex_color;
    }
}       RSRC