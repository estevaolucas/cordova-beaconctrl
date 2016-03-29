var exec = require('cordova/exec'),
  cordova = require('cordova');

function BeaconCtrl() {};

BeaconCtrl.prototype.startMonitoring = function(config, successCallback, errorCallback) {
  exec(successCallback,
      errorCallback, 
      'BeaconCtrlCordovaPlugin', 
      'startMonitoring', 
      [config]
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

BeaconCtrl.prototype.start = function(config) {
  var config = config || {};

  this.startMonitoring(config, function(result) {
    if (result.type) {
      cordova.fireDocumentEvent(result.type, result.data || {});
    }
  }, function (e) {
    var userInfo = e.info,
      newError = [];

    for (var key in userInfo) {
      newError.push({
        code: key,
        message: userInfo[key]
      });
    }

    console.log('Error initializing BeaconControl: ' + e);
    cordova.fireDocumentEvent('error', newError);
  });
}

var plugin = new BeaconCtrl();

exports.start = function(config) {
  plugin.start(config);
}

exports.stop = function() {
  plugin.stopMonitoring();
}

exports.errorCodes = {
  BCLBluetoothNotTurnedOnErrorKey: 'BCLBluetoothNotTurnedOnErrorKey',
  BCLDeniedMonitoringErrorKey: 'BCLDeniedMonitoringErrorKey',
  BCLDeniedLocationServicesErrorKey: 'BCLDeniedLocationServicesErrorKey',
  BCLDeniedBackgroundAppRefreshErrorKey: 'BCLDeniedBackgroundAppRefreshErrorKey',
  BCLDeniedNotificationsErrorKey: 'BCLDeniedNotificationsErrorKey',
}
