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
    console.log('Error initializing BeaconControl: ' + e);
    
    var userInfo = e.info,
      data = [];

    for (var key in userInfo) {
      data.push({
        code: key,
        message: userInfo[key]
      });
    }

    e.data = data

    cordova.fireDocumentEvent('error', e);
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
