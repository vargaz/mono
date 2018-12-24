#
# tablegen.py: Python port of tlbgen
#
from __future__ import print_function

import sys
import io
import os
import argparse

# Random python2/3 hack
import sys
if sys.version_info.major == 3:
    unicode = str

class TokenKind:
    EOF = 0
    ERROR = 1
    ID = 2
    STRING = 3
    INCLUDE = 4
    SEMI = 8
    PERIOD = 9
    COMMA = 10
    LESS = 11
    GREATER = 12
    RSQUARE = 13
    LBRACE = 14
    RBRACE = 15
    LPAREN = 16
    RPAREN = 17
    EQUAL = 18
    QUESTION = 19
    PASTE = 20
    COLON = 21
    LSQUARE = 22
    KW_INT = 23
    KW_BIT = 24
    KW_BITS = 25
    KW_STRING = 26
    KW_LIST = 27
    KW_CODE = 28
    KW_DAG = 29
    KW_CLASS = 30
    KW_DEF = 31
    KW_FOREACH = 32
    KW_DEFM = 33
    KW_MULTICLASS = 34
    KW_FIELD = 35
    KW_LET = 36
    KW_IN = 37
    INT = 38

    to_str = {
        EOF : "EOF", ERROR : "ERROR", ID : "ID", INCLUDE : "INCLUDE", STRING : "STRING",
        INCLUDE : "INCLUDE", SEMI : "SEMI", PERIOD : "PERIOD", COMMA : "COMMA", LESS : "LESS",
        GREATER : "GREATER", RSQUARE : "RSQUARE", LBRACE : "LBRACE",
        RBRACE : "RBRACE", LPAREN : "LPAREN", RPAREN : "RPAREN",
        EQUAL : "EQUAL", QUESTION : "QUESTION", PASTE : "#",
        COLON : "COLON", LSQUARE : "LSQUARE",
        KW_INT: "KW_INT", KW_BIT: "KW_BIT", KW_BITS: "KW_BITS", KW_STRING: "KW_STRING",
        KW_LIST: "KW_LIST", KW_CODE: "KW_CODE", KW_DAG: "KW_DAG", KW_CLASS: "KW_CLASS",
        KW_DEF: "KW_DEF", KW_FOREACH: "KW_FOREACH", KW_DEFM: "KW_DEFM", KW_MULTICLASS: "KW_MULTICLASS",
        KW_FIELD: "KW_FIELD", KW_LET: "KW_LET", KW_IN: "KW_IN",
        INT: "INT"
        }

    simple_tokens = {
        ':' : COLON,
        ';' : SEMI, '.' : PERIOD, ',' : COMMA, '<' : LESS, '>' : GREATER,
        ']' : RSQUARE, '{' : LBRACE, '}' : RBRACE, '(' : LPAREN, ')' : RPAREN,
        '=' : EQUAL, '?' : QUESTION, '#' : PASTE, '[' : LSQUARE
        }

    keywords = {
        "int" : KW_INT, "bit" : KW_BIT, "bits" : KW_BITS, "string" : KW_STRING,
        "list" : KW_LIST, "code" : KW_CODE, "dag" : KW_DAG, "class" : KW_CLASS,
        "def" : KW_DEF, "foreach" : KW_FOREACH, "defm" : KW_DEFM, "multiclass" : KW_MULTICLASS,
        "field" : KW_FIELD, "let" : KW_LET, "in" : KW_IN
        }

