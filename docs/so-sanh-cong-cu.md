# So sánh JUnit 5, TestNG và Spock

Tài liệu này là dữ liệu cho câu hỏi 2 và 3 trong báo cáo: những công cụ nào phổ biến, và phân tích để đề xuất một công cụ. Mọi số liệu đều đo ngày 26/10/2026 và có thể đo lại bằng `bash demo/do-so-lieu.sh`.

## 1. Điều kiện so sánh

| Hạng mục | Giá trị |
|---|---|
| Hệ thống được kiểm thử | `CheckoutService`, `CheckoutApplicationService` (giống nhau cho cả 3 công cụ) |
| Bộ ca kiểm thử | 16 ca, 18 lần thực thi ([test-cases.md](test-cases.md)) |
| Môi trường | Apple M4, JDK 21.0.10, Maven 3.10.0, Surefire 3.5.2 |
| JUnit | JUnit Jupiter 5.11.4 và Mockito 5.14.2 (profile `junit-mockito`) |
| TestNG | TestNG 7.10.2 và Mockito 5.14.2 (profile `testng`) |
| Spock | Spock 2.5-groovy-5.0 và Groovy 5.1.3, mock có sẵn của Spock (profile `spock`) |

Lệnh chạy là `mvn clean test`, `mvn -Ptestng clean test` và `mvn -Pspock clean test`.

## 2. Kết quả chạy

| Công cụ | Code đúng (`main`) | Code có lỗi (nhánh `loi-nguong-500k`) | Log |
|---|---|---|---|
| JUnit 5 | 18/18 đạt | 1 ca thất bại (TC07) | `demo-output/01-junit-mockito.log`, `01-loi-junit-mockito.log` |
| TestNG | 18/18 đạt | 1 ca thất bại (TC07) | `demo-output/01-testng.log`, `01-loi-testng.log` |
| Spock | 18/18 đạt (Surefire báo **21**) | 1 ca thất bại (TC07) | `demo-output/01-spock.log`, `01-loi-spock.log` |

Surefire đếm Spock thành 21 vì nó đếm cả 3 "nút cha" của các feature có bảng `where:` (tên dạng `#id: #subtotal đ → …`) ngoài 18 lần chạy thật. Cần lưu ý điểm này khi đọc báo cáo của Spock.

Lỗi được gây có chủ đích là ở ngưỡng 500.000 đ dùng `>` thay cho `>=`. Đây là lỗi lệch biên rất điển hình khi bảo trì. Cả 3 công cụ đều phát hiện đúng 1 ca thất bại, không công cụ nào bỏ sót hay báo nhầm.

## 3. Số liệu đo

| Chỉ số | JUnit 5 + Mockito | TestNG + Mockito | Spock |
|---|---|---|---|
| Dòng mã test (bỏ dòng trống, package, import) | **52** | 67 | 58 |
| Dòng cấu hình riêng trong `pom.xml` | **14** | 26 | 48 |
| Plugin build phải thêm | **0** | **0** | 1 (GMavenPlus để biên dịch Groovy) |
| Thư viện trên test classpath | 12 jar, 7,5 MB | 8 jar, **7,4 MB** | 8 jar, 10,0 MB |
| Thời gian `mvn clean test`, trung vị 3 lần | **1,79 s** | 1,98 s | 1,90 s |
| Thời gian riêng phần chạy test, trung vị 3 lần | 0,440 s | 0,556 s | **0,124 s** |

Cách đọc bảng:

- **Thời gian không phải yếu tố quyết định ở quy mô này.** Toàn bộ quá trình build của 3 công cụ chênh nhau dưới 0,2 s.
- Spock chạy test nhanh hơn chủ yếu vì **không dùng Mockito**. Ở JUnit, riêng lớp test có mock đã mất 0,439 s, phần lớn là thời gian Mockito tự gắn agent để khởi tạo inline mock maker. Lớp `CheckoutServiceJUnitTest` không dùng mock chỉ mất 0,022 s.
- TestNG dài nhất vì `@DataProvider` trả về `Object[][]` không có kiểu, và phải tự tạo lại mock trong `@BeforeMethod`.
- Spock tốn nhiều cấu hình nhất vì phải thêm Groovy và plugin biên dịch Groovy.

## 4. Thông báo lỗi khi gặp cùng một lỗi

**JUnit 5** (Surefire mặc định):
```
CheckoutServiceJUnitTest.calculatesFinalPrice:25 expected: <475000> but was: <500000>
btp.CheckoutServiceJUnitTest.calculatesFinalPrice(String, BigDecimal, BigDecimal)[4]
```

