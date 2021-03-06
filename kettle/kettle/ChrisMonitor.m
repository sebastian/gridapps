//
//  ChrisMonitor.m
//  kettle
//
//  Created by Sebastian Eide on 22.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "ChrisMonitor.h"
#import "TeaError.h"

@implementation ChrisMonitor

// http://home.elsmorian.com:8080/json
// {"freq": 4502323.0, "instruction": "yes"}
// To set the frequency: 
// http://home.elsmorian.com:8080/setfreq?freq=49.9

- (BOOL)gridStatus:(TeaError **)error
{  
  NSURL *url = [NSURL URLWithString:@"http://home.elsmorian.com:8080/json"];
  NSData *jsonData = [NSData dataWithContentsOfURL:url];
  NSError *jsonError;
  if (jsonData == nil) {
    *error = [TeaError errorWithTitle:@"What a shame" description:@"It seems we cannot connect to the tea-server. Are you certain you are connected to the internet? Maybe try again later?" identifier:@"NoInternet"];
    return NO;
  }
  
  NSDictionary *json = 
      [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];

  if (jsonError) {
    *error = [TeaError errorWithTitle:@"Oh my" description:@"Something seems to be terribly wrong at the moment. Maybe try again later?" identifier:@"CannotParseJson"];
    return NO;
  }
  
  if ([[json objectForKey:@"instruction"] isEqualToString:@"yes"])
    return YES;
  
  // Default case... No other case has worked...
  return NO;
}

@end
