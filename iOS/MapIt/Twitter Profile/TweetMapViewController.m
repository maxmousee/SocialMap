//
//  TweetMapViewController.m
//  Twitter Profile
//
//  Created by Natan Facchin on 7/7/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import "TweetMapViewController.h"

#define FBHOMETOWN "fbHometown"
#define FBCURRENTLOCATION "fbCurrentLocation"

@interface TweetMapViewController ()

@end

@implementation TweetMapViewController

@synthesize username;
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
    //_theBannerView.frame = CGRectOffset(_theBannerView.frame, 0, 50);
    [socialMapView setShowsUserLocation:true];
    [socialMapView setDelegate:self];
    socialMapView.clusterSize = kDEFAULTCLUSTERSIZE;
    socialMapView.clusteringMethod = OCClusteringMethodGrid;
    socialMapView.clusteringEnabled = YES;
    [socialMapView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [socialMapView.layer setBorderWidth: 2.0];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activityIndicator];
    CGPoint center = self.view.center;
    center.y -= 60;
    self.activityIndicator.center = center;
    [self.activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    [self setUpGoogleAd];
    
    singleFingerTapAnnotation = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handleMapAnnotationTap:)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:@FBCURRENTLOCATION]) {
        [self plotFBFriendsCurrentLocationWithFQL];
    }
    if([defaults boolForKey:@FBHOMETOWN]) {
        [self plotFBFriendsHomeTownWithFQL];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpGoogleAd
{
    googleBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    CGRect googleBannerViewFrame = googleBannerView.frame;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    googleBannerViewFrame.origin.y = screenRect.size.height - googleBannerViewFrame.size.height;
    [googleBannerView setFrame:googleBannerViewFrame];
    
    // Specify the ad unit ID.
    googleBannerView.adUnitID = @"ca-app-pub-6181270546404452/2050401562";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    googleBannerView.rootViewController = self;
    [self.view addSubview:googleBannerView];
    
    // Initiate a generic request to load it with an ad.
    
    GADRequest *request = [GADRequest request];
    //request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, @"596325609d0e6da57543212613fd6f6c", nil];
    //request.testDevices = [NSArray arrayWithObjects:@"596325609d0e6da57543212613fd6f6c", nil];
    //request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
    [googleBannerView loadRequest:request];
}

- (void)handleMapAnnotationTap:(UITapGestureRecognizer *)recognizer {
    // if it's a MKAnnotationView
    if ([recognizer.view isKindOfClass:[MKAnnotationView class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *)recognizer.view;
        //NSLog(@"MKAnnotationView");
        
        // if it's a cluster
        if ([annotationView.annotation isKindOfClass:[OCAnnotation class]]) {
            NSMutableArray *usersNamesMA = [[NSMutableArray alloc]init];
            OCAnnotation *clusterAnnotation = (OCAnnotation *)annotationView.annotation;
            
            for (OCAnnotation *userAnnotation in clusterAnnotation.annotationsInCluster) {
                NSString *anUserName = userAnnotation.title;
                //NSLog(@"%@", anUserName);
                [usersNamesMA addObject:anUserName];
                
            }
            
            [usersNamesMA sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            CompleteListVC *clVC = [self.storyboard instantiateViewControllerWithIdentifier:@"usersStoryboard"];
            [clVC setUsersArray:[[NSArray alloc] initWithArray:usersNamesMA]];
            [self.navigationController pushViewController:clVC animated:YES];
        }
    }
}

-(void)dismissActivityIndicators {
    [self.activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
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
        [annotationView addGestureRecognizer:singleFingerTapAnnotation];
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
        annotationView.image = [UIImage imageNamed:@"regular.png"];
        
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

@end
