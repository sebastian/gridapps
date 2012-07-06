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

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, CLLocationManagerDelegate> {
  CLLocationManager *locationManager;
}

@property (nonatomic, retain) GridMonitor *monitor;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (weak, nonatomic) IBOutlet UIView *happyView;
@property (weak, nonatomic) IBOutlet UIView *sadView;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;

- (IBAction)showInfo:(id)sender;
- (IBAction)pleaseAddAReminder:(id)sender;

@end
