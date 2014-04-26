//
//  WebServiceURLBuilder.h
//  Sub Port
//
//  Created by School on 3/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceURLBuilder : NSObject

//These assume the baseURL is http://subportinc.herokuapp.com/api/v1 and route appendix comes after v1 with the auth_token added to end

+ (NSMutableURLRequest *)getRequestForRouteAppendix:(NSString *)routeAppendix;

+ (NSMutableURLRequest *)postRequestWithDictionary:(NSDictionary *)postDictionary forRouteAppendix:(NSString *)routeAppendix;

+ (NSMutableURLRequest *)deleteRequestForRouteAppendix:(NSString *)routeAppendix;


@end
