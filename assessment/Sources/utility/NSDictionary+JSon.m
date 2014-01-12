//
//  NSDictionary+JSon.m
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/25/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import "NSDictionary+JSon.h"

@implementation NSDictionary (JSon)

+(NSDictionary *)dictionaryWithContentsOfJSONURLString:(NSString *)urlAddress {
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlAddress]];
    NSDictionary * jsonDictionary = [NSDictionary dictionaryWithContentsOFJSONData:data];
    return jsonDictionary;
}

+(NSDictionary *)dictionaryWithContentsOFJSONData:(NSData *)data {
    NSError * error = nil;
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) {
        return nil;
    }
    return result;
}

-(NSData *)toJSON {
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) {
        return nil;
    }
    
    return jsonData;
}

-(NSData *)toPrettyJSON {
    NSError * error = nil;
    NSData * prettyJSonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error != nil) {
        return nil;
    }
    
    //print out the data contents for debugging purposes
    NSString * prettyJSonString = [[NSString alloc] initWithData:prettyJSonData encoding:NSUTF8StringEncoding];
    NSLog(@"Pretty JSON object: %@", prettyJSonString);
    
    return prettyJSonData;
}

@end
