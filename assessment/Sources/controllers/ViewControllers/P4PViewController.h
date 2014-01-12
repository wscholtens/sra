//
//  P4PViewController.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/20/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P4PConnectionController.h"

@interface P4PViewController : UIViewController <UITextFieldDelegate, P4PConnectionProtocol>

@property (strong, nonatomic) P4PConnectionController * connection;
@property (nonatomic, strong) UIAlertView * alertView;

#pragma mark - Utility
- (UIImage *) randomBackgroundImage;
- (void) retryAction;
- (void) cancelAction;

#pragma mark - AlertView generators
- (void) requestUserCredentialsWithDelegate:(UIViewController *) delegate;
- (void) showError:(NSString *)errorDescription;

#pragma mark - AlertView delegates
- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void) succesfullSaveMessage:(NSString *)message;

@end
