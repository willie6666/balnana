# PayPal API 核對紀錄

核對日期：2026-11-05（Asia/Taipei）。基準 commit：`81c2218`，加上本次修正。

已核對專案使用的 **11 個 endpoint：10 個付款 REST operation 與 OAuth token endpoint**。
10 個付款 operation 的 22 組測試 HTTP 請求／回應，通過官方 OpenAPI schema 的路徑、method、參數、header、JSON body、HTTP status 與 JSON response 驗證。OAuth 的 Basic Auth、form grant、Bearer token 與 token 重用另以 HTTP 測試驗證。

這是文件與格式相容性檢查。HTTP 回應來自本地模擬服務，未使用 PayPal Sandbox／Live 帳號實際付款，也未取得真實簽章的 webhook。不能據此宣稱真實金流已完成驗收。

## Endpoint 清單

| Method / endpoint | 核對內容 | 官方來源 |
| --- | --- | --- |
| `POST /v1/oauth2/token` | HTTP Basic、`application/x-www-form-urlencoded`、`grant_type=client_credentials`；後續使用 Bearer token | [Authentication](https://developer.paypal.com/api/rest/authentication/) |
| `POST /v2/checkout/orders` | CAPTURE intent、purchase units、PayPal experience context、金額、回傳／取消 URL、request ID、回應 links | [Create order](https://developer.paypal.com/api/orders/v2/orders-create) |
| `GET /v2/checkout/orders/{id}` | 訂單狀態、custom ID、captures | [Show order details](https://developer.paypal.com/api/orders/v2/orders-get) |
| `POST /v2/checkout/orders/{id}/capture` | 空 JSON body、request ID、`Prefer: return=representation`、精簡回應的補查 | [Capture order](https://developer.paypal.com/api/orders/v2/orders-capture) |
| `GET /v2/payments/captures/{capture_id}` | related order ID；capture／refund webhook 的關聯查詢 | [Payments v2](https://developer.paypal.com/api/payments/v2/) |
| `POST /v1/billing/subscriptions` | 26 字元 plan ID、custom ID、application context、request ID、approve link | [Create subscription](https://developer.paypal.com/api/subscriptions/v1/subscriptions-create/) |
| `GET /v1/billing/subscriptions/{id}` | `fields=last_failed_payment`、billing info、狀態、custom ID | [Show subscription](https://developer.paypal.com/api/subscriptions/v1/subscriptions-get/) |
| `GET /v1/billing/subscriptions/{id}/transactions` | start/end time、transaction ID、time、status、gross amount | [List subscription transactions](https://developer.paypal.com/api/subscriptions/v1/subscriptions-transactions) |
| `POST /v1/notifications/verify-webhook-signature` | 五個 transmission header 值、webhook ID、完整 event object、SUCCESS／FAILURE | [Verify signature](https://developer.paypal.com/api/webhooks/v1/verify-webhook-signature-post) |
| `GET /v1/payments/refund/{refund_id}` | 原生 sale refund 的 state 與 sale ID；**deprecated** | [Show refund](https://developer.paypal.com/api/deprecated/payments/v1/refund-get/) |
| `GET /v1/payments/sale/{sale_id}` | 原生 sale 的 state、billing agreement ID、金額與建立時間；**deprecated** | [Show sale](https://developer.paypal.com/api/deprecated/payments/v1/sale-get/) |

OAuth 在本地 token server 測試。其餘清單由 `TestPayPalContractFixtures` 匯出實際送出的請求與模擬服務回應，再交給獨立的 Python JSON Schema validator；不以測試內重寫的一份 schema 代替官方來源。

## 本次發現並修正的差異

- Order capture 預設是 minimal response。現在會要求 `return=representation`；若收到舊 request ID 快取的 minimal response，會補查訂單資料。[官方 header 定義](https://developer.paypal.com/api/orders/v2/orders-capture)
- 訂單與訂閱建立請求加入各自的 `PayPal-Request-Id`。不同 checkout 使用不同 ID；同一 order 的 capture 使用固定 ID。[官方 idempotency 說明](https://developer.paypal.com/api/rest/reference/idempotency/)
- Subscription GET 的官方 schema 也要求 `Content-Type`，現在 REST 請求統一帶 JSON Content-Type 與 Accept；OAuth token 請求維持表單格式。
- Subscription plan ID 依 create schema 限制為 `P-` 加 24 個大寫英數字元。假資料也改成有效格式。
- 單次付款價格須為正值，幣別限於官方表列範圍。HUF、JPY、TWD 不送小數；不接受會被截掉的非零小數。[Currency codes](https://developer.paypal.com/api/codes/currency)
- HTTP 400 代表 bad request，現在只有 404 被判定為資源不存在，避免查詢格式錯誤被當成已處理。
- Native refund 的 pending 狀態要求重試；failed／cancelled 不移除權限。Sale schema 沒有 `reversed` enum，但實際回應可能出現，因此 `reversed` 一律視為負向；撤銷仍由已驗證的 SALE.REVERSED 事件與 REST 的負向狀態（`refunded`、`reversed`，或 REVERSED 事件下的 `denied`）共同判斷。V2 capture 的 `REVERSED` 狀態也比照 `REFUNDED` 收回時間。
- 免費試用：訂閱 ACTIVE、`cycle_executions` 有 `TRIAL` 且 `REGULAR` 的 `cycles_completed` 為 0、`next_billing_time` 在未來、沒有失敗扣款或欠款時，視為試用中，權限給到 `next_billing_time` 加寬限期。每個帳號只給一次（`paypal_subscriptions.trial_until`），試用中取消仍保留到試用結束。官方 schema 沒有說試用期間 `last_payment` 與 `next_billing_time` 的實際值，上線前要用 sandbox 的試用方案確認。
- Capture 被拒（`INSTRUMENT_DECLINED`、`PAYER_ACTION_REQUIRED`、`REDIRECT_PAYER_FOR_ALTERNATE_FUNDING`）時把付款人導回訂單的 payer-action 頁；`TRANSACTION_REFUSED` 直接回報 failed。每次被拒都遞增 `capture_attempts`，下一次 capture 改用新的 `PayPal-Request-Id`，避免 6 小時內重播先前的拒絕。
- V2 capture 失敗事件名稱改用官方 `PAYMENT.CAPTURE.DECLINED`。訂閱保留官方的 `PAYMENT.SALE.COMPLETED`、`REFUNDED`、`REVERSED` 與 billing subscription 事件。[Webhook events](https://developer.paypal.com/api/rest/webhooks/event-names/)
- 模擬回應補齊官方必填欄位、移除不應出現的 null 欄位，避免測試依賴不合法的 PayPal 回應。

## 相容性界線

兩個 native sale/refund GET endpoint 雖仍在官方文件中，已標示 deprecated。本專案目前以它們對帳訂閱 SALE 事件；沒有證據可以把 sale ID 一律當成 v2 capture ID，因此沒有直接替換 URL。此部分仍需用目標 Sandbox REST app 確認實際讀取權限與退款回應。

Subscriptions create 的 `application_context` 也在目前 schema 標示 deprecated，但仍列出其欄位；本次保留現有、可依 checkout 設定回傳 URL 的流程，未宣稱它是不含 deprecated 欄位的全新整合。

JSON schema 不保證帳號或地區的收款資格，也沒有驗證 PayPal 網頁完成付款後實際附加的 redirect query、真實 webhook 簽章／投遞次序、付款與退款的最終一致性延遲。這些需要 Sandbox 的買方／商家帳號與公開 HTTPS webhook 驗收。管理員設定的 fallback days 與兩日寬限期是本專案的方案政策，不是 PayPal 的付款證明。

部分退款目前保留方案時間；只有確認全額退款或撤銷才撤回。這是應用程式政策，不是 PayPal 的要求。

## 驗證結果

- 官方 schema 驗證：**22 組 HTTP exchanges、10 個 REST operation 通過**。
- `TestPayPalOAuthContract` 通過：token grant、Bearer token、token 快取、Sandbox／Live base URL。
- `go vet ./...`、`REQUIRE_DB=1 go test -race ./...` 通過，包含真實 PostgreSQL 測試。
- `flutter analyze` 通過；admin 與 plan 相關 38 個測試通過，另有 1 個依 build define 略過的外部付款案例。

## 重跑方式

從專案根目錄執行；需要專案開發用 PostgreSQL，Go 測試會建立並清除自己的資料庫。

```bash
nix-shell --run 'cd server && REQUIRE_DB=1 PAYPAL_CONTRACT_OUTPUT=/tmp/paypal-exchanges.json go test ./internal/api -run TestPayPalContractFixtures -count=1'
nix-shell -p python3Packages.jsonschema --run 'python server/internal/api/testdata/paypal/check_contract.py /tmp/paypal-exchanges.json --schema-dir /tmp/paypal-official-schemas'
```

Validator 預設下載官方 schema；`--schema-dir` 可重用已下載的 `<name>.json`。本次使用先前從下列官方 URL 下載的 schema 快取；文件站對另一個 Python 執行環境的重新下載回傳 403，因此沒有改用非官方 schema。

| 快取名稱 | 官方 schema / version | 正規化 JSON SHA-256 |
| --- | --- | --- |
| `orders.json` | [Orders 2.36](https://developer.paypal.com/api/orders/v2/schema.json) | `86a3b1456027de8160c7b0fe73994a80396dd5d6ed54b912f6bcb36bb961278e` |
| `payments.json` | [Payments 2.12](https://developer.paypal.com/api/payments/v2/schema.json) | `e5a51ed587b0344d07aeceded1e5b9d0e225c3b01f977c6686d649749bef2f86` |
| `subscriptions.json` | [Subscriptions 1.11](https://developer.paypal.com/api/subscriptions/v1/schema.json) | `d907392a85d858de781ac2197b7fe16d323ab3dce1095111feb0fdb36d2ff91a` |
| `webhooks.json` | [Webhooks 1.11](https://developer.paypal.com/api/webhooks/v1/schema.json) | `4d00cd409e045dbf4d0586cc64c380f792b7b6ef168a0bb33a2874eb16a07223` |
| `legacy.json` | [Payments v1 1.12](https://developer.paypal.com/api/deprecated/payments/v1/schema.json) | `52779f475b6b3cb94ea1cd43e1ea432c547adb51a9a9b181b9e023761a2fefbc` |
