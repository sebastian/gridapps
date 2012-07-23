//
//  NotificationViewController.m
//  kettle
//
//  Created by Sebastian Probst Eide on 11.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "NotificationViewController.h"

#define TOP_MARGIN 0
#define TOP_BAR_TO_PRESERVE 115
#define SIDE_MARGIN 10
#define BUTTON_SIZE_DIFF 40
#define OVERDRAG 20.0

@interface NotificationViewController ()

@end

@implementation NotificationViewController

@synthesize notificationButton;
@synthesize windowShadeImage;
@synthesize notificationLabel;
@synthesize notificationHeaderLabel;

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  initialFrame = self.view.frame;
  pendingTapInNotification = NO;
  windowShadeHappy = [UIImage imageNamed:@"window-shade-green.png"];
  windowShadeSad = [UIImage imageNamed:@"window-shade-red.png"];;
  windowShadeIndifferent = [UIImage imageNamed:@"window-shade-orange.png"];;
  
  [self showUnknownStateNotificationWithTitle:@"Hi there!" andMessage:@"Checking if this is a good time for tea!"];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Methods for notification view.

- (void) showHappyNotificationWithTitle:(NSString *)title andMessage:(NSString *)message
{
  notificationHeaderLabel.text = title;
  notificationLabel.text = message;

  self.notificationButton.hidden = YES;
  
  // Scale the size of the view, since we do want to
  // show the notification button
  [UIView animateWithDuration:.2 animations:^{
    CGRect frame = self.view.frame;
    frame.size.height = initialFrame.size.height - BUTTON_SIZE_DIFF;
    self.view.frame = frame;
  }];
  
  self.windowShadeImage.image = windowShadeHappy;
  
  [self showAndHideNotificationsInATimelyFashion];
}


- (void) showSadNotificationWithTitle:(NSString *)title andMessage:(NSString *)message
{
  notificationHeaderLabel.text = title;
  notificationLabel.text = message;
  self.notificationButton.hidden = NO;
  
  [self enableButton];

  // Scale the size of the view, since we do want to
  // show the notification button
  [UIView animateWithDuration:.2 animations:^{
    CGRect frame = self.view.frame;
    frame.size.height = initialFrame.size.height;
    self.view.frame = frame;
  }];
  
  self.windowShadeImage.image = windowShadeSad;
  
  [self showAndHideNotificationsInATimelyFashion];
}

- (void) showUnknownStateNotificationWithTitle:(NSString *)title andMessage:(NSString *)message
{
  notificationHeaderLabel.text = title;
  notificationLabel.text = message;
  
  self.notificationButton.hidden = YES;
  
  // Scale the size of the view, since we do want to
  // show the notification button
  [UIView animateWithDuration:.2 animations:^{
    CGRect frame = self.view.frame;
    frame.size.height = initialFrame.size.height - BUTTON_SIZE_DIFF;
    self.view.frame = frame;
  }];
  
  self.windowShadeImage.image = windowShadeIndifferent;
  
  [self showAndHideNotificationsInATimelyFashion];
}


- (void) showAndHideNotificationsInATimelyFashion
{
  [self slideDown];
  double delayInSeconds = 5.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    if (! pendingTapInNotification) {
      [self slideUp];
    }
    pendingTapInNotification = NO;
  });
}

- (void) slideDown
{
  dispatch_async(dispatch_get_main_queue(), ^{
    CGRect insideRect = self.view.frame;
    CGFloat newY = TOP_MARGIN - OVERDRAG;
    CGFloat part = insideRect.origin.y + newY;
    insideRect.origin.y = newY;
    
    CGFloat slideTime = 0.5 * (part / insideRect.size.height);
    
    [UIView animateWithDuration:slideTime animations:^{
      self.view.frame = insideRect;
    } completion:^(BOOL completed) {
      notificationFrame = self.view.frame;
    }];
  });
}

- (void) slideUp 
{
  dispatch_async(dispatch_get_main_queue(), ^{
    CGRect outsideRect = self.view.frame;
    CGFloat newY = -outsideRect.size.height + TOP_BAR_TO_PRESERVE;
    CGFloat part = newY - outsideRect.origin.y;
    outsideRect.origin.y = newY;
    
    CGFloat slideTime = 0.5 * (part / outsideRect.size.height);
    
    [UIView animateWithDuration:slideTime animations:^{
      self.view.frame = outsideRect;
    } completion:^(BOOL completion) {
      notificationFrame = self.view.frame;
    }];
  });
}

- (void) slideUpABit
{
  dispatch_async(dispatch_get_main_queue(), ^{
    CGRect outsideRect = self.view.frame;
    outsideRect.origin.y = -OVERDRAG;
    
    [UIView animateWithDuration:.1 animations:^{
      self.view.frame = outsideRect;
    } completion:^(BOOL completion) {
      notificationFrame = self.view.frame;
    }];
  });
}

- (void) disableButton
{
  [notificationButton setTitle:@"... will do!" forState:UIControlStateNormal];
  notificationButton.enabled = NO;
}

- (void) enableButton
{
  [notificationButton setTitle:@"Send me a notification" forState:UIControlStateNormal];
  notificationButton.enabled = YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gesture interactions

- (IBAction)panAction:(UIPanGestureRecognizer *)panRecognizer
{
  pendingTapInNotification = YES;
  if (panRecognizer.state == UIGestureRecognizerStateBegan) {
    notificationFrame = self.view.frame;
    // Is the user dragging despite being at bottom?
    if (notificationFrame.origin.y == -OVERDRAG)
      overdragging = YES;
  }
  if (panRecognizer.state == UIGestureRecognizerStateEnded) {
    CGFloat originy = self.view.frame.origin.y;
    
    CGFloat distanceMoved = originy - notificationFrame.origin.y;
    
    // Check if the user has moved enough for us to complete the movement
    BOOL completeMovement = NO;
    CGFloat fractionOfHeight = self.view.frame.size.height * .1;
    if (abs(distanceMoved) > fractionOfHeight)
      completeMovement = YES;
  
    // Check if we should slide up completely, because the user
    // tugged in the blend at the end
    if (originy == 0.0 && overdragging) {
      // The user did an overdrag, slide all the way up
      [self slideUp];

    // Did the user just overdrag a little, and we want
    // it to slide back?
    } else if (-OVERDRAG < originy && originy <= 0.0) {
      [self slideUpABit];
      
    // Did the user start a movement, that we need to complete?
    } else if (completeMovement) {
      // Is it moving down or up?
      if (distanceMoved > 0.) {
        // Moving down
        [self slideDown];
      } else {
        // Moving up
        [self slideUp];
      }
    }
    overdragging = NO;
  }
  
  CGPoint point = [panRecognizer translationInView:self.view];

  CGRect newFrame = notificationFrame;
  newFrame.origin.y += point.y;
  CGFloat potentialNewY = newFrame.origin.y;
  
  // Do bounds checks
  CGFloat minHeight = (- newFrame.size.height + TOP_BAR_TO_PRESERVE);
  if (potentialNewY < minHeight)
    newFrame.origin.y = minHeight;
  
  if (potentialNewY > 0.0)
    newFrame.origin.y = 0;

  self.view.frame = newFrame;
}

- (IBAction)tappedInTheNotification:(UITapGestureRecognizer *)sender {
  pendingTapInNotification = YES;
}

@end
