module lib.sql;

import core.interpolation;
import lib.helpers;

import arsd.database;

import arsd.mysql;
import arsd.sqlite;
import arsd.postgres;

// sqlite, postgres, and mysql all do it slightly differently, so they need different implementations.
// however, notice that the user code works the same in any of them
auto execi(Args...)(Database db, Args args) {
	// for the generic object, we will do a runtime cast to forward
	// it to the correct implementation. (Alternatives would be to add
	// a virtual method to the base class that forwards the info, but
	// I want to demo things independently of the main library for this demo.)
	if(auto sqlite = cast(Sqlite) db)
		return execi(sqlite, args);
	else if(auto postgres = cast(PostgreSql) db)
		return execi(postgres, args);
	else if(auto mysql = cast(MySql) db)
		return execi(mysql, args);
	else
		assert(0, "Unsupported database engine");

}

// the specific db engine implementations here
auto execi(Args...)(Sqlite db, InterpolationHeader header, Args args, InterpolationFooter footer) {
	import arsd.sqlite;

	// sqlite lets you do ?1, ?2, etc

	enum string query = () {
		string sql;
		int number;
		import std.conv;
		foreach(idx, arg; Args)
			static if(is(arg == InterpolatedLiteral!str, string str))
				sql ~= str;
			else static if(is(arg == InterpolationHeader) || is(arg == InterpolationFooter))
				throw new Exception("Nested interpolation not supported");
			else static if(is(arg == InterpolatedExpression!code, string code))
				{} // just skip it
			else
				sql ~= "?" ~ to!string(++number);
		return sql;
	}();

	auto statement = Statement(db, query);
	int number;
	foreach(arg; args) {
		static if(!isInterpolatedMetadata!(typeof(arg)))
			statement.bind(++number, arg);
	}

	return statement.execute();
}

auto execi(Args...)(PostgreSql db, InterpolationHeader header, Args args, InterpolationFooter footer) {
	import arsd.postgres;

	// postgres uses $1, $2, $3, etc and the arsd lib wants you to pass all the args, so we use the idx here

	enum string query = () {
		string sql = "PREPARE example_statement AS ";
		import std.conv;
		foreach(idx, arg; Args)
			static if(is(arg == InterpolatedLiteral!str, string str))
				sql ~= str;
			else static if(is(arg == InterpolationHeader) || is(arg == InterpolationFooter))
				throw new Exception("Nested interpolation not supported");
			else static if(is(arg == InterpolatedExpression!code, string code))
				{} // just skip it
			else
				sql ~= "$" ~ to!string(idx);
		return sql;
	}();

	return db.executePreparedStatement("example_statement", args);
}

auto execi(Args...)(MySql db, InterpolationHeader header, Args args, InterpolationFooter footer) {
	import arsd.mysql;

	// mysql uses ?, all positional parameters

	enum string query = () {
		string sql;
		foreach(arg; Args)
			static if(is(arg == InterpolatedLiteral!str, string str))
				sql ~= str;
			else static if(is(arg == InterpolationHeader) || is(arg == InterpolationFooter))
				throw new Exception("Nested interpolation not supported");
			else static if(is(arg == InterpolatedExpression!code, string code))
				{} // just skip it
			else
				sql ~= "?";
		return sql;
	}();

	auto statement = prepare(db, query);
	foreach(arg; args) {
		static if(!isInterpolatedMetadata!(typeof(arg)))
			bindParameter(statement, arg);
	}

	execute(statement);

	// the arsd mysql prepared statement doesn't let you get... limitation of that lib.. that old code needs an overhaul so badly
}
