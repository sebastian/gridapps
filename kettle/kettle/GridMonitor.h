//
//  GridMonitor.h
//  kettle
//
//  Created by Sebastian Eide on 06/07/2012.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MonitorCallback)(BOOL);

@interface GridMonitor : NSObject 
{
  BOOL monitorRunning;
  MonitorCallback _callback;
}

- (void) startWithCallback:(MonitorCallback)callback;
- (void) pauseMonitoring;
- (void) resumeMonitoring;

@end
