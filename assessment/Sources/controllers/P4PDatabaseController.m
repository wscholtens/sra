//
//  P4PDatabaseController.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/28/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PDatabaseController.h"
#import <CoreData/CoreData.h>

static P4PDatabaseController * _sharedDatabaseController = nil;

@implementation P4PDatabaseController

#pragma mark - Singleton access

+ (P4PDatabaseController *) sharedDatabaseController {
    @synchronized([P4PDatabaseController class]) {
        if(!_sharedDatabaseController) {
            _sharedDatabaseController = [[P4PDatabaseController alloc] init];
            if (!_sharedDatabaseController.isDatabaseOpen) {
                [_sharedDatabaseController openDatabase];
            }
        }
        return _sharedDatabaseController;
    }
    return nil;
}

#pragma mark - Maintenance Utility

- (BOOL) saveContext {
    NSLog(@"SAVING DATABASE CONTEXT");
    NSError *error;
    BOOL isSuccessful = [self.managedObjectContext save:&error];
    if(!isSuccessful){
        NSLog(@"ERROR: DATABASE COULD NOT BE SAVED: %@", error.description);
    }
    return isSuccessful;
}

- (BOOL) purge {
//    NSLog(@"Purging database");
    NSArray * persistentStores = self.persistentStoreCoordinator.persistentStores;
    NSError * error;
    for(NSPersistentStore * persistentStore in persistentStores){
        [self.persistentStoreCoordinator removePersistentStore:persistentStore error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:persistentStore.URL.path error:&error];
    }
    self.persistentStoreCoordinator = nil;
    self.managedObjectContext = nil;
    self.managedObjectModel = nil;
    if(error) {
        NSLog(@"Database purge error: %@", error.localizedDescription);
        return NO;
    }
    return YES;
}

- (void)openDatabase {
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
}

- (BOOL)isDatabaseOpen {
    BOOL isDatabaseOpen = YES;
    if (!self.managedObjectContext || !self.managedObjectContext.persistentStoreCoordinator) {
        isDatabaseOpen = NO;
    }
    return isDatabaseOpen;
}

#pragma mark - Database properties

- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.PersistentStoreCoordinator = coordinator;
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [self.applicationDocumentsDirectory URLByAppendingPathComponent: @"P4PDatabase.sqlite"];
	
	NSError * error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle the error.
    }
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}




@end
