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
	Class,
	Struct,
	Union,
	If,
	ElseIf,
	Else,
	While,
	For,
	EOF,
}

enum ExpressionKind {
	Number,
	Identifier,
	BinOp,
	Type,
	Bool,
	Nil,
	Call,
	ExprList,
	String,
	This, Super,
	Array,
	ArrayAccess,
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

	NodeStatement[] getChildren() {
		return this.children;
	}

	bool isEmpty() {
		return children[0].isKind(StatementKind.EOF);
	}
}

abstract class NodeStatement : Node {
	private StatementKind kind;

	this(StatementKind kind) {
		super(NodeKind.Statement);
		this.kind = kind;
	}

	bool isKind(StatementKind kind) {
		return kind == this.kind;
	}
}

enum Visibility {
	Private,
	Protected,
	Public,
}

final class NodeClass : NodeStatement {
	private Visibility vis = Visibility.Protected;
	private NodeIdentifier ident;
	private NodeBlock block;

	this(NodeIdentifier ident, NodeBlock block) {
		super(StatementKind.Class);
		this.ident = ident;
		this.block = block;
	}
	this(NodeIdentifier ident, NodeBlock block, Visibility vis) {
		super(StatementKind.Class);
		this.ident = ident;
		this.block = block;
		this.vis = vis;
	}
}

final class NodeStruct : NodeStatement {
	private Visibility vis = Visibility.Protected;
	private NodeIdentifier ident;
	private NodeBlock block;

	this(NodeIdentifier ident, NodeBlock block) {
		super(StatementKind.Struct);
		this.ident = ident;
		this.block = block;
	}
	this(NodeIdentifier ident, NodeBlock block, Visibility vis) {
		super(StatementKind.Struct);
		this.ident = ident;
		this.block = block;
		this.vis = vis;
	}
}

final class NodeUnion : NodeStatement {
	private Visibility vis = Visibility.Protected;
	private NodeIdentifier ident;
	private NodeBlock block;

	this(NodeIdentifier ident, NodeBlock block) {
		super(StatementKind.Union);
		this.ident = ident;
		this.block = block;
	}
	this(NodeIdentifier ident, NodeBlock block, Visibility vis) {
		super(StatementKind.Union);
		this.ident = ident;
		this.block = block;
		this.vis = vis;
	}
}

final class NodeFunction : NodeStatement {
	private Visibility vis = Visibility.Protected;
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
	this(NodeIdentifier ident, NodeType type, NodeArgList args, NodeBlock block, Visibility vis) {
		super(StatementKind.Function);
		this.ident = ident;
		this.type = type;
		this.args = args;
		this.block = block;
		this.vis = vis;
	}
}

final class NodeArgList : NodeStatement {
	private NodeArg[] args;

	this() {
		super(StatementKind.ArgList);
		this.args = [];
	}
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
	private Visibility vis = Visibility.Protected;
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
	this(NodeIdentifier ident, NodeType type, Visibility vis) {
		super(StatementKind.Var);
		this.ident = ident;
		this.type = type;
		this.initialized = false;
		this.vis = vis;
	}
	this(NodeIdentifier ident, NodeType type, NodeExpression val, Visibility vis) {
		super(StatementKind.Var);
		this.ident = ident;
		this.type = type;
		this.val = val;
		this.initialized = true;
		this.vis = vis;
	}
}

final class NodeConst : NodeStatement {
	private Visibility vis = Visibility.Protected;
	private NodeIdentifier ident;
	private NodeType type;
	private NodeExpression val;
	private bool initialized;
	private bool used = false;

	this(NodeIdentifier ident, NodeType type) {
		super(StatementKind.Const);
		this.ident = ident;
		this.type = type;
		this.val = val;
		this.initialized = false;
	}
	this(NodeIdentifier ident, NodeType type, NodeExpression val) {
		super(StatementKind.Const);
		this.ident = ident;
		this.type = type;
		this.val = val;
		this.initialized = true;
	}
	this(NodeIdentifier ident, NodeType type, Visibility vis) {
		super(StatementKind.Const);
		this.ident = ident;
		this.type = type;
		this.val = val;
		this.initialized = false;
		this.vis = vis;
	}
	this(NodeIdentifier ident, NodeType type, NodeExpression val, Visibility vis) {
		super(StatementKind.Const);
		this.ident = ident;
		this.type = type;
		this.val = val;
		this.initialized = true;
		this.vis = vis;
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

final class NodeEOF : NodeStatement {
	private Token tok;

	this(ref Token tok) {
		super(StatementKind.EOF);
		this.tok = tok;
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

final class NodeType : NodeExpression {
	private Token[] type;

	this(Token[] type) {
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

final class NodeString : NodeExpression {
	private Token val;

	this(ref Token val) {
		super(ExpressionKind.String);
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

final class NodeExprList : NodeExpression {
	private NodeExpression[] exprs;

	this() {
		super(ExpressionKind.ExprList);
		this.exprs = [];
	}
	this(NodeExpression[] exprs) {
		super(ExpressionKind.ExprList);
		this.exprs = exprs;
	}
}

final class NodeCall : NodeExpression {
	private Token ident;
	private NodeExprList args;

	this(ref Token ident, NodeExprList args) {
		super(ExpressionKind.Call);
		this.ident = ident;
		this.args = args;
	}
}

final class NodeThis : NodeExpression {
	private Token item;

	this(ref Token item) {
		super(ExpressionKind.This);
		this.item = item;
	}
}

final class NodeSuper : NodeExpression {
	private Token item;
	private NodeExprList args;

	this(ref Token item, NodeExprList args) {
		super(ExpressionKind.Super);
		this.item = item;
		this.args = args;
	}
}

final class NodeArray : NodeExpression {
	private NodeExpression[] content;

	this() {
		super(ExpressionKind.Array);
		this.content = [];
	}
	this(NodeExpression[] content) {
		super(ExpressionKind.Array);
		this.content = content;
	}
}

final class NodeArrayAccess : NodeExpression {
	private NodeExpression ident;
	private NodeExpression expr;

	this(NodeExpression ident, NodeExpression expr) {
		super(ExpressionKind.ArrayAccess);
		this.ident = ident;
		this.expr = expr;
	}
}