
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

Examples are provided in the `examples/` folder to understand how this works. 

The upshot of all this in the end is: you can write a script that looks like regular code.
Certain aspects of it are annotated to indicate that they produce specifically a SPIRV value, internally called a `Node`.
You can use values like this in math expressions and access their fields etc. in a natural way because of polymorphism.
The script is executed during the equivalent of a "compile time" and collects information about the SPIRV calculations to be performed.

In this way, SPIRV `fn*` functions (including your shader entrypoint) are persisted in the final shader module, but
regular functions in Fennel are specialised away and operate like very powerful compile time metaprograms, and Fennel _macros_ allow creating new and convenient syntax.

## Features Index

### Types

Felvine offers manual constructor syntax for types for convenient metaprogramming, but also has built in names to reference the most common ones.
For compound types like structs, it also includes syntax sugar which is usable in variable, uniform, and function declarations. In many cases you may just
want to create a named pointer or struct type, in which case the `(type* Name <defn>)` syntax will declare it and provide it as a variable `Name`. The convenient syntax used for these cases is also shown below in the table, and works recursively for struct members etc.

Types are first class values in Felvine, so should you prefer, you can create aliases of types to match your favorite naming convention instead.
Generic or parametrized types can be represented by a function that returns a type, and will be deduplicated in the final SPIRV.

To test whether a metavalue represents a type, you can use the `type?` function, e.g. `(assert (type? i32))`.

| Kind of type | Constructor | Syntax Sugar | Predefined name(s) | GLSL Type(s) |
| - | - | - | - | - |
| Void | `(Type.void)` | N/A | `void` | `void` |
| Booleans | `(Type.bool)` | N/A | `bool` | `bool` |
| Integers | `(Type.int bits signed?)` | N/A | `i8` `i16` `i32` `i64` `u8` `u16` `u32` `u64` | `int` `uint` `int8_t` `uint64_t` etc. |
| Floats | `(Type.float bits)` | N/A |  `f16` `f32` `f64` | `float16_t` `float` `double` |
| Arrays | `(Type.array element count?)` | `[count... elem]` e.g. `[3 f32]` `[u8]` `[4 4 f64]` | N/A | `float[3]` `uint8_t[]` `double[4][4]` etc. |
| Vectors | `(Type.vector element count)` | N/A | `(vec2 f32)` `(vec3 i32)` `(vec4 f16)` etc. | `vec2` `ivec3` `f16vec4` etc. |
| Matrices | `(Type.matrix element rows cols)` | N/A | `(mat4 f32)` `(mat2x3 f32)` `(mat3 f64)` etc. | `mat4` `mat2x3` `dmat3` etc. |
| Pointers | `(Type.pointer element storageClass)` | `[*Storage elem]` where some abbreviations are supported, e.g. `[*Input (vec3 f32)]` or `[*P 3 f32]` for a physical buffer pointer to an array of 3 floats. | N/A | Mostly N/A, `layout(buffer_reference)` applies to some cases. |
| Structs | `(Type.struct field-types field-names)` | `{ name1 type1 name2 (type2 decorations...) ... }` | N/A | `struct` |
| Images | `(image ...opts elem?)` e.g. `(image :sampled :2D :Array i32)` or `(image :storage :Buffer :Rg32f)` | N/A | N/A | `iimage2DArray`, `layout(rg32f) textureBuffer` etc. |
| Sampled Images | `(Type.sampled image-type)` or  `(sampled-image ...opts elem?)` e.g. `(sampled-image :3D)` | N/A | N/A | `sampler2DArray` `sampler3D` etc. |
| Samplers | `(Type.sampler)` | N/A | `sampler` | `sampler` |
| Functions | `(Type.function return-type [param-types...])` | N/A | N/A | N/A |
| Acceleration Structures | `(Type.acceleration-structure)` | N/A | `acceleration-structure` | `accelerationStructureEXT` |
| Ray Queries | `(Type.ray-query)` | N/A | `ray-query` | `rayQueryEXT` |


### Types as constructors

Felvine types can be used as a function to cast or construct values. That is, they are used to convert a metavalue to a SPIRV value of a compatible type, or to construct composite types from multiple SPIRV values, etc. The arguments required to initialize depends on the type, of course. If the values passed are all metavalues, the result will be a constant in SPIRV and will be constant propagated through certain operations.

