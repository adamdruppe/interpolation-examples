import core.interpolation;

import std.uri;
import std.string;

/++
	You can use this to indicate you want to embed this data directly, without encoding it.

	This overrides the safe-by-default behavior to opt back into plain concatenation as needed.
+/
struct SkipEncoding {
	string what;
}

struct Url {
	this(Args...)(InterpolationHeader header, Args args, InterpolationFooter footer) {
		string mostRecentExpression;
		foreach(arg; args) {
			static if(is(typeof(arg) == InterpolationHeader) || is(typeof(arg) == InterpolationFooter))
				// no need to handle this, will just skip it for this demo
				{} // but note we *could* give it special treatment and build them as one unit
			else static if(is(typeof(arg) == InterpolatedExpression!msg, string msg))
				mostRecentExpression = msg; // tracking this for error messages
			else static if(is(typeof(arg) == InterpolatedLiteral!str, string str)) {
				// this is literal string, so we can assume it doesn't need encoding as
				// user data.

				this.feed(str);
			} else static if(is(typeof(arg) == SkipEncoding)) {
				// let the user bypass things for pre-encoded dynamic data if they opt into it
				this.feed(arg.what);
			} else {
				// something else is user data. encode it appropriately for current state and inject it

				import std.conv;
				auto str = to!string(arg);

				if(state == 3) {
					// reading a path. I know a / can be legal here, including in a user-provided
					// segment (though they often DO have to be encoded there!) but I want to throw
					// to show the demonstration

					if(str.indexOf("/") != -1)
						throw new Exception("User provided variable, " ~ mostRecentExpression ~ ", contains a / but that's not allowed here! Provided string: " ~ str);

					parts[state] ~= str;
				} else if(state == 4) {
					// a query parameter. encode it properly

					parts[state] ~= std.uri.encodeComponent(str);
				} else {
					// somewhere else, we won't validate (even though we could) nor encode here because
					// this is just a demo.

					parts[state] ~= str;
				}
			}
		}
	}

	// the incremental parser state
	private int overallIndex;
	private int state;

	string[6] parts;

	string toString() {
		string res;
		foreach(part; parts)
			res ~= part;
		return res;
	}

	void feed(string s) {
		loop: foreach(ch; s) {
			sw: switch(state) {
				case 0: // reading a scheme
					if(ch == ':') {
						if(overallIndex == 0)
							state = 3;
						else
							state = 2;
					} else if(ch == '/')
						state = 1;
					break;
				case 1: // ambiguous, might be authority or path
					if(ch == '/')
						state = 2;
					else
						state = 3;
					break;
				case 2: // reading an authority
					if(ch == '/')
						state = 3;
					else if(ch == '?')
						state = 4;
					else if(ch == '#')
						state = 5;
					break;
				case 3: // reading a path
					if(ch == '?')
						state = 4;
					else if(ch == '#')
						state = 5;
					break;
				case 4: // reading a query string
					if(ch == '#')
						state = 5;
					break;
				case 5: // reading a fragment
					// just keep going, this is everything that's left
					break;
				default:
					assert(0);
			}

			// relax, it is just a demo implementation!
			parts[state] ~= ch;

			overallIndex++;
		}
	}
}
