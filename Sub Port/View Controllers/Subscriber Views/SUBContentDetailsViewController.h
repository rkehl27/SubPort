//
//  SUBContentDetailsViewController.h
//  Sub Port
//
//  Created by School on 4/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentElement.h"

@interface SUBContentDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (id)initWithContent:(ContentElement *)contentElement;

@end
