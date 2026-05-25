# Pluffy - Premium Dessert Café Ordering Application

Welcome to Pluffy, a premium dessert café ordering application designed for an exceptional user experience. This application focuses on providing a seamless ordering process for our customers, showcasing a variety of delicious dessert offerings.

## Features

- **User Authentication**: Secure login and registration for users.
- **Menu Display**: A beautifully designed menu showcasing all available desserts.
- **Product Details**: Detailed views for each product, including customization options.
- **Shopping Cart**: Users can add, remove, and modify items in their cart.
- **Checkout Process**: A streamlined checkout process with voucher input and payment options.
- **Localization Support**: The application supports multiple languages for a wider audience reach.

## Project Structure

```
Pluffy
├── android
├── ios
├── lib
│   ├── main.dart
│   ├── src
│   │   ├── app.dart
│   │   ├── core
│   │   │   ├── constants.dart
│   │   │   └── utils.dart
│   │   ├── config
│   │   │   └── flavor.dart
│   │   ├── models
│   │   │   └── index.dart
│   │   ├── services
│   │   │   ├── api_service.dart
│   │   │   └── payment_service.dart
│   │   ├── repositories
│   │   │   └── order_repository.dart
│   │   ├── state
│   │   │   └── order_cubit.dart
│   │   ├── features
│   │   │   ├── auth
│   │   │   │   └── login_screen.dart
│   │   │   ├── menu
│   │   │   │   └── menu_screen.dart
│   │   │   ├── product
│   │   │   │   └── product_detail_screen.dart
│   │   │   ├── cart
│   │   │   │   └── cart_screen.dart
│   │   │   └── checkout
│   │   │       └── checkout_screen.dart
│   │   ├── widgets
│   │   │   └── common
│   │   │       └── product_card.dart
│   │   ├── themes
│   │   │   └── app_theme.dart
│   │   └── l10n
├── assets
│   ├── fonts
│   └── localization
├── test
│   └── widget_test.dart
├── .github
│   └── workflows
│       └── ci.yml
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── .gitignore
```

## Getting Started

To get started with the Pluffy application, clone the repository and run the following commands:

```bash
flutter pub get
flutter run
```

## Contributing

We welcome contributions to enhance the Pluffy application. Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

Enjoy your experience with Pluffy!