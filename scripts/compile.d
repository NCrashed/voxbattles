#!/usr/bin/rdmd
/// Скрипт автоматической компиляции проекта под Linux и Windows
/** 
 * Очень важно установить пути к зависимостям (смотри дальше), 
 */
module compile;

import dmake;

import std.stdio;
import std.process;
import std.file;

string compileVoxlap()
{
	if(!exists("../bin/foguan.exe"))
	{
		return "buildVoxlab.bat";
	}
	return "";
}

int main(string[] args)
{
	addCompTarget("foguanCore", "../bin", "foguan", BUILD.SHARED);
	addSource("../src/foguan");

	//addCustomCommand(&compileVoxlap);
	addCustomFlags("-D -Dd../docs ../docs/candydoc/candy.ddoc ../docs/candydoc/modules.ddoc -version=CL_VERSION_1_1");

	checkProgram("dmd", "Cannot find dmd to compile project! You can get it from http://dlang.org/download.html");
	// Компиляция!
	return proceedCmd(args);
}