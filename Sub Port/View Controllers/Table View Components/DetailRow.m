//
//  DetailRow.m
//  Sub Port
//
//  Created by School on 4/11/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "DetailRow.h"
#import "DetailTableViewCell.h"

@implementation DetailRow

#pragma mark - Cell Configuration

- (NSString *)cellIdentifier
{
    return @"DetailTableViewCell";
}

- (UITableViewCell *)cellForDetailRow
{
    DetailTableViewCell *detailCell = [[DetailTableViewCell alloc] init];
    [[detailCell leftLabel] setText:[self leftLabel]];
    [[detailCell rightLabel] setText:[self rightLabel]];
    
    return detailCell;
}

@end