When a variable initializer or store argument, function argument, or function return is evaluated, it is cast to the expected type
using this same construction procedure. Some operations that require values to be integers or floats will also cast the input automatically for convenience.

| Kind of type | Example cast/construction |
| - | - |
| Booleans | `(bool true)` `(bool false)` |
| Numbers | `(u32 1)` `(f32 3)` `(i32 x)` |
| Arrays | Either a single list, or vararg list e.g. `((array i32 3) [1 2 3])` `((array i32) 1 2 3 4 5)` Using a runtime-length array type will infer the length based on the arguments provided. |
| Vectors | A number of vector or scalar arguments which provide enough components. `((vec2 f32) 1.0 2.0)` `((vec4 f32) v.xyz 1.0)` Or, a list of scalars i.e. `((vec3 i32) [0 1 2])`. |
| Matrices | Some number of column vectors or column vector initializers, e.g. `((mat2 f32) [0 1] v.zw)` |
| Structs | A table with the correct fields; given `(type* Pos { x f32 y 32 })`, one can write `(local position (Pos { :x 10 :y 10 }))`

Other types of values (images, functions, etc.) cannot be constructed like this and must be initialized by declarations or implicitly by descriptor bindings.


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
| Other floating operations | `(exp x)` `(exp2 x)` `(log x)` `(ln x)` `(log2 x)` `(sqrt x)` `(inverse-sqrt x)` `(ldexp l exp)` `(local (l exp) (frexp x))` | `exp(x)` `exp2(x)` `log(x)` `log(x)` `log2(x)` `sqrt(x)` `inversesqrt(x)` `ldexp(l, exp)` `l = frexp(x, exp)` |
| Vector and Matrix operations | `(dot v1 v2)` `(distance v1 v2)` `(norm v)` `(length v)` `(normalize v)` `(face-forward v i ref)` `(reflect v n)` `(refract v n eta)` `(det m)` `(determinant m)` `(invert m)` `(transpose m)` | `dot(v1, v2)` `distance(v1, v2)` `length(v)` `length(v)` `normalize(v)` `faceforward(v, i, ref)` `reflect(v, n)` `refract(v, n, eta)` `determinant(m)` `determinant(m)` `inverse(m)` `transpose(m)` |
| Floating pack/unpack operations | `(pack-unorm2x16 v)` `(pack-snorm2x16 v)` `(pack-half2x16 v)` `(pack-unorm4x8 v)` `(pack-snorm4x8 v)` `(pack-double2x32 v)` `(unpack-unorm2x16 i)` `(unpack-snorm2x16 i)` `(unpack-half2x16 i)` `(unpack-unorm4x8 i)` `(unpack-snorm4x8 i)` `(unpack-double2x32 d)` | `packUnorm2x16(v)` `packSnorm2x16(v)` `packHalf2x16(v)` `packUnorm4x8(v)` `packSnorm4x8(v)` `packDouble2x32(v)` `unpackUnorm2x16(i)` `unpackSnorm2x16(i)` `unpackHalf2x16(i)` `unpackUnorm4x8(i)` `unpackSnorm4x8(i)` `unpackDouble2x32(d)` | 


## Declarations and special syntax

The implementation of many of the following syntactic features is found in `dsl/v1.fnl`.
Therefore, to use them as shown, your Felvine script should begin with `(require-macros :dsl.v1)`.
These features are not privileged above anything that a user of Felvine could write themselves if desired, but are intended to still be relatively complete for common purposes.

### Capabilities and Extensions

SPIRV requires that the use of extension features be indicated by listing "capabilities" and "extensions" at the beginning of the module.

To declare capabilities, simply list their name in a statement of the form `(capability <name1> <name2> ...)`. The name may be a plain identifier or a string literal. For extensions, use `(extension <name1> <name2> ...)` as necessary; note that the name of extensions must be a string literal.

For example:

```fennel
(capability
  Shader
  SparseResidency
  SampledBuffer
  ImageBuffer
  Image1D
  ImageCubeArray
  ImageGatherExtended
  Sampled1D
  Int8
  Int16
  Int64
  Float64
  GroupNonUniformArithmetic
  GroupNonUniformClustered
  PhysicalStorageBufferAddresses)

(extension
  :SPV_EXT_descriptor_indexing)
```

