//
//  P4PResult+Remote.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PResult+Remote.h"
#import "P4PCrewmember+Remote.h"
#import "P4PDatabaseController.h"

@implementation P4PResult (Remote)

+ (P4PResult *) emptyResult {
    NSManagedObjectContext * context = [P4PDatabaseController sharedDatabaseController].managedObjectContext;
	NSEntityDescription * resultEntity = [NSEntityDescription entityForName:@"P4PResult" inManagedObjectContext:context];
    
    P4PResult * result = [[P4PResult alloc] initWithEntity:resultEntity insertIntoManagedObjectContext:context];
    return result;
}

+ (P4PResult *)resultWithCrewmemberName:(NSString *)name withCrewmemberID:(NSNumber *)id withPosition:(NSNumber *)position {
    P4PResult * result = [P4PResult emptyResult];
    result.crewmember = [P4PCrewmember crewmemberWithName:name withID:id];
    result.position = position;
    return result;
}

+ (P4PResult *)resultForCrewmemberName:(NSString *)crewmemberName withCrewmemberID:(NSNumber *)crewmemberID withGrades:(NSString *)grades withRemarks:(NSString *)remarks withAssessment:(P4PAssessment *)assessment withPosition:(NSNumber *)position didPass:(NSNumber *)hasPassed {
    P4PResult * result = [P4PResult emptyResult];
    
    NSSet * results = [[NSSet alloc] initWithObjects:result, nil];
    
    result.crewmember = [P4PCrewmember crewmemberWithName:crewmemberName withID:crewmemberID withResults:results];
    result.grades = grades;
    result.remarks = remarks;
    result.assessment = assessment;
    result.position = position;
    result.passed = hasPassed;
    
    return result;
}

@end
