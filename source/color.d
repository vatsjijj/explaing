module color;

import std.conv;
import std.string : split;
import std.math : abs, round;

const string RESET = "\x1b[0m";

private string[] styles = [
	"b", "i",
	"bi"
];

private T clamp(T)(T up, T low, T init) {
	return init > up ? up : init < low ? low : init;
}

struct HSL {
	double h, s, l = 0;
	string style = "";

	this(double h, double s, double l) {
		this.h = clamp!double(360.0, 0.0, h);
		this.s = clamp!double(100.0, 0.0, s) / 100;
		this.l = clamp!double(100.0, 0.0, l) / 100;
	}
	this(double h, double s, double l, string style) {
		this.h = clamp!double(360.0, 0.0, h);
		this.s = clamp!double(100.0, 0.0, s) / 100;
		this.l = clamp!double(100.0, 0.0, l) / 100;
		this.style = style;
	}

	string toString() const @safe pure nothrow {
		string res;
		double rp, gp, bp;
		int r, g, b;
		double c = (1 - abs(2 * this.l - 1)) * this.s;
		double x = c * (1 - abs((this.h / 60.0) % 2 - 1));
		double m = this.l - c / 2.0;
		if (0 <= this.h && this.h < 60) {
			rp = c;
			gp = x;
			bp = 0;
		}
		else if (60 <= this.h && this.h < 120) {
			rp = x;
			gp = c;
			bp = 0;
		}
		else if (120 <= this.h && this.h < 180) {
			rp = 0;
			gp = c;
			bp = x;
		}
		else if (180 <= this.h && this.h < 240) {
			rp = 0;
			gp = x;
			bp = c;
		}
		else if (240 <= this.h && this.h < 300) {
			rp = x;
			gp = 0;
			bp = c;
		}
		else if (300 <= this.h && this.h < 360) {
			rp = c;
			gp = 0;
			bp = x;
		}
		r = cast(int)round((rp + m) * 255);
		g = cast(int)round((gp + m) * 255);
		b = cast(int)round((bp + m) * 255);
		switch (this.style) {
			case "b": res ~= "\x1b[1m"; break;
			case "i": res ~= "\x1b[3m"; break;
			case "bi": res ~= "\x1b[1m\x1b[3m"; break;
			default: res ~= "\x1b[0m"; break;
		}
		res ~= "\x1b[";
		res ~= "38;";
		res ~= "2;";
		res ~= to!string(r) ~ ";";
		res ~= to!string(g) ~ ";";
		res ~= to!string(b) ~ "m";
		return res;
	}
}

struct HSV {
	double h, s, v = 0;
	string style = "";

	this(double h, double s, double v) {
		this.h = clamp!double(360.0, 0.0, h);
		this.s = clamp!double(100.0, 0.0, s) / 100;
		this.v = clamp!double(100.0, 0.0, v) / 100;
	}
	this(double h, double s, double v, string style) {
		this.h = clamp!double(360.0, 0.0, h);
		this.s = clamp!double(100.0, 0.0, s) / 100;
		this.v = clamp!double(100.0, 0.0, v) / 100;
		this.style = style;
	}

	string toString() const @safe nothrow {
		string res;
		double rp, gp, bp;
		int r, g, b;
		double c = this.v * this.s;
		double x = c * (1 - abs((this.h / 60.0) % 2 - 1));
		double m = this.v - c;
		if (0 <= this.h && this.h < 60) {
			rp = c;
			gp = x;
			bp = 0;
		}
		else if (60 <= this.h && this.h < 120) {
			rp = x;
			gp = c;
			bp = 0;
		}
		else if (120 <= this.h && this.h < 180) {
			rp = 0;
			gp = c;
			bp = x;
		}
		else if (180 <= this.h && this.h < 240) {
			rp = 0;
			gp = x;
			bp = c;
		}
		else if (240 <= this.h && this.h < 300) {
			rp = x;
			gp = 0;
			bp = c;
		}
		else if (300 <= this.h && this.h < 360) {
			rp = c;
			gp = 0;
			bp = x;
		}
		r = cast(int)round((rp + m) * 255);
		g = cast(int)round((gp + m) * 255);
		b = cast(int)round((bp + m) * 255);
		switch (this.style) {
			case "b": res ~= "\x1b[1m"; break;
			case "i": res ~= "\x1b[3m"; break;
			case "bi": res ~= "\x1b[1m\x1b[3m"; break;
			default: res ~= "\x1b[0m"; break;
		}
		res ~= "\x1b[";
		res ~= "38;";
		res ~= "2;";
		res ~= to!string(r) ~ ";";
		res ~= to!string(g) ~ ";";
		res ~= to!string(b) ~ "m";
		return res;
	}
}

struct CMYK {
	double c, m, y, k = 0;
	string style = "";

	this(double c, double m, double y, double k) {
		this.c = clamp!double(100.0, 0.0, c);
		this.m = clamp!double(100.0, 0.0, m);
		this.y = clamp!double(100.0, 0.0, y);
		this.k = clamp!double(100.0, 0.0, k);
	}
	this(double c, double m, double y, double k, string style) {
		this.c = clamp!double(100.0, 0.0, c);
		this.m = clamp!double(100.0, 0.0, m);
		this.y = clamp!double(100.0, 0.0, y);
		this.k = clamp!double(100.0, 0.0, k);
		this.style = style;
	}

