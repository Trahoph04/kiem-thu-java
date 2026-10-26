package btp;

import java.math.BigDecimal;

/** Kiểm tra nhanh nghiệp vụ bán hàng, không cần thư viện kiểm thử ngoài. */
public class SmokeCheck {
    public static void main(String[] args) {
        CheckoutService checkout = new CheckoutService();
        check("no discount", checkout.finalPrice(new BigDecimal("300000")).compareTo(new BigDecimal("300000")) == 0);
        check("5 percent discount", checkout.finalPrice(new BigDecimal("500000")).compareTo(new BigDecimal("475000")) == 0);
        check("10 percent discount", checkout.finalPrice(new BigDecimal("1000000")).compareTo(new BigDecimal("900000")) == 0);
        check("rounds final VND amount", checkout.finalPrice(new BigDecimal("999999")).compareTo(new BigDecimal("949999")) == 0);
        try {
            checkout.finalPrice(BigDecimal.ZERO);
            throw new AssertionError("zero subtotal should fail");
        } catch (IllegalArgumentException expected) {
            System.out.println("PASS: rejects zero subtotal");
        }
        System.out.println("Smoke checks completed.");
    }

    private static void check(String name, boolean passed) {
        if (!passed) throw new AssertionError("FAILED: " + name);
        System.out.println("PASS: " + name);
    }
}
