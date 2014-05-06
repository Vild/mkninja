module mkninja.app;

import std.getopt;
import std.stdio : writeln;
import std.c.stdlib : exit;
import std.file: write, readText, dirEntries, SpanMode, DirEntry;
import std.string : replace;

import mkninja.log.log;
import mkninja.grammer;

import pegged.peg : ParseTree;

const int VERSION_MAJOR = 1;
const int VERSION_MINOR = 0;

Log log;

string basedir = "./";

void main(string[] args) {
	string file = "build.mkninja";
	string output = "build.ninja";

	getopt(args,
	       "h|help", &help,
	       "f|file", &file,
	       "o|output", &output,
	       "b|basedir", &basedir);

	if (basedir[$-1 .. $] != "/")
		basedir ~= "/";
	log = Log.MainLogger;
	log.Info("MKNinja", "MKNinja Version %s.%s", VERSION_MAJOR, VERSION_MINOR);

	try {
		string data = loadFile(file);
		log.Info("MKNinja", "Read '%s'.", file);
		write(output, data);
		log.Info("MKNinja", "Wrote '%s'.", output);
	} catch (Exception e) {
		log.Severe("MKNinja", e.msg);
	}
}

void help() {
	writeln("Usage: mkninja [-h|--help] [-f|--file <FILE>] [-o|--output <FILE>]");
	writeln("\t-h | --help    - Show this help");
	writeln("\t-f | --file    - Specifies a config. Default is 'build.mkninja'.");
	writeln("\t-o | --output  - Specifies a output. Default is 'build.ninja'.");
	writeln("\t-b | --basedir - Specifies a basedir path. Default is './'.");
	writeln();
	writeln("@include(...) - Includes the files in the argument - Example: @include(\"other.mkninja\")");
	writeln("@foreach(Directory, Filenames, ToWrite, NewLine = true) - For each file in <Directory> with a filename which fits in <Filenames> write ToWrite, and change all @file to the filename. And if NewLine is true (default is true) write a new line after.");
	exit(0);
}

string loadFile(string file) {
	string output = "";
	ParseTree tree = MKNinjaFile(readText(file));

	void parse(ParseTree p) {
		switch (p.name) {
			case "MKNinjaFile":
				parse(p.children[0]);
				break;
			case "MKNinjaFile.File":
				for(int i = 0; i < p.children.length; i++)
					parse(p.children[i]);
				break;
			

			case "MKNinjaFile.PlainLine":
				output ~= p.matches[0];
				break;
			case "MKNinjaFile.Function":
				parse(p.children[0]);
				break;

			case "MKNinjaFile.Include":
				for(int i = 0; i < p.matches.length; i++)
					loadFile(p.matches[i]);
				break;
			case "MKNinjaFile.ForEach":
				if ((p.matches.length != 3) && (p.matches.length != 4))
					throw new Exception("For each statement can only have 3 or 4 arguments. @foreach(directory, filename, toPrint, newLine = true)");
				auto files = dirEntries(basedir~p.matches[0], p.matches[1], SpanMode.breadth);
				bool newLine = (p.matches.length == 4) ? p.matches[3] == "true" : true;
				foreach (file ; files)
					output ~= p.matches[2].replace("@file", file.name) ~ (newLine ? "\n" : "");
				break;
			default:
				throw new Exception("'%s' is now implemented!", p.name);
		}
	}
	parse(tree);
	return output;
}
