package btp;

import java.math.BigDecimal;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import static org.junit.jupiter.api.Assertions.*;

class CheckoutServiceJUnitTest {
    private final CheckoutService service = new CheckoutService();

    @ParameterizedTest(name = "{0}: {1} đ → {2} đ")
    @CsvSource({
        "TC04, 1,       1",
        "TC05, 300000,  300000",
        "TC06, 499999,  499999",
        "TC07, 500000,  475000",
        "TC08, 750000,  712500",
        "TC09, 999999,  949999",
        "TC10, 1000000, 900000",
        "TC11, 2000000, 1800000",
        "TC12, 500010,  475010",
        "TC13, 1000005, 900005"
    })
    void calculatesFinalPrice(String id, BigDecimal subtotal, BigDecimal expected) {
        assertEquals(expected, service.finalPrice(subtotal));
    }

    @ParameterizedTest(name = "{0}: từ chối giá {1}")
    @CsvSource(value = {"TC01, null", "TC02, -1", "TC03, 0"}, nullValues = "null")
    void rejectsInvalidSubtotal(String id, BigDecimal subtotal) {
        assertThrows(IllegalArgumentException.class, () -> service.finalPrice(subtotal));
    }
}
