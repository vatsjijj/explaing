module context;

import lexer;

struct GlobalContext {
	string file, filename;
	string[] lines;
	Token[] toks;

	this(string filename, ref string file, ref string[] lines) {
		this.file = file;
		this.filename = filename;
		this.lines = lines;
	}
}