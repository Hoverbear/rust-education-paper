---
title: Understanding Over Guesswork
author:
  - Andrew Hobden
  - Yvonne Coady
tags: [Education, Rust, Operating Systems]
abstract: |
  We discuss the merits of instructing operating systems courses using the modern systems programming language Rust. (TODO: Longer, better, stronger, faster)
references:
  - id: rust
    title: Rust
    URL: http://rust-lang.org/
  - id: rust-release
    title: Announcing Rust 1.0
    URL: http://blog.rust-lang.org/2015/05/15/Rust-1.0.html
  - id: no-std
    title: libcore
    URL: http://doc.rust-lang.org/book/no-stdlib.html
  - id: uls
    title: Ultra-Large-Scale Systems
    URL: https://www.sei.cmu.edu/uls/
  - id: redis
    title: Redis
    URL: http://redis.io/
  - id: redis-api
    title: A Fresh Look at Rust
    URL: http://lucumr.pocoo.org/2014/10/1/a-fresh-look-at-rust/#designing-apis
  - id: go-fn
    title: "Go Blog: Function Declaration"
    URL: https://blog.golang.org/gos-declaration-syntax
  - id: billion-dollar
    title: "Null References: The Billion Dollar Mistake"
    author: 
        - given: Tony
          family: Hoare
    URL: http://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare
---

# The State of the OS Course

Concurrency, parallelism, memory management, process scheduling, deadlocks, mutexes, system calls, filesystems, and architectural considerations are all commonly taught concepts in Operating Systems courses. These topics can be a struggle to understand, even for determined students, due to their complex, low-level characteristics. Students are typically asked to use C or C++ to accomplish assignments on the above tasks.

Instructors may also find themselves struggling, as these assignments can be difficult to create, and at times nearly impossible to evaluate. Instructors and their markers desire assignments which are simple enough to fit into a few files, demonstrate understanding of failure modes, can be tested effectively in a preferrably automated fashion, and show students the caveats of their attempts to solve the problem. In many cases, a tradeoff is necessary. Building an interactive shell is a common, and much loved, assignment in which instructors must balance the number of features required with the time provided. Features such as pipes, background tasks, tab-completion, and environment variables are all desirable and interesting to implement, but contribute greatly to the complexity of the code, as well as the amount of time it takes to evaluate.

At the University of Victoria evaluation is typically done through an interactive demo involving the student and one of the teaching assistants. This method gives the student a chance to explain qualities and characteristics of their code, demonstrate it's features, and explain any possible bugs which may be discovered as the code is tested. Testing is often light and relatively incomplete due to time and technical constraints. Tools like `valgrind` and `clang` (with all warnings and lints flagged on) help in evaluation, but are not always used. We have found this to be a better method than the marker grading the student without any input from them, as it encourages a certain level of independence and creativity in the students, it also encourages students to improve their ability to explain their code. This method also gives the student immediate feedback that they may use on further assignments, rather than hearing back sometimes weeks later, often well into the next assignment.

## Challenges

`TODO: Survey some OS instructors to figure out what challenges they face`

## Finding a Better Place

`TODO: Introduce Rust and briefly mention other alternatives. Perhaps a comparison chart.`

# Introducing Rust

Rust @rust is a systems oriented ML-family language supported by Mozilla Research. It was originally developed by Graydon Hoare (TODO: Reference) and reaches it's first stable release on May 15, 2015 @rust-release.

Rust offers a robust set of desirable features for systems code:

* Zero-cost abstractions
* Move semantics
* Guaranteed memory safety
* Threads without data races
* Trait-based generics
* Pattern matching
* Type inference
* Minimal runtime (removable @no-std)
* Efficient C bindings
* Robust static analysis

It accomplishes these features through a number of novel features largely built off it's type system and the borrow checker. Both will be covered below. The Rust community has been working to firmly position Rust as a powerful tool for programming in the large @uls.

## Rust Basics

To someone familiar with C or any of the ML dialects the syntax of Rust will appear reasonably familiar. A 'Hello World' in Rust looks like the following:

```rust
fn main() {
    println!("Hello, world");
}
```

The only quality of the above code which may be at all suprising to programmers is the `!` at the end of the `println!`. This notifys the programmer **explicitly** that they are using a macro. This is a consistent quality of Rust code throughout the language.

> It is better to be explicit and promote understanding of what is occuring, than to expect the programmer to maintain all of this information in their head.

