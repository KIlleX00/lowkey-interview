# Pexelator - Lowkey Technical Interview

This repository contains the solution to the job interview task given by Lowkey for the iOS Developer position.

Pexelator is a compact Pexels client application that offers users the ability to browse through curated photos.

## Features

- **Splash screen**: Displays a fancy logo animation while preloading data for the next screen.
- **Photo List screen**: Presents a curated list of photos with support for paging.
- **Photo Details screen**: Displays a full photo to the user with a cool hero transition.
- **CachedAsyncImage view**: A view that fetches photos and has caching implemented.

## Requirements

- iOS 16.0+
- Xcode 15.4

## How to Build

Swift Package Manager was used to manage dependencies. The code is buildable within Xcode without any additional interaction.

## Dependencies

The project uses the following dependency:
- **Lottie**: Used to show the custom logo animation on the Splash screen.
