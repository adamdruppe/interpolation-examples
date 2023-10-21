module demos.basics;

import std.stdio;
import std.conv;

void main() {
	string name = "D user";
	int dipNumber = 1701;

	// many functions can take it automatically
	writeln(i"Hello, $name! I liked DIP $dipNumber a lot.");

	// and you can use std.conv.text to convert to a standard string very easily
	string result = i"$name! See that DIP $dipNumber is easy to convert to string.".text;
}
