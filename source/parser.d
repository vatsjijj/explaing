module parser;

import lexer;
import ast;
import context;
import error;

// Policy is to increment at the start of the parsing function.
final class Parser {
	private GlobalContext gCtx;
	private NodeProgram program;
	private ulong idx;

	this(ref GlobalContext gCtx) {
		this.gCtx = gCtx;
		this.program = new NodeProgram();
		this.idx = 0;
	}

	private ref Token curr() {
		return gCtx.toks[idx];
	}

	private ref Token peek(ulong amt = 1) {
		return gCtx.toks[idx + amt];
	}

	/**
	 * Checks the peeked token's kind, if it does not match
	 * then it will print an error and (hopefully) exit.
	 */
	private void expect(TokenKind kind, string msg, ulong amt = 0) {
		if (!peek(amt).isKind(kind)) {
			Message tmp = new Message(
				MessageKind.Error,
				msg,
				peek(amt)
			);
			tmp.display(gCtx);
			return;
		}
	}
	private void expect(TokenKind kind, string msg, string note, ulong amt = 0) {
		if (!peek(amt).isKind(kind)) {
			Message tmp = new Message(
				MessageKind.Error,
				msg,
				note,
				peek(amt)
			);
			tmp.display(gCtx);
			return;
		}
	}
	private void expect(TokenKind kind1, TokenKind kind2, string msg, ulong amt = 0) {
		if (!peek(amt).isKind(kind1) && !peek(amt).isKind(kind2)) {
			Message tmp = new Message(
				MessageKind.Error,
				msg,
				peek(amt)
			);
			tmp.display(gCtx);
			return;
		}
	}
	private void expect(TokenKind kind1, TokenKind kind2, string msg, string note, ulong amt = 0) {
		if (!peek(amt).isKind(kind1) && !peek(amt).isKind(kind2)) {
			Message tmp = new Message(
				MessageKind.Error,
				msg,
				note,
				peek(amt)
			);
			tmp.display(gCtx);
			return;
		}
	}
	private void expect(string msg, ulong amt, TokenKind[] kinds...) {
		foreach (kind; kinds) {
			if (peek(amt).isKind(kind)) return;
		}
		Message tmp = new Message(
			MessageKind.Error,
			msg,
			peek(amt)
		);
		tmp.display(gCtx);
	}
	private void expect(string msg, string note, ulong amt, TokenKind[] kinds...) {
		foreach (kind; kinds) {
			if (peek(amt).isKind(kind)) return;
		}
		Message tmp = new Message(
			MessageKind.Error,
			msg,
			note,
			peek(amt)
		);
		tmp.display(gCtx);
	}

	private NodeVar parseVar(Visibility vis) {
		idx++;
		expect(
			TokenKind.Identifier,
			"Expected an identifier.",
			"Identifiers start with a letter or an underscore."
		);
		NodeIdentifier ident = new NodeIdentifier(curr());
		idx++;
		expect(
			TokenKind.Colon,
			"Expected a colon.",
			"Colons are required for definitions."
		);
		idx++;
		NodeType type = parseType();
		if (curr().isKind(TokenKind.Equ)) {
			idx++;
			NodeExpression expr = parseExpression(true);
			return new NodeVar(ident, type, expr, vis);
		}
		expect(
			TokenKind.Semicolon,
			"Expected a semicolon.",
			"Semicolons delimit lines."
		);
		idx++;
		return new NodeVar(ident, type, vis);
	}

	private NodeConst parseConstant(Visibility vis) {
		idx++;
		expect(
			TokenKind.Identifier,
			"Expected an identifier.",
			"Identifiers start with a letter or an underscore."
		);
		NodeIdentifier ident = new NodeIdentifier(curr());
		idx++;
		expect(
			TokenKind.Colon,
			"Expected a colon.",
			"Colons are required for definitions."
		);
		idx++;
		NodeType type = parseType();
		if (curr().isKind(TokenKind.Equ)) {
			idx++;
			NodeExpression expr = parseExpression(true);
			return new NodeConst(ident, type, expr, vis);
		}
		expect(
			TokenKind.Semicolon,
			"Expected a semicolon.",
			"Semicolons delimit lines."
		);
		idx++;
		return new NodeConst(ident, type, vis);
	}

