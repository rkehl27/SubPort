//
//  Provider.h
//  Sub Port
//
//  Created by School on 4/11/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Provider : NSObject

@property (nonatomic, readwrite) NSString *providerName;
@property (nonatomic, readwrite) NSNumber *idNumber;
@property (nonatomic, readwrite) NSString *subscriptionID;
@property (nonatomic, readwrite) BOOL isSelected;

@end
