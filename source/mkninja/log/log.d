module mkninja.log.log;

import std.stdio : stdout, stderr;
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
		}
		return mainLogger;
	}
	
	alias LogHandlerFunc = void function(LogLevel level, string message);

	void AttachHandler(LogHandlerFunc handler) {
		handlers ~= handler;
	}

	void opCall(S...)(LogLevel level, string format_, S args) {
		string message = format_;
		static if (args.length != 0)
			message = format(format_, args);

		foreach(LogHandlerFunc handler ; handlers)
			handler(level, message);
	}

	void Info(S...)(string format, S args) {
		Log(LogLevel.INFO, format, args);
	}

	void Warning(S...)(string format, S args) {
		Log(LogLevel.WARNING, format, args);
	}

	void Severe(S...)(string format, S args) {
		Log(LogLevel.SEVERE, format, args);
	}
private:
	static Log mainLogger = null;
	LogHandlerFunc[] handlers;

	static void TerminalHandler(LogLevel level, string message) {
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
		
		string levelText = format("[%c] %s", icon, message);
		
		if (level >= LogLevel.WARNING) {
			stderr.writeln(levelText);
			stderr.flush;
		} else {
			stdout.writeln(levelText);
			stdout.flush;
		}
	}
}