class Lexer:

    def __init__(self, input_file):
        self.input = input_file
        self.cur_c = None
        self.id_val = ""
        self.line = 1
        self.column = 0
        self.put_back_token = None
        pass

    def lex(self):
        if self.put_back_token:
            res = self.put_back_token
            self.put_back_token = None
            return res
        self.cur_token = self.lex_token ()
        return self.cur_token
        
    def read(self):
        if self.cur_c == None:
            c = self.input.read (1)
        else:
            c = self.cur_c
        self.cur_c = self.input.read (1)
        self.column += 1
        return c

    def put_back(self, token):
        self.put_back_token = token

    def lex_identifier(self, c):
        self.id_val = c
        while True:
            c = self.cur_c
            if c.isalnum () or c == '_':
                self.id_val += c
            else:
                break
            self.read ()
        if self.id_val == "include":
            return TokenKind.INCLUDE
        elif self.id_val in TokenKind.keywords:
            return TokenKind.keywords [self.id_val]
        return TokenKind.ID

    def lex_string(self):
        self.id_val = ''
        while True:
            c = self.read ()
            if c != '"':
                self.id_val += c
            else:
                break
        return TokenKind.STRING

    def lex_int(self, c):
        self.id_val = c
        while c.isdigit ():
            c = self.cur_c
            if c.isdigit ():
                self.id_val += c
            else:
                break
            c = self.read ()
        return TokenKind.INT

    def newline(self):
        self.line += 1
        self.column = 0
        
    def lex_token(self):
        c = self.read ()
        if len (c) == 0:
            return TokenKind.EOF
        if c == '/':
            next_c = self.cur_c
            if next_c == '/':
                while self.read () != '\n':
                    pass
                self.newline ()
                return self.lex_token ()
            elif next_c == '*':
                prev_c = ' '
                while True:
                    c = self.read ()
                    if c == "\n":
                        self.newline ()
                    if c == '/' and prev_c == '*':
                        break
                    prev_c = c
            return self.lex_token ()
        elif c == ' ' or c == '\t':
            return self.lex_token ()
        elif c == '\n':
            self.line += 1
            self.column = 0
            return self.lex_token ()
        elif c.isalpha () or c == '_':
            return self.lex_identifier (c)
        elif c.isdigit ():
            return self.lex_int (c)
        elif c == '"':
            return self.lex_string ()
        elif c in TokenKind.simple_tokens:
            return TokenKind.simple_tokens [c]
        else:
            self.id_val = c
            return TokenKind.ERROR
        return TokenKind.EOF

    def test_lexer():
        lexer = self
        while True:
            tok = lexer.lex ()
            if tok == TokenKind.EOF:
                break
            if tok == TokenKind.ID:
                print ("ID (" + lexer.id_val + ")")
            elif tok == TokenKind.STRING:
                print ("STRING (\"" + lexer.id_val + "\")")
            elif tok == TokenKind.ERROR:
                print ("ERROR (" + lexer.id_val + ")")
                break
            else:
                print (TokenKind.to_str [tok])

class Declaration:
    def __init__(self, name, param_type, value):
        self.name = name
        self.type = param_type
        self.value = value

    def __str__(self):
        return self.type + " " + self.name
    
class Class:
    def __init__(self, name, parent, params):
        self.name = name
        self.parent = parent
        self.params = params
        self.members = []

    def __str__(self):
        s = "class " + self.name
        if len(self.params) > 0:
            s += " <" + ", ".join(str(x) for x in self.params) + ">"
        if len(self.members) > 0:
            s += " { "
            for m in self.members:
                if m.value != None:
                    s = s + m.type + " " + m.name + " = " + str (m.value) + "; "
            s += "}"
        return s

class Define:
    def __init__(self, name, klass, members):
        self.name = name
        self.klass = klass
        self._members = members
        self._member_map = {}
        for m in members:
            self._member_map [m.name] = m.value.get_value ()

    def instance_of(self, classname):
        k = self.klass
        while k != None:
            if k.name == classname:
                return True
            k = k.parent
        return False

    # Make it easier to use this as a record type
    def __getattr__(self, name):
        return self._member_map [name]
    def __str__(self):
        s = "def " + self.name
        if len(self._members) > 0:
            s += " {     // " + self.klass.name + "\n"
            index = 0
            for m in self._members:
                s += "  " + m.type + " " + m.name + " = " + str (m.value) + ";\n"
            s += "}"
        else:
            s += "    // " + self.klass.name
        return s

class Value:
    def __init__(self, type):
        pass
    # Evaluate the receiver in a given scope, returning a new Value
    def eval_in_scope(self, scope):
        pass
    # Return a python value for this object
    def get_value(self):
        pass
        
class IntValue(Value):
    def __init__(self, value):
        self.type = "int"
        self.value = value
    def eval_in_scope(self, scope):
        return self
    def get_value(self):
        return self.value
    def __str__(self):
        return str (self.value)

