# slox

This is an interpreter of the Lox Language written in Swift.

This project follows Bob Nystrom's excellent book,
[Crafting Interpreters](http://www.craftinginterpreters.com)
which takes you through the process of writing an interpreter for a language
called Lox. The book is being released as chapters are completed, one chapter
at a time. I will try to keep up.

My main goal is to understand the process of writing an interpreter and how an
interpreter works. A secondary goal is to take advantage of Swift's features
and idioms to make sure that the port remains "Swifty".

The book promises to later re-implement the language in C. I look forward to
seeing how that will bring insight to improve this Swift version, hopefully
without having to resort to too many `Unsafe*` types.

## Progress
As of 3 Jun 2017, the code is up to date with the book. The following chapters
are implemented:
* Scanning
* Representing Code
* Parsing Expressions
* Evaluating Expressions
* Statements and State

## Alternatives
* Alejandro Martinez
[beat me to the port and name](https://github.com/alexito4/slox).

* Bob Nystrom lists ports in different languages on the
[books wiki on GitHub](https://github.com/munificent/craftinginterpreters/wiki/Lox-implementations).
