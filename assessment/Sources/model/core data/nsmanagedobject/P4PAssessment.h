//
//  P4PAssessment.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 10/12/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class P4PResult;

@interface P4PAssessment : NSManagedObject

@property (nonatomic, retain) NSString * aircraft;
@property (nonatomic, retain) NSString * crew;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * instructor;
@property (nonatomic, retain) NSString * session;
@property (nonatomic, retain) NSString * package;
@property (nonatomic, retain) NSSet *results;
@end

@interface P4PAssessment (CoreDataGeneratedAccessors)

- (void)addResultsObject:(P4PResult *)value;
- (void)removeResultsObject:(P4PResult *)value;
- (void)addResults:(NSSet *)values;
- (void)removeResults:(NSSet *)values;

@end
