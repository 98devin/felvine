
import argparse
import json
import sys
from dataclasses import dataclass, field, replace
from itertools import takewhile
from typing import Dict, List, Literal, Optional, Set, Tuple

def intro():
    return f"""(local {{: mkEnum}} (include :base))"""

@dataclass
class OperandDesc:
    kind: str # basic type or enum, etc.
    name: Optional[str] = None
    quantifier: Literal["?"] | Literal["*"] | None = None

@dataclass
class EnumerantDesc:
    name: str
    value: int
    version: Optional[Tuple[int, int]] = None,
    operands: List[OperandDesc] = field(default_factory=list)
    altnames: Set[str] = field(default_factory=set)
    req_extensions: List[str] = field(default_factory=list)
    req_capabilities: List[str] = field(default_factory=list)

@dataclass
class EnumDesc:
    name: str
    category: Literal["BitEnum"] | Literal["ValueEnum"]
    enumerants: List[EnumerantDesc]


SPEC_CONSTANT_OPS = {
    "OpSConvert",
    "OpFConvert",
    "OpSNegate",
    "OpNot",
    "OpIAdd",
    "OpISub",
    "OpIMul",
    "OpUDiv",
    "OpSDiv",
    "OpUMod",
    "OpSRem",
    "OpSMod",
    "OpShiftRightLogical",
    "OpShiftRightArithmetic",
    "OpShiftLeftLogical",
    "OpBitwiseOr",
    "OpBitwiseXor",
    "OpBitwiseAnd",
    "OpVectorShuffle",
    "OpCompositeExtract",
    "OpCompositeInsert",
    "OpLogicalOr",
    "OpLogicalAnd",
    "OpLogicalNot",
    "OpLogicalEqual",
    "OpLogicalNotEqual",
    "OpSelect",
    "OpIEqual",
    "OpINotEqual",
    "OpULessThan",
    "OpSLessThan",
    "OpUGreaterThan",
    "OpSGreaterThan",
    "OpULessThanEqual",
    "OpSLessThanEqual",
    "OpUGreaterThanEqual",
    "OpSGreaterThanEqual",

    # missing before version 1.4:
    "OpUConvert",

    # If the Shader capability was declared, 
    "OpQuantizeToF16",

    # If the Kernel capability was declared, the following opcodes are also valid:
    "OpConvertFToS",
    "OpConvertSToF",
    "OpConvertFToU",
    "OpConvertUToF",
    "OpUConvert",
    "OpConvertPtrToU",
    "OpConvertUToPtr",
    "OpGenericCastToPtr",
    "OpPtrCastToGeneric",
    "OpBitcast",
    "OpFNegate",
    "OpFAdd",
    "OpFSub",
    "OpFMul",
    "OpFDiv",
    "OpFRem",
    "OpFMod",
    "OpAccessChain",
    "OpInBoundsAccessChain",
    "OpPtrAccessChain",
    "OpInBoundsPtrAccessChain",
}

SPEC_CONSTANT_OPS_CAPABILITIES = {
    "OpQuantizeToF16": [ "Shader" ],
    "OpConvertFToS": [ "Kernel" ],
    "OpConvertSToF": [ "Kernel" ],
    "OpConvertFToU": [ "Kernel" ],
    "OpConvertUToF": [ "Kernel" ],
    "OpUConvert": [ "Kernel" ],
    "OpConvertPtrToU": [ "Kernel" ],
    "OpConvertUToPtr": [ "Kernel" ],
    "OpGenericCastToPtr": [ "Kernel" ],
    "OpPtrCastToGeneric": [ "Kernel" ],
    "OpBitcast": [ "Kernel" ],
    "OpFNegate": [ "Kernel" ],
    "OpFAdd": [ "Kernel" ],
    "OpFSub": [ "Kernel" ],
    "OpFMul": [ "Kernel" ],
    "OpFDiv": [ "Kernel" ],
    "OpFRem": [ "Kernel" ],
    "OpFMod": [ "Kernel" ],
    "OpAccessChain": [ "Kernel" ],
    "OpInBoundsAccessChain": [ "Kernel" ],
    "OpPtrAccessChain": [ "Kernel" ],
    "OpInBoundsPtrAccessChain": [ "Kernel" ],
}

SPEC_CONSTANT_OPS_VERSIONS = {
    "OpUConvert": (1, 4)
}



enums: Dict[str, EnumDesc] = {}
indent_level = 0
output_file = None


def indent():
    global indent_level
    indent_level += 1



def dedent():
    global indent_level
    indent_level -= 1



def indented(iter):
    indent()
    yield from iter
    dedent()



def emit(str="", **kwargs):
    global indent_level
    global output_file
    indent = "    " * indent_level
    print(indent + str, **kwargs, file=output_file)