A `capability` or `extension` statement can be placed anywhere, not only the top level, although all such statements apply globally to the entire module. All entrypoints in the module also share the set of declared capabilities.

When declaring a capability or extension, any other prerequisite extensions or capabilities
are implicitly also declared. For example, `Shader` implies `Matrix`.

To _conditionally_ check for the presence of a capability or extension, the `supported?`
function can be used. In this way the Felvine shader can compute at compile time a different implementation path or set of capabilities depending on the target environment it will be run in. For example:

```fennel
(when (supported? :SPV_EXT_mesh_shader) ; check for extension availability
  (capability :MeshShadingEXT)) ; declare feature use
```

NB: By default, Felvine does not know what the target environment support for features or extensions is, and will always return `true` for `supported?`. To configure this, the command line offers the ability to specify exactly the allowable set of
- SPIRV capabilities and/or extensions (`--spv-features`)
- Vulkan features and/or extensions (`--vk-features`), and 
- Vulkan target version (`--vk-version`)

When specifying these, Felvine can automatically infer support for SPIRV features from the relevant Vulkan extensions or features that are available. If you are running Felvine in your graphics program, these could straightforwardly correspond to the _actual_ available set of extensions in the environment.

### Variables

SPIRV Variables are declared in Felvine using the `var*` construct. It supports providing an initializer, specifying the storage class,
and listing any number of optional Decorations.

The simplest form of variable just requires a name and a type, and will default to a Function storage variable of undefined initial value:
`(var* foo i32)`

If we want to provide a different initial value, it can be listed after a `:=` sign in the declaration. The value given will automatically
be cast to the type of the variable being declared to ensure consistency: `(var* foo i32 := 10)`

Variables are also how we access inputs/outputs of shaders, and certain built-ins. In these cases the storage class default of Function
will be inappropriate, so a different class can be specified. Decorations (like `BuiltIn` and `Location`) provide the means of specifying the purpose and linkage of these variables in different cases:

```fennel
(var* vertexColor (vec4 f32) Input (Location 0))   ; first vertex attribute input
(var* fragColor   (vec4 f32) Output (Location 0))  ; first fragment attachment output
(var* vertexIndex u32 Input (BuiltIn VertexIndex)) ; built-in index variable
(var* sharedMemory {data [1024 f32]} Workgroup)  ; workgroup-shared memory
(var* cullPrimitive [N bool] Output (BuiltIn CullPrimitiveEXT) PerPrimitiveEXT) ; e.g. mesh shader culling use case
```

Only variables of the `Function` or `Private` class should have initializers. Furthermore, any storage class other than `Function` (i.e. including `Private`) is considered to be allocated at the global scope, and so must have a constant initializer if one is given. You do not need to declare such variables at the file scope in Felvine, but they will eventually be moved there in the final SPIRV.

The initializer, storage class, and decorations can come in any order relative to each other,
but only one initializer and one storage class can be provided at most.

### Uniforms and Push Constants

The other most common use for variables in SPIRV is to bind inputs from descriptor sets.
This can mostly be done manually with `var*` assuming the correct decorations are included, but this has some downsides and pitfalls
such as not automatically generating the appropriate type layout for buffer blocks, and requiring additional type definitions.

Therefore Felvine offers some very convenient alternatives. Declaring a uniform is as simple as:
```fennel
(uniform (<set> <binding>) <Name> <Type> <...Decorations...>) ; for images (including texel buffers) or uniform buffers
(buffer  (<set> <binding>) <Name> <Type> <...Decorations...>) ; for storage buffers
(push-constant <Name> <Type>) ; for push constants (Type must be a struct)
```

`Type` can be a struct to represent a buffer, or it can be an opaque type like an image or acceleration structure, or an array of one of these. For example:

```fennel
; type of material image indices
(type* Material { 
  albedo u32
  normal u32
  roughness u32
})

(buffer (0 0) MaterialData {
  materials [Material]
} NonWritable)

(uniform (0 1) MaterialTextures [1024 (sampled-image :2D)])

(buffer (0 2) GeometryData [128 {
  positions [(vec3 f32)]
}])

(push-constant CameraData { 
  position (vec3 f32)
  transform ((mat4x3 f32) RowMajor)
  inv-transform (mat3x4 f32)
  fov f32
})
```

After such a declaration, the values can simply be accessed by name, e.g. `CameraData.position` or `(GeometryData 63 :positions 15)`.
Syntax for indexing is described in more detail later.

