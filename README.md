# LTImagePicker

<p align="left">
    <img src="https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat" />
    <img src="https://img.shields.io/badge/Platforms-iOS-blue.svg?style=flat" />
    <a href="https://travis-ci.org/LorTos/LTImagePicker">
        <img src="https://img.shields.io/travis/LorTos/LTImagePicker.svg?style=flat" />
    </a>
    <a href="https://cocoapods.org/pods/LTImagePicker">
        <img src="https://img.shields.io/cocoapods/v/LTImagePicker.svg?style=flat" />
    </a>
    <img src="https://img.shields.io/github/license/mashape/apistatus.svg" />
</p>

## Example

The example project contains a sample usage of this pod. Feel free to play around with it. To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

- ### Creating coordinator

Create a `LTImagePickerCoordinator` in the ViewController where you want the flow to start, passing a `LTPickerConfig` to customise appearance.
Add a `Notification` to receive the image when you made the final choice.
```swift
var coordinator: LTImagePickerCoordinator?

override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(selectedImage(_:)), name: .didFinishPickingImage, object: nil)

    let config = LTPickerConfig(navBackgroundColor: UIColor.black,
                                navTintColor: UIColor.white,
                                accentColor: UIColor(red: 249/255, green: 215/255, blue: 68/255, alpha: 1),
                                shouldShowTextInput: false)
    coordinator = LTImagePickerCoordinator(configuration: config)
}
```

- ### Start flow

Then simply call:
```swift
coordinator?.startCameraFlow(from: self)
```
to start the flow with the Camera. Otherwise call:

```swift
coordinator?.startLibraryPickerFlow(from: self)
```
to start the flow with the photo library.

- ### Get image and message

Call the function that you passed as the selector in the `Notification` to receive the available data.

```swift
@objc private func selectedImage(_ sender: Notification) {
    // Image always exists
    if let image = sender.userInfo?["image"] as? UIImage {

    }

    // Message is available only if you decided to show the textInput
    // in the LTPickerConfig and you write something
    if let message = sender.userInfo?["message"] as? String, !message.isEmpty {

    }
}
```


## Installation

**LTImagePicker** is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LTImagePicker'
```

and run `pod install`

## Author

LorTos, lorenzotoscanidc@gmail.com

## License

LTImagePicker is available under the MIT license. See the LICENSE file for more info.
