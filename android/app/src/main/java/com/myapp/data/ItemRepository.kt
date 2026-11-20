package com.myapp.data

/**
 * Hard-coded data source for the starter app (specs/starter.md).
 *
 * The default instance returns the 5 planets; [empty] returns nothing and drives the
 * ListScreen empty state.
 */
class ItemRepository(private val source: List<Item> = PLANETS) {

    fun items(): List<Item> = source

    fun item(id: String): Item? = source.firstOrNull { it.id == id }

    companion object {
        val PLANETS: List<Item> = listOf(
            Item(id = "1", title = "Mercury", subtitle = "Closest to the Sun"),
            Item(id = "2", title = "Venus", subtitle = "Hottest planet"),
            Item(id = "3", title = "Earth", subtitle = "Home"),
            Item(id = "4", title = "Mars", subtitle = "The red planet"),
            Item(id = "5", title = "Jupiter", subtitle = "Largest planet"),
        )

        fun empty(): ItemRepository = ItemRepository(emptyList())
    }
}
