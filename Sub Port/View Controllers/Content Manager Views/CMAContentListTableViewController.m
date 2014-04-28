//
//  CMAContentListTableViewController.m
//  Sub Port
//
//  Created by School on 4/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "CMAContentListTableViewController.h"
#import "CMAEditContentDetailsViewController.h"
#import "ContentElement.h"
#import "WebServiceURLBuilder.h"

@interface CMAContentListTableViewController ()<UIAlertViewDelegate> {
    Provider *_currProvider;
    NSMutableArray *_contentList;
}

@end

@implementation CMAContentListTableViewController

- (id)initWithProvider:(Provider *)provider
{
    self = [super init];
    if (self) {
        _currProvider = provider;
        _contentList = [[NSMutableArray alloc] init];
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
    [self customizeNavigationBar];
    [self fetchContentInBackground];
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
    
    // Configure the cell...
    
    ContentElement *currElement = [_contentList objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[currElement name]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContentElement *_selectedElement = [_contentList objectAtIndex:[indexPath row]];
    
    CMAEditContentDetailsViewController *addContentView = [[CMAEditContentDetailsViewController alloc] initWithContentElement:_selectedElement];
    
    addContentView.dismissBlock = ^{
        [self fetchContentInBackground];
    };
    
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:addContentView];
    
    [self presentViewController:navControl animated:YES completion:nil];
}

#pragma mark - Swipe to Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContentElement *elementToDelete = [_contentList objectAtIndex:[indexPath row]];
    
    [_contentList removeObjectAtIndex:[indexPath row]];
    [self deleteContentElement:elementToDelete];
    
    NSLog(@"Deleted row.");
}

#pragma mark - Connection Information

- (void)fetchContentInBackground
{
    [_contentList removeAllObjects];
    NSDictionary *postDictionary = @{@"id": [_currProvider idNumber]};
    NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDictionary forRouteAppendix:@"provider_content_elements"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithData:responseData orError:err];
}

- (void)connectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    [[self refreshControl] endRefreshing];
    NSError *localError;
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
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
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
    
    [[self tableView] reloadData];
}

- (IBAction)addItem:(id)sender
{
    NSLog(@"Add Content Tapped");
    
    ContentElement *newContentElement = [[ContentElement alloc] init];
    [newContentElement setProvider:_currProvider];
    
    CMAEditContentDetailsViewController *addContentView = [[CMAEditContentDetailsViewController alloc] initWithContentElement:newContentElement];
    
    addContentView.dismissBlock = ^{
        [self fetchContentInBackground];
    };
    
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:addContentView];
    
    [self presentViewController:navControl animated:YES completion:nil];
}

- (void)deleteContentElement:(ContentElement *)elementToDelete
{
    NSDictionary *deleteDict = @{@"id":[elementToDelete idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder deleteRequestForRouteAppendix:@"manage_content_elements" withDictionary:deleteDict];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self deleteConnectionDidFinishWithData:responseData orError:err];
}

- (void)deleteConnectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [[self tableView] reloadData];
}


#pragma mark - Configure Navigation

- (void)customizeNavigationBar
{
    [[self navigationItem] setTitle:[_currProvider providerName]];
    
    UIBarButtonItem *addContentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    [[self navigationItem] setRightBarButtonItem:addContentButton];
}


@end
