//
//  NotificationViewController.m
//  kettle
//
//  Created by Sebastian Probst Eide on 11.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "NotificationViewController.h"

#define TOP_MARGIN 0
#define TOP_BAR_TO_PRESERVE 5
#define SIDE_MARGIN 10

@interface NotificationViewController ()

@end

@implementation NotificationViewController

@synthesize notificationButton;
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

  self.view.backgroundColor = [UIColor greenColor];
  self.notificationButton.hidden = YES;
  
  // Scale the size of the view, since we do want to
  // show the notification button
  [UIView animateWithDuration:.2 animations:^{
    CGRect frame = self.view.frame;
    frame.size.height = initialFrame.size.height - 40;
    self.view.frame = frame;
  }];
  
  [self showAndHideNotificationsInATimelyFashion];
}


- (void) showSadNotificationWithTitle:(NSString *)title andMessage:(NSString *)message
{
  notificationHeaderLabel.text = title;
  notificationLabel.text = message;
  self.view.backgroundColor = [UIColor redColor];
  self.notificationButton.hidden = NO;

  // Scale the size of the view, since we do want to
  // show the notification button
  [UIView animateWithDuration:.2 animations:^{
    CGRect frame = self.view.frame;
    frame.size.height = initialFrame.size.height;
    self.view.frame = frame;
  }];
  
  [self showAndHideNotificationsInATimelyFashion];
}

- (void) showAndHideNotificationsInATimelyFashion
{
  CGRect insideRect = self.view.frame;
  insideRect.origin.y = TOP_MARGIN;

  CGRect outsideRect = insideRect;
  outsideRect.origin.y = -outsideRect.size.height + TOP_BAR_TO_PRESERVE;
  
  [UIView animateWithDuration:.5 animations:^{
    self.view.frame = insideRect;
  } completion:^(BOOL completed) {
    notificationFrame = self.view.frame;
    
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      if (pendingTapInNotification) {
        pendingTapInNotification = NO;
      } else {
        [UIView animateWithDuration:.5 animations:^{
          self.view.frame = outsideRect;
        } completion:^(BOOL completion) {
          notificationFrame = self.view.frame;
        }];
      }
    });
  }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gesture interactions

- (IBAction)panAction:(UIPanGestureRecognizer *)panRecognizer
{
  if (panRecognizer.state == UIGestureRecognizerStateBegan) {
    notificationFrame = self.view.frame;
  }
  
  CGPoint point = [panRecognizer translationInView:self.view];

  CGRect newFrame = notificationFrame;
  newFrame.origin.y += point.y;
  
  // Do bounds checks
  CGFloat minHeight = (- newFrame.size.height + TOP_BAR_TO_PRESERVE);
  if (newFrame.origin.y < minHeight)
    newFrame.origin.y = minHeight;

  if (newFrame.origin.y > 0)
    newFrame.origin.y = 0;
  
  self.view.frame = newFrame;
}

- (IBAction)tappedInTheNotification:(UITapGestureRecognizer *)sender {
  pendingTapInNotification = YES;
}

@end
