//
//  SUBMainViewControllerTableViewController.m
//  Sub Port
//
//  Created by Brandon Michael Kiefer on 4/10/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "SUBMainTableViewController.h"
#import "SUBSettingsViewController.h"
#import "SUBSearchTableViewController.h"
#import "SUBContentDetailsViewController.h"
#import "WebServiceURLBuilder.h"
#import "ContentElement.h"
#import "Provider.h"

@interface SUBMainTableViewController ()<UIAlertViewDelegate> {
    NSMutableArray *_tableData;
    NSMutableArray *_contentList;
    
    NSMutableArray *_providers;
}

@end

@implementation SUBMainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _tableData = [[NSMutableArray alloc] init];
        _contentList = [[NSMutableArray alloc] init];
        _providers = [[NSMutableArray alloc] init];
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
    return [_providers count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Provider *currProv = [_providers objectAtIndex:section];
    

    return [NSString stringWithFormat:@"%@\n%@", [currProv providerName], [currProv expDate]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    Provider *currProv = [_providers objectAtIndex:section];
    
    return [[currProv elementCount] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ContentElement *contentElementInstance = [[ContentElement alloc] init];

    Provider *currProv = [_providers objectAtIndex:[indexPath section]];
    contentElementInstance = [[currProv contentElements] objectAtIndex:[indexPath row]];

    [[cell textLabel] setText:[contentElementInstance name]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SUBContentDetailsViewController *detailView = [[SUBContentDetailsViewController alloc] initWithContent:[_tableData objectAtIndex:[indexPath row]]];
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
    [_tableData removeAllObjects];
    [_providers removeAllObjects];
    [_contentList removeAllObjects];

    NSError *localError;
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        NSArray *content = [dataDict objectForKey:@"content_elements"];
        NSArray *providers = [dataDict objectForKey:@"providers"];
        NSArray *subscriptions = [dataDict objectForKey:@"subscriptions"];
        
        for (NSDictionary *contentDict in content) {
            ContentElement *currElement = [[ContentElement alloc] init];
            [currElement setIdNumber:[contentDict objectForKey:@"id"]];
            [currElement setName:[contentDict objectForKey:@"name"]];
            
            [self addProviderToArray:[contentDict objectForKey:@"provider_id"] withContentElement:currElement];
            
            [_contentList addObject:currElement];
            [_tableData addObject:currElement];
        }
        
        for (NSDictionary *provDict in providers) {
            Provider *newProv = [[Provider alloc] init];
            [newProv setProviderName:[provDict objectForKey:@"name"]];
            [newProv setIdNumber:[provDict objectForKey:@"id"]];
            [self addProviderNameToProvider:newProv];
        }
        
        for (NSDictionary *subscripDict in subscriptions) {
            Provider *newProv = [[Provider alloc] init];
            [newProv setIdNumber:[subscripDict objectForKey:@"provider_id"]];
            [newProv setExpDate:[subscripDict objectForKey:@"expiration_date"]];
            [self addProviderExpDateToProvider:newProv];
        }
        
        
    }else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
    [[self tableView] reloadData];
}

- (Provider *)providerInArrayWithId:(NSNumber *)provId
{
    for (Provider *currProv in _providers) {
        if ([[currProv idNumber] isEqualToNumber:provId]) {
            return currProv;
        }
    }
    return nil;
}

- (void)addProviderToArray:(NSNumber *)provId withContentElement:(ContentElement *)element
{
    Provider *currProv = [self providerInArrayWithId:provId];
    if ([currProv idNumber] != nil) {
        //Provider exists in array
        NSNumber *currCount = [currProv elementCount];
        int currCountVal = [currCount integerValue];
        currCountVal++;
        [currProv setElementCount:[NSNumber numberWithInt:currCountVal]];
        [[currProv contentElements] addObject:element];
    } else {
        //Provider does not exist in array
        Provider *newProv = [[Provider alloc] init];
        [newProv setIdNumber:provId];
        [newProv setElementCount:[NSNumber numberWithInt:1]];
        [[newProv contentElements] addObject:element];
        [_providers addObject:newProv];
    }
}

- (void)addProviderNameToProvider:(Provider *)currProv
{
    for (Provider *prov in _providers) {
        if ([[prov idNumber] isEqualToNumber:[currProv idNumber]]) {
            [prov setProviderName:[currProv providerName]];
        }
    }
}

- (void)addProviderExpDateToProvider:(Provider *)currProv
{
    for (Provider *prov in _providers) {
        if ([[prov idNumber] isEqualToNumber:[currProv idNumber]]) {
            [prov setExpDate:[currProv expDate]];
        }
    }
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

- (IBAction)searchButton:(id)sender
{
    SUBSearchTableViewController *searchView = [[SUBSearchTableViewController alloc] initWithContentList:_contentList];
    [[self navigationController] pushViewController:searchView animated:YES];
}

- (void)customizeNavigationItem
{
    UIBarButtonItem *rightbbi = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings:)];
    [[self navigationItem] setRightBarButtonItem:rightbbi];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButton:)];
    [[self navigationItem] setLeftBarButtonItem:searchButton];
    
    [[self navigationItem] setTitle:@"List"];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:.086 green:.7216 blue:1 alpha:1];
}

@end
