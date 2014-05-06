module mkninja.grammer;

import pegged.grammar;

mixin(grammar(`
MKNinjaFile:
	File <- ( Function / PlainLine )+
	
	DQChar              <- EscapeSequence
			               / !doublequote .
	EscapeSequence      <- backslash ( quote
	                         		 / doublequote
	                          		 / backslash
	                         		 / [abfnrtv]
	                         		 )
	
	String              <~ :doublequote (DQChar)* :doublequote
	Bool				<- "true" / "false"
	Number				<~ '-'? [0-9]+ ('.' ( [0-9]+ ) ? ) ?

	Arg                 <- String / Bool / Number
	FunctionArgs        <- POpen ( Arg ( Next Arg )* )? PClose
	
	FunctionIdentifier  <- :'@'
	N                   <- :' '*
	POpen               <- N :'(' N
	PClose              <- N :')' N
	Next                <- N :',' N


	PlainLine           <~ ~(!endOfLine !FunctionIdentifier .)* endOfLine? 
	Function            <- FunctionIdentifier ( Include / ForEach ) :endOfLine?

	Include             <- :"include" FunctionArgs
	ForEach             <- :"foreach" FunctionArgs

	
`));