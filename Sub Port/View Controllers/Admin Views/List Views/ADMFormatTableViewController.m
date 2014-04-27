//
//  ADMFormatTableViewController.m
//  Sub Port
//
//  Created by School on 4/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMFormatTableViewController.h"
#import "FormatType.h"
#import "WebServiceURLBuilder.h"

@interface ADMFormatTableViewController () {
    NSMutableArray *_formatTypes;
}

@end

@implementation ADMFormatTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _formatTypes = [[NSMutableArray alloc] init];
        [self customizeNavigationBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchFormatTypesInBackground];
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
    return [_formatTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FormatType *formatTypeInstance = [self formatTypeAtIndexPath:indexPath];
    [[cell textLabel]setText:[formatTypeInstance formatTypeName]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    cell.accessoryView = switchView;
    if ([formatTypeInstance isHidden]) {
        [switchView setOn:NO animated:NO];
    }
    else {
        [switchView setOn:YES animated:NO];
    }
    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    UIView* contentView = [switchControl superview];
    UITableViewCell* cell = (UITableViewCell *)[contentView superview];
    //NSIndexPath* indexPath = [[self tableView] indexPathForCell:cell];
    //NSLog(@"The %@ switch is %@", cell.textLabel.text, switchControl.on ? @"ON" : @"OFF" );
    
    for (FormatType *tempFormatType in _formatTypes) {
        if ([tempFormatType formatTypeName] == cell.textLabel.text) {
            NSLog(@"The %@ %@ switch is %@", cell.textLabel.text, [tempFormatType idNumber], switchControl.on ? @"ON" : @"OFF" );
            NSDictionary *postDictionary = @{@"id":[tempFormatType idNumber]};
            NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDictionary forRouteAppendix:@"manage_formats"];
    
            NSURLResponse *response;
            NSError *err;
    
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
            [self connectionDidFinishWithDataAfterPost:responseData orError:err];
        }
    }
    
}

- (FormatType *)formatTypeAtIndexPath:(NSIndexPath *)indexPath
{
    return [_formatTypes objectAtIndex:[indexPath row]];
}

#pragma mark - Connection Information

- (void)fetchFormatTypesInBackground
{
    [_formatTypes removeAllObjects];
    NSMutableURLRequest *request = [WebServiceURLBuilder getRequestForRouteAppendix:@"formats"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithData:responseData orError:err];
}

- (void)connectionDidFinishWithDataAfterPost:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&localError];

    if ([responseDictionary valueForKey:@"success"]) {
        //NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)connectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        NSDictionary *formatTypes = [dataDict objectForKey:@"formats"];
        
        for (NSDictionary *formatTypeDictionary in formatTypes) {
            FormatType *currentFormatType = [[FormatType alloc] init];
            [currentFormatType setIdNumber:[formatTypeDictionary objectForKey:@"id"]];
            [currentFormatType setFormatTypeName:[formatTypeDictionary objectForKey:@"name"]];
            
            if([[[formatTypeDictionary objectForKey:@"hidden_flag"] class] isSubclassOfClass:[NSNull class]])
            {
                [currentFormatType setIsHidden:NO];
            } else {
                [currentFormatType setIsHidden:YES];
            }
            
            NSLog( @"%@ is %hhd", [currentFormatType formatTypeName], [currentFormatType isHidden] );
            
            [_formatTypes addObject:currentFormatType];
        }
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [[self tableView] reloadData];
}


#pragma mark - Navigation Item Configuration

- (void)customizeNavigationBar
{
    [[self navigationItem] setTitle:@"Format Types List"];
}

@end
