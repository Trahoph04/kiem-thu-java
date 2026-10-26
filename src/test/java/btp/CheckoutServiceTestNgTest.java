package btp;

import java.math.BigDecimal;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import static org.testng.Assert.assertEquals;

public class CheckoutServiceTestNgTest {
    private final CheckoutService service = new CheckoutService();

    @DataProvider(name = "validOrders")
    public Object[][] validOrders() {
        return new Object[][] {
            {"TC04", "1", "1"},
            {"TC05", "300000", "300000"},
            {"TC06", "499999", "499999"},
            {"TC07", "500000", "475000"},
            {"TC08", "750000", "712500"},
            {"TC09", "999999", "949999"},
            {"TC10", "1000000", "900000"},
            {"TC11", "2000000", "1800000"},
            {"TC12", "500010", "475010"},
            {"TC13", "1000005", "900005"}
        };
    }

    @Test(dataProvider = "validOrders")
    public void calculatesFinalPrice(String id, String subtotal, String expected) {
        assertEquals(service.finalPrice(new BigDecimal(subtotal)), new BigDecimal(expected));
    }

    @DataProvider(name = "invalidSubtotals")
    public Object[][] invalidSubtotals() {
        return new Object[][] {
            {"TC01", null},
            {"TC02", new BigDecimal("-1")},
            {"TC03", BigDecimal.ZERO}
        };
    }

    @Test(dataProvider = "invalidSubtotals", expectedExceptions = IllegalArgumentException.class)
    public void rejectsInvalidSubtotal(String id, BigDecimal subtotal) {
        service.finalPrice(subtotal);
    }
}
