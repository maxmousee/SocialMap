//
//  ProfileViewController.m
//  Twitter Profile
//
//  Created by Jeroen van Rijn on 05-02-13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import "ProfileViewController.h"
#import "TweetMapViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    
    [_mapView setShowsUserLocation:true];
    [_mapView setDelegate:self];
    _mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    _mapView.clusteringMethod = OCClusteringMethodGrid;
    _mapView.clusteringEnabled = YES;
    [_mapView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_mapView.layer setBorderWidth: 2.0];
    
    [self setUpGoogleAd];
    
    singleFingerTapAnnotation = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handleMapAnnotationTap:)];
    
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
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json?user_id=%@&count=200&exclude_replies=true",twitterAccount.username]] parameters:nil];
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
                                                NSMutableString *userName = [[NSMutableString alloc]initWithString:@"@"];
                                                [userName appendString:[(NSDictionary *)userArray objectForKey:@"screen_name"]];
                                                OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc]initWithCoordinate:aPlacemark.location.coordinate];
                                                annotation.title = [(NSDictionary *)userArray objectForKey:@"name"];
                                                annotation.subtitle = userName;
                                                annotation.groupTag = kTYPE1;
                                                [_mapView addAnnotation:annotation];
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
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/mentions_timeline.json?user_id=%@&count=200",twitterAccount.username]] parameters:nil];
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
                                                NSMutableString *userName = [[NSMutableString alloc]initWithString:@"@"];
                                                [userName appendString:[(NSDictionary *)userArray objectForKey:@"screen_name"]];
                                                OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc]initWithCoordinate:aPlacemark.location.coordinate];
                                                annotation.title = [(NSDictionary *)userArray objectForKey:@"name"];
                                                annotation.subtitle = userName;
                                                annotation.groupTag = kTYPE1;
                                                [_mapView addAnnotation:annotation];
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
        CLLocationDistance clusterRadius = _mapView.region.span.longitudeDelta * _mapView.clusterSize * 111000 / 2.0f; //static circle size of cluster
        //CLLocationDistance clusterRadius = mapView.region.span.longitudeDelta/log(mapView.region.span.longitudeDelta*mapView.region.span.longitudeDelta) * log(pow([clusterAnnotation.annotationsInCluster count], 4)) * mapView.clusterSize * 50000; //circle size based on number of annotations in cluster
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circle setTitle:@"background"];
        [_mapView addOverlay:circle];
        
        MKCircle *circleLine = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circleLine setTitle:@"line"];
        [_mapView addOverlay:circleLine];
        
        // set title and subtitle
        OCAnnotation *firstAnnotation = [clusterAnnotation.annotationsInCluster objectAtIndex:0];
        clusterAnnotation.title = [firstAnnotation subtitle];
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
        /*
        if ([singleAnnotation.groupTag isEqualToString:kTYPE1]) {
            annotationView.image = [UIImage imageNamed:@"map_pin_normal.png"];
        }
        else if([singleAnnotation.groupTag isEqualToString:kTYPE2]){
            annotationView.image = [UIImage imageNamed:@"map_pin_fav.png"];
        }
         */
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
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView doClustering];
}

// ==============================

@end
