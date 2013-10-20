//
//  Configs.m
//  MapIt
//
//  Created by Natan Facchin on 8/28/13.
//  Copyright (c) 2013 NFS Industries. All rights reserved.
//

#import "Configs.h"

@implementation Configs

+(Configs *)updateCFG: (BOOL)twTimelineEnabled : (BOOL)twInteractionsEnabled : (int)isFBCurrentLocation {
    Configs *configs = [[Configs alloc]init];
    configs.showTwInteractions = twInteractionsEnabled;
    configs.showTwTimeline = twTimelineEnabled;
    configs.fbCurrentLocation = isFBCurrentLocation;
    return configs;
}

@end
