//
//  ConfigurationViewController.h
//  MapIt
//
//  Created by Natan Facchin on 8/28/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface ConfigurationViewController : UIViewController <FBLoginViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UISwitch *facebookEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterInteractionsOnSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterTimelineOnSwitch;

@end
