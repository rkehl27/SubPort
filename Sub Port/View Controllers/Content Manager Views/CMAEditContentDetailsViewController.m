//
//  CMAEditContentDetailsViewController.m
//  Sub Port
//
//  Created by School on 4/15/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "CMAEditContentDetailsViewController.h"
#import "SUBContentDetailsViewController.h"

@interface CMAEditContentDetailsViewController () {
    ContentElement *_contentElement;
}

@end

@implementation CMAEditContentDetailsViewController

- (id)initWithContentElement:(ContentElement *)contentElement
{
    self = [super init];
    if (self) {
        _contentElement = contentElement;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeView
{
    [[self nameField] setText:[_contentElement name]];
}

- (IBAction)previewContent:(id)sender
{
    SUBContentDetailsViewController *detailView = [[SUBContentDetailsViewController alloc] initWithContent: _contentElement];
    [[self navigationController] pushViewController:detailView animated:YES];
}

@end
