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
    [socialMapView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [socialMapView.layer setBorderWidth: 2.0];
    [self plotFBFriendsWithFQL];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