Usages of all global variables, including those defined as uniforms or push constants, are automatically tracked and linked to each entry point that uses them in the final SPIRV. Keep in mind therefore that only one push constant may be statically used in this way per entrypoint. Also, like `var*`, although they are considered globals due to their storage class, uniforms do not need to be declared at the top level, so they can be generated and returned from a compile time function if needed.

### Decorations

Most of the time, Felvine offers convenient places to put SPIRV decorations on the relevant declarations. When, for whatever reason, it is necessary or preferable to apply decorations belatedly (e.g. for metaprogramming reasons) the `decorate` and `decorate-member` forms are provided.

Any SPIRV value or type can be passed to `(decorate <value/type> ...)` with any number of decorations given. The type or value will then be given those decorations in the SPIRV output. Consult the SPIRV documentation for guidelines on what decorations should apply to what types or values.

For struct types, the `decorate-member` form can also be used to place a decoration on a particular field. For example, if we have `(type* MatX { x (mat3 f32) })` we could decide we want the field x to be row major. We can achieve this with `(decorate-member MatX 0 RowMajor)`. Field indices are 0-based.

### Functions

SPIRV Functions are declared in a way that mirrors normal Fennel functions, but with the addition of type information. The function return type is given immediately after the name, and each input parameter name must be accompanied by a type for that parameter. Vararg functions are not supported.

The body of the function can be a sequence of statements/expressions. The last expression is returned as the result. The result value is cast to the return type of the function in the event that it does not already match.

```fennel
; rotate a vector `v` by a quaternion `q`
(fn* quat_mult (vec3 f32) [(q (vec4 f32)) (v (vec3 f32))]
    (var c (cross v q.xyz))
    (set c (cross (+ c (* q.w v)) q.xyz))
    (+ v (* 2.0 c)))
```

Function overloading (based on the parameter types) is not directly supported in Felvine but is not hard to write at user level.
A Fennel function can analyze the types of the passed parameters and dispatch to the appropriate procedure if this logic is desired.
Similarly, generic/templated functions are not included, but are easy to implement in principle with memoization and a wrapper function which will use `fn*` to declare a new SPIRV function only if it has not already been instantiated for the desired type(s).

Note that even if you do not _call_ the function created with `fn*`, it will still appear in the final SPIRV. This is useful
if you want to export or link the function definition between multiple SPIRV modules, but otherwise the definition can be stripped
by `spirv-opt` if necessary.

### Entrypoints

SPIRV allows multiple shaders to exist within one module. Felvine allows declaring multiple entrypoints as well, and with any name you choose. Entrypoints which exist in the same file can therefore share definitions of types, functions, and global variables (like descriptor bindings) when meaningful to do so. 

A shader entrypoint is effectively a zero-argument function which returns void, but they have additional properties as well. Most obviously, the entrypoint must declare what kind of shader it represents, e.g. Vertex, Fragment, TesselationEvaluation, ClosestHit, which is referred to as the "execution model". Complementary to this and depending on the execution model, we may be able to (or required to) specify a number of "execution modes" which inform the behavior of the shader in other ways. For example, in the Fragment execution model we must specify the origin in screen space as e.g. OriginUpperLeft.

Felvine provides the following syntax allowing to specify the execution model and execution modes and the body of the entrypoint function: `(entrypoint <name> <model> [<modes...>] <body>)`. 
The following are notional examples of how this is used to configure various shader execution models:
```fennel
; Fragment shaders must specify OriginUpperLeft in Vulkan.
; Other execution modes can give guarantees about computed depth tests etc.
(entrypoint fragmentMain Fragment [OriginUpperLeft DepthReplacing DepthLess] ...)

; SPIRV defines compute shaders using the GLCompute execution model.
; Compute-like shaders need to define the local number of invocations with LocalSize,
; or LocalSizeId if a SPIRV constant rather than a compile time number is used as a parameter.
; Depending on extensions, some other features can be activated too.
(entrypoint postProcess GLCompute [(LocalSize 8 8 1) DerivativeGroupQuadsNV] ...)

; Mesh shaders need to define max output bounds
(entrypoint meshMain MeshEXT [(LocalSize 8 8 1) (OutputVertices 64) (OutputPrimitivesEXT 64)] ...)

; ...etc.
```

