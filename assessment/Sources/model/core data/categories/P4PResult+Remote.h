//
//  P4PResult+Remote.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PResult.h"

@interface P4PResult (Remote)

+ (P4PResult *)resultWithCrewmemberName:(NSString *)name withCrewmemberID:(NSNumber *)id withPosition:(NSNumber *)position;
+ (P4PResult *)resultForCrewmemberName:(NSString *)crewmemberName withCrewmemberID:(NSNumber *)crewmemberID withGrades:(NSString *)grades withRemarks:(NSString *)remarks withAssessment:(P4PAssessment *)assessment withPosition:(NSNumber *)position didPass:(NSNumber *)hasPassed;

@end
