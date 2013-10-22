//
//  FbSettingsVC.h
//  MapIt
//
//  Created by Natan Facchin on 10/22/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#define FBHOMETOWN "fbHometown"
#define FBCURRENTLOCATION "fbCurrentLocation"

@interface FbSettingsVC : UIViewController
{
    //nothing to declare here
}

@property (weak, nonatomic) IBOutlet FBProfilePictureView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *usrnameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *currentLocationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hometownSwitch;


@end
