#!/usr/bin/env bash
# Chạy lại chuỗi kịch bản bảo trì KB1–KB5 trên các tag git, mỗi mốc trong một worktree tạm
# nên thư mục đang mở không bị thay đổi.
# Dùng: bash demo/kich-ban.sh [kb1|kb2|kb3|kb4|kb5|tat-ca]   (mặc định: tat-ca)
set -uo pipefail
cd "$(dirname "$0")/.."
export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 21)}"
LOG_DIR=target/demo-logs
mkdir -p "$LOG_DIR"
WORK=$(mktemp -d)
don_dep() {
    local d
    for d in "$WORK"/*; do [ -d "$d" ] && git worktree remove --force "$d" >/dev/null 2>&1; done
    rm -rf "$WORK"
    git worktree prune
}
trap don_dep EXIT

DAM=$'\e[1m'; XANH=$'\e[32m'; DO=$'\e[31m'; MO=$'\e[2m'; HET=$'\e[0m'

tieu_de() { printf '\n%s══ %s ══%s\n' "$DAM" "$*" "$HET"; }

# chay_tai <tag> <mô tả> [JAVA_HOME=...] <tham số mvn...>
chay_tai() {
    local tag=$1 mo_ta=$2; shift 2
    local jdk=$JAVA_HOME
    if [[ ${1:-} == JAVA_HOME=* ]]; then jdk=${1#JAVA_HOME=}; shift; fi
    local dir=$WORK/$tag
    [ -d "$dir" ] || git worktree add -q --detach "$dir" "$tag"
    local log=$LOG_DIR/$tag-$(date +%H%M%S).log
    printf '\n%s▶ [%s] %s%s\n' "$DAM" "$tag" "$mo_ta" "$HET"
    printf '%s  $ mvn %s   (JDK %s)%s\n' "$MO" "$*" "$("$jdk/bin/java" -version 2>&1 | head -1 | cut -d'"' -f2)" "$HET"
    local bd kt
    bd=$(perl -MTime::HiRes=time -e 'printf "%.2f", time')
    (cd "$dir" && JAVA_HOME=$jdk mvn -o -B "$@" > "$OLDPWD/$log" 2>&1)
    kt=$(perl -MTime::HiRes=time -e 'printf "%.2f", time')
    tom_tat "$log" "$(awk -v a="$bd" -v b="$kt" 'BEGIN { s = sprintf("%.1f", b - a); sub(/\./, ",", s); print s }')"
    LAST_DIR=$dir
}

tom_tat() {
    local log=$1 thoi_gian=${2:+  (${2} s)}
    grep -E 'Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$log" | tail -1 | sed 's/^\[[A-Z]*\]/ /'
    # Mục Failures/Errors cuối log Surefire: mỗi ca đỏ một dòng (assertAll in thông điệp ở dòng kế tiếp)
    sed -En '/^\[ERROR\] (Failures|Errors): *$/,/^\[ERROR\] Tests run:/p' "$log" \
        | grep -E '^\[ERROR\]   |^[[:space:]]+org\.opentest4j\.AssertionFailedError: ' \
        | sed -E 's/^\[ERROR\]   (.*) Multiple Failures.*/  ✘ \1 (assertAll)/; s/^\[ERROR\]   /  ✘ /;
                 s/^[[:space:]]+org\.opentest4j\.AssertionFailedError: /      ↳ /; s/[[:space:]]+$//' \
        | awk '!seen[$0]++' | head -14
    grep -m1 -A5 'Argument(s) are different' "$log" | grep -v '^-> at' | sed 's/^/    /'
    grep -E 'Rule violated|All coverage checks' "$log" | sed -E 's/^\[[A-Z]+\] /  /'
    if grep -q 'BUILD SUCCESS' "$log"; then echo "  ${XANH}BUILD SUCCESS${HET}${thoi_gian}"; else echo "  ${DO}BUILD FAILURE${HET}${thoi_gian}"; fi
    printf '%s  log: %s%s\n' "$MO" "$log" "$HET"
}

# In độ phủ dòng/nhánh của mã nghiệp vụ (bỏ SmokeCheck) từ jacoco.csv
do_phu() {
    awk -F, 'NR > 1 && $3 != "SmokeCheck" {
        printf "  %-28s nhánh %d/%d   dòng %d/%d\n", $3, $7, $6 + $7, $9, $8 + $9
        bm += $6; bc += $7; lm += $8; lc += $9 }
        END { printf "  %-28s nhánh %.1f%%   dòng %.1f%%\n", "TỔNG", 100 * bc / (bm + bc), 100 * lc / (lm + lc) }' "$1"
}

