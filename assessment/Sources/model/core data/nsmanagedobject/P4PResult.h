//
//  P4PResult.h
//  p4passessment
//
//  Created by Wouter Scholtens on 8/17/13.
//  Copyright (c) 2013 Wouter Scholtens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class P4PAssessment, P4PCrewmember;

@interface P4PResult : NSManagedObject

@property (nonatomic, retain) NSString * grades;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * remarks;
@property (nonatomic, retain) NSNumber * passed;
@property (nonatomic, retain) P4PAssessment *assessment;
@property (nonatomic, retain) P4PCrewmember *crewmember;

@end
