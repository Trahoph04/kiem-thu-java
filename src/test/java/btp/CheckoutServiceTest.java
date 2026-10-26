package btp;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CheckoutServiceTest {
    private final CheckoutService service = new CheckoutService();

    @Test void appliesDiscountAtBusinessThresholds() {
        assertAll(
            () -> assertEquals(new BigDecimal("499999"), service.finalPrice(new BigDecimal("499999"))),
            () -> assertEquals(new BigDecimal("475000"), service.finalPrice(new BigDecimal("500000"))),
            () -> assertEquals(new BigDecimal("900000"), service.finalPrice(new BigDecimal("1000000")))
        );
    }

    @Test void roundsFinalPriceToWholeVnd() {
        assertEquals(new BigDecimal("949999"), service.finalPrice(new BigDecimal("999999")));
    }

    @Test void rejectsZeroOrNegativeSubtotal() {
        assertAll(
            () -> assertThrows(IllegalArgumentException.class, () -> service.finalPrice(BigDecimal.ZERO)),
            () -> assertThrows(IllegalArgumentException.class, () -> service.finalPrice(new BigDecimal("-1")))
        );
    }
}
