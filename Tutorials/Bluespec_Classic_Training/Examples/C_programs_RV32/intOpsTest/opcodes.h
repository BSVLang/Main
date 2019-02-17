#pragma once

#define False 0
#define True  1

typedef enum {
    OP_EQ, OP_NE, OP_LT, OP_GE, OP_LTU, OP_GEU,
    OP_ADD, OP_SUB,
    OP_LOGICAL_AND, OP_LOGICAL_OR, OP_LOGICAL_NOT,
    OP_AND, OP_OR, OP_XOR, OP_NOT,
    OP_SLL, OP_SRL, OP_SRA,
    N_OPS
} opcodes;

char *opcode_names [] = {
    "EQ", "NE", "LT", "GE", "LTU", "GEU",
    "ADD", "SUB",
    "OP_LOGICAL_AND", "OP_LOGICAL_OR", "OP_LOGICAL_NOT",
    "AND", "OR", "XOR", "NOT",
    "SLL", "SRL", "SRA",
    "N_OPS"
};

void compute32 (uint32_t op,
		uint32_t shamt,
		uint32_t u1,
		uint32_t u2,
		uint32_t *p_noop,
		uint32_t *p_result)
{
    int32_t i1 = u1;
    int32_t i2 = u2;
    uint32_t result;

    *p_noop = False;
    switch (op) {
    case OP_EQ:  *p_result = (i1 == i2); break;
    case OP_NE:  *p_result = (i1 != i2); break;
    case OP_LT:  *p_result = (i1 <  i2); break;
    case OP_GE:  *p_result = (i1 >= i2); break;
    case OP_LTU: *p_result = (u1 <  u2); break;
    case OP_GEU: *p_result = (u1 >= u2); break;

    case OP_ADD: *p_result = (i1 + i2); break;
    case OP_SUB: *p_result = (i1 - i2); break;

    case OP_LOGICAL_AND: *p_result = (u1 && u2); break;
    case OP_LOGICAL_OR:  *p_result = (u1 || u2); break;
    case OP_LOGICAL_NOT: *p_result = ! (u1); break;

    case OP_AND: *p_result = (u1 & u2); break;
    case OP_OR:  *p_result = (u1 | u2); break;
    case OP_XOR: *p_result = (u1 ^ u2); break;
    case OP_NOT: *p_result = ~u1;       break;

    case OP_SLL: u2 = shamt; *p_result = (u1 << u2); break;
    case OP_SRL: u2 = shamt; *p_result = (u1 >> u2); break;
    case OP_SRA: u2 = shamt; *p_result = (i1 >> u2); break;

    default: *p_noop = True; break;
    }
}

void compute64 (uint32_t op,
		uint32_t shamt,
		uint64_t u1,
		uint64_t u2,
		uint32_t *p_noop,
		uint64_t *p_result)
{
    int64_t i1 = u1;
    int64_t i2 = u2;
    uint64_t result;

    *p_noop = False;
    switch (op) {
    case OP_EQ:  *p_result = (i1 == i2); break;
    case OP_NE:  *p_result = (i1 != i2); break;
    case OP_LT:  *p_result = (i1 <  i2); break;
    case OP_GE:  *p_result = (i1 >= i2); break;
    case OP_LTU: *p_result = (u1 <  u2); break;
    case OP_GEU: *p_result = (u1 >= u2); break;

    case OP_ADD: *p_result = (i1 + i2); break;
    case OP_SUB: *p_result = (i1 - i2); break;

    case OP_LOGICAL_AND: *p_result = (u1 && u2); break;
    case OP_LOGICAL_OR:  *p_result = (u1 || u2); break;
    case OP_LOGICAL_NOT: *p_result = ! (u1); break;

    case OP_AND: *p_result = (u1 & u2); break;
    case OP_OR:  *p_result = (u1 | u2); break;
    case OP_XOR: *p_result = (u1 ^ u2); break;
    case OP_NOT: *p_result = ~u1;       break;

    case OP_SLL: u2 = shamt; *p_result = (u1 << u2); break;
    case OP_SRL: u2 = shamt; *p_result = (u1 >> u2); break;
    case OP_SRA: u2 = shamt; *p_result = (i1 >> u2); break;

    default: *p_noop = True; break;
    }
}
