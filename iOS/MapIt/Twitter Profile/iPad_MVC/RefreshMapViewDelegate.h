//
//  RefreshMapViewDelegate.h
//  MapIt
//
//  Created by Natan Facchin on 8/28/13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Configs;
@protocol RefreshMapViewDelegate <NSObject>

@required
- (void)refreshMapConfigs:(Configs *)newCFGs;

@end