	string toString() const @safe nothrow {
		string res;
		int r, g, b;
		r = cast(int)round(255.0 * (1 - this.c / 100.0) * (1 - this.k / 100.0));
		g = cast(int)round(255.0 * (1 - this.m / 100.0) * (1 - this.k / 100.0));
		b = cast(int)round(255.0 * (1 - this.y / 100.0) * (1 - this.k / 100.0));
		switch (this.style) {
			case "b": res ~= "\x1b[1m"; break;
			case "i": res ~= "\x1b[3m"; break;
			case "bi": res ~= "\x1b[1m\x1b[3m"; break;
			default: res ~= "\x1b[0m"; break;
		}
		res ~= "\x1b[";
		res ~= "38;";
		res ~= "2;";
		res ~= to!string(r) ~ ";";
		res ~= to!string(g) ~ ";";
		res ~= to!string(b) ~ "m";
		return res;
	}
}

struct RGB {
	int r, g, b = 0;
	bool fg = true;
	string style = "";

	this(uint rgb) {
		import std.bitmanip : nativeToBigEndian;
		// [NIL, R, G, B]
		ubyte[4] colArr = nativeToBigEndian(rgb);
		this.r = colArr[1];
		this.g = colArr[2];
		this.b = colArr[3];
	}
	this(uint rgb, string style) {
		import std.bitmanip : nativeToBigEndian;
		// [NIL, R, G, B]
		ubyte[4] colArr = nativeToBigEndian(rgb);
		this.r = colArr[1];
		this.g = colArr[2];
		this.b = colArr[3];
		this.style = style;
	}
	this(int r, int g, int b) {
		this.r = clamp!int(255, 0, r);
		this.g = clamp!int(255, 0, g);
		this.b = clamp!int(255, 0, b);
	}
	this(int r, int g, int b, bool fg) {
		this.r = clamp!int(255, 0, r);
		this.g = clamp!int(255, 0, g);
		this.b = clamp!int(255, 0, b);
		this.fg = fg;
	}
	this(int r, int g, int b, string style) {
		this.r = clamp!int(255, 0, r);
		this.g = clamp!int(255, 0, g);
		this.b = clamp!int(255, 0, b);
		this.style = style;
	}

	string toString() const @safe nothrow {
		string res;
		switch (this.style) {
			case "b": res ~= "\x1b[1m"; break;
			case "i": res ~= "\x1b[3m"; break;
			case "bi": res ~= "\x1b[1m\x1b[3m"; break;
			default: res ~= "\x1b[0m"; break;
		}
		res ~= "\x1b[";
		res ~= this.fg ? "38;" : "48;";
		res ~= "2;";
		res ~= to!string(this.r) ~ ";";
		res ~= to!string(this.g) ~ ";";
		res ~= to!string(this.b) ~ "m";
		return res;
	}
}

const string BOLD      = "\x1b[1m";
const string DIM       = "\x1b[2m";
const string ITALIC    = "\x1b[3m";
const string UNDERLINE = "\x1b[4m";

const RGB RED   = RGB(255,   0,   0);
const RGB GREEN = RGB(  0, 255,   0);
const RGB BLUE  = RGB(  0,   0, 255);
const RGB WHITE = RGB(255, 255, 255);

const CMYK CYAN    = CMYK(100,   0,   0, 0);
const CMYK MAGENTA = CMYK(  0, 100,   0, 0);
const CMYK YELLOW  = CMYK(  0,   0, 100, 0);

const RGB RED_BOLD   = RGB(255,   0,   0, "b");
const RGB GREEN_BOLD = RGB(  0, 255,   0, "b");
const RGB BLUE_BOLD  = RGB(  0,   0, 255, "b");
const RGB WHITE_BOLD = RGB(255, 255, 255, "b");

const CMYK CYAN_BOLD    = CMYK(100,   0,   0, 0, "b");
const CMYK MAGENTA_BOLD = CMYK(  0, 100,   0, 0, "b");
const CMYK YELLOW_BOLD  = CMYK(  0,   0, 100, 0, "b");

const RGB RED_ITALIC   = RGB(255,   0,   0, "i");
const RGB GREEN_ITALIC = RGB(  0, 255,   0, "i");
const RGB BLUE_ITALIC  = RGB(  0,   0, 255, "i");
const RGB WHITE_ITALIC = RGB(255, 255, 255, "i");

const CMYK CYAN_ITALIC    = CMYK(100,   0,   0, 0, "i");
const CMYK MAGENTA_ITALIC = CMYK(  0, 100,   0, 0, "i");
const CMYK YELLOW_ITALIC  = CMYK(  0,   0, 100, 0, "i");

const RGB RED_BOLD_ITALIC   = RGB(255,   0,   0, "bi");
const RGB GREEN_BOLD_ITALIC = RGB(  0, 255,   0, "bi");
const RGB BLUE_BOLD_ITALIC  = RGB(  0,   0, 255, "bi");
const RGB WHITE_BOLD_ITALIC = RGB(255, 255, 255, "bi");

const CMYK CYAN_BOLD_ITALIC    = CMYK(100,   0,   0, 0, "bi");
const CMYK MAGENTA_BOLD_ITALIC = CMYK(  0, 100,   0, 0, "bi");
const CMYK YELLOW_BOLD_ITALIC  = CMYK(  0,   0, 100, 0, "bi");