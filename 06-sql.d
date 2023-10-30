module demo.sql;

import arsd.sqlite;
import lib.sql;

import std.stdio;

void main() {
	auto db = new Sqlite(":memory:");
	db.query("CREATE TABLE sample (id INTEGER, name TEXT)");

	// you might think this is sql injection... but it isn't! the lib
	// uses the rich metadata provided by the interpolated sequence to
	// use prepared statements appropriate for the db engine under the hood
	int id = 1;
	string name = "' DROP TABLE', '";
	db.execi(i"INSERT INTO sample VALUES ($(id), $(name))");

	foreach(row; db.query("SELECT * from sample"))
		writeln(row[0], ": ", row[1]);
}
