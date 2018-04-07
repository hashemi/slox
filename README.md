# slox

This is an interpreter of the Lox Language written in Swift.

This project follows Bob Nystrom's excellent book,
[Crafting Interpreters](http://www.craftinginterpreters.com)
which takes you through the process of writing an interpreter for a language
called Lox.

In the book, the language is implemented as an tree-walking interpreter
in Java and a bytecode compiler and VM in C. This project ports the
Java version to Swift. It now complete in Dec 2017. 🎉

## Related Projects

* [bslox](https://github.com/hashemi/bslox) is my Swift port of the
bytecode/VM, C version.

* [CompilerKit](https://github.com/hashemi/CompilerKit) is a Swift
collection data structures and algorithms that can be used in
constructing a compiler.

## Tests
The test suite is from the reference Java implementation. To run the
tests:

```shell
$ swift build
$ ./test_swift.py chap13_inheritance
```

Almost all tests pass. The only two exceptions are class and method
equality.

## Goals & Design
The main goal is to write a Lox interpreter in Swift while demonstrating
Swift's strengths. The project takes advantage of Swift's enums and
extensions to implementer the interpreter in a type-safe, clear and concise
way.

**Enums for type safety.** The reference Java implementation stores and
exchanges all Lox data as Java `Object` types. This neccessates runtime
type checks and coerced type casting. In this Swift implementation, enums
are used instead to create a restricted and explicit set of possible Lox
data types with the actual data attached as associated values to the
enum cases in the correct Swift types. There's no type casting and the
`Any` type (Swift's equivalent to `Object`) is not used in this project.

**Enums make the visitor pattern redundant.** As Bob Nystrom says in the
book:

> The Visitor pattern is really about approximating the functional style
> within an OOP language.

Fortunately, it's totally unnecessary in Swift! As a *multi-paradigm*
programming laugnage, Swift has support for both the OOP and
functional-styles of programming. Instead of using objects, the Swift
version uses enum cases with associated values to represent the
different kinds of expressions that get parsed. Different operations
you need to perform on the expressions can then be written as simple
recursive functions with a switch statement over the differet kinds
of expressions.

This is an important improvement since the visitor pattern adds so much
cruft and boilerplate code to the Java version that one of the first
things you have to do is write a little code generator utility to
produce the supporting Java code.

**Extensions for better code organization.** Swift's extensions allow
you to add to an existing data type outside of its inital declaration.
For example, the abstract syntax tree printer is written as a function
in a source file separate from the expression data type, `Expr`.
However, it is added to the `Expr` data type as a simple computed
property that returns a string and can be accessed like this:

```swift
expression.ast
```

Without extensions, you would need to make an `ast` function that
takes the expression as an argument. Since the function is now in
the global namespace, it would be a bad idea to just call it `ast`.
This is what the Java implementation looks like:

```java
new AstPrinter().print(expression)
```

## Alternatives
* A list of ports is available in the
[books GitHub wiki](https://github.com/munificent/craftinginterpreters/wiki/Lox-implementations).

## License
MIT
