//
//  PickerTableViewCell.h
//  Sub Port
//
//  Created by School on 4/13/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong, readwrite) UIPickerView *picker;

- (id)initWithArray:(NSArray *)array;

@end
