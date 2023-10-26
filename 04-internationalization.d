#!/usr/bin/env dub
/+ dub.json:
{
    "name": "internationalization",
    "targetType": "executable",
    "dependencies": {
        "gettext": "~>1"
    },
    "configurations": [
        {
            "name": "default"
        },
        {
            "name": "i18n",
            "preGenerateCommands": [
                "dub run --config=xgettext --single 04-internationalization.d",
                "dub run gettext:merge -- --popath=po --backup=none",
                "dub run gettext:po2mo -- --popath=po --mopath=mo"
            ],
            "copyFiles": [
                "mo"
            ]
        },
        {
            "name": "xgettext",
            "targetPath": ".xgettext",
            "versions": [ "xgettext" ],
            "subConfigurations": {
                "gettext": "xgettext"
            }
        }
    ]
}
+/
module demo.internationalization;


/* **************
	Usage
*  **************/

void main() {
	mixin(gettext.main);

	// try changing the language and the count
	gettext.selectLanguage("./mo/test.mo");

	int count = 1;

	string name = "Adam";

	import std.stdio;
	// you can pass an explicit variable to indicate the pluralness (then use %d in the string to represent it)
	writeln(tr(i"I, $name, have a singular apple.", i"I, $name, have %d apples.", count));

	// or it can figure it out
	writeln(tr(i"I, $name, have a singular apple.", i"I, $name, have $count apples."));
}


/* **************
       Lib Impl
*  **************/

import core.interpolation;

import gettext;

auto toTrString(Args...)(string pluralCode = null) {
	import std.conv;
	string result;
	int exprCount;
	foreach(idx, alias arg; Args) {
		static if(is(typeof(arg) == InterpolatedLiteral!str, string str))
			result ~= str;
		else static if(is(typeof(arg) == InterpolationHeader)) // || is(typeof(arg) == InterpolationFooter))
			throw new Exception("Nested interpolated items not currently implemented for translation " ~ idx.stringof);
		else static if(is(typeof(arg) == InterpolatedExpression!str, string str)) {
			exprCount++;
			if(pluralCode !is null && str == pluralCode)
				result ~= "%d"; // the underlying lib assumes this one will have this specific thing
			else
				result ~= "$" ~ to!string(exprCount);
		}
	}

	return result;
}

// make the explicit arg optional if there's only one numeric expression passed

string tr(Args...)(InterpolationHeader header, Args args) {
	static size_t interpolationEndsAt() {
		int open = 1;
		foreach(idx, arg; Args) {
			static if(is(arg == InterpolationFooter))
				open--;
			else static if(is(arg == InterpolationHeader))
				open++;
			if(open == 0)
				return idx;
		}
		return Args.length;
	}

	static struct PluralArg {
		size_t idx;
		string code;
	}
	PluralArg getPluralArg() {
		static if(is(typeof(args[$-1]) : int)) {
			return PluralArg(Args.length - 1, null);
		} else {
			size_t[string] map;
			foreach(idx, arg; Args) {
				static if(is(arg == InterpolatedExpression!code, string code) && is(Args[idx+1] : int))
					map[code] = idx + 1;
			}

			if(map.length == 1)
				foreach(k, v; map)
					return PluralArg(v, k);
			assert(0, "Multiple integer args - please pass the one that makes the sentence plural as a separate argument at the end.");
		}
	}

	string finalize(string str) {
		import std.string, std.conv;
		int exprCount;
		foreach(idx, arg; args) {
			static if(is(typeof(arg) == InterpolatedExpression!code, string code)) {
				exprCount++;
				// FIXME: should only replace from the last replacement forward
				return str.replace("$" ~ to!string(exprCount), to!string(args[idx + 1]));
			}
		}

		return str;
	}

	enum isPlural = interpolationEndsAt != Args.length;

	static if(isPlural) {
		alias singular = args[0 .. interpolationEndsAt()];
		alias plural = args[interpolationEndsAt() + 2 .. $]; // skip the header and the footer

		return finalize(gettext.tr!(toTrString!singular(), toTrString!plural(getPluralArg().code))(args[getPluralArg().idx]));
	} else {
		return finalize(gettext.tr!(toTrString!args));
	}
}

