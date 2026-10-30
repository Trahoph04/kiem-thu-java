# Kịch bản quay video demo (khoảng 12–14 phút)

Video gồm 7 cảnh. Cảnh 1–6 chạy bằng script `demo/video.sh`. Trước mỗi lệnh, script in lệnh ra rồi **chờ bạn nhấn Enter**: bạn nói xong phần giới thiệu mới nhấn Enter để chạy. Lời thoại dưới đây chỉ là gợi ý, hãy nói theo cách của nhóm.

## A. Chuẩn bị trước khi quay (khoảng 10 phút)

1. **Tắt thông báo:** Trung tâm điều khiển → Tập trung → Không làm phiền. Đóng Zalo, Messenger, Mail.
2. **Terminal:**
   - Mở một cửa sổ Terminal **mới** để `JAVA_HOME` trỏ JDK 21, rồi chạy `cd ~/Documents/kiem-thu-java`.
   - Phóng to cửa sổ, tăng cỡ chữ bằng `Cmd +` (khoảng 16–18pt).
   - Nên dùng giao diện nền sáng: Terminal → Cài đặt → Hồ sơ → Basic.
   - Rút gọn dấu nhắc cho gọn hình: `PROMPT='%1~ $ '` (chỉ áp dụng cho cửa sổ đó).
3. **Chạy thử một lượt, không dừng** (khoảng 1 phút), vừa để kiểm tra vừa để Maven chạy nhanh hơn khi quay:
   ```bash
   TU_DONG=1 bash demo/video.sh > /dev/null && echo OK
   git status --short    # không được có thay đổi nào
   ```
4. **IntelliJ IDEA:** mở thư mục dự án (chọn *Trust Project* nếu được hỏi), mở sẵn các tab:
   - `docs/test-cases.md`
   - `src/test/java/btp/CheckoutServiceTestNgTest.java`
   - `src/test/groovy/btp/CheckoutServiceSpec.groovy`
   - `src/test/java/btp/CheckoutServiceJUnitTest.java`
   - `src/test/java/btp/CheckoutApplicationServiceJUnitTest.java`
5. **Word:** mở báo cáo `deliverables/BaoCao_BaiTapNhom1_CongCuHoTroKiemThu.docx` (đã điền thông tin nhóm), để sẵn ở trang bìa.
6. **Công cụ quay:**
   - Nhấn `Cmd + Shift + 5` → chọn *Ghi toàn bộ màn hình* → *Tùy chọn* → *Micrô*: chọn micrô của máy → *Ghi*.
   - Dừng bằng nút ⏹ trên thanh menu hoặc `Cmd + Control + Esc`. File `.mov` được lưu ra Màn hình nền.

## B. Cách dùng script

| Lệnh | Tác dụng |
|---|---|
| `bash demo/video.sh` | Chạy từ cảnh 1. Nhấn Enter để chạy từng lệnh; hết cảnh nhấn Enter để xóa màn hình, sang cảnh sau |
| `bash demo/video.sh 4` | Bắt đầu từ cảnh 4 (khi cần quay lại một cảnh) |
| `Ctrl + C` | Dừng giữa chừng; thư mục tạm tự được dọn |

Script chạy các mốc cũ (tag `gd1-comparison`, nhánh `loi-nguong-500k`, các tag `kb*`) trong **thư mục tạm**, nên mã nguồn đang mở trong IntelliJ không bị thay đổi.

## C. Kịch bản từng cảnh

### Cảnh 0 – Mở đầu (0:00–0:40) · màn hình: trang bìa báo cáo trong Word

> "Kính chào thầy/cô. Nhóm [tên nhóm] xin trình bày phần demo bài tập nhóm số 1: tìm hiểu công cụ hỗ trợ kiểm thử trong bảo trì phần mềm. Nhóm đã cài đặt và so sánh ba công cụ JUnit, TestNG và Spock trên cùng một hệ thống, chọn ra JUnit, sau đó minh họa bằng năm kịch bản bảo trì. Video gồm bốn phần: hệ thống thử nghiệm, so sánh ba công cụ, các tính năng của JUnit, và chuỗi kịch bản bảo trì."

### Cảnh 1 – Môi trường và hệ thống (0:40–2:00) · Terminal: `bash demo/video.sh`

