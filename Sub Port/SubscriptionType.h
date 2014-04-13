//
//  SubscriptionType.h
//  Sub Port
//
//  Created by School on 4/13/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Provider.h"

@interface SubscriptionType : NSObject

@property (nonatomic, readwrite) NSString *subscriberName;
@property (nonatomic, readwrite) NSNumber *idNumber;
@property (nonatomic, readwrite) Provider *associatedProvider;

@end
