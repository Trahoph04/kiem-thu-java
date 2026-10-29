# Các tính năng của JUnit hỗ trợ bảo trì

Tài liệu này là dữ liệu cho câu hỏi 4 trong báo cáo: đặc điểm chính của công cụ được đề xuất. Mỗi tính năng dưới đây **đều đã cài trong dự án và đã chạy được**. Phiên bản: JUnit 6.1.3 với Mockito 5.24.0, JaCoCo 0.8.16, Surefire 3.5.2 và JDK 21. Mốc mã nguồn là tag `gd2-features`.

## 1. Kiến trúc của JUnit

JUnit gồm 3 phần:

- **JUnit Platform** là nền tảng để công cụ build (Maven Surefire), IDE và Console Launcher phát hiện và chạy test. Nền tảng này không phụ thuộc vào cách viết test.
- **JUnit Jupiter** là mô hình lập trình (các annotation `@Test`, `@ParameterizedTest`, `@Nested`, …) cùng engine để chạy chúng.
- **JUnit Vintage** cho phép chạy test JUnit 3/4 cũ trên cùng nền tảng. Phần này hữu ích khi chuyển đổi dần bộ test của hệ thống cũ. Ở JUnit 6, engine này đã bị đánh dấu *deprecated*, tức chỉ nên dùng tạm trong lúc chuyển đổi.

Nhờ cách chia tách này, cùng một bộ test chạy được bằng `mvn test`, trong IDE, hoặc bằng Console Launcher (`demo/cay-ket-qua.sh`). Spock cũng chỉ là một engine khác chạy trên JUnit Platform, nên hai công cụ dùng chung hạ tầng.

JUnit 6 (09/2025) vẫn dùng mô hình Jupiter, yêu cầu Java 17 trở lên, và đánh số phiên bản chung cho Platform và Jupiter.

## 2. Bảng tính năng

| # | Tính năng | Cài ở đâu | Vai trò trong bảo trì | Bằng chứng |
|---|---|---|---|---|
| 1 | `@DisplayName` và tên ca tham số hóa (`name = "{0}: …"`, `quoteTextArguments = false` của JUnit 6) | Mọi test JUnit | Tên ca trùng với mã trong tài liệu (TC01…TC16), nên khi test đỏ người bảo trì biết ngay **yêu cầu nào** bị vi phạm | `demo-output/02-junit-cay.txt` |
| 2 | Reporter JUnit 5 của Surefire (`usePhrasedTestCaseMethodName`, …) | `pom.xml`, profile `junit-mockito` | Báo cáo XML và CI hiện tên tiếng Việt thay cho `[4]`. Đây là khắc phục cho điểm yếu đã đo ở giai đoạn 1 | `target/surefire-reports/*.xml` |
| 3 | `@Nested` | `CheckoutServiceJUnitTest`: V0, V1–V3, Hiệu năng | Cấu trúc test bám theo phân vùng nghiệp vụ. Khi một quy tắc thay đổi, chỉ cần tìm đúng một nhóm | `02-junit-cay.txt` |
| 4 | `@ParameterizedTest` với `@CsvFileSource` | `src/test/resources/bang-gia.csv` (TC04–TC13) | **Tách dữ liệu khỏi mã test.** Đổi ngưỡng hay tỉ lệ giảm giá thì chỉ sửa file CSV; người kiểm thử không cần biết Java | `02-junit-tinh-nang.log` |
| 5 | `@CsvSource` (`nullValues`), `@NullAndEmptySource`, `@ValueSource` | TC01–TC03, TC15 | Phủ các giá trị biên và giá trị rỗng/null bằng một khai báo ngắn | như trên |
| 6 | `assertAll` | TC04–TC13, TC14 | Báo **tất cả** các điều kiện sai trong một lần chạy, thay vì dừng ở lỗi đầu tiên | `02-junit-loi-nguong.log` ("Multiple Failures") |
| 7 | `assertThrows` kèm kiểm tra thông điệp lỗi | TC01–TC03, TC15 | Thông điệp tiếng Việt hiện ra cho người dùng cũng là một phần hợp đồng; sửa nhầm là test bắt được | `02-junit-tinh-nang.log` |
| 8 | Thông điệp assertion có mã ca (`id + ": sai thành tiền"`) | TC04–TC13 | Console của Surefire in luôn `TC07: sai thành tiền ==> expected: <475000> but was: <500000>` | `02-junit-loi-nguong.log` |
| 9 | `@Tag` và chạy chọn lọc (`-Dgroups`, `-DexcludedGroups`, `--include-tag`) | Tag `tinh-gia`, `luu-don`, `hieu-nang` | **Kiểm thử hồi quy chọn lọc:** sửa phần lưu đơn thì chạy nhanh tag `luu-don` (5 ca); trước khi bàn giao thì chạy toàn bộ | `02-junit-chon-tag.log` |
| 10 | `@Timeout` | HN01: 100.000 phép tính trong dưới 1 giây | Chặn **hồi quy về hiệu năng** khi tái cấu trúc thuật toán | `02-junit-cay.txt` |
| 11 | Mô hình mở rộng `@ExtendWith(MockitoExtension.class)` với `@Mock`, `@Spy`, `@InjectMocks`, `@Captor` | `CheckoutApplicationServiceJUnitTest` | Cô lập phụ thuộc (kho lưu đơn); kiểm tra **thứ tự** xử lý (TC15: mã đơn sai thì không được gọi tới hàm tính giá); bắt giá trị đã lưu để so sánh | `02-junit-tinh-nang.log` |
| 12 | Nạp Mockito bằng `-javaagent` | `pom.xml` (`maven-dependency-plugin:properties` + `argLine`) | Bảo trì thích nghi cho chính hạ tầng test: JDK mới sẽ chặn việc tự gắn agent lúc chạy, nên cấu hình trước để test không hỏng khi nâng JDK | Log không còn dòng "self-attaching" |
| 13 | Đo độ phủ bằng JaCoCo (tích hợp qua `argLine`) | `pom.xml`, báo cáo HTML ở `target/site/jacoco/index.html` | Biết phần mã nào **chưa có lưới an toàn** trước khi sửa. Hiện tại đạt 100% lệnh, nhánh và dòng | `demo-output/02-jacoco.csv` |
| 14 | Chạy một lớp hoặc một test: `-Dtest=Lớp#phươngThức` | — | Phản hồi nhanh khi đang sửa lỗi: chạy riêng ca tái hiện lỗi | `mvn test -Dtest=CheckoutApplicationServiceJUnitTest#savesOrderWithFinalPrice` (1 ca) |
| 15 | JUnit Platform Console Launcher (`--details=tree`) | `demo/cay-ket-qua.sh` | Hiển thị kết quả dạng cây kèm ✔/✘ theo nhóm và tên ca, phù hợp để demo hoặc đọc nhanh | `02-junit-cay.txt` |

