# Chuỗi kịch bản bảo trì với JUnit

Đây là dữ liệu cho câu hỏi 1 (vai trò của công cụ kiểm thử trong bảo trì) và câu hỏi 4 (kịch bản minh họa). Mỗi kịch bản là một yêu cầu bảo trì có thật trên module Checkout. Mỗi mốc được đánh dấu bằng tag git, nên có thể chạy lại bằng:

```bash
bash demo/kich-ban.sh tat-ca    # hoặc kb1 … kb5
```

Script chạy từng tag trong một worktree tạm, nên không làm thay đổi thư mục đang mở. Log được ghi vào `target/demo-logs/`. Log gốc lúc thực hiện nằm trong `demo-output/kb*`.

## Phân loại bảo trì dùng trong tài liệu

Theo ISO/IEC/IEEE 14764, có 4 loại bảo trì:

- **Sửa lỗi** (corrective): sửa lỗi đã phát hiện sau khi bàn giao.
- **Phòng ngừa** (preventive): phát hiện và loại bỏ lỗi tiềm ẩn trước khi chúng gây sự cố.
- **Thích nghi** (adaptive): giữ cho phần mềm dùng được khi môi trường thay đổi.
- **Hoàn thiện** (perfective): bổ sung tính năng hoặc cải thiện hiệu năng và khả năng bảo trì.

## Tổng quan

| KB | Loại bảo trì | Yêu cầu | Tag | Tính năng JUnit chính | Kết quả trước → sau |
|---|---|---|---|---|---|
| 1 | Phòng ngừa | Trước khi nhận thay đổi, đánh giá lưới an toàn của bộ test hiện có | `kb1-truoc` → `kb1-sau` | Tích hợp JaCoCo, `@CsvSource(nullValues)`, `@NullAndEmptySource`, `jacoco:check` | Phủ nhánh 75% → 100%; build tự chặn khi độ phủ giảm |
| 2 | Thích nghi | Các JDK sau này sẽ cấm nạp agent khi đang chạy (JEP 451); hệ thống chuẩn bị nâng JDK | `kb2-truoc` → `kb2-sau` | Hạ tầng chạy test (Surefire `argLine`, Mockito agent), chạy lại trên nhiều JDK | 5 ca lỗi → 19/19 đạt trên JDK 21, 25, 27 |
| 3 | Hoàn thiện (thêm tính năng) | Khách VIP được giảm thêm 2 điểm phần trăm | `kb3-truoc` → `kb3-sau` | Viết test trước (TDD), `@CsvFileSource`, `@Tag("vip")` | 9 ca đỏ → 30/30 đạt |
| 4 | Hoàn thiện (tái cấu trúc) | Đổi chuỗi `if` thành bảng tra để dễ thêm bậc giảm giá | `kb4-truoc` → `kb4-loi` → `kb4-sau` | Kiểm thử hồi quy, giá trị biên, `assertAll`, `@Timeout` | 6 ca đỏ (độ phủ vẫn 100%) → 30/30 đạt, test không đổi dòng nào |
| 5 | Sửa lỗi | BUG-01: mã đơn bị lưu kèm khoảng trắng | `kb5-truoc` → `kb5-sau` | Test tái hiện lỗi, chạy riêng một test (`-Dtest`), `verify` của Mockito | TC28 đỏ → 31/31 đạt |

## KB1 – Phòng ngừa: tìm phần mã chưa có lưới an toàn

**Bối cảnh.** Trước khi nhận các yêu cầu thay đổi, đội bảo trì cần biết bộ test hiện tại có đủ sức phát hiện lỗi hồi quy hay không.

**Các bước.**

1. Ở `kb1-truoc` (bộ test gốc, 4 test), chạy JaCoCo từ dòng lệnh mà không cần sửa `pom.xml`:
   ```
   mvn clean org.jacoco:jacoco-maven-plugin:0.8.16:prepare-agent test org.jacoco:jacoco-maven-plugin:0.8.16:report
   ```
