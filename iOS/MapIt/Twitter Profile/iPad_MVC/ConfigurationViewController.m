//
//  ConfigurationViewController.m
//  MapIt
//
//  Created by Natan Facchin on 8/28/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import "ConfigurationViewController.h"

@interface ConfigurationViewController () <FBLoginViewDelegate>

@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

- (void)fillTextBoxAndDismiss:(NSString *)text;

- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error;

@end

@implementation ConfigurationViewController

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
    [self setFacebookLoginButton];
    
    _twitterTimelineOnSwitch.onTintColor = [UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1];
    _twitterInteractionsOnSwitch.onTintColor = [UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int isTwInteractionsEnabled = [defaults integerForKey:@"twUserInteractions"];
    if(isTwInteractionsEnabled > 0) [_twitterTimelineOnSwitch setOn:YES];
    else [_twitterTimelineOnSwitch setOn:NO];
    
    int isTwTimelineEnabled = [defaults integerForKey:@"twTimeline"];
    if(isTwTimelineEnabled > 0) [_twitterTimelineOnSwitch setOn:YES];
    else [_twitterTimelineOnSwitch setOn:NO];
    _currentConfigs = [Configs updateCFG:[_twitterTimelineOnSwitch isOn]:[_twitterInteractionsOnSwitch isOn]:loginview];
    if (_delegate) {
        [_delegate refreshMapConfigs:_currentConfigs];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setFacebookLoginButton {
    loginview = [[FBLoginView alloc] init];
    loginview.readPermissions = @[@"basic_info",
                                  @"user_location",
                                  @"friends_location",
                                  @"friends_hometown"];
    
    loginview.delegate = self;
    
    [loginview sizeToFit];
    
    CGRect loginViewFrame = loginview.frame;
    loginViewFrame.origin.x += 80;
    loginViewFrame.origin.y += 140;
    loginview.frame = loginViewFrame;
    
    [self.view addSubview:loginview];
}

// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertTitle = @"Error";
        // For simplicity, we will use any error message provided by the SDK,
        // but you may consider inspecting the fberrorShouldNotifyUser or
        // fberrorCategory to provide better recourse to users. See the Scrumptious
        // sample for more examples on error handling.
        if (error.fberrorUserMessage) {
            alertMsg = error.fberrorUserMessage;
        } else {
            alertMsg = @"Operation failed due to a connection problem, retry later.";
        }
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.", message];
        NSString *postId = [resultDict valueForKey:@"id"];
        if (!postId) {
            postId = [resultDict valueForKey:@"postId"];
        }
        if (postId) {
            alertMsg = [NSString stringWithFormat:@"%@\nPost ID: %@", alertMsg, postId];
        }
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    //self.selectedFriendsView.text = text;
    NSLog(@"%@", text);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<Cancelled>"];
}

- (IBAction)savePreferencesReloadMap:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[_twitterInteractionsOnSwitch isOn] forKey:@"twUserInteractions"];
    [defaults setInteger:[_twitterTimelineOnSwitch isOn] forKey:@"twTimeline"];
    [defaults synchronize];
    if (_currentConfigs.showTwTimeline != [_twitterTimelineOnSwitch isOn]) {
        _currentConfigs = [Configs updateCFG:[_twitterTimelineOnSwitch isOn]:[_twitterInteractionsOnSwitch isOn]:loginview];
    }
    if(_currentConfigs.showTwInteractions != [_twitterInteractionsOnSwitch isOn]) {
        _currentConfigs = [Configs updateCFG:[_twitterTimelineOnSwitch isOn]:[_twitterInteractionsOnSwitch isOn]:loginview];
    }
    if(_currentConfigs.loginview != loginview) {
        _currentConfigs = [Configs updateCFG:[_twitterTimelineOnSwitch isOn]:[_twitterInteractionsOnSwitch isOn]:loginview];
    }
    if (_delegate) {
        [_delegate refreshMapConfigs:_currentConfigs];
    }
}

@end
