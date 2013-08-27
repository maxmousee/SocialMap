//
//  TweetMapViewController.h
//  Twitter Profile
//
//  Created by Natan Facchin on 7/7/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <iAd/iAd.h>
#import <math.h>
#import "OCMapView.h"
#import "OCMapViewSampleHelpAnnotation.h"

#define ARC4RANDOM_MAX 0X100000000
#define kTYPE1 @"Friend"
#define kTYPE2 @"Friend of friend"
#define kDEFAULTCLUSTERSIZE 0.2


@interface TweetMapViewController : UIViewController <MKMapViewDelegate, ADBannerViewDelegate> {
    NSString *username;
    NSArray *followersIDs;
    IBOutlet OCMapView *socialMapView;
    
    BOOL bannerIsVisible;
}

@property (nonatomic, retain) NSString *username;
@property (weak, nonatomic) IBOutlet ADBannerView *theBannerView;

@end
