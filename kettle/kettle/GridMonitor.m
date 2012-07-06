//
//  GridMonitor.m
//  kettle
//
//  Created by Sebastian Eide on 06/07/2012.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "GridMonitor.h"

@implementation GridMonitor

#pragma mark - Init

- (id) init 
{
  self = [super init];
  if (self) {
    monitorRunning = NO;
  }
  return self;
}

#pragma mark - Monitoring


// http://home.elsmorian.com:8080/json
// {"freq": 4502323.0, "instruction": "yes"}
// To set the frequency: 
// http://home.elsmorian.com:8080/setfreq?freq=49.9

- (void) startMonitor
{
  BOOL state = NO;
  while (monitorRunning) {
    state = !state;
    dispatch_async(dispatch_get_main_queue(), ^{
      _callback(state);
    });
    sleep(10);
  }
}

- (void) startWithCallback:(MonitorCallback)callback
{
  _callback = callback;
  if (!monitorRunning) {
    monitorRunning = YES;
    [self performSelectorInBackground:@selector(startMonitor) withObject:nil];    
  } else {
    NSLog(@"ERROR: tried starting the monitor again... view did load called more than exptected :(");
  }
}

@end
