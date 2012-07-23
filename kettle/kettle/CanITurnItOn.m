//
//  CanITurnItOn.m
//  kettle
//
//  Created by Sebastian Eide on 22.07.12.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "CanITurnItOn.h"
#import "TeaError.h"

@implementation CanITurnItOn

// http://caniturniton.com/api/json
// Sample output:
//  { "decision": { "frequency": 49.976, "recommendation": "No" } }

- (BOOL)gridStatus:(TeaError **)error
{
  NSURL *url = [NSURL URLWithString:@"http://caniturniton.com/api/json"];
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
  
  NSDictionary *decision = [json objectForKey:@"decision"];
  double frequency = [[decision objectForKey:@"frequency"] doubleValue];
  
  if (frequency >= 50.)
    return YES;
  
  // Default case... No other case has worked...
  return NO;
}


@end
