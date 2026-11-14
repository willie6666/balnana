import '../../core/l10n.dart';

String settingLabel(AppLocalizations l10n, String key) => switch (key) {
  'BALNANA_PUBLIC_URL' => l10n.adminPublicUrl,
  'BALNANA_SOURCE_URL' => l10n.adminSourceUrl,
  'BALNANA_PRIVACY_URL' => l10n.adminPrivacyUrl,
  'BALNANA_MAP_SOURCE' => l10n.adminMapSource,
  'BALNANA_MAP_STYLE' => l10n.adminMapStyle,
  'BALNANA_MAP_TILES' => l10n.adminMapTiles,
  'BALNANA_MAP_ATTRIBUTION' => l10n.adminMapAttribution,
  'BALNANA_EXCHANGE_RATES' => l10n.adminExchangeRates,
  'BALNANA_OXR_APP_ID' => l10n.adminOxrAppId,
  'BALNANA_AUTH_MODE' => l10n.adminAuthMode,
  'BALNANA_AUTH_PASSWORD' => l10n.adminPasswordLogin,
  'BALNANA_AUTH_REQUIRE_EMAIL' => l10n.adminRequireEmail,
  'BALNANA_AUTH_REQUIRE_VERIFIED' => l10n.adminRequireVerified,
  'BALNANA_OAUTH_GOOGLE_TRUST_EMAIL' => l10n.adminTrustEmail,
  'BALNANA_AUTH_SIGNUP' => l10n.adminSignup,
  'BALNANA_LINK_GROUPS' => l10n.adminLinkGroups,
  'BALNANA_SMTP_HOST' => l10n.adminSmtpHost,
  'BALNANA_SMTP_PORT' => l10n.adminSmtpPort,
  'BALNANA_SMTP_USER' => l10n.adminSmtpUser,
  'BALNANA_SMTP_PASSWORD' => l10n.adminSmtpPassword,
  'BALNANA_SMTP_FROM' => l10n.adminSmtpFrom,
  'BALNANA_OAUTH_GOOGLE_CLIENT_ID' || 'BALNANA_OAUTH_OIDC_CLIENT_ID' => l10n.adminClientId,
  'BALNANA_OAUTH_GOOGLE_SECRET' || 'BALNANA_OAUTH_OIDC_SECRET' => l10n.adminClientSecret,
  'BALNANA_OAUTH_OIDC_ISSUER' => l10n.adminOidcIssuer,
  'BALNANA_OAUTH_OIDC_NAME' => l10n.adminOidcName,
  'BALNANA_ANDROID_CERT_SHA256' => l10n.adminFingerprints,
  'BALNANA_BILLING_ENABLED' => l10n.adminBillingOn,
  'BALNANA_KOFI_URL' => l10n.adminKofiUrl,
  'BALNANA_KOFI_TOKEN' => l10n.adminKofiToken,
  'BALNANA_PLAY_PACKAGE' => l10n.adminPlayPackage,
  'BALNANA_PLAY_SERVICE_ACCOUNT' => l10n.adminPlayServiceAccount,
  'BALNANA_PLAY_PUSH_ACCOUNT' => l10n.adminPlayPushAccount,
  'BALNANA_PAYPAL_CLIENT_ID' => l10n.adminPayPalClientId,
  'BALNANA_PAYPAL_SECRET' => l10n.adminPayPalSecret,
  'BALNANA_PAYPAL_WEBHOOK_ID' => l10n.adminPayPalWebhookId,
  'BALNANA_PAYPAL_SANDBOX' => l10n.adminPayPalSandbox,
  _ => key,
};

String? settingHelp(AppLocalizations l10n, String key) => switch (key) {
  'BALNANA_PUBLIC_URL' => l10n.adminPublicUrlHelp,
  'BALNANA_SOURCE_URL' => l10n.adminSourceUrlHelp,
  'BALNANA_PRIVACY_URL' => l10n.adminPrivacyUrlHelp,
  'BALNANA_MAP_STYLE' => l10n.adminMapStyleHelp,
  'BALNANA_MAP_TILES' => l10n.adminMapTilesHelp,
  'BALNANA_MAP_ATTRIBUTION' => l10n.adminMapAttributionHelp,
  'BALNANA_EXCHANGE_RATES' => l10n.adminExchangeRatesHelp,
  'BALNANA_OXR_APP_ID' => l10n.adminOxrAppIdHelp,
  'BALNANA_AUTH_SIGNUP' => l10n.adminSignupHelp,
  'BALNANA_AUTH_REQUIRE_EMAIL' => l10n.adminRequireEmailHelp,
  'BALNANA_AUTH_REQUIRE_VERIFIED' => l10n.adminRequireVerifiedHelp,
  'BALNANA_OAUTH_GOOGLE_TRUST_EMAIL' => l10n.adminGoogleTrustEmailHelp,
  'BALNANA_LINK_GROUPS' => l10n.adminLinkGroupsHelp,
  'BALNANA_OAUTH_OIDC_NAME' => l10n.adminOidcNameHelp,
  'BALNANA_ANDROID_CERT_SHA256' => l10n.adminFingerprintsHelp,
  'BALNANA_BILLING_ENABLED' => l10n.adminBillingOnHelp,
  'BALNANA_KOFI_URL' => l10n.adminKofiUrlHelp,
  'BALNANA_KOFI_TOKEN' => l10n.adminKofiTokenHelp,
  'BALNANA_PLAY_PACKAGE' => l10n.adminPlayPackageHelp,
  'BALNANA_PLAY_SERVICE_ACCOUNT' => l10n.adminPlayServiceAccountHelp,
  'BALNANA_PLAY_PUSH_ACCOUNT' => l10n.adminPlayPushAccountHelp,
  'BALNANA_PAYPAL_CLIENT_ID' => l10n.adminPayPalClientIdHelp,
  'BALNANA_PAYPAL_SANDBOX' => l10n.adminPayPalSandboxHelp,
  _ => null,
};

/// Why the server refused a setting.
String settingProblem(AppLocalizations l10n, String key) => switch (key) {
  'BALNANA_PUBLIC_URL' ||
  'BALNANA_SOURCE_URL' ||
  'BALNANA_PRIVACY_URL' ||
  'BALNANA_KOFI_URL' ||
  'BALNANA_MAP_STYLE' ||
  'BALNANA_OAUTH_OIDC_ISSUER' => l10n.adminInvalidUrl,
  'BALNANA_SMTP_FROM' => l10n.adminInvalidFrom,
  'BALNANA_SMTP_PORT' => l10n.adminInvalidPort,
  'BALNANA_OAUTH_GOOGLE_SECRET' ||
  'BALNANA_OAUTH_OIDC_CLIENT_ID' ||
  'BALNANA_OAUTH_OIDC_SECRET' => l10n.adminInvalidRequired,
  'BALNANA_PAYPAL_CLIENT_ID' ||
  'BALNANA_PAYPAL_SECRET' ||
  'BALNANA_PAYPAL_WEBHOOK_ID' => l10n.adminPayPalRequired,
  'BALNANA_AUTH_MODE' => l10n.adminNeedsSignIn,
  'BALNANA_BILLING_ENABLED' => l10n.adminBillingNeedsAccounts,
  'BALNANA_ANDROID_CERT_SHA256' => l10n.adminInvalidFingerprint,
  'BALNANA_MAP_TILES' => l10n.adminInvalidMapTiles,
  _ => l10n.adminInvalidValue,
};