This quality does not do away with conciseness, or elegance of code. Community members have developed bindings for well-known tools like Redis @redis and found the APIs for equivalent Rust and Python actions of relatively similar "feel", despite the benefits of Rust's type system providing an additional safety net @redis-api.

Rust does, however, have significant semantic differences compared to C-like languages. For variable declaration, Rust has the `let` keyword which is *immutable by default*, mutability is opt-in via `let mut`. The Rust compiler also enforces best practices, for example, introducing a file-level `const` which is not in all capitals is a compile-time error.(TODO: Check this is still the case)

As well, function definitions differ from C-like languages. This change makes function definitions easier to comprehend when dealing with complex parameters, generics, and return values. Numerous reasoning for why C's declaration syntax is inadequate were well explained by Rob Pike @go-fn.

```rust
fn example_simple() {}
fn example_params(x: u64, y: &u64, z: &mut u64) {}
fn example_returns(x: u64) -> u64 {}
fn example_generic<U: Read>(reader: U) -> u64 {}
fn example_generic_alt<U>(reader: U) -> u64 where U: Read {}
```

### A Strong Type System

In some problem areas it is desirable to have a dynamic type system, particularly in higher level code. Implicit, possibly lossy data conversions can often be dangerous in system code. It is common for OS students to accidently take a pointer as a value, or vice versa. It would be desirable to have a stronger type system.

For example, in C:

```c
void main() {
    float foo = 1.1;
    // Lossy conversion.
    int bar = foo;  // No error.
    // Possibly unintended conversion.
    int baz = &foo; // Compile-time Warning.
}
```

Conversely, in Rust explicit conversions are required:

```rust
fn main() {
    let foo = 1.1;
    // Lossy converstion.
    let bar = foo as u64;
    // Potentially unintended conversion.
    let baz = &foo as u64; // Compile-time error.
}
```

The programmer is not *prevented* from doing these things, Rust only ensures that it is actually the intended action.

### On the Lack of `null`

Cited by its creator (@billion-dollar) as a 'billion-dollar mistake' `null` is one of the most dangerous thorns in a coder's toolbox. For example, every time a programmer wishes to `malloc` they must change for the pointer to be a `null`, libraries return it often without forewarning. This all happens implictly, the author of the code must keep all of this information in their head. The consequences for making a mistake could be dramatic in lower level code. Segfaults, deadlocks, and system failure are all very real possibilities when exploring complex OS code.

Many functional languages like Haskell and F# have the concept of an `Option`, a concept that Rust shares. Instead of needing to be aware of and check for `null` at every occurance, the language semantics require the programmer to explicitly decide on the control flow for all values. It is common for newcomers to the language to dislike the "noise" this brings to the code, but once they understand the benefits of this design choice, and the ways to work with it, these complaints tend fade.

In Rust the `Option<T>` enum exists as either a `Some(T)` or a `None`. Rust provides a number of techniques for working with this type. First, is the simple "just crash if it doesn't work" call `.unwrap()`, then there is `.unwrap_or(some_default)`. As well there are functions like `.is_some()` and `.is_none()` which function as expected. It's also possible work work with an optional value without unwrapping it. It is very common to utilize Rust's `match` expression to handle control flow and unwrap enumerated values.

```rust
// Create a `Some(T)` and a None.
let maybe_foo = Some(0);
let not_foo = None;
// Unwrapping.
let foo = maybe_foo.unwrap();
let default = not_foo.unwrap_or(1);
let matched = match maybe_foo {
    Some(x) => x,
    None => -1,
}
// Mapping
let mapped = maybe_foo.map(|x| x as f64);
```

### Handling Errors

`Result<T, E>` enum exists as either `Ok(T)` or `Err(E)` conveys the result of something which may fail with an error.

### Borrow and Move Semantics

### Traits

## Safety as a First-Class Goal

`TODO: Discuss "safety" and define it clearly, show how Rust accomplishes this.`

## Zero-cost Abstractions

`TODO: Discuss why Rust's abstractions are different than, say, Java's, and why this is appropriate for systems.`

## Composition over Inheritance

`TODO: Talk about how traits resonate with the UNIX philosophy and why this matters.`

## Static Analysis at the Core

`TODO: Discuss the power of static analysis.`

## Tooling

`TODO: Discuss tooling, testing, and automation.`

# A Comparison with C

`TODO: A few examples where C falls apart and the equivilent Rust code works, or gives a compiler error.`

# Tackling Common Problems

`TODO: Show a few solutions to problems like Dining Philosophers and do a qualitative evaluation of the differences in what they teach.`

# Future Work

# References