The body of the entrypoint is a great place to declare global variables that should not be shared like input/outputs. It is also where control flow begins.

If for whatever reason you need to defer the choice of execution modes to after the declaration of the entrypoint, this can be done. Simply call `(execution-mode <name> ...<execution mode(s)>...)` with either the same name used for the entrypoint given as a string, or the entrypoint itself as the first parameter.

### Conditional Control Flow

Fennel provides full tail call elimination, but SPIRV requires strictly structured control flow. So while "compile-time" control flow can appear anywhere and will essentially be inlined into the final code, the following constructs can only appear within an enclosing `fn*` definition (at the point when the construct is evaluated). If you need more advanced control flow constructs, many can be formed by combinations of the below and optionally made more pleasant to use with a macro. More ought to be added to `dsl.v1` however if these are found to be too limiting.

#### `if*`

The if/else block is designed to mimic Fennel's syntax. It begins with `if*`, followed by any number of condition-expression pairs, and finally an else expression. The value of the `if*` expression is the value of the branch that is taken, so it can also be used as a ternary expression.

```fennel
(local v (if* (lt? x y) value-if-true value-if-false)) ; use as ternary

; multi-way if-else chain
(if* foo (set* color in-color-1)
     bar (do (set* color in-color-2) (set* alpha 0.5))
     baz nil ; `nil` can indicate to do nothing
     (set* color (* color 0.1))) ; final else case not preceded by a condition 
```

#### `when*`

For procedural `if` blocks that are mainly used for side effects, the former syntax can be verbose.
Felvine includes `when*` as an analog to Fennel's `when` syntax allowing simpler multi-statement if blocks with no else case.
This could also be viewed as a one-iteration-max while loop.

```fennel
(var* v i32 := (some-function x))

(when* (gte? v 128)  ; When condition holds,
    (set* v 127)     ; do this,
    (set* x (+ v 1)) ; then do this,
    ...)             ; etc., each statement is part of the same block.
```

#### `while*`

The simplest looping construct, repeating the body until the condition is no longer true.

```fennel
(var* j i32 := 0)

(while* (lt? j b)     ; As long as condition is true,
    (set* j (+ j a))) ; perform one or more steps.
```

#### `for*`

A numerical for loop which iterates from a starting point to an end point (inclusive). The type of the loop variable must be given as well.
An optional step value can be provided to iterate downwards or in greater increments than 1.

```fennel
(var* j i32 := 0)
(var* k [10 i32] := ...)

; Sum array contents
(for* [(i i32) 0 9]
    (set* j (+ j (k i))))

; Reverse array contents
(for* [(i i32) 9 5 -1]
    (local e (k i))
    (set* (k i) (k (- 9 i)))
    (set* (k (- 9 i)) e))

; Iterate from dynamic start/endpoint.
; The endpoints are only evaluated once before the loop begins.
(for* [(i i32) (k 0) j]
    ...)
```

The iteration variable (here, `i`) _is_ mutable but changing it during the loop should be avoided.

### Specialization Constants

SPIRV Specialization constants are declared using the `const*` form, analogously to `var*`. However, as they are
constant values, they cannot be given a storage class. They _must_ be initialized; this acts as the default value
for the specialization constant if a different one is not provided before running the shader. They also must be decorated with the `SpecId` decoration to uniquely identify the variable to the Vulkan API.

Note that in Felvine, it is easier (compared to GLSL) to use specialization constants for purposes like configuring the workgroup size. There is no special syntax for it, the declared constant can simply be used with the `LocalSizeId` execution mode when declaring an entrypoint.

As in SPIRV, specialization constants can only be scalars. However, composite specialization constants can be
constructed from these scalars with the normal expression syntax.

```fennel
(const* LOCAL_SIZE_X u32 := 8 (SpecId 0))
(const* LOCAL_SIZE_Y u32 := 8 (SpecId 1))
(local LOCAL_SIZE_XY ((vec2 u32) LOCAL_SIZE_X LOCAL_SIZE_Y)) ; still computed as a spec constant for constant folding
```

### Indexing and field access

Retrieving elements of vectors, matrices, arrays, and structs is an extremely common operation and can be done in a consistent way in Felvine.
Indices and fields are accessed by applying the value to an integer (for array/element access) or string (for struct field access or swizzling).
This part of the language is implemented with polymorphism rather than macros, and so cannot be changed.

For example:

