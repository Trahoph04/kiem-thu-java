package btp

import spock.lang.Specification

class CheckoutServiceSpec extends Specification {
    def service = new CheckoutService()

    def "#id: #subtotal đ → #expected đ"() {
        expect:
        service.finalPrice(subtotal as BigDecimal) == expected

        where:
        id     | subtotal | expected
        "TC04" | 1        | 1
        "TC05" | 300000   | 300000
        "TC06" | 499999   | 499999
        "TC07" | 500000   | 475000
        "TC08" | 750000   | 712500
        "TC09" | 999999   | 949999
        "TC10" | 1000000  | 900000
        "TC11" | 2000000  | 1800000
        "TC12" | 500010   | 475010
        "TC13" | 1000005  | 900005
    }

    def "#id: từ chối giá #subtotal"() {
        when:
        service.finalPrice(subtotal as BigDecimal)

        then:
        thrown(IllegalArgumentException)

        where:
        id     | subtotal
        "TC01" | null
        "TC02" | -1
        "TC03" | 0
    }
}
