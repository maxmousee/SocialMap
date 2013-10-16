//
//  Configs.m
//  MapIt
//
//  Created by Natan Facchin on 8/28/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import "Configs.h"

@implementation Configs

+(Configs *)updateCFG: (int)twTimelineEnabled : (int)twInteractionsEnabled : (FBLoginView *)theLoginview : (int)isFBCurrentLocation {
    Configs *configs = [[Configs alloc]init];
    configs.loginview = theLoginview;
    configs.showTwInteractions = twInteractionsEnabled;
    configs.showTwTimeline = twTimelineEnabled;
    configs.fbCurrentLocation = isFBCurrentLocation;
    return configs;
}

@end
