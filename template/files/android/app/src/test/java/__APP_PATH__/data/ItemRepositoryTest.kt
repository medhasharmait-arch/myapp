package __APP_ID__.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ItemRepositoryTest {

    @Test
    fun `items returns exactly the 5 planets in spec order`() {
        val expected = listOf(
            Item("1", "Mercury", "Closest to the Sun"),
            Item("2", "Venus", "Hottest planet"),
            Item("3", "Earth", "Home"),
            Item("4", "Mars", "The red planet"),
            Item("5", "Jupiter", "Largest planet"),
        )
        assertEquals(expected, ItemRepository().items())
    }

    @Test
    fun `item looks up by id`() {
        val repository = ItemRepository()
        assertEquals("Earth", repository.item("3")?.title)
        assertNull(repository.item("42"))
    }

    // Examples table in specs/search.md.
    @Test
    fun `blank query returns every item in order`() {
        val all = ItemRepository().items()
        assertEquals(all, ItemRepository().search(""))
        assertEquals(all, ItemRepository().search("   "))
    }

    @Test
    fun `search matches subtitles and keeps order`() {
        assertEquals(listOf("Venus", "Mars", "Jupiter"), ItemRepository().search("planet").map { it.title })
    }

    @Test
    fun `search is case-insensitive and trims the query`() {
        assertEquals(listOf("Earth"), ItemRepository().search("EARTH").map { it.title })
        assertEquals(listOf("Mars"), ItemRepository().search("  mars ").map { it.title })
    }

    @Test
    fun `search with no match returns nothing`() {
        assertTrue(ItemRepository().search("pluto").isEmpty())
        assertTrue(ItemRepository.empty().search("").isEmpty())
    }

    @Test
    fun `empty repository returns no items`() {
        assertTrue(ItemRepository.empty().items().isEmpty())
        assertNull(ItemRepository.empty().item("1"))
    }
}
