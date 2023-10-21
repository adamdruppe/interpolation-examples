module demo.formatting;

import lib.format;

void main() {
	string name = "D user";
	float wealth = 55.70;

	// double dollar sign = literal $ in the output
	// then :% is interpreted by this function to mean
	// "use this format string for the preceding argument"
	writefln(i"$name has $$$wealth:%0.2f");
}
