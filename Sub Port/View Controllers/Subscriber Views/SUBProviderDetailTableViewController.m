//
//  SUBProviderDetailTableViewController.m
//  Sub Port
//
//  Created by School on 4/11/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "SUBProviderDetailTableViewController.h"

@interface SUBProviderDetailTableViewController () {
    Provider *_provider;
}

@end

@implementation SUBProviderDetailTableViewController

- (id)initWithProvider:(Provider *)provider
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _provider = provider;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

#pragma mark - Connection Information

- (void)fetchProviderDetails
{
    NSDictionary *inputData = @{@"id":[_provider idNumber]};
    NSError *error = nil;
    NSData *jsonInputData = [NSJSONSerialization dataWithJSONObject:inputData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:@"http://subportinc.herokuapp.com/api/vi/sub_providers/?auth_token="];
    
    
}


@end
