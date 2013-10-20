//
//  iPadMapViewController.m
//  MapIt
//
//  Created by Natan Facchin on 8/28/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import "iPadMapViewController.h"

@interface iPadMapViewController () <FBLoginViewDelegate, MKMapViewDelegate, UISplitViewControllerDelegate, RefreshMapViewDelegate>

@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@end

@implementation iPadMapViewController

@synthesize twitterUsername;
@synthesize activityIndicator;

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
    socialMapView.clusterSize = kDEFAULTCLUSTERSIZE;
    socialMapView.clusteringMethod = OCClusteringMethodGrid;
    socialMapView.clusteringEnabled = YES;
    [socialMapView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [socialMapView.layer setBorderWidth: 2.0];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:self.activityIndicator];
    CGPoint center = self.view.center;
    center.y -= 120;
    self.activityIndicator.center = center;
    [self.activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

- (void)refreshMapConfigs:(Configs *)newCFGs {
    //NSLog(@"refresh cfgs");
    //Make sure we're not setting up the same configurations.
    //if (_currentCFGs != newCFGs) {
        _currentCFGs = newCFGs;
        //Update the UI to reflect the new monster selected from the list.
    dispatch_queue_t myQueue = dispatch_queue_create("WaitQueue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshMap];
        });
    });
    //}
}

-(void)refreshMap {
    //NSLog(@"refresh map");
    //make sure to remove all overlays before draw it again
    [self.activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [socialMapView removeOverlays:socialMapView.overlays];
    [socialMapView removeAnnotations:socialMapView.annotations];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (FBSession.activeSession.isOpen)
    {
        if([defaults integerForKey:@"isFBCurrentLocation"] > 0) {
            [self plotFBFriendsHomeTownWithFQL];
        } else {
            [self plotFBFriendsCurrentLocationWithFQL];
        }
    }
    if([defaults boolForKey:@"twUserInteractions"]) {
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                [self plotInteractions];
            });
        });
    }
    if([defaults boolForKey:@"twTimeline"]) {
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            sleep(4);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                [self plotTimeline];
            });
        });
    }
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
                                //NSLog(@"%@", userLocation);
                                if(userLocation != nil && [userLocation length] > 0) {
                                    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                    [geocoder geocodeAddressString:userLocation completionHandler:^(NSArray* placemarks, NSError* error){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            // Update the UI
                                            for (CLPlacemark* aPlacemark in placemarks)
                                            {
                                                // Add an annotation
                                                OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc]initWithCoordinate:aPlacemark.location.coordinate];
                                                annotation.title = [(NSDictionary *)userArray objectForKey:@"name"];
                                                NSMutableString *userName = [[NSMutableString alloc]initWithString:@"@"];
                                                [userName appendString:[(NSDictionary *)userArray objectForKey:@"screen_name"]];
                                                annotation.subtitle = userName;
                                                annotation.groupTag = kTYPE2;
                                                [socialMapView addAnnotation:annotation];
                                            }
                                        });
                                    }];
                                }
                                // Filter the preferred data
                            }
                        }
                    }];
                    [self dismissActivityIndicators];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.reason);
                }
            }
        } else {
            [self dismissActivityIndicators];
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
                                //NSLog(@"%@", userLocation);
                                if(userLocation != nil && [userLocation length] > 0) {
                                    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                    [geocoder geocodeAddressString:userLocation completionHandler:^(NSArray* placemarks, NSError* error){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            // Update the UI
                                            for (CLPlacemark* aPlacemark in placemarks)
                                            {
                                                // Add an annotation
                                                OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc]initWithCoordinate:aPlacemark.location.coordinate];
                                                annotation.title = [(NSDictionary *)userArray objectForKey:@"name"];
                                                NSMutableString *userName = [[NSMutableString alloc]initWithString:@"@"];
                                                [userName appendString:[(NSDictionary *)userArray objectForKey:@"screen_name"]];
                                                annotation.subtitle = userName;
                                                annotation.groupTag = kTYPE2;
                                                [socialMapView addAnnotation:annotation];
                                            }
                                        });
                                    }];
                                }
                                // Filter the preferred data
                            }
                        }
                    }];
                    [self dismissActivityIndicators];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.reason);
                }
            }
        } else {
            NSLog(@"No access granted");
            [self dismissActivityIndicators];
        }
    }];
}

// FQL via Graph API
-(void)plotFBFriendsCurrentLocationWithFQL {
    NSLog(@"plotFBFriendsCurrentLocationWithFQL");
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
                                  [self dismissActivityIndicators];
                                  return;
                              }
                              
                              //NSArray* friendIds = ((NSArray*)[result data])[0][@"fql_result_set"];
                              NSArray* friends = ((NSArray*)[result data])[1][@"fql_result_set"];
                              [socialMapView removeOverlays:socialMapView.overlays];
                              
                              for (NSDictionary *userData in friends) {
                                  @try {
                                      //NSLog(@"%@", [userData objectForKey:@"name"]);
                                      NSDictionary *userLocationDict = [userData objectForKey:@"current_location"];
                                      //NSLog(@"%@", [userLocationDict objectForKey:@"city"]);
                                      //NSLog(@"%@", [userLocationDict objectForKey:@"latitude"]);
                                      //NSLog(@"%@", [userLocationDict objectForKey:@"longitude"]);
                                      // Add an annotation
                                      double latitude = [[userLocationDict objectForKey:@"latitude"]doubleValue];
                                      double longitude = [[userLocationDict objectForKey:@"longitude"]doubleValue];
                                      
                                      OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc]initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
                                      annotation.title = [userData objectForKey:@"name"];
                                      annotation.groupTag = kTYPE1;
                                      [socialMapView addAnnotation:annotation];
                                  }
                                  @catch (NSException *exception) {
                                      //NSLog(@"EXCEPTION %@", exception);
                                  }
                                  
                              }
                              [self dismissActivityIndicators];
                          }];
}

