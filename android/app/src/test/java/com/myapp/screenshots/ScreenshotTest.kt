package com.myapp.screenshots

import androidx.compose.runtime.Composable
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.github.takahirom.roborazzi.RobolectricDeviceQualifiers
import com.github.takahirom.roborazzi.captureRoboImage
import com.myapp.data.ItemRepository
import com.myapp.ui.screens.DetailScreen
import com.myapp.ui.screens.HomeScreen
import com.myapp.ui.screens.ListScreen
import com.myapp.ui.theme.MyAppTheme
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * One screenshot per state in the specs/starter.md "States" table, in light and dark mode.
 * Files: src/test/snapshots/<Screen>_<state>_<light|dark>.png
 *
 * Record: ./gradlew :app:recordRoborazziDebug   Verify: ./gradlew :app:verifyRoborazziDebug
 */
@RunWith(AndroidJUnit4::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(qualifiers = RobolectricDeviceQualifiers.Pixel7)
class ScreenshotTest {

    @Test fun homeDefaultLight() = snap("HomeScreen_default", dark = false) { home() }
    @Test fun homeDefaultDark() = snap("HomeScreen_default", dark = true) { home() }

    @Test fun listItemsLight() = snap("ListScreen_items", dark = false) { list(ItemRepository()) }
    @Test fun listItemsDark() = snap("ListScreen_items", dark = true) { list(ItemRepository()) }

    @Test fun listEmptyLight() = snap("ListScreen_empty", dark = false) { list(ItemRepository.empty()) }
    @Test fun listEmptyDark() = snap("ListScreen_empty", dark = true) { list(ItemRepository.empty()) }

    // specs/search.md
    @Test fun listSearchLight() = snap("ListScreen_search_planet", dark = false) { list(ItemRepository(), "planet") }
    @Test fun listSearchDark() = snap("ListScreen_search_planet", dark = true) { list(ItemRepository(), "planet") }

    @Test fun listNoResultsLight() = snap("ListScreen_search_noresults", dark = false) { list(ItemRepository(), "pluto") }
    @Test fun listNoResultsDark() = snap("ListScreen_search_noresults", dark = true) { list(ItemRepository(), "pluto") }

    @Test fun detailEarthLight() = snap("DetailScreen_earth", dark = false) { earth() }
    @Test fun detailEarthDark() = snap("DetailScreen_earth", dark = true) { earth() }

    @Composable private fun home() = HomeScreen(onSeePlanets = {})

    @Composable private fun list(repository: ItemRepository, query: String = "") =
        ListScreen(items = repository.items(), query = query, onQueryChange = {}, onBack = {}, onItemClick = {})

    @Composable private fun earth() =
        DetailScreen(item = requireNotNull(ItemRepository().item("3")), onBack = {})

    private fun snap(name: String, dark: Boolean, content: @Composable () -> Unit) {
        // Switch the night qualifier before the capture activity launches, so the system
        // (isSystemInDarkTheme, window theme) is in the same mode as the Compose theme.
        RuntimeEnvironment.setQualifiers(if (dark) "+night" else "+notnight")
        val mode = if (dark) "dark" else "light"
        captureRoboImage("src/test/snapshots/${name}_$mode.png") {
            MyAppTheme(content = content)
        }
    }
}
