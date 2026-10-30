# Công cụ hỗ trợ kiểm thử trong bảo trì phần mềm: JUnit, TestNG, Spock

Mã nguồn và demo cho bài tập nhóm số 1, "Tìm hiểu về một công cụ dùng trong bảo trì phần mềm", chủ đề **công cụ hỗ trợ kiểm thử**.

Hệ thống mẫu là module thanh toán tính tiền bằng VND:

- dưới 500.000 đ: không giảm;
- từ 500.000 đ: giảm 5%;
- từ 1.000.000 đ: giảm 10%;
- khách VIP được giảm thêm 2 điểm phần trăm;
- kết quả làm tròn `HALF_UP` đến đồng.

Ba công cụ JUnit 6, TestNG 7 và Spock 2 được cài đặt, dùng thử và đánh giá trên **cùng một bộ 16 ca kiểm thử**. Công cụ được chọn là **JUnit (kèm Mockito)**, sau đó được khai thác sâu qua chuỗi 5 kịch bản bảo trì.

## Môi trường (macOS)

```bash
brew install maven
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 21)' >> ~/.zshrc && source ~/.zshrc
mvn -version   # phải có "Java version: 21…"
```

Nếu không đặt `JAVA_HOME`, lệnh `mvn` của Homebrew sẽ chạy bằng OpenJDK mới nhất của Homebrew.

## Lệnh chạy

```bash
mvn clean verify            # JUnit + Mockito, kèm JaCoCo và cổng độ phủ 100%
mvn -Ptestng clean test     # TestNG + Mockito (bộ so sánh)
mvn -Pspock clean test      # Spock (bộ so sánh)

mvn test -Dgroups=luu-don   # chạy chọn lọc theo @Tag: tinh-gia, luu-don, vip, hieu-nang
mvn test -Dtest='CheckoutApplicationServiceJUnitTest#savesOrderIdWithoutSurroundingSpaces'

bash demo/so-sanh-truc-tiep.sh   # chạy bộ ca chung trên 3 công cụ, in bảng kết quả từng ca
bash demo/cay-ket-qua.sh    # kết quả JUnit dạng cây
bash demo/kich-ban.sh       # chạy lại chuỗi kịch bản KB1–KB5
bash demo/do-so-lieu.sh     # đo lại số liệu so sánh (nên chạy ở tag gd1-comparison)

# Kiểm tra nhanh, không cần thư viện ngoài
mkdir -p target/smoke && javac -encoding UTF-8 -d target/smoke src/main/java/btp/*.java && java -cp target/smoke btp.SmokeCheck
```

## Tài liệu

| Tài liệu | Nội dung |
|---|---|
| [docs/test-cases.md](docs/test-cases.md) | Phân vùng tương đương, giá trị biên, bảng ca TC01–TC28 |
| [docs/so-sanh-cong-cu.md](docs/so-sanh-cong-cu.md) | Số liệu, thông báo lỗi, tính năng, độ phổ biến, bảng điểm, đề xuất |
| [docs/tinh-nang-junit.md](docs/tinh-nang-junit.md) | 15 tính năng JUnit hỗ trợ bảo trì kèm bằng chứng |
| [docs/kich-ban-bao-tri.md](docs/kich-ban-bao-tri.md) | Chuỗi kịch bản KB1–KB5 theo 4 loại bảo trì |
| [docs/huong-dan-demo.md](docs/huong-dan-demo.md) | Kịch bản demo khi thuyết trình |
| [docs/kich-ban-video.md](docs/kich-ban-video.md) | Kịch bản quay video demo, dùng kèm `bash demo/video.sh` |
| `demo-output/` | Log gốc của các lần chạy |
| `deliverables/BaoCao_BaiTapNhom1_CongCuHoTroKiemThu.docx` | Báo cáo Word (bản nháp; chỗ tô vàng là thông tin nhóm cần điền) |

## Các mốc trong git

| Tag | Nội dung |
|---|---|
| `gd0-baseline` | Bản gốc (JUnit 5 + Mockito, TestNG) |
| `gd1-comparison` | 16 ca chung trên 3 công cụ, bản mới nhất; dùng để đo so sánh |
| `gd2-features` | Bộ JUnit khai thác tính năng sâu, JaCoCo, Mockito agent |
| `kb1-truoc` … `kb5-sau` | Trước và sau của từng kịch bản bảo trì |

Nhánh `loi-nguong-500k` chứa một lỗi **cố ý** (`>` thay cho `>=`) để so sánh thông báo lỗi. Không gộp nhánh này vào `main`.
