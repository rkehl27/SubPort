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
#import "PickerRow.h"
#import "PickerTableViewCell.h"

@interface SUBProviderDetailTableViewController ()<UIPickerViewDelegate, UIPickerViewDataSource> {
    Provider *_provider;
    NSString *_contentArea;
    NSString *_deliveryMode;
    NSArray *_subscriptionTypes;
    NSString *_selectedSubscriptionType;
    
    NSMutableArray *_rows;
    NSMutableArray *_cells;
    
    PickerTableViewCell *_pickerCell;
}

@property (nonatomic, strong) UIPickerView *subscriptionTypePickerView;

@end

const CGFloat kOptimumPickerHeight = 216;
const CGFloat kOptimumPickerWidth = 320;

@implementation SUBProviderDetailTableViewController

- (id)initWithProvider:(Provider *)provider
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _provider = provider;
        _rows = [[NSMutableArray alloc] init];
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
    
    UINib *nib2 = [UINib nibWithNibName:@"PickerTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib2 forCellReuseIdentifier:@"PickerTableViewCell"];
    
    [self customizeNavigationBar];
    [self fetchProviderDetails];
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
    return [_rows count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < [_rows count]) {
        DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTableViewCell" forIndexPath:indexPath];
        
        DetailRow *row = [_rows objectAtIndex:[indexPath row]];
        
        [[cell leftLabel] setText:[row leftLabel]];
        [[cell rightLabel] setText:[row rightLabel]];
        
        if ([indexPath row] < 2) {
            [cell setUserInteractionEnabled:NO];
        }
        
        [_cells addObject:cell];
        
        return cell;
    } else {
        _pickerCell = [tableView dequeueReusableCellWithIdentifier:@"PickerTableViewCell" forIndexPath:indexPath];
        [[_pickerCell leftLabel] setText:@"TYPE"];
        [_cells addObject:_pickerCell];
        
        return _pickerCell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 2) {
        NSLog(@"Selected row 2");
    }
}

#pragma mark - Picker View

- (void)createPicker
{
    _subscriptionTypePickerView = [[UIPickerView alloc] init];
    
    [[self subscriptionTypePickerView] setDelegate:self];
    [[self subscriptionTypePickerView] setDataSource:self];
    
    [[self subscriptionTypePickerView] setBackgroundColor:[UIColor whiteColor]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedSubscriptionType = [_subscriptionTypes objectAtIndex:row];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_subscriptionTypes objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_subscriptionTypes count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
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
        _subscriptionTypes = [dataDict objectForKey:@"subscriptions"];
        _contentArea = [dataDict objectForKey:@"content_area"];
        _deliveryMode = [dataDict objectForKey:@"delivery_mode"];
        
        DetailRow *contentAreaRow = [[DetailRow alloc] init];
        [contentAreaRow setLeftLabel:@"Content Area"];
        [contentAreaRow setRightLabel:_contentArea];
        
        DetailRow *deliveryModeRow = [[DetailRow alloc] init];
        [deliveryModeRow setLeftLabel:@"Delivery Mode"];
        [deliveryModeRow setRightLabel:_deliveryMode];
        
        DetailRow *subscriptionTypeRow = [[DetailRow alloc] init];
        [subscriptionTypeRow setLeftLabel:@"Subscription Type"];
        
        [_rows addObject:contentAreaRow];
        [_rows addObject:deliveryModeRow];
        [_rows addObject:subscriptionTypeRow];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark - Navigation Control

- (IBAction)addProvider:(id)sender
{
    [_provider setIsSelected:YES];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)removeProvider:(id)sender
{
    [_provider setIsSelected:NO];
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
    
    UIBarButtonItem *removeProvider = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(removeProvider:)];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    [[self navigationItem] setLeftBarButtonItem:cancel];
    
    if ([_provider isSelected]) {
        [[self navigationItem] setRightBarButtonItem:removeProvider];
    } else {
        [[self navigationItem] setRightBarButtonItem:addProvider];
    }
}

@end
