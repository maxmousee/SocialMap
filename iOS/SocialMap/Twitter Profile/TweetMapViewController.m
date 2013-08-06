//
//  TweetMapViewController.m
//  Twitter Profile
//
//  Created by Natan Facchin on 7/7/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import "TweetMapViewController.h"

@interface TweetMapViewController ()

@end

@implementation TweetMapViewController

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
    [socialMapView setShowsUserLocation:true];
    [socialMapView setDelegate:self];
    [self plotFBFriendsWithFQL];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[self getFollowers];
        //[self plotFollowing];
        //[self plotInteractions];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
        });
    });
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)plotFollowing{
    
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
                                                [socialMapView addAnnotation:point];
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
                                                [socialMapView addAnnotation:point];
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

// FQL via Graph API
-(void)plotFBFriendsWithFQL {
    NSString* fql =
    @"{"
    @"'allfriends':'SELECT uid2 FROM friend WHERE uid1=me()',"
    @"'frienddetails':'SELECT uid, name, pic, hometown_location, current_location FROM user WHERE uid IN ( SELECT uid2 FROM friend WHERE uid1 = me() )',"
    @"}";
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:@{ @"q" : fql}
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if(error) {
                                  //[self printError:@"Error reading friends via FQL" error:error];
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OOPS" message:@"Something bad happened trying to reach Facebook :(" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                  [alert show];
                                  NSLog(@"%@", error);
                                  return;
                              }
                              //NSArray* friendIds = ((NSArray*)[result data])[0][@"fql_result_set"];
                              NSArray* friends = ((NSArray*)[result data])[1][@"fql_result_set"];
                              for (NSDictionary *userData in friends) {
                                  @try {
                                      //NSLog(@"%@", [userData objectForKey:@"name"]);
                                      NSDictionary *userLocationDict = [userData objectForKey:@"current_location"];
                                      //NSLog(@"%@", [userLocationDict objectForKey:@"city"]);
                                      //NSLog(@"%@", [userLocationDict objectForKey:@"latitude"]);
                                      //NSLog(@"%@", [userLocationDict objectForKey:@"longitude"]);
                                      // Add an annotation
                                      MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                                      double latitude = [[userLocationDict objectForKey:@"latitude"]doubleValue];
                                      double longitude = [[userLocationDict objectForKey:@"longitude"]doubleValue];
                                      point.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                                      point.title = [userData objectForKey:@"name"];
                                      [socialMapView addAnnotation:point];
                                  }
                                  @catch (NSException *exception) {
                                      NSLog(@"EXCEPTION %@", exception);
                                  }
                                  
                              }
                          }];
}

@end
