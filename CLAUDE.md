# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Code and demo for a CTU software-maintenance group assignment ("Bài tập nhóm số 1", topic *Công cụ hỗ trợ kiểm thử*). The task is to compare at least 3 tools of one category, pick one, and demo its maintenance-supporting features through a chain of scenarios. The group compares **JUnit 5, TestNG and Spock**, all running the same test suite against one small Java 17 checkout module. This repo holds only code, logs and data for the report. The group writes the Word report and slides themselves. User-facing strings, docs and Javadoc are in Vietnamese. Keep new ones in Vietnamese too.

Business rule (VND, `BigDecimal`): below 500,000 there is no discount; from 500,000 the discount is 5%; from 1,000,000 it is 10%. The result is rounded `HALF_UP` to whole đồng (scale 0). A subtotal that is `null` or ≤ 0 throws `IllegalArgumentException`.

## Commands

Maven comes from Homebrew. The `mvn` wrapper from brew falls back to brew's own (newest) OpenJDK when `JAVA_HOME` is unset, so always run with JDK 21:

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

mvn clean test              # JUnit 5 + Mockito (default profile `junit-mockito`)
mvn -Ptestng clean test     # TestNG + Mockito
mvn -Pspock clean test      # Spock (Groovy)
mvn test -Dtest=CheckoutServiceJUnitTest#calculatesFinalPrice   # single test
mvn -o ...                  # offline, once ~/.m2 is populated (use for live demos)

bash demo/do-so-lieu.sh     # re-measure comparison metrics -> demo-output/01-so-lieu.txt

# Dependency-free smoke check
mkdir -p target/smoke && javac -encoding UTF-8 -d target/smoke src/main/java/btp/*.java && java -cp target/smoke btp.SmokeCheck
```

`clean` deletes `target/surefire-reports`, so logs worth keeping go in `demo-output/` (tracked in git).

## Architecture

- `CheckoutService`: pure pricing logic (`finalPrice`).
- `CheckoutApplicationService`: checks that `orderId` is not blank, calls `CheckoutService`, then saves through `OrderRepository`.
- `OrderRepository`: an interface with **no implementation**. Tests only ever mock it (Mockito, or Spock's `Mock()`).
- `docs/test-cases.md` is the source of truth for the shared cases TC01–TC16 (18 executions). **All three tools must implement exactly the same cases.** A change to one tool's tests must be mirrored in the other two, and the mapping table in that doc must be updated.
- `docs/so-sanh-cong-cu.md` holds the measured comparison and the weighted scoring that leads to the recommendation of JUnit + Mockito.

## Three mutually exclusive test profiles

The three frameworks are never on the classpath together. Profiles isolate them by **file-name convention**, using `maven-compiler-plugin` `testExcludes` and Surefire `includes`:

| Profile | Test files | Excludes |
|---|---|---|
| `junit-mockito` (default) | `src/test/java/**/*JUnitTest.java` | base config excludes `*TestNgTest.java` |
| `testng` | `src/test/java/**/*TestNgTest.java` | overrides to exclude `*JUnitTest.java` |
| `spock` | `src/test/groovy/**/*Spec.groovy` (compiled by GMavenPlus) | excludes all `*.java` tests; Surefire includes `*Spec` |

Follow the naming convention and new test files need no POM edits. A file that matches no convention compiles in the default profile and breaks it.

## Gotchas

- `BigDecimal` equality is **scale-sensitive** in JUnit/TestNG `assertEquals` and in Mockito `verify` (expected values must be `new BigDecimal("900000")`, not `"900000.00"`). It is **not** scale-sensitive in Spock, because Groovy `==` uses `compareTo`.
- Surefire counts Spock data-driven feature containers as extra tests: the suite reports 21, but only 18 real executions happen.
- With Surefire's default reporters, JUnit `@DisplayName` and `@ParameterizedTest(name=…)` names are not shown (failures show `[4]` instead of `TC07`).
- Mockito prints "self-attaching" / dynamic-agent warnings on JDK 21. These are expected, not failures.
- Branch `loi-nguong-500k` contains a **deliberate** bug (`>` instead of `>=` at 500,000) for demoing failure messages. Never merge it into `main`.
- Git tags mark the phases: `gd0-baseline`, `gd1-comparison`, … Later maintenance scenarios use `kbN-truoc` / `kbN-sau` tag pairs.
- The README still describes the old Windows/PowerShell workflow (to be rewritten for macOS in the demo-packaging phase). `.github/modernize/` is VS Code Java-upgrade extension residue. `.idea` says JDK 1.8 but the POM requires release 17.
