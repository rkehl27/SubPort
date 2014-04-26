//
//  FormFieldRow.m
//  Sub Port
//
//  Created by School on 3/30/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "FormFieldRow.h"

@implementation FormFieldRow

- (id)initWithLabel:(NSString *)label
{
    self = [super init];
    if (self) {
        _label = label;
    }
    return self;
}

@end
