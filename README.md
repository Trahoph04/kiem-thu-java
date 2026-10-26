# Demo kiểm thử Java cho quy trình bán hàng

Dự án minh họa nghiệp vụ thanh toán đơn hàng bằng VND: dưới 500.000 đồng không giảm giá; từ 500.000 đồng giảm 5%; từ 1.000.000 đồng giảm 10%. Giá cuối cùng được làm tròn đến đồng gần nhất. JUnit 5 và TestNG là framework kiểm thử; Mockito được dùng cùng JUnit để giả lập kho lưu đơn hàng.

## Chạy kiểm tra độc lập không cần thư viện ngoài

Từ thư mục dự án trong PowerShell:

```powershell
New-Item -ItemType Directory -Force target\smoke | Out-Null
javac -encoding UTF-8 -d target\smoke src\main\java\btp\CheckoutService.java src\main\java\btp\OrderRepository.java src\main\java\btp\CheckoutApplicationService.java src\main\java\btp\SmokeCheck.java
java -cp target\smoke btp.SmokeCheck
```

## Chạy JUnit 5 + Mockito và TestNG

```powershell
mvn clean test
mvn -Ptestng clean test
```

Lượt đầu chạy JUnit 5 cùng bài test Mockito. Lượt thứ hai kích hoạt profile TestNG. Lưu kết quả lượt đầu trước khi chạy lượt sau vì `clean` xóa output cũ. Nếu CMD không nhận lệnh `mvn`, dùng đường dẫn Maven do VS Code cài:

```cmd
"%APPDATA%\Code\User\globalStorage\pleiades.java-extension-pack-jdk\maven\latest\bin\mvn.cmd" clean test
"%APPDATA%\Code\User\globalStorage\pleiades.java-extension-pack-jdk\maven\latest\bin\mvn.cmd" -Ptestng clean test
```

## Ý tưởng demo

1. Chạy test cho đơn hàng dưới 500.000 đồng: không giảm giá.
2. Chạy test tại hai ngưỡng 500.000 và 1.000.000 đồng.
3. Dùng TestNG `@DataProvider` chạy năm mức giá.
4. Dùng Mockito xác minh đơn `ORD-001` được lưu với tổng tiền 900.000 đồng.
5. Đổi tạm kết quả mong đợi trong test để cho thấy test thất bại, sau đó hoàn tác và chạy lại.

## Tài liệu Project 1

Thư mục `deliverables` chứa báo cáo Word và slide PowerPoint. Báo cáo còn các trường cần điền tên nhóm, thành viên và giảng viên. Bổ sung log mới của hai lượt Maven trước khi ghi kết quả JUnit/Mockito và TestNG vào bản nộp.
