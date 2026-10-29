#!/usr/bin/env bash
# In kết quả JUnit dạng cây (tên ca, ✔/✘) bằng JUnit Platform Console Launcher.
# Dùng: bash demo/cay-ket-qua.sh [tham số thêm cho launcher, ví dụ --include-tag luu-don]
set -euo pipefail
cd "$(dirname "$0")/.."
export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 21)}"
JUNIT_VERSION=$(mvn -o -q help:evaluate -Dexpression=junit.version -DforceStdout)
LAUNCHER=target/tools/junit-platform-console-standalone-$JUNIT_VERSION.jar

mvn -o -B -q test-compile dependency:build-classpath \
    -Dmdep.includeScope=test -Dmdep.outputFile=target/test-classpath.txt
[ -f "$LAUNCHER" ] || mvn -o -B -q dependency:copy \
    -Dartifact="org.junit.platform:junit-platform-console-standalone:$JUNIT_VERSION" \
    -DoutputDirectory=target/tools
MOCKITO_JAR=$(tr ':' '\n' < target/test-classpath.txt | grep '/mockito-core-')

# Mockito nạp dưới dạng agent nên launcher, Mockito và Byte Buddy phải nằm chung classpath của JVM.
java -Xshare:off -javaagent:"$MOCKITO_JAR" \
    -cp "$LAUNCHER:target/classes:target/test-classes:$(cat target/test-classpath.txt)" \
    org.junit.platform.console.ConsoleLauncher execute \
    --disable-banner --details=tree --include-engine=junit-jupiter \
    --scan-class-path target/test-classes "$@"
