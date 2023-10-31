module demo.html;

import lib.html;

void main() {
	string name = "<bar>"; // this will be properly encoded
	auto element = i"<foo>$(name)</foo>".html; // it returns a dom.d Element
	assert(element.tagName == "foo"); // notice it is a structured object, not a string

	import std.stdio;
	writeln(element.toString());

	// auto fail = i"<foo>$(name)</fo>".html; // uncomment this to see a compile-time validation error:
	/+
	/home/me/program/lib/arsd/dom.d(536): Error: uncaught CTFE exception `arsd.dom.MarkupException("char 18 (line 1): mismatched tag: </fo> != <foo> (opened on line 1)"c)`
	lib/html.d(97):        called from here: `process()`
	lib/html.d(97):        while evaluating: `static assert(process() !is null)`
	07-html.d(13): Error: template instance `lib.html.html!(InterpolatedLiteral!"<foo>", InterpolatedExpression!"name", string, InterpolatedLiteral!"</fo>")` error instantiating
	+/
}
