module demo.formatting;

import lib.format;

void main() {
	string name = "D user";
	float wealth = 55.70;

	// only $ followed by a D identifier or a ( is special
	// so the double $ here is a basic one followed by an
	// interpolated var. Can also use \$ in i"strings"
	// then :% is interpreted by this function to mean
	// "use this format string for the preceding argument"
	writefln(i"$name has $$wealth:%0.2f");
}
