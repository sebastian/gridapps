//
//  Utilities.m
//  kettle
//
//  Created by Sebastian Eide on 22.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

- (id) init
{
  self = [super init];
  if (self)
    msgIds = [NSMutableDictionary dictionary];
  return self;
}

static Utilities *utility;
+ (id) getInstance
{
  if (utility == nil)
    utility = [[Utilities alloc] init];
  return utility;
}

- (BOOL) shouldShowAlertForId:(NSString *)msgId
{
  if (msgId == nil)
    return YES;
  if (![msgIds objectForKey:msgId]) {
    [msgIds setObject:msgId forKey:msgId];
    return YES;
  }
  return NO;
}

+ (void) showAlert:(NSString *)title message:(NSString *)message msgIdentity:(NSString *)msgId
{
  Utilities *u = [Utilities getInstance];
  if ([u shouldShowAlertForId:msgId]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [[[UIAlertView alloc] initWithTitle:title 
                                  message:message
                                 delegate:nil 
                        cancelButtonTitle:nil 
                        otherButtonTitles:@"Ok", nil] show];
    });
  }
}

@end
