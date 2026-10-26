package io.github.willie6666.balnana

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        intent = withWholeLink(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(withWholeLink(intent))
    }

    /**
     * Flutter hands the app only a link's path. A web link (an App Link to
     * this build's server) becomes balnana://app/link?url=<the link>, so the
     * app sees which server it is for before it uses the secret in it.
     */
    private fun withWholeLink(intent: Intent): Intent {
        val data = intent.data ?: return intent
        if (intent.action != Intent.ACTION_VIEW || (data.scheme != "https" && data.scheme != "http")) return intent
        val route = Uri.Builder()
            .scheme("balnana")
            .authority("app")
            .path("/link")
            .appendQueryParameter("url", data.toString())
            .build()
        return Intent(intent).setData(route)
    }
}
