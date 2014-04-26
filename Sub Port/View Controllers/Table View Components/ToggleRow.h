//
//  ToggleRow.h
//  Sub Port
//
//  Created by Rebecca Kehl on 4/25/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToggleRow : NSObject

@property (nonatomic, strong, readwrite) NSString *textForLabel;
@property (nonatomic, readwrite) BOOL isHiddenFlag;

@end
