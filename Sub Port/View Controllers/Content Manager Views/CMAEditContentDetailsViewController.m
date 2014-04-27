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

@interface CMAEditContentDetailsViewController ()<UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    ContentElement *_contentElement;
    NSMutableArray *_formatTypes;
    FormatType *_selectedFormatType;
    BOOL _isHiddenFlag;
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
        //Is Editing
        [self fetchContentInBackground];
        [self customizeNavigationBarForEditContent];
    } else {
        //Is Adding
        [self customizeNavigationBarForAddContent];
        NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:1209600];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *currDateString = [formatter stringFromDate:currentDate];
        [[self dateField] setText:currDateString];
        [[self hiddenToggle] setOn:NO];
    }
    [self fetchFormatTypesInBackground];
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
    
    [[self hiddenToggle] addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)initializePicker
{
    UIPickerView *formatPicker = [[UIPickerView alloc] init];
    [formatPicker setDelegate:self];
    [formatPicker setDataSource:self];
    [formatPicker setBackgroundColor:[UIColor whiteColor]];
    [formatPicker setShowsSelectionIndicator:YES];
    
    [[self formatField] setInputView:formatPicker];
}

- (IBAction)previewContent:(id)sender
{
    [self synchronizeObjectWithFields];
    
    if ([[_contentElement url] length] > 0) {
        SUBContentDetailsViewController *detailView = [[SUBContentDetailsViewController alloc] initWithURL:[_contentElement url]];
        [[self navigationController] pushViewController:detailView animated:YES];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No URL has been entered!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

- (void)switchChanged:(id)sender
{
    NSLog(@"Switch Toggled");
    
    NSDictionary *postDict = @{@"id": [_contentElement idNumber]};
    NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDict forRouteAppendix:@"hide_content_elements"];
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithDataAfterPost:responseData orError:err];
}

- (void)connectionDidFinishWithDataAfterPost:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[_formatTypes objectAtIndex:row] formatTypeName];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedFormatType = [_formatTypes objectAtIndex:row];
    [[self formatField] setText:[_selectedFormatType formatTypeName]];
}

#pragma mark - General Connection Information

- (void)fetchFormatTypesInBackground
{
    NSMutableURLRequest *request = [WebServiceURLBuilder getRequestForRouteAppendix:@"formats"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self formatConnectionDidFinishWithData:responseData orError:err];
}

- (void)formatConnectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
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
                [_formatTypes addObject:currentFormatType];
            }
        }
        
        [self initializePicker];
        
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
        NSDictionary *contentElementDict = [dataDict objectForKey:@"content_element"];
        
        [_contentElement setName:[contentElementDict objectForKey:@"name"]];
        [_contentElement setUrl:[contentElementDict objectForKey:@"url"]];
        
        if([[[contentElementDict objectForKey:@"hidden_flag"] class] isSubclassOfClass:[NSNull class]])
        {
            [_contentElement setIsHidden:NO];
            _isHiddenFlag = NO;
        } else {
            [_contentElement setIsHidden:YES];
            _isHiddenFlag = YES;
        }
        
        [self initializeView];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
    
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

- (void)synchronizeObjectWithFields
{
    [_contentElement setName:[[self nameField] text]];
    [_contentElement setUrl:[[self urlField] text]];
    [_contentElement setIsHidden:[[self hiddenToggle] isOn]];
    [_contentElement setFormat:_selectedFormatType];
}

#pragma mark - Connection Information FOR EDITING CONTENT

- (void)fetchContentInBackground
{
    NSDictionary *postDictionary = @{@"id": [_contentElement idNumber]};
    NSMutableURLRequest *request = [WebServiceURLBuilder putRequestForRouteAppendix:@"provider_content_elements" withDictionary:postDictionary];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithData:responseData orError:err];
}

- (void)pushEditsToServer
{
    [self synchronizeObjectWithFields];
    
    NSNumber *isHiddenValue = [NSNumber numberWithBool:[_contentElement isHidden]];
    
    NSDictionary *postDictionary = @{ @"provider_id":[[_contentElement provider] idNumber],
                                     @"name":[_contentElement name],
                                     @"link":[_contentElement url],
                                     @"format_id":[[_contentElement format] idNumber],
                                     @"hidden_flag":isHiddenValue  };
    
    NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDictionary forRouteAppendix:@"manage_content_elements"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self pushConnectionDidFinishWithData:responseData orError:err];
}

#pragma mark - Connection Information FOR ADDING CONTENT

- (void)pushNewContentToServer
{
    [self synchronizeObjectWithFields];
    
    NSNumber *isHiddenValue = [NSNumber numberWithBool:[_contentElement isHidden]];
    
    NSDictionary *putDictionary = @{ @"provider_id":[[_contentElement provider] idNumber],
                                            @"name":[_contentElement name],
                                            @"link":[_contentElement url],
                                       @"format_id":[[_contentElement format] idNumber],
                                     @"hidden_flag":isHiddenValue  };
    
    NSMutableURLRequest *request = [WebServiceURLBuilder putRequestForRouteAppendix:@"manage_content_elements" withDictionary:putDictionary];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self pushConnectionDidFinishWithData:responseData orError:err];
}

- (BOOL)validateInformation
{
    [self synchronizeObjectWithFields];
    if ([[_contentElement name] length] <= 0) {
        return false;
    } else if ([[_contentElement url] length] <= 0) {
        return false;
    } else if ([[[_contentElement format] formatTypeName] length] <= 0) {
        return false;
    }
    return true;
}

#pragma mark - Editing Control

- (IBAction)doneEditing:(id)sender
{
    //Verify Information
    if ([self validateInformation]) {
        [self pushEditsToServer];
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:[self dismissBlock]];
    } else {
        UIAlertView *av1 = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"One or more fields isn't complete."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
        [av1 show];
    }
}

- (IBAction)addContent:(id)sender
{
    //Verify Information
    if ([self validateInformation]) {
        [self pushNewContentToServer];
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:[self dismissBlock]];
    } else {
        UIAlertView *av1 = [[UIAlertView alloc] initWithTitle:@"Error"
                                                       message:@"One or more fields isn't   complete."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
        [av1 show];
    }
}

- (IBAction)cancel:(id)sender
{
    [self synchronizeObjectWithFields];
    NSNumber *isHiddenFlagValue = [NSNumber numberWithBool:_isHiddenFlag];
    NSNumber *isHiddenContentValue = [NSNumber numberWithBool:[_contentElement isHidden]];
    
    if ([isHiddenFlagValue isEqualToNumber:isHiddenContentValue]) {
        NSLog(@"They Match!");
    } else {
        NSLog(@"They don't match :(");
        NSDictionary *postDict = @{@"id": [_contentElement idNumber]};
        NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDict forRouteAppendix:@"hide_content_elements"];
        NSURLResponse *response;
        NSError *err;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        
        [self connectionDidFinishWithDataAfterPost:responseData orError:err];
    }
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:[self dismissBlock]];
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
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];

    [self setFieldsEnabled:YES];
    [self setEditing:YES];
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
