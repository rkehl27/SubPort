//
//  SUBMainViewControllerTableViewController.m
//  Sub Port
//
//  Created by Brandon Michael Kiefer on 4/10/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "SUBMainTableViewController.h"
#import "SUBSettingsViewController.h"
#import "SUBContentDetailsViewController.h"
#import "WebServiceURLBuilder.h"
#import "ContentElement.h"

@interface SUBMainTableViewController () {
    NSMutableArray *_contentList;
}

@end

@implementation SUBMainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _contentList = [[NSMutableArray alloc] init];
        [self customizeNavigationItem];
        [self configureRefreshControl];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchContentInBackground];
    [[self refreshControl] beginRefreshing];
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
    return [_contentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ContentElement *contentElementInstance = [_contentList objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[contentElementInstance name]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SUBContentDetailsViewController *detailView = [[SUBContentDetailsViewController alloc] initWithContent:[_contentList objectAtIndex:[indexPath row]]];
    [[self navigationController] pushViewController:detailView animated:YES];
}

#pragma mark - Connection Information

- (void)fetchContentInBackground
{
    NSMutableURLRequest *request = [WebServiceURLBuilder getRequestForRouteAppendix:@"user_content_elements"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithData:responseData orError:err];
}

- (void)connectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    [[self refreshControl] endRefreshing];
    [_contentList removeAllObjects];

    NSError *localError;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        NSArray *content = [dataDict objectForKey:@"content_elements"];
        
        for (NSDictionary *dict in content) {
            ContentElement *currElement = [[ContentElement alloc] init];
            [currElement setIdNumber:[dict objectForKey:@"id"]];
            [currElement setName:[dict objectForKey:@"name"]];
            
            [_contentList addObject:currElement];
        }
    }
    
    [[self tableView] reloadData];
}


- (void)configureRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(userPulledToRefresh:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setTintColor:[UIColor blackColor]];
    [self setRefreshControl:refreshControl];
}

- (void)userPulledToRefresh:(id)sender
{
    [self fetchContentInBackground];
}

#pragma mark - Configure Navigation Bar

- (IBAction)settings:(id)sender
{
    SUBSettingsViewController *settingsView = [[SUBSettingsViewController alloc] init];
    [[self navigationController] pushViewController:settingsView animated:YES];
}

- (void)customizeNavigationItem
{
    UIBarButtonItem *rightbbi = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings:)];
    [[self navigationItem] setRightBarButtonItem:rightbbi];
    
    [[self navigationItem] setTitle:@"List"];
}

@end
