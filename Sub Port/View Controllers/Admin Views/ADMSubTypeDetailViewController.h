//
//  ADMSubTypeDetailViewController.h
//  Sub Port
//
//  Created by Rebecca Kehl on 4/27/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdminObject.h"
#import "Provider.h"

@interface ADMSubTypeDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *objectLabel;
@property (weak, nonatomic) IBOutlet UITextField *objectTextField;
@property (nonatomic, copy) void (^dismissBlock)(void);
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIStepper *dayStepper;
@property (weak, nonatomic) IBOutlet UIStepper *monthStepper;
@property (weak, nonatomic) IBOutlet UIStepper *yearStepper;

- (id)initWithAdminObject:(AdminObject *)administratorObj AndProvider:(Provider *)provider;

@end
