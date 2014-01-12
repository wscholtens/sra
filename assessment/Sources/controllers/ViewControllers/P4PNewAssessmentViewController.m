//
//  P4PNewAssessmentViewController.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/20/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "P4PNewAssessmentViewController.h"
#import "P4PAssessmentViewController.h"
#import "P4PConnectionController.h"
#import "P4PAssessment+Remote.h"
#import "P4PResult+Remote.h"
#import "P4PCrewmember+Remote.h"
#import "NSDictionary+JSon.h"
#import "MBProgressHUD.h"
#import "P4PAppDelegate.h"

@interface P4PNewAssessmentViewController ()
@property (nonatomic, strong) IBOutlet UIButton * crewMemberIDButton;
@property (nonatomic, strong) IBOutlet UILabel * assessmentNewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic) BOOL clickedCrewmemberID;

@property (nonatomic, strong) NSString * package;
@property (nonatomic, strong) NSString * crewmemberIDA;
@property (nonatomic, strong) NSString * crewmemberIDB;
@property (nonatomic, strong) NSString * crewmemberIDC;
@property (nonatomic, strong) NSString * crewmemberNameA;
@property (nonatomic, strong) NSString * crewmemberNameB;
@property (nonatomic, strong) NSString * crewmemberNameC;
@property (nonatomic, strong) NSString * session;

@property (strong, nonatomic) NSArray * assessments;

@end

@implementation P4PNewAssessmentViewController

#pragma mark - IBActions

- (IBAction)crewmemberID:(id)sender {
    self.clickedCrewmemberID = YES;
    if(self.connection.hasCredentials){
        [self requestIDForCrewmember:[NSNumber numberWithInt:0] withDelegate:self];
    } else {
        [self requestUserCredentialsWithDelegate:self];
    }
}

#pragma mark - Core functionality

