//
//  WebServiceURLBuilder.m
//  Sub Port
//
//  Created by School on 3/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "WebServiceURLBuilder.h"
#import "VerifiedUser.h"

@implementation WebServiceURLBuilder

+ (NSMutableURLRequest *)getRequestForRouteAppendix:(NSString *)routeAppendix
{
    NSString *baseURL = @"http://subportinc.herokuapp.com/api/v1/{routeAppendix}/?auth_token=";
    baseURL = [baseURL stringByReplacingOccurrencesOfString:@"{routeAppendix}" withString:routeAppendix];
    NSString *fullURL = [baseURL stringByAppendingString:[[VerifiedUser sharedUser] authToken]];
    
    NSURL *url = [NSURL URLWithString:fullURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
}

+ (NSMutableURLRequest *)postRequestWithDictionary:(NSDictionary *)postDictionary forRouteAppendix:(NSString *)routeAppendix
{
    NSError *error = nil;
    NSData *jsonInputData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *baseURL = @"http://subportinc.herokuapp.com/api/v1/{routeAppendix}/?auth_token=";
    baseURL = [baseURL stringByReplacingOccurrencesOfString:@"{routeAppendix}" withString:routeAppendix];
    NSString *fullURL = [baseURL stringByAppendingString:[[VerifiedUser sharedUser] authToken]];
    
    NSURL *url = [NSURL URLWithString:fullURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonInputData];
    
    return request;
}

+ (NSMutableURLRequest *)deleteRequestForRouteAppendix:(NSString *)routeAppendix
{
    NSString *baseURL = @"http://subportinc.herokuapp.com/api/v1/{routeAppendix}/?auth_token=";
    baseURL = [baseURL stringByReplacingOccurrencesOfString:@"{routeAppendix}" withString:routeAppendix];
    NSString *fullURL = [baseURL stringByAppendingString:[[VerifiedUser sharedUser] authToken]];
    
    NSURL *url = [NSURL URLWithString:fullURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
}

@end