**TestNG**:
```
CheckoutServiceTestNgTest.calculatesFinalPrice:29 expected [475000] but found [500000]
btp.CheckoutServiceTestNgTest.calculatesFinalPrice[TC07, 500000, 475000](4)
```

**Spock**:
```
btp.CheckoutServiceSpec.TC07: 500000 đ → 475000 đ
Condition not satisfied:

service.finalPrice(subtotal as BigDecimal) == expected
|       |          |                       |  |
|       500000     500000                  |  475000
<btp.CheckoutService@3abd581e>             false
```

Nhận xét:

- **Spock chẩn đoán tốt nhất:** in tên ca TC07 và giá trị của từng phần trong biểu thức (power assertion).
- **TestNG** in đủ tham số của dòng dữ liệu bị lỗi.
- **JUnit với cấu hình mặc định yếu nhất:** chỉ in chỉ số `[4]`, người bảo trì phải tự đếm dòng trong `@CsvSource` mới biết là TC07. Surefire mặc định bỏ qua cả tên trong `@ParameterizedTest(name=…)` lẫn `@DisplayName`, ở console và cả XML. Điểm yếu này khắc phục được bằng cấu hình reporter của Surefire (giai đoạn 2).

## 5. So sánh tính năng (rút ra khi cài 16 ca)

| Tính năng | JUnit 5 | TestNG | Spock |
|---|---|---|---|
| Ngôn ngữ viết test | Java | Java | Groovy (phải học thêm) |
| Tham số hóa | `@ParameterizedTest` + `@CsvSource`, tự chuyển chuỗi sang `BigDecimal` | `@DataProvider` trả `Object[][]`, phải tự chuyển kiểu | Bảng `where:`, đọc như bảng ca kiểm thử |
| Đặt tên ca theo dữ liệu | `name = "{0}: …"` (Surefire mặc định không hiện) | Không có; Surefire in tham số | Tên phương thức là chuỗi, chèn được `#id` |
| Kiểm tra ngoại lệ | `assertThrows` | `expectedExceptions` hoặc `assertThrows` | Khối `when:`/`then:` với `thrown()` |
| Giả lập (mock) | Cần Mockito | Cần Mockito | Có sẵn: `Mock()`, `1 * repo.save(...)`, `0 * _` |
| Vòng đời đối tượng test | Mỗi test một instance mới, khai báo mock ở field là đủ | **Một instance cho cả lớp**, phải tạo lại mock trong `@BeforeMethod`, quên là các test ảnh hưởng nhau | Mỗi feature một instance mới |
| Thứ tự tham số `assertEquals` | `(expected, actual)` | `(actual, expected)`, ngược JUnit nên dễ nhầm khi chuyển đổi | Không có, dùng `==` |
| So sánh `BigDecimal` | `equals`: chặt, phân biệt `900000` với `900000.00` | `equals`: chặt | Toán tử `==` của Groovy dùng `compareTo`: **không** phân biệt scale, nên lỗi làm sai scale sẽ lọt qua |
| Báo cáo | XML của Surefire | XML của Surefire và **HTML riêng** (`index.html`, `emailable-report.html`) | XML của Surefire (đếm thêm nút cha) |
| Nhóm và chọn test | `@Tag` | `groups` | `@Tag` |
| Phụ thuộc và thứ tự giữa test | `@Order` (không có phụ thuộc) | `dependsOnMethods`, `priority`, cấu hình `testng.xml` | `@Stepwise` |

Ba dòng cuối của bảng lấy theo tài liệu chính thức của từng công cụ, chưa cài trong dự án. Giai đoạn 2 sẽ minh họa các tính năng này cho công cụ được chọn.

## 6. Độ phổ biến và mức độ duy trì của dự án (tra ngày 26/10/2026)

| | JUnit | TestNG | Spock | (Mockito) |
|---|---|---|---|---|
| Sao GitHub | **7.060** (`junit-team/junit-framework`) | 2.059 (`testng-team/testng`) | 3.630 (`spockframework/spock`) | 15.454 |
| Bản mới nhất trên Maven Central | 6.1.3 (dòng 5.x dừng ở 5.14.4) | 7.12.0 | 2.5 (10/2026) | 5.24.0 |
| Lần push gần nhất | 26/10/2026 | 26/10/2026 | 21/10/2026 | 24/10/2026 |
| Giấy phép | EPL-2.0 | Apache-2.0 | Apache-2.0 | MIT |

