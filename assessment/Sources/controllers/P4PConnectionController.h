//
//  P4PConnectionController.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/24/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol P4PConnectionProtocol <NSObject>
@optional
- (void) badCredentials;
- (void) badCredentialsWithMessage:(NSString *)message;
- (void) errorWithMessage:(NSString *)error;
@end

@interface P4PConnectionController : NSObject

@property (nonatomic, strong) NSURL * url;
@property (nonatomic, weak) id <P4PConnectionProtocol> delegate;

#pragma mark - Lifecycle
- (id) initWithDelegate:(id)delegate withURL:(NSURL *)url;

#pragma mark - Core functionality
- (NSDictionary *) sendSynchronousJSON:(NSData *)JSON;

#pragma mark - Utility
- (NSURLProtectionSpace *) protectionSpaceForP4P;
- (NSURLCredential *) credentials;
- (void) saveUsername:(NSString *)username withPassword:(NSString *)password;
- (NSString *) dummyPasswordForActualPassword:(NSString *)password;
- (BOOL) hasCredentials;


@end
