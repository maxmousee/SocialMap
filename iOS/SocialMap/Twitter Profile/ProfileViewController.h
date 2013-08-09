//
//  ProfileViewController.h
//  Twitter Profile
//
//  Created by Jeroen van Rijn on 05-02-13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ProfileViewController : UIViewController
{
    IBOutlet UIImageView *profileImageView;
    IBOutlet UIImageView *bannerImageView;
    
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *usernameLabel;
    
    IBOutlet UILabel *tweetsLabel;
    IBOutlet UILabel *followingLabel;
    IBOutlet UILabel *followersLabel;
    
    NSString *username;
    BOOL isFullScreen;
    CGRect mapViewSmallFrame;
}

@property (nonatomic, retain) NSString *username;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)handleMapViewTap:(UITapGestureRecognizer *)recognizer;

@end
