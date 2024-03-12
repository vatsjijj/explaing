import std.stdio;
import std.file;
import std.string;
import error;
import lexer;
import context;
import parser;
import symbol;
import analysis;

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

		Parser p = new Parser(gCtx);
		auto tree = p.parse();
		Resolver res = new Resolver(gCtx, tree);
		res.resolve();
		Analyzer sema = new Analyzer(gCtx, res);
		sema.analyze();
	}
	catch (Exception e) {
		stderr.writeln(e.message);
		return 2;
	}

	return 0;
}
