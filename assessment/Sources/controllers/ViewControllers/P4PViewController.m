//
//  P4PViewController.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/20/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PViewController.h"
#import "P4PAppDelegate.h"
#import "P4PAssessmentViewController.h"
#import "P4PAssessment.h"

@interface P4PViewController ()
@property(nonatomic) BOOL isObserver;
@end

@implementation P4PViewController

#pragma mark - Utility

- (void) retryAction {
//    @required To be implemented by subclasses
}

- (void) cancelAction {
//    @required To be implemented by subclasses
}

- (UIImage *) randomBackgroundImage {
    NSMutableArray * images = [[NSMutableArray alloc] init];
    [images addObject:[UIImage imageNamed:@"simrent_backgroundsmall.jpg"]];
//    [images addObject:[UIImage imageNamed:@"login_background2.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background3.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background4.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background5.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background7.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background8.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background11.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background12.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background13.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background15.jpeg"]];
//    [images addObject:[UIImage imageNamed:@"login_background16.jpeg"]];
    
    NSInteger randomIndex = arc4random() % images.count;
    return [images objectAtIndex:randomIndex];
}

#pragma mark - UIAlertview generators

- (void) requestUserCredentialsWithDelegate:(UIViewController *) delegate {
    UIAlertView * loginView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Enter Credentials" delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
    loginView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [loginView textFieldAtIndex:1].delegate = self;
    self.alertView = loginView;
    
//    NSLog(@"P4PViewController.requestUserCredentialsWithDelegate called");
    
    if(!((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert) {
        ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = YES;
        [loginView show];
    }
}

- (void) showError:(NSString *)errorDescription {
    UIAlertView * errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorView show];
}

#pragma mark - UIAlertView delegates

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = NO;    
    NSString * title = alertView.title;
    if([title isEqualToString:@"Login"]){
        NSString * buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if([buttonTitle isEqualToString:@"Login"]) {
            UITextField * usernameField = [alertView textFieldAtIndex:0];
            UITextField * passwordField = [alertView textFieldAtIndex:1];
            if(self.connection){
                [self.connection saveUsername:usernameField.text withPassword:passwordField.text];
            } else {
                NSURL * dummyUrl = [NSURL URLWithString:@""];
                self.connection = [[P4PConnectionController alloc] initWithDelegate:self withURL:dummyUrl];
                [self.connection saveUsername:usernameField.text withPassword:passwordField.text];
            }
            NSLog(@"\nNew username: %@\n", usernameField.text);
            [self retryAction];
        } else {
            [self.connection saveUsername:@"" withPassword:@""];
            [self cancelAction];
        }
    } else if([alertView.message isEqualToString:@"Invalid credentials"]){
        [self requestUserCredentialsWithDelegate:self];
    } else if([alertView.message isEqualToString:@"Missing credentials"]){
        [self requestUserCredentialsWithDelegate:self];
    } else if([alertView.message isEqualToString:@"You are using your email. Use your 3 digit code instead."]){
        [self requestUserCredentialsWithDelegate:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([self.alertView.title isEqualToString:@"Login"]) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];        
        [self alertView:self.alertView clickedButtonAtIndex:1];
    }
    return YES;
}

#pragma mark - P4PConnection delegates

- (void) badCredentials {
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid credentials" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    self.alertView.alertViewStyle = UIAlertViewStyleDefault;
    self.alertView.delegate = self;
    if(!((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert) {
        ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = YES;
        [self.alertView show];
    }
}

- (void) badCredentialsWithMessage:(NSString *)message {
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You are using your email. Use your 3 digit code instead." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    self.alertView.alertViewStyle = UIAlertViewStyleDefault;
    self.alertView.delegate = self;
    if(!((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert) {
        ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = YES;
        [self.alertView show];
    }    
}

- (BOOL) newAssessmentInApp {
    BOOL foundNewAssessment = NO;
    UIViewController * viewController;
    P4PAssessment * lastAssessment;
    P4PAssessmentViewController * assessmentViewController;
    for(int i = 0; i < self.navigationController.viewControllers.count; i++){
        viewController = [self.navigationController.viewControllers objectAtIndex:i];
        if([viewController isKindOfClass:[P4PAssessmentViewController class]]){
            assessmentViewController = (P4PAssessmentViewController *) viewController;
            lastAssessment = [assessmentViewController.assessments lastObject];
            if(!lastAssessment.date) {
                foundNewAssessment = YES;
                break;
            }
        }
    }
    return foundNewAssessment;
}

- (void) noCredentials {
    if(![self newAssessmentInApp]){
        [self requestUserCredentialsWithDelegate:self];
    }
}


- (void) errorWithMessage:(NSString *)message {
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    self.alertView.alertViewStyle = UIAlertViewStyleDefault;
    self.alertView.delegate = self;
    if(!((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert) {
        ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = YES;
        [self.alertView show];
    }
}

- (void) succesfullSaveMessage:(NSString *)message {
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Assessment saved" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    self.alertView.alertViewStyle = UIAlertViewStyleDefault;
    self.alertView.delegate = self;
    if(!((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert) {
        ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = YES;
        [self.alertView show];
    }
}

- (void) message:(NSString *)message withTitle:(NSString *)title {
    self.alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    self.alertView.alertViewStyle = UIAlertViewStyleDefault;
    self.alertView.delegate = self;
    if(!((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert) {
        ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = YES;
        [self.alertView show];
    }
}

#pragma mark - UIViewController delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noCredentials) name:@"No credentials" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAction) name:@"ApplicationWillResignActive" object:nil];
    self.isObserver = YES;
    self.view.clipsToBounds = YES;
}



- (void) viewDidAppear:(BOOL)animated {
    if(!self.isObserver){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noCredentials) name:@"No credentials" object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isObserver = NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [self message:@"Closing other apps might help" withTitle:@"Warning: Low memory"];
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
