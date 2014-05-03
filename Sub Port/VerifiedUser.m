//
//  VerifiedUser.m
//  Sub Port
//
//  Created by School on 2/23/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "VerifiedUser.h"

@implementation VerifiedUser

- (id)init
{
    self = [super init];
    if (self) {
        //do something
    }
    return self;
}

+ (id)sharedUser
{
    static VerifiedUser *sharedVerifiedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedVerifiedUser = [[self alloc] init];
    });
    return sharedVerifiedUser;
}

- (void)resetSharedUser
{
    [[VerifiedUser sharedUser] setName:nil];
    [[VerifiedUser sharedUser] setPassword:nil];
    [[VerifiedUser sharedUser] setEmail:nil];
    [[VerifiedUser sharedUser] setCreditCardNumber:nil];
    [[VerifiedUser sharedUser] setExpirationDate:nil];
    [[VerifiedUser sharedUser] setCsvCode:nil];
    [[VerifiedUser sharedUser] setAuthToken:nil];
}

@end
