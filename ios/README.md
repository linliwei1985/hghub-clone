# HGhub iOS server client

Native WKWebView wrapper for a user-managed HGhub web deployment. Supports inline/native HLS playback, refresh, back navigation, and changing the server URL.

Build on macOS with full Xcode installed:

```sh
APP_URL="http://YOUR_SERVER_IP:8081/" bash ios/build.sh
```

The default URL is empty so public source builds do not disclose a deployment address. It can be supplied at build time, changed in the unsigned app's `HGServerURL` Info.plist key before signing, or entered at first launch.

Output: `ios/build/HGhub-iOS-unsigned.ipa`. This package has only an ad hoc local build signature, no Apple provisioning profile. It is intended for signing and sideloading with AltStore/SideStore or an appropriate Apple certificate. Downloading it alone does not install it on iOS. The build checks archive integrity, arm64 architecture, Info.plist and local code-signature structure; real-device installation and playback must be tested separately.
