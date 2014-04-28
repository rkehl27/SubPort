//
//  CreateAccountTableViewController.m
//  Sub Port
//
//  Created by School on 3/30/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "CreateAccountTableViewController.h"
#import "FormFieldTableViewCell.h"
#import "FormFieldRow.h"
#import "VerifiedUser.h"
#import "SUBSelectProvidersTableViewController.h"

@interface CreateAccountTableViewController ()<UIAlertViewDelegate>{
    NSMutableArray *_rows;
    NSMutableArray *_cells;
    VerifiedUser *_user;
}

@end

@implementation CreateAccountTableViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self.tableView setRowHeight:66];
        _rows = [[NSMutableArray alloc] init];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Username"]];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Password"]];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Password Confirmation"]];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Email"]];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Credit Card Number"]];
        [_rows addObject:[[FormFieldRow alloc] initWithLabel:@"Expiration Date"]];
        
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
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FormFieldTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FormFieldTableViewCell" forIndexPath:indexPath];
    
    FormFieldRow *item = [_rows objectAtIndex:[indexPath row]];
    
    [[cell rowLabel] setText:[item label]];
    
    if ([[[cell rowLabel] text] isEqualToString:@"Password"]) {
        [[cell rowTextField] setSecureTextEntry:YES];
    }
    
    if ([[[cell rowLabel] text] isEqualToString:@"Password Confirmation"]) {
        [[cell rowTextField] setSecureTextEntry:YES];
    }
    
    if ([[[cell rowLabel] text] isEqualToString:@"Credit Card Number"]) {
        [[cell rowTextField] setKeyboardType:UIKeyboardTypeNumberPad];
        [[cell rowTextField] setPlaceholder:@"################"];
    }
    
    [_cells addObject:cell];
    
    return cell;
}

- (void)configureNavigationController
{
    [[self navigationItem] setTitle:@"Create Account"];
    
    UIBarButtonItem *signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(signUp:)];
    
    [[self navigationItem] setRightBarButtonItem:signUpButton];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Login.png"]];
}

- (BOOL)validateInformation
{
    UIAlertView *av1 = [[UIAlertView alloc] init];
    UIAlertView *av2 = [[UIAlertView alloc] init];
    UIAlertView *av3 = [[UIAlertView alloc] init];
    BOOL emptyField = false;
    BOOL passwordsMatch = false;
    BOOL error = false;
    _user = [[VerifiedUser alloc] init];
    NSString *password;
    NSString *passwordConfirm;
    
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
            } else if ([[[cell rowLabel] text] isEqualToString:@"Password"]) {
                password = [[cell rowTextField] text];
            } else if ([[[cell rowLabel] text] isEqualToString:@"Password Confirmation"]) {
                passwordConfirm = [[cell rowTextField] text];
                if ([password isEqualToString:passwordConfirm]){
                    passwordsMatch = true;
                }
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
                    [_user setCreditCardNumber:[[cell rowTextField] text]];
                }
            } else if ([[[cell rowLabel] text] isEqualToString:@"Expiration Date"]) {
                [_user setExpirationDate:[[cell rowTextField] text]];
            } else {
                //error
            }
            
            if (passwordsMatch) {
                [_user setPassword:password];
            } else {
                av2 = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:@"Passwords Don't Match"
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles: nil];
            }
        }
    }
    
    
    if (emptyField) {
        [av1 show];
    } else if (!passwordsMatch) {
        [av2 show];
    } else if (error) {
        [av3 show];
    } else {
        return true;
    }
    
    return false;
}

- (IBAction)signUp:(id)sender
{
    if ([self validateInformation]) {
        NSLog(@"Sign up valid");
        [self postNewAccountInformationToServer];
    } else {
        NSLog(@"Sign up Invalid");
    }
    
    NSLog(@"Sign Up Pressed!");
}

-(void)postNewAccountInformationToServer
{
    NSDictionary *inputData = @{@"user":@{
                                        @"email":[_user email],
                                        @"name":[_user name],
                                        @"password":[_user password],
                                        @"password_confirmation":[_user password],
                                        @"credit_card_number":[_user creditCardNumber],
                                        @"expiration_date":[_user expirationDate]}};
    
    NSError *error = nil;
    NSData *jsonInputData = [NSJSONSerialization dataWithJSONObject:inputData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:@"http://subportinc.herokuapp.com/api/v1/registrations"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonInputData];
    
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
        [[VerifiedUser sharedUser] setPassword:[_user password]];
        [[VerifiedUser sharedUser] setEmail:[_user email]];
        [[VerifiedUser sharedUser] setCreditCardNumber:[_user creditCardNumber]];
        [[VerifiedUser sharedUser] setExpirationDate:[_user expirationDate]];
        [[VerifiedUser sharedUser] setAuthToken:[dataDict objectForKey:@"auth_token"]];
        
        SUBSelectProvidersTableViewController *selectProvidersViewController = [[SUBSelectProvidersTableViewController alloc] initWithRootView:@"createAccount"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:selectProvidersViewController];
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

@end
