package btp;

import java.math.BigDecimal;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import static org.mockito.Mockito.*;
import static org.testng.Assert.*;

public class CheckoutApplicationServiceTestNgTest {
    private OrderRepository repository;
    private CheckoutApplicationService application;

    // TestNG dùng chung một instance cho cả lớp nên phải tạo lại mock trước mỗi test.
    @BeforeMethod
    public void setUp() {
        repository = mock(OrderRepository.class);
        application = new CheckoutApplicationService(new CheckoutService(), repository);
    }

    @Test(description = "TC14: lưu đơn ORD-001 với tổng tiền 900.000 đ")
    public void savesOrderWithFinalPrice() {
        BigDecimal total = application.checkout("ORD-001", new BigDecimal("1000000"));

        assertEquals(total, new BigDecimal("900000"));
        verify(repository).save("ORD-001", new BigDecimal("900000"));
        verifyNoMoreInteractions(repository);
    }

    @DataProvider(name = "blankOrderIds")
    public Object[][] blankOrderIds() {
        return new Object[][] {{null}, {""}, {"   "}};
    }

    @Test(dataProvider = "blankOrderIds", description = "TC15: từ chối mã đơn trống, không lưu đơn")
    public void rejectsBlankOrderIdWithoutSaving(String orderId) {
        assertThrows(IllegalArgumentException.class,
                () -> application.checkout(orderId, new BigDecimal("1000000")));
        verifyNoInteractions(repository);
    }

    @Test(description = "TC16: từ chối giá 0 đ, không lưu đơn")
    public void rejectsInvalidSubtotalWithoutSaving() {
        assertThrows(IllegalArgumentException.class,
                () -> application.checkout("ORD-002", BigDecimal.ZERO));
        verifyNoInteractions(repository);
    }
}
