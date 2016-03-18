var exec = require('cordova/exec'),
  cordova = require('cordova');

function BeaconCtrl() {};

BeaconCtrl.prototype.startMonitoring = function(successCallback, errorCallback) {
  exec(successCallback,
      errorCallback, 
      'BeaconCtrlCordovaPlugin', 
      'startMonitoring', 
      []
      );
};

BeaconCtrl.prototype.stopMonitoring = function(successCallback, errorCallback) {
  exec(successCallback,
      errorCallback, 
      'BeaconCtrlCordovaPlugin', 
      'stopMonitoring', 
      []
      );
};

BeaconCtrl.prototype.start = function() {
  this.startMonitoring(function(result) {
    if (result.type) {
      cordova.fireDocumentEvent(result.type, result.data || {});
    }
  }, function (e) {
    console.log('Error initializing BeaconControl: ' + e);

    cordova.fireDocumentEvent('error', e);
  });
}

var plugin = new BeaconCtrl();

exports.start = function() {
  plugin.start();
}

exports.stop = function() {
  plugin.stopMonitoring();
}
