#!/usr/bin/env bash
# Đo số liệu so sánh JUnit 5 / TestNG / Spock trên cùng bộ 16 ca kiểm thử.
# Chạy từ thư mục gốc dự án: bash demo/do-so-lieu.sh
set -euo pipefail
cd "$(dirname "$0")/.."
export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 21)}"
RUNS="${RUNS:-3}"
OUT=demo-output/01-so-lieu.txt
: > "$OUT"
log() { echo "$*" | tee -a "$OUT"; }

log "Máy: $(sysctl -n machdep.cpu.brand_string) | $(mvn -v | grep 'Java version' | cut -d, -f1) | $(mvn -v | head -1 | cut -d' ' -f1-3)"
log ""
log "== Dòng mã test (bỏ dòng trống, package, import)"
loc() { cat "$@" | grep -vE '^\s*$|^\s*(package|import) ' | wc -l | tr -d ' '; }
log "junit-mockito: $(loc src/test/java/btp/*JUnitTest.java)"
log "testng:        $(loc src/test/java/btp/*TestNgTest.java)"
log "spock:         $(loc src/test/groovy/btp/*Spec.groovy)"

log ""
log "== Dòng cấu hình riêng của từng profile trong pom.xml"
for p in junit-mockito testng spock; do
    n=$(awk -v id="<id>$p</id>" '/<profile>/{buf=0; on=1} on{buf++} index($0,id){hit=1} /<\/profile>/{if(hit){print buf}; on=0; hit=0}' pom.xml)
    log "$p: $n dòng"
done

log ""
log "== Thư viện trên test classpath (kể cả phụ thuộc bắc cầu)"
for p in junit-mockito testng spock; do
    cp_file=$(mktemp)
    mvn -o -B -q -P"$p" dependency:build-classpath -Dmdep.includeScope=test -Dmdep.outputFile="$cp_file" >/dev/null
    jars=$(tr ':' '\n' < "$cp_file" | grep -c '\.jar$' || true)
    kb=$(tr ':' '\n' < "$cp_file" | xargs du -k | awk '{s+=$1} END {print s}')
    log "$p: $jars jar, $(awk -v k="$kb" 'BEGIN {printf "%.1f", k/1024}') MB"
    rm -f "$cp_file"
done

log ""
log "== Thời gian (giây): toàn bộ 'mvn clean test' | riêng phần chạy test (Surefire)"
run_log=$(mktemp)
for p in junit-mockito testng spock; do
    for i in $(seq 1 "$RUNS"); do
        start=$(perl -MTime::HiRes=time -e 'printf "%.3f", time')
        mvn -o -B -P"$p" clean test > "$run_log" 2>&1
        end=$(perl -MTime::HiRes=time -e 'printf "%.3f", time')
        tests=$(grep -E 'Tests run: .*-- in ' "$run_log" | sed -E 's/.*Time elapsed: ([0-9.]+) s.*/\1/' | awk '{s+=$1} END {printf "%.3f", s}')
        log "$p lần $i: $(awk -v a="$start" -v b="$end" 'BEGIN {printf "%.2f", b-a}') | $tests"
    done
done
rm -f "$run_log"
log ""
log "Đã ghi vào $OUT"
