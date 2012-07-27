//
//  GridMonitor.m
//  kettle
//
//  Created by Sebastian Eide on 06/07/2012.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "GridMonitor.h"
#import "Utilities.h"
#import "TeaError.h"

#import "Monitor.h"
#import "ChrisMonitor.h"
#import "CanITurnItOn.h"

@implementation GridMonitor

typedef enum {
  GridGood = 1,
  GridBad = 2,
  DoNotKnow = 3,
} MonitorCheck;


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

- (MonitorCheck) checkMonitors 
{
  NSArray *monitors = 
      [NSArray arrayWithObjects:
          [[ChrisMonitor alloc] init],
          [[CanITurnItOn alloc] init],
            nil];
  
  __block TeaError *error;
  __block BOOL returnOK;
  [monitors enumerateObjectsUsingBlock:^(Monitor *monitor, NSUInteger idx, BOOL *stop) {
    BOOL result = [monitor gridStatus:&error];
    if (error == nil) {
      *stop = YES;
      returnOK = result;
    }
  }];
  
  if (error) {
    [Utilities showAlert:[error title] message:[error description] msgIdentity:[error identifier]];
    return DoNotKnow;
  }

  if (returnOK)
    return GridGood;
  else
    return GridBad;
}

- (void) startMonitor
{
  BOOL previousState = YES;
  BOOL firstRun = YES;
  BOOL goodRun = YES;
  
  while (monitorRunning) {
    // We anticipate that this will successful at
    // determining the grid state
    goodRun = YES;
    
    MonitorCheck result = [self checkMonitors];
    
    BOOL currentGridState = previousState;
    switch (result) {
      case GridGood:
        currentGridState = YES;
        break;
        
      case GridBad:
        currentGridState = NO;
        break;
        
      case DoNotKnow:
        // We have no idea...
        goodRun = NO;
        break;
        
      default:
        break;
    }
    if (goodRun && (firstRun || previousState != currentGridState)) {
      dispatch_async(dispatch_get_main_queue(), ^{
        _callback(currentGridState);
      });
      firstRun = NO;
      previousState = currentGridState;
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
