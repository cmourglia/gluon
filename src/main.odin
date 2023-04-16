package gluon

import "core:fmt"
import "core:testing"

Entry :: struct {
	kind: Token_Kind,
	str:  string,
}

@(test)
test_lexer1 :: proc(t: ^testing.T) {
	tokens := lex("=+(){},;")
	defer delete(tokens)

	expected_tokens := [?]Entry {
		// let five = 5;
		{.Assign, ""},
		{.Plus, ""},
		{.Open_Paren, ""},
		{.Close_Paren, ""},
		{.Open_Brace, ""},
		{.Close_Brace, ""},
		{.Comma, ""},
		{.Semicolon, ""},
		{.EOF, ""},
	}

	testing.expect_value(t, len(tokens), len(expected_tokens))

	for token, i in tokens {
		testing.expect_value(t, tokens[i].kind, expected_tokens[i].kind)
		testing.expect_value(t, tokens[i].literal, expected_tokens[i].str)
	}
}

@(test)
test_lexer2 :: proc(t: ^testing.T) {
	tokens := lex(
		`let five = 5;
        let ten = 10;

        let add = fn(x, y) {
            x + y;
        };

        let result = add(five, ten)
		;



		+/*-<10>5;== not !=;

		if a == 2 {
			let b = 3;
		} else {
			return true and false or not false;
		}
    `,
	)
	defer delete(tokens)

	expected_tokens := [?]Entry {
		// let five = 5;
		{.Let, ""},
		{.Identifier, "five"},
		{.Assign, ""},
		{.Integer, "5"},
		{.Semicolon, ""},

		// let ten = 10;
		{.Let, ""},
		{.Identifier, "ten"},
		{.Assign, ""},
		{.Integer, "10"},
		{.Semicolon, ""},

		// let add = fn(x, y) { x + y; };
		{.Let, ""},
		{.Identifier, "add"},
		{.Assign, ""},
		{.Function, ""},
		{.Open_Paren, ""},
		{.Identifier, "x"},
		{.Comma, ""},
		{.Identifier, "y"},
		{.Close_Paren, ""},
		{.Open_Brace, ""},
		{.Identifier, "x"},
		{.Plus, ""},
		{.Identifier, "y"},
		{.Semicolon, ""},
		{.Close_Brace, ""},
		{.Semicolon, ""},

		// let result = add(five, ten);
		{.Let, ""},
		{.Identifier, "result"},
		{.Assign, ""},
		{.Identifier, "add"},
		{.Open_Paren, ""},
		{.Identifier, "five"},
		{.Comma, ""},
		{.Identifier, "ten"},
		{.Close_Paren, ""},
		{.Semicolon, ""},

		// +/*-<10>5;== not !=;
		{.Plus, ""},
		{.Slash, ""},
		{.Star, ""},
		{.Minus, ""},
		{.Less, ""},
		{.Integer, "10"},
		{.Greater, ""},
		{.Integer, "5"},
		{.Semicolon, ""},
		{.Equal, ""},
		{.Not, ""},
		{.BangEqual, ""},
		{.Semicolon, ""},

		// if a == 2 {
		{.If, ""},
		{.Identifier, "a"},
		{.Equal, ""},
		{.Integer, "2"},
		{.Open_Brace, ""},
		// let b = 3;
		{.Let, ""},
		{.Identifier, "b"},
		{.Assign, ""},
		{.Integer, "3"},
		{.Semicolon, ""},
		// } else {
		{.Close_Brace, ""},
		{.Else, ""},
		{.Open_Brace, ""},
		// return true and false or not false;
		{.Return, ""},
		{.True, ""},
		{.And, ""},
		{.False, ""},
		{.Or, ""},
		{.Not, ""},
		{.False, ""},
		{.Semicolon, ""},
		// }
		{.Close_Brace, ""},

		// EOF
		{.EOF, ""},
	}

	testing.expect_value(t, len(tokens), len(expected_tokens))

	for token, i in tokens {
		testing.expect_value(t, tokens[i].kind, expected_tokens[i].kind)
		testing.expect_value(t, tokens[i].literal, expected_tokens[i].str)
	}
}

test_parser1 :: proc(t: ^testing.T) {

}

main :: proc() {
}
