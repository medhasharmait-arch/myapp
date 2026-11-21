package __APP_ID__

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import __APP_ID__.ui.__APP_NAME__NavHost
import __APP_ID__.ui.theme.__APP_NAME__Theme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContent {
            __APP_NAME__Theme {
                __APP_NAME__NavHost()
            }
        }
    }
}
