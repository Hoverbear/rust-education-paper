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
    type: webpage
    URL: http://rust-lang.org/
  - id: rust-release
    title: Announcing Rust 1.0
    type: webpage
    URL: http://blog.rust-lang.org/2015/05/15/Rust-1.0.html
  - id: no-std
    type: webpage
    title: libcore
    URL: http://doc.rust-lang.org/book/no-stdlib.html
  - id: uls
    title: Ultra-Large-Scale Systems
    type: webpage
    URL: https://www.sei.cmu.edu/uls/
  - id: redis
    title: Redis
    type: webpage
    URL: http://redis.io/
  - id: redis-api
    title: A Fresh Look at Rust
    type: webpage
    author:
      - given: Armin
        family: Ronacher
    URL: http://lucumr.pocoo.org/2014/10/1/a-fresh-look-at-rust/#designing-apis
  - id: go-fn
    title: "Go Blog: Function Declaration"
    author:
        - given: Rob
          family: Pike
    type: webpage
    URL: https://blog.golang.org/gos-declaration-syntax
  - id: billion-dollar
    title: "Null References: The Billion Dollar Mistake"
    author:
        - given: Tony
          family: Hoare
    type: webpage
    URL: http://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare
  - id: abstraction
    title: "Abstraction without overhead: traits in Rust"
    author:
      - given: Aaron
        family: Turon
    type: webpage
    URL: http://blog.rust-lang.org/2015/05/11/traits.html
  - id: travis-docs
    title: "Rust, Travis, and Github Pages"
    author:
      - given: Andrew
        family: Hobden
    type: webpage
    URL: http://hoverbear.org/2015/03/06/rust-travis-github-pages/
  - id: rust-research
    title: "Rust: Academic Research"
    type: webpage
    URL: https://doc.rust-lang.org/nightly/book/academic-research.html
  - id: compatability
    title: Stability as a Deliverable
    type: webpage
    URL: https://doc.rust-lang.org/nightly/book/academic-research.html
    authors:
      - given: Aaron
        family: Turon
      - given: Niko
        family: Matsakis
  - id: release-schedule
    title: Scheduling the Trains
    type: webpage
    URL: http://blog.rust-lang.org/2014/12/12/1.0-Timeline.html
    author:
      - given: Aaron
        family: Turon
  - id: semantic-versioning
    title: Semantic Versioning
    type: webpage
    URL: http://semver.org/
  - id: rust-stackoverflow
    title: Rust Stack Overflow
    type: webpage
    URL: https://stackoverflow.com/questions/tagged/rust
  - id: coreutils
    title: uutils/coreutils
    type: webpage
    URL: https://github.com/uutils/coreutils
  - id: rust-boot
    title: Writing an OS in Rust in Tiny Steps
    type: webpage
    author:
      - given: Julia
        family: Evans
    URL: http://jvns.ca/blog/2014/03/12/the-rust-os-story/
  - id: zinc
    title: zinc.rs
    type: webpage
    URL: http://zinc.rs/
  - id: splint
    title: Splint
    type: webpage
    URL: http://splint.org/
  - id: region-cyclone
    title: "Region-Based Memory Management in Cyclone"
    type: webpage
    authors:
      - family: Grossman
      - family: Morrisett
      - family: Jim
      - family: Hicks
      - family: Wang
      - family: Cheney
    URL: http://209.68.42.137/ucsd-pages/Courses/cse227.w03/handouts/cyclone-regions.pdf
---

# The State of the OS Course

Concurrency, parallelism, memory management, process scheduling, deadlocks, mutexes, system calls, filesystems, and architectural considerations are all commonly taught concepts in Operating Systems courses. These topics can be a struggle to understand, even for determined students, due to their complex, low-level characteristics. Students are typically asked to use C or C++ to accomplish assignments on the above tasks.

Instructors may also find themselves struggling, as these assignments can be difficult to create, and at times nearly impossible to evaluate. Instructors and their markers desire assignments which are simple enough to fit into a few files, demonstrate understanding of failure modes, can be tested effectively in a preferrably automated fashion, and show students the caveats of their attempts to solve the problem. In many cases, a tradeoff is necessary. Building an interactive shell is a common, and much loved, assignment in which instructors must balance the number of features required with the time provided. Features such as pipes, background tasks, tab-completion, and environment variables are all desirable and interesting to implement, but contribute greatly to the complexity of the code, as well as the amount of time it takes to evaluate.

