# Forth compiler and interpreter

### Implemented commands:
* .S - print stack
* Arithmetic operators ( + - * /, = <  )
* Logical operators (and, not)
* rot (a b c --> b c a)
* swap (a b --> b a)
* dup (a --> a a)
* drop (a --> )
* . ( a -- ) pop number from stack and print it
* Input/Output
  * key ( -- c) – read one symbol from stdin
  * emit ( c -- ) – write one symbol to stdout.
  * number ( -- n ) – read signed number from stdin
  * mem -  load on the stack a constant - the address of the start of the user memory.
* Memory Commands:
  * ! (data address -- ) – writes data to address;
  * @ (address -- value) – reads the contents of memory at address;
