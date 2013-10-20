//
//  Configs.h
//  MapIt
//
//  Created by Natan Facchin on 8/28/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface Configs : NSObject {
}

@property (nonatomic, assign) int fbCurrentLocation;
@property (nonatomic, assign) BOOL showTwTimeline;
@property (nonatomic, assign) BOOL showTwInteractions;

+(Configs *)updateCFG: (BOOL)twTimelineEnabled : (BOOL)twInteractionsEnabled : (int)isFBCurrentLocation;

@end
