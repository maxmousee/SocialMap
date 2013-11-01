//
//  TwtrSettingsViewController.h
//  MapIt
//
//  Created by Natan Facchin on 10/21/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

@interface TwtrSettingsViewController : UIViewController {
    NSString *username;
}

@property (weak, nonatomic) IBOutlet UISwitch *interactionsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *timelineSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *userProfileIV;

@end
