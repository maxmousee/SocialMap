//
//  TwtrSettingsViewController.m
//  MapIt
//
//  Created by Natan Facchin on 10/21/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import "TwtrSettingsViewController.h"

#define TWUSRINTERACTIONS "userInteractions"
#define TWTIMELINE "timeline"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface TwtrSettingsViewController ()

@end

@implementation TwtrSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    _interactionsSwitch.onTintColor = [UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1];
    _timelineSwitch.onTintColor = [UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL twInteractions = [defaults boolForKey:@TWUSRINTERACTIONS];
    BOOL twTimeline = [defaults boolForKey:@TWTIMELINE];
    
    if(twTimeline || twInteractions) {
        [_interactionsSwitch setOn:twInteractions animated:YES];
        [_timelineSwitch setOn:twTimeline animated:YES];
    } else {
        [_interactionsSwitch setOn:YES animated:YES];
        [_timelineSwitch setOn:NO animated:YES];
    }

    
	[_userProfileIV.layer setBorderWidth:4.0f];
    [_userProfileIV.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [_userProfileIV.layer setShadowRadius:3.0];
    [_userProfileIV.layer setShadowOpacity:0.5];
    [_userProfileIV.layer setShadowOffset:CGSizeMake(1.0, 0.0)];
    [_userProfileIV.layer setShadowColor:[[UIColor blackColor] CGColor]];
    
    [_userProfileIV.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_userProfileIV.layer setBorderWidth: 2.0];
    
    /*
    [_userBackgroundIV.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_userBackgroundIV.layer setBorderWidth: 2.0];
    */
    [self getInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        [_interactionsSwitch setFrame:CGRectOffset(_interactionsSwitch.frame, 0, 12)];
        [_timelineSwitch setFrame:CGRectOffset(_timelineSwitch.frame, 0, 12)];
    }
    
    [_interactionsSwitch setHidden:NO];
    [_timelineSwitch setHidden:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getProfileImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    _userProfileIV.image = [UIImage imageWithData:data];
}

/*
- (void) getBannerImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    _userBackgroundIV.image = [UIImage imageWithData:data];
}
*/
- (void) getInfo
{
    // Request access to the Twitter accounts
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                // Creating a request to get the info about a user on Twitter
                username = twitterAccount.username;
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:twitterAccount.username forKey:@"screen_name"]];
                [twitterInfoRequest setAccount:twitterAccount];
                
                // Making the request
                
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // Check if we reached the reate limit
                        
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        
                        // Check if there was an error
                        
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        // Check if there is some response data
                        
                        if (responseData) {
                            
                            NSError *error = nil;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            NSLog(@"%@", TWData);
                            
                            // Filter the preferred data
                            
                            //NSString *screen_name = [(NSDictionary *)TWData objectForKey:@"screen_name"];
                            //NSString *name = [(NSDictionary *)TWData objectForKey:@"name"];
                            
                            //int followers = [[(NSDictionary *)TWData objectForKey:@"followers_count"] integerValue];
                            //int following = [[(NSDictionary *)TWData objectForKey:@"friends_count"] integerValue];
                            //int tweets = [[(NSDictionary *)TWData objectForKey:@"statuses_count"] integerValue];
                            
                            NSString *profileImageStringURL = [(NSDictionary *)TWData objectForKey:@"profile_image_url_https"];
                            //NSString *bannerImageStringURL =[(NSDictionary *)TWData objectForKey:@"profile_banner_url"];
                            
                            
                            // Update the interface with the loaded data
                            
                            //[_usernameLabel setText:[NSString stringWithFormat:@"@%@",screen_name]];
                            
                            //_countTweetsLabel.text = [NSString stringWithFormat:@"%i", tweets];
                            //_countFollowingLabel.text= [NSString stringWithFormat:@"%i", following];
                            //_countFollowersLabel.text = [NSString stringWithFormat:@"%i", followers];
                            
                            //NSString *lastTweet = [[(NSDictionary *)TWData objectForKey:@"status"] objectForKey:@"text"];
                            
                            // Get the profile image in the original resolution
                            
                            profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                            [self getProfileImageForURLString:profileImageStringURL];
                            
                            
                            // Get the banner image, if the user has one
                            /*
                            if (bannerImageStringURL) {
                                NSString *bannerURLString = [NSString stringWithFormat:@"%@/mobile_retina", bannerImageStringURL];
                                [self getBannerImageForURLString:bannerURLString];
                            } else {
                                _userBackgroundIV.backgroundColor = [UIColor underPageBackgroundColor];
                            }
                             */
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"UserInteractions enabled %d", [_interactionsSwitch isOn]);
    //NSLog(@"Timeline enabled %d", [_timelineSwitch isOn]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[_interactionsSwitch isOn] forKey:@TWUSRINTERACTIONS];
    [defaults setInteger:[_timelineSwitch isOn] forKey:@TWTIMELINE];
    [defaults synchronize];
}

@end
