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

	private NodeVar parseVar() {
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
		expect(
			TokenKind.Primitive, TokenKind.Identifier,
			"Expected a primitive type or identifier.",
			"Ensure that this is a valid identifier or primitive type."
		);
		NodeType type = new NodeType(curr());
		idx++;
		if (curr().isKind(TokenKind.Equ)) {
			idx++;
			NodeExpression expr = parseExpression(true);
			return new NodeVar(ident, type, expr);
		}
		expect(
			TokenKind.Semicolon,
			"Expected a semicolon.",
			"Semicolons delimit lines."
		);
		idx++;
		return new NodeVar(ident, type);
	}

	private NodeExpression parseExpression(bool semicolon = false) {
		NodeExpression expr;
		switch (curr().kind) {
			case TokenKind.Nil: {
				expr = new NodeNil(curr());
				idx++;
				break;
			}
			default: {
				Message msg = new Message(
					MessageKind.Error,
					"Expected a valid expression.",
					"Valid expressions are numbers, operations, or nil.",
					curr()
				);
				msg.display(gCtx);
				break;
			}
		}
		if (semicolon) {
			expect(
				TokenKind.Semicolon,
				"Expected a semicolon.",
				"Lines delimit with semicolons."
			);
			idx++;
		}
		return expr;
	}

	private NodeStatement parseStatement() {
		NodeStatement statement;
		switch (curr().kind) {
			case TokenKind.Var: {
				statement = parseVar();
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