2. Đọc báo cáo `target/site/jacoco/index.html`. Báo cáo chỉ ra 3 nhánh chưa được kiểm thử: `subtotal == null` (`CheckoutService:12`), `orderId == null` và `orderId` trống (`CheckoutApplicationService:15`), cùng dòng `throw` ở `CheckoutApplicationService:16`.
3. Bổ sung TC01 (giá `null`) và TC15 (mã đơn `null`, `""`, `"   "`). Phần này đã làm ở giai đoạn 1.
4. Ở `kb1-sau`, thêm luật `jacoco:check`: độ phủ dòng và nhánh của mã nghiệp vụ phải đạt 100%, nếu không thì `mvn verify` thất bại.

**Kết quả.**

| Mốc | Số test | Nhánh | Dòng | `mvn verify` |
|---|---|---|---|---|
| `kb1-truoc` | 4 | 9/12 (75,0%) | 20/21 (95,2%) | (chưa có cổng chặn) |
| `kb1-sau` | 19 | 12/12 (100%) | 21/21 (100%) | `All coverage checks have been met.` |
| `kb1-sau`, chỉ chạy `-Dtest=CheckoutServiceJUnitTest*` | 14 | 66% | 57% | **BUILD FAILURE**: `lines covered ratio is 0.57, but expected minimum is 1.00` |

Không tính `SmokeCheck`, vì đây là chương trình kiểm tra thủ công chứ không phải mã nghiệp vụ.

**Bài học.** Công cụ đo độ phủ biến câu hỏi "test đã đủ chưa?" thành con số đo được. Cổng chặn tự động biến chính sách "mọi nhánh nghiệp vụ phải có test" thành một ràng buộc mà build kiểm tra mỗi lần chạy, không phải dựa vào sự cẩn thận của từng người.

## KB2 – Thích nghi: chuẩn bị cho JDK cấm nạp agent động

**Bối cảnh.** Trên JDK 21 trở lên, Mockito in cảnh báo *"Mockito is currently self-attaching … This will no longer work in future releases of the JDK"*. Theo JEP 451, các bản JDK sau này sẽ mặc định cấm nạp agent khi chương trình đang chạy, và khi đó mọi test có mock sẽ hỏng. Đội bảo trì cần chuẩn bị trước khi nâng JDK.

**Các bước.**

1. Ở `kb2-truoc`, giả lập chính sách mặc định của JDK tương lai bằng cờ `-XX:-EnableDynamicAgentLoading`:
   ```
   mvn clean test -DargLine=-XX:-EnableDynamicAgentLoading
   ```
2. Ở `kb2-sau`, cấu hình Surefire nạp Mockito bằng `-javaagent` ngay khi khởi động JVM. Đường dẫn jar do `maven-dependency-plugin:properties` cung cấp. Sau đó chạy lại với cùng cờ cấm.
3. Chạy lại toàn bộ bộ test trên JDK 25.0.2 và JDK 27.0.1 có sẵn trên máy.

**Kết quả.**

| Mốc | JDK | Cờ cấm agent động | Kết quả |
|---|---|---|---|
| `kb2-truoc` | 21.0.10 | không | 18/18 đạt, có cảnh báo self-attaching |
| `kb2-truoc` | 21.0.10 | có | **5 lỗi**: `Could not initialize plugin: interface org.mockito.plugins.MockMaker`, toàn bộ ở `CheckoutApplicationServiceJUnitTest` |
| `kb2-sau` | 21.0.10 | có | 19/19 đạt |
| `kb2-sau` | 25.0.2 | không | 19/19 đạt |
| `kb2-sau` | 27.0.1 | không | 19/19 đạt |

Ghi chú trung thực: không có cờ cấm thì bộ test cũ vẫn chạy được trên cả JDK 25 và 27 (chỉ in cảnh báo). Lỗi ở dòng 2 xuất hiện khi giả lập chính sách sẽ áp dụng trong tương lai.

