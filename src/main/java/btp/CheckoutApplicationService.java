package btp;

import java.math.BigDecimal;

public class CheckoutApplicationService {
    private final CheckoutService checkoutService;
    private final OrderRepository repository;

    public CheckoutApplicationService(CheckoutService checkoutService, OrderRepository repository) {
        this.checkoutService = checkoutService;
        this.repository = repository;
    }

    public BigDecimal checkout(String orderId, BigDecimal subtotal) {
        return checkout(orderId, subtotal, false);
    }

    public BigDecimal checkout(String orderId, BigDecimal subtotal, boolean vip) {
        if (orderId == null || orderId.isBlank()) {
            throw new IllegalArgumentException("Mã đơn hàng không được để trống");
        }
        BigDecimal finalPrice = checkoutService.finalPrice(subtotal);
        repository.save(orderId, finalPrice);
        return finalPrice;
    }
}