def capitalize_initial(str):
    return str[0].capitalize() + str[1:]



def common_prefix(str1, str2):
    def eq(ab):
        a, b = ab
        return a == b
    return "".join(map(lambda p: p[0], takewhile(eq, zip(str1, str2))))



def uncommon_suffix(str1, str2):
    prefix = common_prefix(str1, str2)
    return (str1[len(prefix):], str2[len(prefix):])



def make_name_unique(name, nameset):
    if name not in nameset:
        nameset.add(name)
        return name

    count = 2
    nameN = f"{name}{count}"
    while nameN in nameset:
        count += 1
        nameN = f"{name}{count}"

    nameset.add(nameN)
    return nameN



def sanitize_operand_name(name):
    name = ", ".join(item.replace("'", "").replace("\n", " ").strip() for item in name.split(","))
    return name



def sanitize_name(name, default=None):
    name = name.strip("'")
    name = name.replace(" ", "_").replace("-", "_")
    name = "".join(capitalize_initial(part) for part in name.split("_"))
    name = name.replace("~", "").replace(".", "")
    if '\n' in name:
        if default is None:
            raise ValueError("Could not sanitize due to newlines: `{name}`")
        name = default
    if name[0].isdigit() or not name.isalnum():
        name = f'_{name}'
    return name



def emit_enum_case(enumerant: EnumerantDesc):
    
    operand_types = []
    
    emit(f":{enumerant.name}" " {")
    indent()

    emit(f":tag :{enumerant.name}")
    emit(f":value {enumerant.value}")

    if enumerant.version is not None:
        emit(f":version {{ :major {enumerant.version[0]} :minor {enumerant.version[1]} }}")

    if len(enumerant.req_extensions) != 0:
        emit(f":extensions [")
        indent()
        for extension in enumerant.req_extensions:
            emit(f":{extension}")
        dedent()
        emit("]")

    if len(enumerant.req_capabilities) != 0:
        emit(f":capabilities [")
        indent()
        for capability in enumerant.req_capabilities:
            emit(f":{capability}")
        dedent()
        emit("]")

    if len(enumerant.operands) != 0:
        emit(f":operands [")
        indent()
        for operand in enumerant.operands:
            
            operand_content = []
            operand_content.append(f":kind :{operand.kind}")
            
            if operand.quantifier is not None:
                operand_content.append(f":quantifier :{operand.quantifier}")
            
            if operand.name is not None:
                operand_content.append(f":name \"{sanitize_operand_name(operand.name)}\"")

            emit("{" + " ".join(operand_content) + "}")

        dedent()
        emit("]")

    dedent()
    emit("}")



def emit_enum_datatype(enum: EnumDesc, enum_kind: str):

    emit(f"(local {enum.name} (mkEnum :{enum.name} :{enum_kind}" " {")
    indent()
    
    for enumerant in enum.enumerants:
        emit_enum_case(enumerant)

    dedent()
    emit("}))")

    emit()

    had_alternatives = False
    for enumerant in enum.enumerants:
        for alt_name in enumerant.altnames:
            had_alternatives = True
            emit(f"(set {enum.name}.enumerants.{alt_name} {enum.name}.enumerants.{enumerant.name})")
    
    if had_alternatives:
        emit()




def emit_enum(enum: EnumDesc):
    if enum.category == "BitEnum":
        enum_kind = "bits"
    elif enum.category == "ValueEnum":
        enum_kind = "value"
    emit_enum_datatype(enum, enum_kind)



def produce_spec_constant_op_desc(instructions: EnumDesc):
    enumerants = []
    for op in instructions.enumerants:
        if op.name in SPEC_CONSTANT_OPS:
            operands = [opand for opand in op.operands if opand.kind not in ("IdResult", "IdResultType")]
            enumerants.append(EnumerantDesc(
                name = op.name,
                value = op.value,
                altnames = op.altnames,
                version = SPEC_CONSTANT_OPS_VERSIONS.get(op.name),
                operands = operands,
                req_capabilities = SPEC_CONSTANT_OPS_CAPABILITIES.get(op.name, []),
                req_extensions = [],
            ))

    return EnumDesc(
        name = "SpecConstantOp",
        category = "ValueEnum",
        enumerants = enumerants,
    )



def produce_instruction_desc(raw) -> EnumDesc:
    return EnumDesc(
        name = "Op",
        category = "ValueEnum",
        enumerants = produce_enumerants_desc(raw, namefield="opname", valuefield="opcode", operandfield="operands")
    )



