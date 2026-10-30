# Kịch bản quay video demo (khoảng 15 phút)

Mọi kết quả trong video đều **chạy thật trước camera**, không lấy từ báo cáo:

- Ba công cụ chạy từng ca kiểm thử, và kết quả từng ca hiện thành bảng.
- Người trình bày **tự tay sửa code để gây lỗi**, rồi chạy lại cho người xem thấy công cụ nào phát hiện và báo lỗi ra sao.
- Số liệu so sánh được đo ngay trên máy.
- Bảng kết luận tổng hợp lại từ chính các kết quả vừa chạy.

Script `demo/video.sh` chạy theo từng cảnh. Trước mỗi lệnh, script in lệnh ra rồi **chờ bạn nhấn Enter**: bạn nói xong mới nhấn để chạy. Lời thoại dưới đây chỉ là gợi ý.

## A. Chuẩn bị trước khi quay (khoảng 10 phút)

1. **Tắt thông báo:** bật Không làm phiền, đóng Zalo, Messenger, Mail.
2. **Terminal:**
   - Mở cửa sổ **mới**, chạy `cd ~/Documents/kiem-thu-java`.
   - Phóng to cửa sổ, tăng cỡ chữ bằng `Cmd +` (khoảng 16pt).
   - Rút gọn dấu nhắc: `PROMPT='%1~ $ '`.
3. **Chạy thử một lượt, không dừng** (khoảng 1,5 phút). Mã nguồn được tự khôi phục sau khi chạy xong:
   ```bash
   TU_DONG=1 bash demo/video.sh > /dev/null && echo OK
   git status --short    # không được có thay đổi nào
   ```
4. **IntelliJ IDEA:** mở thư mục dự án, mở sẵn các tab:
   - `src/main/java/btp/CheckoutService.java` (bạn sẽ sửa ở cảnh 3)
   - `docs/test-cases.md`
   - `CheckoutServiceTestNgTest.java`
   - `CheckoutServiceSpec.groovy`
   - `CheckoutServiceJUnitTest.java`
5. **Word:** mở báo cáo trong `deliverables/` (đã điền thông tin nhóm).
6. **Bắt đầu quay:** nhấn `Cmd + Shift + 5` → Ghi toàn bộ màn hình → Tùy chọn → chọn micrô → Ghi. Dừng bằng nút ⏹ trên thanh menu.

## B. Cách dùng script

| Lệnh | Tác dụng |
|---|---|
| `bash demo/video.sh` | Chạy từ cảnh 1 |
| `bash demo/video.sh 3` | Bắt đầu từ cảnh 3 (khi cần quay lại) |
| `Ctrl + C` | Dừng; nếu đang ở cảnh 3, mã nguồn **tự được khôi phục** |

## C. Kịch bản từng cảnh

### Cảnh 0 – Mở đầu (40 giây) · màn hình: trang bìa báo cáo

> "Kính chào thầy/cô. Nhóm [tên nhóm] xin trình bày demo bài tập nhóm số 1: công cụ hỗ trợ kiểm thử trong bảo trì phần mềm. Trong video, nhóm sẽ chạy trực tiếp ba công cụ JUnit, TestNG và Spock trên cùng một hệ thống, tự gây lỗi để so sánh, đo số liệu, rồi rút ra kết luận chọn công cụ. Phần cuối minh họa năm kịch bản bảo trì với công cụ được chọn."

Chuyển sang Terminal, chạy `bash demo/video.sh`.

### Cảnh 1 – Môi trường và hệ thống (1 phút)

| Màn hình | Lời thoại gợi ý |
|---|---|
| `mvn -version` | "Môi trường là JDK 21 và Maven 3.10." |
| Mã `CheckoutService` | "Hệ thống thử nghiệm là module thanh toán: dưới 500 nghìn không giảm, từ 500 nghìn giảm 5%, từ 1 triệu giảm 10%, làm tròn đến đồng." |
| IntelliJ: `docs/test-cases.md` | "Nhóm thiết kế 16 ca bằng phân vùng tương đương và giá trị biên, ví dụ TC06 và TC07 nằm hai bên ngưỡng 500 nghìn. Cả ba công cụ đều phải chạy đúng bộ ca này." |

### Cảnh 2 – Chạy thật 16 ca trên 3 công cụ (2 phút)