-(void)plotFBFriendsHomeTownWithFQL {
    NSLog(@"plotFBFriendsHomeTownWithFQL");
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
                                  [self dismissActivityIndicators];
                                  return;
                              }
                              
                              //NSArray* friendIds = ((NSArray*)[result data])[0][@"fql_result_set"];
                              NSArray* friends = ((NSArray*)[result data])[1][@"fql_result_set"];
                              [socialMapView removeOverlays:socialMapView.overlays];
                              
                              for (NSDictionary *userData in friends) {
                                  @try {
                                      //NSLog(@"%@", [userData objectForKey:@"name"]);
                                      NSDictionary *userLocationDict = [userData objectForKey:@"hometown_location"];
                                      //NSLog(@"%@", [userLocationDict objectForKey:@"city"]);
                                      //NSLog(@"%@", [userLocationDict objectForKey:@"latitude"]);
                                      //NSLog(@"%@", [userLocationDict objectForKey:@"longitude"]);
                                      // Add an annotation
                                      double latitude = [[userLocationDict objectForKey:@"latitude"]doubleValue];
                                      double longitude = [[userLocationDict objectForKey:@"longitude"]doubleValue];
                                      
                                      OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc]initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
                                      annotation.title = [userData objectForKey:@"name"];
                                      annotation.groupTag = kTYPE1;
                                      [socialMapView addAnnotation:annotation];
                                  }
                                  @catch (NSException *exception) {
                                      //NSLog(@"EXCEPTION %@", exception);
                                  }
                                  
                              }
                              [self dismissActivityIndicators];
                          }];
}

- (void)dismissActivityIndicators {
    [self.activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
}

// ==============================
#pragma mark - map delegate
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *annotationView;
    
    // if it's a cluster
    if ([annotation isKindOfClass:[OCAnnotation class]]) {
        
        OCAnnotation *clusterAnnotation = (OCAnnotation *)annotation;
        
        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"ClusterView"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ClusterView"];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        //calculate cluster region
        CLLocationDistance clusterRadius = socialMapView.region.span.longitudeDelta * socialMapView.clusterSize * 111000 / 2.0f; //static circle size of cluster
        //CLLocationDistance clusterRadius = mapView.region.span.longitudeDelta/log(mapView.region.span.longitudeDelta*mapView.region.span.longitudeDelta) * log(pow([clusterAnnotation.annotationsInCluster count], 4)) * mapView.clusterSize * 50000; //circle size based on number of annotations in cluster
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circle setTitle:@"background"];
        [socialMapView addOverlay:circle];
        
        MKCircle *circleLine = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circleLine setTitle:@"line"];
        [socialMapView addOverlay:circleLine];
        
        // set title and subtitle
        OCAnnotation *firstAnnotation = [clusterAnnotation.annotationsInCluster objectAtIndex:0];
        clusterAnnotation.title = [firstAnnotation title];
        clusterAnnotation.subtitle = [NSString stringWithFormat:@"and %d more...", [clusterAnnotation.annotationsInCluster count] - 1];
        
        // set its image
        annotationView.image = [UIImage imageNamed:@"regular.png"];
        
    }
    // If it's a single annotation
    else if([annotation isKindOfClass:[OCMapViewSampleHelpAnnotation class]]){
        OCMapViewSampleHelpAnnotation *singleAnnotation = (OCMapViewSampleHelpAnnotation *)annotation;
        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"singleAnnotationView"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:singleAnnotation reuseIdentifier:@"singleAnnotationView"];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        //singleAnnotation.title = singleAnnotation.groupTag;
    }
    // Error
    else{
        annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"errorAnnotationView"];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"errorAnnotationView"];
            annotationView.canShowCallout = NO;
            ((MKPinAnnotationView *)annotationView).pinColor = MKPinAnnotationColorRed;
        }
    }
    
    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    MKCircle *circle = overlay;
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
    
    if ([circle.title isEqualToString:@"background"])
    {
        circleView.fillColor = [UIColor blueColor];
        circleView.alpha = 0.25;
    }
    else if ([circle.title isEqualToString:@"helper"])
    {
        circleView.fillColor = [UIColor redColor];
        circleView.alpha = 0.25;
    }
    else
    {
        circleView.strokeColor = [UIColor blackColor];
        circleView.lineWidth = 0.5;
    }
    
    return circleView;
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated{
    [socialMapView removeOverlays:socialMapView.overlays];
    [socialMapView doClustering];
}

// ==============================

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
