//
//  ProfileViewController.m
//  Twitter Profile
//
//  Created by Jeroen van Rijn on 05-02-13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import "ProfileViewController.h"
#import "TweetMapViewController.h"

@interface ProfileViewController () <ADBannerViewDelegate>

@end

@implementation ProfileViewController

@synthesize username;

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
    [super viewDidLoad];
    
    [profileImageView.layer setBorderWidth:4.0f];
    [profileImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [profileImageView.layer setShadowRadius:3.0];
    [profileImageView.layer setShadowOpacity:0.5];
    [profileImageView.layer setShadowOffset:CGSizeMake(1.0, 0.0)];
    [profileImageView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    
    [profileImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [profileImageView.layer setBorderWidth: 2.0];
    
    [bannerImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [bannerImageView.layer setBorderWidth: 2.0];
    
    [_mapView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_mapView.layer setBorderWidth: 2.0];
    
    isFullScreen = false;
    mapViewSmallFrame = _mapView.frame;
    
    _theBannerView.frame = CGRectOffset(_theBannerView.frame, 0, 50);
    bannerIsVisible = YES;
    _theBannerView.delegate = self;
    
    [self getInfo];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int plotInteractions = [defaults integerForKey:@"userInteractions"];
    int plotTimeline = [defaults integerForKey:@"userInteractions"];
    if (plotInteractions > 0) {
        [self plotInteractions];
    }
    if(plotTimeline > 0) {
        [self plotTimeline];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!bannerIsVisible)
    {
        NSLog(@"bannerViewDidLoadAd");
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -50);
        //buttonFrame.frame = CGRectOffset(buttonFrame.frame, 0, -50);
        //web.frame = CGRectMake(web.frame.origin.x, web.frame.origin.y, web.frame.size.width,
        //                       web.frame.size.height-50);
        [UIView commitAnimations];
        bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (bannerIsVisible)
    {
        NSLog(@"bannerView:didFailToReceiveAdWithError:");
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // assumes the banner view is at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, 50);
        //buttonFrame.frame = CGRectOffset(buttonFrame.frame, 0, 50);
        //web.frame = CGRectMake(web.frame.origin.x,
        //                       web.frame.origin.y,
        //                       web.frame.size.width,
        //                       web.frame.size.height+50);
        [UIView commitAnimations];
        bannerIsVisible = NO;
    }
}

- (IBAction)handleMapViewTap:(UITapGestureRecognizer *)recognizer{
    NSLog(@"Tap gesture recognized");
    if(!isFullScreen) {
        [_mapView setFrame:[self.view frame]];
    } else {
        //[_mapView setFrame:mapViewSmallFrame];
    }
    //isFullScreen = !isFullScreen;
}

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
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:username forKey:@"screen_name"]];
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
                            
                            NSString *screen_name = [(NSDictionary *)TWData objectForKey:@"screen_name"];
                            NSString *name = [(NSDictionary *)TWData objectForKey:@"name"];
                            
                            int followers = [[(NSDictionary *)TWData objectForKey:@"followers_count"] integerValue];
                            int following = [[(NSDictionary *)TWData objectForKey:@"friends_count"] integerValue];
                            int tweets = [[(NSDictionary *)TWData objectForKey:@"statuses_count"] integerValue];
                            
                            NSString *profileImageStringURL = [(NSDictionary *)TWData objectForKey:@"profile_image_url_https"];
                            NSString *bannerImageStringURL =[(NSDictionary *)TWData objectForKey:@"profile_banner_url"];
                            
                            
                            // Update the interface with the loaded data
                            
                            nameLabel.text = name;
                            usernameLabel.text= [NSString stringWithFormat:@"@%@",screen_name];
                            
                            tweetsLabel.text = [NSString stringWithFormat:@"%i", tweets];
                            followingLabel.text= [NSString stringWithFormat:@"%i", following];
                            followersLabel.text = [NSString stringWithFormat:@"%i", followers];
                            
                            //NSString *lastTweet = [[(NSDictionary *)TWData objectForKey:@"status"] objectForKey:@"text"];
                            
                            // Get the profile image in the original resolution
                            
                            profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                            [self getProfileImageForURLString:profileImageStringURL];
                            
                            
                            // Get the banner image, if the user has one
                            
                            if (bannerImageStringURL) {
                                NSString *bannerURLString = [NSString stringWithFormat:@"%@/mobile_retina", bannerImageStringURL];
                                [self getBannerImageForURLString:bannerURLString];
                            } else {
                                bannerImageView.backgroundColor = [UIColor underPageBackgroundColor];
                            }
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}

