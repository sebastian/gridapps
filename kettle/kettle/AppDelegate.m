//
//  AppDelegate.m
//  kettle
//
//  Created by Sebastian Eide on 06/07/2012.
//  Copyright (c) 2012 Kle.io. All rights reserved.
//

#import "AppDelegate.h"
#import "AVFoundation/AVFoundation.h"
#import "MainViewController.h"
#import "GridMonitor.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  // Only iPhone like devices support the translucent style.
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
  }

  monitor = [[GridMonitor alloc] init];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil];
  } else {
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPad" bundle:nil];
  }
  self.mainViewController.monitor = monitor;
  self.window.rootViewController = self.mainViewController;
    
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  switch (application.applicationState) {
    case UIApplicationStateActive:
      // We only want the sound to play, if the application was active at the time
      // of receiving the notification.
      [self playSoundNamed:@"shortKettle.caf"];    
      break;

    default:
      break;
  }
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
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
  NSURL *url = [NSURL URLWithString:@"http://home.elsmorian.com:8081/requestnotify"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];

  NSString *bodyContent = [NSString stringWithFormat:@"token=%@", [self convertTokenToDeviceID:devToken]];
  [request setHTTPBody:[bodyContent dataUsingEncoding:NSUTF8StringEncoding]];
  
  NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
  [connection start];
}

- (NSString *)convertTokenToDeviceID:(NSData *)token
{
  NSMutableString *deviceID = [NSMutableString string];
  
  // iterate through the bytes and convert to hex
  unsigned char *ptr = (unsigned char *)[token bytes];
  
  for (NSInteger i=0; i < 32; ++i) {
    [deviceID appendString:[NSString stringWithFormat:@"%02x", ptr[i]]];
  }
  return deviceID;
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
  NSLog(@"Error in registration. Error: %@", err);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sending a notification request to the server and handling NSURLRequestDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  // Don't expect a response.
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
  // Don't expect data.
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
  //  NSString *responseText = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
  //  // Do anything you want with it 
  //  [responseText release];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Misc

- (void) playSoundNamed:(NSString *)name {
  NSString * path;
  AVAudioPlayer * snd;
  NSError * err;
  
  path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSURL * url = [NSURL fileURLWithPath:path];
    snd = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (!snd) {
      NSLog(@"Sound named '%@' had error %@", name, [err localizedDescription]);
    } else {
      [snd prepareToPlay];
      dispatch_queue_t soundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
      dispatch_async(soundQueue, ^{
        [snd play];
        sleep(5);
      });
    }
  } else {
    NSLog(@"Sound file '%@' doesn't exist at '%@'", name, path);
  }
}
@end
