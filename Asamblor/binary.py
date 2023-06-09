from lexer import NUMBER_TOKEN, INSTRUCTION_NAME, LABEL_NAME, JUMP_NAME, EOF, REGISTER_TOKEN, EOFL
from opcodes import opcodes, dual_mode_instructions
import re
BRANCH_BIT_COUNT = 10
IMMEDIATE_BIT_COUNT = 9
INSTRUCTION_SIZE = 16


class Binariser(object):
    def __init__(self, instructions_tokenized):
        self.instructions_tokenized = instructions_tokenized
        self.labels_to_lines()

    def binarise(self):
        binary_instructions = []
        for instruction_id, instruction in enumerate(self.instructions_tokenized):
            binary_instructions.append(
                self.binarise_instruction(instruction_id, instruction))

        for i in range(len(binary_instructions), 65536):
            binary_instructions.append("1"*16)

        return '\n'.join(binary_instructions)

    def labels_to_lines(self):
        labels_lines = dict()
        for line, instruction in enumerate(self.instructions_tokenized):
            for token in instruction:
                if token.type is LABEL_NAME:
                    if labels_lines.get(token.value) is not None:
                        print(f'Label {token.value} is already used')
                    else:
                        labels_lines[token.value] = line
        self.labels_lines = labels_lines

    def binarise_instruction(self, instruction_id, instruction):
        binary_instruction = []
        instruction_length = 0
        for token in instruction:
            binarised_token = self.visit(token, instruction_id, instruction)
            if binarised_token is not None:
                instruction_length += len(binarised_token)
                binary_instruction.append(binarised_token)

        binarised_instruction = ''.join(binary_instruction)

        padding = ''
        if INSTRUCTION_SIZE != instruction_length:
            padding = '' + '0'*(INSTRUCTION_SIZE - instruction_length)

        return binarised_instruction + padding

    def visit(self, token, instruction_id, instruction):
        method = getattr(self, "binarise" + token.type)
        return method(token, instruction_id, instruction)

    # transforms positive(>=0) decimals to binary
    # returns binary values between [-2^(bitCount - 1), 2^(bitCount - 1))
    def decimal_to_binary(self, decimal, bitCount):
        if decimal >= 0:
            binary = bin(decimal).split("0b")[1]
            while len(binary) < bitCount:
                binary = '0'+binary
            return binary
        else:
            return bin(-decimal-pow(2, bitCount)).split("0b")[1]

    def binariseLABEL_NAME(self, token, instruction_id, instruction):
        return None

    def binariseINSTRUCTION_NAME(self, token, instruction_id, instruction):
        instruction_name = token.value
        opcode = opcodes[instruction_name]
        if instruction_name in dual_mode_instructions:
            # register - register
            if instruction[-1].type is NUMBER_TOKEN:
                opcode = '1' + opcode[1:]
        return opcode

    def binariseREGISTER_TOKEN(self, token, instruction_id, instruction):
        return '0' if token.value == 'X' else '1'

    def binariseNUMBER_TOKEN(self, token, instruction_id, instruction):
        max_value = 2**(IMMEDIATE_BIT_COUNT - 1) - 1
        if token.value > max_value:
            raise Exception(f'Immediate value can\'t be more than {max_value}')
        return self.decimal_to_binary(token.value, IMMEDIATE_BIT_COUNT)

    def binariseJUMP_NAME(self, token, instruction_id, instruction):
        offset = self.labels_lines[token.value] - instruction_id
        if(offset < -256 or offset > 255):
            raise Exception(f'Jump is too big, must be between -256 and 255')
        return self.decimal_to_binary(offset, BRANCH_BIT_COUNT)
