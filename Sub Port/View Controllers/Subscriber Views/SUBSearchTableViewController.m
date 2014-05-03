//
//  SUBSearchTableViewController.m
//  Sub Port
//
//  Created by Rebecca Kehl on 4/28/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "SUBSearchTableViewController.h"
#import "SUBContentDetailsViewController.h"
#import "ContentElement.h"

@interface SUBSearchTableViewController () {
    NSMutableArray *_contentList;
    NSMutableArray *_tableData;
    NSMutableArray *_searchData;
    
    UISearchBar *_searchBar;
    UISearchDisplayController *_searchDisplayController;
}

@end

@implementation SUBSearchTableViewController

- (id)initWithContentList:(NSMutableArray *)contentList
{
    self = [super init];
    if (self) {
        _contentList = contentList;
        _searchData = [[NSMutableArray alloc] init];
        _tableData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeNavigationBar];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableData addObjectsFromArray:_contentList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
     NSString *cellIdentifier = @"cellIdentifier";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
     if (cell == nil) {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
     }
     
     ContentElement *contentElementInstance = [_tableData objectAtIndex:[indexPath row]];
    
     [[cell textLabel] setText:[contentElementInstance name]];
     
     return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SUBContentDetailsViewController *detailView = [[SUBContentDetailsViewController alloc] initWithContent:[_tableData objectAtIndex:[indexPath row]]];
    [[self navigationController] pushViewController:detailView animated:YES];
}
#pragma mark - UISearchBar

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [_tableData removeAllObjects];
    
    if ([searchString length] == 0) {
        [_tableData addObjectsFromArray:_contentList];
    } else {
        for (ContentElement *contElem in _contentList) {
            NSString *contentName = [contElem name];
            NSRange range = [contentName rangeOfString:searchString
                                               options:NSCaseInsensitiveSearch];
            
            if (range.length > 0) { //if the substring match
                [_tableData addObject:contElem];
            }
        }
    }
    
    [[self tableView] reloadData];
    
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [_tableData removeAllObjects];
    [_tableData addObjectsFromArray:_contentList];
    [[self tableView] reloadData];
}

#pragma mark - Navigation Item Configuration

- (void)customizeNavigationBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    
    _searchDisplayController.delegate = self;
    _searchDisplayController.searchResultsDataSource = self;
    _searchDisplayController.searchResultsDelegate = self;
    
    self.navigationItem.titleView = _searchBar;
    self.tableView.backgroundColor = [UIColor colorWithRed:.086 green:.7216 blue:1 alpha:1];
}

@end
