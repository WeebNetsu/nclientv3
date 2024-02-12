# NClientV3

nHentai browser and reader inspired by [NClientV2](https://github.com/Dar9586/NClientV2).

You can find the releases here: https://github.com/WeebNetsu/nclientv3/releases

## Notes

- This app only works on **Android 10 and up**.
- This app is intended for users 21 years and older.
- If nHentai is blocked in your country, then this app may behave strangely or not work.

### FAQs

- Does this work on iOS? - I don't own any Apple products, so not sure 🤷
- I am just getting a blank screen? - nHentai might be blocked in your country, try using a VPN or Proxy

## Contributing

### Issues

Please be descriptive of your issues, if you create an issue and all it says is "app bug" or similar, I will close it immediately as it only wastes my time. Please follow the provided template.

### Project Structure

- `assets/` - All images, music, sfx etc.
- `lib/` - All source code
  - `constants/` - Constants such as path to assets and links
  - `models/` - Classes/Objects to structure data
  - `theme/` - App theme setup
  - `utils/` - Global scope functions
  - `views/` - All pages on the app
    - `widgets/` - Widgets that were designed to only work with this view
  - `widgets/` - Global scope widgets

### Building from Source

`flutter clean && flutter pub get && flutter build apk --release`

### Resources

- [Flutter](https://flutter.dev)
- [nHentai Dart API](https://github.com/Zekfad/nhentai_dart)

## Support

If you want to support the work I do, please consider subscribing to [Steve's teacher](https://www.youtube.com/@Stevesteacher) if you enjoy learning about programming, or send a donation my way, every little bit helps!

[<img alt="liberapay" src="https://img.shields.io/badge/-LiberaPay-EBC018?style=flat-square&logo=liberapay&logoColor=white" />](https://liberapay.com/stevesteacher/)
[<img alt="kofi" src="https://img.shields.io/badge/-Kofi-7648BB?style=flat-square&logo=ko-fi&logoColor=white" />](https://ko-fi.com/stevesteacher)
[<img alt="patreon" src="https://img.shields.io/badge/-Patreon-F43F4B?style=flat-square&logo=patreon&logoColor=white" />](https://www.patreon.com/Stevesteacher)
[<img alt="paypal" src="https://img.shields.io/badge/-PayPal-0c1a55?style=flat-square&logo=paypal&logoColor=white" />](https://www.paypal.com/donate/?hosted_button_id=P9V2M4Q6WYHR8)
