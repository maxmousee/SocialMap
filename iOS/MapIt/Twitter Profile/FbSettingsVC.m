//
//  FbSettingsVC.m
//  MapIt
//
//  Created by Natan Facchin on 10/22/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import "FbSettingsVC.h"

@interface FbSettingsVC ()

@end

@implementation FbSettingsVC

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
	// Do any additional setup after loading the view.
    
    _currentLocationSwitch.onTintColor = [UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1];
    _hometownSwitch.onTintColor = [UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fbCurrentLocation = [defaults boolForKey:@FBCURRENTLOCATION];
    BOOL fbHometown = [defaults boolForKey:@FBHOMETOWN];
    
    if(fbCurrentLocation || fbHometown) {
        [_currentLocationSwitch setOn:fbCurrentLocation animated:YES];
        [_hometownSwitch setOn:fbHometown animated:YES];
    } else {
        [_currentLocationSwitch setOn:YES animated:YES];
        [_hometownSwitch setOn:NO animated:YES];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [self loadUserProfile];
}

- (void)loadUserProfile
{
    [FBRequestConnection startWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObject:@"id,name" forKey:@"fields"] HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(error) {
            //[self printError:@"Error reading friends via FQL" error:error];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OOPS" message:@"Something bad happened trying to reach Facebook :(" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSLog(@"%@", error);
            return;
        }
        @try {
            NSDictionary* myInfo = ((NSDictionary*)result);
            NSLog(@"%@", myInfo);
            NSString *userName = [myInfo objectForKey:@"name"];
            [_usrnameLabel setText:userName];
            [self loadUsrProfilePic:[myInfo objectForKey:@"id"]];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        @finally {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        }
    }];
}

- (void)loadUsrProfilePic:(NSString *)profileId
{
    [_userImage.layer setBorderWidth:4.0f];
    [_userImage.layer setBorderColor:[[UIColor grayColor] CGColor]];
    
    [_userImage.layer setShadowRadius:3.0];
    [_userImage.layer setShadowOpacity:0.5];
    [_userImage.layer setShadowOffset:CGSizeMake(1.0, 0.0)];
    [_userImage.layer setShadowColor:[[UIColor blackColor] CGColor]];
    
    [_userImage.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [_userImage.layer setBorderWidth: 2.0];
    
    [_userImage setProfileID:profileId];
    [_userImage setPictureCropping:FBProfilePictureCroppingSquare];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"UserInteractions enabled %d", [_interactionsSwitch isOn]);
    //NSLog(@"Timeline enabled %d", [_timelineSwitch isOn]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[_currentLocationSwitch isOn] forKey:@FBCURRENTLOCATION];
    [defaults setBool:[_hometownSwitch isOn] forKey:@FBHOMETOWN];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
