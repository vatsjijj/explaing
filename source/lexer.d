module lexer;

import std.ascii;

enum TokenKind {
	// Special
	EOF,
	Identifier,
	Integer, Float, Bool,
	Primitive,
	// Keywords
	Def, Var, Const,
	If, Else,
	While, For,
	Return,
	// Binops
	Mod, FSlash, Star,
	Plus, Dash,
	Equ, DEqu,
	// Symbols
	LParen, RParen,
	LBrace, RBrace,
	LBrack, RBrack,
	Semicolon, Colon,
	Comma,
}

struct Token {
	TokenKind kind;
	string content;
	ulong line, col, len;

	this(TokenKind kind, string content, ulong line, ulong col) {
		this.kind = kind;
		this.content = content;
		this.line = line;
		this.col = col;
		this.len = content.length;
	}

	string toString() const @safe pure {
		import std.conv : to;
		string tmp;
		tmp ~= to!string(kind) ~ " ";
		tmp ~= content ~ " ";
		tmp ~= "(" ~ to!string(line) ~ ":" ~ to!string(col) ~ ") ";
		tmp ~= to!string(len);
		return tmp;
	}
}

private struct Context {
	string file;
	ulong line = 1;
	ulong col = 1;
	ulong idx = 0;

	this(ref string file) {
		this.file = file;
	}

	char currChar() {
		return file[idx];
	}

	void inc() {
		idx++;
		col++;
	}

	bool isChar(char ch) {
		return currChar() == ch;
	}

	char peek(ulong amt = 1) {
		return file[idx + amt];
	}
}

private void doWhite(ref Context ctx) {
	while (isWhite(ctx.currChar())) {
		if (ctx.currChar() == '\n') {
			ctx.line++;
			ctx.col = 1;
		}
		else {
			ctx.col++;
		}
		ctx.idx++;
	}
}

private Token doIdent(ref Context ctx) {
	Token tok;
	string tmp;
	ulong line = ctx.line;
	ulong col = ctx.col;
	while (
		isAlphaNum(ctx.currChar())
		|| ctx.isChar('_')
		|| ctx.isChar('-')
		|| ctx.isChar('@')
		|| ctx.isChar('&')
		|| ctx.isChar('|')
		|| ctx.isChar('?')
		|| ctx.isChar('!') 
		|| ctx.isChar('\'')
	) {
		tmp ~= ctx.currChar();
		ctx.inc();
	}
	switch (tmp) {
		case "void", "i32", "u32", "bool":
			tok = Token(TokenKind.Primitive, tmp, line, col);
			break;
		case "if":
			tok = Token(TokenKind.If, tmp, line, col);
			break;
		case "else":
			tok = Token(TokenKind.Else, tmp, line, col);
			break;
		case "while":
			tok = Token(TokenKind.While, tmp, line, col);
			break;
		case "for":
			tok = Token(TokenKind.For, tmp, line, col);
			break;
		case "def":
			tok = Token(TokenKind.Def, tmp, line, col);
			break;
		case "return":
			tok = Token(TokenKind.Return, tmp, line, col);
			break;
		case "var":
			tok = Token(TokenKind.Var, tmp, line, col);
			break;
		case "const":
			tok = Token(TokenKind.Const, tmp, line, col);
			break;
		case "true", "false":
			tok = Token(TokenKind.Bool, tmp, line, col);
			break;
		default:
			tok = Token(TokenKind.Identifier, tmp, line, col);
			break;
	}
	return tok;
}

private Token doNum(ref Context ctx) {
	Token tok;
	string tmp;
	ulong line = ctx.line;
	ulong col = ctx.col;
	bool isFloat = false;
	while (isDigit(ctx.currChar())) {
		tmp ~= ctx.currChar();
		ctx.inc();
	}
	if (ctx.currChar() == '.') {
		isFloat = true;
		tmp ~= ctx.currChar();
		ctx.inc();
		while (isDigit(ctx.currChar())) {
			tmp ~= ctx.currChar();
			ctx.inc();
		}
	}
	if (isFloat) {
		return Token(TokenKind.Float, tmp, line, col);
	}
	return Token(TokenKind.Integer, tmp, line, col);
}

private Token doOther(ref Context ctx) {
	Token tok;
	string tmp;
	ulong line = ctx.line;
	ulong col = ctx.col;
	tmp ~= ctx.currChar();
	ctx.inc();
	switch (tmp) {
		case "(":
			tok = Token(TokenKind.LParen, tmp, line, col);
			break;
		case ")":
			tok = Token(TokenKind.RParen, tmp, line, col);
			break;
		case "[":
			tok = Token(TokenKind.LBrack, tmp, line, col);
			break;
		case "]":
			tok = Token(TokenKind.RBrack, tmp, line, col);
			break;
		case "{":
			tok = Token(TokenKind.LBrace, tmp, line, col);
			break;
		case "}":
			tok = Token(TokenKind.RBrace, tmp, line, col);
			break;
		case ";":
			tok = Token(TokenKind.Semicolon, tmp, line, col);
			break;
		case ":":
			tok = Token(TokenKind.Colon, tmp, line, col);
			break;
		case "+":
			tok = Token(TokenKind.Plus, tmp, line, col);
			break;
		case "-":
			tok = Token(TokenKind.Dash, tmp, line, col);
			break;
		case "/":
			tok = Token(TokenKind.FSlash, tmp, line, col);
			break;
		case "*":
			tok = Token(TokenKind.Star, tmp, line, col);
			break;
		case "%":
			tok = Token(TokenKind.Mod, tmp, line, col);
			break;
		case "=":
			if (ctx.currChar() == '=') {
				tmp ~= ctx.currChar();
				ctx.inc();
				tok = Token(TokenKind.DEqu, tmp, line, col);
				break;
			}
			tok = Token(TokenKind.Equ, tmp, line, col);
			break;
		default: {
			import std.stdio;
			stderr.writeln("TODO: OP ERR!");
			break;
		}
	}
	return tok;
}

Token[] tokenize(ref string file) {
	Context ctx = Context(file);
	Token[] res;

	while (ctx.idx < file.length) {
		if (isWhite(ctx.currChar())) {
			doWhite(ctx);
		}
		else if (isAlpha(ctx.currChar()) || ctx.currChar() == '_') {
			res ~= doIdent(ctx);
		}
		else if (isDigit(ctx.currChar())) {
			res ~= doNum(ctx);
		}
		else {
			res ~= doOther(ctx);
		}
	}
	return res;
}