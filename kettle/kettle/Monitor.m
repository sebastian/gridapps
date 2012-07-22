//
//  Monitor.m
//  kettle
//
//  Created by Sebastian Eide on 22.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "Monitor.h"
#import "TeaError.h"

@implementation Monitor

- (BOOL)gridStatus:(TeaError **)error
{
  *error = [TeaError errorWithTitle:@"NOT ALLOWED" description:@"Using abstract class" identifier:nil];
  return NO;
}

@end