**Bài học.** Bảo trì thích nghi không chỉ áp dụng cho mã sản phẩm mà cho cả **hạ tầng kiểm thử**. Chạy lại cùng một bộ test trên nhiều môi trường là cách rẻ nhất để xác nhận phần mềm vẫn tương thích sau khi môi trường thay đổi.

## KB3 – Hoàn thiện: thêm chính sách khách VIP

**Yêu cầu.** Khách VIP được giảm thêm 2 điểm phần trăm, tức 2% / 7% / 12% thay cho 0% / 5% / 10%. Khách thường giữ nguyên.

**Các bước.**

1. **Viết test trước** (`kb3-truoc`):
   - Thêm 9 dòng dữ liệu vào `bang-gia-vip.csv` (TC17–TC25).
   - Thêm TC26 (VIP vẫn từ chối giá 0) và TC27 (lưu đơn VIP), gắn `@Tag("vip")`.
   - Code chỉ mới có khung `finalPrice(subtotal, vip)` và `checkout(orderId, subtotal, vip)`, chưa xử lý VIP.
2. Chạy test: 9 ca đỏ. Đây là danh sách việc cần làm, và mỗi dòng đỏ nói rõ con số đúng phải là bao nhiêu.
3. Cài đặt (`kb3-sau`): cộng `VIP_BONUS = 0,02` vào tỉ lệ giảm và truyền cờ `vip` từ `checkout` xuống.
4. Chạy lại: các ca VIP đã xanh, nhưng **TC14 đỏ**. TC14 kiểm tra rằng phải gọi `finalPrice(1000000)` (hàm một tham số), trong khi code mới gọi `finalPrice(1000000, false)`. Đây là **test giòn**, tức kiểm tra quá chặt vào cách cài đặt bên trong. Sửa 1 dòng test để kiểm tra lời gọi mới.

**Kết quả.**

| Mốc | Kết quả | Ghi chú |
|---|---|---|
| `kb3-truoc` | 30 ca, **9 đỏ** (TC18–TC25, TC27) | Ví dụ: `TC20: sai thành tiền VIP ==> expected: <465000> but was: <475000>`. TC17 và TC26 tình cờ đã đúng |
| sau khi cài đặt | 30 ca, 1 đỏ (TC14) | `Argument(s) are different! Wanted: checkoutService.finalPrice(1000000); Actual: checkoutService.finalPrice(1000000, false)` |
| `kb3-sau` | **30/30 đạt**, độ phủ 100% | Bộ TestNG và Spock cũ vẫn đạt, vì API cũ được giữ nguyên |

Bảng giá VIP:

| Mã | Tổng tiền | Thành tiền VIP |
|---|---|---|
| TC17 | 1 | 1 (từ 0,98) |
| TC18 | 300.000 | 294.000 |
| TC19 | 499.999 | 489.999 (từ 489.999,02) |
| TC20 | 500.000 | 465.000 |
| TC21 | 999.999 | 929.999 (từ 929.999,07) |
| TC22 | 1.000.000 | 880.000 |
| TC23 | 2.000.000 | 1.760.000 |
| TC24 | 500.050 | 465.047 (từ 465.046,5, `HALF_UP`) |
| TC25 | 300.025 | 294.025 (từ 294.024,5, `HALF_UP`) |

**Bài học.** Khi thêm tính năng, test viết trước vừa là đặc tả vừa là thước đo "làm xong chưa". Các ca cũ chạy lại giúp đảm bảo khách thường không bị ảnh hưởng. Chính test cũng cần được bảo trì: test kiểm tra hành vi bên ngoài thì bền, còn test kiểm tra lời gọi nội bộ thì dễ gãy.

## KB4 – Hoàn thiện: tái cấu trúc bậc giảm giá thành bảng tra

**Yêu cầu.** Chuỗi `if/else if` theo ngưỡng khó mở rộng. Cần đổi thành `NavigableMap<ngưỡng, tỉ lệ>` để sau này thêm bậc chỉ cần thêm một dòng.

