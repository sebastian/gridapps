//
//  AppDelegate.m
//  kettle
//
//  Created by Sebastian Eide on 06/07/2012.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"
#import "GridMonitor.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  monitor = [[GridMonitor alloc] init];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil];
  } else {
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPad" bundle:nil];
  }
  self.mainViewController.monitor = monitor;
  self.window.rootViewController = self.mainViewController;
  
  // Did we wake up with a notification?
  UILocalNotification *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
  if (remoteNotification) {
    application.applicationIconBadgeNumber = 0;
    NSLog(@"Got launched because of a notification");
    // Can we do something clever here?
    
    // Did we get this notification while the app was closed?
    switch (application.applicationState) {
      case UIApplicationStateActive:
        NSLog(@"Got a message while already active, should we play a sound?");
        break;
        
      case UIApplicationStateBackground:
        NSLog(@"Application was in background, should we play sound?");
        break;
        
      case UIApplicationStateInactive:
        NSLog(@"The application was inactive. Presumably the sound has already been played?");
        break;
        
      default:
        break;
    }
  }
  
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  [monitor pauseMonitoring];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  [monitor resumeMonitoring];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [monitor pauseMonitoring];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notification registration

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
  const void *devTokenBytes = [devToken bytes];
  
  NSURL *url = [NSURL URLWithString:@"http://home.elsmorian.com:8080/notificationsubscribers"];
  NSMutableURLRequest *request = [NSURLRequest requestWithURL:url];
  [request setHTTPBody:[NSData dataWithBytes:devTokenBytes length:[devToken length]]];
  NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
  [connection start];
  
  NSLog(@"Has sent of registration asynchronously.");
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
  NSLog(@"Error in registration. Error: %@", err);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sending a notification request to the server and handling NSURLRequestDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  // Don't expect a response.
  NSLog(@"ERROR: Received a response on URLRequest, but hadn't expected one");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
  // Don't expect data.
  NSLog(@"ERROR: Received data, but hadn't expected any");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                              message:[error localizedDescription]
                             delegate:nil
                    cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                    otherButtonTitles:nil] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  // Don't want to deal with this...
  // Ok...
  NSLog(@"ERROR connection finished loading... don't want to deal with it...");
  //  NSString *responseText = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];  
  //  // Do anything you want with it 
  //  [responseText release];
}

@end
