package btp;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Tính giá thanh toán theo chính sách giảm giá minh họa của cửa hàng. */
public class CheckoutService {
    private static final BigDecimal FIVE_HUNDRED_THOUSAND = new BigDecimal("500000");
    private static final BigDecimal ONE_MILLION = new BigDecimal("1000000");

    public BigDecimal finalPrice(BigDecimal subtotal) {
        return finalPrice(subtotal, false);
    }

    /** Khách VIP được giảm thêm 2 điểm phần trăm so với bậc thường. */
    public BigDecimal finalPrice(BigDecimal subtotal, boolean vip) {
        if (subtotal == null || subtotal.signum() <= 0) {
            throw new IllegalArgumentException("Giá trị đơn hàng phải lớn hơn 0");
        }

        BigDecimal discountRate = BigDecimal.ZERO;
        if (subtotal.compareTo(ONE_MILLION) >= 0) {
            discountRate = new BigDecimal("0.10");
        } else if (subtotal.compareTo(FIVE_HUNDRED_THOUSAND) >= 0) {
            discountRate = new BigDecimal("0.05");
        }

        return subtotal.multiply(BigDecimal.ONE.subtract(discountRate))
                .setScale(0, RoundingMode.HALF_UP);
    }
}