	private NodeExprList parseExprList() {
		NodeExpression[] exprs;
		expect(
			TokenKind.LParen,
			"Expected a left parenthese."
		);
		idx++;
		if (curr().isKind(TokenKind.RParen)) {
			idx++;
			return new NodeExprList();
		}
		exprs ~= parseExpression();
		while (curr().isKind(TokenKind.Comma)) {
			idx++;
			exprs ~= parseExpression();
		}
		expect(
			TokenKind.RParen,
			"Expected a right parenthese."
		);
		idx++;
		return new NodeExprList(exprs);
	}

	private NodeCall parseCall() {
		Token ident = curr();
		idx++;
		NodeExprList args = parseExprList();
		return new NodeCall(ident, args);
	}

	private NodeType parseType() {
		Token[] type;
		switch (curr().kind) {
			case TokenKind.Const:
				type ~= curr();
				idx++;
				break;
			default: break;
		}
		expect(
			TokenKind.Primitive, TokenKind.Identifier,
			"Expected a type."
		);
		type ~= curr();
		idx++;
		while (curr().isKind(
			TokenKind.Pointer,
			TokenKind.LBrack, TokenKind.RBrack
		)) {
			type ~= curr();
			idx++;
		}
		return new NodeType(type);
	}

	private NodeExpression parseExpression(bool semicolon = false) {
		NodeExpression lhs, rhs;
		Token op;
		bool binop = false;
		switch (curr().kind) {
			case TokenKind.This: {
				lhs = new NodeThis(curr());
				idx++;
				break;
			}
			case TokenKind.Nil: {
				lhs = new NodeNil(curr());
				idx++;
				break;
			}
			case TokenKind.Integer, TokenKind.Float: {
				lhs = new NodeNumber(curr());
				idx++;
				break;
			}
			case TokenKind.Bool: {
				lhs = new NodeBool(curr());
				idx++;
				break;
			}
			case TokenKind.Identifier: {
				if (peek().isKind(TokenKind.LParen)) {
					lhs = parseCall();
					break;
				}
				lhs = new NodeIdentifier(curr());
				idx++;
				break;
			}
			case TokenKind.Super: {
				Token tok = curr();
				idx++;
				NodeExprList args = parseExprList();
				lhs = new NodeSuper(tok, args);
				break;
			}
			case TokenKind.String: {
				lhs = new NodeString(curr());
				idx++;
				break;
			}
			default: {
				Message msg = new Message(
					MessageKind.Error,
					"Expected a valid expression.",
					"Valid expressions are numbers, operations, strings, or nil.",
					curr()
				);
				msg.display(gCtx);
				break;
			}
		}
		if (curr().isKind(
			TokenKind.Plus, TokenKind.Dash,
			TokenKind.Star, TokenKind.FSlash,
			TokenKind.Mod, TokenKind.DEqu,
			TokenKind.Dot, TokenKind.Equ
		)) {
			op = curr();
			idx++;
			rhs = parseExpression();
			binop = true;
		}
		if (semicolon) {
			expect(
				TokenKind.Semicolon,
				"Expected a semicolon.",
				"Lines delimit with semicolons."
			);
			idx++;
		}
		return binop ? new NodeBinOp(lhs, op, rhs) : lhs;
	}

	// TODO: Add notes!
	private NodeArg parseArg() {
		expect(
			TokenKind.Identifier,
			"Expected an identifier."
		);
		NodeIdentifier ident = new NodeIdentifier(curr());
		idx++;
		expect(
			TokenKind.Colon,
			"Expected a colon."
		);
		idx++;
		NodeType type = parseType();
		return new NodeArg(ident, type);
	}

	// TODO: Add notes!
	private NodeArgList parseArgList() {
		NodeArg[] args;
		expect(
			TokenKind.LParen,
			"Expected a left parenthese."
		);
		idx++;
		if (curr().isKind(TokenKind.RParen)) {
			idx++;
			return new NodeArgList();
		}
		args ~= parseArg();
		while (curr().isKind(TokenKind.Comma)) {
			idx++;
			args ~= parseArg();
		}
		expect(
			TokenKind.RParen,
			"Expected a right parenthese."
		);
		idx++;
		return new NodeArgList(args);
	}

