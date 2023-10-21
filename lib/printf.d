module lib.printf;

import core.interpolation;
import std.meta;

template isInterpolatedMetadata(T) {
	static if(is(T == InterpolatedLiteral!str, string str))
		enum bool isInterpolatedMetadata = true;
	else static if(is(T == InterpolatedExpression!str, string str))
		enum bool isInterpolatedMetadata = true;
	else
		enum bool isInterpolatedMetadata = false;
}

template UserTypes(T...) {
	alias helper = AliasSeq!();
	static foreach(t; T)
		static if(isInterpolatedMetadata!t)
			{}
		else static if(is(t == string))
			helper = AliasSeq!(helper, size_t, const char*);
		else
			helper = AliasSeq!(helper, t);

	alias UserTypes = helper;
}

template extractPrintfString(Args...) {
	string helper() {
		string s;
		foreach(arg; Args) {
			static if(is(arg == InterpolatedLiteral!str, string str))
				s ~= str;
			else static if(is(arg == int))
				s ~= "%d";
			else static if(is(arg == string))
				s ~= "%.*s";
		}
		s ~= "\0";
		return s;
	}

	enum extractPrintfString = helper();
}

struct NthResult {
	size_t idx;
	string component;
}

NthResult getNthUserArgIdx(size_t idx, Args...)() {
	int counter;
	foreach(i, arg; Args) {
		static if(is(arg == InterpolatedLiteral!str, string str))
			{}
		else static if(is(arg == int)) {
			if(counter == idx)
				return NthResult(i);
			counter++;
		}
		else static if(is(arg == string)) {
			if(counter == idx)
				return NthResult(i, "length");
			counter++;
			if(counter == idx)
				return NthResult(i, "ptr");
			counter++;
		}
	}

	assert(0);
}

auto getNthUserArg(size_t idx, Args...)(Args args) {
	enum nth = getNthUserArgIdx!(idx, Args);
	static if(nth.component.length)
		return mixin("args[nth.idx]." ~ nth.component);
	else
		return args[nth.idx];
}

auto makePrintfArgs(Args...)(InterpolationHeader header, Args args, InterpolationFooter footer) {
	static struct Result {
		const(char)* fmt;
		UserTypes!Args userArgs;
	}

	Result result;
	result.fmt = extractPrintfString!Args.ptr;

	foreach(idx, ref userArg; result.userArgs)
		cast() userArg = getNthUserArg!idx(args);

	return result;
}

