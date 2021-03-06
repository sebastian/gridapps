//
//  AppDelegate.h
//  kettle
//
//  Created by Sebastian Eide on 06/07/2012.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;
@class GridMonitor;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
  GridMonitor *monitor;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainViewController *mainViewController;

@end