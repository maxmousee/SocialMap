//
//  FbSettingsVC.h
//  MapIt
//
//  Created by Natan Facchin on 10/22/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FbSettingsVC : UIViewController
{
    //nothing to declare here
}

@property (weak, nonatomic) IBOutlet UIImageView *userProfileIV;
@property (weak, nonatomic) IBOutlet UILabel *usrnameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *currentLocationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hometownSwitch;


@end