## 3. Lệnh minh họa

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
mvn clean test                                   # 19 ca: 16 ca chung (18 lần) + HN01, kèm báo cáo JaCoCo
mvn test -Dgroups=luu-don                        # chỉ 5 ca lưu đơn
mvn test -DexcludedGroups=hieu-nang              # bỏ HN01 (18 lần)
mvn test -Dtest='CheckoutApplicationServiceJUnitTest#savesOrderWithFinalPrice'
bash demo/cay-ket-qua.sh                         # cây kết quả
bash demo/cay-ket-qua.sh --include-tag tinh-gia  # cây kết quả, chỉ nhóm tính giá
open target/site/jacoco/index.html               # báo cáo độ phủ
```

## 4. Thông báo lỗi trước và sau khi tận dụng tính năng

Cùng một lỗi cố ý ở ngưỡng 500.000 đ (`>` thay cho `>=`):

**Giai đoạn 1** (JUnit với Surefire mặc định):
```
CheckoutServiceJUnitTest.calculatesFinalPrice:25 expected: <475000> but was: <500000>
btp.CheckoutServiceJUnitTest.calculatesFinalPrice(String, BigDecimal, BigDecimal)[4]
```

**Giai đoạn 2** (có `assertAll`, thông điệp kèm mã ca, reporter đặt tên):
```
CheckoutServiceJUnitTest$DiscountTiers.calculatesFinalPrice:38 Multiple Failures (1 failure)
    org.opentest4j.AssertionFailedError: TC07: sai thành tiền ==> expected: <475000> but was: <500000>
```

Trong báo cáo XML, ca này mang tên `TC07: 500000 đ → 475000 đ`.

Phần tóm tắt trên console của Surefire vẫn in chỉ số `[4]` ở dòng `<<< FAILURE!`. Đây là giới hạn của Surefire 3.5.x chứ không phải của JUnit; Console Launcher thì hiện đúng tên ca.
