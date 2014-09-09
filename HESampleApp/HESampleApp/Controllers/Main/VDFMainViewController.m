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
- (IBAction)textFieldDidBeginEditing:(UITextField*)textField;
- (IBAction)textFieldDidEndEditing:(UITextField*)textField;
- (IBAction)onClearOutputButtonClick:(id)sender;
- (IBAction)onSendSMSPinButtonClick:(id)sender;

- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
- (void)scrollTap:(UIGestureRecognizer*)gestureRecognizer;
- (void)recalculateScrollViewContent;
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
    
    [self.scrollView addGestureRecognizer:yourTap];
    [self.view addSubview:self.scrollView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.scrollView setScrollEnabled:YES];
    
    [self recalculateScrollViewContent];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)recalculateScrollViewContent {
    CGRect frame = self.outputTextView.frame;
    frame.size.height = self.outputTextView.contentSize.height;
    self.outputTextView.frame = frame;
    
    [self.scrollView setContentSize:(CGSizeMake(self.view.frame.size.width,480+self.outputTextView.frame.size.height))];
}

- (IBAction)onAppIdSetButtonClick:(id)sender {
    [self hideKeyboard];
    
    [VDFSettings initializeWithParams:@{ VDFApplicationIdSettingKey: self.appIdTextField.text }];
}

- (IBAction)onSmsCodeSendButtonClick:(id)sender {
    [self hideKeyboard];
    
    [[VDFUsersService sharedInstance] validateSmsPin:self.smsCodeTextField.text withSessionToken:self.smsCodeSessionTokenTextField.text delegate:self];
}

- (IBAction)onRetrieveUserDetailsButtonClick:(id)sender {
    [self hideKeyboard];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithValidateWithSms:self.smsValidationSwitch.isOn];
    [[VDFUsersService sharedInstance] retrieveUserDetails:options delegate:self];
}

- (IBAction)onSendSMSPinButtonClick:(id)sender {
    [self hideKeyboard];
    
    [[VDFUsersService sharedInstance] sendSmsPinWithSession:self.smsCodeSessionTokenTextField.text delegate:self];
}

#pragma mark -
#pragma mark VDFUsersServiceDelegate Implementation

-(void)didReceivedUserDetails:(VDFUserTokenDetails*)userDetails withError:(NSError*)error {
    if(error == nil) {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didReceivedUserDetails: resolved=%i, stillRunning=%i, token=%@, validationRequired=%i", userDetails.resolved, userDetails.stillRunning, userDetails.token, userDetails.validationRequired];
        
        // autofill box:
        if([self.smsCodeSessionTokenTextField.text isEqualToString:@""]) {
            self.smsCodeSessionTokenTextField.text = userDetails.token;
        }
    } else {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didReceivedUserDetails: errorCode=%i", [error code]];
    }
    
    [self recalculateScrollViewContent];
}

- (void)didValidatedSMSToken:(VDFSmsValidationResponse *)response withError:(NSError *)errorCode {
    self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didValidatedSMSToken: smsCode=%@, success=%i, errorCode=%i", response.smsCode, response.isSucceded, [errorCode code]];
    [self recalculateScrollViewContent];
}

- (void)didSMSPinRequested:(NSNumber *)isSuccess withError:(NSError *)error {
    self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didSMSPinRequested: success=%@, errorCode=%i", isSuccess, [error code]];
    [self recalculateScrollViewContent];
}

#pragma mark -
#pragma mark VDFMessageLogger Implementation

- (void)logMessage:(NSString*)message {
    if([self.displayLogSwitch isOn]) {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n Log: %@", message];
        [self recalculateScrollViewContent];
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
    [self recalculateScrollViewContent];
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
