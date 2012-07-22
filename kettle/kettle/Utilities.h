//
//  Utilities.h
//  kettle
//
//  Created by Sebastian Eide on 22.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject
{
  NSMutableDictionary *msgIds;
}

/**
 * Shows a UIAlertView in the main thread with a single button
 * with the title OK.
 *
 * @params 
 *   title: Title used in the alert
 *   message: The message body shown
 *   msgIdentity: The identity that is used to determine 
 *                if the alert has already been shown.
 *                If nil, the alert will be shown every time
 *                the method is called.
 */
+ (void) showAlert:(NSString *)title message:(NSString *)message msgIdentity:(NSString *)msgId;

@end
