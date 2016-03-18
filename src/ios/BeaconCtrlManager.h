//
//  BeaconCtrlManager.h
//  BCLRemoteApp
//
// Copyright (c) 2015, Upnext Technologies Sp. z o.o.
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause License found in the
// LICENSE.txt file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>
#import <BeaconCtrl/BCLBeaconCtrl.h>
#import <BeaconCtrl/BCLBeaconCtrlAdmin.h>

extern NSString * const BeaconManagerReadyForSetupNotification;
extern NSString * const BeaconManagerDidLogoutNotification;
extern NSString * const BeaconManagerDidFetchBeaconCtrlConfigurationNotification;
extern NSString * const BeaconManagerClosestBeaconDidChangeNotification;
extern NSString * const BeaconManagerCurrentZoneDidChangeNotification;
extern NSString * const BeaconManagerPropertiesUpdateDidStartNotification;
extern NSString * const BeaconManagerPropertiesUpdateDidFinishNotification;

@interface BeaconCtrlManager : NSObject

@property (nonatomic, strong) BCLBeaconCtrl *beaconCtrl;
@property (nonatomic, readonly) BOOL isReadyForSetup;
@property (nonatomic, readonly) BOOL canTryAutoLogin;

@property (strong) NSString *clientId;
@property (strong) NSString *clientSecret;

+ (instancetype)sharedManager;

- (void)refetchBeaconCtrlConfiguration:(void (^)(NSError *error))completion;
- (void)startWithDelegate:(id<BCLBeaconCtrlDelegate>)delegate withCompletion:(void (^)(BOOL, NSError *))completion;
- (void)logout;

- (BOOL)actionCanBePerformed:(BCLAction *)action saveTimestamp:(BOOL)save;

@end