class StringValue(Value):
    def __init__(self, value):
        self.type = "string"
        self.value = value
    def eval_in_scope(self, scope):
        return self
    def get_value(self):
        return self.value
    def __str__(self):
        return '"' + str (self.value) + '"'

class IdValue(Value):
    def __init__(self, value):
        self.type = "id"
        self.value = value
    def eval_in_scope(self, scope):
        return scope [self.value]
    def get_value(self):
        error ("Undefined value '" + self.value + "'")
    def __str__(self):
        return str (self.value)

class ConstValue(Value):
    def __init__(self, value):
        self.value = value
    def eval_in_scope(self, scope):
        return self
    def get_value(self):
        return value
    def __str__(self):
        return str (self.value)

# A def
class DefValue(Value):
    def __init__(self, value):
        self.type = "def"
        self.value = value
    def eval_in_scope(self, scope):
        return self
    def get_value(self):
        return self.value
    def __str__(self):
        return self.value.name

current_lexer = None

def error(msg):
    raise Exception("Error at line " + str (current_lexer.line) + " column " +  str (current_lexer.column) + ": " + msg)
    sys.exit (1)

def unexpected(lexer):
    error ("Unexpected token: " + TokenKind.to_str [lexer.cur_token] + " " + lexer.id_val)

class Parser:
    def __init__(self, lexer):
        self.lexer_stack = []
        self.lexer = lexer
        self.classes = {}
        self.defines = []
        self.defines_by_name = {}
        self.in_let = False
        self.let_bindings = {}

    def run(self):
        lexer = self.lexer
        while True:
            tok = lexer.lex ()
            if tok == TokenKind.KW_CLASS:
                self.parse_class ()
            elif tok == TokenKind.KW_DEF:
                self.parse_define ()
            elif tok == TokenKind.KW_LET:
                self.parse_let ()
            elif tok == TokenKind.RBRACE:
                self.parse_let_end ()
            elif tok == TokenKind.INCLUDE:
                self.parse_include ()
                lexer = self.lexer
            elif tok == TokenKind.EOF:
                if len (self.lexer_stack) > 0:
                    self.lexer = self.lexer_stack [len (self.lexer_stack) - 1]
                    self.lexer_stack = self.lexer_stack [0:-1]
                    global current_lexer
                    current_lexer = self.lexer
                    lexer = self.lexer
                else:
                    break
            else:
                unexpected (lexer)

    def parse_id(self):
        lexer = self.lexer
        tok = lexer.lex ()
        if tok != TokenKind.ID:
            error("id expected")
        return lexer.id_val

    def parse_expected(self, token, msg):
        lexer = self.lexer
        tok = lexer.lex ()
        if tok != token:
            error (msg + " expected, got " + str(tok))

    def parse_value(self, tok):
        lexer = self.lexer
        if tok == TokenKind.STRING:
            return StringValue (lexer.id_val)
        elif tok == TokenKind.ID:
            if lexer.id_val in self.defines_by_name:
                return DefValue (self.defines_by_name [lexer.id_val])
            else:
                return IdValue (lexer.id_val)
        elif tok == TokenKind.INT:
            return IntValue (int (lexer.id_val))
        else:
            unexpected (lexer)

    def typecheck (self, name, member_type, value):
        if (value.type == "string" or value.type == "int") and member_type != value.type:
            error ("Cannot assign value '" + str (value) + "' to member '" + name + "' of type '" + member_type + ".")

    def instantiate_class(self, klass, args, let_bindings):
        if len(klass.params) < len(args):
            error ("Invalid parameter count for class " + klass.name)
        scope = {}
        index = 0
        for p in klass.params:
            if index >= len(args):
                if p.value == None:
                    error ("Parameter '" + p.name + "' for class '" + klass.name + "' has no default value.")
                scope [p.name] = p.value
            else:
                self.typecheck (p.name, p.type, args [index])
                scope [p.name] = args [index]
            index += 1
        members = []
        for m in klass.members:
            new_val = m.value.eval_in_scope (scope)
            if m.name in let_bindings:
                new_val = let_bindings [m.name]
            self.typecheck (m.name, m.type, new_val)
            members.append (Declaration (m.name, m.type, new_val))
        return members

    def apply_lets(self, members, lets):
        for m in members:
            if m.name in lets:
                m.value = lets [m.name]
                lets [m.name] = None
        for m in lets:
            if lets[m] != None:
                error ("Unknown member '" + m + "' in let statement.")
    
    # type Id [= <value>]
    def parse_decl(self):
        lexer = self.lexer
        tok = lexer.lex ()
        if tok == TokenKind.KW_INT:
            decl_type = "int"
        elif tok == TokenKind.KW_STRING:
            decl_type = "string"
        elif tok == TokenKind.KW_BIT:
            decl_type = "bit"
        elif tok == TokenKind.ID:
            decl_type = lexer.id_val
        else:
            error ("type expected")
        tok = lexer.lex ()
        if tok != TokenKind.ID:
            error ("id expected")
        decl_name = lexer.id_val
        tok = lexer.lex ()
        val = None
        if tok == TokenKind.EQUAL:
            tok = lexer.lex ()
            val = self.parse_value (tok)
        else:
            lexer.put_back(tok)
        return [decl_type, decl_name, val]

    # Class<args>
    # Returns a [klass, <list of Declaration>] pair
    def parse_base(self):
        lexer = self.lexer
        parent_name = self.parse_id ()
        if not parent_name in self.classes:
            error ("class '" + parent_name + "' not found.")
        parent = self.classes [parent_name]
        tok = lexer.lex ()
        args = []
        if tok == TokenKind.LESS:
            while True:
                tok = lexer.lex ()
                if tok == TokenKind.GREATER:
                    break
                if tok == TokenKind.COMMA:
                    tok = lexer.lex ()
                val = self.parse_value(tok)
                args.append (val)
        else:
            lexer.put_back (tok)
        members = self.instantiate_class (parent, args, self.let_bindings)
        return [parent, members]

    # { [<decl>] }
    # Return [list of Declarations, map of let bindings]
    def parse_objbody(self, parent_members):
        lexer = self.lexer
        members = []
        members_by_name = {}
        for m in parent_members:
            members_by_name [m.name] = m
        lets = {}
        while True:
            tok = lexer.lex ()
            if tok == TokenKind.RBRACE:
                break
            if tok == TokenKind.KW_LET:
                tok = lexer.lex ()
                if tok != TokenKind.ID:
                    error ("Expected ID, got " + str(tok) + " " + lexer.id_val)
                name = lexer.id_val
                self.parse_expected (TokenKind.EQUAL, "=")
                tok = lexer.lex ()
                val = self.parse_value (tok)
                lets [name] = val
            else:
                lexer.put_back (tok)
                [member_type, member_name, val] = self.parse_decl ()
                if member_name in members_by_name:
                    error ("Overriding inherited member '" + member_name + "'.")
                members.append (Declaration(member_name, member_type, val))
            tok = lexer.lex ()
            if tok != TokenKind.SEMI:
                error ("; expected, got " + str(tok))
        return [members, lets]

    def parse_class(self):
        lexer = self.lexer
        name = self.parse_id ()
        if name in self.defines_by_name or name in self.classes:
            error ("Duplicate def/class name '" + name + "'.")
        params = []
        parent_members = []
        parent = None
        tok = lexer.lex ()
        if tok == TokenKind.LESS:
            while True:
                [decl_type, decl_name, val] = self.parse_decl ()
                params.append (Declaration (decl_name, decl_type, val))
                tok = lexer.lex ()
                if tok == TokenKind.GREATER:
                    break
                if tok != TokenKind.COMMA:
                    error ("comma expected")
            tok = lexer.lex ()
        if tok == TokenKind.COLON:
            [parent, parent_members] = self.parse_base ()
            tok = lexer.lex ()
        if tok != TokenKind.LBRACE:
            error ("{ expected")
        [members, lets] = self.parse_objbody (parent_members)

        record = Class (name, parent, params)
        for m in parent_members:
            record.members.append (m)
        for m in members:
            record.members.append (m)
        self.classes [record.name] = record

    # def Id: Class<args>
    def parse_define(self):
        lexer = self.lexer
        name = self.parse_id ()
        if name in self.defines_by_name or name in self.classes:
            error ("Duplicate def/class name '" + name + "'.")
        self.parse_expected (TokenKind.COLON, ":")
        [parent, members] = self.parse_base ()
        tok = lexer.lex ()
        if tok == TokenKind.LBRACE:
            [def_members, lets] = self.parse_objbody (members)
            self.apply_lets (members, lets)
            tok = lexer.lex ()
        if tok != TokenKind.SEMI:
            error ("; expected")
        define = Define(name, parent, members)
        self.defines.append (define)
        self.defines_by_name [define.name] = define

    # let <list> in { <declarations> }
    def parse_let(self):
        lexer = self.lexer
        while True:
            tok = lexer.lex ()
            if tok != TokenKind.ID:
                error ("Expected ID, got " + str(tok) + " " + lexer.id_val)
            name = lexer.id_val
            self.parse_expected (TokenKind.EQUAL, "=")
            tok = lexer.lex ()
            val = self.parse_value (tok)
            self.let_bindings [name] = val
            tok = lexer.lex ()
            if tok != TokenKind.COMMA:
                lexer.put_back (tok)
                break
        self.parse_expected (TokenKind.KW_IN, "in")
        self.parse_expected (TokenKind.LBRACE, "{")
        self.in_let = True

    def parse_let_end(self):
        if self.in_let == False:
            error ("Unexpected }")
        self.in_let = False
        self.let_bindings = {}

    def parse_include(self):
        lexer = self.lexer
        tok = lexer.lex ()
        if tok != TokenKind.STRING:
            error ("Expected STRING, got " + str(tok) + " " + lexer.id_val)
        name = lexer.id_val
        self.lexer_stack.append (lexer)
        f = open (name)
        self.lexer = Lexer(f)
        global current_lexer
        current_lexer = lexer

