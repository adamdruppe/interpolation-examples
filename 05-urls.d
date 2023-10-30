module demo.urls;

import std.stdio;

import lib.url;

void main() {
	int id = 65;
	string term = "my thing & / or other thing";

	auto url = Url(i"https://example.com/users/$(id)?search=$(term)");

	writeln(url);

	try {
		// this isn't illegal in all cases, but our demo library
		// forbids / in path segments without user intervention.
		//
		// so we want to demonstrate validation here deliberately.
		string path = "/this";
		Url(i"https://example.com/users/$(path)?search=$(term)");
		assert(0); // the above will throw
	} catch(Exception e) {
		// it will print out even the name of the `path` variable above!
		writeln("A url was invalid: " ~ e.msg);
	}

	/+
		please note that if you did:

		Url("https://example.com/users/ " ~ to!string(id) ~ "?search=" ~ term);

		you'd get an incorrect result, because the term is not correctly encoded there.

		Easy mistake to make with string concatenation, but with the enhanced interpolation
		approach, the code is both easier to write - you don't have to match quotes and
		append operators - and more likely to be correct, since the library can encode
		it for you since it knows the full context.
	+/
}
