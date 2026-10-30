#!/usr/bin/env bash
# Chạy demo theo từng cảnh để quay video. Trước mỗi lệnh, script in lệnh và chờ Enter để người
# trình bày kịp thuyết minh; hết mỗi cảnh, script chờ Enter rồi xóa màn hình.
# Dùng: bash demo/video.sh [cảnh bắt đầu 1–6]      TU_DONG=1 bash demo/video.sh  (chạy thử, không chờ)
set -uo pipefail
cd "$(dirname "$0")/.."
export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 21)}"
TU_DONG="${TU_DONG:-0}"
BAT_DAU="${1:-1}"
GOC=$PWD
WORK=$(mktemp -d)

DAM=$'\e[1m'; MO=$'\e[2m'; XANH=$'\e[36m'; HET=$'\e[0m'
LOC_KQ="grep -E 'Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+\$|coverage checks|BUILD'"

don_dep() {
    local d
    for d in "$WORK"/*; do [ -d "$d" ] && git -C "$GOC" worktree remove --force "$d" >/dev/null 2>&1; done
    rm -rf "$WORK"; git -C "$GOC" worktree prune
}
trap don_dep EXIT

cho() { [ "$TU_DONG" = 1 ] || read -r -p "${MO}   ↵ Enter${HET}" _ < /dev/tty; }

canh() {
    [ "$TU_DONG" = 1 ] || clear
    printf '\n%s%s══ CẢNH %s ══ %s%s\n' "$DAM" "$XANH" "$1" "$2" "$HET"
}

# lenh "<ghi chú>" "<lệnh>" [thư mục chạy]
lenh() {
    printf '\n%s# %s%s\n%s$ %s%s' "$MO" "$1" "$HET" "$DAM" "$2" "$HET"
    cho
    [ "$TU_DONG" = 1 ] && echo
    (cd "${3:-$GOC}" && bash -c "$2")
}

worktree() {  # worktree <tag/nhánh> → in đường dẫn thư mục làm việc tạm
    local dir=$WORK/$1
    [ -d "$dir" ] || git worktree add -q --detach "$dir" "$1"
    echo "$dir"
}

canh1() {
    canh 1 "Môi trường và hệ thống được kiểm thử"
    lenh "Môi trường: JDK 21 và Maven" "mvn -version | head -3"
    lenh "Quy tắc giảm giá (phiên bản dùng để so sánh 3 công cụ)" \
        "git show gd1-comparison:src/main/java/btp/CheckoutService.java | sed -n '6,26p'"
}

canh2() {
    canh 2 "Ba công cụ chạy cùng một bộ 16 ca (tag gd1-comparison)"
    local d; d=$(worktree gd1-comparison)
    lenh "JUnit 6 + Mockito" "mvn -o clean test | $LOC_KQ" "$d"
    lenh "TestNG 7 + Mockito" "mvn -o -Ptestng clean test | $LOC_KQ" "$d"
    lenh "Spock 2 (21 = 18 lần chạy thật + 3 nút cha của bảng where:)" "mvn -o -Pspock clean test | $LOC_KQ" "$d"
}

canh3() {
    canh 3 "Cùng một lỗi biên, ba kiểu thông báo lỗi (nhánh loi-nguong-500k)"
    local d; d=$(worktree loi-nguong-500k)
    lenh "Lỗi cố ý: ngưỡng 500.000 đ dùng > thay cho >=" "git --no-pager diff --color=always gd1-comparison loi-nguong-500k -- src/main"
    lenh "JUnit (Surefire mặc định): chỉ in chỉ số [4]" \
        "mvn -o clean test | grep -E '^\[ERROR\]   .*expected|\[4\] -- Time'" "$d"
    lenh "TestNG: in tham số của dòng dữ liệu" \
        "mvn -o -Ptestng clean test | grep -E '<<< FAILURE!\$|^\[ERROR\]   .*expected' | grep -v TestSuite" "$d"
    lenh "Spock: tên ca và giá trị từng phần (power assertion)" \
        "mvn -o -Pspock clean test | grep -m1 -A6 'TC07: 500000.*FAILURE'" "$d"
}

canh4() {
    canh 4 "Tính năng JUnit hỗ trợ bảo trì (nhánh main)"
    lenh "Dữ liệu ca TC04–TC13 tách ra tệp CSV" "cat src/test/resources/bang-gia.csv"
    lenh "Kết quả dạng cây: @Nested, @DisplayName, tham số hóa" "bash demo/cay-ket-qua.sh 2>&1 | grep -v '^\[ *[0-9]* containers'"
    lenh "Chạy chọn lọc theo @Tag(\"vip\")" "bash demo/cay-ket-qua.sh --include-tag vip 2>&1 | grep -v '^\[ *[0-9]* containers'"
    lenh "Toàn bộ 31 ca + cổng độ phủ JaCoCo" "mvn -o clean verify | $LOC_KQ"
    lenh "Mở báo cáo độ phủ trong trình duyệt" "open target/site/jacoco/index.html"
}

canh5() {
    canh 5 "Chuỗi kịch bản bảo trì KB1–KB5"
    lenh "Lịch sử bảo trì: mỗi mốc là một tag git" "git --no-pager log --oneline --decorate --color=always -14"
    local k tieu_de
    for k in kb1 kb2 kb3 kb4 kb5; do
        case $k in
            kb1) tieu_de="KB1 – Phòng ngừa: tìm mã chưa có test, đặt cổng chặn độ phủ" ;;
            kb2) tieu_de="KB2 – Thích nghi: JDK tương lai cấm nạp agent động" ;;
            kb3) tieu_de="KB3 – Hoàn thiện: thêm khách VIP, viết test trước" ;;
            kb4) tieu_de="KB4 – Hoàn thiện: tái cấu trúc, độ phủ 100% vẫn có lỗi" ;;
            kb5) tieu_de="KB5 – Sửa lỗi: BUG-01 mã đơn lưu kèm khoảng trắng" ;;
        esac
        [ "$k" = kb1 ] || { cho; [ "$TU_DONG" = 1 ] || clear; }
        lenh "$tieu_de" "bash demo/kich-ban.sh $k 2>&1 | grep -v '  log: '"
    done
}

canh6() {
    canh 6 "Kết thúc"
    lenh "Cây thư mục tài liệu và báo cáo" "ls docs deliverables"
}

for i in 1 2 3 4 5 6; do
    if [ "$i" -ge "$BAT_DAU" ]; then
        "canh$i"
        printf '\n%s── hết cảnh %s ──%s' "$MO" "$i" "$HET"; cho; echo
    fi
done
