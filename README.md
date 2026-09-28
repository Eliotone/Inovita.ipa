# Inovita
Get the IPA: push this folder to a GitHub repo -> Actions tab -> "Build IPA" -> download the `Inovita-ipa` artifact.
The IPA is unsigned: sign/install it with Sideloadly or AltStore (free Apple ID), or your Apple Developer certificate.
Or on a Mac: `brew install xcodegen && xcodegen generate && open Inovita.xcodeproj`, then run on your iPhone (Bluetooth doesn't work in Simulator).
