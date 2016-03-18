//
//  BCLBackend+Nobot.m
//  iBeconPrototype
//
//  Created by Estevão Lucas on 3/8/16.
//  Copyright © 2016 nobot. All rights reserved.
//

#import "NobotBCLBackend.h"

@implementation NoBotBCLBackend

+ (NSString *)baseURLString {
    NSString *baseURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BeaconCtrlBaseURL"];
    
    if (baseURL) {
        return baseURL;
    }
    
    return [super baseURLString];
}

@end
