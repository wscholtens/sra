//
//  P4PCrewmember+Remote.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PCrewmember.h"

@interface P4PCrewmember (Remote)

+ (P4PCrewmember *) crewmemberWithName:(NSString *)name;
+ (P4PCrewmember *) crewmemberWithName:(NSString *)name withID:(NSNumber *)id;
+ (P4PCrewmember *) crewmemberWithName:(NSString *)name withID:(NSNumber *)id withResults:(NSSet *)results;

@end
