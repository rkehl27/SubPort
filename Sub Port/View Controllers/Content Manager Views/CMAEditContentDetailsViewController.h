//
//  CMAEditContentDetailsViewController.h
//  Sub Port
//
//  Created by School on 4/15/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentElement.h"

@interface CMAEditContentDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *formatField;
@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UISwitch *hiddenToggle;
@property (weak, nonatomic) IBOutlet UITextField *dateField;

- (id)initWithContentElement:(ContentElement *)contentElement;

@end
