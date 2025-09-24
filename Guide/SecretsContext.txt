| **Secret Name**                  | **Purpose / Explanation**                                                                                                          |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `APP_STORE_CONNECT_API_KEY`      | Base64-encoded contents of your App Store Connect API key `.p8` file. Used for authentication with fastlane to upload builds.      |
| `APP_STORE_CONNECT_KEY_ID`       | The Key ID of your App Store Connect API key (visible when you create the API key in App Store Connect).                           |
| `APP_STORE_CONNECT_ISSUER_ID`    | The Issuer ID associated with your App Store Connect API key (from App Store Connect).                                             |
| `APP_IDENTIFIER`                 | The bundle identifier of your iOS app (e.g., `com.example.MyApp`). Required for fastlane to identify the app in App Store Connect. |
| `TEAM_ID`                        | Your Apple Developer Team ID (used for signing the app and interacting with App Store Connect).                                    |
| `GITHUB_TOKEN`                   | Automatically provided by GitHub Actions; used for committing the updated build number back to the repository.                     |
| `FASTLANE_PASSWORD` *(optional)* | Only needed if you use Apple ID login instead of an API key; your Apple ID password (not recommended if using API key).            |
