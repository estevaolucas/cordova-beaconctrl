//
//  BeaconCtrlCordovaPlugin.m
//
//  Created by Estevão Lucas on 3/16/16.
//  Copyright © 2016 nobot. All rights reserved.
//  Source: https://github.com/katzer/cordova-plugin-local-notifications/blob/master/src/ios/APPLocalNotification.m
//

#import "BeaconCtrlCordovaPlugin.h"
#import <Cordova/CDV.h>
#import <UNNetworking/UNCodingUtil.h>

@interface BeaconCtrlCordovaPlugin ()

@property (strong) NSString *callbackId;

@end


@implementation BeaconCtrlCordovaPlugin

static NSDictionary *launchOptions;

- (void)startMonitoring:(CDVInvokedUrlCommand *)command {
    [[BeaconCtrlManager sharedManager] startWithDelegate:self withCompletion:^(BOOL success, NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        if (!success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                             messageAsString:error.localizedDescription];
        }
        
        self.callbackId = command.callbackId;
        
        [self.commandDelegate runInBackground:^{
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        }];
    }];
}

- (void)stopMonitoring {
    [[BeaconCtrlManager sharedManager] logout];
}

#pragma mark - BCLBeaconCtrlDelegate

- (void)closestObservedBeaconDidChange:(BCLBeacon *)closestBeacon {
//    NSLog(@"The closest beacon is: %@", closestBeacon.name);
}

- (void)currentZoneDidChange:(BCLZone *)currentZone {
//    NSLog(@"You're now in this zone: %@", currentZone.name);
}

- (void)didChangeObservedBeacons:(NSSet *)newObservedBeacons {
    NSLog(@"Changed observed beacons: %@", [newObservedBeacons allObjects]);
}

- (BOOL)shouldAutomaticallyNotifyAction:(BCLAction *)action {
    return NO;
}

- (void)willNotifyAction:(BCLAction *)action {
//    if (![[BeaconCtrlManager sharedManager] actionCanBePerformed:action saveTimestamp:NO]) {
//        return;
//    }
    
    [self fireEvent:@"willNotifyAction" values:[self normalizeAction:action]];
}

- (BOOL)shouldAutomaticallyPerformAction:(BCLAction *)action {
    return YES;
}

- (void)willPerformAction:(BCLAction *)action {
    [self fireEvent:@"willPerformAction" values:[self normalizeAction:action]];
}

- (void)didPerformAction:(BCLAction *)action {
//    if (![[BeaconCtrlManager sharedManager] actionCanBePerformed:action saveTimestamp:YES]) {
//        return;
//    }
    [self fireEvent:@"didPerformAction" values:[self normalizeAction:action]];
}

- (void)beaconsPropertiesUpdateDidStart:(BCLBeacon *)beacon {
    // TODO implement
}

- (void)beaconsPropertiesUpdateDidFinish:(BCLBeacon *)beacon success:(BOOL)success {
    // TODO implement
}

- (void)beaconsFirmwareUpdateDidStart:(BCLBeacon *)beacon {
    // TODO implement
}

- (void)beaconsFirmwareUpdateDidProgress:(BCLBeacon *)beacon progress:(NSUInteger)progress {
    // TODO implement
}

- (void)beaconsFirmwareUpdateDidFinish:(BCLBeacon *)beacon success:(BOOL)success {
    // TODO implement
}

- (NSDictionary *)normalizeAction:(BCLAction *)action {
    // FIXME: return action.trigger to
    NSDictionary *a = @{
                        @"id": action.identifier,
                        @"name": action.name,
                        @"type": action.type,
                        @"isTestAction": [NSNumber numberWithBool:action.isTestAction],
                        @"customValues": action.customValues,
                        @"payload": action.payload
                        };
    
    return a;
}

- (void)fireEvent:(NSString *)event values:(NSDictionary *)values {
    NSDictionary *result = @{ @"type": event,
                              @"data": values };
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                  messageAsDictionary:result];
    //[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    //}];
}

@end