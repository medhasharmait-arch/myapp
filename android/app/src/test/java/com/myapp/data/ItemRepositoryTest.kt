package com.myapp.data

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

    @Test
    fun `empty repository returns no items`() {
        assertTrue(ItemRepository.empty().items().isEmpty())
        assertNull(ItemRepository.empty().item("1"))
    }
}
