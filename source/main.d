import std.stdio;
import std.file;
import std.string;
import error;
import lexer;
import context;

int main(string[] args) {
	if (args.length < 2) {
		stderr.writeln("Expected an argument.");
		stderr.writeln("Usage:");
		stderr.writeln("   ", args[0], " <input>");
		return 1;
	}

	try {
		string file = args[1].readText();
		string[] lines = file.splitLines();

		GlobalContext gCtx = GlobalContext(args[1], file, lines);
		
		Token[] toks = tokenize(gCtx);

		gCtx.toks = toks;
	}
	catch (Exception e) {
		stderr.writeln(e.message);
		return 2;
	}

	return 0;
}
