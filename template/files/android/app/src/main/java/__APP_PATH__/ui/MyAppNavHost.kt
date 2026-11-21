package __APP_ID__.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import __APP_ID__.data.ItemRepository
import __APP_ID__.ui.screens.DetailScreen
import __APP_ID__.ui.screens.HomeScreen
import __APP_ID__.ui.screens.ListScreen

/** Route names match the screen names in specs/starter.md. */
object Routes {
    const val HOME = "HomeScreen"
    const val LIST = "ListScreen"
    const val DETAIL = "DetailScreen/{id}"
    fun detail(id: String) = "DetailScreen/$id"
}

@Composable
fun __APP_NAME__NavHost(repository: ItemRepository = ItemRepository()) {
    val navController = rememberNavController()
    NavHost(navController = navController, startDestination = Routes.HOME) {
        composable(Routes.HOME) {
            HomeScreen(onSeePlanets = { navController.navigate(Routes.LIST) })
        }
        composable(Routes.LIST) {
            // Survives rotation; a fresh visit from Home starts empty (specs/search.md).
            var query by rememberSaveable { mutableStateOf("") }
            ListScreen(
                items = repository.items(),
                query = query,
                onQueryChange = { query = it },
                onBack = { navController.popBackStack() },
                onItemClick = { navController.navigate(Routes.detail(it.id)) },
            )
        }
        composable(
            route = Routes.DETAIL,
            arguments = listOf(navArgument("id") { type = NavType.StringType }),
        ) { entry ->
            val item = entry.arguments?.getString("id")?.let(repository::item)
            if (item == null) {
                LaunchedEffect(Unit) { navController.popBackStack() }
            } else {
                DetailScreen(item = item, onBack = { navController.popBackStack() })
            }
        }
    }
}
