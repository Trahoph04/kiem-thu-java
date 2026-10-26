package btp;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class CheckoutApplicationServiceTest {
    @Test void calculatesAndSavesOrderUsingMockRepository() {
        OrderRepository repository = mock(OrderRepository.class);
        CheckoutApplicationService application = new CheckoutApplicationService(new CheckoutService(), repository);

        BigDecimal total = application.checkout("ORD-001", new BigDecimal("1000000"));

        assertEquals(new BigDecimal("900000"), total);
        verify(repository).save("ORD-001", new BigDecimal("900000"));
        verifyNoMoreInteractions(repository);
    }
}
