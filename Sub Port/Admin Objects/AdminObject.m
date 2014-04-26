//
//  AdminObject.m
//  Sub Port
//
//  Created by Rebecca Kehl on 4/25/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "AdminObject.h"

@implementation AdminObject

- (id)initWithObjectType:(NSString *)objectType andRouteAppendix:(NSString *)routeAppendix
{
    self = [super init];
    if (self) {
        _objectType = objectType;
        _routeAppendix = routeAppendix;
    }
    return self;
}

@end
