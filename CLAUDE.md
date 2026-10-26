# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A small Java 17 demo project for a software-testing course (CTU). It shows one checkout/discount rule tested three ways: JUnit 5, JUnit 5 + Mockito, and TestNG. User-facing messages, Javadoc and the README are in Vietnamese. Keep new strings in Vietnamese too.

Business rule (VND, `BigDecimal`): below 500,000 there is no discount; from 500,000 the discount is 5%; from 1,000,000 it is 10%. The result is rounded `HALF_UP` to whole đồng (scale 0). A subtotal that is `null` or ≤ 0 throws `IllegalArgumentException`.

## Commands

The README's commands are written for Windows (PowerShell, and VS Code's bundled `mvn.cmd`). On this macOS machine `mvn` is **not on PATH**, so Maven commands need Maven installed first. The smoke check only needs the JDK:

```bash
# Smoke check, no external libraries (works with the system JDK)
mkdir -p target/smoke
javac -encoding UTF-8 -d target/smoke src/main/java/btp/*.java
java -cp target/smoke btp.SmokeCheck

# JUnit 5 + Mockito (default profile `junit-mockito`)
mvn clean test
mvn test -Dtest=CheckoutServiceTest#roundsFinalPriceToWholeVnd   # single test method

# TestNG (profile `testng`)
mvn -Ptestng clean test
mvn -Ptestng test -Dtest=CheckoutServiceTestNgTest
```

`clean` deletes `target/surefire-reports`. The course report needs the logs from both runs, so save the first run's results before you start the second.

## Architecture

- `CheckoutService`: pure pricing logic (`finalPrice`).
- `CheckoutApplicationService`: checks that `orderId` is not blank, calls `CheckoutService`, then saves the result through `OrderRepository`.
- `OrderRepository`: an interface with **no implementation**. Tests only ever use it as a Mockito mock.
- `SmokeCheck`: a `main`-based check with no dependencies, which the README uses for live demos.

## Two mutually exclusive test profiles

JUnit/Mockito and TestNG dependencies are never on the classpath at the same time, so `pom.xml` uses `maven-compiler-plugin` `testExcludes` to stop each profile from compiling the other framework's tests:

- The base build config excludes `CheckoutServiceTestNgTest.java`. This applies to the default `junit-mockito` profile.
- The `testng` profile replaces that list (`combine.self="override"`) and excludes the JUnit test files instead.

**When you add a test file**, add it to the exclude list of the profile it does *not* belong to, or that profile's build will fail to compile. Surefire only picks up files named `*Test.java`.

## Gotchas

- `assertEquals` on `BigDecimal` and Mockito's `verify(...).save(..., value)` both use `equals`, which is **scale-sensitive**. Expected values must have scale 0 (`new BigDecimal("900000")`, not `"900000.00"`). `SmokeCheck` uses `compareTo` instead.
- `target/surefire-reports` currently holds stale `GradeServiceTest` / `GradeReportServiceTest` reports copied from another project. They are not this project's results.
- `.idea/misc.xml` sets the language level to JDK 1.8, but the POM requires `release 17`.
- `.github/modernize/` contains hook scripts from a VS Code Java-upgrade extension. They are not part of the build.
- The README mentions a `deliverables/` folder (the Word report and slides). It is not in this directory.