- (void) continueShowNewAssessmentByCrewmembers {
    NSURL * newAssessmentUrl = [NSURL URLWithString:@"/request/new_assessment_id.php"];
    self.connection = [[P4PConnectionController alloc] initWithDelegate:self withURL:newAssessmentUrl];
    
    NSDictionary * responseDictionary = nil;
    NSData * requestJSON = [self jsonRequestObjectNewAssessmentWithCrewmemberIDA:self.crewmemberIDA withCrewmemberIDB:self.crewmemberIDB withCrewmemberIDC:self.crewmemberIDC withCredentials:self.connection.credentials];
    responseDictionary = [self.connection sendSynchronousJSON:requestJSON];
    if(responseDictionary && ![responseDictionary valueForKey:@"error"]){
        self.crewmemberNameA = [responseDictionary valueForKey:@"a_name"];
        self.crewmemberNameB = [responseDictionary valueForKey:@"b_name"];
        self.crewmemberNameC = [responseDictionary valueForKey:@"c_name"];
        self.session = [responseDictionary valueForKey:@"session"];
        
        self.assessments = [self assessmentsFromJSONDictionary:responseDictionary];
        self.assessments = [self sortAssessments:self.assessments];
        
        [self addNewAssessment];
        [self performSegueWithIdentifier: @"pushToAssessments" sender:self];
        [self clearInputData];
        self.clickedCrewmemberID = NO;        
    } else {
        NSError * error = [responseDictionary valueForKey:@"error"];
        if(!error) {
            [self showError:@"Server response invalid"];
        } else {
            [self showError:error.localizedDescription];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) showNewAssessmentByCrewmembers {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    [self performSelector:@selector(continueShowNewAssessmentByCrewmembers) withObject:nil afterDelay:0.1];
}

#pragma mark - Utility

- (void) clearInputData {
    self.crewmemberNameA = nil;
    self.crewmemberNameB = nil;
    self.crewmemberNameC = nil;
    self.crewmemberIDA = nil;
    self.crewmemberIDB = nil;
    self.crewmemberIDC = nil;
    
    self.package = nil;
    self.assessments = nil;
}

- (NSArray *) sortAssessments:(NSArray *)assessments {
    NSSortDescriptor * sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedAssessments = [assessments sortedArrayUsingDescriptors:sortDescriptors];
    return sortedAssessments;
}

- (void) retryAction {
    if(![self.connection hasCredentials]){
        [self requestUserCredentialsWithDelegate:self];
    } else {
        if(self.clickedCrewmemberID && self.isViewLoaded && self.view.window){
            if(self.crewmemberIDA) {
                [self showNewAssessmentByCrewmembers];
            } else {
                [self requestIDForCrewmember:[NSNumber numberWithInt:0] withDelegate:self];
            }
        }
    }
}

- (void) cancelAction {
    self.clickedCrewmemberID = NO;
    self.crewmemberIDA = nil;
    self.crewmemberIDB = nil;
    self.crewmemberIDC = nil;
}

- (NSArray *) assessmentsFromJSONDictionary:(NSDictionary *)dictionary {
    self.crewmemberIDA = [dictionary valueForKey:@"a"];
    self.crewmemberIDB = [dictionary valueForKey:@"b"];
    self.crewmemberIDC = [dictionary valueForKey:@"c"];
    self.crewmemberNameA = [dictionary valueForKey:@"a_name"];
    self.crewmemberNameB = [dictionary valueForKey:@"b_name"];
    self.crewmemberNameC = [dictionary valueForKey:@"c_name"];
    
    id flights = [dictionary valueForKey:@"flights"];
    
    NSMutableArray * assessments = [[NSMutableArray alloc] init];
    NSMutableDictionary * mutableAssessmentDictionary;
    if([flights isKindOfClass:[NSArray class]]){
        for(NSDictionary * assessmentDictionary in flights){
            mutableAssessmentDictionary = [assessmentDictionary mutableCopy];
            [mutableAssessmentDictionary setValue:self.crewmemberIDA forKey:@"a"];
            [mutableAssessmentDictionary setValue:self.crewmemberIDB forKey:@"b"];
            [mutableAssessmentDictionary setValue:self.crewmemberIDC forKey:@"c"];
            NSDictionary * modifiedAssessmentDictionary = mutableAssessmentDictionary;
            [assessments addObject:[P4PAssessment assessmentForDictionary:modifiedAssessmentDictionary]];
        }
    }
    return assessments;
}

- (NSString *) crewmemberNameForID:(NSString *)crewmemberID {
    BOOL found = NO;
    NSString * crewmemberName;
    for(P4PAssessment * assessment in self.assessments) {
        for(P4PResult * result in assessment.results){
            if([result.crewmember.id.stringValue isEqualToString:crewmemberID]){
                found = YES;
                crewmemberName = result.crewmember.name;
                break;
            }
        }
        if(found){
            break;
        }
    }
    return crewmemberName;
}

- (NSNumber *) numberFromString:(NSString *)string {
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * number = [formatter numberFromString:string];
    return number;
}

#pragma mark - New Assessment

- (void) addNewAssessment {
    P4PAssessment * assessment = [[P4PAssessment alloc] init];
    
    if(self.clickedCrewmemberID){
        assessment.crew = nil;
    } 
    assessment.aircraft = [self newAircraft];
    assessment.instructor = [self.connection.credentials.user uppercaseString];
    assessment.results = [self newResults];
    assessment.package = self.package;
    
    NSMutableArray * mutableAssessments = [self.assessments mutableCopy];
    [mutableAssessments addObject:assessment];
    self.assessments = (NSArray *) mutableAssessments;
}

- (NSSet *)newResults {
    NSNumber * crewmemberIDA = [self numberFromString:self.crewmemberIDA];
    NSNumber * crewmemberIDB = [self numberFromString:self.crewmemberIDB];
    NSNumber * crewmemberIDC = [self numberFromString:self.crewmemberIDC];
    
    NSString * grades = @"00000000000000000";

    P4PResult * resultA = nil;
    P4PResult * resultB = nil;
    P4PResult * resultC = nil;
    
    if(self.crewmemberNameA && ![self.crewmemberNameA isEqualToString:@""]){
        resultA = [P4PResult resultWithCrewmemberName:self.crewmemberNameA withCrewmemberID:crewmemberIDA withPosition:[NSNumber numberWithInt:0]];
        resultA.grades = grades;
    }
    if(self.crewmemberNameB && ![self.crewmemberNameB isEqualToString:@""]){
        resultB = [P4PResult resultWithCrewmemberName:self.crewmemberNameB withCrewmemberID:crewmemberIDB withPosition:[NSNumber numberWithInt:1]];
        resultB.grades = grades;        
    }
    if(self.crewmemberNameC && ![self.crewmemberNameC isEqualToString:@""]){
        resultC = [P4PResult resultWithCrewmemberName:self.crewmemberNameC withCrewmemberID:crewmemberIDC withPosition:[NSNumber numberWithInt:2]];
        resultC.grades = grades;        
    }

    NSMutableSet * results = [NSMutableSet setWithObjects:resultA, resultB, resultC, nil];

    return results;
}

- (NSString *) newAircraft {
    P4PAssessment * lastAssessment = [self.assessments lastObject];
    return lastAssessment.aircraft;
}

#pragma mark - JSON

- (NSData *) jsonRequestObjectNewAssesmentWithCrewID:(NSString *)crewID withCredentials:(NSURLCredential *)credentials{
    NSMutableDictionary * requestDictionary = [[NSMutableDictionary alloc] init];
    [requestDictionary setValue:credentials.user forKey:@"fi"];
    [requestDictionary setValue:credentials.password forKey:@"password"];
    [requestDictionary setValue:crewID forKey:@"crew"];
    
    NSData * jsonData = [requestDictionary toJSON];
    return jsonData;
}

- (NSData *) jsonRequestObjectNewAssessmentWithCrewmemberIDA:(NSString *)crewmemberIDA withCrewmemberIDB:(NSString *)crewmemberIDB withCrewmemberIDC:(NSString *)crewmemberIDC withCredentials:(NSURLCredential *)credentials {
    NSMutableDictionary * requestDictionary = [[NSMutableDictionary alloc] init];
    [requestDictionary setValue:credentials.user forKey:@"fi"];
    [requestDictionary setValue:credentials.password forKey:@"password"];
    [requestDictionary setValue:crewmemberIDA forKey:@"a"];
    [requestDictionary setValue:crewmemberIDB forKey:@"b"];
    [requestDictionary setValue:crewmemberIDC forKey:@"c"];
    
    NSData * jsonData = [requestDictionary toJSON];
    return jsonData;
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"pushToAssessments"]){
        P4PAssessmentViewController * assessmentViewController = [segue destinationViewController];
        assessmentViewController.assessments = self.assessments;
    }
}


