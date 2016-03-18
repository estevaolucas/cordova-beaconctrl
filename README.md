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
1. Create a file named `Podfile` in the `plataforms/ios` folder with the content below; 
2. Run command `$ pod install` in the same folder of Podfile;
3. In case of a self-hosted BeaconControl environment, you'll need to add the ``BCLBaseURLAPI`` key to project's Info.plist file in order to override the default base url;

Podfile:
    
      source 'https://github.com/CocoaPods/Specs.git'
      target 'NAME OF PROJECT`S TARGET' do
         pod "UNNetworking", :git => "https://github.com/upnext/UNNetworking.git", :branch => :master
         pod 'BeaconCtrl', :git => "https://github.com/upnext/BeaconCtrl_iOS_SDK.git", :branch => :master
         pod 'SSKeychain'
      end


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
    cordova.plugins.beaconCtrl.start({
        clientId: 'CLIENTID',
        clientSecret: 'CLIENTSECRET'
    });

  // stop monitoring
  cordova.plugins.beaconCtrl.stop();

## TODO 

 - Create *Podfile* and run `post install` with hook
 - Document the API
 - Android support
 - Publish plugin

## License

MIT © [Estevão Lucas](http://twitter.com/estevao_lucas)

