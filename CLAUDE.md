# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Code and demo for a CTU software-maintenance group assignment ("Bài tập nhóm số 1", topic *Công cụ hỗ trợ kiểm thử*). The task is to compare at least 3 tools of one category, pick one, and demo its maintenance-supporting features through a chain of scenarios. The group compares **JUnit (6.x, Jupiter API), TestNG and Spock**, all running the same test suite against one small Java 17 checkout module. This repo holds the code, logs and data, plus a generated draft of the Word report in `deliverables/` (Times New Roman 13, A4; yellow-highlighted placeholders are for the group to fill in). Once the group edits that `.docx` in Word, treat it as theirs: don't regenerate or overwrite it without asking. The group makes the slides themselves. User-facing strings, docs and Javadoc are in Vietnamese. Keep new ones in Vietnamese too.

Business rule (VND, `BigDecimal`): below 500,000 there is no discount; from 500,000 the discount is 5%; from 1,000,000 it is 10%. The result is rounded `HALF_UP` to whole đồng (scale 0). A subtotal that is `null` or ≤ 0 throws `IllegalArgumentException`.

## Commands

Maven comes from Homebrew. The `mvn` wrapper from brew falls back to brew's own (newest) OpenJDK when `JAVA_HOME` is unset, so always run with JDK 21:

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

mvn clean verify            # JUnit + Mockito (default profile `junit-mockito`), incl. JaCoCo 100% line/branch gate
mvn -Ptestng clean test     # TestNG + Mockito
mvn -Pspock clean test      # Spock (Groovy)
mvn test -Dtest=CheckoutServiceJUnitTest#calculatesFinalPrice   # single test
mvn -o ...                  # offline, once ~/.m2 is populated (use for live demos)

bash demo/do-so-lieu.sh     # re-measure comparison metrics -> demo-output/01-so-lieu.txt
bash demo/cay-ket-qua.sh    # JUnit results as a tree via Console Launcher (args pass through, e.g. --include-tag luu-don)
mvn test -Dgroups=luu-don   # JUnit tags: tinh-gia, luu-don, vip, hieu-nang
bash demo/kich-ban.sh kb3    # replay maintenance scenario(s) kb1..kb5|tat-ca in temp git worktrees
bash demo/video.sh [N]      # scene-by-scene demo for video recording, pauses before each command (TU_DONG=1 = no pauses)

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
- After tag `gd1-comparison` (pinned for the measurements), only the **JUnit** suite evolves. It showcases features listed in `docs/tinh-nang-junit.md`: `@Nested`, `@CsvFileSource` (TC04–TC13 data live in `src/test/resources/bang-gia.csv`), `@Tag`, `@Timeout`, and `MockitoExtension` with `@Spy`/`@InjectMocks`/`@Captor`. TestNG/Spock suites stay as the comparison baseline. Maintenance-scenario tests (TC17+) are JUnit-only.
- The `junit-mockito` profile also wires JaCoCo (report bound to `test` phase, `SmokeCheck` excluded), Mockito as `-javaagent` via `maven-dependency-plugin:properties` + `@{argLine}`, and Surefire's JUnit 5 reporters so display names appear in XML/console.

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
- Even with the JUnit 5 reporters, Surefire's console `<<< FAILURE!` line still shows `[4]`. That is why JUnit assertion messages are prefixed with the case id. JUnit 6 quotes text arguments in display names unless `quoteTextArguments = false`.
- In the `testng` profile Mockito still prints "self-attaching" warnings (only the JUnit profile loads it as an agent). These are expected, not failures.
- Don't copy `target/site/jacoco` numbers after a `-Dtest=` run: coverage then reflects only the selected tests.
- Branch `loi-nguong-500k` contains a **deliberate** bug (`>` instead of `>=` at 500,000) for demoing failure messages. Never merge it into `main`.
- Git tags mark the phases (`gd0-baseline`, `gd1-comparison`, `gd2-features`) and maintenance scenarios KB1–KB5 (`kbN-truoc` / `kbN-sau`, plus `kb4-loi`), documented in `docs/kich-ban-bao-tri.md`. Some tagged commits on `main` are **intentionally red** (`kb3-truoc`, `kb4-loi`, `kb5-truoc`). `demo/kich-ban.sh` depends on these tags, so don't move or delete them.
- The coverage gate fails `mvn verify` whenever a `-Dtest=` subset is run, so use `mvn test -Dtest=…` for single tests.
- Scripts run under macOS's bash 3.2: no bash-4 features (`${x^^}`, associative arrays, `mapfile`).
- `.github/modernize/` is VS Code Java-upgrade extension residue. `.idea` says JDK 1.8 but the POM requires release 17.
