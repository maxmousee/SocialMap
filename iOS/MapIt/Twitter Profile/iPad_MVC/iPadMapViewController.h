//
//  iPadMapViewController.h
//  MapIt
//
//  Created by Natan Facchin on 8/28/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <math.h>
#import "OCMapView.h"
#import "OCMapViewSampleHelpAnnotation.h"
#import "RefreshMapViewDelegate.h"
#import "Configs.h"

#define ARC4RANDOM_MAX 0X100000000
#define kTYPE1 @"Facebook"
#define kTYPE2 @"Twitter"
#define kDEFAULTCLUSTERSIZE 0.2

@interface iPadMapViewController : UIViewController <MKMapViewDelegate, FBLoginViewDelegate, UISplitViewControllerDelegate, RefreshMapViewDelegate> {
    NSString *username;
    NSArray *followersIDs;
    IBOutlet OCMapView *socialMapView;
}

@property (nonatomic, retain) NSString *twitterUsername;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) Configs *currentCFGs;

@end
