//
//  P4PMainMenuViewController.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/20/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PMainMenuViewController.h"
#import "P4PAssessmentViewController.h"
#import "P4PConnectionController.h"
#import "P4PAssessment+Remote.h"
#import "NSDictionary+JSon.h"
#import "MBProgressHUD.h"
#import "P4PAppDelegate.h"

@interface P4PMainMenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton * startAssessmentButton;
@property (weak, nonatomic) IBOutlet UIButton * previousAssessmentsButton;
@property (weak, nonatomic) IBOutlet UIImageView * backgroundImageView;
@property (nonatomic) BOOL clickedMyAssessments;
@property (nonatomic) BOOL clickedNewAssessment;
@property (strong, nonatomic) NSArray * instructorHistory;
@end

@implementation P4PMainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)newAssessment:(id)sender {
    self.clickedNewAssessment = YES;
    self.clickedMyAssessments = NO;
}

- (IBAction)myAssessments:(id)sender {
    self.clickedNewAssessment = NO;
    self.clickedMyAssessments = YES;
    NSURL * myAssessmentsUrl = [NSURL URLWithString:@"/request/get_fi_assessments.php"];
    self.connection = [[P4PConnectionController alloc] initWithDelegate:self withURL:myAssessmentsUrl];
    
    if(self.connection.hasCredentials) {
        [self showMyAssessments];
    } else {
        [self requestUserCredentialsWithDelegate:self];
    }
}

#pragma mark - Core functionality

- (void) continueShowMyAssessments {
    NSURLCredential * credentials = self.connection.credentials;
    NSInteger assessmentCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"history_preference"];
    
    NSDictionary * responseDictionary;
    if(credentials.user && credentials.password) {
        NSData * JSON = [self jsonRequestObjectInstructorAssessmentsWithUsername:credentials.user withPassword:credentials.password withCount:assessmentCount];
        responseDictionary = [self.connection sendSynchronousJSON:JSON];
        if(responseDictionary && ![responseDictionary valueForKey:@"error"]){
            self.instructorHistory = [self assessmentsFromJSONDictionary:responseDictionary];
            self.instructorHistory = [self sortAssessments:self.instructorHistory];
            [self performSegueWithIdentifier: @"pushToMyAssessments" sender:self];
        } else {
            NSError * error = [responseDictionary valueForKey:@"error"];
            if(!error) {
                [self showError:@"Server response invalid"];
            } else {
                [self showError:error.localizedDescription];
            }
        }
    } else {
        [self requestUserCredentialsWithDelegate:self];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];      
}

- (void) showMyAssessments {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    [self performSelector:@selector(continueShowMyAssessments) withObject:nil afterDelay:0.1];
}

- (NSArray *) sortAssessments:(NSArray *)assessments {    
    NSSortDescriptor * sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedAssessments = [assessments sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedAssessments;
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"pushToMyAssessments"]){
        P4PAssessmentViewController * assessmentViewController = [segue destinationViewController];
        assessmentViewController.assessments = self.instructorHistory;
    }
}

#pragma mark - Utility

- (void) retryAction {
    if(!self.connection.hasCredentials) {
        [self requestUserCredentialsWithDelegate:self];
    } else {
        if(!((P4PAppDelegate *) [UIApplication sharedApplication].delegate).isReset) {
            if(self.clickedMyAssessments && self.isViewLoaded && self.view.window){
                [self showMyAssessments];
            } 
        } else {
            ((P4PAppDelegate *) [UIApplication sharedApplication].delegate).isReset = NO;
        }
    }
}

- (void) cancelAction { 
    self.clickedMyAssessments = NO;
    self.clickedNewAssessment = NO;
}

- (NSArray *) assessmentsFromJSONDictionary:(NSDictionary *)dictionary {
    NSMutableArray * assessments = [[NSMutableArray alloc] init];
    NSArray * flights = [dictionary valueForKey:@"flights"];
    for(NSDictionary * dictionary in flights){
        [assessments addObject:[P4PAssessment assessmentForDictionary:dictionary]];
    }
    return assessments;
}

- (NSData *) jsonRequestObjectInstructorAssessmentsWithUsername:(NSString *)username withPassword:(NSString *)password withCount:(NSInteger) count {
    NSString * countString = [NSString stringWithFormat:@"%i", count];
    
    NSMutableDictionary * requestDictionary = [[NSMutableDictionary alloc] init];
    [requestDictionary setValue:username forKey:@"fi"];
    [requestDictionary setValue:password forKey:@"password"];
    [requestDictionary setValue:countString forKey:@"limit"];
    
    NSData * jsonData = [requestDictionary toJSON];
    
    return jsonData;
}

#pragma mark - UIViewController delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clickedMyAssessments = NO;
    self.clickedNewAssessment = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    self.backgroundImageView.image = [self randomBackgroundImage];
}

- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

@end