	private NodeReturn parseReturn() {
		idx++;
		NodeExpression expr = parseExpression(true);
		return new NodeReturn(expr);
	}

	// TODO: Add notes!
	private NodeBlock parseBlock() {
		Node[] children;
		expect(
			TokenKind.LBrace,
			"Expected a left brace."
		);
		idx++;
		while (!curr().isKind(TokenKind.RBrace)) {
			switch (curr().kind) {
				case TokenKind.Var, TokenKind.Const, TokenKind.Def:
					children ~= parseStatement();
					break;
				case TokenKind.Class, TokenKind.Struct, TokenKind.Union:
					children ~= parseStatement();
					break;
				case TokenKind.Private, TokenKind.Protected, TokenKind.Public:
					children ~= parseStatement();
					break;
				case TokenKind.Return:
					children ~= parseReturn();
					break;
				default:
					children ~= parseExpression(true);
					break;
			}
		}
		idx++;
		return new NodeBlock(children);
	}

	// TODO: Add notes!
	private NodeFunction parseFunction(Visibility vis) {
		idx++;
		expect(
			TokenKind.Identifier,
			"Expected an identifier.",
			"Ensure a valid identifier is after `def`."
		);
		NodeIdentifier ident = new NodeIdentifier(curr());
		idx++;
		NodeArgList args = parseArgList();
		expect(
			TokenKind.Colon,
			"Expected a colon."
		);
		idx++;
		NodeType type = parseType();
		NodeBlock block = parseBlock();
		return new NodeFunction(ident, type, args, block, vis);
	}

	// TODO: Add notes.
	private NodeClass parseClass(Visibility vis) {
		idx++;
		expect(
			TokenKind.Identifier,
			"Expected an identifier."
		);
		NodeIdentifier ident = new NodeIdentifier(curr());
		idx++;
		NodeBlock block = parseBlock();
		return new NodeClass(ident, block, vis);
	}

	// TODO: Add notes.
	private NodeStruct parseStruct(Visibility vis) {
		idx++;
		expect(
			TokenKind.Identifier,
			"Expected an identifier."
		);
		NodeIdentifier ident = new NodeIdentifier(curr());
		idx++;
		NodeBlock block = parseBlock();
		return new NodeStruct(ident, block, vis);
	}

	// TODO: Add notes.
	private NodeUnion parseUnion(Visibility vis) {
		idx++;
		expect(
			TokenKind.Identifier,
			"Expected an identifier."
		);
		NodeIdentifier ident = new NodeIdentifier(curr());
		idx++;
		NodeBlock block = parseBlock();
		return new NodeUnion(ident, block, vis);
	}

	private NodeStatement parseStatement() {
		NodeStatement statement;
		Visibility vis = Visibility.Protected;
		switch (curr().kind) {
			case TokenKind.Private:
				vis = Visibility.Private;
				idx++;
				break;
			case TokenKind.Protected:
				idx++;
				break;
			case TokenKind.Public:
				vis = Visibility.Public;
				idx++;
				break;
			default: break;
		}
		switch (curr().kind) {
			case TokenKind.Var: {
				statement = parseVar(vis);
				break;
			}
			case TokenKind.Const: {
				statement = parseConstant(vis);
				break;
			}
			case TokenKind.Def: {
				statement = parseFunction(vis);
				break;
			}
			case TokenKind.Class: {
				statement = parseClass(vis);
				break;
			}
			case TokenKind.Struct: {
				statement = parseStruct(vis);
				break;
			}
			case TokenKind.Union: {
				break;
			}
			// Error!
			default: {
				Message msg = new Message(
					MessageKind.Error,
					"Expected a statement.",
					"Did you intend to define a function, variable, or constant?",
					curr()
				);
				msg.display(gCtx);
				break;
			}
		}
		return statement;
	}

	NodeProgram parse() {
		while (!curr().isKind(TokenKind.EOF)) {
			program.append(parseStatement());
		}
		return program;
	}
}