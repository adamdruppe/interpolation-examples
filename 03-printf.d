module demo.printf;

import core.stdc.stdio;

import lib.printf;

void main() {
	int age = 3;
	string name = "The child";
	printf(makePrintfArgs(i"$(name) is $(age) years old.\n").tupleof);
}
