package btp;

import java.math.BigDecimal;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Timeout;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvFileSource;
import org.junit.jupiter.params.provider.CsvSource;
import static org.junit.jupiter.api.Assertions.*;

@Tag("tinh-gia")
@DisplayName("CheckoutService – tính giá thanh toán")
class CheckoutServiceJUnitTest {
    private final CheckoutService service = new CheckoutService();

    @Nested
    @DisplayName("V0 – giá không hợp lệ")
    class InvalidSubtotal {
        @ParameterizedTest(name = "{0}: từ chối giá {1}", quoteTextArguments = false)
        @DisplayName("TC01–TC03: ném IllegalArgumentException")
        @CsvSource(value = {"TC01, null", "TC02, -1", "TC03, 0"}, nullValues = "null")
        void rejectsInvalidSubtotal(String id, BigDecimal subtotal) {
            IllegalArgumentException error =
                    assertThrows(IllegalArgumentException.class, () -> service.finalPrice(subtotal));
            assertEquals("Giá trị đơn hàng phải lớn hơn 0", error.getMessage());
        }
    }

    @Nested
    @DisplayName("V1–V3 – bậc giảm giá và làm tròn")
    class DiscountTiers {
        @ParameterizedTest(name = "{0}: {1} đ → {2} đ", quoteTextArguments = false)
        @DisplayName("TC04–TC13: dữ liệu từ bang-gia.csv")
        @CsvFileSource(resources = "/bang-gia.csv", numLinesToSkip = 1)
        void calculatesFinalPrice(String id, BigDecimal subtotal, BigDecimal expected) {
            BigDecimal actual = service.finalPrice(subtotal);
            assertAll(
                () -> assertEquals(expected, actual, id + ": sai thành tiền"),
                () -> assertEquals(0, actual.scale(), id + ": giá cuối phải làm tròn đến đồng")
            );
        }
    }

    @Nested
    @Tag("vip")
    @DisplayName("KB3 – khách VIP giảm thêm 2%")
    class VipCustomer {
        @ParameterizedTest(name = "{0}: VIP {1} đ → {2} đ", quoteTextArguments = false)
        @DisplayName("TC17–TC25: dữ liệu từ bang-gia-vip.csv")
        @CsvFileSource(resources = "/bang-gia-vip.csv", numLinesToSkip = 1)
        void calculatesVipPrice(String id, BigDecimal subtotal, BigDecimal expected) {
            assertEquals(expected, service.finalPrice(subtotal, true), id + ": sai thành tiền VIP");
        }

        @Test
        @DisplayName("TC26: VIP vẫn từ chối giá 0 đ")
        void rejectsInvalidVipSubtotal() {
            assertThrows(IllegalArgumentException.class, () -> service.finalPrice(BigDecimal.ZERO, true));
        }
    }

    @Nested
    @Tag("hieu-nang")
    @DisplayName("Hiệu năng")
    class Performance {
        @Test
        @Timeout(1)
        @DisplayName("HN01: tính 100.000 đơn trong dưới 1 giây")
        void calculatesManyOrdersQuickly() {
            for (long i = 1; i <= 100_000; i++) {
                service.finalPrice(BigDecimal.valueOf(i * 10));
            }
        }
    }
}
