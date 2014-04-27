//
//  ContentElement.h
//  Sub Port
//
//  Created by School on 4/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Provider.h"
#import "FormatType.h"

@interface ContentElement : NSObject

@property (nonatomic, readwrite) NSNumber *idNumber;
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *url;
@property (nonatomic, readwrite) FormatType *format;
@property (nonatomic, readwrite) BOOL isHidden;

@property (nonatomic, readwrite) Provider *provider;

@end