```fennel
; To demonstrate all different kinds of indexing we will use this example type:
(type* Data {
    vector (vec3 f32)
    matrix (mat3x3 f32)
    array [10 f32]
    pointer [*P { x f32 y f32 }]
})

(var* data Data := ...) ; Suppose we have a value of this type already.
(var* other-pointer-value [*P { x f32 y f32 }] := ...) ; and suppose we have another pointer.

(local v data.vector)    ; Field access can use `.` when left hand side is an identifier
(local v (data :vector)) ; Field access can also be written `(struct :field)` for other cases or dynamic fields.

(local v0 (v 0)) ; Vector indexing is written `(vector index)`. indexing is zero-based (per SPIRV).
(local vXY v.xy) ; Swizzling allows accessing vector elements by other names: xyzw, rgba, or 0123
(local vXY (v :xy)) ; Swizzles can also be written in this style.

(local m00  (data :matrix 0 0))  ; When using the list style indexing, we can chain multiple accesses together.
(local m0YZ (data.matrix 0 :yz)) ; Matrix indexing returns columns, which we can then swizzle if we desire.

; Note: p is a Function* PhysicalStorageBuffer64* since variables are initially pointer-valued and indexing preserves the leading pointer in the type.
(local p data.pointer) 

; Often you _do_ want the indexed value to be a pointer, as SPIRV has restrictions on the indexing available otherwise.
; For example, only pointers-to-arrays can be dynamically indexed, while direct array indices must be constants.
; Usually the default semantics will be the ones you want; indexing will preserve the outermost pointer.

(local a0-ptr (data.array 0)) ; Function* f32, using dynamic indexing (happens to be constant here).
(local a0 (data.array.* 0)) ; f32, using constant indexing. Worse choice since (in principle) it copies the array.

; Felvine auto-dereferences when needed so usually you will not need to do this, but all these are valid and equivalent:
(local b (+ a0-ptr.* 10)) ; trailing .* to dereference
(local b (+ a0-ptr 10))   ; implicit dereference before addition
(local b (+ a0 10))       ; a0 already is a plain f32 value

; Because the leading pointer type is preserved,
; the SAME indexing syntax is used for storing values into variables/buffers etc.
(set* data.vector data.vector.zyx)
(set* (data :array 5) v0)

; Felvine auto-dereferences pointer indirections, here we have two nested pointers as another example.
; All of the below are valid and equivalent, such that px is a `PhysicalStorageBuffer64* f32`
(local px p.x) 
(local px p.*.x)
(local px (p :* :x)) ; (p :*) is equivalent to p.*

; Without a trailing .*, we are setting the pointer value itself here, not its contents.
(set* data.pointer other-pointer-value)

; Here we set the pointed-to value. Note that px is also implicitly dereferenced when casting it to f32 here.
(set* data.pointer.* { :x px :y px })
```

### Reference Types (and self-referential types)

SPIRV supports using pointers in the `PhysicalStorageBuffer` storage class as bindless
accessors to buffer memory when using the `bufferDeviceAddress` vulkan feature.

This enables indirection in data structures, as well, in which case often the data types
being declared could be self referential or mutually recursive in some way. Felvine provides
the `ref-types*` declaration to more easily define such families of types all at once.

For example:

```fennel
(ref-types*
  Node { 
    left Node
    right Node
    content (mat4 f32)
  }
  Tree { 
    root Node
    first-child Node
    last-child Node
  })
```

After this definition, `Tree` and `Node` will refer to pointer types with an element type
of the struct provided. Because they are pointers, it is ok for the structs to contain references to the type name itself as shown. The types can also be used with pointer arithmetic. To access the internal struct type, use e.g. `Node.elem`.

This syntax does not support inline decorations applied to the types, but this can be performed after the fact using `decorate`.

# References and Similar Work

- Lua (https://www.lua.org/)
- Fennel (https://fennel-lang.org/)
- Collapsing Towers of Interpreters (https://dl.acm.org/doi/pdf/10.1145/3158140)
- Staged Metaprogramming for Shader System Development (https://dl.acm.org/doi/pdf/10.1145/3355089.3356554)

[Lua]: https://www.lua.org/
[CTI]: https://dl.acm.org/doi/pdf/10.1145/3158140
[Fennel]: https://fennel-lang.org/
[PE]: https://en.wikipedia.org/wiki/Partial_evaluation