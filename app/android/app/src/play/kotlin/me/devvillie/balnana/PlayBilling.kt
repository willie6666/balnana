package me.devvillie.balnana

import android.app.Activity
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Google Play's side of paying: what is on sale, the purchase itself, and
 * what this Play account already holds. The server decides what any of it is
 * worth, so purchases go no further than their tokens.
 */
class PlayBilling(private val activity: Activity, messenger: BinaryMessenger) : PurchasesUpdatedListener {
    private val channel = MethodChannel(messenger, "balnana/play_billing")
    private val client = BillingClient.newBuilder(activity)
        .setListener(this)
        .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
        .enableAutoServiceReconnection()
        .build()
    // Who is waiting for the connection being made.
    private val connecting = mutableListOf<(BillingResult) -> Unit>()
    // Who is waiting for the purchase under way: Play opens one at a time.
    private var buying: MethodChannel.Result? = null

    init {
        channel.setMethodCallHandler { call, result ->
            connected(result) {
                when (call.method) {
                    "products" -> products(call.argument<List<String>>("products").orEmpty(), result)
                    "buy" -> buy(call.argument("product")!!, call.argument("offer")!!, call.argument("account")!!, result)
                    "purchases" -> purchases(result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun close() {
        channel.setMethodCallHandler(null)
        client.endConnection()
    }

    private fun connected(result: MethodChannel.Result, then: () -> Unit) {
        if (client.isReady) return then()
        connecting.add { setup -> if (setup.responseCode == BillingClient.BillingResponseCode.OK) then() else fail(result, setup) }
        // Asked again while connecting: the answer goes to both.
        if (connecting.size > 1) return
        client.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(setup: BillingResult) {
                activity.runOnUiThread {
                    val waiting = connecting.toList()
                    connecting.clear()
                    waiting.forEach { it(setup) }
                }
            }

            override fun onBillingServiceDisconnected() {}
        })
    }

    // Some of the library's answers come on its own threads; Flutter's replies
    // and the purchase screen need the main one.
    private fun fail(result: MethodChannel.Result, billing: BillingResult) = activity.runOnUiThread {
        val owned = billing.responseCode == BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED
        result.error(if (owned) "owned" else "billing", billing.debugMessage, billing.responseCode)
    }

    private fun details(ids: List<String>, result: MethodChannel.Result, then: (List<ProductDetails>) -> Unit) {
        val products = ids.map {
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(it)
                .setProductType(BillingClient.ProductType.SUBS)
                .build()
        }
        val params = QueryProductDetailsParams.newBuilder().setProductList(products).build()
        client.queryProductDetailsAsync(params) { billing, found ->
            if (billing.responseCode != BillingClient.BillingResponseCode.OK) return@queryProductDetailsAsync fail(result, billing)
            activity.runOnUiThread { then(found.productDetailsList) }
        }
    }

    // Base plans only: an offer on top of one comes with rules about who may
    // have it, and the app doesn't sell any.
    private fun products(ids: List<String>, result: MethodChannel.Result) = details(ids, result) { found ->
        result.success(
            found.flatMap { product ->
                product.subscriptionOfferDetails.orEmpty().filter { it.offerId == null }.map { offer ->
                    val phase = offer.pricingPhases.pricingPhaseList.last()
                    mapOf(
                        "productId" to product.productId,
                        "offerToken" to offer.offerToken,
                        "name" to product.name,
                        "price" to phase.formattedPrice,
                        "period" to phase.billingPeriod,
                    )
                }
            },
        )
    }

    private fun buy(productId: String, offerToken: String, account: String, result: MethodChannel.Result) {
        if (buying != null) return result.error("busy", null, null)
        details(listOf(productId), result) { found ->
            val product = found.firstOrNull { it.productId == productId }
                ?: return@details result.error("billing", "no such product", null)
            if (buying != null) return@details result.error("busy", null, null)
            val offer = BillingFlowParams.ProductDetailsParams.newBuilder()
                .setProductDetails(product)
                .setOfferToken(offerToken)
                .build()
            val params = BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(listOf(offer))
                .setObfuscatedAccountId(account)
                .build()
            buying = result
            val launched = client.launchBillingFlow(activity, params)
            if (launched.responseCode != BillingClient.BillingResponseCode.OK) {
                buying = null
                fail(result, launched)
            }
        }
    }

    // A purchase that didn't come from this screen has nobody waiting. The
    // server hears of it from Google, or from the app on the plan page.
    override fun onPurchasesUpdated(billing: BillingResult, purchases: MutableList<Purchase>?) {
        activity.runOnUiThread {
            val result = buying ?: return@runOnUiThread
            buying = null
            when (billing.responseCode) {
                BillingClient.BillingResponseCode.OK -> result.success(purchases.orEmpty().map { it.purchaseToken })
                BillingClient.BillingResponseCode.USER_CANCELED -> result.success(emptyList<String>())
                else -> fail(result, billing)
            }
        }
    }

    private fun purchases(result: MethodChannel.Result) {
        val params = QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.SUBS).build()
        client.queryPurchasesAsync(params) { billing, purchases ->
            if (billing.responseCode != BillingClient.BillingResponseCode.OK) return@queryPurchasesAsync fail(result, billing)
            activity.runOnUiThread { result.success(purchases.map { it.purchaseToken }) }
        }
    }
}
