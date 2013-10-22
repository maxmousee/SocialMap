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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
