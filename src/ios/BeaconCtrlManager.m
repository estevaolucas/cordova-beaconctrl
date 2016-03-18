//
//  BeaconCtrlManager.m
//  BCLRemoteApp
//
// Copyright (c) 2015, Upnext Technologies Sp. z o.o.
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause License found in the
// LICENSE.txt file in the root directory of this source tree.
//

#import "BeaconCtrlManager.h"
#import "AppDelegate.h"
#import <BeaconCtrl/BCLBeacon.h>
#import <BeaconCtrl/BCLTrigger.h>
#import <BeaconCtrl/BCLBeacon.h>

NSString * const BeaconManagerReadyForSetupNotification = @"BeaconManagerReadyForSetupNotification";
NSString * const BeaconManagerDidLogoutNotification = @"BeaconManagerDidLogoutpNotification";
NSString * const BeaconManagerDidFetchBeaconCtrlConfigurationNotification = @"BeaconManagerDidFetchBeaconCtrlConfigurationNotification";
NSString * const BeaconManagerClosestBeaconDidChangeNotification = @"BeaconManagerClosestBeaconDidChangeNotification";
NSString * const BeaconManagerCurrentZoneDidChangeNotification = @"BeaconManagerCurrentZoneDidChangeNotification";
NSString * const BeaconManagerPropertiesUpdateDidStartNotification = @"BeaconManagerPropertiesUpdateDidStartNotification";
NSString * const BeaconManagerPropertiesUpdateDidFinishNotification = @"BeaconManagerPropertiesUpdateDidFinishNotification";
NSString * const BeaconManagerFirmwareUpdateDidStartNotification = @"BeaconManagerFirmwareUpdateDidStartNotification";
NSString * const BeaconManagerFirmwareUpdateDidProgressNotification = @"BeaconManagerFirmwareUpdateDidProgresstNotification";
NSString * const BeaconManagerFirmwareUpdateDidFinishNotification = @"BeaconManagerFirmwareUpdateDidFinishNotification";

@interface BeaconCtrlManager ()

@property (nonatomic, copy) NSString *pushNotificationDeviceToken;
@property (nonatomic) BCLBeaconCtrlPushEnvironment pushEnvironment;

@property (nonatomic, readwrite) BOOL isReadyForSetup;

@end

@implementation BeaconCtrlManager

- (instancetype)init {
    if (self = [super init]) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self
               selector:@selector(didRegisterForRemoteNotifications:)
                   name:CDVRemoteNotification
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(didFailToRegisterRegisterForRemoteNotifications:)
                   name:CDVRemoteNotificationError
                 object:nil];
        
        NSUserDefaults *stantardUserDefaults = [NSUserDefaults standardUserDefaults];
        [stantardUserDefaults setInteger:10 forKey:@"BCLRemoteAppMaxFloorNumber"];
        [stantardUserDefaults synchronize];
        
        // FIXME: get real value
        _isReadyForSetup = YES; //((AppDelegate *)[UIApplication sharedApplication].delegate).isRemoteNotificationSetupReady;
    }
    
    return self;
}

+ (instancetype)sharedManager {
    static BeaconCtrlManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[BeaconCtrlManager alloc] init];
    });
    return sharedManager;
}

- (void)refetchBeaconCtrlConfiguration:(void (^)(NSError *error))completion {
    __typeof__(self) __weak weakSelf = self;
    
    [self.beaconCtrl fetchConfiguration:^(NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BeaconManagerDidFetchBeaconCtrlConfigurationNotification object:weakSelf];
        }
        
        [weakSelf.beaconCtrl updateMonitoredBeacons];
        
        if (completion) {
            completion(error);
        }
    }];
}

- (void)setIsReadyForSetup:(BOOL)isReadyForSetup {
    if (_isReadyForSetup == NO && isReadyForSetup == YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BeaconManagerReadyForSetupNotification object:self];
    }
    
    _isReadyForSetup = isReadyForSetup;
}

- (void)logout {
    [self.beaconCtrl stopMonitoringBeacons];
    [self.beaconCtrl logout];
    
    self.beaconCtrl.delegate = nil;
    self.beaconCtrl = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BeaconManagerDidLogoutNotification object:self];
}

