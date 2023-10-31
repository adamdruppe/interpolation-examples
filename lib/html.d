module lib.html;

import core.interpolation;

/+
	There's a few approaches we could take to this.

	One idea is to use an incremental parser, feeding the data into it
	and embedding objects in context as you go.

	Another idea is to create a HTML template out of the literal data, with
	placeholders, then do the replacement of runtime data after.

	The current dom.d string stream implementation does not necessarily give
	yo the context needed to do this right, so you'd be better off actually
	processing the string separately to get full feature. But that's just
	a limitation of this library (its streaming features were hacked on
	after-the-fact and the input string stream and the output element
	streams are 100% separate) and I think the stream is a bit more fun
	right now.

	I'm going to do a streaming thing here with a ctfe hook so we can
	validate at compile time and run at runtime. Just for fun.
+/

import arsd.dom;

Element html(Args...)(InterpolationHeader, Args args, InterpolationFooter) {
	Element process() {
		// getMoreHelper, hasMoreHelper returning string and bool

		static class ContextAwareDocument : Document {
			Element currentContext;
			override void processNodeWhileParsing(Element parent, Element child) {
				super.processNodeWhileParsing(parent, child);
				this.currentContext = parent; // doesn't actually work combined with string processing due to limitation of dom.d implementation but here for future expansion
			}
		}

		auto document = new ContextAwareDocument();
		int streamPosition = 0;
		string currentCode;
		auto stream = new Utf8Stream(
			// get more, like range.popFront; range.front (this code predates ranges though)
			() {
				// the static foreach inside switch pattern is a useful one for
				// indexing a tuple (or other compile-time entity) with a runtime
				// value
				sw: switch(streamPosition) {
					static foreach(idx, item; args) {
						case idx:
							static if(is(typeof(item) == InterpolatedLiteral!str, string str)) {
								streamPosition++;
								return str;
							} else static if(is(typeof(item) == InterpolatedExpression!code, string code)) {
								currentCode = code;
								streamPosition++;
								goto sw;
							} else static if(is(typeof(item) == InterpolationHeader) || is(typeof(item) == InterpolationFooter)) {
								throw new Exception("nested IESes not allowed");
							} else {
								// we know this comes from other code, so to inject it into the document,
								// we need to encode it properly for the given context.
								streamPosition++;
								import std.conv;
								// ctfe can't read the actual input parameters, but it CAN read local variables
								// inside this function. So we can branch there and use placeholder stuff in CTFE
								// and actual data at runtime, thus allowing compile-time validation.
								if(__ctfe)
									return htmlEntitiesEncode("{{" ~ currentCode ~ "}}");
								else
									return htmlEntitiesEncode(to!string(item));

								// Additionally, if we wanted to do context-aware processing - e.g. json encode
								// inside <script> and html encode elsewhere - we could output the ctfe thing into
								// the runtime processor ahead of time and work on everything on the dom level.
								// but meh
							}
						break sw;
					}

					default: assert(0);
				}
				return "";
			},
			// has more delegate, like range.front
			() {
				return streamPosition < args.length;
			}
		);

		document.parseStream(stream, true /* case sensitive */, true /* strict mode */);
		return document.root;
	}

	// pragma(msg, process().toString); // if you want to see the ctfe result
	static assert(process() !is null); // validate it at CTFE

	return process(); // then run it at runtime
}
