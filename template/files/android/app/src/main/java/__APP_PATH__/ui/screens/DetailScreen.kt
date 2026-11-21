package __APP_ID__.ui.screens

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import __APP_ID__.data.Item
import __APP_ID__.data.ItemRepository
import __APP_ID__.ui.theme.__APP_NAME__Theme

@Composable
fun DetailScreen(
    item: Item,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Scaffold(
        modifier = modifier.testTag("DetailScreen"),
        topBar = { BackTopBar(title = item.title, onBack = onBack) },
    ) { padding ->
        Text(
            text = item.subtitle,
            style = MaterialTheme.typography.bodyLarge,
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp, vertical = 16.dp),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun DetailScreenPreview() {
    __APP_NAME__Theme { DetailScreen(item = ItemRepository.PLANETS[2], onBack = {}) }
}
