//
//  P4PAssessment+Remote.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PDatabaseController.h"
#import "P4PCrewmember+Remote.h"
#import "P4PAssessment+Remote.h"
#import "P4PResult+Remote.h"

@implementation P4PAssessment (Remote)

- (id)init {
    NSManagedObjectContext * context = [P4PDatabaseController sharedDatabaseController].managedObjectContext;
    NSEntityDescription * assessmentEntity = [NSEntityDescription entityForName:@"P4PAssessment" inManagedObjectContext:context];
    
    self = [super initWithEntity:assessmentEntity insertIntoManagedObjectContext:context];
    if (self) {}
    return self;
}

+ (P4PAssessment *) assessmentForDictionary:(NSDictionary *)dictionary {
    NSManagedObjectContext * context = [P4PDatabaseController sharedDatabaseController].managedObjectContext;
	NSEntityDescription * assessmentEntity = [NSEntityDescription entityForName:@"P4PAssessment" inManagedObjectContext:context];

    P4PAssessment * assessment = [[P4PAssessment alloc] initWithEntity:assessmentEntity insertIntoManagedObjectContext:context];
    
    NSString * timestampString = [dictionary valueForKey:@"date"];
    int timestamp = timestampString.intValue;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timestamp];

    assessment.crew = [dictionary valueForKey:@"crew"];
    assessment.date = date;
    assessment.package = [dictionary valueForKey:@"package"];
    assessment.session = [dictionary valueForKey:@"session"];
    assessment.aircraft = [dictionary valueForKey:@"ac"];
    assessment.instructor = [dictionary valueForKey:@"fi"];
    
    NSNumber * idA = [NSNumber numberWithInt:[[dictionary valueForKey:@"a"] integerValue]] ;
    NSString * nameA = [dictionary valueForKey:@"a_name"];
    NSString * remarksA = [dictionary valueForKey:@"a_remarks"];
    NSString * gradesA = [dictionary valueForKey:@"a_list"];

    NSNumber * idB = [NSNumber numberWithInt:[[dictionary valueForKey:@"b"] integerValue]];
    NSString * nameB = [dictionary valueForKey:@"b_name"];
    NSString * remarksB = [dictionary valueForKey:@"b_remarks"];
    NSString * gradesB = [dictionary valueForKey:@"b_list"];
    
    NSNumber * idC = [NSNumber numberWithInt:[[dictionary valueForKey:@"c"] integerValue]];
    NSString * nameC = [dictionary valueForKey:@"c_name"];
    NSString * remarksC = [dictionary valueForKey:@"c_remarks"];
    NSString * gradesC = [dictionary valueForKey:@"c_list"];
    
    NSNumber * passA = [NSNumber numberWithBool:[[dictionary valueForKey:@"a_ready"] boolValue]];
    NSNumber * passB = [NSNumber numberWithBool:[[dictionary valueForKey:@"b_ready"] boolValue]];
    NSNumber * passC = [NSNumber numberWithBool:[[dictionary valueForKey:@"c_ready"] boolValue]];
    
    P4PResult * resultA = [P4PResult resultForCrewmemberName:nameA withCrewmemberID:idA withGrades:gradesA withRemarks:remarksA withAssessment:assessment withPosition:[NSNumber numberWithInt:0] didPass:passA];
    P4PResult * resultB = [P4PResult resultForCrewmemberName:nameB withCrewmemberID:idB withGrades:gradesB withRemarks:remarksB withAssessment:assessment withPosition:[NSNumber numberWithInt:1] didPass:passB];
    P4PResult * resultC = [P4PResult resultForCrewmemberName:nameC withCrewmemberID:idC withGrades:gradesC withRemarks:remarksC withAssessment:assessment withPosition:[NSNumber numberWithInt:2] didPass:passC];
    
    NSMutableSet * results = [[NSMutableSet alloc] init];    
    [results addObject:resultA];
    [results addObject:resultB];
    [results addObject:resultC];
    
    assessment.results = results;
    
    return assessment;
}

#pragma mark - Utility

- (NSDictionary *) dictionary {
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setValue:self.session forKey:@"session"];
    [dictionary setValue:self.aircraft forKey:@"ac"];
    [dictionary setValue:self.crew forKey:@"crew"];
    [dictionary setValue:self.instructor forKey:@"fi"];
    
    NSString * positionKey;
    for(P4PResult * result in self.results){
        switch ([result.position intValue]) {
            case 0:
                positionKey = @"a";
                break;
            case 1:
                positionKey = @"b";
                break;
            case 2:
                positionKey = @"c";
                break;
            default:
                positionKey = @"x";
                break;
        }
        if(result.crewmember.id.intValue != 0){
            NSString * idString = [NSString stringWithFormat:@"%i", [result.crewmember.id intValue]];
            [dictionary setValue:idString forKey:positionKey];
            [dictionary setValue:result.grades forKey:[NSString stringWithFormat:@"%@%@", positionKey, @"_list"]];
            [dictionary setValue:result.remarks forKey:[NSString stringWithFormat:@"%@%@", positionKey, @"_remarks"]];
            [dictionary setValue:result.passed forKey:[NSString stringWithFormat:@"%@%@", positionKey, @"_ready"]];
        }
    }
    return dictionary;
}

- (P4PResult *) resultForPosition:(NSNumber *)position {
    for (P4PResult * result in self.results) {
        if([result.position isEqualToNumber:position]) {
            return result;
        }
    }
    return nil;
}

- (P4PCrewmember *) crewmemberForPosition:(NSNumber *)position {
    P4PResult * result = [self resultForPosition:position];
    if(result) {
        return [result crewmember];
    } else {
        return nil;
    }
}


@end
