//
//  FormFieldTableViewCell.h
//  Sub Port
//
//  Created by School on 3/29/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormFieldTableViewCell : UITableViewCell

@property (weak, nonatomic, readwrite) IBOutlet UITextField *rowTextField;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *rowLabel;

@end
