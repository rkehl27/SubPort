//
//  ADMDetailViewController.h
//  Sub Port
//
//  Created by Rebecca Kehl on 4/26/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdminObject.h"

@interface ADMDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *objectLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, copy) void (^dismissBlock)(void);

- (id)initWithAdminObject:(AdminObject *)administratorObj;

@end
