package gluon

import "core:fmt"

Token_Kind :: enum {
	// Special chars
	Illegal,
	EOF,

	// Literals
	Identifier,
	Integer,

	// Operators
	Assign,
	Plus,
	Minus,
	Star,
	Slash,

	// Bool operators
	Equal,
	BangEqual,
	Less,
	Greater,

	// Delimiters
	Comma,
	Semicolon,

	// Scopes
	Open_Paren,
	Close_Paren,
	Open_Brace,
	Close_Brace,

	// Keywords
	Function,
	Let,
	True,
	False,
	If,
	Else,
	Return,
	And,
	Or,
	Not,
}

Token :: struct {
	kind:    Token_Kind,
	literal: string,
}

lex :: proc(input: string) -> []Token {
	tokens := make([dynamic]Token, 0, 6)

	lexer := make_lexer(input)

	for {
		token, ok := next_token(&lexer)
		append(&tokens, token)
		if !ok {break}
	}

	return tokens[:]
}

@(private = "file")
Lexer :: struct {
	input:         string,
	position:      uint,
	read_position: uint,
	char:          u8,
}

builtin := map[string]Token_Kind {
	"fn"     = .Function,
	"let"    = .Let,
	"true"   = .True,
	"false"  = .False,
	"if"     = .If,
	"else"   = .Else,
	"return" = .Return,
	"and"    = .And,
	"or"     = .Or,
	"not"    = .Not,
}

next_token :: proc(lexer: ^Lexer) -> (Token, bool) {
	token: Token

	skip_whitespace(lexer)

	switch lexer.char {
	case '=':
		if peek_char(lexer) == '=' {
			token = Token{.Equal, ""}
			read_char(lexer)
		} else {
			token = Token{.Assign, ""}
		}
	case '+':
		token = Token{.Plus, ""}
	case '-':
		token = Token{.Minus, ""}
	case '*':
		token = Token{.Star, ""}
	case '/':
		if peek_char(lexer) == '/' {
			// TODO: Comment
			read_char(lexer)
		} else {
			token = Token{.Slash, ""}
		}
	case '!':
		if peek_char(lexer) == '=' {
			token = Token{.BangEqual, ""}
			read_char(lexer)
		} // else invalid
	case '<':
		token = Token{.Less, ""}
	case '>':
		token = Token{.Greater, ""}
	case ',':
		token = Token{.Comma, ""}
	case ';':
		token = Token{.Semicolon, ""}
	case '(':
		token = Token{.Open_Paren, ""}
	case ')':
		token = Token{.Close_Paren, ""}
	case '{':
		token = Token{.Open_Brace, ""}
	case '}':
		token = Token{.Close_Brace, ""}

	case 'a' ..= 'z', 'A' ..= 'Z', '_':
		start := lexer.position
		for is_alphanum(lexer.char) || lexer.char == '_' {
			read_char(lexer)
		}
		end := lexer.position

		identifier := lexer.input[start:end]

		if kind, found := builtin[identifier]; found {
			token = Token{kind, ""}
		} else {
			token = Token{.Identifier, identifier}
		}

		// Necessary to early return, we do not want to consume the next char after the switch
		return token, true

	case '0' ..= '9':
		start := lexer.position
		for is_digit(lexer.char) {
			read_char(lexer)
		}
		end := lexer.position

		token = Token{.Integer, lexer.input[start:end]}

		// Necessary to early return, we do not want to consume the next char after the switch
		return token, true

	case 0:
		token = Token{.EOF, ""}
	}

	read_char(lexer)

	return token, token.kind != .EOF
}

skip_whitespace :: proc(lexer: ^Lexer) {
	for is_whitespace(lexer.char) {
		read_char(lexer)
	}
}

is_whitespace :: proc(c: u8) -> bool {
	return c == ' ' || c == '\t' || c == '\b' || c == '\n' || c == '\r'
}

is_alpha :: proc(input: u8) -> bool {
	result := input >= 'a' && input <= 'z' || input >= 'A' && input <= 'Z'
	return result
}

is_digit :: proc(input: u8) -> bool {
	result := input >= '0' && input <= '9'
	return result
}

is_alphanum :: proc(input: u8) -> bool {
	result := is_alpha(input) || is_digit(input)
	return result
}

make_lexer :: proc(input: string) -> Lexer {
	lexer := Lexer{input, 0, 0, 0}
	read_char(&lexer)
	return lexer
}

read_char :: proc(lexer: ^Lexer) {
	if lexer.read_position >= len(lexer.input) {
		lexer.char = 0
	} else {
		lexer.char = lexer.input[lexer.read_position]
	}

	lexer.position = lexer.read_position
	lexer.read_position += 1
}

peek_char :: proc(lexer: ^Lexer) -> u8 {
	if lexer.read_position >= len(lexer.input) {
		return 0
	}

	return lexer.input[lexer.read_position]
}
