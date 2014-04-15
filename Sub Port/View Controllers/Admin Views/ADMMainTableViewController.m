//
//  ADMMainTableViewController.m
//  Sub Port
//
//  Created by School on 4/13/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMMainTableViewController.h"
#import "ADMProvidersTableViewController.h"
#import "UNISettingsViewController.h"
#import "DetailRow.h"
#import "DetailTableViewCell.h"

@interface ADMMainTableViewController () {
    NSMutableArray *_rows;
}

@end

@implementation ADMMainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        _rows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeNavigationBar];
    
    [self loadTableModel];
    
    UINib *nib = [UINib nibWithNibName:@"DetailTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"DetailTableViewCell"];
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
    return [_rows count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTableViewCell" forIndexPath:indexPath];
    
    DetailRow *row = [_rows objectAtIndex:[indexPath row]];
    
    [[cell leftLabel] setText:[row leftLabel]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewController *view;
    
    switch ([indexPath row]) {
        case 0:
            break;
            
        case 1:
            break;
            
        case 2:
            break;
            
        case 3:
            view = [[ADMProvidersTableViewController alloc] init];
            [[self navigationController] pushViewController:view animated:YES];
            break;
            
        default:
            break;
    }
}

- (void)loadTableModel
{
    DetailRow *formatsRow = [[DetailRow alloc] init];
    [formatsRow setLeftLabel:@"Formats"];
    
    DetailRow *contentAreasRow = [[DetailRow alloc] init];
    [contentAreasRow setLeftLabel:@"Content Areas"];
    
    DetailRow *deliveryModesRow = [[DetailRow alloc] init];
    [deliveryModesRow setLeftLabel:@"Delivery Modes"];
    
    DetailRow *providersRow = [[DetailRow alloc] init];
    [providersRow setLeftLabel:@"Providers"];
    
    [_rows addObject:formatsRow];
    [_rows addObject:contentAreasRow];
    [_rows addObject:deliveryModesRow];
    [_rows addObject:providersRow];
}

#pragma mark - Configure Navigation Controller

- (IBAction)settings:(id)sender
{
    UNISettingsViewController *settingsView = [[UNISettingsViewController alloc] init];
    [[self navigationController] pushViewController:settingsView animated:YES];
}

- (void)customizeNavigationBar
{
    UIBarButtonItem *rightbbi = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings:)];
    [[self navigationItem] setRightBarButtonItem:rightbbi];
    [[self navigationItem] setTitle:@"Admin"];
}

@end