**Các bước.**

1. Tái cấu trúc (`kb4-loi`), vô tình dùng `lowerEntry(subtotal)` (ngưỡng **nhỏ hơn hẳn**) thay cho `floorEntry(subtotal)` (ngưỡng **nhỏ hơn hoặc bằng**).
2. Chạy bộ test cũ, không sửa gì: 6 ca đỏ.
3. Thử chạy với `-Dmaven.test.failure.ignore=true`: **độ phủ vẫn 100%** và cổng JaCoCo vẫn cho qua.
4. Sửa thành `floorEntry` (`kb4-sau`): 30/30 đạt. HN01 (`@Timeout`) cũng đạt, nên không có hồi quy về hiệu năng.

**Kết quả.**

| Mốc | Kết quả |
|---|---|
| `kb4-loi` | 30 ca, **6 đỏ**, tất cả ở **đúng ngưỡng**: TC07 (500.000 → 500.000 thay vì 475.000), TC10 (1.000.000 → 950.000), TC14, TC20, TC22, TC27 |
| `kb4-loi` (bỏ qua test đỏ) | `All coverage checks have been met.`, tức độ phủ 100% dù mã sai |
| `kb4-sau` | **30/30 đạt**; `git diff kb4-truoc kb4-sau -- src/test` rỗng (test không đổi) |

**Bài học.**

- Bộ test là **lưới an toàn cho tái cấu trúc**: hành vi không được đổi, nên test cũng không phải đổi.
- **Độ phủ không chứng minh được tính đúng.** Chính các ca **giá trị biên** (thiết kế ở giai đoạn 1) mới bắt được lỗi lệch biên.
- Nhờ `assertAll` và thông điệp có mã ca, một lần chạy liệt kê đủ cả 6 chỗ sai.

## KB5 – Sửa lỗi: BUG-01 mã đơn lưu kèm khoảng trắng

**Phiếu lỗi BUG-01.** Bộ phận chăm sóc khách hàng tra mã `ORD-003` nhưng không thấy đơn. Trong kho, mã được lưu là `"  ORD-003  "`, vì nhân viên dán mã kèm khoảng trắng.

**Các bước.**

1. Viết test tái hiện lỗi `TC28 (BUG-01)` trước khi sửa (`kb5-truoc`), rồi chạy **riêng test đó** để có phản hồi nhanh:
   ```
   mvn test -Dtest='CheckoutApplicationServiceJUnitTest#savesOrderIdWithoutSurroundingSpaces'
   ```
2. Mockito chỉ đúng chỗ khác nhau:
   ```
   Argument(s) are different! Wanted:
   repository.save("ORD-003", 300000);
   Actual invocations have different arguments at position [0]:
   repository.save("  ORD-003  ", 300000);
   ```
3. Sửa 1 dòng (`kb5-sau`): `repository.save(orderId.strip(), finalPrice)`.
4. Chạy lại TC28 (xanh), rồi chạy hồi quy toàn bộ bằng `mvn verify`: 31/31 đạt, độ phủ 100%.

**Bài học.** Quy trình sửa lỗi có công cụ hỗ trợ là: tái hiện lỗi bằng test, sửa, rồi chạy hồi quy. TC28 được giữ lại vĩnh viễn để lỗi này không quay lại mà không ai hay.

## Tổng kết vai trò của công cụ kiểm thử trong các loại bảo trì

| Loại bảo trì | Công cụ giúp gì | Minh chứng |
|---|---|---|
| Phòng ngừa | Đo và giữ chất lượng của lưới an toàn | KB1 |
| Thích nghi | Xác nhận tương thích khi môi trường thay đổi | KB2 |
| Hoàn thiện | Đặc tả trước cho tính năng mới; bảo vệ hành vi khi tái cấu trúc | KB3, KB4 |
| Sửa lỗi | Tái hiện lỗi, xác nhận đã sửa, chặn lỗi quay lại | KB5 |
