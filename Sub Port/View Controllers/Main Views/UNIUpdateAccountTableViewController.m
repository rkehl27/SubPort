//
//  UNIUpdateAccountTableViewController.m
//  Sub Port
//
//  Created by Rebecca Kehl on 4/28/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//
#import "UNIUpdateAccountTableViewController.h"
#import "WebServiceURLBuilder.h"
#import "FormFieldTableViewCell.h"
#import "FormFieldRow.h"
#import "VerifiedUser.h"

@interface UNIUpdateAccountTableViewController ()<UIAlertViewDelegate>{
    NSMutableArray *_rows;
    NSMutableArray *_cells;
    VerifiedUser *_user;
}

@end

@implementation UNIUpdateAccountTableViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self.tableView setRowHeight:66];
        _rows = [[NSMutableArray alloc] init];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Username"]];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Email"]];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Credit Card Number"]];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Expiration Date"]];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"CSV Code"]];
        
        _cells = [[NSMutableArray alloc] init];
        
        [self.tableView setAllowsSelection:NO];
        [self configureNavigationController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"FormFieldTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FormFieldTableViewCell1"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FormFieldTableViewCell1" forIndexPath:indexPath];
    
    FormFieldRow *item = [_rows objectAtIndex:[indexPath row]];
    
    [[cell rowLabel] setText:[item label]];
    
    if ([[[cell rowLabel] text] isEqualToString:@"Credit Card Number"]) {
        [[cell rowTextField] setKeyboardType:UIKeyboardTypeNumberPad];
    } else if ([[[cell rowLabel] text] isEqualToString:@"CSV Code"]) {
        [[cell rowTextField] setKeyboardType:UIKeyboardTypeNumberPad];
    } else if ([[[cell rowLabel] text] isEqualToString:@"Expiration Date"]) {
        [[cell rowTextField] setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    }
    
    [self synchronizeCellWithUserInfo];
    
    [_cells addObject:cell];
    
    return cell;
}

#pragma mark - Configure nav control

- (void)configureNavigationController
{
    [[self navigationItem] setTitle:@"Update Account"];
    
    UIBarButtonItem *signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Change Info"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(updateInfo:)];
    
    [[self navigationItem] setRightBarButtonItem:signUpButton];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:.086 green:.7216 blue:1 alpha:1];
}

#pragma mark - Validation and synchronization

- (BOOL)validateInformation
{
    UIAlertView *av1 = [[UIAlertView alloc] init];
    UIAlertView *av3 = [[UIAlertView alloc] init];
    BOOL emptyField = false;
    BOOL error = false;
    _user = [[VerifiedUser alloc] init];
    
    for (int i = 0; i<[_cells count]; i++) {
        FormFieldTableViewCell *cell = [_cells objectAtIndex:i];
        if ([[[cell rowTextField] text] length] == 0) {
            av1 = [[UIAlertView alloc] initWithTitle:@"Error"
                                             message:@"One or more fields isn't complete."
                                            delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles: nil];
            emptyField = true;
        } else {
            if ([[[cell rowLabel] text] isEqualToString:@"Username"]) {
                [_user setName:[[cell rowTextField] text]];
            } else if ([[[cell rowLabel] text] isEqualToString:@"Email"]) {
                [_user setEmail:[[cell rowTextField] text]];
            } else if ([[[cell rowLabel] text] isEqualToString:@"Credit Card Number"]) {
                if ([[[cell rowTextField] text] length] < 16) {
                    av3 = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:@"Credit Card number is too short."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
                    error = true;
                } else if ([[[cell rowTextField] text] length] > 16) {
                    av3 = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:@"Credit Card number is too long."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
                    error = true;
                } else {
                    if ([[[[cell rowTextField] text] stringByReplacingOccurrencesOfString:@"X" withString:@""] length] < 16) {
                        [_user setCreditCardNumber:[[VerifiedUser sharedUser] creditCardNumber]];
                    } else {
                        [_user setCreditCardNumber:[[cell rowTextField] text]];
                    }
                }
            } else if ([[[cell rowLabel] text] isEqualToString:@"Expiration Date"]) {
                [_user setExpirationDate:[[cell rowTextField] text]];
            } else if ([[[cell rowLabel] text] isEqualToString:@"CSV Code"]){
                [_user setCsvCode:[[cell rowTextField] text]];
            } else {
                //error
            }
        }
    }
    
    
    if (emptyField) {
        [av1 show];
    } else if (error) {
        [av3 show];
    } else {
        return true;
    }
    
    return false;
}

- (IBAction)updateInfo:(id)sender
{
    if ([self validateInformation]) {
        [self postNewAccountInformationToServer];
    } else {
    }
}

- (void)synchronizeCellWithUserInfo
{
    for (FormFieldTableViewCell *cell in _cells) {
        if ([[[cell rowLabel] text] isEqualToString:@"Username"]) {
            [[cell rowTextField] setText:[[VerifiedUser sharedUser] name]];
        } else if ([[[cell rowLabel] text] isEqualToString:@"Email"]) {
            [[cell rowTextField] setText:[[VerifiedUser sharedUser] email]];
        } else if ([[[cell rowLabel] text] isEqualToString:@"Credit Card Number"]) {
            NSString *creditCardString = [[VerifiedUser sharedUser] creditCardNumber];
            NSString *hideNumbers = [creditCardString stringByReplacingCharactersInRange:NSMakeRange(0, 12) withString:@"XXXXXXXXXXXX"];
            [[cell rowTextField] setText:hideNumbers];
            
        } else if ([[[cell rowLabel] text] isEqualToString:@"Expiration Date"]) {
            [[cell rowTextField] setText:[[VerifiedUser sharedUser] expirationDate]];
        } else if ([[[cell rowLabel] text] isEqualToString:@"CSV Code"]){
            [[cell rowTextField] setText:[[VerifiedUser sharedUser] csvCode]];
        } else {
            //error
        }
    }
}

#pragma mark - Connection Information

-(void)postNewAccountInformationToServer
{
    NSDictionary *putDict = @{@"email":[_user email],
                              @"name":[_user name],
                              @"credit_card_number":[_user creditCardNumber],
                              @"expiration_date":[_user expirationDate],
                              @"csc":[_user csvCode]
                              };
    
    NSMutableURLRequest *request = [WebServiceURLBuilder putRequestForRouteAppendix:@"update_account" withDictionary:putDict];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithData:responseData orError:err];
}

- (void)connectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Response: %@", responseString);
    
    NSError *localError;
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        
        [[VerifiedUser sharedUser] setName:[_user name]];
        [[VerifiedUser sharedUser] setEmail:[_user email]];
        [[VerifiedUser sharedUser] setCreditCardNumber:[_user creditCardNumber]];
        [[VerifiedUser sharedUser] setCsvCode:[_user csvCode]];
        [[VerifiedUser sharedUser] setExpirationDate:[_user expirationDate]];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:[responseDictionary valueForKey:@"info"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

@end