module error;

import std.stdio;
import std.string;
import core.stdc.stdlib : exit;
import lexer;
import color;
import context;

const string DRAW_HORIZONTAL = "─";
const string DRAW_ANGLE      = "╭";
const string DRAW_VERTICAL   = "│";
const string DRAW_INV_ANGLE  = "╰";
const string DRAW_JUNCTION   = "┬";
const string DRAW_DOT        = "·";

const string DRAW_TOP    = "╭─";
const string DRAW_BOTTOM = "╰────";

const RGB ERROR    = RGB(0xE01414, "b");
const RGB WARN     = RGB(0xE0C814, "b");
const RGB NOTICE   = RGB(0x14E0E0, "b");
const RGB FILENAME = RGB(0x148BE0, "b");

enum MessageKind {
	Notice,
	Warning,
	Error,
}

class Message {
	private MessageKind kind;
	private const string message, note;
	private Token tok;

	this(MessageKind kind, string message, ref Token tok) {
		this.kind = kind;
		this.message = message;
		this.tok = tok;
		this.note = "";
	}
	this(MessageKind kind, string message, string note, ref Token tok) {
		this.kind = kind;
		this.message = message;
		this.tok = tok;
		this.note = note;
	}

	private string indent(ulong amt) {
		string tmp;
		foreach (_; 0..amt) {
			tmp ~= " ";
		}
		return tmp;
	}

	private string repeat(string str, ulong amt) {
		string tmp;
		foreach (_; 0..amt) {
			tmp ~= str;
		}
		return tmp;
	}

	private string kindColor() {
		final switch (kind) {
			case MessageKind.Notice:
				return NOTICE.toString();
			case MessageKind.Warning:
				return WARN.toString();
			case MessageKind.Error:
				return ERROR.toString();
		}
	}

	ulong getLine() {
		return this.tok.line;
	}

	void display(ref GlobalContext gCtx) {
		import std.conv : to;
		ulong len = to!string(tok.line).length + 2;
		string tmp;
		tmp ~= kindColor();
		tmp ~= to!string(kind) ~ RESET ~ ":\n";
		tmp ~= indent(len);
		tmp ~= DRAW_TOP ~ "[" ~ FILENAME.toString();
		tmp ~= gCtx.filename ~ RESET ~ DIM ~ " | " ~ RESET;
		tmp ~= BOLD ~ to!string(tok.line) ~ RESET ~ DIM ~ ":";
		tmp ~= RESET ~ BOLD ~ to!string(tok.col) ~ RESET ~ "]\n";
		tmp ~= " " ~ DIM ~ to!string(tok.line) ~ RESET ~ " ";
		tmp ~= DRAW_VERTICAL ~ " " ~ gCtx.lines[tok.line - 1] ~ "\n";
		tmp ~= indent(len);
		tmp ~= DRAW_DOT ~ " ";
		tmp ~= kindColor();
		tmp ~= indent(tok.col - 1);
		tmp ~= repeat(DRAW_HORIZONTAL, (tok.len - 1) / 2);
		tmp ~= DRAW_JUNCTION;
		tmp ~= repeat(DRAW_HORIZONTAL, tok.len / 2);
		tmp ~= RESET ~ "\n";
		tmp ~= indent(len);
		tmp ~= DRAW_DOT ~ " ";
		tmp ~= kindColor();
		tmp ~= indent(tok.col - 1);
		tmp ~= indent((tok.len - 1) / 2);
		tmp ~= DRAW_INV_ANGLE ~ repeat(DRAW_HORIZONTAL, tok.len / 2 + 2) ~ " ";
		tmp ~= RESET ~ message ~ "\n";
		tmp ~= indent(len);
		tmp ~= DRAW_BOTTOM;
		if (note != "") {
			tmp ~= "\n " ~ NOTICE.toString() ~ "Note" ~ RESET ~ ": ";
			tmp ~= note;
		}
		stderr.writeln(tmp);
		if (kind == MessageKind.Error) exit(1);
	}
}