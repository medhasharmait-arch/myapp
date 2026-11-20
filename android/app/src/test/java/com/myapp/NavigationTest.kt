package com.myapp

import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/** Home -> List -> Detail -> back -> back, on the JVM (the Maestro flow covers a real device). */
@RunWith(AndroidJUnit4::class)
class NavigationTest {

    @get:Rule val compose = createAndroidComposeRule<MainActivity>()

    @Test
    fun homeToListToDetailAndBack() {
        compose.onNodeWithText("Hello!").assertExists()
        compose.onNodeWithText("See the planets").performClick()

        compose.onNodeWithTag("ListScreen").assertExists()
        compose.onNodeWithText("Planets").assertExists()
        compose.onNodeWithText("Earth").performClick()

        compose.onNodeWithTag("DetailScreen").assertExists()
        compose.onNodeWithText("Home").assertExists()
        compose.onNodeWithContentDescription("Back").performClick()

        compose.onNodeWithTag("ListScreen").assertExists()
        compose.onNodeWithContentDescription("Back").performClick()

        compose.onNodeWithTag("HomeScreen").assertExists()
    }

    /** specs/search.md: List -> type "red" -> only Mars -> clear -> all 5 again -> open Mars. */
    @Test
    fun searchFiltersTheList() {
        compose.onNodeWithText("See the planets").performClick()

        compose.onNodeWithTag("SearchField").performTextInput("red")
        compose.onNodeWithText("Mars").assertExists()
        compose.onNodeWithText("Mercury").assertDoesNotExist()
        compose.onNodeWithText("Jupiter").assertDoesNotExist()

        compose.onNodeWithContentDescription("Clear search", useUnmergedTree = true).performClick()
        // Back to the full list, scrolled to the top (the small test screen only fits the
        // first rows; lazy rows below the fold aren't composed).
        compose.onNodeWithText("Mercury").assertExists()
        compose.onNodeWithText("Venus").assertExists()

        compose.onNodeWithTag("SearchField").performTextInput("pluto")
        compose.onNodeWithText("No planets match \"pluto\"").assertExists()

        compose.onNodeWithContentDescription("Clear search", useUnmergedTree = true).performClick()
        compose.onNodeWithTag("SearchField").performTextInput("mars")
        compose.onNodeWithText("Mars").performClick()
        compose.onNodeWithTag("DetailScreen").assertExists()
        compose.onNodeWithText("The red planet").assertExists()
    }
}