- (void) getProfileImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    profileImageView.image = [UIImage imageWithData:data];
}

- (void) getBannerImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    bannerImageView.image = [UIImage imageWithData:data];
}

- (void)plotTimeline{
    
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
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json?user_id=%@&count=800",username]] parameters:nil];
                [twitterInfoRequest setAccount:twitterAccount];
                
                // Making the request
                
                @try {
                    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        
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
                            //NSLog(@"%@", TWData);
                            for (NSArray *tweetArray in TWData) {
                                //NSLog(@"%@", tweetArray);
                                //NSString *tweetGeolocation = [(NSDictionary *)tweetArray objectForKey:@"geo"];
                                //NSLog(@"%@", tweetGeolocation);
                                NSArray *userArray = [(NSDictionary *)tweetArray objectForKey:@"user"];
                                //NSLog(@"%@", userArray);
                                NSString *userLocation = [(NSDictionary *)userArray objectForKey:@"location"];
                                NSLog(@"%@", userLocation);
                                if(userLocation != nil && [userLocation length] > 0) {
                                    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                    [geocoder geocodeAddressString:userLocation completionHandler:^(NSArray* placemarks, NSError* error){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            // Update the UI
                                            for (CLPlacemark* aPlacemark in placemarks)
                                            {
                                                // Add an annotation
                                                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                                                point.coordinate = aPlacemark.location.coordinate;
                                                point.title = [(NSDictionary *)userArray objectForKey:@"name"];
                                                NSMutableString *userName = [[NSMutableString alloc]initWithString:@"@"];
                                                [userName appendString:[(NSDictionary *)userArray objectForKey:@"screen_name"]];
                                                point.subtitle = userName;
                                                [_mapView addAnnotation:point];
                                            }
                                        });
                                    }];
                                }
                                // Filter the preferred data
                            }
                        }
                    }];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.reason);
                }
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}

- (void)plotInteractions{
    
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
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/mentions_timeline.json?user_id=%@&count=800",username]] parameters:nil];
                [twitterInfoRequest setAccount:twitterAccount];
                
                // Making the request
                
                @try {
                    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        
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
                            //NSLog(@"%@", TWData);
                            for (NSArray *tweetArray in TWData) {
                                //NSLog(@"%@", tweetArray);
                                //NSString *tweetGeolocation = [(NSDictionary *)tweetArray objectForKey:@"geo"];
                                //NSLog(@"%@", tweetGeolocation);
                                NSArray *userArray = [(NSDictionary *)tweetArray objectForKey:@"user"];
                                //NSLog(@"%@", userArray);
                                NSString *userLocation = [(NSDictionary *)userArray objectForKey:@"location"];
                                NSLog(@"%@", userLocation);
                                if(userLocation != nil && [userLocation length] > 0) {
                                    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                    [geocoder geocodeAddressString:userLocation completionHandler:^(NSArray* placemarks, NSError* error){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            // Update the UI
                                            for (CLPlacemark* aPlacemark in placemarks)
                                            {
                                                // Add an annotation
                                                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                                                point.coordinate = aPlacemark.location.coordinate;
                                                point.title = [(NSDictionary *)userArray objectForKey:@"name"];
                                                NSMutableString *userName = [[NSMutableString alloc]initWithString:@"@"];
                                                [userName appendString:[(NSDictionary *)userArray objectForKey:@"screen_name"]];
                                                point.subtitle = userName;
                                                [_mapView addAnnotation:point];
                                            }
                                        });
                                    }];
                                }
                                // Filter the preferred data
                            }
                        }
                    }];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.reason);
                }
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}

@end
