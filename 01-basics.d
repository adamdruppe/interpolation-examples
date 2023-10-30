module demos.basics;

import std.stdio;
import std.conv;

void main() {
	string name = "D user";
	int dipNumber = 1701;

	// many functions can take it automatically. Always use $(...) to add expressions.
	writeln(i"Hello, $(name)! I liked DIP $(dipNumber) a lot.");

	// and you can use std.conv.text to convert to a standard string very easily
	string result = i"$(name)! See that DIP $(dipNumber) is easy to convert to string.".text;

	struct A {
		int member;
	}

	auto item = A(443);

	writeln(i"Works for struct members with parens too: $(item.member)");

	// and all the lookup is done same as if you wrote out the parameter list
	// yourself, so it also works with things like with expressions
	with(item) writeln(i"The member is $(member).");

	// be aware that inside the $() is D code, so you do NOT escape quotes and such in
	// there, but can do so normally in the string parts:
	string[string] AA = ["hello":"world"];
	writeln(i"The AA has \"$(AA["hello"])\" inside it."); // The AA has "world" inside it.

	// you can also nest interpolated elements but it is up to the library what they
	// do with it. writeln just flattens everything:

	writeln(i"Nested $(i"string") here");
}
