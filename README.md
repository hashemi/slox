# slox

This is an interpreter of the Lox Language written in Swift.

This project follows Bob Nystrom's excellent book,
[Crafting Interpreters](http://www.craftinginterpreters.com)
which takes you through the process of writing an interpreter for a language
called Lox. The book is being released as chapters are completed, one chapter
at a time. I will try to keep up.

My main goal is to understand the process of writing an interpreter and how an
interpreter works. I'm intentionally re-producing the Java code in Swift as
faithfully as possible at first.

A secondary goal will be to refactor the code to make it more Swifty. Top
candidates for refactoring are:
* replacing some classes with structs or plain functions,
* using associated values with `TokenType` instead of stashing values in an
  `Any` property of `Token`, and
* string manipulation in the `Scanner` class, which I'm deferring until
  Swift 4's string overhaul is complete.

The book promises to later re-implement the language in C. I look forward to
seeing how that will bring insight to improve this Swift version, hopefully
without having to resort to any `UnsafePointer*` types.
