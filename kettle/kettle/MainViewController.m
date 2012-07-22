//
//  MainViewController.m
//  kettle
//
//  Created by Sebastian Eide on 06/07/2012.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "MainViewController.h"
#import "GridMonitor.h"
#import "NotificationViewController.h"
#import "Utilities.h"

@implementation MainViewController
@synthesize happyAnimViewPortrait;
@synthesize happyAnimViewLandscape;
@synthesize sadImageViewPortrait, sadImageViewLandscape;
@synthesize happyImageViewLandscape, happyImageViewPortrait;
@synthesize happyView;
@synthesize sadView;

@synthesize notificationViewController;
@synthesize monitor;
@synthesize flipsidePopoverController;


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init and UIViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {        
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
  [self loadPhotos];
  [self loadImagesForOrientation:UIInterfaceOrientationPortrait];

  self.happyAnimViewLandscape.animationDuration = 5.;
  self.happyAnimViewLandscape.animationRepeatCount = 0;
  self.happyAnimViewPortrait.animationDuration = 5.;
  self.happyAnimViewPortrait.animationRepeatCount = 0;
  
  self.happyView.backgroundColor = [UIColor clearColor];
  self.sadView.backgroundColor = [UIColor clearColor];
  
  [self.monitor startWithCallback:^(BOOL gridIsOK) {
    CGFloat happyAlpha;
    if (gridIsOK) {
      happyAlpha = 1.0;
      [self.happyAnimViewLandscape startAnimating];
      [self.happyAnimViewPortrait startAnimating];
      [notificationViewController showHappyNotificationWithTitle:@"Great!" andMessage:@"Pop the kettle on, the grid is meeting demand!"];

    } else {
      happyAlpha = 0.0;
      [self.happyAnimViewLandscape stopAnimating];
      [self.happyAnimViewPortrait stopAnimating];
      [notificationViewController showSadNotificationWithTitle:@"Hold up!" andMessage:@" The grid is under demand, maybe wait a bit before boiling the kettle..."];        
    }
    [UIView animateWithDuration:1. animations:^{
      self.happyView.alpha = happyAlpha;
    }];
  }];
  
  [self.view addSubview:notificationViewController.view];
}

- (void)viewDidUnload
{
  [self setHappyView:nil];
  [self setSadView:nil];
  [self setSadImageViewPortrait:nil];
  [self setHappyImageViewLandscape:nil];
  [self setSadImageViewLandscape:nil];
  [self setNotificationViewController:nil];
  [self setHappyAnimViewPortrait:nil];
  [self setHappyAnimViewLandscape:nil];

  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [self loadImagesForOrientation:toInterfaceOrientation];
}

- (void)loadImagesForOrientation:(UIInterfaceOrientation)orientation
{
  if (orientation == UIInterfaceOrientationPortrait ||
      orientation == UIInterfaceOrientationPortraitUpsideDown) {
    self.happyAnimViewPortrait.hidden = NO;    
    self.happyImageViewPortrait.hidden = NO;
    self.sadImageViewPortrait.hidden = NO;
    self.happyAnimViewLandscape.hidden = YES;
    self.happyImageViewLandscape.hidden = YES;
    self.sadImageViewLandscape.hidden = YES;
  } else if (orientation == UIInterfaceOrientationLandscapeRight ||
             orientation == UIInterfaceOrientationLandscapeLeft) {
    self.happyAnimViewPortrait.hidden = YES; 
    self.happyImageViewPortrait.hidden = YES;
    self.sadImageViewPortrait.hidden = YES;
    self.happyAnimViewLandscape.hidden = NO;
    self.happyImageViewLandscape.hidden = NO;
    self.sadImageViewLandscape.hidden = NO;
  }
}

- (void) loadPhotos
{
  NSString *strDevice;
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    strDevice = @"ipad";
  }
  else {
    strDevice = @"iphone";
  }
  
  UIImage * (^imageForState)(NSString *, NSString *) = ^(NSString *state, NSString *orientation) {
    NSString *photoName = [NSString stringWithFormat:@"%@-%@-electric-%@.png", strDevice, orientation, state];
    return [UIImage imageNamed:photoName];
  };
  
  NSString *strOrientation;
  strOrientation = @"portrait";
  self.happyAnimViewPortrait.animationImages = [NSArray arrayWithObjects:
                 imageForState(@"anim1", strOrientation),
                 imageForState(@"anim2", strOrientation),
                 imageForState(@"anim3", strOrientation),
                 imageForState(@"anim4", strOrientation), nil];
  self.happyImageViewPortrait.image = imageForState(@"on", strOrientation);
  self.sadImageViewPortrait.image = imageForState(@"off", strOrientation);

  strOrientation = @"landscape";
  self.happyAnimViewLandscape.animationImages = [NSArray arrayWithObjects:
                          imageForState(@"anim1", strOrientation),
                          imageForState(@"anim2", strOrientation),
                          imageForState(@"anim3", strOrientation),
                          imageForState(@"anim4", strOrientation), nil];
  self.happyImageViewLandscape.image = imageForState(@"on", strOrientation);
  self.sadImageViewLandscape.image = imageForState(@"off", strOrientation);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
      return YES;
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (IBAction)showInfo:(UIButton *)infoButton
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
          [self.flipsidePopoverController presentPopoverFromRect:infoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Register for push notifications

- (IBAction)pleaseAddAReminder:(UIButton *)button
{
  [notificationViewController disableButton];
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CoreLocation - MKReverseGeocoder

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  [manager stopUpdatingLocation];
  
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    if (error) {

      [Utilities showAlert:@"Warning" message:@"We don't know where you are. The power grid measurements we are using are only valid for the United Kingdom. If you are elsewhere, please disregard the advice given by this app" msgIdentity:@"LackOfGeoWarning"];
            
    } else {
      CLPlacemark *placemark = [placemarks objectAtIndex:0];      
      NSString *country = [placemark country];
      if (![country isEqualToString:@"United Kingdom"]) {

        // Warn the user that the mesurements are not valid outside the UK.
        [Utilities showAlert:@"Warning" message:@"You are outside the United Kingdom. The power grid measurements we are using are not valid for your location" msgIdentity:@"OutsideUKWarning"];

      }
    }
  }];
}

@end
