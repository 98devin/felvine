
# Felvine

Felvine is a **F**unctional, **E**mbedded **L**anguage for SPIR**V** (specifically, Vulkan) shaders.

TL;DR Replaces preprocessing hacks, reflection, and complicated language features with a powerful and customizable metalanguage.

### Functional

Felvine shaders are defined in an EDSL within Fennel, a Lisp-like language which compiles to Lua.
This means the metalanguage offers conveniences like tail calls, first class functions, and hygienic macros,
all of which are guaranteed to be erased in the compiled shader module. Because of Lua,
operator overloading, prototype-based OO, and other techniques are also possible.

### Embedded

Not only are Felvine shaders embedded within Fennel, but Felvine as a whole can be embedded within any
host which can interact with Lua. This allows runtime compilation of shaders and trivially passing
complex parameters into the shader scripts where specialization constants might be inconvenient.
Reflection of the entire compilation environment and arbitrary return values from shader compilation are also possible, without
necessarily needing to introspect the SPIRV output to get bindings etc. 

### SPIRV

Felvine offers full access to SPIRV if needed, and generates bindings from the SPIRV grammar directly to support future extensions.
However, deep knowledge of SPIRV is not required either, and only some concepts (Capabilities, Storage Class, Execution Modes, and Decorations) are used directly. Extensions and Capabilities can be conditionally enabled with arbitrary compile time predicates, and Felvine can validate their usage
against any user defined set of allowed Vulkan features and extensions, replacing the need for complicated IFDEFs in other shader languages.
The user should still consult Vulkan documentation for more complex validity requirements as Felvine cannot check all use cases (nor can HLSL or GLSL et al.)

Felvine scripts run in a single pass, meaning that the SPIRV generated is very predictable and straightforward. In many cases it is simpler
and performs fewer redundant operations than unoptimized results from glslang. Of course, spirv-opt can still be used for speed and to strip debug information.


## Features Index

### Types

Felvine offers manual constructor syntax for types for convenient metaprogramming, but also has built in names to reference the most common ones.
For compound types like structs, it also includes syntax sugar which is usable in variable, uniform, and function declarations. In many cases you may just
want to create a named pointer or struct type, in which case the `(type* Name <defn>)` syntax will declare it and provide it as a variable `Name`. The convenient syntax used for these cases is also shown below in the table, and works recursively for struct members etc.

Types are first class values in Felvine, so should you prefer, you can create aliases of types to match your favorite naming convention instead.
Generic or parametrized types can be represented by a function that returns a type, and will be deduplicated in the final SPIRV.

To test whether a metavalue represents a type, you can use the `type?` function, e.g. `(assert (type? i32) "Integers are a type!")`.

| Kind of type | Constructor | Syntax Sugar | Predefined name(s) | GLSL Type(s) |
| - | - | - | - | - |
| Void | `(Type.void)` | N/A | `void` | `void` |
| Booleans | `(Type.bool)` | N/A | `bool` | `bool` |
| Integers | `(Type.int bits signed?)` | N/A | `i8` `i16` `i32` `i64` `u8` `u16` `u32` `u64` | `int` `uint` `int8_t` `uint64_t` etc. |
| Floats | `(Type.float bits)` | N/A |  `f16` `f32` `f64` | `float16_t` `float` `double` |
| Arrays | `(Type.array element count?)` | `[count... elem]` e.g. `[3 f32]` `[u8]` `[4 4 f64]` | N/A | `float[3]` `uint8_t[]` `double[4][4]` etc. |
| Vectors | `(Type.vector element count)` | N/A | `(vec2 f32)` `(vec3 int32)` `(vec4 f16)` etc. | `vec2` `ivec3` `f16vec4` etc. |
| Matrices | `(Type.matrix element rows cols)` | N/A | `(mat4 f32)` `(mat2x3 f32)` `(mat3 f64)` etc. | `mat4` `mat2x3` `dmat3` etc. |
| Pointers | `(Type.pointer element storageClass)` | `[*Storage elem]` where some abbreviations are supported, e.g. `[*Input (vec3 f32)]` or `[*P 3 f32]` for a physical buffer pointer to an array of 3 floats. | N/A | Mostly N/A, `layout(buffer_reference)` applies to some cases. |
| Structs | `(Type.struct field-types field-names)` | `{ name1 type1 name2 (type2 decorations...) ... }` | N/A | `struct` |
| Images | `(image ...opts elem?)` e.g. `(image :sampled :2D :Array i32)` or `(image :storage :Buffer :Rg32f)` | N/A | N/A | `iimage2DArray`, `layout(rg32f) textureBuffer` etc. |
| Sampled Images | `(Type.sampled image-type)` or  `(sampled-image ...opts elem?)` e.g. `(sampled-image :3D)` | N/A | N/A | `sampler2DArray` `sampler3D` etc. |
| Samplers | `(Type.sampler)` | N/A | `sampler` | `sampler` |
| Functions | `(Type.function return-type [param-types...])` | N/A | N/A | N/A |
| Acceleration Structures | `(Type.acceleration-structure)` | N/A | `acceleration-structure` | `accelerationStructureEXT` |
| Ray Queries | `(Type.ray-query)` | N/A | `ray-query` | `rayQueryEXT` |


