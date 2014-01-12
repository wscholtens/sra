//
//  P4PCrewmember+Remote.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PCrewmember+Remote.h"
#import "P4PDatabaseController.h"

@implementation P4PCrewmember (Remote)

+ (P4PCrewmember *) crewmemberWithName:(NSString *)name {
    NSManagedObjectContext * context = [P4PDatabaseController sharedDatabaseController].managedObjectContext;
	NSEntityDescription * crewmemberEntity = [NSEntityDescription entityForName:@"P4PCrewmember" inManagedObjectContext:context];
    
    P4PCrewmember * crewmember = [[P4PCrewmember alloc] initWithEntity:crewmemberEntity insertIntoManagedObjectContext:context];
    crewmember.name = name;
    
    return crewmember;
}

+ (P4PCrewmember *) crewmemberWithName:(NSString *)name withID:(NSNumber *)id {
    P4PCrewmember * crewmember = [P4PCrewmember crewmemberWithName:name];
    crewmember.id = id;
    return crewmember;
}

+ (P4PCrewmember *) crewmemberWithName:(NSString *)name withID:(NSNumber *)id withResults:(NSSet *)results{
    P4PCrewmember * crewmember = [P4PCrewmember crewmemberWithName:name withID:id];
    crewmember.results = results;
    return crewmember;
}

@end