def produce_enumerants_desc(raw, keep_zero=True, **kwargs) -> List[EnumerantDesc]:    
    enumerants: List[EnumerantDesc] = []
    seen_enumerants: Dict[int, EnumerantDesc] = {}

    for raw_enumerant in raw:
        enumerant_desc = produce_enumerant_desc(raw_enumerant, **kwargs)
        if not keep_zero and enumerant_desc.value == 0:
            continue

        if enumerant_desc.value in seen_enumerants:
            seen_desc = seen_enumerants[enumerant_desc.value]
            (seen_suffix, new_suffix) = uncommon_suffix(seen_desc.name, enumerant_desc.name)

            if ((new_suffix == "") or
                (seen_suffix != "" and new_suffix == "KHR") or
                (seen_suffix not in ("", "KHR") and new_suffix == "EXT")
            ):
                seen_desc.altnames.add(seen_desc.name)
                seen_desc.name = enumerant_desc.name
            else:
                seen_desc.altnames.add(enumerant_desc.name)

        else:
            seen_enumerants[enumerant_desc.value] = enumerant_desc
            enumerants.append(enumerant_desc)

    return enumerants



def produce_enum_desc(raw) -> EnumDesc:
    return EnumDesc(
        name = raw["kind"],
        category = raw["category"],
        enumerants = produce_enumerants_desc(raw["enumerants"], keep_zero=(raw["category"] != "BitEnum"))
    )



def produce_operand_desc(raw) -> OperandDesc:
    return OperandDesc(
        kind = raw["kind"],
        name = raw.get("name"),
        quantifier = raw.get("quantifier"),
    )



def produce_enumerant_desc(raw, prefix="", namefield="enumerant", valuefield="value", operandfield="parameters") -> EnumerantDesc:
    raw_version = raw.get("version", "None")
    return EnumerantDesc(
        name = f"{prefix}{raw[namefield]}",
        value = int(str(raw[valuefield]), base=0), # WTF: Python complains about base=0 when the input is another int...
        version = None if raw_version == "None" else tuple(map(int, raw_version.split("."))),
        operands = [produce_operand_desc(raw_operand) for raw_operand in raw.get(operandfield, [])],
        req_extensions = raw.get("extensions", []),
        req_capabilities = raw.get("capabilities", []),
    )



def emit_spirv_types(grammar, *, glsl_grammar=None):

    for raw_operand_kind in grammar["operand_kinds"]:
        if raw_operand_kind["category"] in ("ValueEnum", "BitEnum"):
            enum_desc = produce_enum_desc(raw_operand_kind)
            enums[enum_desc.name] = enum_desc

    for enum_desc in enums.values():
        emit_enum(enum_desc)
        emit()

    instructions_desc = produce_instruction_desc(grammar["instructions"])
    spec_constant_op_desc = produce_spec_constant_op_desc(instructions_desc)

    emit_enum_datatype(spec_constant_op_desc, enum_kind="value")
    emit()

    emit_enum_datatype(instructions_desc, enum_kind="op")
    emit()

    if glsl_grammar is not None:
        glsl_instructions_desc = produce_instruction_desc(glsl_grammar["instructions"])
        glsl_instructions_desc.name = "ExtGLSL"
        emit_enum_datatype(glsl_instructions_desc, enum_kind="ext")
        emit()

    emit("{")
    indent()

    for _, enum_desc in enums.items():
        emit(f": {enum_desc.name}")

    emit(": Op")
    emit(": SpecConstantOp")
    emit(":LiteralSpecConstantOpInteger SpecConstantOp")

    if glsl_grammar is not None:
        emit(": ExtGLSL")

    emit(": magicNumber")
    emit(": majorVersion")
    emit(": minorVersion")
    emit(": version")
    emit(": revision")

    dedent()
    emit("}")


def emit_spirv_constants(grammar):
    magic_number = grammar["magic_number"]
    emit(f"(local magicNumber {magic_number})")

    major_version = grammar["major_version"]
    emit(f"(local majorVersion {major_version})")

    minor_version = grammar["minor_version"]
    emit(f"(local minorVersion {minor_version})")

    emit(f"(local version {{ :major {major_version} :minor {minor_version} }})")

    revision = grammar["revision"]
    emit(f"(local revision {revision})")

    emit()



def emit_impl(grammar, **kwargs):
    emit(intro())
    emit_spirv_constants(grammar)
    emit_spirv_types(grammar, **kwargs)



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("spirv_grammar", type=str)
    parser.add_argument("--ext-glsl-grammar", type=str, required=False)
    parser.add_argument("-o", type=str, required=False)

    args = parser.parse_args()

    if args.o is not None:
        output_file = open(args.o, 'w', encoding='utf-8', newline='\n')
    else:
        output_file = sys.stdout

    with open(args.spirv_grammar, 'r') as f:
        grammar = json.load(f)

    if args.ext_glsl_grammar is not None:
        with open(args.ext_glsl_grammar, 'r') as f:
            glsl_grammar = json.load(f)
    else:
        glsl_grammar = None

    emit_impl(grammar, glsl_grammar=glsl_grammar)