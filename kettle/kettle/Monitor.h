//
//  Monitor.h
//  kettle
//
//  Created by Sebastian Eide on 22.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TeaError;

@interface Monitor : NSObject

- (BOOL)gridStatus:(TeaError **)error;

@end