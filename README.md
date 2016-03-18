# cordova-plugin-beaconCtrl

[iOS](https://github.com/upnext/BeaconControl_iOS_SDK) Cordova plugin for [BeaconControl](http://beaconcontrol.io) SDK

## Installation

    cordova plugin add cordova-plugin-beaconCtrl

## Requirements
- Ruby 
- Cocoapods 

## Supported Platforms

- iOS
- Android under development

## Pos-installation config

Create Podfile at root of iOS folder


      source 'https://github.com/CocoaPods/Specs.git'
    
      target 'clubinho' do
        pod "UNNetworking", :git => "https://github.com/upnext/UNNetworking.git", :branch
        => :master
      #  pod 'BeaconCtrl', :git => "https://github.com/upnext/BeaconCtrl_iOS_SDK.git", :branch => :master
        pod 'BeaconCtrl', :path => "/Users/estevao/Sites/nobot/BeaconControl_iOS_SDK"
        pod 'SSKeychain'
      end
      
TODO: Configure ClientId and SecretId...

### Quick Example

    // background mode
    document.addEventListener('willNotifyAction', function(data) {
        // data will return all informations about the action
    }, true);

    // foreground mode
    document.addEventListener('didPerformAction', function(data) {
      alert('entrou no didPerformAction');
    }, true);

    document.addEventListener('error', function(data) {
      
    }, true);

	// start monitoring
    cordova.plugins.beaconCtrl.start();

	// stop monitoring
	cordova.plugins.beaconCtrl.stop();

## TODO 

 - Create *Podfile* and run `post install` with hook
 - Document the API
 - Android support
 - Publish plugin

## License

MIT © [Estevão Lucas](http://twitter.com/estevao_lucas)

