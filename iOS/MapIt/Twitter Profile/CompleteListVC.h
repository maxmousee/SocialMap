//
//  CompleteListVC.h
//  MapIt
//
//  Created by Natan Facchin on 10/23/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompleteListVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *users;
}

- (void)setUsersArray:(NSArray *)theUsers;

@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@end
