//
//  VerifiedUser.h
//  Sub Port
//
//  Created by School on 2/23/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VerifiedUser : NSObject

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *password;
@property (nonatomic, strong, readwrite) NSString *email;
@property (nonatomic, strong, readwrite) NSString *creditCardNumber;
@property (nonatomic, strong, readwrite) NSString *csvCode;
@property (nonatomic, strong, readwrite) NSString *expirationDate;
@property (nonatomic, strong, readwrite) NSString *authToken;

+ (id)sharedUser;

- (void)resetSharedUser;

@end
