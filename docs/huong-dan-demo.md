# Hướng dẫn demo khi thuyết trình (khoảng 12 phút)

Máy demo: macOS, JDK 21, Maven từ Homebrew. Mọi lệnh chạy từ thư mục gốc dự án và dùng `-o` (offline), nên không cần mạng.

## Chuẩn bị trước giờ trình bày

1. Mở terminal mới, kiểm tra `mvn -version` có dòng `Java version: 21…`.
2. Nếu máy vừa xóa `~/.m2`, chạy một lần **có mạng**: `mvn clean verify && mvn -Ptestng clean test && mvn -Pspock clean test`.
3. Chạy thử toàn bộ: `bash demo/kich-ban.sh tat-ca`, khoảng 1–2 phút, phải không có lỗi ngoài dự kiến.
4. Kiểm tra `git status` sạch và đang ở nhánh `main`.
5. Tăng cỡ chữ terminal, mở sẵn `docs/test-cases.md` và mã nguồn trong IDE.

Nếu demo trực tiếp gặp sự cố, mở log có sẵn trong `demo-output/` (tên file ghi ở từng bước dưới đây).

## 1. Hệ thống được kiểm thử và bộ ca chung (1 phút)

- Nghiệp vụ: dưới 500.000 đ không giảm, từ 500.000 đ giảm 5%, từ 1.000.000 đ giảm 10%, làm tròn đến đồng.
- Mở `docs/test-cases.md` và nói về phân vùng V0–V3, giá trị biên, 16 ca và 18 lần thực thi.

## 2. So sánh 3 công cụ (3 phút)

```bash
mvn -o clean test | grep "Tests run:" | tail -1           # JUnit: 31 ca ở main
mvn -o -Ptestng clean test | grep "Tests run:" | tail -1   # TestNG: 18
mvn -o -Pspock  clean test | grep "Tests run:" | tail -1   # Spock: 21 (18 thật + 3 nút cha)
```

Thông báo lỗi khi gặp cùng một lỗi biên. Log có sẵn: `demo-output/01-loi-*.log`.

```bash
git switch -q loi-nguong-500k
mvn -o -Ptestng clean test | grep -A1 "Failures:" | tail -1
mvn -o -Pspock  clean test | sed -n '/Failures:/,/false/p'
git switch -q main
```

Ý chính: Spock chẩn đoán tốt nhất, nhưng JUnit thắng ở bảng điểm (90 so với 76 và 69) nhờ độ phổ biến, tích hợp và chi phí học. Xem `docs/so-sanh-cong-cu.md`, mục 7.

## 3. Tính năng của JUnit (3 phút)

```bash
bash demo/cay-ket-qua.sh                          # cây kết quả: @Nested, @DisplayName, tham số hóa
bash demo/cay-ket-qua.sh --include-tag luu-don    # chạy chọn lọc theo @Tag
open target/site/jacoco/index.html                # độ phủ 100%
```

Chỉ vào `src/test/resources/bang-gia.csv`: đổi quy tắc giá thì chỉ sửa dữ liệu. Danh sách 15 tính năng có trong `docs/tinh-nang-junit.md`.

## 4. Chuỗi kịch bản bảo trì (4 phút, mỗi kịch bản 30–60 giây)

```bash
bash demo/kich-ban.sh kb1   # Phòng ngừa: nhánh 75% → 100%, cổng chặn làm build thất bại
bash demo/kich-ban.sh kb2   # Thích nghi: cấm agent động → 5 lỗi; cấu hình -javaagent → 19/19 trên JDK 21/25/27
bash demo/kich-ban.sh kb3   # Hoàn thiện: viết test VIP trước (9 đỏ) → cài đặt → 30/30
bash demo/kich-ban.sh kb4   # Tái cấu trúc: lowerEntry → 6 đỏ dù độ phủ 100% → floorEntry → 30/30
bash demo/kich-ban.sh kb5   # Sửa lỗi: TC28 đỏ, Mockito chỉ đúng "  ORD-003  " → strip() → 31/31
```

Nếu thiếu thời gian, chỉ demo trực tiếp **KB4 và KB5**, các kịch bản còn lại trình bày bằng slide. Log gốc nằm ở `demo-output/kb*.log` và `demo-output/kich-ban-tat-ca.txt`.

## 5. Kết luận (30 giây)

Đối chiếu bảng cuối của `docs/kich-ban-bao-tri.md`: công cụ kiểm thử hỗ trợ cả 4 loại bảo trì, và mỗi loại đều có một kịch bản minh chứng chạy được.
