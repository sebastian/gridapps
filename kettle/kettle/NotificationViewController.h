//
//  NotificationViewController.h
//  kettle
//
//  Created by Sebastian Probst Eide on 11.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController {
  CGRect notificationFrame;
  CGRect initialFrame;
  BOOL pendingTapInNotification;
}
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationHeaderLabel;
@property (weak, nonatomic) IBOutlet UIButton *notificationButton;

- (void) showHappyNotificationWithTitle:(NSString *)title andMessage:(NSString *)message;
- (void) showSadNotificationWithTitle:(NSString *)title andMessage:(NSString *)message;

@end
