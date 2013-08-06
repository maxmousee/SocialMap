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

@interface TweetMapViewController : UIViewController <MKMapViewDelegate> {
    NSString *username;
    NSArray *followersIDs;
    IBOutlet MKMapView *socialMapView;
}

@property (nonatomic, retain) NSString *username;

@end