Một số nguồn tham khảo:

- Khảo sát JetBrains *State of Developer Ecosystem 2021* (mục Java) ghi rằng *JUnit và Mockito là hai framework kiểm thử đơn vị phổ biến nhất* và mức sử dụng tăng khoảng 2 điểm phần trăm so với năm trước. Trang chỉ có biểu đồ dạng ảnh nên không trích được tỉ lệ chính xác: <https://www.jetbrains.com/lp/devecosystem-2021/java/>
- Bài báo D. Grabek, J. Gryta, M. Dzieńkowski, "Comparative analysis of Java unit and integration testing tools: JUnit, TestNG and Spock", *IAPGOS* 16(2), 2026, tr. 145–151, DOI 10.35784/iapgos.8302. Tóm tắt của bài kết luận *"không có công cụ nào tối ưu cho mọi trường hợp"*: Spock nổi bật về độ dễ đọc, TestNG về hiệu năng và dễ học, JUnit về hỗ trợ truy cập dữ liệu đa luồng. Nên trích bài này trong báo cáo để phần đề xuất có lập luận hai chiều.

Đáng chú ý: **JUnit 6 đã ra mắt ngày 30/09/2025** và hiện là dòng chính. Dự án đang dùng JUnit 5.11.4 (12/2024), trong khi Spock dùng bản mới nhất. Xem mục 8.

## 7. Bảng điểm có trọng số (bối cảnh: đội bảo trì một hệ thống Java)

Thang điểm 1–5. Điểm tổng = Σ(trọng số × điểm) / 5, tối đa 100.

| Tiêu chí | Trọng số | JUnit 5 | TestNG | Spock | Căn cứ |
|---|---|---|---|---|---|
| Phổ biến, cộng đồng, tài liệu | 20 | 5 | 3 | 3 | Mục 6: số sao GitHub, khảo sát JetBrains |
| Tích hợp hệ sinh thái Java (IDE, build, CI, mock, đo độ phủ) | 20 | 5 | 4 | 3 | Mục 3: không cần plugin; Spock cần Groovy và GMavenPlus |
| Chi phí học và duy trì cho đội Java | 15 | 5 | 4 | 2 | Mục 3 và 5: Java thuần so với Groovy; 14, 26 và 48 dòng cấu hình |
| Chẩn đoán lỗi khi có hồi quy | 15 | 3 | 4 | 5 | Mục 4 |
| Độ dễ đọc, ngắn gọn của test | 10 | 4 | 3 | 5 | Mục 3 và 5: 52, 67 và 58 dòng; bảng `where:` |
| Tính năng nâng cao (nhóm, phụ thuộc, song song, mở rộng) | 10 | 4 | 5 | 4 | Mục 5 |
| Độ chặt và tin cậy của kết quả | 10 | 5 | 4 | 3 | Mục 2 và 5: `==` bỏ qua scale, đếm thêm nút cha; vòng đời instance của TestNG |
| **Tổng** | **100** | **90** | **76** | **69** | |

Đây là đánh giá có chủ quan. Nhóm nên xem lại và có thể chỉnh trọng số hoặc điểm, miễn giữ phần căn cứ.

## 8. Kết luận đề xuất

**Đề xuất chọn JUnit (Jupiter) kết hợp Mockito** làm công cụ hỗ trợ kiểm thử trong bảo trì hệ thống Java:

- Điểm cao nhất (90).
- Phổ biến nhất, không cần thêm ngôn ngữ hay plugin, test ngắn nhất.
- So sánh chặt nhất, nên ít bỏ sót lỗi hồi quy liên quan tới giá trị tiền.

Hai điểm yếu đo được và sẽ xử lý ở giai đoạn 2:

1. Thông báo lỗi mặc định không chỉ ra tên ca. Cấu hình reporter của Surefire để hiện tên dạng `TC07: …`.
2. Cảnh báo Mockito tự gắn agent. Cấu hình `-javaagent` cho Surefire.

Trường hợp khác nên chọn công cụ khác:

- Đội đã quen Groovy hoặc Gradle và coi trọng test "đọc như đặc tả" thì nên dùng **Spock**.
- Bộ kiểm thử tích hợp hoặc kiểm thử giao diện cần phụ thuộc giữa các test, chạy song song theo suite, có báo cáo HTML sẵn thì nên dùng **TestNG**.
