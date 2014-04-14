//
//  SUBProviderDetailTableViewController.m
//  Sub Port
//
//  Created by School on 4/11/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "SUBProviderDetailTableViewController.h"
#import "WebServiceURLBuilder.h"
#import "DetailRow.h"
#import "DetailTableViewCell.h"

#import "SubscriptionType.h"

@interface SUBProviderDetailTableViewController ()<UIAlertViewDelegate> {
    Provider *_provider;
    NSString *_contentArea;
    NSString *_deliveryMode;
    NSMutableArray *_subscriptionTypes;
    SubscriptionType *_selectedSubType;
    
    NSMutableArray *_rows;
    NSMutableArray *_cells;
}

@end

@implementation SUBProviderDetailTableViewController

- (id)initWithProvider:(Provider *)provider
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _provider = provider;
        _selectedSubType = [_provider subType];
        _rows = [[NSMutableArray alloc] init];
        _cells = [[NSMutableArray alloc] init];
        _subscriptionTypes = [[NSMutableArray alloc] init];
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
    
    UINib *nib = [UINib nibWithNibName:@"DetailTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"DetailTableViewCell"];
    
    [self fetchProviderDetails];
    [self customizeNavigationBar];
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
    [[cell rightLabel] setText:[row rightLabel]];
    
    if ([indexPath row] < 3) {
        [cell setUserInteractionEnabled:NO];
    }
    
    [_cells addObject:cell];
    
    if ([indexPath row] > 2) {
        if ([[row leftLabel]isEqualToString:[_selectedSubType subscriberName]]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isSelected]) {
        [cell setSelected:NO];
    }
    
    if ([indexPath row] > 2) {
        if ([[_selectedSubType subscriberName] length] > 1) {
            for (UITableViewCell *cell in _cells) {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        DetailRow *selectedRow = [_rows objectAtIndex:[indexPath row]];
        
        for (SubscriptionType *subType in _subscriptionTypes) {
            if ([[selectedRow leftLabel] isEqualToString:[subType subscriberName]]) {
                _selectedSubType = subType;
            }
        }
    }
}

#pragma mark - Connection Information

- (void)fetchProviderDetails
{
    NSDictionary *inputData = @{@"id":[_provider idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:inputData forRouteAppendix:@"sub_providers"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithData:responseData orError:err];
}

- (void)connectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        NSArray *typesOfSubscriptions = [dataDict objectForKey:@"subscriptions"];
        _contentArea = [dataDict objectForKey:@"content_area"];
        _deliveryMode = [dataDict objectForKey:@"delivery_mode"];
        
        DetailRow *contentAreaRow = [[DetailRow alloc] init];
        [contentAreaRow setLeftLabel:@"Content Area"];
        [contentAreaRow setRightLabel:_contentArea];
        
        DetailRow *deliveryModeRow = [[DetailRow alloc] init];
        [deliveryModeRow setLeftLabel:@"Delivery Mode"];
        [deliveryModeRow setRightLabel:_deliveryMode];
        
        DetailRow *subscriptionTypeRow = [[DetailRow alloc] init];
        [subscriptionTypeRow setLeftLabel:@"Subscription Types:"];
        
        [_rows addObject:contentAreaRow];
        [_rows addObject:deliveryModeRow];
        [_rows addObject:subscriptionTypeRow];
        
        for (NSDictionary *typeOfSubscriptionDict in typesOfSubscriptions) {
            SubscriptionType *subscriptionTypeInst = [[SubscriptionType alloc] init];
            [subscriptionTypeInst setSubscriberName:[typeOfSubscriptionDict objectForKey:@"name"]];
            [subscriptionTypeInst setIdNumber:[typeOfSubscriptionDict objectForKey:@"id"]];
            [subscriptionTypeInst setAssociatedProvider:_provider];
            
            [_subscriptionTypes addObject:subscriptionTypeInst];
            
            DetailRow *typeRow = [[DetailRow alloc] init];
            [typeRow setLeftLabel:[subscriptionTypeInst subscriberName]];
            [_rows addObject:typeRow];
        }
        
        [self synchronizeSubscriptionTypesWithSelectedSubscription:[dataDict objectForKey:@"sub_id"]];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)synchronizeSubscriptionTypesWithSelectedSubscription:(NSNumber *)idNumber
{
    for (SubscriptionType *subType in _subscriptionTypes) {
        if ([subType idNumber] == idNumber) {
            _selectedSubType = subType;
        }
    }
}

- (void)addProviderToUser
{
    NSDictionary *inputData = @{@"provider_id":[_provider idNumber], @"sub_id":[[_provider subType] idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder putRequestForRouteAppendix:@"sub_providers" withDictionary:inputData];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self putConnectionDidFinishWithData:responseData orError:err];
}

- (void)putConnectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];

    NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
    
    NSLog(@"Put request Completed");
}

- (void)removeProviderFromUser
{
    NSDictionary *inputData = @{@"id":[_provider idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder deleteRequestForRouteAppendix:@"sub_providers" withDictionary:inputData];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self deleteConnectionDidFinishWithData:responseData orError:err];
}

- (void)deleteConnectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
    
    NSLog(@"Delete request Completed");
}

#pragma mark - Navigation Control

- (IBAction)addProvider:(id)sender
{
    [_provider setSubType:_selectedSubType];
    
    if ([_selectedSubType idNumber] != nil) {
        [_provider setIsSelected:YES];
        [self addProviderToUser];
        [[self navigationController] popViewControllerAnimated:YES];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must select a subscription type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

- (IBAction)removeProvider:(id)sender
{
    [_provider setIsSelected:NO];
    
    [self removeProviderFromUser];
    
    [_provider setSubType:nil];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)customizeNavigationBar
{
    [[self navigationItem] setTitle:[_provider providerName]];
    
    UIBarButtonItem *addProvider = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProvider:)];
    
    UIBarButtonItem *removeProvider = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(removeProvider:)];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    [[self navigationItem] setLeftBarButtonItem:cancel];
    
    if ([_provider isSelected]) {
        [[self navigationItem] setRightBarButtonItem:removeProvider];
    } else {
        [[self navigationItem] setRightBarButtonItem:addProvider];
    }

    if ([_subscriptionTypes count] == 0) {
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    }
}

@end