At the University of Victoria evaluation is typically done through an interactive demo involving the student and one of the teaching assistants. This method gives the student a chance to explain qualities and characteristics of their code, demonstrate it's features, and explain any possible bugs which may be discovered as the code is tested. Testing is often light and relatively incomplete due to time and technical constraints. Tools like `valgrind` and `clang` (with all warnings and lints flagged on) help in evaluation, but are not always used. We have found this to be a better method than the marker grading the student without any input from them, as it encourages a certain level of independence and creativity in the students, it also encourages students to improve their ability to explain their code. This method also gives the student immediate feedback that they may use on further assignments, rather than hearing back sometimes weeks later, often well into the next assignment.

# Introducing Rust

Rust (@rust) is a systems oriented ML-family language supported by Mozilla Research. It was originally developed by Graydon Hoare (TODO: Reference) and reaches it's first stable release on May 15, 2015 (@rust-release).

Rust offers a robust set of desirable features for systems code:

* Ahead-of-time compilation
* Zero-cost abstractions
* Move semantics
* Guaranteed memory safety
* Threads without data races
* Trait-based generics
* Pattern matching
* Type inference
* Minimal runtime (removable, @no-std)
* Efficient C bindings
* Robust static analysis

It accomplishes these features through a number of novel features largely built off it's type system and the borrow checker. Both will be covered below. The Rust community has been working to firmly position Rust as a powerful tool for programming in the large (@uls).

## Rust Basics

To someone familiar with C or any of the ML dialects the syntax of Rust will appear reasonably familiar. A 'Hello World' in Rust looks like the following:

```rust
fn main() {
    println!("Hello, world");
}
```

The only quality of the above code which may be at all suprising to programmers is the `!` at the end of the `println!`. This notifys the programmer **explicitly** that they are using a macro. This is a consistent quality of Rust code throughout the language.

> It is better to be explicit and promote understanding of what is occuring, than to expect the programmer to maintain all of this information in their head.

This quality does not do away with conciseness, or elegance of code. Community members have developed bindings for well-known tools like Redis (@redis) and found the APIs for equivalent Rust and Python actions of relatively similar "feel", despite the benefits of Rust's type system providing an additional safety net (@redis-api).

Rust does, however, have significant semantic differences compared to C-like languages. For variable declaration, Rust has the `let` keyword which is *immutable by default*, mutability is opt-in via `let mut`. The Rust compiler also enforces best practices, for example, introducing a file-level `const` which is not in all capitals is a compile-time error.(TODO: Check this is still the case)

As well, function definitions differ from C-like languages. This change makes function definitions easier to comprehend when dealing with complex parameters, generics, and return values. Numerous reasoning for why C's declaration syntax is inadequate were well explained by Rob Pike (@go-fn).

```rust
fn example_simple() {}
fn example_params(x: u64, y: &u64, z: &mut u64) {}
fn example_returns(x: u64) -> u64 {}
fn example_generic<U: Read>(reader: U) -> u64 {}
fn example_generic_alt<U>(reader: U) -> u64
    where U: Read {}
```

## A Strong Type System

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

## We Don't Need No `null`

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

## Results and `try!()`

`Result<T, E>` enum exists as either `Ok(T)` or `Err(E)` conveys the result of something which may fail with an error. Overall this type feels like an `Option<T>` as above, and is interacted with in largely the same way except that the `Err(E)` value contains an error type which details information about the error. Using Rust's `match` expression the user can act on various error conditions or success.

```rust
use std::io;
use std::error::Error;
// Create an error. (Normally raised from lib)
let error = io::Error::new(io::ErrorKind::Other,
    "I'm an example error!");
// The two result variants. Type notations usually
// not necessary except in small examples.
let success: Result<_, io::Error> = Ok("Success!");
let failure: Result<&str, _> = Err(error);
// Return either the value or the error description.
let val_or_desc = match success {
    Ok(val) => val,
    Err(ref e)  => e.description(),
};
```

It is a compiler warning to perform an action such as `file.read_to_string()` which returns a `Result<usize, Error>` and to not handle the error in some way. In Rust is it idiomatic for any recoverable error to be passed up the call stack to where it is sensibly handled. In approaching this idea newcomers typically struggle with the fact that an `io::Error` and a `Utf8Error` are different types. This is typically solved by creating a new `Error` which is an enumeration over the possible underlaying errors. Then there are the `Into<T>` and `From<T>` traits which can be implemented to provide seamless interaction.

```rust
pub enum MyError {
    Io(io::Error),
    Utf8(Utf8Error)
}
impl From<io::Error> for MyError {
    fn from(err: io::Error) -> Error {
        Error::Io(err)
    }
}
// ...
```

