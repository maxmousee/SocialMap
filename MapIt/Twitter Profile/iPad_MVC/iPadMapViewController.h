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

#define ARC4RANDOM_MAX 0X100000000
#define kTYPE1 @"Friend"
#define kTYPE2 @"Friend of friend"
#define kDEFAULTCLUSTERSIZE 0.2

@interface iPadMapViewController : UIViewController <MKMapViewDelegate> {
    NSString *username;
    NSArray *followersIDs;
    IBOutlet OCMapView *socialMapView;
}

@property (nonatomic, retain) NSString *twitterUsername;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end
