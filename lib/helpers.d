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


