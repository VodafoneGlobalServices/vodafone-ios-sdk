//
//  VDFMainViewController.m
//  HESampleApp
//
//  Created by Michał Szymańczyk on 14/07/14.
//  Copyright (c) 2014 Vodafone. All rights reserved.
//

#import "VDFMainViewController.h"
#import <VodafoneSDK/VodafoneSDK.h>

@interface VDFMainViewController ()

@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *userResolveSessionTokenTextField;
@property (weak, nonatomic) IBOutlet UISwitch *smsValidationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *smsCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *smsCodeSessionTokenTextField;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UISwitch *displayLogSwitch;

- (IBAction)onAppIdSetButtonClick:(id)sender;
- (IBAction)onSmsCodeSendButtonClick:(id)sender;
- (IBAction)onRetrieveUserDetailsButtonClick:(id)sender;
- (IBAction)onGetUserDetailsButtonClick:(id)sender;
- (IBAction)textFieldDidBeginEditing:(UITextField*)textField;
- (IBAction)textFieldDidEndEditing:(UITextField*)textField;
- (IBAction)onClearOutputButtonClick:(id)sender;

- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
- (void)scrollTap:(UIGestureRecognizer*)gestureRecognizer;
//- (void)recalculateScrollViewContent;
- (void)hideKeyboard;

@end

@implementation VDFMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // register for keyboard handling
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *yourTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTap:)];
    
//    [self.scrollView setBorderType:NSNoBorder];
//    [self.scrollView setHasVerticalScroller:YES];
//    [self.scrollView setHasHorizontalScroller:NO];
//    [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
//    
//    [self.outputTextView setMinSize:NSMakeSize(0.0, contentSize.height)];
//    [self.outputTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
//    [self.outputTextView setVerticallyResizable:YES];
//    [self.outputTextView setHorizontallyResizable:NO];
//    [self.outputTextView setAutoresizingMask:NSViewWidthSizable];
//    
//    [[self.outputTextView textContainer]
//     setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
//    [[self.outputTextView textContainer] setWidthTracksTextView:YES];
    
    [self.scrollView addGestureRecognizer:yourTap];
    [self.view addSubview:self.scrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (IBAction)onAppIdSetButtonClick:(id)sender {
    [self hideKeyboard];
    
    [VDFSettings initializeWithParams:@{ VDFApplicationIdSettingKey: self.appIdTextField.text }];
}

- (IBAction)onSmsCodeSendButtonClick:(id)sender {
    [self hideKeyboard];
    
    [[VDFUsersService sharedInstance] validateSMSToken:self.smsCodeTextField.text withSessionToken:self.smsCodeSessionTokenTextField.text delegate:self];
}

- (IBAction)onRetrieveUserDetailsButtonClick:(id)sender {
    [self hideKeyboard];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithToken:self.userResolveSessionTokenTextField.text validateWithSms:self.smsValidationSwitch.isOn];
    [[VDFUsersService sharedInstance] retrieveUserDetails:options delegate:self];
}

- (IBAction)onGetUserDetailsButtonClick:(id)sender {
    [self hideKeyboard];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithToken:self.userResolveSessionTokenTextField.text validateWithSms:self.smsValidationSwitch.isOn];
    VDFUserTokenDetails *userDetails = [[VDFUsersService sharedInstance] getUserDetails:options];
    
    if(userDetails != nil) {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n onGetUserDetailsButtonClick: resolved=%i, stillRunning=%i, source=%@, token=%@, tetheringConflict=%i, validate=%i", userDetails.resolved, userDetails.stillRunning, userDetails.source, userDetails.token, userDetails.tetheringConflict, userDetails.validated];
    } else {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingString:@"\n onGetUserDetailsButtonClick: nil"];
    }
}

#pragma mark -
#pragma mark VDFUsersServiceDelegate Implementation

-(void)didReceivedUserDetails:(VDFUserTokenDetails*)userDetails withError:(NSError*)error {
    if(error == nil) {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didReceivedUserDetails: resolved=%i, stillRunning=%i, source=%@, token=%@, tetheringConflict=%i, validate=%i", userDetails.resolved, userDetails.stillRunning, userDetails.source, userDetails.token, userDetails.tetheringConflict, userDetails.validated];
        
        // autofill boxes:
        if([self.userResolveSessionTokenTextField.text isEqualToString:@""]) {
            self.userResolveSessionTokenTextField.text = userDetails.token;
        }
        if([self.smsCodeSessionTokenTextField.text isEqualToString:@""]) {
            self.smsCodeSessionTokenTextField.text = userDetails.token;
        }
    } else {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didReceivedUserDetails: errorCode=%i", [error code]];
    }
}

- (void)didValidatedSMSToken:(VDFSmsValidationResponse *)response withError:(NSError *)errorCode {
    self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didValidatedSMSToken: smsCode=%@, success=%i, errorCode=%i", response.smsCode, response.isSucceded, [errorCode code]];
}

#pragma mark -
#pragma mark VDFMessageLogger Implementation

- (void)logMessage:(NSString*)message {
    if([self.displayLogSwitch isOn]) {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n Log: %@", message];
    }
    NSLog(@"%@",message);
}

#pragma mark -
#pragma mark - Keyboard handling

- (void)hideKeyboard {
    if(self.activeField) {
        [self.activeField resignFirstResponder];
    }
}

- (void)scrollTap:(UIGestureRecognizer*)gestureRecognizer {
    [self hideKeyboard];
}

- (IBAction)textFieldDidBeginEditing:(UITextField*)textField {
    self.activeField = textField;
}

- (IBAction)textFieldDidEndEditing:(UITextField*)textField {
    self.activeField = nil;
}

- (IBAction)onClearOutputButtonClick:(id)sender {
    self.outputTextView.text = @"";
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


@end
