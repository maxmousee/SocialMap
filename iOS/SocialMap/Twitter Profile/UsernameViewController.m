//
//  UsernameViewController.m
//  Twitter Profile
//

#import "UsernameViewController.h"
#import "ProfileViewController.h"

@interface UsernameViewController () <FBLoginViewDelegate>

@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

- (void)fillTextBoxAndDismiss:(NSString *)text;

- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error;

@end

@implementation UsernameViewController

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
    [usernameTextfield setText:@"Loading Twitter Stuff..."];
    [_showMapButton setEnabled:NO];
    [_showTwitterInfoButton setEnabled:NO];
    
    FBLoginView *loginview = [[FBLoginView alloc] init];
    loginview.readPermissions = @[@"basic_info",
                                  @"user_location",
                                  @"user_location",
                                  @"friends_location",
                                  @"friends_hometown",
                                  @"friends_about_me"];
    
    //loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    CGRect loginViewFrame = _showMapButton.frame;
    loginViewFrame.origin.y += 50;
    //loginViewFrame.origin.y += 105;
    //loginViewFrame.origin.x += 65;
    loginview.frame = loginViewFrame;
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    
    //[loginview sizeToFit];
    
    [self getTwitterInfo];
    //[self requestFriendsWithFQL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ProfileViewController *profileViewController = [segue destinationViewController];
    [profileViewController setUsername:usernameTextfield.text];
}

- (void) getTwitterInfo
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
                NSMutableString *twitterUsername = [[NSMutableString alloc]initWithString:@"@"];
                [twitterUsername appendString:twitterAccount.username];
                [usernameTextfield setText:twitterUsername];
                [_showMapButton setEnabled:YES];
                [_showTwitterInfoButton setEnabled:YES];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
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

#pragma mark UI handlers

- (IBAction)pickFriendsButtonClick:(id)sender {
    // FBSample logic
    // if the session is open, then load the data for our view controller
    fbUsers = [[NSMutableArray alloc]init];
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              [self pickFriendsButtonClick:sender];
                                          }
                                      }];
        return;
    }
    
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        [fbUsers addObject:user];
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    //self.selectedFriendsView.text = text;
    NSLog(@"%@", text);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<Cancelled>"];
}

// FQL via Graph API
-(void)requestFriendsWithFQL {
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
                                      NSLog(@"%@", [userData objectForKey:@"name"]);
                                      NSDictionary *userLocationDict = [userData objectForKey:@"current_location"];
                                      NSLog(@"%@", [userLocationDict objectForKey:@"city"]);
                                      NSLog(@"%@", [userLocationDict objectForKey:@"latitude"]);
                                      NSLog(@"%@", [userLocationDict objectForKey:@"longitude"]);
                                  }
                                  @catch (NSException *exception) {
                                      NSLog(@"EXCEPTION %@", exception);
                                  }
                                  
                              }
                          }];
}

#pragma mark -

@end
