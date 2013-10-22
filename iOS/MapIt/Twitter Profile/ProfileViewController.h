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
#import "OCMapView.h"
#import "OCMapViewSampleHelpAnnotation.h"

@interface ProfileViewController : UIViewController <MKMapViewDelegate>
{
    //nothing here
}

@property (weak, nonatomic) IBOutlet OCMapView *mapView;

@end
