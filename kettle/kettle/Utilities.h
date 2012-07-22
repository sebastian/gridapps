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

+ (id) getInstance;
+ (void) showAlert:(NSString *)title message:(NSString *)message msgIdentity:(NSString *)msgId;

@end
