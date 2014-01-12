//
//  NSDictionary+JSon.h
//  pilots4pilots
//
//  Created by Wouter Scholtens on 9/25/12.
//  Copyright (c) 2012 Wouter Scholtens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSon)

/**
 Factory method that creates a NSDictionary of an array of NSDictionaries from a JSon object returned by the given url. Preferred method for parsing via a httpget request. In order for this to work, the server always has to return an object, not an array of objects. An array can then be designated via a variable name that can be accessed in the dictionary.
 */
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;

/**
 Factory method that creates a NSDictionary from a JSON object in the given data object.
 */
+(NSDictionary *)dictionaryWithContentsOFJSONData:(NSData *)data;

/**
 Utility method that converts a dictionary into a JSon object.
 */
-(NSData*)toJSON;

/**
 Utility method that converts a dictionary into a Pretty JSon object. NOTE: Should only be used for viewing JSON objects during debugging. Not for actual usage as it uses more data to represent the same JSON object.
 */

-(NSData *)toPrettyJSON;

@end