+ (NSString *)pushEnvironmentNameWithPushEnvironment:(BCLBeaconCtrlPushEnvironment)pushEnvironment {
    switch(pushEnvironment) {
        case BCLBeaconCtrlPushEnvironmentProduction:
            return @"production";
        case BCLBeaconCtrlPushEnvironmentSandbox:
            return @"sandbox";
        default:
            return nil;
    }
}

- (void)startWithDelegate:(id<BCLBeaconCtrlDelegate>)delegate withCompletion:(void (^)(BOOL, NSError *))completion {
    __typeof__(self) __weak weakSelf = self;

    NSString *clientId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BeaconCtrlAPIClientId"];
    NSString *clientSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BeaconCtrlAPIClientSecret"];
    
    [BCLBeaconCtrl setupBeaconCtrlWithClientId:clientId
                                  clientSecret:clientSecret
                                        userId:nil
                               pushEnvironment:self.pushEnvironment
                                     pushToken:self.pushNotificationDeviceToken
                                    completion:^(BCLBeaconCtrl *beaconCtrl, BOOL isRestoredFromCache, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (!beaconCtrl) {
                if (completion) {
                    completion(NO, error);
                    return;
                }
            }
            
            weakSelf.beaconCtrl = beaconCtrl;
            beaconCtrl.delegate = delegate;
            
            [beaconCtrl startMonitoringBeacons];
            
            NSError *beaconMonitoringError;
            if (![beaconCtrl isBeaconCtrlReadyToProcessBeaconActions:&beaconMonitoringError]) {
                NSLog(@"%@",[beaconMonitoringError localizedDescription]);

                completion(NO, beaconMonitoringError);

                return;
            }
            
            if (completion) {
                completion(YES, nil);
            }
        });
    }];
}

- (NSDictionary *)normalizeCustomValuesForAction:(BCLAction *)action {
    NSMutableDictionary *tempCustomValues = [[NSMutableDictionary alloc] init];
    
    [action.customValues enumerateObjectsUsingBlock:^(NSDictionary *pair, NSUInteger idx, BOOL *stop) {
        NSString *name = pair[@"name"];
        NSString *value = pair[@"value"];
        
        tempCustomValues[name] = value;
    }];
    
    return [tempCustomValues copy];
}

- (BOOL)actionCanBePerformed:(BCLAction *)action saveTimestamp:(BOOL)save {
    NSDictionary *values = [self normalizeCustomValuesForAction:action];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *timestampKey = [NSString stringWithFormat:@"timestamp-%@", action.name];
    NSNumber *actionTimestampValue = values[@"timestamp"];
    NSDate *actionTimestampStored = [userDefaults objectForKey:timestampKey];
    
    // there is timestamp for this action
    if (actionTimestampValue) {
        // alredy save same value
        if (actionTimestampStored) {
            int now = [[NSDate new] timeIntervalSince1970];
            int stored = [actionTimestampStored timeIntervalSince1970];
            
            // already did the action
            NSLog(@"----- Checkin time difference: %ld", (stored + [actionTimestampValue integerValue] - now));
            if ((stored + [actionTimestampValue integerValue]) > now) {
                return NO;
            }
        }
        
        // save this action's time
        if (save) {
            [userDefaults setObject:[NSDate new] forKey:timestampKey];
        }
    }
    
    return YES;
}

#pragma mark - Private
- (UIViewController *)topViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)didRegisterForRemoteNotifications:(NSNotification *)notification {
    self.isReadyForSetup = YES;
    
#ifdef DEBUG
    self.pushEnvironment = BCLBeaconCtrlPushEnvironmentSandbox;
#else
    self.pushEnvironment = BCLBeaconCtrlPushEnvironmentProduction;
#endif
    self.pushNotificationDeviceToken = notification.userInfo[@"deviceToken"];
}

- (void)didFailToRegisterRegisterForRemoteNotifications:(NSNotification *)notification {
    self.isReadyForSetup = YES;
    
    self.pushEnvironment = BCLBeaconCtrlPushEnvironmentNone;
    self.pushNotificationDeviceToken = nil;
}

@end
