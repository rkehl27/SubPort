//
//  PickerTableViewCell.m
//  Sub Port
//
//  Created by School on 4/13/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "PickerTableViewCell.h"

@interface PickerTableViewCell (){
    NSArray *_pickerArray;
}

@end


@implementation PickerTableViewCell

- (id)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        _pickerArray = array;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self createPicker];
    [_textField setInputView:_picker];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
    [_textField setEnabled:YES];
    [_textField becomeFirstResponder];
}

- (void)createPicker
{
    _picker = [[UIPickerView alloc] init];
    [_picker setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - Picker Delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    _selectedSubscriptionType = [ objectAtIndex:row];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_pickerArray objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_pickerArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


@end
