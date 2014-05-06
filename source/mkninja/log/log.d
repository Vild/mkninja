module mkninja.log.log;

import mkninja.log.terminal : stdout, stderr, Color;
import std.traits : isSomeChar, isAggregateType, isSomeString, isIntegral, isBoolean;
import std.conv : toTextRange;
import std.string : format;

enum LogLevel {
	VERBOSE,
	DEBUG,
	INFO,
	WARNING,
	SEVERE
};

class Log {
public:
	static Log MainLogger() { 
		if (mainLogger is null) {
			mainLogger = new Log();
			mainLogger.AttachHandler(&TerminalHandler);
			stdout.restoreDefaults;
			stderr.restoreDefaults;
		}
		return mainLogger;
	}
	
	alias LogHandlerFunc = void function(LogLevel level, string module_, string message);

	void AttachHandler(LogHandlerFunc handler) {
		handlers ~= handler;
	}

	void opCall(S...)(LogLevel level, string module_, string format_, S args) {
		string message = format_;
		static if (args.length != 0)
			message = format(format_, args);

		foreach(LogHandlerFunc handler ; handlers)
			handler(level, module_, message);
	}

	void Info(S...)(string module_, string format, S args) {
		Log(LogLevel.INFO, module_, format, args);
	}

	void Warning(S...)(string module_, string format, S args) {
		Log(LogLevel.WARNING, module_, format, args);
	}

	void Severe(S...)(string module_, string format, S args) {
		Log(LogLevel.SEVERE, module_, format, args);
	}
private:
	static Log mainLogger = null;
	LogHandlerFunc[] handlers;

	static void TerminalHandler(LogLevel level, string module_, string message) {
		char icon = ' ';

		Color fg = Color.white;
		Color bg = Color.black;
		bool bold = false;

		switch (level) {
			case LogLevel.VERBOSE:
				icon = '&';
				fg = Color.cyan;
				bg = Color.black;
				bold = false;
				break;
			case LogLevel.DEBUG:
				icon = '%';
				fg = Color.green;
				bg = Color.black;
				bold = false;
				break;
			case LogLevel.INFO:
				icon = '*';
				fg = Color.white;
				bg = Color.black;
				bold = false;
				break;
			case LogLevel.WARNING:
				icon = '#';
				fg = Color.white;
				bg = Color.yellow;
				bold = true;
				break;
			case LogLevel.SEVERE:
				icon = '!';
				fg = Color.white;
				bg = Color.red;
				bold = true;
				break;
			default:
				icon = '?';
				break;
		}

		string levelText = format("[%c] [%s]\t %s", icon, module_, message);

		stdout.writeln;
		stdout.bold = bold;
		stdout.foregroundColor = fg;
		stdout.backgroundColor = bg;
		stdout.write(levelText);
		stdout.flush;
		stdout.restoreDefaults;
	}
	static void StdTerminalHandler(LogLevel level, string module_, string message) {
		char icon = ' ';
		
		switch (level) {
			default:
				break;
			case LogLevel.INFO:
				icon= '*';
				break;
			case LogLevel.WARNING:
				icon = '#';
				break;
			case LogLevel.SEVERE:
				icon = '!';
				break;
		}
		
		string levelText = format("[%c] [%s]\t %s", icon, module_, message);
		
		if (level >= LogLevel.WARNING) {
			stderr.writeln(levelText);
			stderr.flush;
		} else {
			stdout.writeln(levelText);
			stdout.flush;
		}
	}
}