| Lệnh trên màn hình | Lời thoại gợi ý |
|---|---|
| `mvn -version` | "Môi trường demo là JDK 21 và Maven 3.10 trên macOS." |
| Mã `CheckoutService` | "Hệ thống thử nghiệm là module thanh toán: đơn dưới 500 nghìn không giảm, từ 500 nghìn giảm 5%, từ 1 triệu giảm 10%, làm tròn đến đồng." |

Chuyển sang IntelliJ, tab `docs/test-cases.md`:

> "Từ quy tắc này nhóm thiết kế 16 ca kiểm thử bằng phân vùng tương đương và giá trị biên. Ví dụ TC06 và TC07 là hai phía của ngưỡng 500 nghìn. Ba công cụ đều phải chạy đúng bộ ca này."

Quay lại Terminal, nhấn Enter để sang cảnh 2.

### Cảnh 2 – Ba công cụ chạy cùng bộ ca (2:00–3:30)

Trước khi nhấn Enter, có thể chuyển nhanh qua IntelliJ để cho xem ba file test TestNG, Spock và JUnit:

> "Cùng một dữ liệu: JUnit dùng `@CsvSource`, TestNG dùng `DataProvider` trả về mảng Object, còn Spock dùng bảng `where:` viết bằng Groovy."

| Lệnh | Lời thoại gợi ý |
|---|---|
| JUnit | "JUnit 6 kèm Mockito: 18 lần chạy đều đạt." |
| TestNG | "TestNG cũng 18 lần, đều đạt." |
| Spock | "Spock báo 21, vì Surefire đếm thêm 3 nút cha của bảng `where:`; số ca chạy thật vẫn là 18." |

### Cảnh 3 – Cùng một lỗi, ba kiểu thông báo (3:30–5:00)

| Lệnh | Lời thoại gợi ý |
|---|---|
| `git diff` | "Để so sánh khả năng chẩn đoán, nhóm cố ý đổi `>=` thành `>` ở ngưỡng 500 nghìn. Đây là lỗi lệch biên rất hay gặp khi bảo trì." |
| JUnit | "JUnit bắt được lỗi, nhưng mặc định chỉ in chỉ số `[4]`; người bảo trì phải tự đếm mới biết là TC07." |
| TestNG | "TestNG in đủ tham số: TC07, 500000, 475000." |
| Spock | "Spock rõ nhất: in tên ca và giá trị của từng phần trong biểu thức." |

Chuyển sang Word, Bảng 4.6 (bảng điểm):

> "Tổng hợp theo bảy tiêu chí có trọng số, JUnit được 90 điểm, TestNG 76, Spock 69. JUnit phổ biến nhất, không cần thêm ngôn ngữ hay plugin, và so sánh giá tiền chặt nhất. Điểm yếu về thông báo lỗi khắc phục được bằng cấu hình, như phần tiếp theo."

### Cảnh 4 – Tính năng JUnit hỗ trợ bảo trì (5:00–7:30)

| Lệnh | Lời thoại gợi ý |
|---|---|
| `cat bang-gia.csv` | "Dữ liệu kiểm thử được tách ra tệp CSV. Khi chính sách giá đổi, chỉ cần sửa tệp này mà không phải sửa mã Java." |
| Cây kết quả | "Console Launcher hiện kết quả dạng cây: mỗi nhóm `@Nested` là một phân vùng nghiệp vụ, mỗi ca có tên TC rõ ràng, nên không còn cảnh chỉ in `[4]`." (cuộn để xem hết) |
| `--include-tag vip` | "Có thể chạy chọn lọc theo `@Tag`, ví dụ chỉ 11 ca VIP. Đây là kiểm thử hồi quy chọn lọc khi chỉ sửa một phần nhỏ." |
| `mvn clean verify` | "Trước khi bàn giao thì chạy toàn bộ 31 ca kèm cổng độ phủ JaCoCo." |
| `open …jacoco…` | Chuyển sang trình duyệt: "Báo cáo độ phủ đạt 100% dòng và nhánh." |

(Không bắt buộc) chuyển sang IntelliJ, tab `CheckoutApplicationServiceJUnitTest.java`:

> "`MockitoExtension` tạo đối tượng giả cho kho lưu đơn, nhờ đó kiểm tra được rằng mã đơn sai thì hệ thống không lưu gì."

### Cảnh 5 – Chuỗi kịch bản bảo trì KB1–KB5 (7:30–12:30)

