package btp;

import java.math.BigDecimal;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import static org.testng.Assert.assertEquals;

public class CheckoutServiceTestNgTest {
    private final CheckoutService service = new CheckoutService();

    @DataProvider(name = "orderCases")
    public Object[][] orderCases() {
        return new Object[][] {
            {"100000", "100000"},
            {"499999", "499999"},
            {"500000", "475000"},
            {"999999", "949999"},
            {"1000000", "900000"}
        };
    }

    @Test(dataProvider = "orderCases")
    public void calculatesFinalPrice(String subtotal, String expected) {
        assertEquals(service.finalPrice(new BigDecimal(subtotal)), new BigDecimal(expected));
    }
}
