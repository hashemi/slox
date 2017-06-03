# slox

This is an interpreter of the Lox Language written in Swift.

This project follows Bob Nystrom's excellent book,
[Crafting Interpreters](http://www.craftinginterpreters.com)
which takes you through the process of writing an interpreter for a language
called Lox. The book is being released as chapters are completed, one chapter
at a time.

## Progress
As of 3 Jun 2017, this code is up to date with the book. The following chapters
are implemented:
* Scanning
* Representing Code
* Parsing Expressions
* Evaluating Expressions
* Statements and State

## Goals & Design
The main goal is to write a Lox interpreter in Swift. A secondary goal is to
demonstrate Swift's strengths. The project takes advantage of Swift's enums
and extensions to implementer the interpreter in a type-safe, clear and
concise way.

The reference Java implementation uses runtime type checking and casting to deal
with Lox values. It stores the values using Java's `Object` type, which means
that the compiler has no idea what the data is. The programmer is responsible
for making sure that all of the possible value types are accounted for in all
parts of the program that need to handle them. This can become very messy very
quickly as the program gets larger in size. An equivalent implementation in
Swift could use the `Any` (or worse, `Any?`) type. But there's a better way.

Enums can be used restrict the possible Lox values. The Swift compiler will
insist that switch statements are exhaustive, which guarantees that all
possibilities are accounted for any time you work with those values. If in the
future you decide to add a new kind of value but forget to account for it in
code that you wrote in the past, the compiler will remind you to update your
code and your program won't compile until you do so. The syntax is also more
compact and readable than runtime checking and casting.

A similar issue is providing a systematic way of dealing with different kinds
of Lox expressions and statements. In the Java implementation, the visitor
pattern is used. It is so verbose and requires so much boilerplate code that one
of the first pieces of code you will write is a code generator to produce the
protocols required to implement the visitor pattern.

The visitor pattern is like poor-mans enum type for object-oriented languages.
With Swift, you get to use enums natively. The visitor pattern is redundant.
Instead of having an abstract base class with an number of subclasses
representing the different possibilities, you represent them as enum cases. A
visitor protocol is not required, you simply use a `switch` statement.
Extensions make it possible to split this code into separate files while keeping
the functionality within the relevant types. You don't need a separate Abstract
Syntax Tree Printer class, you can get the AST of an expression as a string by
accessing the expression's `ast` computed property.

## Alternatives
* Alejandro Martinez
[beat me to the port and name](https://github.com/alexito4/slox).

* Bob Nystrom lists ports in different languages on the
[books wiki on GitHub](https://github.com/munificent/craftinginterpreters/wiki/Lox-implementations).

## License
MIT