khac_biet() { printf '%s  $ git diff %s %s -- src/main%s\n' "$MO" "$1" "$2" "$HET"; git --no-pager diff --color=always "$1" "$2" -- src/main | sed 's/^/  /'; }

kb1() {
    tieu_de "KB1 – Bảo trì phòng ngừa: tìm phần mã chưa có lưới an toàn"
    chay_tai kb1-truoc "Đo độ phủ bộ test GỐC bằng JaCoCo (gọi từ dòng lệnh)" \
        clean org.jacoco:jacoco-maven-plugin:0.8.16:prepare-agent test org.jacoco:jacoco-maven-plugin:0.8.16:report
    do_phu "$LAST_DIR/target/site/jacoco/jacoco.csv"
    chay_tai kb1-sau "Sau khi bổ sung TC01/TC15 và đặt cổng jacoco:check 100%" clean verify
    do_phu "$LAST_DIR/target/site/jacoco/jacoco.csv"
    chay_tai kb1-sau "Cổng chặn: chỉ chạy test tính giá thì độ phủ không đạt" clean verify '-Dtest=CheckoutServiceJUnitTest*'
}

kb2() {
    tieu_de "KB2 – Bảo trì thích nghi: JDK tương lai cấm nạp agent động (JEP 451)"
    chay_tai kb2-truoc "Mockito tự gắn agent lúc chạy + giả lập JDK cấm agent động" clean test -DargLine=-XX:-EnableDynamicAgentLoading
    chay_tai kb2-sau "Mockito nạp bằng -javaagent khi khởi động + cùng cờ cấm" clean test -DargLine=-XX:-EnableDynamicAgentLoading
    local j
    for j in "$(/usr/libexec/java_home -v 25 2>/dev/null)" /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home; do
        [ -x "$j/bin/java" ] && chay_tai kb2-sau "Chạy lại toàn bộ trên JDK mới" "JAVA_HOME=$j" clean test
    done
}

kb3() {
    tieu_de "KB3 – Bảo trì hoàn thiện: thêm chính sách khách VIP (viết test trước)"
    chay_tai kb3-truoc "Đã có test TC17–TC27, mới có khung phương thức" clean verify
    khac_biet kb3-truoc kb3-sau
    chay_tai kb3-sau "Đã cài đặt giảm thêm 2% cho VIP" clean verify
}

kb4() {
    tieu_de "KB4 – Bảo trì hoàn thiện: tái cấu trúc bậc giảm giá thành bảng tra"
    khac_biet kb4-truoc kb4-loi
    chay_tai kb4-loi "Tái cấu trúc dùng nhầm lowerEntry" clean verify
    chay_tai kb4-loi "Cùng mã lỗi nhưng bỏ qua test đỏ: độ phủ VẪN đạt 100%" clean verify -Dmaven.test.failure.ignore=true
    khac_biet kb4-loi kb4-sau
    chay_tai kb4-sau "Sửa thành floorEntry, bộ test không đổi dòng nào" clean verify
}

kb5() {
    tieu_de "KB5 – Bảo trì sửa lỗi: BUG-01 mã đơn lưu kèm khoảng trắng"
    chay_tai kb5-truoc "Chạy riêng TC28 tái hiện lỗi" clean test '-Dtest=CheckoutApplicationServiceJUnitTest#savesOrderIdWithoutSurroundingSpaces'
    khac_biet kb5-truoc kb5-sau
    chay_tai kb5-sau "Chạy riêng TC28 sau khi sửa" clean test '-Dtest=CheckoutApplicationServiceJUnitTest#savesOrderIdWithoutSurroundingSpaces'
    chay_tai kb5-sau "Hồi quy toàn bộ trước khi bàn giao" clean verify
}

case "${1:-tat-ca}" in
    kb1|kb2|kb3|kb4|kb5) "$1" ;;
    tat-ca) kb1; kb2; kb3; kb4; kb5 ;;
    *) echo "Dùng: bash demo/kich-ban.sh [kb1|kb2|kb3|kb4|kb5|tat-ca]"; exit 2 ;;
esac
