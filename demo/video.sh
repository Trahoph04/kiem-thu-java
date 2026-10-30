#!/usr/bin/env bash
# Chạy demo theo từng cảnh để quay video. Trước mỗi lệnh, script in lệnh và chờ Enter để người
# trình bày kịp thuyết minh; hết mỗi cảnh, script chờ Enter rồi xóa màn hình.
# Dùng: bash demo/video.sh [cảnh bắt đầu 1–8]      TU_DONG=1 bash demo/video.sh  (chạy thử, không chờ)
set -uo pipefail
cd "$(dirname "$0")/.."
export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 21)}"
TU_DONG="${TU_DONG:-0}"
BAT_DAU="${1:-1}"
GOC=$PWD
WORK=$(mktemp -d)
# Kết quả của cảnh 2–4 được giữ lại để cảnh 5 tổng hợp, kể cả khi chạy lại từ cảnh 5.
# Lệnh hiển thị dùng biến $DATA (ngắn gọn trên video); bash -c bên trong lenh() tự mở rộng biến.
export DATA="${TMPDIR:-/tmp}/kiem-thu-java-demo"
mkdir -p "$DATA"
CAN_KHOI_PHUC=0

DAM=$'\e[1m'; MO=$'\e[2m'; XANH=$'\e[36m'; VANG=$'\e[33m'; HET=$'\e[0m'
LOC_KQ="grep -E 'Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+\$|coverage checks|BUILD'"

don_dep() {
    local d
    if [ "$CAN_KHOI_PHUC" = 1 ]; then
        git -C "$GOC" checkout -- src/main && echo "${MO}(đã khôi phục src/main)${HET}"
    fi
    for d in "$WORK"/*; do [ -d "$d" ] && git -C "$GOC" worktree remove --force "$d" >/dev/null 2>&1; done
    rm -rf "$WORK"; git -C "$GOC" worktree prune
}
trap don_dep EXIT
trap 'exit 130' INT TERM   # Ctrl+C cũng đi qua don_dep, nên mã nguồn không bị bỏ lại ở trạng thái lỗi

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
    canh 2 "Chạy thật bộ 16 ca trên cả 3 công cụ"
    lenh "JUnit, TestNG, Spock lần lượt chạy cùng bộ ca rồi in kết quả TỪNG CA" \
        'bash demo/so-sanh-truc-tiep.sh $DATA/kq-dung.json'
}

canh3() {
    canh 3 "Tự tay gây lỗi, xem 3 công cụ phát hiện thế nào"
    if ! git diff --quiet -- src/main; then
        echo "${VANG}src/main đang có thay đổi chưa commit: script sẽ dùng nguyên trạng và không tự khôi phục.${HET}"
    else
        CAN_KHOI_PHUC=1
        printf '\n%sMở src/main/java/btp/CheckoutService.java trong IntelliJ, sửa dòng 28:\n' "$VANG"
        printf '    floorEntry(subtotal)  →  lowerEntry(subtotal)    (lấy ngưỡng "nhỏ hơn hẳn" thay vì "nhỏ hơn hoặc bằng")\n'
        printf 'rồi Cmd+S. Có thể thử lỗi khác, ví dụ đổi RoundingMode.HALF_UP thành HALF_DOWN.\n'
        printf 'Không sửa gì thì nhấn Enter, script sẽ tự gây lỗi lowerEntry.%s' "$HET"
        cho; echo
        if git diff --quiet -- src/main; then
            sed -i '' 's/floorEntry(subtotal)/lowerEntry(subtotal)/' src/main/java/btp/CheckoutService.java
            echo "${MO}(script đã tự sửa floorEntry → lowerEntry)${HET}"
        fi
    fi
    lenh "Thay đổi vừa đưa vào mã nguồn" "git --no-pager diff --color=always -- src/main"
    lenh "Chạy lại cả 3 công cụ trên mã có lỗi" 'bash demo/so-sanh-truc-tiep.sh $DATA/kq-loi.json'
    local d; d=$(worktree loi-nguong-500k)
    lenh "Để công bằng: JUnit với cấu hình MẶC ĐỊNH (bản so sánh ban đầu, cùng loại lỗi biên) báo thế nào?" \
        'mvn -o clean test > $DATA/junit-mac-dinh.log 2>&1; grep -E "^\[ERROR\]   .*expected|\[[0-9]+\] -- Time" $DATA/junit-mac-dinh.log' "$d"
    if [ "$CAN_KHOI_PHUC" = 1 ]; then
        lenh "Khôi phục mã nguồn đúng" "git checkout -- src/main && git status --short src/main && echo 'src/main đã trở lại như cũ'"
        CAN_KHOI_PHUC=0
    fi
}

canh4() {
    canh 4 "Đo số liệu so sánh ngay trên máy (tag gd1-comparison)"
    local d; d=$(worktree gd1-comparison)
    lenh "Đếm dòng mã test, dòng cấu hình, thư viện; chạy mỗi công cụ 3 lần để đo thời gian" \
        'RUNS=3 bash demo/do-so-lieu.sh && cp demo-output/01-so-lieu.txt $DATA/so-lieu.txt' "$d"
}

canh5() {
    canh 5 "Tổng hợp kết quả vừa chạy → kết luận"
    lenh "Bảng tổng hợp lấy từ cảnh 2, 3, 4, kèm bảng điểm có trọng số" \
        'python3 demo/bang-ket-qua.py tong-hop $DATA/kq-dung.json $DATA/kq-loi.json $DATA/so-lieu.txt $DATA/junit-mac-dinh.log'
}

canh6() {
    canh 6 "Tính năng JUnit hỗ trợ bảo trì (nhánh main)"
    lenh "Dữ liệu ca TC04–TC13 tách ra tệp CSV" "cat src/test/resources/bang-gia.csv"
    lenh "Kết quả dạng cây: @Nested, @DisplayName, tham số hóa" "bash demo/cay-ket-qua.sh 2>&1 | grep -v '^\[ *[0-9]* containers'"
    lenh "Chạy chọn lọc theo @Tag(\"vip\")" "bash demo/cay-ket-qua.sh --include-tag vip 2>&1 | grep -v '^\[ *[0-9]* containers'"
    lenh "Toàn bộ 31 ca + cổng độ phủ JaCoCo" "mvn -o clean verify | $LOC_KQ"
    lenh "Mở báo cáo độ phủ trong trình duyệt" "open target/site/jacoco/index.html"
}

canh7() {
    canh 7 "Chuỗi kịch bản bảo trì KB1–KB5"
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

canh8() {
    canh 8 "Kết thúc"
    lenh "Tài liệu và báo cáo của nhóm" "ls docs deliverables"
}

for i in 1 2 3 4 5 6 7 8; do
    if [ "$i" -ge "$BAT_DAU" ]; then
        "canh$i"
        printf '\n%s── hết cảnh %s ──%s' "$MO" "$i" "$HET"; cho; echo
    fi
done
