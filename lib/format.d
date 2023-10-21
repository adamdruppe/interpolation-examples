module lib.format;

import core.interpolation;
import lib.helpers;

// it always uses positional parameters to pass to std.format since otherwise we need to manipulate the arg tuple and that's a hassle.
// i also tried %.0s to print it as a zero-length but that didn't work either randomly.
template makeStdFormatString(Args...) {
	string helper() {
		import std.string;
		import std.conv;

		string result;

		void addDefault(size_t idx) {
			result ~= "%" ~ to!string(idx + 1) ~ "$s";
		}

		foreach(idx, arg; Args) {
			static if(is(arg == InterpolatedLiteral!str, string str)) {
				if(str.length > 2 && str[0 .. 2] == ":%")
					result ~= "%"~to!string(idx)~"$" ~ str[2 .. $]; // FIXME should escape the % after the format string ends too
				else
					// note that we know the difference between string literal and interpolated
					// things, meaning the library has the knowledge it needs to correctly encode
					// all the data for its target
					result ~= str.replace("%", "%%");
			} else static if(is(arg == InterpolatedExpression!str, string str)) {
			} else static if(is(arg == InterpolationHeader)) {
			} else static if(is(arg == InterpolationFooter)) {
			} else {
				static if(idx + 1 < Args.length && is(Args[idx + 1] == InterpolatedLiteral!str, string str)) {
					if(str.length > 2 && str[0 .. 2] == ":%")
						{} // user-provided format string, will be handled in next iteration
					else
						addDefault(idx);

				} else {
					// default formatter
					addDefault(idx);
				}
			}
		}
		return result;
	}

	enum string makeStdFormatString = helper();
}

Formatted!T fmt(T)(T value, string formatString) {
	return Formatted!T(value, formatString);
}

struct Formatted(T) {
	T value;
	string formatString;
}

void writefln(Args...)(InterpolationHeader header, Args args, InterpolationFooter footer) {
	// pragma(msg, Args);
	// pragma(msg, makeStdFormatString!Args);
	import std.stdio;
	std.stdio.writefln(makeStdFormatString!Args, args);
}
