//
//  P4PDatabaseController.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface P4PDatabaseController : NSObject

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;

+ (P4PDatabaseController *) sharedDatabaseController;

- (BOOL) saveContext;
- (BOOL) purge;
- (NSURL *) applicationDocumentsDirectory;

@end
