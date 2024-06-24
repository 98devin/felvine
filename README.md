
# Felvine

Felvine is a **F**unctional, **E**mbedded **L**anguage for SPIR**V** (specifically, Vulkan) shaders.

TL;DR Replaces preprocessing hacks, reflection, and complicated language features with a powerful and customizable metalanguage.

### Functional

Felvine shaders are defined in an EDSL within Fennel, a Lisp-like language which compiles to Lua.
This means the metalanguage offers conveniences like tail calls, first class functions, and hygienic macros,
all of which are guaranteed to be erased in the compiled shader module. Because of Lua however,
operator overloading, prototype-based OO, and other techniques are also possible.

### Embedded

Not only are Felvine shaders embedded within Fennel, but Felvine as a whole can be embedded within any
host which can interact with Lua. This allows runtime compilation of shaders and trivially passing
complex parameters into the shader scripts where specialization constants might be inconvenient.
Reflection of the entire compilation environment and arbitrary return values from shader compilation are also possible, without
necessarily needing to introspect the SPIRV output to get bindings etc.

### SPIRV

Felvine offers full access to SPIRV if needed, and generates bindings from the SPIRV grammar directly to support future extensions.

However, deep knowledge of SPIRV is not required either, and only some concepts (Capabilities, Storage Class, Execution Modes, and Decorations) are used directly.
Extensions and Capabilities can be conditionally enabled with arbitrary compile time predicates, and Felvine can validate their usage
against any user defined set of allowed Vulkan features and extensions, replacing the need for complicated IFDEFs in other shader languages.
The user should still consult Vulkan documentation for more complex validity requirements as Felvine cannot check all use cases (nor can HLSL or GLSL et al.)

##



