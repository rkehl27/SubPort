//
//  AdminObject.h
//  Sub Port
//
//  Created by Rebecca Kehl on 4/25/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdminObject : NSObject

@property (nonatomic, strong, readwrite) NSString *objectType;
@property (nonatomic, strong, readwrite) NSString *routeAppendix;

- (id)initWithObjectType:(NSString *)objectType andRouteAppendix:(NSString *)routeAppendix;

@end
