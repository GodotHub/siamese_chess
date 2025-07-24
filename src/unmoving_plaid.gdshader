shader_type spatial;

uniform sampler2D texture_albedo;
uniform float scale = 1.0;
// Hue is in normalized value [0.0, 1.0] where 0.0 means no change.
// For example, 0.1 shifts hue by 36° (0.1 * 360°).
uniform float hue_shift       : hint_range(-1.0, 1.0) = 0.0;
// Saturation multiplier. 1.0 means no change.
uniform float saturation_mult : hint_range(0.0, 2.0) = 1.0;
// Value (brightness in HSV) multiplier. 1.0 means no change.
uniform float value_mult      : hint_range(0.0, 2.0) = 1.0;
// Brightness addition in RGB space. 0.0 means no change.
uniform float brightness_add  : hint_range(-1.0, 1.0) = 0.0;
// Contrast multiplier in RGB space. 1.0 means no change.
uniform float contrast_mult   : hint_range(0.0, 2.0) = 1.0;

// Converts an RGB color to HSV.
vec3 rgb2hsv(vec3 c) {
    float cMax = max(max(c.r, c.g), c.b);
    float cMin = min(min(c.r, c.g), c.b);
    float delta = cMax - cMin;
    
    float h = 0.0;
    if(delta < 0.00001) {
        h = 0.0;
    } else if(cMax == c.r) {
        h = mod(((c.g - c.b) / delta), 6.0);
    } else if(cMax == c.g) {
        h = ((c.b - c.r) / delta) + 2.0;
    } else {
        h = ((c.r - c.g) / delta) + 4.0;
    }
    h /= 6.0;
    if(h < 0.0) h += 1.0;
    
    float s = (cMax <= 0.0) ? 0.0 : (delta / cMax);
    float v = cMax;
    return vec3(h, s, v);
}

// Converts an HSV color back to RGB.
vec3 hsv2rgb(vec3 c) {
    float h = c.x * 6.0;
    float s = c.y;
    float v = c.z;
    
    float c_val = v * s;
    float x = c_val * (1.0 - abs(mod(h, 2.0) - 1.0));
    vec3 rgb;
    
    if (0.0 <= h && h < 1.0) {
        rgb = vec3(c_val, x, 0.0);
    } else if (1.0 <= h && h < 2.0) {
        rgb = vec3(x, c_val, 0.0);
    } else if (2.0 <= h && h < 3.0) {
        rgb = vec3(0.0, c_val, x);
    } else if (3.0 <= h && h < 4.0) {
        rgb = vec3(0.0, x, c_val);
    } else if (4.0 <= h && h < 5.0) {
        rgb = vec3(x, 0.0, c_val);
    } else if (5.0 <= h && h < 6.0) {
        rgb = vec3(c_val, 0.0, x);
    } else {
        rgb = vec3(0.0, 0.0, 0.0);
    }
    float m = v - c_val;
    return rgb + vec3(m);
}
void fragment() {
    vec2 screen_uv = SCREEN_UV * scale;
    vec4 tex = texture(texture_albedo, screen_uv);
    vec3 col = tex.rgb;
	    // Adjust brightness and contrast in RGB space.
    // The contrast formula shifts the color around mid-gray (0.5).
    col = (col - 0.5) * contrast_mult + 0.5 + brightness_add;
    
    // Convert to HSV to adjust hue, saturation, and value.
    vec3 hsv = rgb2hsv(col);
    
    // Apply hue shift and wrap the value [0,1].
    hsv.x = mod(hsv.x + hue_shift, 1.0);
    
    // Adjust saturation and value multipliers.
    hsv.y *= saturation_mult;
    hsv.z *= value_mult;
    
    // Convert back to RGB.
    col = hsv2rgb(hsv);
    ALBEDO = col;
}