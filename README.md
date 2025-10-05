# pokedex

My app simulates a Pokedex from the Pokemon games/show. It allows users to select the Pokemon they are interested in the learn more about it. For this app, I used the PokeAPI with the endpoint “https://pokeapi.co/api/v2/pokemon/${id}”. This app can be run in both the Android Emulator and the Web. The app will try to initially load all the first generation Pokemon (151 total) ids and sprites. If the uri cannot be reached, an error will appear with a button to retry to connect. If the app can connect but there is no data, a message will appear to display there is no data. If the app can connect, and there is data, the ids and sprites will load under in a 5-column grid view. If the sprite cannot load, a placeholder image will be shown. If the user wants to learn more about the Pokemon, they can press on the card of the desired Pokemon. This will bring up a pop-up screen that will display the name, ID, sprite, types, height, and weight. The user can go back to the main page by pressing the close button. If the user needs to refresh the main page, the user can press the reload button on the top right (under the AppBar) or on mobile they can all the way up. 

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
