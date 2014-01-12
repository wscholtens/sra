//
//  P4PCrewmember.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface P4PCrewmember : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * crew;
@property (nonatomic, retain) NSSet *results;
@end

@interface P4PCrewmember (CoreDataGeneratedAccessors)

- (void)addResultsObject:(NSManagedObject *)value;
- (void)removeResultsObject:(NSManagedObject *)value;
- (void)addResults:(NSSet *)values;
- (void)removeResults:(NSSet *)values;

@end
