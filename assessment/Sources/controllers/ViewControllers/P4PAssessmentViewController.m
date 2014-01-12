//
//  P4PAssessmentViewController.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "P4PAssessmentViewController.h"
#import "NSDictionary+JSon.h"
#import "P4PAssessment+Remote.h"
#import "P4PResult+Remote.h"
#import "P4PCrewmember+Remote.h"
#import "P4PMainMenuViewController.h"
#import "P4PAppDelegate.h"
#import "MBProgressHUD.h"
#import "DCRoundSwitch.h"

@interface P4PAssessmentViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView * scrollView;
@property (strong, nonatomic) IBOutlet UIView * assessmentView;

@property (strong, nonatomic) IBOutlet UILabel * crewmemberANameTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberBNameTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberCNameTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberANameLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberBNameLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberCNameLabel;
@property (strong, nonatomic) IBOutlet UILabel * remarksTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel * dateTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel * dateLabel;

@property (strong, nonatomic) IBOutlet UILabel * instructorTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel * instructorLabel;
@property (strong, nonatomic) IBOutlet UILabel * sessionTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel * aircraftTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberAGradesNameLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberBGradesNameLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberCGradesNameLabel;

@property (strong, nonatomic) IBOutlet UILabel * lowgradeStandardMinusTitleALabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeAcceptableTitleALabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeStandardTitleALabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeStandardPlusTitleALabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeStandardMinusTitleBLabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeAcceptableTitleBLabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeStandardTitleBLabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeStandardPlusTitleBLabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeStandardMinusTitleCLabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeAcceptableTitleCLabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeStandardTitleCLabel;
@property (strong, nonatomic) IBOutlet UILabel * lowgradeStandardPlusTitleCLabel;

@property (strong, nonatomic) IBOutlet UITextField * aircraftField;

@property (strong, nonatomic) IBOutlet UILabel * crewmemberARemarkNameLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberBRemarkNameLabel;
@property (strong, nonatomic) IBOutlet UILabel * crewmemberCRemarkNameLabel;
@property (strong, nonatomic) IBOutlet UITextView * remarkAView;
@property (strong, nonatomic) IBOutlet UITextView * remarkBView;
@property (strong, nonatomic) IBOutlet UITextView * remarkCView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem * backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem * saveButton;
@property (strong, nonatomic) IBOutlet UIButton * nextAssessmentButton;
@property (strong, nonatomic) IBOutlet UIButton * previousAssessmentButton;

@property (strong, nonatomic) UIButton * crewmemberAReadyButton;
@property (strong, nonatomic) UIButton * crewmemberBReadyButton;
@property (strong, nonatomic) UIButton * crewmemberCReadyButton;

@property (strong, nonatomic) DCRoundSwitch * dayNightSwitch;

@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeDownRecognizer;

@property (nonatomic, strong) UIButton * deleteTextButton;

@property (nonatomic) int assessmentIndex;
@property (strong, nonatomic) P4PAssessment * assessment;

@property (nonatomic) BOOL keyboardVisible;
@property (nonatomic) BOOL isNight;
@property (nonatomic) BOOL clickedSaveButton;
@property (nonatomic) float originalBrightness;
@property (nonatomic) int firstResponderTag;
@property (nonatomic) double scrollViewHeightOffset;
@property (strong, nonatomic) UIPopoverController * actionMenuPopover;

@end

@implementation P4PAssessmentViewController

#pragma mark - IBActions

- (IBAction)savePressed:(UIBarButtonItem *)sender {
    self.clickedSaveButton = YES;
    if([self.connection hasCredentials]) {
        [self confirmSaveAssessmentWithDelegate:self];
    } else {
        [self requestUserCredentialsWithDelegate:self];
    }
}

- (IBAction)gradePressed:(UIButton *)sender {
    [self setGradeForButtonWithTag:sender.tag];
    NSNumber * tag = [NSNumber numberWithInt:sender.tag];
    [self performSelector:@selector(setButtonGroupForButtonPressedWithTag:) withObject:tag afterDelay:0.1];
}

- (IBAction)readyButtonPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.assessment resultForPosition:[NSNumber numberWithInt:sender.tag]].passed = [NSNumber numberWithBool:sender.isSelected];
    NSLog(@"Ready: %@", [self.assessment resultForPosition:[NSNumber numberWithInt:sender.tag]].passed); 
}

- (IBAction)nextAssessmentButtonPressed:(UIButton *)sender {
    if(self.assessmentIndex < self.assessments.count - 1) {
        self.assessmentIndex++;
        self.assessment = [self.assessments objectAtIndex:self.assessmentIndex];
        [self showNewViewAnimatedSlideAscending:YES];
    }
}

- (IBAction)previousAssessmentPressed:(UIButton *)sender {
    if(self.assessmentIndex > 0) {
        self.assessmentIndex--;
        self.assessment = [self.assessments objectAtIndex:self.assessmentIndex];
        [self showNewViewAnimatedSlideAscending:NO];
    }
}

- (void) toggleDayNightSwitch:(DCRoundSwitch *)sender {
    self.isNight = sender.on;
    [self enableNightVision:self.isNight];
}

- (void) backButtonPressed {
    P4PAssessment * lastAssessment = [self.assessments lastObject];
    if(!lastAssessment.date) {
        [self requestBackConfirmation:self];
    } else {
        [self returnToMainMenu];
    }
}

#pragma mark - Animations

- (void) showNewViewAnimatedSlideAscending:(BOOL)isAscending {
    UIView * oldAssessmentView = self.assessmentView;
	UIView * newAssessmentView = self.assessmentView;
    UIView * superView = self.assessmentView.superview;
	
	[oldAssessmentView removeFromSuperview];
	[superView addSubview:newAssessmentView];
	
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.3];
	[animation setType:kCATransitionPush];
    if(isAscending) {
        [animation setSubtype:kCATransitionFromRight];
    } else {
        [animation setSubtype:kCATransitionFromLeft];
    }
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[superView layer] addAnimation:animation forKey:@"newAssessmentAnimation"];
    if(self.keyboardVisible) {
        [self.view endEditing:YES];
    }
}