#pragma mark - UIAlertView Generators

- (void) requestIDForCrewmember:(NSNumber *)crewmemberNumber withDelegate:(UIViewController *) delegate {
    NSString * message = [NSString stringWithFormat:@"Enter Crew Member %i", [crewmemberNumber intValue]+1];
    
    UIAlertView * requestCrewIDView = [[UIAlertView alloc] initWithTitle:@"Crew Member ID" message:message delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    requestCrewIDView.tag = [crewmemberNumber intValue] + 50;
    requestCrewIDView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [requestCrewIDView textFieldAtIndex:0].delegate = self;
    [[requestCrewIDView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];    
    self.alertView = requestCrewIDView;
    if(!((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert) {
        ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = YES;
        [requestCrewIDView show];
    }
}

- (NSString *) convertCrewmemberNumberToCrewmemberString:(NSNumber *)crewmemberNumber {
    NSString * crewmemberString = @"";    
    switch ([crewmemberNumber intValue]) {
        case 1:
            crewmemberString = @"A";
            break;
        case 2:
            crewmemberString = @"B";
            break;
        case 3:
            crewmemberString = @"C";
            break;
        default:
            crewmemberString = @"X";
            break;
    }
    return crewmemberString;
}

#pragma mark - UIAlertView delegates

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ((P4PAppDelegate *)[UIApplication sharedApplication].delegate).hasAlert = NO;  
    NSString * title = alertView.title;
    if([title isEqualToString:@"Crew Member ID"]){
        [self handleCrewmemberView:alertView withButtonClickedAtIndex:buttonIndex];
    } else if([title isEqualToString:@"Error"]) {
        [[self navigationController] popToRootViewControllerAnimated:YES];
    } else {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void) handleCrewmemberView:(UIAlertView *) alertView withButtonClickedAtIndex:(NSInteger) buttonIndex {
    NSString * buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"OK"]){
        NSString * inputText = [alertView textFieldAtIndex:0].text;
        if(alertView.tag == 50){
            [self clearInputData];
            if(inputText && ![inputText isEqualToString:@""]){
                self.crewmemberIDA = inputText;
                [self requestIDForCrewmember:[NSNumber numberWithInt:1] withDelegate:self];
            } else {
                [self errorWithMessage:@"The ID for crew member A is mandatory!"];
            }
        } else if(alertView.tag == 51){
            if(inputText && ![inputText isEqualToString:@""]){
                self.crewmemberIDB = inputText;
                [self requestIDForCrewmember:[NSNumber numberWithInt:2] withDelegate:self];
            } else {
                [self showNewAssessmentByCrewmembers];
                self.alertView = nil;
            }
        } else if(alertView.tag == 52){
            self.crewmemberIDC = inputText;
            [self showNewAssessmentByCrewmembers];
            self.alertView = nil;
        }
    } else {
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if(alertView.tag == 50){
        NSString * inputText = [alertView textFieldAtIndex:0].text;
        if(inputText.length == 0) {
            return NO;
        }
    } else if([alertView.title isEqualToString:@"Crew #"]){
        NSString * inputText = [alertView textFieldAtIndex:0].text;
        if(inputText.length == 0) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([self.alertView.title isEqualToString:@"Crew #"]){
        if([self.alertView textFieldAtIndex:0].text.length > 0) {
            [self.alertView dismissWithClickedButtonIndex:1 animated:YES];
            [self alertView:self.alertView clickedButtonAtIndex:1];
        } else {
            return NO;
        }
    } else if([self.alertView.title isEqualToString:@"Crew Member ID"]){
        if(self.alertView.tag == 50){
            if([self.alertView textFieldAtIndex:0].text.length > 0) {
                [self.alertView dismissWithClickedButtonIndex:1 animated:YES];
                [self alertView:self.alertView clickedButtonAtIndex:1];
            } else {
                return NO;
            }
        } else {
            [self.alertView dismissWithClickedButtonIndex:1 animated:YES];
            [self alertView:self.alertView clickedButtonAtIndex:1];
        }
    } else {
        [super textFieldShouldReturn:textField];
    }
    return YES;
}

#pragma mark - UIViewController delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL * newAssessmentUrl = [NSURL URLWithString:@"/request/new_assessment_crew.php"];
    self.connection = [[P4PConnectionController alloc] initWithDelegate:self withURL:newAssessmentUrl];
    [self crewmemberID:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    self.backgroundImageView.image = [self randomBackgroundImage];
}

- (void)viewDidUnload {
    [self setAssessmentNewLabel:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

@end
