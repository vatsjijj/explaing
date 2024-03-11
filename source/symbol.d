module symbol;

import std.stdio;
import core.stdc.stdlib : exit;
import parser;
import error;
import ast;
import context;

private alias VarTable   = NodeVar[string];
private alias ConstTable = NodeConst[string];
private alias FuncTable  = NodeFunction[string];
private alias TypeTable  = NodeType[string];

struct Scope {
	VarTable vars;
	ConstTable consts;
	FuncTable funcs;
	TypeTable types;

	bool exists(string key) {
		return key in vars || key in consts || key in funcs || key in types;
	}
	bool exists(ref NodeVar var) {
		return (var.getIdent().getTok().content in vars) !is null;
	}

	ubyte where(string key) {
		if (key in vars)   return 0;
		if (key in consts) return 1;
		if (key in funcs)  return 2;
		if (key in types)  return 3;
		return 255;
	}

	void check(NodeVar var, GlobalContext gCtx) {
		if (!exists(var)) {
			return;
		}
		Message msg = new Message(
			MessageKind.Error,
			"Symbol has been previously defined.",
			"Make sure there isn't another symbol of the same name.",
			var.getIdent().getTok()
		);
		msg.display(gCtx);
	}

	void set(NodeVar var) {
		vars[var.getIdent().getTok().content] = var;
	}
}

class Resolver {
	private GlobalContext gCtx;
	private NodeProgram prog;
	private Scope globalScope;
	private Scope[NodeBlock] scopes;
	private NodeBlock[] blocks;

	this(ref GlobalContext gCtx, ref NodeProgram prog) {
		this.gCtx = gCtx;
		this.prog = prog;
	}

	private bool inGlobalScope() {
		return blocks.length == 0;
	}

	private bool exists(string key) {
		if (inGlobalScope()) {
			return globalScope.exists(key);
		}
		for (ulong i = long(blocks.length) - 1; i >= 0; --i) {
			if (scopes[blocks[i]].exists(key)) return true;
		}
		return false;
	}
	private bool exists(ref NodeVar var) {
		if (inGlobalScope()) {
			return globalScope.exists(var);
		}
		for (ulong i = long(blocks.length) - 1; i >= 0; --i) {
			if (scopes[blocks[i]].exists(var)) return true;
		}
		return false;
	}

	private ubyte where(string key) {
		if (inGlobalScope()) {
			return globalScope.where(key);
		}
		for (ulong i = long(blocks.length) - 1; i >= 0; --i) {
			ubyte at = scopes[blocks[i]].where(key);
			if (at != 255) return at;
		}
		return 255;
	}

	void checkShadowed(ref NodeVar var) {
		if (!exists(var)) {
			return;
		}
		Message msg = new Message(
			MessageKind.Notice,
			"Symbol is shadowing a previously defined symbol.",
			var.getIdent().getTok()
		);
		msg.display(gCtx);
	}

	private void resolveVar(NodeVar var) {
		if (inGlobalScope()) {
			globalScope.check(var, gCtx);
			globalScope.set(var);
			return;
		}
		scopes[blocks[$ - 1]].check(var, gCtx);
		scopes[blocks[$ - 1]].set(var);
	}

	private void resolveProgram() {
		foreach (statement; prog.getChildren()) {
			switch (statement.getKind()) {
				case StatementKind.Var:
					resolveVar(cast(NodeVar)statement);
					break;
				case StatementKind.EOF: break;
				default: {
					stderr.writeln("Compiler error in " ~ gCtx.filename ~ ":");
					stderr.writeln("   You're not supposed to be seeing this message.");
					stderr.writeln("   This is a COMPILER BUG! File a PR on GitHub or contact me about this.");
					stderr.writeln("   Please include the code you were trying to run with the report.");
					exit(127);
					break;
				}
			}
		}
	}

	ref Scope[NodeBlock] getScopes() {
		return this.scopes;
	}

	ref Scope getGlobalScope() {
		return this.globalScope;
	}

	void resolve() {
		if (prog.isEmpty()) {
			Message msg = new Message(
				MessageKind.Warning,
				"Module is completely empty.",
				"Did you want to define anything in this module?",
				(cast(NodeEOF)prog.getChildren()[0]).getTok()
			);
			msg.display(gCtx);
			return;
		}
		resolveProgram();
	}
}