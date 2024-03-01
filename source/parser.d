module parser;

import lexer;
import ast;
import context;
import error;

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

	private NodeStatement parseStatement() {
		NodeStatement statement;
		switch (curr().kind) {
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