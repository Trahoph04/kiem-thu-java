package btp;

import java.math.BigDecimal;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@Tag("luu-don")
@ExtendWith(MockitoExtension.class)
@DisplayName("CheckoutApplicationService – thanh toán và lưu đơn")
class CheckoutApplicationServiceJUnitTest {
    @Spy private CheckoutService checkoutService;
    @Mock private OrderRepository repository;
    @InjectMocks private CheckoutApplicationService application;
    @Captor private ArgumentCaptor<BigDecimal> savedPrice;

    @Test
    @DisplayName("TC14: lưu đơn ORD-001 với tổng tiền 900.000 đ")
    void savesOrderWithFinalPrice() {
        BigDecimal total = application.checkout("ORD-001", new BigDecimal("1000000"));

        verify(repository).save(eq("ORD-001"), savedPrice.capture());
        assertAll(
            () -> assertEquals(new BigDecimal("900000"), total),
            () -> assertEquals(total, savedPrice.getValue(), "Giá lưu phải bằng giá trả về"),
            () -> verify(checkoutService).finalPrice(new BigDecimal("1000000"), false)
        );
        verifyNoMoreInteractions(repository);
    }

    @ParameterizedTest(name = "TC15: từ chối mã đơn {0}, không lưu đơn")
    @DisplayName("TC15: mã đơn trống")
    @NullAndEmptySource
    @ValueSource(strings = "   ")
    void rejectsBlankOrderIdWithoutSaving(String orderId) {
        IllegalArgumentException error = assertThrows(IllegalArgumentException.class,
                () -> application.checkout(orderId, new BigDecimal("1000000")));
        assertEquals("Mã đơn hàng không được để trống", error.getMessage());
        verifyNoInteractions(repository, checkoutService);
    }

    @Test
    @Tag("vip")
    @DisplayName("TC27: lưu đơn VIP ORD-VIP với tổng tiền 880.000 đ")
    void savesVipOrderWithVipPrice() {
        BigDecimal total = application.checkout("ORD-VIP", new BigDecimal("1000000"), true);

        assertEquals(new BigDecimal("880000"), total);
        verify(repository).save("ORD-VIP", new BigDecimal("880000"));
    }

    @Test
    @DisplayName("TC16: từ chối giá 0 đ, không lưu đơn")
    void rejectsInvalidSubtotalWithoutSaving() {
        assertThrows(IllegalArgumentException.class,
                () -> application.checkout("ORD-002", BigDecimal.ZERO));
        verifyNoInteractions(repository);
    }
}
