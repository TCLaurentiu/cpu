NUMBER_TOKEN, INSTRUCTION_NAME = "NUMBER_TOKEN", "INSTRUCTION_NAME"
LABEL_NAME, JUMP_NAME, EOF = "LABEL_NAME", "JUMP_NAME", "EOF",
REGISTER_TOKEN, EOFL = "REGISTER_TOKEN", "EOFL"


class Token(object):
    def __init__(self, type, value):
        self.type = type
        self.value = value

    def __repr__(self):
        return self.type + " = " + str(self.value)


class Lexer(object):
    def __init__(self, code):
        self.code = code
        self.length = len(code)
        self.pos = 0  # where we are in the code
        self.last_token = None
        self.default_error_message = "Error parsing code"

    def error(self, message = None):
        raise Exception(message if message is not None else self.default_error_message)

    def get_next_token_aux(self):
        code = self.code
        if self.pos > self.length - 1:
            return Token(EOF, EOF)
        while code[self.pos] in [' ', ','] : # skip spaces and commas
            self.pos += 1

        if code[self.pos] == '/': # start of comment
            while code[self.pos] != '\n': # skip the comment
                self.pos += 1
        
        if code[self.pos] == '\n':
            self.pos += 1
            return Token(EOFL, EOFL)

        if code[self.pos] == '#': # reading a number
            number = ''
            self.pos += 1
            while code[self.pos].isdigit():
                number += code[self.pos]
                self.pos += 1
            return Token(NUMBER_TOKEN, int(number))

        string = ''
        while code[self.pos].isalpha() or code[self.pos].isdigit():
            string += code[self.pos]
            self.pos += 1

        if string == '':
            return Token(EOF, EOF)
        
        if string in ['X', 'Y']:
            return Token(REGISTER_TOKEN, string)

        if code[self.pos] == ':':
            self.pos += 1
            return Token(LABEL_NAME, string)

        if self.last_token is not None and self.last_token.type is INSTRUCTION_NAME:
            return Token(JUMP_NAME, string)

        if self.last_token is None or self.last_token.type in [EOFL, LABEL_NAME]:
            return Token(INSTRUCTION_NAME, string)

        self.error()

    def get_next_token(self):
        token = self.get_next_token_aux()
        self.last_token = token
        return token

    def tokenize(self):
        instructions = []
        instruction = []
        while True:
            token = self.get_next_token()
            if token.type is EOFL:
                instructions.append(instruction)
                instruction = []
            else:
                instruction.append(token)
            if token.type is EOF:
                break
        return instructions