- (void) setButtonGroupForButtonPressedWithTag:(NSNumber *)tagNumber {
    //Tag formula: tag = 4 * column + 100 * row + 1000;
    
    int tag = [tagNumber intValue];
    int realTag = tag % 1000;
    int positionIndependentTag = (realTag % 100);
    int positionInGroupTag = positionIndependentTag % 4;
    
    UIButton * lowerButton = (UIButton *) [self.assessmentView viewWithTag:tag - 1];
    UIButton * pressedButton = (UIButton *) [self.assessmentView viewWithTag:tag];
    UIButton * higherButton = (UIButton *) [self.assessmentView viewWithTag:tag + 1];
    
    if(![pressedButton isSelected]){
        pressedButton.selected = YES;
        if(positionInGroupTag == 0){
            if(((UIButton *) [self.assessmentView viewWithTag:tag + 1]).selected && ((UIButton *) [self.assessmentView viewWithTag:tag + 2]).selected) {
                [self deselectButton:higherButton];
            }
            [self deselectButton:((UIButton *) [self.assessmentView viewWithTag:tag + 2])];
            [self deselectButton:((UIButton *) [self.assessmentView viewWithTag:tag + 3])];
        } else if(positionInGroupTag == 1) {
            if(((UIButton *) [self.assessmentView viewWithTag:tag + 1]).selected && ((UIButton *) [self.assessmentView viewWithTag:tag + 2]).selected) {
                [self deselectButton:higherButton];
            }
            [self deselectButton:((UIButton *) [self.assessmentView viewWithTag:tag + 2])];
        } else if(positionInGroupTag == 2) {
            if(((UIButton *) [self.assessmentView viewWithTag:tag - 1]).selected && ((UIButton *) [self.assessmentView viewWithTag:tag - 2]).selected) {
                [self deselectButton:lowerButton];
            }
            [self deselectButton:((UIButton *) [self.assessmentView viewWithTag:tag - 2])];
        } else if(positionInGroupTag == 3) {
            if(((UIButton *) [self.assessmentView viewWithTag:tag - 1]).selected && ((UIButton *) [self.assessmentView viewWithTag:tag - 2]).selected) {
                [self deselectButton:lowerButton];
            }            
            [self deselectButton:((UIButton *) [self.assessmentView viewWithTag:tag - 3])];
            [self deselectButton:((UIButton *) [self.assessmentView viewWithTag:tag - 2])];
        }
    } else {
        if(positionInGroupTag == 0){
            if([higherButton isSelected]){
                higherButton.selected = NO;
                pressedButton.selected = YES;
            } else {
                pressedButton.selected = NO;
            }
        } else if(positionInGroupTag > 0 && positionInGroupTag < 3) {
            if([higherButton isSelected]) {
                higherButton.selected = NO;
                pressedButton.selected = YES;
            } else if([lowerButton isSelected]) {
                lowerButton.selected = NO;
                pressedButton.selected = YES;
            } else {
                pressedButton.selected = NO;
            }
        } else if(positionInGroupTag == 3) {
            if([lowerButton isSelected]) {
                lowerButton.selected = NO;
                pressedButton.selected = YES;
            } else {
                pressedButton.selected = NO;
            }
        }
    }
}

- (void) deselectButton:(UIButton *)button {
    [button setSelected:NO];
}

- (int) gradeValueForButtonTag:(int) tag {
    int realTag = tag % 1000;
    int positionIndependentTag = (realTag % 100);
    int positionInGroupTag = positionIndependentTag % 4;
    
    UIButton * lowerButton = (UIButton *) [self.assessmentView viewWithTag:tag - 1];
    UIButton * pressedButton = (UIButton *) [self.assessmentView viewWithTag:tag];
    UIButton * higherButton = (UIButton *) [self.assessmentView viewWithTag:tag + 1];
    
    if(![pressedButton isSelected]){
        if(positionInGroupTag == 0){
            if([higherButton isSelected]){
                return 2;
            } else {
                return 1;
            }
        } else if(positionInGroupTag > 0 && positionInGroupTag < 3) {
            if([higherButton isSelected]) {
                return (positionInGroupTag * 2) + 2;
            } else if([lowerButton isSelected]) {
                return (positionInGroupTag * 2);
            } else {
                return (positionInGroupTag * 2) + 1;
            }
        } else if(positionInGroupTag == 3) {
            if([lowerButton isSelected]) {
                return 6;
            } else {
                return 7;
            }
        }
    } else {
        if(positionInGroupTag == 0){
            if([higherButton isSelected]){
                return 1;
            } else {
                return 0;
            }
        } else if(positionInGroupTag > 0 && positionInGroupTag < 3) {
            if([higherButton isSelected]) {
                return (positionInGroupTag * 2) + 1;
            } else if([lowerButton isSelected]) {
                return (positionInGroupTag * 2) + 1;
            } else {
                return 0;
            }
        } else if(positionInGroupTag == 3) {
            if([lowerButton isSelected]) {
                return 7;
            } else {
                return 0;
            }
        }
    }
    return 0;
}


-(void) setGradeForButtonWithTag:(int)tag {
    int crewmemberPosition = ((tag - 1000) / 100);
    int skillIndex = (tag % 100) / 4;
    int gradeValue = [self gradeValueForButtonTag:tag];
    
    P4PResult * result = [self.assessment resultForPosition:[NSNumber numberWithInt:crewmemberPosition]];
    
    NSString * preString;
    if(skillIndex >= 0) {
        preString = [result.grades substringToIndex:skillIndex];
    } else {
        preString = @"";
    }
    
    NSString * postString;
    if(skillIndex < result.grades.length - 1) {
        postString = [result.grades substringFromIndex:skillIndex+1];
    } else {
        postString = @"";
    }
    
    NSNumber * grade = [NSNumber numberWithInt:gradeValue];
    NSString * gradeString = [grade stringValue];
    
    NSString * newGradeString = [NSString stringWithFormat:@"%@%@%@", preString, gradeString, postString];
    result.grades = newGradeString;
}

#pragma mark - Core functionality

- (void) continueSendAssessment {
    NSDictionary * isSavedConfirmation = nil;
    NSData * requestJSON = [self jsonRequestObjectSaveAssessment];
    isSavedConfirmation = [self.connection sendSynchronousJSON:requestJSON];
    if(isSavedConfirmation){
        [self verifySavedConfirmation:isSavedConfirmation];
    }    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) sendAssessment {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving assessment";
    [self performSelector:@selector(continueSendAssessment) withObject:nil afterDelay:0.1];
}

