//
//  P4PConnectionController.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/24/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "P4PConnectionController.h"
#import "NSDictionary+JSon.h"

@interface P4PConnectionController ()
@property (nonatomic, strong) NSString * baseUrl;
@end

@implementation P4PConnectionController

#pragma mark - Lifecycle

- (id)initWithDelegate:(id) delegate withURL:(NSURL *)url{
    self = [super init];
    if (self) {
        self.baseUrl = @"https://simrentdb.nl";
        
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseUrl, url]];
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Core functionality

- (NSDictionary *) sendSynchronousJSON:(NSData *)JSON {
    //print out the request data contents for debugging purposes
    NSLog(@"URL: %@", [self.url absoluteString]);
    
    NSString * requestString = [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding];    
    NSLog(@"JSON request: %@", requestString);
    
    NSURLRequest * JSONRequest = [self requestWithJSON:JSON];
    
    NSError * errorReturned = nil;
    NSURLResponse * theResponse =[[NSURLResponse alloc]init];
    NSData * responseData = [NSURLConnection sendSynchronousRequest:JSONRequest returningResponse:&theResponse error:&errorReturned];
    
    //print out the actual response data without json dictionary formatting contents for debugging purposes
    NSString * dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON response: %@", dataString);

    NSDictionary * responseJSON = nil;
    if (errorReturned) {
        NSLog(@"Connection JSON Send ERROR: %@", errorReturned.localizedDescription);
        [self.delegate errorWithMessage:errorReturned.localizedDescription];
    } else {
        [self logJSONData:responseData];
        responseJSON = [NSDictionary dictionaryWithContentsOFJSONData:responseData];
        if([self verifyIsErrorMessage:responseJSON]){
            responseJSON = nil;
        }
    }
    return responseJSON;
}

#pragma mark - Utility 

- (BOOL) hasCredentials {
    if(!self.credentials.user || [self.credentials.user isEqualToString:@""] || [self.credentials.user isEqualToString:@"Unknown"]) {
        return NO;
    }
    if(!self.credentials.password || [self.credentials.password isEqualToString:@""] || [self.credentials.password isEqualToString:@"Unknown"]) {
        return NO;
    }
    return YES;
}

- (BOOL) verifyIsErrorMessage:(NSDictionary *)JSON {
    BOOL isErrorMessage = NO;
    NSString * errorMessage = [JSON valueForKey:@"error"];
    if([errorMessage isEqualToString:@"Login invalid!"]){
        [self clearCredentials];        
        [self.delegate badCredentials];
        isErrorMessage = YES;
    } else if([errorMessage isEqualToString:@"You are using your e-mail. Use your 3 digit code. Close the app and start again."]) {
        [self.delegate badCredentialsWithMessage:@"You are using your email. Use your 3 digit code instead."];
    } else if (errorMessage) {
        [self.delegate errorWithMessage:errorMessage];
    }
    return isErrorMessage;
}

- (void) clearCredentials {
    if(self.credentials) {
        [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:self.credentials forProtectionSpace:self.protectionSpaceForP4P];
        NSLog(@"Clearing credentials");
    }
}

- (void)logJSONData:(NSData *)data {
    NSError* error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if([jsonObject isKindOfClass:[NSDictionary class]]){
        [jsonObject toPrettyJSON];
    } else if([jsonObject isKindOfClass:[NSArray class]]){
        for (NSDictionary * assessment in jsonObject){
            [assessment toPrettyJSON];
        }
    } else {
        NSLog(@"JSon Object is not an array or dictionary!");
    }
}

- (NSURLRequest *) requestWithJSON:(NSData *) JSON {
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:self.url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:JSON];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [JSON length]] forHTTPHeaderField:@"Content-Length"];
    return request;
}

- (NSURLProtectionSpace *) protectionSpaceForP4P {
    return [[NSURLProtectionSpace alloc] initWithHost:self.baseUrl port:443 protocol:@"http" realm:nil authenticationMethod:NSURLAuthenticationMethodDefault];
}

- (NSURLCredential *) credentials {
    NSURLProtectionSpace * protectionSpace = self.protectionSpaceForP4P;
    NSURLCredential * credentials = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
//    NSLog(@"Retrieving keychain credentials: %@", credentials.user);
    return credentials;
}

- (void) saveUsername:(NSString *)username withPassword:(NSString *)password {
    [self saveCredentialsWithUsername:username withPassword:password];
    [self updateSettingsWithUsername:username];
    [self updateSettingsWithPassword:password];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"credentials changed" object:self];
}
    
- (NSString *) dummyPasswordForActualPassword:(NSString *)password {
    NSString * dummyPassword = @"";
    for(int i = 0; i < password.length; i++){
        dummyPassword = [NSString stringWithFormat:@"%@%@", dummyPassword, @"X"];
    }
    return dummyPassword;
}

- (void) updateSettingsWithUsername:(NSString *)username {
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings setValue:username forKey:@"username_preference"];
}

- (void) updateSettingsWithPassword:(NSString *)password {
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString * dummyPassword = [self dummyPasswordForActualPassword:password];
    [settings setValue:dummyPassword forKey:@"password_preference"];
}

- (void) saveCredentialsWithUsername:(NSString *)username withPassword:(NSString *)password{
    NSURLCredentialPersistence persistance = NSURLCredentialPersistencePermanent;
    NSURLCredential * credential = [[NSURLCredential alloc] initWithUser:username password:password persistence:persistance];
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential forProtectionSpace:self.protectionSpaceForP4P];
}


@end
