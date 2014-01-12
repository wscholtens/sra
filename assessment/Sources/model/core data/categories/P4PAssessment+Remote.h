//
//  P4PAssessment+Remote.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PAssessment.h"
#import "P4PCrewmember+Remote.h"

@interface P4PAssessment (Remote)

+ (P4PAssessment *) assessmentForDictionary:(NSDictionary *)dictionary;

#pragma mark - Utility

- (NSMutableDictionary *) dictionary;
- (P4PCrewmember *) crewmemberForPosition:(NSNumber *)position;
- (P4PResult *) resultForPosition:(NSNumber *)position;

@end
