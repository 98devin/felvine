;
; Based on the PBRNeutralToneMapping function (pbrNeutral.glsl) defined by KhronosGroup
; https://github.com/KhronosGroup/ToneMapping/blob/main/PBR_Neutral/pbrNeutral.glsl
;

(require-macros :dsl.v1)
(capability Shader)


(var* inColor (vec3 f32) Input (Location 0))
(var* outColor (vec4 f32) Output (Location 0))


(fn* pbr-neutral-tonemapping (vec3 f32) [(color (vec3 f32))]
  (local start-compression (- 0.8 0.04))
  (local desaturation 0.15)
  
  (local x (min color.r color.g color.b))
  (local offset
    (select (lt? x 0.08) (* x x (- x 6.25)) 0.04))
  
  (local color (- color offset))
  (local peak (max color.r color.g color.b))
  
  (if* (lt? peak start-compression) color
    (do
      (local d (- 1 start-compression))
      (local new-peak
        (/ (- 1 (* d d)) (- (+ peak d) start-compression)))
      (local color (* color (/ new-peak peak)))

      (local g (- 1 (/ 1 (+ 1 (* desaturation (- peak new-peak))))))
      (mix color new-peak g)
    )))


(entrypoint main Fragment [OriginUpperLeft]
  (set* outColor
    ((vec4 f32)
      (pbr-neutral-tonemapping inColor)
      1.0)))