Lệnh `git log` đầu cảnh:

> "Mỗi kịch bản có mốc trước và sau được đánh dấu bằng tag git; script chạy lại từng mốc."

| Kịch bản | Lời thoại gợi ý (nói trong lúc kết quả hiện ra) |
|---|---|
| KB1 – Phòng ngừa | "Đo độ phủ của bộ test gốc: chỉ 75% nhánh, còn thiếu ca giá null và mã đơn trống. Sau khi bổ sung thì đạt 100%. Nhóm đặt thêm cổng chặn: nếu độ phủ tụt, ví dụ chỉ chạy một phần test, thì build thất bại." |
| KB2 – Thích nghi | "Các bản JDK sau này sẽ cấm nạp agent khi đang chạy, theo JEP 451. Giả lập bằng cờ JVM: bản cũ lỗi 5 ca dùng Mockito. Sau khi cấu hình Mockito làm javaagent thì đạt 19/19, và chạy được cả trên JDK 25 và 27." |
| KB3 – Hoàn thiện (VIP) | "Yêu cầu mới: khách VIP giảm thêm 2%. Nhóm viết test trước: 9 ca đỏ cho biết chính xác số tiền đúng phải là bao nhiêu. Sau khi cài đặt, 30/30 đạt." |
| KB4 – Hoàn thiện (tái cấu trúc) | "Tái cấu trúc bậc giảm giá thành bảng tra nhưng dùng nhầm `lowerEntry`. 6 ca đỏ, đều nằm đúng ngưỡng. Đáng chú ý là độ phủ vẫn 100%: độ phủ không chứng minh mã đúng, chính các ca giá trị biên mới bắt được lỗi. Sửa thành `floorEntry`, bộ test không đổi dòng nào, 30/30 đạt." |
| KB5 – Sửa lỗi | "Phiếu lỗi: mã đơn bị lưu kèm khoảng trắng. Nhóm viết TC28 tái hiện lỗi và chạy riêng ca đó; Mockito chỉ đúng tham số bị sai. Sửa một dòng bằng `strip()`, chạy lại toàn bộ 31/31 đạt. TC28 được giữ lại để lỗi không quay lại." |

Kết quả KB3 và KB4 dài, nên cuộn lên trong lúc nói nếu cần.

### Cảnh 6 – Kết luận (12:30–13:15) · Terminal rồi Word (mục lục)

> "Tóm lại, công cụ hỗ trợ kiểm thử hỗ trợ đủ bốn loại bảo trì: phòng ngừa, thích nghi, hoàn thiện và sửa lỗi. Nhóm đề xuất JUnit kết hợp Mockito. Toàn bộ mã nguồn, số liệu và kịch bản đều chạy lại được bằng các script trong thư mục `demo`, chi tiết có trong báo cáo. Cảm ơn thầy/cô đã theo dõi."

## D. Sau khi quay

- **Cắt ghép:** dùng iMovie: tạo dự án mới → kéo các file `.mov` vào → cắt các đoạn chờ thừa → Chia sẻ → Tệp → độ phân giải 1080p. Nếu chỉ cần cắt đầu và cuối, QuickTime Player → Sửa → Cắt là đủ.
- **Gửi giáo viên:** video 1080p dài khoảng 13 phút nặng vài trăm MB, quá lớn để đính kèm email. Nên tải lên Google Drive rồi gửi đường link, hoặc tải lên YouTube ở chế độ *Không công khai*.
- **Tên file gợi ý:** `Nhom[..]_BaiTap1_Demo_CongCuKiemThu.mp4`.

## E. Sự cố thường gặp

| Hiện tượng | Cách xử lý |
|---|---|
| `mvn -version` ra Java 27 | Mở cửa sổ Terminal mới, hoặc chạy `export JAVA_HOME=$(/usr/libexec/java_home -v 21)` |
| `Cannot access central … in offline mode` | Chạy một lần khi có mạng: `mvn clean verify && mvn -Ptestng clean test && mvn -Pspock clean test` |
| Nói vấp, muốn quay lại một cảnh | `Ctrl + C`, rồi `bash demo/video.sh <số cảnh>`, sau đó ghép lại trong iMovie |
| Trình duyệt không mở báo cáo JaCoCo | Chạy `open target/site/jacoco/index.html` sau khi đã chạy `mvn clean verify` |
