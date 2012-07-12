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
  BOOL hasReportedFaultyConnection = NO;
  BOOL previousState = YES;
  BOOL firstRun = YES;
  while (monitorRunning) {
    // Get the state from the webserver
    NSURL *url = [NSURL URLWithString:@"http://home.elsmorian.com:8080/json"];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    NSError *jsonError;
    if (jsonData != nil) {
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];
      if (jsonError) {
        NSLog(@"ERROR: Failed at reading the JSON data");
        if (!hasReportedFaultyConnection) {
          hasReportedFaultyConnection = YES;
          [[[UIAlertView alloc] initWithTitle:@"Oh my" 
                                      message:@"Something seems to be terribly wrong at the moment. Maybe try again later?" 
                                     delegate:nil 
                            cancelButtonTitle:nil 
                            otherButtonTitles:@"Ok", nil] show];
        }
      } else {
        BOOL shouldMakeTea;
        if ([[json objectForKey:@"instruction"] isEqualToString:@"yes"]) {
          shouldMakeTea = YES;
        } else {
          shouldMakeTea = NO;
        }
        if (firstRun || previousState != shouldMakeTea) {
          dispatch_async(dispatch_get_main_queue(), ^{
            _callback(shouldMakeTea);
          });
        }
        firstRun = NO;
        previousState = shouldMakeTea;
      }
    } else {
      if (!hasReportedFaultyConnection) {
        hasReportedFaultyConnection = YES;
        [[[UIAlertView alloc] initWithTitle:@"What a shame" 
                                    message:@"It seems we cannot connect to the tea-server. Are you certain you are connected to the internet? Maybe try again later?" 
                                   delegate:nil 
                          cancelButtonTitle:nil 
                          otherButtonTitles:@"Ok", nil] show];
      }
    }
    sleep(1);
  }
}

- (void) startWithCallback:(MonitorCallback)callback
{
  _callback = callback;
  [self resumeMonitoring];
}

- (void) pauseMonitoring
{
  monitorRunning = NO;
}

- (void) resumeMonitoring
{
  if (!monitorRunning) {
    monitorRunning = YES;
    [self performSelectorInBackground:@selector(startMonitor) withObject:nil];    
  } else {
    NSLog(@"ERROR: tried starting the monitor again... view did load called more than exptected :(");
  }
}

@end
