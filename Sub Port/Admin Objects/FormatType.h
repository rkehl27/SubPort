//
//  FormatType.h
//  Sub Port
//
//  Created by Brandon Michael Kiefer on 4/24/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormatType : NSObject

@property (nonatomic, readwrite) NSString *formatTypeName;
@property (nonatomic, readwrite) NSNumber *idNumber;
@property (nonatomic, readwrite) BOOL isHidden;

@end
