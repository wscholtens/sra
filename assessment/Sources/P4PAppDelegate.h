//
//  P4PAppDelegate.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/20/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface P4PAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) float originalBrightness;
@property (nonatomic) float currentBrightness;
@property (nonatomic) BOOL hasAlert;
@property (nonatomic) BOOL isReset;

- (void) dismissAllAlerts;

@end
