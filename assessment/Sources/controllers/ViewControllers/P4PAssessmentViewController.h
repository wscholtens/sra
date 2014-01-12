//
//  P4PAssessmentViewController.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PViewController.h"

@interface P4PAssessmentViewController : P4PViewController <UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSArray * assessments;

@end
