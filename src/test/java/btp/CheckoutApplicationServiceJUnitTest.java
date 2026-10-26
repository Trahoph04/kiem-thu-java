package btp;

import java.math.BigDecimal;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CheckoutApplicationServiceJUnitTest {
    private final OrderRepository repository = mock(OrderRepository.class);
    private final CheckoutApplicationService application =
            new CheckoutApplicationService(new CheckoutService(), repository);

    @Test
    @DisplayName("TC14: lưu đơn ORD-001 với tổng tiền 900.000 đ")
    void savesOrderWithFinalPrice() {
        BigDecimal total = application.checkout("ORD-001", new BigDecimal("1000000"));

        assertEquals(new BigDecimal("900000"), total);
        verify(repository).save("ORD-001", new BigDecimal("900000"));
        verifyNoMoreInteractions(repository);
    }

    @ParameterizedTest(name = "TC15: từ chối mã đơn [{0}], không lưu đơn")
    @NullAndEmptySource
    @ValueSource(strings = "   ")
    void rejectsBlankOrderIdWithoutSaving(String orderId) {
        assertThrows(IllegalArgumentException.class,
                () -> application.checkout(orderId, new BigDecimal("1000000")));
        verifyNoInteractions(repository);
    }

    @Test
    @DisplayName("TC16: từ chối giá 0 đ, không lưu đơn")
    void rejectsInvalidSubtotalWithoutSaving() {
        assertThrows(IllegalArgumentException.class,
                () -> application.checkout("ORD-002", BigDecimal.ZERO));
        verifyNoInteractions(repository);
    }
}
