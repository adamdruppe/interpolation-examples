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
