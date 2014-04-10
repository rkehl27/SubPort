//
//  FormFieldRow.h
//  Sub Port
//
//  Created by School on 3/30/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormFieldRow : NSObject

@property (nonatomic, strong, readwrite) NSString *label;
@property (nonatomic, strong, readwrite) NSString *textForLabel;

- (id)initWithLabel:(NSString *)label;

@end
