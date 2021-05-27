# Voximplant Bitcode Demo

This repository contains example of how to include [Bitcode](https://voximplant.com/docs/howtos/advanced/bitcode) version of Voximplant iOS SDK.

## Using helper

1. Copy [Voximplant Bitcode helper](voximplant_bitcode.rb) and [Gemfile](Gemfile) to your project directory
2. Install bundler gem with `$ (sudo) gem install bundler`
3. Add this lines to your `Podfile`:

    ```ruby
    def voximplant
        sdk_version = '2.39.0'

        require_relative 'voximplant_bitcode'
        Voximplant::prepare_voximplant_pods sdk_version

        pod 'VoxImplantSDK', :path => "./Pods/VoxImplantSDK"
        pod 'VoxImplantWebRTC', :path => "./Pods/VoxImplantWebRTC"
    end
    ```

4. Change `pod 'VoxImplantSDK'` lines to `voximplant`
5. Run this commands

    ```bash
    $ bundle install
    $ bundle exec pod install
    ```
6. Open generated .xcworkspace

## Manually

1. Download and extract [Voximplant iOS SDK][sdk] and [Voximplant WebRTC][webrtc]
2. Edit your `Podfile` by replacing `pod 'VoxImplantSDK'` lines by:

    ```ruby
    pod 'VoxImplantSDK', :path => "Path/To/Extracted/VoxImplant_bitcode"
    pod 'VoxImplantWebRTC', :path => "Path/To/Extracted/VoxImplantWebRTC_bitcode"
    ```
3. Run `pod install`
4. Open generated .xcworkspace

[sdk]: https://s3.eu-central-1.amazonaws.com/voximplant-releases/ios-sdk/2.34.3/VoxImplant_bitcode.zip
[webrtc]: https://s3.eu-central-1.amazonaws.com/voximplant-releases/ios-webrtc/78.5.0/VoxImplantWebRTC_bitcode.zip