Trước khi nhấn Enter, chuyển nhanh qua IntelliJ cho xem ba file test:

> "Cùng một dữ liệu nhưng mỗi công cụ viết một kiểu: JUnit dùng `@CsvSource`, TestNG dùng `DataProvider`, Spock dùng bảng `where:` bằng Groovy."

Quay lại Terminal và nhấn Enter. Maven lần lượt chạy JUnit, TestNG, Spock; các dòng `Running …` và `Tests run …` hiện ra theo thời gian thực. Sau đó script in **bảng từng ca** (TC01–TC16 × 3 công cụ):

> "Đây là kết quả từng ca của cả ba công cụ, đọc trực tiếp từ báo cáo XML mà chúng vừa sinh ra. Cả ba đều chạy đủ 18 lần và đều đạt. Spock bị Surefire đếm thành 21 vì tính cả 3 nút cha của bảng `where:`. JUnit còn 13 ca bổ sung của các kịch bản bảo trì, sẽ trình bày ở phần sau."

### Cảnh 3 – Tự tay gây lỗi (2,5 phút) ★ phần quan trọng nhất

Script in hướng dẫn và chờ. Chuyển sang IntelliJ, tab `CheckoutService.java`, **dòng 28**:

> "Bây giờ nhóm sẽ tự tạo một lỗi giống lỗi lập trình viên hay mắc khi bảo trì: đổi `floorEntry` thành `lowerEntry`. Nghĩa là thay vì lấy ngưỡng *nhỏ hơn hoặc bằng*, code sẽ lấy ngưỡng *nhỏ hơn hẳn*, nên đơn đúng 500 nghìn sẽ không được giảm."

Sửa xong nhấn `Cmd + S`, quay lại Terminal và nhấn Enter. Nếu không sửa gì, script tự gây đúng lỗi này.

| Màn hình | Lời thoại gợi ý |
|---|---|
| `git diff` | "Đây là đúng một dòng vừa sửa." |
| Ba công cụ chạy lại, bảng có ✘ | "Cả ba công cụ đều phát hiện lỗi ở đúng ba ca TC07, TC10, TC14. Đó là các ca có tổng tiền nằm đúng ngưỡng 500 nghìn và 1 triệu, nhờ nhóm đã thiết kế ca kiểm thử theo giá trị biên." |
| "Cách mỗi công cụ báo lỗi ở ca TC07" | "Khác biệt nằm ở cách báo lỗi. TestNG in tham số TC07, 500000, 475000. Spock in giá trị từng phần của biểu thức. JUnit ở đây báo rõ TC07 vì nhóm đã cấu hình thêm." |
| JUnit cấu hình mặc định | "Còn nếu để JUnit mặc định như lúc so sánh ban đầu, nó chỉ in chỉ số `[4]`. Đây là điểm yếu nhóm ghi nhận khi chấm tiêu chí chẩn đoán lỗi." |
| Khôi phục | "Script khôi phục lại code đúng." |

Có thể thử thêm một lỗi khác (không bắt buộc): đổi `RoundingMode.HALF_UP` thành `HALF_DOWN`. Lần này hai ca làm tròn TC12 và TC13 sẽ đỏ.

### Cảnh 4 – Đo số liệu ngay trên máy (1 phút)

> "Ngoài khả năng phát hiện lỗi, nhóm đo chi phí sử dụng của từng công cụ: số dòng mã test, số dòng cấu hình, thư viện kéo theo, và thời gian chạy. Mỗi công cụ được chạy ba lần để đo thời gian."

Trong lúc chờ (khoảng 30 giây), giải thích tiếp:

> "Spock tốn 48 dòng cấu hình vì phải thêm Groovy và plugin biên dịch. TestNG viết dài nhất vì `DataProvider` không có kiểu. Thời gian chạy của ba công cụ gần như bằng nhau, nên không phải yếu tố quyết định."

### Cảnh 5 – Tổng hợp và kết luận (1,5 phút)

Script in hai bảng. Bảng thứ nhất là **kết quả vừa chạy trong video**, gồm số ca đạt, số ca phát hiện, cách báo lỗi, số dòng code, cấu hình, thời gian. Bảng thứ hai là **bảng điểm có trọng số**.

