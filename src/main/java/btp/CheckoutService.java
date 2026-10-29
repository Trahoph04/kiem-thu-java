package btp;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;
import java.util.NavigableMap;
import java.util.TreeMap;

/** Tính giá thanh toán theo chính sách giảm giá minh họa của cửa hàng. */
public class CheckoutService {
    /** Ngưỡng tổng tiền (đ) → tỉ lệ giảm. Thêm bậc mới chỉ cần thêm một dòng. */
    private static final NavigableMap<BigDecimal, BigDecimal> DISCOUNT_TIERS = new TreeMap<>(Map.of(
            BigDecimal.ZERO, BigDecimal.ZERO,
            new BigDecimal("500000"), new BigDecimal("0.05"),
            new BigDecimal("1000000"), new BigDecimal("0.10")));
    private static final BigDecimal VIP_BONUS = new BigDecimal("0.02");

    public BigDecimal finalPrice(BigDecimal subtotal) {
        return finalPrice(subtotal, false);
    }

    /** Khách VIP được giảm thêm 2 điểm phần trăm so với bậc thường. */
    public BigDecimal finalPrice(BigDecimal subtotal, boolean vip) {
        if (subtotal == null || subtotal.signum() <= 0) {
            throw new IllegalArgumentException("Giá trị đơn hàng phải lớn hơn 0");
        }

        BigDecimal discountRate = DISCOUNT_TIERS.lowerEntry(subtotal).getValue();
        if (vip) {
            discountRate = discountRate.add(VIP_BONUS);
        }

        return subtotal.multiply(BigDecimal.ONE.subtract(discountRate))
                .setScale(0, RoundingMode.HALF_UP);
    }
}
