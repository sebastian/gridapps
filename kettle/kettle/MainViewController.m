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

@implementation MainViewController
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

  self.happyImageViewLandscape.animationDuration = 5.;
  self.happyImageViewLandscape.animationRepeatCount = 0;
  self.happyImageViewPortrait.animationDuration = 5.;
  self.happyImageViewPortrait.animationRepeatCount = 0;
  
  self.happyView.backgroundColor = [UIColor clearColor];
  self.sadView.backgroundColor = [UIColor clearColor];
  
  [self.monitor startWithCallback:^(BOOL gridIsOK) {
    UIColor *backgroundColour;
    CGFloat happyAlpha = 1.;
    CGFloat sadAlpha = 1.;
    if (gridIsOK) {
      backgroundColour = [UIColor greenColor];
      sadAlpha = 0.;
      [self.happyImageViewLandscape startAnimating];
      [self.happyImageViewPortrait startAnimating];
      [notificationViewController showHappyNotificationWithTitle:@"Fantastic" andMessage:@"You can safely make your tea now! Enjoy it, and please do NOT add milk!"];
    } else {
      backgroundColour = [UIColor redColor];
      happyAlpha = 0.;
      [self.happyImageViewLandscape stopAnimating];
      [self.happyImageViewPortrait stopAnimating];
      [notificationViewController showSadNotificationWithTitle:@"Sorry" andMessage:@"The power grid is under load."];
    }
    
    [UIView animateWithDuration:1. animations:^{
      self.view.backgroundColor = backgroundColour;
      self.happyView.alpha = happyAlpha;
      self.sadView.alpha = sadAlpha;
    }];
  }];
  
  [self.view addSubview:notificationViewController.view];
}

- (void)viewDidUnload
{
  happyPhotosLandscape = nil;
  happyPhotosPortrait = nil;
  sadPhotoLandscape = nil;
  sadPhotoPortrait = nil;
  
  [self setHappyView:nil];
  [self setSadView:nil];
  [self setSadImageViewPortrait:nil];
  [self setHappyImageViewLandscape:nil];
  [self setSadImageViewLandscape:nil];
  [self setNotificationViewController:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [self loadImagesForOrientation:toInterfaceOrientation];
}

- (void)loadImagesForOrientation:(UIInterfaceOrientation)orientation
{
  NSLog(@"LoadImagesForOrientation");
  if (orientation == UIInterfaceOrientationPortrait ||
      orientation == UIInterfaceOrientationPortraitUpsideDown) {
    self.happyImageViewPortrait.hidden = NO;
    self.sadImageViewPortrait.hidden = NO;
    self.happyImageViewLandscape.hidden = YES;
    self.sadImageViewLandscape.hidden = YES;
  } else if (orientation == UIInterfaceOrientationLandscapeRight ||
             orientation == UIInterfaceOrientationLandscapeLeft) {
    self.happyImageViewPortrait.hidden = YES;
    self.sadImageViewPortrait.hidden = YES;
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
    NSString *photoName = [NSString stringWithFormat:@"%@-%@-%@.png", strDevice, orientation, state];
    return [UIImage imageNamed:photoName];
  };

  NSString *strOrientation;
  strOrientation = @"portrait";
  happyPhotosPortrait = [NSArray arrayWithObjects:
                 imageForState(@"1", strOrientation),
                 imageForState(@"2", strOrientation),
                 imageForState(@"3", strOrientation),
                 imageForState(@"4", strOrientation), nil];
  sadPhotoPortrait = imageForState(@"off", strOrientation);

  strOrientation = @"landscape";
  happyPhotosLandscape = [NSArray arrayWithObjects:
                          imageForState(@"1", strOrientation),
                          imageForState(@"2", strOrientation),
                          imageForState(@"3", strOrientation),
                          imageForState(@"4", strOrientation), nil];
  sadPhotoLandscape = imageForState(@"off", strOrientation);
  
  self.happyImageViewPortrait.animationImages = happyPhotosPortrait;
  self.sadImageViewPortrait.image = sadPhotoPortrait;
  self.happyImageViewLandscape.animationImages = happyPhotosLandscape;
  self.sadImageViewLandscape.image = sadPhotoLandscape;
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
  NSLog(@"Got a location update");
  [manager stopUpdatingLocation];
  
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    if (error) {
      // Notify the user that we coudln't reverse geolocate them...
      [[[UIAlertView alloc] initWithTitle:@"Warning"
                                 message:@"We don't know where you are. The power grid measurements we are using are only valid for the United Kingdom. If you are elsewhere, please disregard the advice given by this app"
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:@"Ok", nil] show];
      
    } else {
      CLPlacemark *placemark = [placemarks objectAtIndex:0];      
      NSString *country = [placemark country];
      if (![country isEqualToString:@"United Kingdom"]) {
        // Warn the user that the mesurements are not valid outside the UK.
        [[[UIAlertView alloc] initWithTitle:@"Warning" 
                                    message:@"You are outside the United Kingdom. The power grid measurements we are using are not valid for your location" 
                                   delegate:nil 
                          cancelButtonTitle:nil 
                          otherButtonTitles:@"Ok", nil] show];
      }
    }
  }];
}

@end
