//
//  CMAEditContentDetailsViewController.m
//  Sub Port
//
//  Created by School on 4/15/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "CMAEditContentDetailsViewController.h"
#import "SUBContentDetailsViewController.h"
#import "WebServiceURLBuilder.h"

@interface CMAEditContentDetailsViewController ()<UIPickerViewDataSource, UIPickerViewDelegate> {
    ContentElement *_contentElement;
    NSMutableArray *_formatTypes;
}

@end

@implementation CMAEditContentDetailsViewController

- (id)initWithContentElement:(ContentElement *)contentElement
{
    self = [super init];
    if (self) {
        _contentElement = contentElement;
        _formatTypes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)init
{
    ContentElement *contentElement = [[ContentElement alloc] init];
    self = [self initWithContentElement:contentElement];
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
    if ([[_contentElement name] length] > 0) {
        [self fetchContentInBackground];
        [self customizeNavigationBarForEditContent];
    } else {
        [self customizeNavigationBarForAddContent];
        NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:1209600];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *currDateString = [formatter stringFromDate:currentDate];
        [[self dateField] setText:currDateString];
    }
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
    [[self urlField] setText:[_contentElement url]];
    [[self hiddenToggle] setOn:[_contentElement isHidden]];
}

- (IBAction)previewContent:(id)sender
{
    SUBContentDetailsViewController *detailView = [[SUBContentDetailsViewController alloc] initWithContent: _contentElement];
    [[self navigationController] pushViewController:detailView animated:YES];
}

#pragma mark - Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_formatTypes count];
}

#pragma mark - Connection Information

- (void)fetchContentInBackground
{
    NSDictionary *postDictionary = @{@"id": [_contentElement idNumber]};
    NSMutableURLRequest *request = [WebServiceURLBuilder putRequestForRouteAppendix:@"provider_content_elements" withDictionary:postDictionary];
    
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
        NSDictionary *contentElementDict = [dataDict objectForKey:@"content_element"];
        
        [_contentElement setName:[contentElementDict objectForKey:@"name"]];
        [_contentElement setUrl:[contentElementDict objectForKey:@"url"]];
        
        if([[[contentElementDict objectForKey:@"hidden_flag"] class] isSubclassOfClass:[NSNull class]])
        {
            [_contentElement setIsHidden:NO];
        } else {
            [_contentElement setIsHidden:YES];
        }
        
        [self initializeView];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
    
}

- (void)sychronizeObjectWithFields
{
    [_contentElement setName:[[self nameField] text]];
    [_contentElement setUrl:[[self urlField] text]];
    [_contentElement setIsHidden:[[self hiddenToggle] isOn]];
}

- (void)pushChangesToServer
{
    [self sychronizeObjectWithFields];
    NSDictionary *postDictionary = @{@"id": [_contentElement idNumber], @"name":[_contentElement name], @"link":[_contentElement url], @"hidden_flag":@TRUE};

    NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDictionary forRouteAppendix:@"manage_content_elements"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self pushConnectionDidFinishWithData:responseData orError:err];
}

- (void)pushContentToServer
{
    
}

- (void)postHiddenFlag
{
    [self sychronizeObjectWithFields];
    NSDictionary *postDictionary = @{@"id": [_contentElement idNumber], @"name":[_contentElement name], @"link":[_contentElement url], @"hidden_flag":@TRUE};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDictionary forRouteAppendix:@"hide_content_areas"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self pushConnectionDidFinishWithData:responseData orError:err];
}

- (void)pushConnectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {

    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

#pragma mark - Editing Control

- (IBAction)toggleEditing:(id)sender
{
    if ([self isEditing]) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing:)];
        [[self navigationItem] setRightBarButtonItem:editButton];
        [self setEditing:NO];
        
        [self setFieldsEnabled:NO];
        
        [self pushChangesToServer];
        //[self postHiddenFlag];
        
        [[self navigationController] popViewControllerAnimated:YES];
    } else {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditing:)];
        [[self navigationItem] setRightBarButtonItem:doneButton];
        [self setEditing:YES];
        
        [self setFieldsEnabled:YES];
    }
}

- (IBAction)addContent:(id)sender
{
    //Verify Information
    [self pushContentToServer];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)setFieldsEnabled:(BOOL)enabled
{
    [[self nameField] setEnabled:enabled];
    [[self urlField] setEnabled:enabled];
    [[self hiddenToggle] setEnabled:enabled];
    [[self formatField] setEnabled:enabled];
    [[self dateField] setEnabled:NO];
}

#pragma mark - Navigation Control

- (void)customizeNavigationBarForEditContent
{
    [[self navigationItem] setTitle:@"Edit Content"];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing:)];
    [[self navigationItem] setRightBarButtonItem:editButton];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];

    [self setFieldsEnabled:NO];
}

- (void)customizeNavigationBarForAddContent
{
    [[self navigationItem] setTitle:@"Add Content"];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addContent:)];
    [[self navigationItem] setRightBarButtonItem:addButton];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];
    
    [self setFieldsEnabled:YES];
}

@end
