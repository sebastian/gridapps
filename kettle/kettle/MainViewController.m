//
//  MainViewController.m
//  kettle
//
//  Created by Sebastian Eide on 06/07/2012.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "MainViewController.h"
#import "GridMonitor.h"

@implementation MainViewController

@synthesize monitor = _monitor;
@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize happyView = _happyView;
@synthesize sadView = _sadView;
@synthesize reminderButton = _reminderButton;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.happyView.backgroundColor = [UIColor clearColor];
    self.sadView.backgroundColor = [UIColor clearColor];
    
    //  Setup geolocation
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [locationManager startUpdatingLocation];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.monitor startWithCallback:^(BOOL gridIsOK) {
    UIColor *backgroundColour;
    CGFloat happyAlpha = 1.;
    CGFloat sadAlpha = 1.;
    if (gridIsOK) {
      backgroundColour = [UIColor greenColor];
      sadAlpha = 0.;
    } else {
      backgroundColour = [UIColor redColor];
      happyAlpha = 0.;
    }
    [UIView animateWithDuration:1. animations:^{
      self.view.backgroundColor = backgroundColour;
      self.happyView.alpha = happyAlpha;
      self.sadView.alpha = sadAlpha;
    }];
  }];
  NSLog(@"view did load");
}

- (void)viewDidUnload
{
  [self setHappyView:nil];
  [self setSadView:nil];
  [self setReminderButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
      return YES;
  }
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        if (!self.flipsidePopoverController) {
            FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (IBAction)pleaseAddAReminder:(id)sender {
}

#pragma mark CoreLocation - MKReverseGeocoder

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  NSLog(@"Got a location update");
  [manager stopUpdatingLocation];
  
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    if (error) {
      // Notify the user that we coudln't reverse geolocate them...
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" 
                                                          message:@"We don't know where you are. The power grid measurements we are using are only valid for the United Kingdom. If you are elsewhere, please disregard the advice given by this app" 
                                                         delegate:nil 
                                                cancelButtonTitle:nil 
                                                otherButtonTitles:@"Ok", nil];
      [alertView show];
      
    } else {
      CLPlacemark *placemark = [placemarks objectAtIndex:0];      
      NSString *country = [placemark country];
      if (![country isEqualToString:@"United Kingdom"]) {
        // Warn the user that the mesurements are not valid outside the UK.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" 
                                   message:@"You are outside the United Kingdom. The power grid measurements we are using are not valid for your location" 
                                  delegate:nil 
                         cancelButtonTitle:nil 
                         otherButtonTitles:@"Ok", nil];
        [alertView show];
      }
    }
  }];
}

@end
