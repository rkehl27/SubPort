//
//  ToggleRowTableViewCell.h
//  Sub Port
//
//  Created by Rebecca Kehl on 4/25/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToggleRowTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *rowLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

@end
