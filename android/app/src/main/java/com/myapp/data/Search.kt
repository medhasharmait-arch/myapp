package com.myapp.data

/**
 * Search rules from specs/search.md: case-insensitive "contains" on title or subtitle,
 * the query is trimmed, and a blank query matches everything. Order is preserved.
 */
fun List<Item>.search(query: String): List<Item> {
    val needle = query.trim()
    if (needle.isEmpty()) return this
    return filter {
        it.title.contains(needle, ignoreCase = true) || it.subtitle.contains(needle, ignoreCase = true)
    }
}