> "Tổng hợp những gì vừa chạy: cả ba công cụ đều phát hiện đủ lỗi; Spock chẩn đoán rõ nhất nhưng tốn cấu hình và phải học Groovy; JUnit ngắn gọn nhất, không cần plugin, và phổ biến nhất. Chấm theo bảy tiêu chí có trọng số, JUnit được 90 điểm, TestNG 76, Spock 69. Vì vậy nhóm chọn JUnit kết hợp Mockito. Điểm yếu về báo lỗi của JUnit khắc phục được bằng cấu hình, như các bạn vừa thấy ở cảnh 3."

### Cảnh 6 – Tính năng JUnit hỗ trợ bảo trì (2 phút)

| Màn hình | Lời thoại gợi ý |
|---|---|
| `bang-gia.csv` | "Dữ liệu kiểm thử tách ra tệp CSV. Đổi chính sách giá chỉ cần sửa tệp này." |
| Cây kết quả | "Kết quả dạng cây: mỗi nhóm `@Nested` là một phân vùng nghiệp vụ, mỗi ca có tên rõ ràng." |
| `--include-tag vip` | "Chạy chọn lọc theo `@Tag`, chỉ 11 ca VIP. Đây là kiểm thử hồi quy chọn lọc." |
| `mvn clean verify` + trình duyệt | "Toàn bộ 31 ca kèm cổng độ phủ JaCoCo; báo cáo độ phủ đạt 100%." |

### Cảnh 7 – Chuỗi kịch bản bảo trì KB1–KB5 (4 phút)

Mỗi kịch bản là các lần chạy Maven thật trên từng mốc git. Thời gian chạy hiện cạnh `BUILD SUCCESS` / `BUILD FAILURE`.

| Kịch bản | Lời thoại gợi ý |
|---|---|
| KB1 – Phòng ngừa | "Bộ test gốc chỉ phủ 75% nhánh. Bổ sung lên 100% và đặt cổng chặn: chạy thiếu test thì build thất bại." |
| KB2 – Thích nghi | "Giả lập JDK tương lai cấm nạp agent động: bản cũ lỗi 5 ca. Cấu hình lại thì đạt 19/19, chạy được trên JDK 25 và 27." |
| KB3 – Hoàn thiện (VIP) | "Viết test trước cho chính sách VIP: 9 ca đỏ. Cài đặt xong thì 30/30 đạt." |
| KB4 – Hoàn thiện (tái cấu trúc) | "Tái cấu trúc nhưng dùng nhầm `lowerEntry`, đúng lỗi vừa thử ở cảnh 3. 6 ca đỏ trong khi độ phủ vẫn 100%. Sửa xong thì 30/30 đạt, bộ test không đổi dòng nào." |
| KB5 – Sửa lỗi | "Viết TC28 tái hiện lỗi mã đơn có khoảng trắng; Mockito chỉ đúng tham số bị sai. Sửa một dòng, toàn bộ 31/31 đạt." |

### Cảnh 8 – Kết thúc (40 giây) · Terminal rồi Word

> "Qua demo, nhóm đã chạy trực tiếp ba công cụ, so sánh bằng số liệu và lỗi thật, chọn JUnit kết hợp Mockito, và cho thấy công cụ này hỗ trợ đủ bốn loại bảo trì. Mã nguồn, báo cáo và script chạy lại đều có trong repo của nhóm. Cảm ơn thầy/cô đã theo dõi."

## D. Sau khi quay

- **Cắt ghép:** dùng iMovie, xuất 1080p. Nếu chỉ cần cắt đầu và cuối, QuickTime → Sửa → Cắt là đủ.
- **Gửi giáo viên:** tải lên Google Drive hoặc YouTube (chế độ *Không công khai*) rồi gửi link.

## E. Sự cố thường gặp

| Hiện tượng | Cách xử lý |
|---|---|
| `mvn -version` ra Java 27 | Mở cửa sổ Terminal mới, hoặc chạy `export JAVA_HOME=$(/usr/libexec/java_home -v 21)` |
| `Cannot access central … in offline mode` | Chạy một lần khi có mạng: `mvn clean verify && mvn -Ptestng clean test && mvn -Pspock clean test` |
| Sửa code ở cảnh 3 nhưng bảng vẫn toàn ✔ | IntelliJ chưa lưu tệp: nhấn `Cmd + S`, hoặc nhấn Enter mà không sửa để script tự gây lỗi |
| Quên khôi phục code sau khi thử | `git checkout -- src/main` |
