# Social Login Setup (Google, Apple, Facebook, Twitter)

This guide shows how to enable and configure every social login provider supported by the MartFury mobile app. Follow the steps to collect credentials, wire them into the project, and test the full authentication flow without touching any code.

## Prerequisites

- A working MartFury Flutter project connected to your Botble backend
- Access to the relevant developer portals:
  - [Google Cloud Console](https://console.cloud.google.com)
  - [Apple Developer](https://developer.apple.com/)
  - [Meta for Developers](https://developers.facebook.com/)
  - [Twitter Developer Portal](https://developer.twitter.com/)

## Step 1: Collect Provider Credentials

### Google

1. Open the Google Cloud Console and select your project.
2. Enable **Google Identity Services / Google Sign-In**.
3. Navigate to **APIs & Services → Credentials**.
4. Create OAuth 2.0 Client IDs for your platforms (Android, iOS, Web as required).
5. Copy the **Web Client ID** (used as `clientId`) and the **Server Client ID**.

### Apple

1. Sign in to the Apple Developer portal.
2. Under **Certificates, Identifiers & Profiles**, enable **Sign in with Apple** for your app ID.
3. Create a **Services ID** and add the return URLs.
4. Note the **Services ID** and your **Team ID** (and private key if needed by your backend).

### Facebook

1. Log into [developers.facebook.com](https://developers.facebook.com).
2. Create or select an app, then add the **Facebook Login** product.
3. Configure the **Valid OAuth redirect URIs** for your bundle/package.
4. Copy the **App ID** and **Client Token**.

### Twitter (X)

1. In the Twitter Developer Portal, create a project/app.
2. Enable 3-legged OAuth and set callback URLs (e.g., `martfury://twitter-auth`).
3. Copy the **API Key** (consumer key) and **API Secret Key** (consumer secret).

## Step 2: Configure the App

### 1. Run the social sign-in wizard

Use the interactive script to toggle providers and paste credentials:

```bash
dart run scripts/setup_social_signin.dart
```

The wizard creates or updates `assets/config/social_sign_in.json`. A typical result looks like:

```json
{
  "google": {
    "enabled": true,
    "clientId": "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com",
    "serverClientId": "YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com"
  },
  "apple": {
    "enabled": true,
    "serviceId": "com.yourcompany.services.id",
    "teamId": "YOUR_TEAM_ID"
  },
  "facebook": {
    "enabled": false,
    "appId": "",
    "clientToken": ""
  },
  "twitter": {
    "enabled": false,
    "consumerKey": "",
    "consumerSecret": ""
  }
}
```

> ⚠️ Treat `assets/config/social_sign_in.json` as sensitive. Do not commit filled-in credentials to public repositories.

### 2. Optional: .env overrides

Environment variables override JSON values at runtime. Useful for CI/CD or per-machine configuration:

```bash
ENABLE_GOOGLE_SIGN_IN=true
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_SERVER_CLIENT_ID=your_google_server_client_id

ENABLE_APPLE_SIGN_IN=true
APPLE_SERVICE_ID=your_apple_service_id
APPLE_TEAM_ID=your_apple_team_id

ENABLE_FACEBOOK_SIGN_IN=true
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_CLIENT_TOKEN=your_facebook_client_token

ENABLE_TWITTER_SIGN_IN=true
TWITTER_CONSUMER_KEY=your_twitter_consumer_key
TWITTER_CONSUMER_SECRET=your_twitter_consumer_secret
TWITTER_REDIRECT_URI=martfury://twitter-auth
```

By default, Google Sign-In is enabled if credentials exist, while Apple, Facebook, and Twitter remain disabled until explicitly toggled on.

### 3. Platform configuration checklist

Ensure native projects include the required entries:

| Provider | iOS | Android |
|----------|-----|---------|
| Google | `Info.plist` contains the Web Client ID scheme | `AndroidManifest.xml` includes `SignInHubActivity` and manifest placeholders |
| Apple | Add Sign in with Apple capability | Callback activity (`SignInWithAppleCallback`) with scheme `signinwithapple` |
| Facebook | URL scheme `fbYOUR_APP_ID`, `FacebookAppID`, `FacebookClientToken`, queries schemes | `FacebookActivity` + `ApplicationId`/`ClientToken` meta-data, manifest placeholders |
| Twitter | URL schemes (`twitterkit-...`, `martfury`) | `OAuthActivity`, consumer key/secret meta-data, intent-filter with scheme `martfury` |

Refer to the native platform docs for any additional steps (entitlements, string resources, SHA hashes, etc.).

## Step 3: Testing

1. Restart the Flutter app so it reloads the JSON/`.env`.
2. Visit the sign-in screen and confirm that only the enabled providers are visible.
3. Tap each button and complete the external consent flow.
4. Verify redirection back to the app and ensure analytics events (e.g., `login (method=google)`) appear in your monitoring tool.

## Troubleshooting

- **Provider button missing**: Ensure the provider is enabled in the JSON or `.env`, credentials are present, and the app was restarted.
- **Invalid configuration / redirect errors**: Confirm bundle IDs, package names, and redirect URIs match what you configured in the provider console.
- **Runtime crashes or unknown errors**: Double-check keys for typos, confirm device connectivity, and inspect native logs for provider-specific messages.

## Security Considerations

- Keep filled configuration files and `.env` out of public version control.
- Restrict access to developer portal credentials and rotate secrets periodically.
- Provide clear user-facing error messages for failed social logins.

## Reference Material

- Google: [Cloud Console](https://console.cloud.google.com) · [Google Sign-In Docs](https://developers.google.com/identity/sign-in/android/start-integrating)
- Apple: [Apple Developer](https://developer.apple.com/) · [Sign in with Apple Docs](https://developer.apple.com/sign-in-with-apple/)
- Facebook: [Meta for Developers](https://developers.facebook.com/) · [Facebook Login Docs](https://developers.facebook.com/docs/facebook-login)
- Twitter/X: [Twitter Developer Portal](https://developer.twitter.com/) · [Twitter OAuth Docs](https://developer.twitter.com/en/docs/authentication/oauth-1-0a)
