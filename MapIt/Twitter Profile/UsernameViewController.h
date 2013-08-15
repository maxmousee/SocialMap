//
//  UsernameViewController.h
//  Twitter Profile
//
//  Created by Jeroen van Rijn on 05-02-13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <iAd/iAd.h>

@interface UsernameViewController : UIViewController<FBFriendPickerDelegate, ADBannerViewDelegate>
{
    NSString *username;
    NSMutableArray *fbUsers;
    BOOL bannerIsVisible;
}

- (IBAction)pickFriendsButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *showMapButton;
@property (weak, nonatomic) IBOutlet UIButton *showTwitterInfoButton;
@property (weak, nonatomic) IBOutlet UISwitch *interactionsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *timelineSwitch;
@property (weak, nonatomic) IBOutlet ADBannerView *theBannerView;

@end
