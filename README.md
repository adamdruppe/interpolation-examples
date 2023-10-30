These are examples of using the D interpolation strings as implemented in:

https://github.com/dlang/dmd/pull/15715

You must build and use that compiler to try these yourself, but you can browse the code from here.

To just look at how it would be used from the end user perspective, look at top-level .d files. To see library implementations, look in the lib folder.

PRs welcome to this to add more use cases.

Please note: NONE of the examples in this repository is part of the proposal to change the compiler. Those changes are in the mentioned PR above. This repository is just a set of example use cases.

* * *

One of the points I'm trying to make with this is that library flexibility is useful to maintain convenience with correctness. A lot of times, when you build a string, there's several encoding and escaping considerations you need to do right, or you'll get a mangled result (and/or a security hole!). The string representation is often really convenient and natural to read and write, but also really easy to do slightly wrong.

An interpolated sequence gives you the best of both worlds: the programmer gets to use the convenient and natural string representation, where the library gets to use a structured and correct object representation. Thanks to the rich metadata provided to library functions, it can tell for sure the difference between string literals and interpolated data - a fact that has been used in other special-purpose templating languages like Ruby on Rails' erb or React.js' JSX help programmers write correct and secure code.

With this new feature, D is able to do these things in a self-hosted capacity, adding to D's existing metaprogramming dominance - and as the basic demos show, without compromising on ease of use.

* * *

# Feature design FAQ:

## Why does it return a compiler-tuple instead of a struct?

One of the design principles here is to maximize compatibility with other D features. This means we don't want to discard *any* information or forbid any use case (though some uses might be easier or more convenient than others). This includes using interpolated sequences as template arguments, including things like types and aliases, which would be potentially lost if converted to a struct. Additionally, even basic functions can lose information when wrapped in an object because D supports many things on function parameters that it does not support in objects, like `ref`, automatic C-string conversion for string literals, and other things.

To learn more about how these work, see my comment here: https://github.com/dlang/dmd/pull/15715#issuecomment-1781745762

## Why does it wrap string literals in a special `InterpolatedLiteral` type?

This lets the library function tell, without a doubt, the difference between a string in the source code and a string that came from a variable. This helps you ensure that interpolated data is processed safely.

The literal string being communicated to the library via a template argument also preserves the fact that it is available at compile time. Many of the examples in this repo use this fact to build data structures and validate formats at compile time. Like with the previous question, this ensures compatibility with all D features, including CTFE, whenever possible.

## Why does it *not* implicitly convert to string?

Observe that in many of the examples, there is an important difference between how user-provided data and the characters around them are processed. Getting this right is vital to prevent bugs, including security problems. Remember, strings are just one of many uses of the language feature.

D has several design decisions that trade a small amount of convenience for correctness, including several limitations on implicit conversions in the type system. Usually, you can easily tell the compiler to "trust me" using an explicit cast or a function call. This feature is no different.

```
@system void foo();
@safe void bar() {
	foo(); // will not compile, might not be memory safe, use `@trusted` if you are sure
}

void thing(shared(Object) o) {
	o.toString(); // will not compile, might not be thread safe, use `cast` if you are sure
}

immutable(ubyte)[] storedData;
void store(ubyte[] data) {
	storedData = data; // will not compile, might be unexpected modified later. use `assumeUnique` if you are sure
}

void overflow() {
	short a, b;
	short c = a + b; // will not compile, might give unexpected numeric result, use `cast` if you are sure
}

void runCommand(string s) {}

runCommand(i"command $injected"); // will not compile, might have command injection vulnerability, use `.text` if you are sure
```

In no case does D make these things impossible - there's always a way for you to specify you are sure - but in each of those, it makes it a bit more inconvenient just to make you stop and confirm your intention to the language and to future readers of this code.

Given the long history of problems arising from "stringly-typed" code, leveraging D's type system to make you think twice before stumbling into a bug seems like an obvious win. Please note that Java's similar feature proposal also works this way.

And importantly, look at the examples in this repository: given the flexibility this feature gives to library authors for using strongly-typed, richly functional objects and functions, the converting to a plain string and bypassing these protections ought to be less common than you may expect.
