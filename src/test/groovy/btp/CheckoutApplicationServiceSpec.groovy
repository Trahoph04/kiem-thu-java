package btp

import spock.lang.Specification

class CheckoutApplicationServiceSpec extends Specification {
    OrderRepository repository = Mock()
    def application = new CheckoutApplicationService(new CheckoutService(), repository)

    def "TC14: lưu đơn ORD-001 với tổng tiền 900.000 đ"() {
        when:
        def total = application.checkout("ORD-001", 1000000 as BigDecimal)

        then:
        1 * repository.save("ORD-001", 900000)
        0 * _
        total == 900000
    }

    def "TC15: từ chối mã đơn [#orderId], không lưu đơn"() {
        when:
        application.checkout(orderId, 1000000 as BigDecimal)

        then:
        thrown(IllegalArgumentException)
        0 * repository._

        where:
        orderId << [null, "", "   "]
    }

    def "TC16: từ chối giá 0 đ, không lưu đơn"() {
        when:
        application.checkout("ORD-002", 0 as BigDecimal)

        then:
        thrown(IllegalArgumentException)
        0 * repository._
    }
}
