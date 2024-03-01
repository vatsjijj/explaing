module parser;

import lexer;
import ast;
import context;
import error;

final class Parser {
	private GlobalContext gCtx;
	private NodeProgram program;

	this(ref GlobalContext gCtx) {
		this.gCtx = gCtx;
		this.program = new NodeProgram();
	}
}