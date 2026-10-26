package btp;

import java.math.BigDecimal;

public interface OrderRepository {
    void save(String orderId, BigDecimal finalPrice);
}