- (void) verifySavedConfirmation:(NSDictionary *) confirmation {
    if([[confirmation valueForKey:@"saved"] isEqualToString:@"false"]){
        [self errorWithMessage:@"Could not save assessment"];
    } else if([[confirmation valueForKey:@"mail_a"] isEqualToString:@"false"] ||
       [[confirmation valueForKey:@"mail_b"] isEqualToString:@"false"] ||
       [[confirmation valueForKey:@"mail_c"] isEqualToString:@"false"]){
        [self errorWithMessage:@"Saved, but could not send mail to a crewmember"];
    } else if([[confirmation valueForKey:@"mail_p4p_schedule"] isEqualToString:@"false"]){
        [self errorWithMessage:@"Saved, but could not send mail to P4P scheduling"];
    } else if([[confirmation valueForKey:@"mail_p4p"] isEqualToString:@"false"]){
        [self errorWithMessage:@"Saved, but could not send P4P mail"];
    } else if([confirmation valueForKey:@"error"]){
        //do nothing except wait for error already given by connection
    } else {
        [self saveSucceededMessage];
    }
}

- (void) saveSucceededMessage {
    NSArray * viewControllers = [self.navigationController viewControllers];
    for(P4PViewController * viewController in viewControllers) {
        if([viewController isKindOfClass:[P4PMainMenuViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            [viewController succesfullSaveMessage:nil];
            break;
        }
    }
}

#pragma mark - Night Vision

- (UIColor *) backgroundColorNightVisionEnabled:(BOOL)enabled {
    UIColor * backgroundColor;
    if(enabled){
        backgroundColor = [UIColor blackColor];
    } else {
        backgroundColor = [UIColor whiteColor];
    }
    return backgroundColor;
}

- (UIColor *) backgroundEditColorNightVisionEnabled:(BOOL)enabled {
    UIColor * backgroundColor;
    if(enabled){
        backgroundColor = [UIColor blackColor];
    } else {
        backgroundColor = [UIColor colorWithRed:0.901961 green:0.901961 blue:0.901961 alpha:1];
    }
    return backgroundColor;
}

- (UIColor *) foregroundColorNightVisionEnabled:(BOOL)enabled {
    UIColor * foregroundColor;
    if(enabled){
        foregroundColor = [UIColor whiteColor];
    } else {
        foregroundColor = [UIColor blackColor];
    }
    return foregroundColor;
}

- (void) enableNightVision:(BOOL)enabled {
    P4PAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    if(enabled) {
        appDelegate.originalBrightness = [UIScreen mainScreen].brightness;
        appDelegate.currentBrightness = 0.0;
        [[UIScreen mainScreen] setBrightness:appDelegate.currentBrightness];
    } else {
        [[UIScreen mainScreen] setBrightness:appDelegate.originalBrightness];
        appDelegate.currentBrightness = appDelegate.originalBrightness;
    }
    
    [self enableNavbarNightVision:enabled];
    [self enableLabelsNightVision:enabled];
    [self enableTextFieldsNightVision:enabled];
    [self enableTextViewsNightVision:enabled];
    [self enableGradeButtonsNightVision:enabled];
    [self enableOtherButtonsNightVision:enabled];
    
    self.view.backgroundColor = [self backgroundColorNightVisionEnabled:enabled];
    self.assessmentView.backgroundColor = [self backgroundColorNightVisionEnabled:enabled];
    self.scrollView.backgroundColor = [self backgroundColorNightVisionEnabled:enabled];
}

- (void) enableNavbarNightVision:(BOOL)enabled {
    if(enabled){
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
}

- (void) enableNightVision:(BOOL)enabled forLabel:(UILabel *)label {
    label.textColor = [self foregroundColorNightVisionEnabled:enabled];
    label.backgroundColor = [self backgroundColorNightVisionEnabled:enabled];
}

- (void) enableLabelsNightVision:(BOOL)enabled {
    [self enableNightVision:enabled forLabel:self.dateTitleLabel];
    [self enableNightVision:enabled forLabel:self.dateLabel];
    [self enableNightVision:enabled forLabel:self.sessionTitleLabel];
    [self enableNightVision:enabled forLabel:self.aircraftTitleLabel];
    [self enableNightVision:enabled forLabel:self.instructorTitleLabel];
    [self enableNightVision:enabled forLabel:self.instructorLabel];
    
    [self enableNightVision:enabled forLabel:self.crewmemberANameTitleLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberBNameTitleLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberCNameTitleLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberANameLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberBNameLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberCNameLabel];
    
    [self enableNightVision:enabled forLabel:self.crewmemberAGradesNameLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberBGradesNameLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberCGradesNameLabel];
    
    [self enableNightVision:enabled forLabel:self.remarksTitleLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberARemarkNameLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberBRemarkNameLabel];
    [self enableNightVision:enabled forLabel:self.crewmemberCRemarkNameLabel];

    [self enableNightVision:enabled forLabel:self.lowgradeStandardMinusTitleALabel];
    [self enableNightVision:enabled forLabel:self.lowgradeAcceptableTitleALabel];
    [self enableNightVision:enabled forLabel:self.lowgradeStandardTitleALabel];
    [self enableNightVision:enabled forLabel:self.lowgradeStandardPlusTitleALabel];
    [self enableNightVision:enabled forLabel:self.lowgradeStandardMinusTitleBLabel];
    [self enableNightVision:enabled forLabel:self.lowgradeAcceptableTitleBLabel];
    [self enableNightVision:enabled forLabel:self.lowgradeStandardTitleBLabel];
    [self enableNightVision:enabled forLabel:self.lowgradeStandardPlusTitleBLabel];
    [self enableNightVision:enabled forLabel:self.lowgradeStandardMinusTitleCLabel];
    [self enableNightVision:enabled forLabel:self.lowgradeAcceptableTitleCLabel];
    [self enableNightVision:enabled forLabel:self.lowgradeStandardTitleCLabel];
    [self enableNightVision:enabled forLabel:self.lowgradeStandardPlusTitleCLabel];
    
    UILabel * gradeLabel;
    for(int i = 0; i < 17; i++){
        gradeLabel = (UILabel *)[self.assessmentView viewWithTag:i+30];
        [self enableNightVision:enabled forLabel:gradeLabel];
    }
}

- (void) enableNightVision:(BOOL)enabled forTextField:(UITextField *)textField {
    textField.textColor = [self foregroundColorNightVisionEnabled:enabled];
    textField.backgroundColor = [self backgroundEditColorNightVisionEnabled:enabled];
}

- (void) enableTextFieldsNightVision:(BOOL)enabled {
    [self enableNightVision:enabled forTextField:self.aircraftField];
}

- (void) enableNightVision:(BOOL)enabled forTextView:(UITextView *)textView {
    textView.textColor = [self foregroundColorNightVisionEnabled:enabled];
    textView.backgroundColor = [self backgroundEditColorNightVisionEnabled:enabled];
}

- (void) enableTextViewsNightVision:(BOOL)enabled {
    [self enableNightVision:enabled forTextView:self.remarkAView];
    [self enableNightVision:enabled forTextView:self.remarkBView];
    [self enableNightVision:enabled forTextView:self.remarkCView];
}

- (void) enableNightVision:(BOOL)enabled forGradeButton:(UIButton *)gradeButton {
    if(enabled){
        UIImage * nightCheckedImage = [UIImage imageNamed:@"checked_night.jpeg"];
        UIImage * nightUncheckedImage = [UIImage imageNamed:@"unchecked_night.jpeg"];
        [gradeButton setImage:nightCheckedImage forState:UIControlStateSelected];
        [gradeButton setImage:nightUncheckedImage forState:UIControlStateNormal];
    } else {
        UIImage * dayCheckedImage = [UIImage imageNamed:@"checked.jpeg"];
        UIImage * dayUncheckedImage = [UIImage imageNamed:@"unchecked.jpeg"];
        [gradeButton setImage:dayCheckedImage forState:UIControlStateSelected];
        [gradeButton setImage:dayUncheckedImage forState:UIControlStateNormal];
    }
}

- (void) enableGradeButtonsNightVision:(BOOL)enabled {
    UIButton * gradeButton;
    for(int column = 0; column < 3; column++) {
        for(int row = 0; row < 17; row++) {
            for(int i = 0; i < 4; i++){
                int tag = 1000 + (column * 100) + (row * 4) + i;
                gradeButton = (UIButton *) [self.assessmentView viewWithTag:tag];
                [self enableNightVision:enabled forGradeButton:gradeButton];
            }
        }
    }
}

- (void) enableOtherButtonsNightVision:(BOOL)enabled {
    if(enabled){
        UIImage * nightPreviousImage = [UIImage imageNamed:@"back4_night.png"];
        [self.previousAssessmentButton setImage:nightPreviousImage forState:UIControlStateNormal];
        [self.previousAssessmentButton setImage:nightPreviousImage forState:UIControlStateHighlighted];
        [self.previousAssessmentButton setImage:nightPreviousImage forState:UIControlStateSelected];
    } else {
        UIImage * dayPreviousImage = [UIImage imageNamed:@"back4.png"];
        [self.previousAssessmentButton setImage:dayPreviousImage forState:UIControlStateNormal];
        [self.previousAssessmentButton setImage:dayPreviousImage forState:UIControlStateHighlighted];
        [self.previousAssessmentButton setImage:dayPreviousImage forState:UIControlStateSelected];
    }
    
    if(enabled){
        UIImage * nightNextImage = [UIImage imageNamed:@"play4_night.png"];
        [self.nextAssessmentButton setImage:nightNextImage forState:UIControlStateNormal];
        [self.nextAssessmentButton setImage:nightNextImage forState:UIControlStateHighlighted];
        [self.nextAssessmentButton setImage:nightNextImage forState:UIControlStateSelected];
    } else {
        UIImage * dayNextImage = [UIImage imageNamed:@"play4.png"];
        [self.nextAssessmentButton setImage:dayNextImage forState:UIControlStateNormal];
        [self.nextAssessmentButton setImage:dayNextImage forState:UIControlStateHighlighted];
        [self.nextAssessmentButton setImage:dayNextImage forState:UIControlStateSelected];
    }
    
    if(enabled){
        UIImage * nightCheckedImage = [UIImage imageNamed:@"checked_night.jpeg"];
        UIImage * nightUncheckedImage = [UIImage imageNamed:@"unchecked_night.jpeg"];
        [self.crewmemberAReadyButton setImage:nightCheckedImage forState:UIControlStateSelected];
        [self.crewmemberAReadyButton setImage:nightUncheckedImage forState:UIControlStateNormal];
        [self.crewmemberBReadyButton setImage:nightCheckedImage forState:UIControlStateSelected];
        [self.crewmemberBReadyButton setImage:nightUncheckedImage forState:UIControlStateNormal];
        [self.crewmemberCReadyButton setImage:nightCheckedImage forState:UIControlStateSelected];
        [self.crewmemberCReadyButton setImage:nightUncheckedImage forState:UIControlStateNormal];
    } else {
        UIImage * dayCheckedImage = [UIImage imageNamed:@"checked.jpeg"];
        UIImage * dayUncheckedImage = [UIImage imageNamed:@"unchecked.jpeg"];
        [self.crewmemberAReadyButton setImage:dayCheckedImage forState:UIControlStateSelected];
        [self.crewmemberAReadyButton setImage:dayUncheckedImage forState:UIControlStateNormal];
        [self.crewmemberBReadyButton setImage:dayCheckedImage forState:UIControlStateSelected];
        [self.crewmemberBReadyButton setImage:dayUncheckedImage forState:UIControlStateNormal];
        [self.crewmemberCReadyButton setImage:dayCheckedImage forState:UIControlStateSelected];
        [self.crewmemberCReadyButton setImage:dayUncheckedImage forState:UIControlStateNormal];
    }
}


#pragma mark - Crew Setup

- (void) setCrewmemberNameForPosition:(NSNumber *)position withCrewmember:(P4PCrewmember *)crewmember {
    switch (position.intValue) {
        case 0:
            self.crewmemberANameLabel.text = crewmember.name;
            self.crewmemberAGradesNameLabel.text = crewmember.name;
            self.crewmemberARemarkNameLabel.text = crewmember.name;
            break;
        case 1:
            self.crewmemberBNameLabel.text = crewmember.name;
            self.crewmemberBGradesNameLabel.text = crewmember.name;
            self.crewmemberBRemarkNameLabel.text = crewmember.name;
            break;
        case 2:
            self.crewmemberCNameLabel.text = crewmember.name;
            self.crewmemberCGradesNameLabel.text = crewmember.name;
            self.crewmemberCRemarkNameLabel.text = crewmember.name;
            break;
        default:
            break;
    }
}

- (void) setGradeButtonGroup:(int)group forPosition:(int)position withValue:(int)grade {
    int startTag = 1000 + ((position) * 100) + (group * 4);
    
    UIButton * button0 = (UIButton *) [self.assessmentView viewWithTag:startTag];
    UIButton * button1 = (UIButton *) [self.assessmentView viewWithTag:startTag+1];
    UIButton * button2 = (UIButton *) [self.assessmentView viewWithTag:startTag+2];
    UIButton * button3 = (UIButton *) [self.assessmentView viewWithTag:startTag+3];
    
    switch (grade) {
        case 1:
            button0.selected = YES;
            button1.selected = NO;
            button2.selected = NO;
            button3.selected = NO;
            break;
        case 2:
            button0.selected = YES;
            button1.selected = YES;
            button2.selected = NO;
            button3.selected = NO;
            break;
        case 3:
            button0.selected = NO;
            button1.selected = YES;
            button2.selected = NO;
            button3.selected = NO;
            break;
        case 4:
            button0.selected = NO;
            button1.selected = YES;
            button2.selected = YES;
            button3.selected = NO;
            break;
        case 5:
            button0.selected = NO;
            button1.selected = NO;
            button2.selected = YES;
            button3.selected = NO;
            break;
        case 6:
            button0.selected = NO;
            button1.selected = NO;
            button2.selected = YES;
            button3.selected = YES;
            break;
        case 7:
            button0.selected = NO;
            button1.selected = NO;
            button2.selected = NO;
            button3.selected = YES;
            break;
        default:
            button0.selected = NO;
            button1.selected = NO;
            button2.selected = NO;
            button3.selected = NO;
            break;
    }
}

- (void) setGradeButtonsForCrewmember:(P4PCrewmember *)crewmember withPosition:(NSNumber *)position {
    P4PResult * result = [self.assessment resultForPosition:position];
    NSString * grades = result.grades;
    
    if(!grades || [grades isEqualToString:@""]){
        grades = @"00000000000000000";
    }
    
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSRange range;
    int grade;
    NSString * subString;
    for(int i = 0; i < 17; i++){
        range = NSMakeRange(i, 1);
        subString = [grades substringWithRange:range];
        grade = [formatter numberFromString:subString].intValue;
        [self setGradeButtonGroup:i forPosition:position.intValue withValue:grade];
    }
}

- (void) setCrewmember:(P4PCrewmember *)crewmember withPosition:(NSNumber *)position {
    [self setCrewmemberNameForPosition:position withCrewmember:crewmember];
    [self setGradeButtonsForCrewmember:crewmember withPosition:position];
    
    P4PResult * result = [self.assessment resultForPosition:position];    
    [self setCrewmemberReady:result.passed withPosition:position];
}

- (void) setCrewmemberRemark:(NSString *)remark withPosition:(NSNumber *)position {
    switch (position.intValue) {
        case 0:
            self.remarkAView.text = remark;
            break;
        case 1:
            self.remarkBView.text = remark;
            break;
        case 2:
            self.remarkCView.text = remark;
            break;
        default:
            break;
    }
}

- (void) setCrewmemberReady:(NSNumber *)isReady withPosition:(NSNumber *)position {
    P4PResult * result = [self.assessment resultForPosition:position];    
    if(result.crewmember.name && ![result.crewmember.name isEqualToString:@""] && [self canBeSaved]) {
        switch (position.intValue) {
            case 0:
                self.crewmemberAReadyButton.selected = isReady.boolValue;
                self.crewmemberAReadyButton.hidden = NO;
                break;
            case 1:
                self.crewmemberBReadyButton.selected = isReady.boolValue;
                self.crewmemberBReadyButton.hidden = NO;
                break;
            case 2:
                self.crewmemberCReadyButton.selected = isReady.boolValue;
                self.crewmemberCReadyButton.hidden = NO;
                break;
            default:
                break;
        }
    } else {
        if([self canBeSaved] && result.crewmember && ![result.crewmember.name isEqualToString:@""]) {
            switch (position.intValue) {
                case 0:
                    self.crewmemberAReadyButton.selected = NO;
                    self.crewmemberAReadyButton.hidden = NO;
                    break;
                case 1:
                    self.crewmemberBReadyButton.selected = NO;
                    self.crewmemberBReadyButton.hidden = NO;
                    break;
                case 2:
                    self.crewmemberCReadyButton.selected = NO;
                    self.crewmemberCReadyButton.hidden = NO;
                    break;
                default:
                    break;
            }            
        } else {
            switch (position.intValue) {
                case 0:
                    self.crewmemberAReadyButton.hidden = YES;
                    break;
                case 1:
                    self.crewmemberBReadyButton.hidden = YES;
                    break;
                case 2:
                    self.crewmemberCReadyButton.hidden = YES;
                    break;
                default:
                    break;
            }
        }
    }
}

- (void) setCrew {
    NSSet * results = self.assessment.results;
    for(P4PResult * result in results){
        [self setCrewmember:result.crewmember withPosition:result.position];
        [self setCrewmemberRemark:result.remarks withPosition:result.position];
        [self setCrewmemberReady:result.passed withPosition:result.position];
    }
    int count = 3 - results.count;
    if(count > 0){
        NSNumber * position;
        for(int i = 0; i < count; i++){
            position = [NSNumber numberWithInt:(2-i)];
            [self setCrewmember:nil withPosition:position];
            [self setCrewmemberRemark:nil withPosition:position];
            [self setCrewmemberReady:nil withPosition:position];
        }
    }
}

#pragma mark - Checkbox Setup

- (void)setupCrewmemberReadyButtons {
    self.crewmemberAReadyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.crewmemberBReadyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.crewmemberCReadyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.crewmemberAReadyButton.frame =  CGRectMake(120, 20 + 30 * 0, 22, 22);
    self.crewmemberBReadyButton.frame =  CGRectMake(120, 20 + 30 * 1, 22, 22);
    self.crewmemberCReadyButton.frame =  CGRectMake(120, 20 + 30 * 2, 22, 22);
    
    self.crewmemberAReadyButton.tag = 0;
    self.crewmemberBReadyButton.tag = 1;
    self.crewmemberCReadyButton.tag = 2;
    
    [self pimpCheckboxButton:self.crewmemberAReadyButton];
    [self pimpCheckboxButton:self.crewmemberBReadyButton];
    [self pimpCheckboxButton:self.crewmemberCReadyButton];
    
    [self.crewmemberAReadyButton addTarget:self action:@selector(readyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.crewmemberBReadyButton addTarget:self action:@selector(readyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.crewmemberCReadyButton addTarget:self action:@selector(readyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.assessmentView addSubview:self.crewmemberAReadyButton];
    [self.assessmentView addSubview:self.crewmemberBReadyButton];
    [self.assessmentView addSubview:self.crewmemberCReadyButton];
}

- (void)pimpCheckboxButton:(UIButton *)button {
    UIImage * buttonImageNormal = [UIImage imageNamed:@"unchecked.jpeg"];
    UIImage * strechableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [button setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
    
    UIImage * buttonImageSelected = [UIImage imageNamed:@"checked.jpeg"];
    UIImage * strechableButtonImageSelected = [buttonImageSelected stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [button setBackgroundImage:strechableButtonImageSelected forState:UIControlStateSelected];
    
    button.adjustsImageWhenHighlighted = NO;
    button.adjustsImageWhenDisabled = NO;
}

- (void)addGradeButtonWithRect:(CGRect)rect andTag:(int)tag{
    UIButton * gradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    gradeButton.frame = rect;
    gradeButton.tag = tag;
    
    [gradeButton setTitle:@"GradeButton" forState:UIControlStateNormal];
    gradeButton.backgroundColor = [UIColor clearColor];
    [gradeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    
    [self pimpCheckboxButton:gradeButton];
    
    [gradeButton addTarget:self action:@selector(gradePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.assessmentView addSubview:gradeButton];
}

- (void) setCheckboxGroupForColumn:(int)column andRow:(int)row {
    float width = 22;
    
    float x = 240 + (column * 180);
    float y = 190 + row * width * 1.5;
    
    float offsetX;
    for(int i = 0; i < 4; i++){
        offsetX = (i * width) + (i * 15);
        CGRect rect = CGRectMake(x + offsetX, y, width, width);
        int tag = 1000 + (column * 100) + (row * 4) + i;
        [self addGradeButtonWithRect:rect andTag:tag];
    }
}

- (void) setCheckboxesForCrewmemberPosition:(int)position {
    for(int i = 0; i < 17; i++){
        [self setCheckboxGroupForColumn:position andRow:i];
    }
}

- (void) setGradeLabels {
    NSString * gradeTitle;
    for(int i = 0; i < 17; i++){
        switch (i) {
            case 0: gradeTitle = @"SOP knowledge";break;
            case 1: gradeTitle = @"System knowledge";break;
            case 2: gradeTitle = @"Operational knowledge";break;
            case 3: gradeTitle = @"Failure management";break;
            case 4: gradeTitle = @"Time management";break;
            case 5: gradeTitle = @"Aircraft handling";break;
            case 6: gradeTitle = @"Automation handling";break;
            case 7: gradeTitle = @"Instrument scan";break;
            case 8: gradeTitle = @"Situational awareness";break;
            case 9: gradeTitle = @"Positional awareness";break;
            case 10:gradeTitle = @"Planning & anticipation";break;
            case 11:gradeTitle = @"Assertiveness";break;
            case 12:gradeTitle = @"Decisiveness";break;
            case 13:gradeTitle = @"Information Analysis";break;
            case 14:gradeTitle = @"Leadership potential";break;
            case 15:gradeTitle = @"Teamwork";break;
            case 16:gradeTitle = @"Communication skills";break;
            default:
                break;
        }
        float height = 28;
        
        CGRect rect = CGRectMake(20, 188 + (i * (height + 5)), 600, (height));
        UILabel * label = [[UILabel alloc] initWithFrame:rect];
        label.tag= i + 30;
        label.text = gradeTitle;
        [self.assessmentView addSubview:label];
    }
}

- (void) setCheckboxes {
    [self setGradeLabels];
    for(int i = 0; i < 3; i++){
        [self setCheckboxesForCrewmemberPosition:i];
    }
}

#pragma mark - Setup

- (void) setConnection {
    NSURL * saveAssessmentUrl = [NSURL URLWithString:@"/request/save_assessment.php"];
    self.connection = [[P4PConnectionController alloc] initWithDelegate:self withURL:saveAssessmentUrl];
}

- (void) setEnvironment {
    self.dateLabel.text = self.formattedDate;
    self.aircraftField.text = self.assessment.aircraft;
    self.instructorLabel.text = self.assessment.instructor;
}

- (void) setAssessment:(P4PAssessment *)assessment {
    _assessment = assessment;    
    [self setCrew];
    [self setEnvironment];
    [self setNavigationBar];
    [self setAssessmentHistoryArrows];
    [self setLocks];
}

- (void) setLocks {
    if(!self.canBeSaved){
        [self lockEntireAssessment:YES];
    } else {
        [self setEnvironmentLocks:NO];
        for(int i = 0; i < 3; i++){
            if([self.assessment resultForPosition:[NSNumber numberWithInt:i]]) {
                [self setCrewmemberLocks:NO forPosition:i];
            } else {
                [self setCrewmemberLocks:YES forPosition:i];
            }
        }
    }
}

- (void) setCrewmemberLocks:(BOOL)locked forPosition:(int)position {
    [self setGradeLocks:locked forPosition:position];
    switch (position) {
        case 0:
            [self.remarkAView setEditable:!locked];
            self.crewmemberAReadyButton.enabled = !locked;
            break;
        case 1:
            [self.remarkBView setEditable:!locked];
            self.crewmemberBReadyButton.enabled = !locked;
            break;
        case 2:
            [self.remarkCView setEditable:!locked];
            self.crewmemberCReadyButton.enabled = !locked;
            break;
        default:
            break;
    }
}

- (void) setGradeLocks:(BOOL)locked forPosition:(int)position {
    int tag;
    UIButton * gradeButton;
    for(int row = 0; row < 17; row++){
        for(int column = 0; column < 4; column++){
            tag = column + (4 * row) + (100 * position) + 1000;
            gradeButton = (UIButton *)[self.assessmentView viewWithTag:tag];
            [gradeButton setUserInteractionEnabled:!locked];
        }
    }
}

- (void) setEnvironmentLocks:(BOOL)locked {
    self.aircraftField.userInteractionEnabled = !locked;
}

- (void) lockEntireAssessment:(BOOL)locked {
    [self setCrewmemberLocks:locked forPosition:0];
    [self setCrewmemberLocks:locked forPosition:1];
    [self setCrewmemberLocks:locked forPosition:2];
    [self setEnvironmentLocks:locked];
}

- (void) setNavigationBar {
    [self setBackButton];
    [self setSaveButton];
    [self setNavigationTitle];
}

- (void) setBackButton {
    if([self canBeSaved]){
        self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed)];
        self.navigationItem.leftBarButtonItem = self.backButton;
    }
}

- (void) setSaveButton {
    if(!self.canBeSaved){
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.saveButton;        
    }
}

- (void) setNavigationTitle {
    if(self.assessmentIndex == self.assessments.count - 1) {
        if(self.canBeSaved){
            self.navigationItem.title = @"New Assessment";
        } else {
            NSString * newNavigationTitle = [NSString stringWithFormat:@"Assessment (%i of %i)", self.assessmentIndex+1, self.assessments.count];
            self.navigationItem.title = newNavigationTitle;
        }
    } else {
        NSString * newNavigationTitle = [NSString stringWithFormat:@"Assessment (%i of %i)", self.assessmentIndex+1, self.assessments.count];
        self.navigationItem.title = newNavigationTitle;
    }
}

- (void) setAssessmentHistoryArrows {
    if(self.assessmentIndex == 0){
        if(self.assessments.count > 1){
            self.nextAssessmentButton.hidden = NO;
            self.previousAssessmentButton.hidden = YES;
        } else {
            self.nextAssessmentButton.hidden = YES;
            self.previousAssessmentButton.hidden = YES;
        }
    } else if(self.assessmentIndex == self.assessments.count - 1) {
        self.nextAssessmentButton.hidden = YES;
        self.previousAssessmentButton.hidden = NO;
    } else {
        self.nextAssessmentButton.hidden = NO;
        self.previousAssessmentButton.hidden = NO;
    }
}

- (void) setGestures {
    [self.assessmentView addGestureRecognizer:self.swipeLeftRecognizer];
    [self.assessmentView addGestureRecognizer:self.swipeRightRecognizer];
    [self.assessmentView addGestureRecognizer:self.swipeDownRecognizer];
}

- (void) setTextView:(UITextView *)textView {
    textView.delegate = self;
    if(!self.assessment.date){
        [textView.layer setBorderColor: [[UIColor grayColor] CGColor]];
        [textView.layer setBorderWidth: 1.0];
        [textView.layer setCornerRadius:8.0f];
        [textView.layer setMasksToBounds:YES];
    } else {
        textView.backgroundColor = [UIColor whiteColor];
    }
}

- (void) setTextViews {
    [self setTextView:self.remarkAView];
    [self setTextView:self.remarkBView];
    [self setTextView:self.remarkCView];
}

- (void) setupDayNightSwitch {
    CGRect dayNightSwitchFrame = CGRectMake(600, 45, 79, 27);
    self.dayNightSwitch = [[DCRoundSwitch alloc] initWithFrame:dayNightSwitchFrame];
    [self.dayNightSwitch addTarget:self action:@selector(toggleDayNightSwitch:) forControlEvents:UIControlEventValueChanged];
    
    self.dayNightSwitch.onText = @"Night";
    self.dayNightSwitch.offText = @"Day";
    
    self.dayNightSwitch.onTintColor = [UIColor blackColor];
    self.dayNightSwitch.on = NO;
    
    
    [self.assessmentView addSubview:self.dayNightSwitch];
}

- (void) setControls {
    self.aircraftField.delegate = self;
    [self setTextViews];
    [self setupCrewmemberReadyButtons];
    [self setupDayNightSwitch];
    self.isNight = NO;
    self.clickedSaveButton = NO;
}

- (void) setNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInstructorName) name:@"credentials changed" object:nil];
}

#pragma mark - Keyboard methods

- (void) moveViewUp:(BOOL)upwards byAmount:(double)height{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect rect = self.scrollView.frame;
    if(upwards){
        rect.size.height = rect.size.height - height;
    } else if(!upwards){
        rect.size.height = rect.size.height + height;
    }
    self.scrollView.frame = rect;
    [self resizeViews];
    CGRect scrolledDownRect = CGRectMake(0, self.assessmentView.frame.size.height - rect.size.height, rect.size.width, rect.size.height);
    [self.scrollView scrollRectToVisible:scrolledDownRect animated:NO];
    
    [UIView commitAnimations];
}

- (double) getKeyboardHeight: (NSNotification *) notification {
    NSDictionary * info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize keyboardSize = keyboardFrame.size;
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        return keyboardSize.height;
    } else {
        return keyboardSize.width;
    }
}


- (void) keyboardDidShow:(NSNotification *)notification {
    if(self.keyboardVisible) {
        NSLog(@"Keyboard already visible. Ignoring superfluous notification.");
        return;
    }
    if(self.firstResponderTag >= 20 && self.firstResponderTag <= 22){
        self.scrollViewHeightOffset = [self getKeyboardHeight:notification];
        [self moveViewUp:YES byAmount:self.scrollViewHeightOffset];
    } else {
        self.scrollViewHeightOffset = 0;
    }
}

- (void) keyboardWillHide: (NSNotification *)notification {
    if(!(self.scrollViewHeightOffset == 0)) {
        [self moveViewUp:NO byAmount:self.scrollViewHeightOffset];
    }
}

#pragma mark - Utility

- (void) retryAction {
    if(self.clickedSaveButton) {
        [self sendAssessment];
    }
}

- (void) cancelAction {
    self.clickedSaveButton = NO;
}

- (void) returnToMainMenu {
    NSArray * viewControllers = [self.navigationController viewControllers];
    for(P4PViewController * viewController in viewControllers) {
        if([viewController isKindOfClass:[P4PMainMenuViewController class]]) {
            ((P4PAppDelegate *) [UIApplication sharedApplication].delegate).isReset = YES;
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}

- (NSString *) formattedDate {
    NSDate * date = self.assessment.date;
    if(!date) {
        date = [NSDate date];
    }
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString * dateString = [dateFormatter stringFromDate:date];

    return dateString;
}

- (NSData *) jsonRequestObjectSaveAssessment {
    NSURLCredential * credentials = self.connection.credentials;
    
    P4PAssessment * assessment = [self.assessments lastObject];
    NSMutableDictionary * requestDictionary = assessment.dictionary;
    [requestDictionary setValue:credentials.user forKey:@"fi"];
    [requestDictionary setValue:credentials.password forKey:@"password"];
    
//    NSData * jsonData = [requestDictionary toPrettyJSON];
    NSData * jsonData = [requestDictionary toJSON];
    
    return jsonData;
}

- (BOOL) canBeSaved {
    if(self.assessment.date){
        return NO;
    }
    int crewmemberID = 0;
    for(P4PResult * result in self.assessment.results){
        if(result.crewmember.id && result.crewmember.id.intValue != 0) {
            crewmemberID = result.crewmember.id.intValue;
            break;
        }
    }
    if(crewmemberID > 0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Gestures

- (IBAction) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self nextAssessmentButtonPressed:nil];        
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self previousAssessmentPressed:nil];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            [self.view endEditing:YES];
        }
    }
}

#pragma mark - Notification Observers

- (void) updateInstructorName {
    P4PAssessment * lastAssessment = [self.assessments lastObject];
    if(!lastAssessment.date) {
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        NSString * username = [settings stringForKey:@"username_preference"];
        username = [username uppercaseString];
        if([username isEqualToString:@"UNKNOWN"]) {
            username = @"Unknown";
        }
        lastAssessment.instructor = username;
        if([self canBeSaved]){
            self.instructorLabel.text = username;
        }
    }
}

#pragma mark - UITextField delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    switch (textField.tag) {
        case 12:
            self.assessment.session = newString;
            break;
        case 13:
            self.assessment.aircraft = newString;
        default:
            break;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([self.alertView.title isEqualToString:@"Save assessment"]){
        [self.alertView dismissWithClickedButtonIndex:1 animated:YES];
        [self alertView:self.alertView clickedButtonAtIndex:1];
    } else {
        [super textFieldShouldReturn:textField];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 12:
            self.assessment.session = textField.text;
            break;
        case 13:
            self.assessment.aircraft = textField.text;
        default:
            break;
    }
}

#pragma mark - UITextView delegates

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.firstResponderTag = textView.tag;
    return YES;
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView {
    self.firstResponderTag = 0;
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    switch (textView.tag) {
        case 20:
            [self.assessment resultForPosition:[NSNumber numberWithInt:0]].remarks = newString;
            break;
        case 21:
            [self.assessment resultForPosition:[NSNumber numberWithInt:1]].remarks = newString;
            break;
        case 22:
            [self.assessment resultForPosition:[NSNumber numberWithInt:2]].remarks = newString;
            break;            
        default:
            break;
    }
    return YES;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    [self.assessment resultForPosition:[NSNumber numberWithInt:textView.tag - 20]].remarks = textView.text;
}

#pragma mark - UIAlertView generators 

- (void) requestBackConfirmation:(UIViewController *) delegate {
    UIAlertView * requestBackConfirmationView = [[UIAlertView alloc] initWithTitle:@"Cancel assessment" message:@"Are you sure?" delegate:delegate cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    requestBackConfirmationView.alertViewStyle = UIAlertViewStyleDefault;
    self.alertView = requestBackConfirmationView;
    if(!((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert) {
        ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = YES;
        [requestBackConfirmationView show];
    }
}

- (void) confirmSaveAssessmentWithDelegate:(UIViewController *) delegate {
    UIAlertView * saveAssessmentAlertView = [[UIAlertView alloc] initWithTitle:@"Save assessment" message:nil delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];;
    self.alertView = saveAssessmentAlertView;
    if(!((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert) {
        ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = YES;
        [saveAssessmentAlertView show];
    }
}

#pragma mark - UIAlertView delegates

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = NO;    
    NSString * title = alertView.title;
    if([title isEqualToString:@"Save assessment"]){
        NSString * buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if([buttonTitle isEqualToString:@"OK"]){
            self.alertView = nil;
            [self sendAssessment];
        } else {
            self.clickedSaveButton = NO;
        }
    } else if([title isEqualToString:@"Cancel assessment"]) {
        NSString * buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if([buttonTitle isEqualToString:@"Yes"]){
            [self returnToMainMenu];
            self.alertView = nil;
        }
    }else {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

#pragma mark - UIViewController delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.assessments && self.assessments.count > 0){
        self.assessmentIndex = self.assessments.count - 1;
    }
    self.scrollView.delegate = self;
    
    [self setConnection];
    [self setCheckboxes];
    [self setGestures];
    [self setControls];
    [self setNotificationObservers];
    [self setAssessment:[self.assessments objectAtIndex:self.assessmentIndex]];
    
//    Debug info:
//    [self jsonRequestObjectSaveAssessment];
}

- (void) viewDidUnload {
    self.dayNightSwitch = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [self resizeViews];
}

- (void) viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.dayNightSwitch setOn:NO];
}

- (void) viewDidDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void) resizeViews {
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        CGSize correctedSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        CGRect correctedFrame = CGRectMake(0, 0, correctedSize.width, correctedSize.height);
        self.scrollView.contentSize = correctedSize;
        self.assessmentView.frame = correctedFrame;
    } else {
        CGSize correctedSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
        CGRect correctedFrame = CGRectMake(0, 0, correctedSize.width, correctedSize.height);
        self.scrollView.contentSize = correctedSize;
        self.assessmentView.frame = correctedFrame;
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self resizeViews];
}

@end
