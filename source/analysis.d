module analysis;

import std.algorithm.sorting;
import symbol;
import parser;
import lexer;
import context;
import ast;
import error;

class Analyzer {
	private GlobalContext gCtx;
	private Resolver resolver;

	this(ref GlobalContext gCtx, ref Resolver resolver) {
		this.gCtx = gCtx;
		this.resolver = resolver;
	}

	private Message unused(ref NodeVar var) {
		if (!var.isUsed()) {
			Message msg = new Message(
				MessageKind.Warning,
				"Variable is unused.",
				"Consider removing this variable.",
				var.getIdent().getTok()
			);
			return msg;
		}
		return null;
	}
	private Message unused(ref NodeConst cnst) {
		if (!cnst.isUsed()) {
			Message msg = new Message(
				MessageKind.Warning,
				"Constant is unused.",
				"Consider removing this constant.",
				cnst.getIdent().getTok()
			);
			return msg;
		}
		return null;
	}

	private Message[] checkScopeVars(ref Scope scp) {
		Message[] tmpArr;
		foreach (var; scp.vars) {
			auto tmp = unused(var);
			if (tmp !is null) tmpArr ~= tmp;
		}
		return tmpArr;
	}

	private void checkGlobalScope() {
		Message[] unused = checkScopeVars(resolver.getGlobalScope());
		if (unused.length > 1) unused.sort!(
			(Message x, Message y) => x.getLine() < y.getLine()
		);
		foreach(msg; unused) {
			msg.display(gCtx);
		}
	}

	private void checkOtherScope() {
		Message[][] msgs;
		foreach (scpe; resolver.getScopes()) {
			msgs ~= checkScopeVars(scpe);
		}
		foreach (arr; msgs) {
			if (arr.length > 1) arr.sort!(
				(Message x, Message y) => x.getLine() < y.getLine()
			);
		}
		foreach (i; msgs) {
			foreach (j; i) {
				j.display(gCtx);
			}
		}
	}

	void analyze() {
		checkGlobalScope();
		checkOtherScope();
	}
}