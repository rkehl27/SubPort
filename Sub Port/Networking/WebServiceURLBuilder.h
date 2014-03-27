//
//  WebServiceURLBuilder.h
//  Sub Port
//
//  Created by School on 3/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceURLBuilder : NSObject

+ (NSMutableURLRequest *)URLRequestForURL:(NSURL *)url;

+ (NSMutableURLRequest *)URLRequestForURL:(NSURL *)url JSONToPost:(NSData *)json;


@end
