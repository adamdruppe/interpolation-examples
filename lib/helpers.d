/++
	These functions could also possibly be in core.interpolation, but
	they're separate from the compiler per se.
+/
module lib.helpers;

import core.interpolation;

template isInterpolatedMetadata(T) {
	static if(is(T == InterpolatedLiteral!str, string str))
		enum bool isInterpolatedMetadata = true;
	else static if(is(T == InterpolatedExpression!str, string str))
		enum bool isInterpolatedMetadata = true;
	else
		enum bool isInterpolatedMetadata = false;
}

// let's add a thing that takes a full tuple and converts it to an object with nesting and sequencing done automatically.
// args after the final sequence might be included or just numbered so you can slice them externally to preserve refness.
//
// could also just be a little forwarder to a traditionally written function.
