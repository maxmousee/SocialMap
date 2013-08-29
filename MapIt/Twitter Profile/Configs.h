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

@property (nonatomic, strong) FBLoginView *loginview;
@property (nonatomic, assign) int showTwInteractions;
@property (nonatomic, assign) int showTwTimeline;

+(Configs *)updateCFG: (int)twTimelineEnabled : (int)twInteractionsEnabled : (FBLoginView *)loginview;

@end