When working with functions which may return a `Result<T, E>` it is common to use the `try!()` macro. This macro expands to either unwrap the `T` value inside and assign it, or return the error up the call stack. This helps reduce visual 'noise' and assist in composition.

```rust
fn open_and_read() -> Result<usize, MyError> {
    let mut f = try!(File::open("foo.txt"));
    let mut s = String::new();
    let num_read = try!(f.read_to_string(&mut s));
    Ok(num_read)
}
```

Error handling in Rust is explicit, composable, and sane. There are no exceptions, nulls, 'special numbers' (like -1) or anything that may prevent the programmer from handling the error as *they* choose to, even if that is to simply `.unwrap()` it and crash on failure.

## Borrow and Move: Lose the GC

Memory management is hard, that's why programmers invented the garbage collector. These days there are tracing GCs, generational GCs, and all sorts of exotic algorithms to sweep up unused memory. This all arises from the archaic assumption that compilers cannot perform enough static analysis to accurately trace the lifetime of a value throughout the execution of a program. For many languages this is quite true, C being one of the primary offenders. In Rust there is the notion of moving, copying, and referencing.

Like C and C++, Rust features a powerful pointer system that allows programmers to make fine-grain, informed decisions about how values are stored, passed, and represented. Rust goes a step further, introducing the distinction between *immutably borrowing* (`&`), *mutably borrowing* (`&mut`), *copying* (`Copy` trait), and *moving* values. At any given time there may be any number of *immutable borrows*, meanwhile there may only be one *mutable borrow*, and a value may not be used in the function once it has been *moved* out.

This makes it simple for a programmer to observe a function signature and determine which values the function may mutate or consume, and which it may return. Using this information the compiler is able to determine the lifetime constraints of almost any value without additional notations. In (rare, complex) cases where it does require additional information the programmer can annotate lifetimes just as they would with generic types.

```rust
// `bool` has a `Copy` trait.
let foo = true;
// Immutable reference.
let ref_of_foo = &foo;
ref_of_foo = false; // Error
// Mutable reference.
let mut_ref = &mut foo;
mut_ref = false;
// Make a copy.
let other_foo = foo;
```

## Traits: Zero-cost Abstractions

Unlike many common languages today Rust does not use a class based or inheritance based system. Data is stored in `struct`s, primitives, or `enum`s which implement a set of traits that define how it interacts and which functions are available to it. To someone familiar with Java or C++, traits may feel like interfaces. For example, the `File` is a `struct` which implements `Read` and `Write` among other traits. Other structures like `TcpStream` and `UdpSocket` also implement the same `Read` and `Write` interface. Traits are zero-cost abstractions that act to encourage common interfaces and capabilities between like-structures. (@abstraction)

```rust
struct Thing {
    barred: bool,
}
trait Foo {
    // Implementor must define.
    fn bar(&mut self);
    // Default definition.
    fn do_bar(&mut self) { self.bar() }
}
impl Foo for Thing {
    fn bar(&mut self) {
        self.barred = true;
    }
}
```

## Static Analysis at the Core

Static analysis tools, like `splint` for C (@splint) are an invaluable tool for Operating Systems programming, particularly when working on large codebases with multiple programmers. These tools accomplish in-depth analysis of source code and attempt to derive information from the code to understand where potential mistakes or errors may occur. For languages like C they all have one big problem: C wasn't designed for static analysis.

Rust's type system and region based memory, based off the ideas of Cyclone (@region-cyclone), are particularly well suited to static analysis. Indeed, `rustc` itself performs a tremendous amount of static analysis even without the help of external tools. The type system carries all the information necessary for the compiler to understand all possible control flows of the program, all possible (recoverable) errors which arise, and the lifetimes of each region of memory.

Of particular interest is `rustc`'s "Borrow Checker" which analyzes and understands the pointer system (detailed above) and is able to verify data safety, even across multiple threads. The borrow checker is an area of active research (CITEME) and has thus far proven itself sound.

As a result of the static analysis done by `rustc` it is able to infer information about (but not limited to):

* Unused variables and functions.
* Unreachable code.
* Unsafe pointer sharing (multiple mutable pointers.)
* Unused `Result`s.
* Incorrect type matching.
* Lossy casts.
* Unclear lifetimes (asking for either clarity or refactoring.)

## Safety as a First-Class Goal

The concept of "Safety" in code is often poorly defined. In general, safety can be broken down into three categories:

