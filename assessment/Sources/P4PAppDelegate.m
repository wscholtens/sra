//
//  P4PAppDelegate.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/20/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PAppDelegate.h"
#import "P4PViewController.h"
#import "P4PConnectionController.h"
#import "P4PDatabaseController.h"

@implementation P4PAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.hasAlert = NO;
    [[P4PDatabaseController sharedDatabaseController] purge];
    return YES;
}

- (void) updateSettings {
    self.originalBrightness = [UIScreen mainScreen].brightness;
    
    if(self.currentBrightness){
        [[UIScreen mainScreen] setBrightness:self.currentBrightness];
    } else {
        self.currentBrightness = self.originalBrightness;
    }
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    if (![settings boolForKey:@"hasLaunchedBefore"]) {
        [settings setBool:YES forKey:@"hasLaunchedBefore"];
        
        if(![settings valueForKey:@"history_preference"]){
            [settings setInteger:5 forKey:@"history_preference"];
        }
    }
    [self updateCredentials];     
}

- (void) setOriginalBrightness:(float)originalBrightness {
    _originalBrightness = originalBrightness;
}

- (void) setCurrentBrightness:(float)currentBrightness {
    _currentBrightness = currentBrightness;
}

- (void) updateCredentials {
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings synchronize];
    
    BOOL isMultiUserApp = [settings boolForKey:@"multiuser_preference"];
    
    NSString * newUsername;
    NSString * newPassword;
    if(isMultiUserApp){
        newUsername = nil;
        newPassword = nil;
    } else {
        newUsername = [settings stringForKey:@"username_preference"];
        newPassword = [settings stringForKey:@"password_preference"];
    }
    
    NSURL * url = [NSURL URLWithString:@""];
    P4PConnectionController * connection = [[P4PConnectionController alloc] initWithDelegate:self withURL:url];
    NSURLCredential * credentials = connection.credentials;
    NSString * oldUsername = credentials.user;
    NSString * oldPassword = credentials.password;
    
    if(!newUsername || !newPassword) {
        [self noteNoCredentials];
    }
    
    if(!newUsername){
        newUsername = @"Unknown";
    }
    if(!newPassword) {
        newPassword = @"Unknown";
    }
    
    BOOL hasNewCredentials = NO;
    if(![newUsername isEqualToString:oldUsername]){
        hasNewCredentials = YES;
    }
    
    if(![newPassword isEqualToString:oldPassword] &&
       ![newPassword isEqualToString:[connection dummyPasswordForActualPassword:oldPassword]]){
        hasNewCredentials = YES;
    }
    
    if(hasNewCredentials){
        [connection saveUsername:newUsername withPassword:newPassword];
    }
}

- (void) clearCredentials {
    P4PConnectionController * connection = [[P4PConnectionController alloc] initWithDelegate:self withURL:nil];
    [connection saveUsername:@"Unknown" withPassword:@"Unknown"];
}

- (void) noteNoCredentials {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"No credentials" object:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    if([settings boolForKey:@"multiuser_preference"]){
        [self clearCredentials];
    }
    [self dismissAllAlerts];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationWillResignActive" object:nil];
    [[UIScreen mainScreen] setBrightness:self.originalBrightness];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"App did enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [self updateSettings];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"App did become active");
    [self updateSettings];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"App will terminate");
    [[P4PDatabaseController sharedDatabaseController] purge];
}

- (void) setHasAlert:(BOOL)hasAlert {
    _hasAlert = hasAlert;
//    NSLog(hasAlert ? @"hasAlert: Yes" : @"hasAlert: No");
}

- (void) dismissAllAlerts {
    for (UIWindow * window in [UIApplication sharedApplication].windows) {
        for (NSObject * object in window.subviews) {
            if ([object isKindOfClass:[UIAlertView class]]) {
                [(UIAlertView *)object dismissWithClickedButtonIndex:[(UIAlertView *)object cancelButtonIndex] animated:YES];
            }
        }
    }
    self.hasAlert = NO;
}


@end
