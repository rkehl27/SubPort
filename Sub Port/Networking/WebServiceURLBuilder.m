//
//  WebServiceURLBuilder.m
//  Sub Port
//
//  Created by School on 3/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "WebServiceURLBuilder.h"

@implementation WebServiceURLBuilder

+ (NSMutableURLRequest *)URLRequestForURL:(NSURL *)url
{
    return [NSMutableURLRequest requestWithURL:url];
}

+ (NSMutableURLRequest *)URLRequestForURL:(NSURL *)url JSONToPost:(NSData *)json
{
    return [self URLRequestForURL:url dataToPost:json contentType:@"application/json"];
}

+ (NSMutableURLRequest *)URLRequestForURL:(NSURL *)url dataToPost:(NSData *)dataToPost contentType:(NSString *)contentType
{
    return [self mutableURLRequestForURL:url dataToPost:dataToPost contentType:contentType];
}

+ (NSMutableURLRequest *)mutableURLRequestForURL:(NSURL *)url dataToPost:(NSData *)dataToPost contentType:(NSString *)contentType
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:dataToPost];
    return request;
}

@end
