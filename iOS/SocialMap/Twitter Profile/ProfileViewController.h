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

@interface ProfileViewController : UIViewController
{
    IBOutlet UIImageView *profileImageView;
    IBOutlet UIImageView *bannerImageView;
    
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *usernameLabel;
    
    IBOutlet UILabel *tweetsLabel;
    IBOutlet UILabel *followingLabel;
    IBOutlet UILabel *followersLabel;
    
    IBOutlet UITextView *lastTweetTextView;
    
    NSString *username;
}

@property (nonatomic, retain) NSString *username;

@end
