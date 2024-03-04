module lexer;

import std.ascii;
import error;
import context;

enum TokenKind {
	// Special
	EOF,
	Err,
	Identifier,
	Integer, Float, Bool,
	Primitive,
	String,
	// Keywords
	Def, Var, Const,
	If, Else,
	While, For,
	Return,
	Nil,
	Pointer,
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

	bool isKind(TokenKind kind) {
		return this.kind == kind;
	}
	bool isKind(TokenKind[] kinds...) {
		foreach (kind; kinds) {
			if (kind == this.kind) return true;
		}
		return false;
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
	bool isChar(char[] chs...) {
		foreach (ch; chs) {
			if (currChar() == ch) return true;
		}
		return false;
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
		|| ctx.isChar(
			'_', '-', '@', '&',
			'|', '?', '!', '\'',
			'`'
		)
	) {
		tmp ~= ctx.currChar();
		ctx.inc();
	}
	switch (tmp) {
		case "void", "u8", "i8", "i32", "u32", "f32", "bool":
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
		case "nil":
			tok = Token(TokenKind.Nil, tmp, line, col);
			break;
		case "ptr":
			tok = Token(TokenKind.Pointer, tmp, line, col);
			break;
		default:
			tok = Token(TokenKind.Identifier, tmp, line, col);
			break;
	}
	return tok;
}

private Token doNum(ref Context ctx) {
	string tmp;
	ulong line = ctx.line;
	ulong col = ctx.col;
	bool isFloat = false;
	while (isDigit(ctx.currChar())) {
		tmp ~= ctx.currChar();
		ctx.inc();
	}
	if (ctx.isChar('.')) {
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

private Token doOther(ref Context ctx, ref GlobalContext gCtx) {
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
		case ",":
			tok = Token(TokenKind.Comma, tmp, line, col);
			break;
		case "=":
			if (ctx.isChar('=')) {
				tmp ~= ctx.currChar();
				ctx.inc();
				tok = Token(TokenKind.DEqu, tmp, line, col);
				break;
			}
			tok = Token(TokenKind.Equ, tmp, line, col);
			break;
		default: {
			tok = Token(TokenKind.Err, tmp, line, col);
			Message msg = new Message(MessageKind.Error, "Invalid token.", tok);
			msg.display(gCtx);
			break;
		}
	}
	return tok;
}

private Token doString(ref Context ctx) {
	ulong line = ctx.line;
	ulong col = ctx.col;
	string tmp;
	tmp ~= ctx.currChar();
	ctx.inc();
	while (!ctx.isChar('"', '\n', '\r')) {
		if (ctx.isChar('\\')) {
			tmp ~= ctx.currChar();
			ctx.inc();
			if (ctx.isChar(
				'\\', '"', 'n', 'r', 't', 'b', 'v', 'a'
			)) {
				tmp ~= ctx.currChar();
			}
		}
		else {
			tmp ~= ctx.currChar();
		}
		ctx.inc();
	}
	tmp ~= ctx.currChar();
	ctx.inc();
	return Token(TokenKind.String, tmp, line, col);
}

Token[] tokenize(ref GlobalContext gCtx) {
	Context ctx = Context(gCtx.file);
	Token[] res;

	while (ctx.idx < gCtx.file.length) {
		if (isWhite(ctx.currChar())) {
			doWhite(ctx);
		}
		else if (ctx.isChar('"')) {
			res ~= doString(ctx);
		}
		else if (isAlpha(ctx.currChar()) || ctx.isChar('_')) {
			res ~= doIdent(ctx);
		}
		else if (isDigit(ctx.currChar())) {
			res ~= doNum(ctx);
		}
		else {
			res ~= doOther(ctx, gCtx);
		}
	}
	res ~= Token(TokenKind.EOF, "EOF", ctx.line, ctx.col);
	return res;
}