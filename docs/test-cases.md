# Bộ ca kiểm thử chung cho 3 công cụ

JUnit 5, TestNG và Spock cùng thực thi **đúng bộ ca dưới đây** trên cùng mã nguồn (`btp.CheckoutService`, `btp.CheckoutApplicationService`), cùng JDK 21 và Maven. Nhờ vậy, khác biệt trong kết quả so sánh chỉ đến từ công cụ.

## 1. Đặc tả được kiểm thử

- `finalPrice(subtotal)`: dưới 500.000 đ thì không giảm; từ 500.000 đ giảm 5%; từ 1.000.000 đ giảm 10%. Kết quả làm tròn `HALF_UP` đến đồng (scale 0). `subtotal` là `null` hoặc ≤ 0 thì ném `IllegalArgumentException`.
- `checkout(orderId, subtotal)`: `orderId` là `null` hoặc rỗng/toàn khoảng trắng thì ném `IllegalArgumentException`. Nếu hợp lệ, tính giá rồi lưu **một lần** qua `OrderRepository.save(orderId, finalPrice)`. Khi có lỗi thì **không** được lưu.

## 2. Phân vùng tương đương và giá trị biên của `subtotal`

| Vùng | Miền giá trị | Kết quả | Giá trị biên | Giá trị đại diện |
|---|---|---|---|---|
| V0, không hợp lệ | `null`, ≤ 0 | Ngoại lệ | 0 | `null`, −1 |
| V1, không giảm | 1 – 499.999 | Giữ nguyên | 1; 499.999 | 300.000 |
| V2, giảm 5% | 500.000 – 999.999 | × 0,95 | 500.000; 999.999 | 750.000 |
| V3, giảm 10% | ≥ 1.000.000 | × 0,90 | 1.000.000 | 2.000.000 |

Ngoài ra có 2 ca kiểm tra quy tắc làm tròn `HALF_UP`, chọn sao cho phần lẻ đúng bằng ,5. Ca 999.999 cho ra 949.999,05, tức là chỉ làm tròn xuống, nên không kiểm tra được quy tắc này.

## 3. Bảng ca kiểm thử

| Mã | Nhóm | Đầu vào | Kết quả mong đợi | Kỹ thuật |
|---|---|---|---|---|
| TC01 | Giá không hợp lệ | `subtotal = null` | `IllegalArgumentException` | Phân vùng V0 |
| TC02 | Giá không hợp lệ | `subtotal = -1` | `IllegalArgumentException` | Phân vùng V0 |
| TC03 | Giá không hợp lệ | `subtotal = 0` | `IllegalArgumentException` | Biên V0/V1 |
| TC04 | Không giảm | 1 | 1 | Biên dưới V1 |
| TC05 | Không giảm | 300.000 | 300.000 | Đại diện V1 |
| TC06 | Không giảm | 499.999 | 499.999 | Biên trên V1 |
| TC07 | Giảm 5% | 500.000 | 475.000 | Biên dưới V2 |
| TC08 | Giảm 5% | 750.000 | 712.500 | Đại diện V2 |
| TC09 | Giảm 5% | 999.999 | 949.999 (từ 949.999,05) | Biên trên V2 |
| TC10 | Giảm 10% | 1.000.000 | 900.000 | Biên dưới V3 |
| TC11 | Giảm 10% | 2.000.000 | 1.800.000 | Đại diện V3 |
| TC12 | Làm tròn | 500.010 | 475.010 (từ 475.009,5) | `HALF_UP` ở V2 |
| TC13 | Làm tròn | 1.000.005 | 900.005 (từ 900.004,5) | `HALF_UP` ở V3 |
| TC14 | Lưu đơn (mock) | `"ORD-001"`, 1.000.000 | Trả về 900.000; `save("ORD-001", 900000)` đúng 1 lần, không tương tác nào khác | Kiểm thử tương tác |
| TC15 | Mã đơn không hợp lệ | `orderId` = `null`, `""`, `"   "` (3 lần chạy) | `IllegalArgumentException`; không gọi `save` | Phân vùng không hợp lệ |
| TC16 | Lỗi lan truyền | `"ORD-002"`, 0 | `IllegalArgumentException`; không gọi `save` | Kiểm thử tương tác |

Tổng cộng có **16 ca và 18 lần thực thi**, vì TC15 chạy với 3 giá trị. Mỗi công cụ phải báo `Tests run: 18`.

## 4. Vị trí cài đặt trong từng công cụ

| Mã | JUnit 5 (`*JUnitTest.java`) | TestNG (`*TestNgTest.java`) | Spock (`*Spec.groovy`) |
|---|---|---|---|
| TC01–03 | `CheckoutServiceJUnitTest.rejectsInvalidSubtotal` | `CheckoutServiceTestNgTest.rejectsInvalidSubtotal` | `CheckoutServiceSpec` – "#id: từ chối giá #subtotal" |
| TC04–13 | `CheckoutServiceJUnitTest.calculatesFinalPrice` | `CheckoutServiceTestNgTest.calculatesFinalPrice` | `CheckoutServiceSpec` – "#id: #subtotal đ → #expected đ" |
| TC14 | `CheckoutApplicationServiceJUnitTest.savesOrderWithFinalPrice` | `CheckoutApplicationServiceTestNgTest.savesOrderWithFinalPrice` | `CheckoutApplicationServiceSpec` – "TC14: …" |
| TC15 | `CheckoutApplicationServiceJUnitTest.rejectsBlankOrderIdWithoutSaving` | `CheckoutApplicationServiceTestNgTest.rejectsBlankOrderIdWithoutSaving` | `CheckoutApplicationServiceSpec` – "TC15: …" |
| TC16 | `CheckoutApplicationServiceJUnitTest.rejectsInvalidSubtotalWithoutSaving` | `CheckoutApplicationServiceTestNgTest.rejectsInvalidSubtotalWithoutSaving` | `CheckoutApplicationServiceSpec` – "TC16: …" |
