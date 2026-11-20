package com.myapp.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.myapp.R
import com.myapp.data.Item
import com.myapp.data.ItemRepository
import com.myapp.data.search
import com.myapp.ui.theme.MyAppTheme

/**
 * The planets list with a search field (specs/starter.md, specs/search.md).
 *
 * [items] is everything the repository has; the screen shows `items.search(query)`.
 */
@Composable
fun ListScreen(
    items: List<Item>,
    query: String,
    onQueryChange: (String) -> Unit,
    onBack: () -> Unit,
    onItemClick: (Item) -> Unit,
    modifier: Modifier = Modifier,
) {
    Scaffold(
        modifier = modifier.testTag("ListScreen"),
        topBar = { BackTopBar(title = stringResource(R.string.list_title), onBack = onBack) },
    ) { padding ->
        if (items.isEmpty()) {
            CenteredMessage(
                text = stringResource(R.string.list_empty),
                modifier = Modifier.fillMaxSize().padding(padding),
            )
            return@Scaffold
        }
        val results = items.search(query)
        // Start from the top whenever the query changes; otherwise the list keeps its
        // scroll anchor on the old first item and hides the rows above it (e.g. Mercury
        // after clearing a search for "red").
        val listState = rememberLazyListState()
        LaunchedEffect(query) { listState.scrollToItem(0) }
        Column(Modifier.fillMaxSize().padding(padding)) {
            SearchField(query = query, onQueryChange = onQueryChange)
            if (results.isEmpty()) {
                CenteredMessage(
                    text = stringResource(R.string.list_no_results, query.trim()),
                    modifier = Modifier.fillMaxSize(),
                )
            } else {
                LazyColumn(state = listState) {
                    items(results, key = { it.id }) { item ->
                        ListItem(
                            headlineContent = { Text(item.title) },
                            supportingContent = { Text(item.subtitle) },
                            modifier = Modifier.clickable { onItemClick(item) },
                        )
                        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
                    }
                }
            }
        }
    }
}

@Composable
private fun SearchField(query: String, onQueryChange: (String) -> Unit) {
    OutlinedTextField(
        value = query,
        onValueChange = onQueryChange,
        placeholder = { Text(stringResource(R.string.search_hint)) },
        leadingIcon = {
            Icon(painter = painterResource(R.drawable.ic_search), contentDescription = null)
        },
        trailingIcon = if (query.isEmpty()) {
            null
        } else {
            {
                IconButton(onClick = { onQueryChange("") }) {
                    Icon(
                        painter = painterResource(R.drawable.ic_close),
                        contentDescription = stringResource(R.string.search_clear),
                    )
                }
            }
        },
        singleLine = true,
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .testTag("SearchField"),
    )
}

@Composable
private fun CenteredMessage(text: String, modifier: Modifier = Modifier) {
    Box(modifier = modifier.padding(horizontal = 24.dp), contentAlignment = Alignment.Center) {
        Text(
            text = text,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun ListScreenPreview() {
    MyAppTheme {
        ListScreen(ItemRepository.PLANETS, query = "", onQueryChange = {}, onBack = {}, onItemClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun ListScreenSearchPreview() {
    MyAppTheme {
        ListScreen(ItemRepository.PLANETS, query = "planet", onQueryChange = {}, onBack = {}, onItemClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun ListScreenEmptyPreview() {
    MyAppTheme {
        ListScreen(emptyList(), query = "", onQueryChange = {}, onBack = {}, onItemClick = {})
    }
}