### Type constructors

Felvine types can be used as a function to cast or construct values. The arguments required to initialize depends on the type, of course.
If the values passed are all metavalues, the result will be a constant in SPIRV and will be somewhat constant propagated.

When a variable initializer or store argument, function argument, or function return is evaluated, it is cast to the expected type
using this procedure. Some operations that require values to be integers or floats will also cast the input automatically.

| Kind of type | Example cast/construction |
| - | - |
| Booleans | `(bool true)` `(bool false)` |
| Numbers | `(u32 1)` `(f32 3)` `(i32 x)` |
| Arrays | Either a single list, or vararg list e.g. `((array i32 3) [1 2 3])` `((array i32) 1 2 3 4 5)` Using a runtime-length array type will infer the length based on the arguments provided. |
| Vectors | A number of vector or scalar arguments which provide enough components. `((vec2 f32) 1.0 2.0)` `((vec4 f32) v.xyz 1.0)` Or, a list of scalars i.e. `((vec3 i32) [0 1 2])`. |
| Matrices | A list of vectors or vector initializers, e.g. `((mat2 f32) [0 1] v.zw)` |
| Structs | An object with the correct fields, e.g. given the definition `(type* Pos { x f32 y 32 })`, one can write `(local position (Pos { :x 10 :y 10 }))`

Other types cannot be constructed from values and must be initialized by e.g. descriptor bindings.


### Functions and operators

| Operation | Felvine syntax | GLSL Syntax |
| - | - | - |
| Basic arithmetic operations | `(+ x y)` `(- x y)` `(* x y)` `(/ x y)` `(% x y)` `(^ x y)`. Note that addition/multiplication operators can take any number of arguments, e.g. `(+ x y z w ...)` | `x + y` `x - y` `x * y` `x / y` `x % y` `pow(x, y)` |
| Fused multiply-add | `(fma x y z)` `(*+ x y z)` | `fma(x, y, z)`
| Logical comparison operations | `(lt? x y)` `(gt? x y)` `(eq? x y)` `(lte? x y)` `(gte? x y)` `(neq? x y)`. Note that these work on both scalars and vectors. | `x < y` `x > y` `x == y` `x <= y` `x >= y` `x != y` |
| Minimum/Maximum | `(min x y)` `(max x y)` `(min x y z w ...)` | `min(x, y)` `max(x, y)` `min(x, min(y, min(z, w)))` |
| Minimum/Maximum ignoring NaN | `(nmin x y)` `(nmax x y)` `(nmin x y z w ...)` | ? |
| Derivative operations | `(d/dx v)` `(d/dy v)` `(fwidth v)` | `dFdx(v)` `dFdy(v)` `fwidth(v)` |
| Lerp/Mix functions | `(mix x0 x1 t)` `(step edge t)` `(smoothstep e0 e1 t)` | `mix(x0, x1, t)` `step(edge, t)` `smoothstep(e0, e1, t)` |
| Rounding/adjusting functions | `(round v)` `(round-even v)` `(ceil v)` `(floor v)` `(trunc v)` `(fract v)` | `round(v)` `roundEven(v)` `ceil(v)` `floor(v)` `trunc(v)` `fract(v)` |
| Absolute value/Sign | `(abs x)` `(sign x)` | `abs(x)` `sign(x)` |
| Unit conversions | `(degrees-to-radians deg)` `(radians-to-degrees rad)` | `radians(deg)` `degrees(rad)` |
| Trigonometry | `(sin theta)` `(cos theta)` `(tan theta)` `(arcsin theta)` `(arccos theta)` `(arctan theta)` `(sinh theta)` `(cosh theta)` `(tanh theta)` `(arcsinh theta)` `(arccosh theta)` `(arctanh theta)` | `sin(theta)` `cos(theta)` `tan(theta)` `asin(theta)` `acos(theta)` `atan(theta)` `sinh(theta)` `cosh(theta)` `tanh(theta)` `asinh(theta)` `acosh(theta)` `atanh(theta)` |
| Other floating operations | `(exp x)` `(exp2 x)` `(log x)` `(ln x)` `(log2 x)` `(sqrt x)` `(inverse-sqrt x)` | `exp(x)` `exp2(x)` `log(x)` `log(x)` `log2(x)` `sqrt(x)` `inversesqrt(x)` |
| Vector and Matrix operations | `(dot v1 v2)` `(normalize v)` `(det m)` `(determinant m)` `(invert m)` `(transpose m)` | `dot(v1, v2)` `normalize(v)` `determinant(m)` `determinant(m)` `inverse(m)` `transpose(m)` |

