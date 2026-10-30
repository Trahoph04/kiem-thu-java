#!/usr/bin/env bash
# Chạy bộ ca chung trên JUnit, TestNG và Spock với mã nguồn hiện tại, rồi in bảng kết quả từng ca.
# Dùng: bash demo/so-sanh-truc-tiep.sh [tệp .json để lưu kết quả cho bảng tổng hợp]
set -uo pipefail
cd "$(dirname "$0")/.."
export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 21)}"
XML=$(mktemp -d)
trap 'rm -rf "$XML"' EXIT

for p in junit-mockito:JUnit testng:TestNG spock:Spock; do
    profile=${p%%:*}; ten=${p#*:}
    printf '\n\e[1m▶ %s\e[0m   \e[2m$ mvn -o -P%s clean test\e[0m\n' "$ten" "$profile"
    mvn -o -B -P"$profile" clean test 2>&1 \
        | grep --line-buffered -E '^\[(INFO|ERROR)\] (Running |Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+, Time)' \
        | sed -E 's/^\[[A-Z]+\] /   /; s/ -- in / – /'
    cp -R target/surefire-reports "$XML/$profile"
done

python3 demo/bang-ket-qua.py bang "$XML/junit-mockito" "$XML/testng" "$XML/spock" ${1:+--luu "$1"}
