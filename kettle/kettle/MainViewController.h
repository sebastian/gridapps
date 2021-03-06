//
//  MainViewController.h
//  kettle
//
//  Created by Sebastian Eide on 06/07/2012.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "FlipsideViewController.h"
#import <CoreLocation/CoreLocation.h>

@class GridMonitor;
@class NotificationViewController;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, CLLocationManagerDelegate>
{
  CLLocationManager *locationManager;
  UIInterfaceOrientation currentOrientation;
}

@property (strong, nonatomic) IBOutlet NotificationViewController *notificationViewController;
@property (nonatomic, retain) GridMonitor *monitor;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

// Happy
@property (weak, nonatomic) IBOutlet UIView *happyView;
@property (weak, nonatomic) IBOutlet UIImageView *happyImageViewPortrait;
@property (weak, nonatomic) IBOutlet UIImageView *happyImageViewLandscape;
@property (weak, nonatomic) IBOutlet UIImageView *happyAnimViewPortrait;
@property (weak, nonatomic) IBOutlet UIImageView *happyAnimViewLandscape;

// Sad
@property (weak, nonatomic) IBOutlet UIView *sadView;
@property (weak, nonatomic) IBOutlet UIImageView *sadImageViewPortrait;
@property (weak, nonatomic) IBOutlet UIImageView *sadImageViewLandscape;

- (IBAction)showInfo:(id)sender;
- (IBAction)pleaseAddAReminder:(UIButton *)button;

@end
