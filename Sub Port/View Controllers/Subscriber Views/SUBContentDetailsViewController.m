//
//  SUBContentDetailsViewController.m
//  Sub Port
//
//  Created by School on 4/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "SUBContentDetailsViewController.h"
#import "WebServiceURLBuilder.h"

@interface SUBContentDetailsViewController ()<UIAlertViewDelegate> {
    ContentElement *_contentElement;
}

@end

@implementation SUBContentDetailsViewController

- (id)initWithContent:(ContentElement *)contentElement
{
    self = [super init];
    if (self) {
        _contentElement = contentElement;
    }
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
    
    [self customizeNavigationBar];
    [self fetchURLForWebView];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchURLForWebView
{
    NSDictionary *putDictionary = @{@"id":[_contentElement idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder putRequestForRouteAppendix:@"user_content_elements" withDictionary:putDictionary];
    
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
        NSDictionary *contentDict = [dataDict objectForKey:@"content_elements"];
        
        NSString *urlString = [contentDict objectForKey:@"url"];
        
        [[self webView] setBackgroundColor:[UIColor whiteColor]];
        [[self webView] setScalesPageToFit:YES];
        [[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[localError localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

- (void)customizeNavigationBar
{
    [[self navigationItem] setTitle:[_contentElement name]];
}

@end