## Motivation

Before reading, you may want to reference the [Fennel] and [Lua] languages (which are fundamentally simple), and you should be familiar
with the basics of Vulkan shaders. This section will not serve as an exhaustive index of possible techniques, but should help explain why Felvine's approach
is useful and powerful. 

It helps to have some mental model of the way that Felvine scripts execute that allows them to generate code. Felvine is an example of
_staged metaprogramming_ in which the "metaprogram" (in this case written in Fennel) has the job of generating code in the next "stage" of runtime
(in this case, SPIRV to run on the GPU). However, although Felvine includes a library for serializing SPIRV which could do this job directly, it is more complicated to use and would be flexible only at the expense of ergonomics if this was the end of the story. 

Felvine instead provides syntax which allows you to write natural code, and automatically generate appropriate SPIRV. This syntax forms a
domain specific language in which shader concepts can be naturally expressed and manipulated in a first class way. But how? We have an interpreter for code (Fennel), but it produces values in the metalanguage (i.e. `(+ 1 2)` becomes `3`, not SPIRV code performing an addition). The trick is to take advantage of the fact that our metalanguage is dynamically typed, meaning that functions like `+` are, from a point of view, polymorphic. We can _overload_
the addition operation to work on two different "kinds" of values, then:
- regular lua numbers (implementation provided by lua)
- staged SPIRV values (representing SPIRV Code which will eventually _produce_ a number which is not yet known)

Lua provides many extension points in the form of what it calls "metamethods" which allow a very broad class of operations to be made _stage-polymorphic_,
meaning they will work on regular values and SPIRV Code values. Therefore we can write a function `(fn [x y] (+ x y))` and it will automagically work either
at compile time (when evaluating the Felvine script) or at shader runtime, depending on the arguments given. This stage polymorphism also equates to a very strong form of _[partial evaluation][PE]_, such that meta-control flow and constant values are folded away almost entirely. This means that it is very simple to write zero-cost abstractions. In many cases though it is desirable to retain certain control flow in the generated SPIRV, and so Felvine provides counterparts to control flow operations which are reified in SPIRV.

```fnl
(var foo 3)               ; Typical Fennel syntax to declare a mutable variable with an initial value uses `var`.
(var* foo-code f32 := 3)  ; `var*` instead produces a SPIRV variable, and requires we provide its type as well as an optional initial assignment.

(fn double [x] (+ x x)) ; This function is written with no knowledge of SPIRV.

; It will evaluate to 6, when called with a metavalue.
; This effectively inlines and constant folds the function away.
(print (double foo)) ; => 6

; It will produce a representation of SPIRV performing an OpFAdd when called with a staged value.
(print (double foo-code)) ; => (expr f32 OpFAdd)
```

Many examples are provided in the `examples/` folder to understand how this works. 

The upshot of all this in the end is: you write a script that looks like regular code for the most part.
Certain aspects of it are annotated to indicate that they produce specifically a SPIRV value, internally called a `Node`.
You can use values like this in math expressions and access their fields etc. in a natural way.

SPIRV `fn*` functions (including your shader entrypoint) are persisted in the final shader module, but
regular functions in Fennel operate like very powerful compile time macros, and Fennel _macros_ allow creating new and convenient syntax.

###


# References and Similar Work

- Lua (https://www.lua.org/)
- Fennel (https://fennel-lang.org/)
- Collapsing Towers of Interpreters (https://dl.acm.org/doi/pdf/10.1145/3158140)
- Staged Metaprogramming for Shader System Development (https://dl.acm.org/doi/pdf/10.1145/3355089.3356554)

[Lua]: https://www.lua.org/
[CTI]: https://dl.acm.org/doi/pdf/10.1145/3158140
[Fennel]: https://fennel-lang.org/
[PE]: https://en.wikipedia.org/wiki/Partial_evaluation