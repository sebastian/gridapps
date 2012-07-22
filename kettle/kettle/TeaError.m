//
//  TeaError.m
//  kettle
//
//  Created by Sebastian Eide on 22.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "TeaError.h"

@implementation TeaError

@synthesize title = _title;
@synthesize description = _description;
@synthesize identifier = _identifier;

- (id) initWithTitle:(NSString *)title description:(NSString *)description identifier:(NSString *)identifier
{
  self = [super init];
  if (self) {
    _title = title;
    _description = description;
    _identifier = identifier;
  }
  return self;
}

+ (id) errorWithTitle:(NSString *)title description:(NSString *)description identifier:(NSString *)identifier
{
  return [[TeaError alloc] initWithTitle:title description:description identifier:identifier];
}

@end