class Table:
    def __init__(self, defines):
        self.defines = defines
        self.by_name = {}
        for define in self.defines:
            self.by_name [define.name] = define

class Backend:
    def __init__(self):
        pass

    def generate(self, table, output):
        pass

class DefaultBackend(Backend):
    def __init__(self):
        pass

    def generate(self, table, props, output):
        output.write ("------------- Defs -----------------\n")
        for define in table.defines:
            output.write (str (define))
            output.write ("\n")

class TableGen:
    def __init__(self):
        self.backends = {}
        self.backends_help = {}
        self.add_backend (DefaultBackend (), "--print-records", "Print all records to stdout (default)")

    def add_backend(self, gen, option_name, option_help):
        self.backends [option_name] = gen
        self.backends_help [option_name] = option_help
        
    def parse_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument ('--out', dest='outfile', help='path to output file')
        parser.add_argument ('infile', help='path to input file')
        parser.add_argument ('-p', dest='props_list', action='append', help='NAME=VALUE property passed to the code generator')
        for g in self.backends.keys ():
            parser.add_argument (g, dest='backend', action='store_const', const=g, help=self.backends_help [g])
        self.args = parser.parse_args ()
        self.props = {}
        for prop in self.args.props_list:
            parts = prop.split ('=')
            if len (parts) != 2:
                print ("Usage: -p VARIABLE=VALUE")
                sys.exit (1)
            self.props [parts [0]] = parts [1]

    def run(self):
        self.parse_args ()
        f = open (self.args.infile)

        lexer = Lexer(f)
        global current_lexer
        current_lexer = lexer

        parser = Parser(lexer)
        parser.run ()

        table = Table (parser.defines)
        table.filename = self.args.infile

        if self.args.backend == None:
            backend = DefaultBackend ()
        else:
            backend = self.backends [self.args.backend]
        if self.args.outfile != None:
            output = open (self.args.outfile, "w")
        else:
            output = sys.stdout
        try:
            backend.generate (table, self.props, output)
        except:
            os.remove (self.args.outfile)
            raise
        if output != sys.stdout:
            output.close ()

    # For testing
    def parse(self, input_str):
        f = io.StringIO (unicode (input_str))

        lexer = Lexer(f)
        global current_lexer
        current_lexer = lexer

        parser = Parser(lexer)
        parser.run ()

        table = Table (parser.defines)
        return table
