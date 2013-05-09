module client.api;

import std.stdio;

export extern(C) void debugPrint() 
{ 
	auto file = new File("test.log", "w");
	scope(exit) file.close();

	file.writeln("hello dll world"); 
}