* **Type Safety** is the ability of a language to prevent or discourage type errors, such as treating a `float` like an `int`. Rust and languages like Haskell excel here as their type systems are strong, explicit (but often inferred), and do not include the notion of a `null` that can go anywhere indiscriminately.
* **Memory Safety** is the ability of a language to reduce or eliminate the possibility of mistakes like writing a 64 bit value into a 32 bit space (overwriting unintended data), or multi-threaded mutable access to the same memory. Rust's borrow checker effectively eliminates data races in safe code.
* **Thread Safety** is the ability of a language to prevent inter-thread race conditions, such as one thread exiting when another thread is waiting on data from it. Rust provides some robust tools for managing thread pools integrated into it's type system, however some mistakes are still possible if the programmer works hard enough to accomplish them.

Rust advertises both type safety and data safety, accomplishing both very effectively. There is still research and development to be done before it can truthfully bill itself as thread-safe, but this type of safety is perhaps the most elusive.

## Tooling

One significant advantage of using Rust over its alternatives is its robust, opinionated set of tooling. The Rust standard distribution includes `rustc` (the compiler), `cargo` (a package manager and build tool), and `rustdoc` (a documentation generator). Currently there is work being done on a `rustfmt` which woud function the same as Go's venerable `gofmt`.

Package management is a feature Rust has inherited from several other modern languages. `cargo` behaves similar to Ruby's `bundler`, indeed it was created by the same person even! All package dependencies, build options, and tasks are defined in a `Cargo.toml` file. Package versions are kept in a `Cargo.lock` that `cargo` creates whenever it needs. There is no 'fetch' or 'install' command, dependencies are checked and (if necessary) pulled on `cargo build`, `test`, or `doc`.

Rust supports both *unit tests* and *integration tests* by default. Unit tests may appear wherever is appropriate in the code and are annotated by `#[test]`, it's common for designers to include a `test` module in their code. Integration tests are written in the `tests/` directory and allow a package to be tested as a depended upon library. Testing is done by simply invoking `cargo test` in the project directory. These features blow away barriers which programmers might face in other languages that would prevent them from bothering to test. Additionally, it makes marking Rust based projects very easy, all an instructor needs to do is provide (or replace) the `tests/` directory with an appropriate suite.

```rust
#[test]
fn test_passes() {
    assert_eq!(true, true);
}
#[test]
#[should_panic]
fn test_fails() {
    assert!(true == false);
}
```

Having a standardized, high quality documentation format is invaluable for programmers, and Rust facilitates this. Documentation comments are can be placed anywhere in the code using `///` for function level documentation or `//!` for module level documentation. Documentation is in a common markdown format, code samples included in the documentation are automatically processed as unit tests. Generating documentation is done by `cargo doc`, which generates HTML and manpage documentation. Many Rust projects even go so far as to automate the unit testing and documentation generation step and hook it into their git commits (@travis-docs).

# Research

Rust is born of strong research. It is strongly founded on a set of well reasoned, influential [papers](https://doc.rust-lang.org/nightly/book/academic-research.html
) (@rust-research). The language was originally developed by Graydon Hoare and is MIT licensed. There has been over 1017 contributors to the project, including signficant contributions by Mozilla Research, Samsung Research, and Tilde.

There are active researchers working on Rust and the language is rolling forward on a 6 week schedule, but all code compatible with current versions of Rust will be compatible with Rust until version 2.0 (@compatability). This schedule is the same as Mozilla's highly successful Firefox model (@release-schedule) and follows semantic versioning (@semantic-versioning). This makes the language a target for active feature and fix development, since it releases often, while keeping it stable for industrial use.

# Community

One of the biggest dangers in choosing a language that "Is not C" to teach operating systems in is that it can be very difficult for students to get help. There is very little operating systems development in languages like Python, C#, or Java and what does exist is often rather exotic, especially compared to the extremely well documented C problems that crop up.

Mozilla's IRC network hosts the popular #rust channel which regularly has over 800 members at any given time. [`crates.io`](http://crates.io/) hosts over 2300 'crates', Rust's nickname for a package. The language reached 1.0 on (FINDME) following (FINDME) years of development. The community is active and friendly with special interest groups hosting their own channels for various purposes. There are a number of active article feeds and active discussion on [Stack Overflow](https://stackoverflow.com/questions/tagged/rust
). (@rust-stackoverflow)

Best of all, there is active operating system development in Rust. There is a project to develop `coreutils` (@coreutils), a kernel (@rust-boot), and embedded system platforms (@zinc). At the time of writing, these projects are young enough that students could even contribute components upstream.

# A Comparison with C

`TODO: A few examples where C falls apart and the equivilent Rust code works, or gives a compiler error.`

# Tackling Common Problems

`TODO: Show a few solutions to problems like Dining Philosophers and do a qualitative evaluation of the differences in what they teach.`

# Future Work

# References
