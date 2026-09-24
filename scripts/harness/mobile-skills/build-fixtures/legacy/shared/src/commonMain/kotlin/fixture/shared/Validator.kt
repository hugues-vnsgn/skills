package fixture.shared
object Validator {
    fun isValid(value: String): Boolean = value.trim().length >= 3
}
