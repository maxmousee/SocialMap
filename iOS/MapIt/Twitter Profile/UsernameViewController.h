//
//  UsernameViewController.h
//  Twitter Profile
//
//  Created by Jeroen van Rijn on 05-02-13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface UsernameViewController : UIViewController<FBFriendPickerDelegate>
{
    NSString *username;
    NSMutableArray *fbUsers;
}

- (IBAction)pickFriendsButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *showMapButton;
@property (weak, nonatomic) IBOutlet UIButton *showTwitterInfoButton;
@property (weak, nonatomic) IBOutlet UISwitch *interactionsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *timelineSwitch;

@end
