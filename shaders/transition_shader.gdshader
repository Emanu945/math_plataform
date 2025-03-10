shader_type canvas_item;

uniform float lines = 10.0;  // Número de listras horizontais
uniform float threshold : hint_range(0.0, 1.0) = 0.0;  // Limiar para controle de largura das listras
uniform vec4 line_color_a : source_color = vec4(1.0);  // Cor da listra superior (padrão: branco)
uniform vec4 line_color_b : source_color = vec4(0.0, 0.0, 0.0, 0.0);  // Cor da listra inferior (padrão: transparente)

void fragment() {
    vec2 stripe_uv = vec2(UV.x, fract(UV.y * lines / 2.0));  // Divide a textura em listras
    if (stripe_uv.y < 0.5) {  // Metade superior das listras
        if (stripe_uv.x < threshold) {
            COLOR = line_color_a;  // Aplica a cor A se dentro do limiar
        } else {
            COLOR = vec4(0.0);  // Transparente fora do limiar
        }
    } else {  // Metade inferior das listras
        if (stripe_uv.x > 1.0 - threshold) {
            COLOR = line_color_b;  // Aplica a cor B se dentro do limiar
        } else {
            COLOR = vec4(0.0);  // Transparente fora do limiar
        }
    }
}