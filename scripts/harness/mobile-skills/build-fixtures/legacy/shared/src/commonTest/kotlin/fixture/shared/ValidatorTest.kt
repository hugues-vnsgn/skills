package fixture.shared
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue
class ValidatorTest {
    @Test fun rejectsBlankAndShortValues() {
        assertFalse(Validator.isValid("   "))
        assertFalse(Validator.isValid(" ab "))
    }
    @Test fun acceptsTrimmedThreeCharacterValues() {
        assertTrue(Validator.isValid(" abc "))
    }
}
