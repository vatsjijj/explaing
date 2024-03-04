module ast;

import lexer;

enum NodeKind {
	Program,
	Statement,
	Expression,
}

enum StatementKind {
	Function,
	ArgList,
	Arg,
	Block,
	Return,
	Var,
	Const,
	If,
	ElseIf,
	Else,
	While,
	For,
}

enum ExpressionKind {
	Number,
	Identifier,
	BinOp,
	Type,
	Bool,
	Nil,
}

abstract class Node {
	private NodeKind kind;

	this(NodeKind kind) {
		this.kind = kind;
	}
}

final class NodeProgram : Node {
	private NodeStatement[] children;

	this() {
		super(NodeKind.Program);
	}
	this(NodeStatement[] children) {
		super(NodeKind.Program);
		this.children = children;
	}

	void append(NodeStatement node) {
		this.children ~= node;
	}
}

abstract class NodeStatement : Node {
	private StatementKind kind;

	this(StatementKind kind) {
		super(NodeKind.Statement);
		this.kind = kind;
	}
}

final class NodeFunction : NodeStatement {
	private NodeIdentifier ident;
	private NodeType type;
	private NodeArgList args;
	private NodeBlock block;

	this(NodeIdentifier ident, NodeType type, NodeArgList args, NodeBlock block) {
		super(StatementKind.Function);
		this.ident = ident;
		this.type = type;
		this.args = args;
		this.block = block;
	}
}

final class NodeArgList : NodeStatement {
	private NodeArg[] args;

	this(NodeArg[] args) {
		super(StatementKind.ArgList);
		this.args = args;
	}
}

final class NodeArg : NodeStatement {
	private NodeIdentifier ident;
	private NodeType type;

	this(NodeIdentifier ident, NodeType type) {
		super(StatementKind.Arg);
		this.ident = ident;
		this.type = type;
	}
}

final class NodeBlock : NodeStatement {
	private Node[] children;

	this(Node[] children) {
		super(StatementKind.Block);
		this.children = children;
	}
}

final class NodeReturn : NodeStatement {
	private NodeExpression expr;

	this(NodeExpression expr) {
		super(StatementKind.Return);
		this.expr = expr;
	}
}

final class NodeVar : NodeStatement {
	private NodeIdentifier ident;
	private NodeType type;
	private NodeExpression val;
	private bool initialized;
	private bool used = false;

	this(NodeIdentifier ident, NodeType type) {
		super(StatementKind.Var);
		this.ident = ident;
		this.type = type;
		this.initialized = false;
	}
	this(NodeIdentifier ident, NodeType type, NodeExpression val) {
		super(StatementKind.Var);
		this.ident = ident;
		this.type = type;
		this.val = val;
		this.initialized = true;
	}
}

final class NodeConst : NodeStatement {
	private NodeIdentifier ident;
	private NodeType type;
	private NodeExpression val;
	private bool used = false;

	this(NodeIdentifier ident, NodeType type, NodeExpression val) {
		super(StatementKind.Const);
		this.ident = ident;
		this.type = type;
		this.val = val;
	}
}

final class NodeIf : NodeStatement {
	private NodeExpression condition;
	private NodeBlock block;

	this(NodeExpression condition, NodeBlock block) {
		super(StatementKind.If);
		this.condition = condition;
		this.block = block;
	}
}

final class NodeElseIf : NodeStatement {
	private NodeExpression condition;
	private NodeBlock block;

	this(NodeExpression condition, NodeBlock block) {
		super(StatementKind.ElseIf);
		this.condition = condition;
		this.block = block;
	}
}

final class NodeElse : NodeStatement {
	private NodeBlock block;

	this(NodeBlock block) {
		super(StatementKind.Else);
		this.block = block;
	}
}

final class NodeWhile : NodeStatement {
	private NodeExpression condition;
	private NodeBlock block;

	this(NodeExpression condition, NodeBlock block) {
		super(StatementKind.While);
		this.condition = condition;
		this.block = block;
	}
}

final class NodeFor : NodeStatement {
	private NodeStatement stmt;
	private NodeExpression expr1, expr2;
	private NodeBlock block;

	this(NodeStatement stmt, NodeExpression expr1, NodeExpression expr2, NodeBlock block) {
		super(StatementKind.For);
		this.stmt = stmt;
		this.expr1 = expr1;
		this.expr2 = expr2;
		this.block = block;
	}
}

abstract class NodeExpression : Node {
	private ExpressionKind kind;

	this(ExpressionKind kind) {
		super(NodeKind.Expression);
		this.kind = kind;
	}
}

// Holder for `nil`.
final class NodeNil : NodeExpression {
	private Token nil;

	this(ref Token nil) {
		super(ExpressionKind.Nil);
		this.nil = nil;
	}
}

// Simple holder for a token, used sparingly.
final class NodeNumber : NodeExpression {
	private Token num;

	this(ref Token num) {
		super(ExpressionKind.Number);
		this.num = num;
	}
}

// Basically a simple holder for a token.
final class NodeIdentifier : NodeExpression {
	private Token ident;

	this(ref Token ident) {
		super(ExpressionKind.Identifier);
		this.ident = ident;
	}
}

// Also a holder.
final class NodeType : NodeExpression {
	private Token type;

	this(ref Token type) {
		super(ExpressionKind.Type);
		this.type = type;
	}
}

final class NodeBool : NodeExpression {
	private Token val;

	this(ref Token val) {
		super(ExpressionKind.Bool);
		this.val = val;
	}
}

final class NodeBinOp : NodeExpression {
	private Token op;
	private NodeExpression lhs, rhs;

	this(NodeExpression lhs, ref Token op, NodeExpression rhs) {
		super(ExpressionKind.BinOp);
		this.lhs = lhs;
		this.op = op;
		this.rhs = rhs;
	}
}