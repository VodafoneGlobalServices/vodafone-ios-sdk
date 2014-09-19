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

@property (weak, nonatomic) IBOutlet UISwitch *smsValidationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *smsCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *smsCodeSessionTokenTextField;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UISwitch *displayLogSwitch;
@property (weak, nonatomic) IBOutlet UITextField *imsiTextField;
@property (weak, nonatomic) IBOutlet UITextField *backendAppKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientAppSecretTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientAppKeyTextField;

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
    
    self.imsiTextField.text = @"491748862966";
//    self.imsiTextField.text = @"204049810027400";
    
    [self recalculateScrollViewContent];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSString*)vdfErrorCodeToString:(VDFErrorCode)errorCode {
    switch (errorCode) {
        case VDFErrorNoConnection: return @"VDFErrorNoConnection";
        case VDFErrorConnectionTimeout: return @"VDFErrorConnectionTimeout";
        case VDFErrorNoGSMConnection: return @"VDFErrorNoGSMConnection";
        case VDFErrorServerCommunication: return @"VDFErrorServerCommunication";
        case VDFErrorThrottlingLimitExceeded: return @"VDFErrorThrottlingLimitExceeded";
        case VDFErrorInvalidInput: return @"VDFErrorInvalidInput";
        case VDFErrorTokenNotFound: return @"VDFErrorTokenNotFound";
        case VDFErrorWrongSmsCode: return @"VDFErrorWrongSmsCode";
        case VDFErrorApixAuthorization: return @"VDFErrorApixAuthorization";
        case VDFErrorMsisdnCountryNotSupported: return @"VDFErrorMsisdnCountryNotSupported";
        case VDFErrorOAuthTokenRetrieval: return @"VDFErrorOAuthTokenRetrieval";
        case VDFErrorOutOfVodafoneCellular: return @"VDFErrorOutOfVodafoneCellular";
        default:
            return [NSString stringWithFormat:@"%i", errorCode];
    }
}

- (NSString*)resolutionStatusToString:(ResolutionStatus)resolutionStatus {
    switch (resolutionStatus) {
        case ResolutionStatusCompleted: return @"ResolutionStatusCompleted";
        case ResolutionStatusPending: return @"ResolutionStatusPending";
        case ResolutionStatusFailed: return @"ResolutionStatusFailed";
        case ResolutionStatusValidationRequired: return @"ResolutionStatusValidationRequired";
        default:
            return [NSString stringWithFormat:@"%i", resolutionStatus];
    }
}


- (void)recalculateScrollViewContent {
    CGRect frame = self.outputTextView.frame;
    frame.size.height = self.outputTextView.contentSize.height;
    self.outputTextView.frame = frame;
    
    [self.scrollView setContentSize:(CGSizeMake(self.view.frame.size.width,480+self.outputTextView.frame.size.height))];
}

- (IBAction)onAppIdSetButtonClick:(id)sender {
    [self hideKeyboard];
    
    [VDFSettings initializeWithParams:@{ VDFClientAppKeySettingKey: self.clientAppKeyTextField.text,
                                         VDFClientAppSecretSettingKey: self.clientAppSecretTextField.text,
                                         VDFBackendAppKeySettingKey: self.backendAppKeyTextField.text }];
}

- (IBAction)onSmsCodeSendButtonClick:(id)sender {
    [self hideKeyboard];
    
    [[VDFUsersService sharedInstance] validateSmsCode:self.smsCodeTextField.text inSession:self.smsCodeSessionTokenTextField.text delegate:self];
}

- (IBAction)onRetrieveUserDetailsButtonClick:(id)sender {
    [self hideKeyboard];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:self.smsValidationSwitch.isOn];
    if(self.imsiTextField.text != nil && ![self.imsiTextField.text isEqualToString:@""]) {
        options.msisdn = self.imsiTextField.text;
    }
    [[VDFUsersService sharedInstance] retrieveUserDetails:options delegate:self];
}

- (IBAction)onSendSMSPinButtonClick:(id)sender {
    [self hideKeyboard];
    
    [[VDFUsersService sharedInstance] sendSmsPinInSession:self.smsCodeSessionTokenTextField.text delegate:self];
}

#pragma mark -
#pragma mark VDFUsersServiceDelegate Implementation

-(void)didReceivedUserDetails:(VDFUserTokenDetails*)userDetails withError:(NSError*)error {
    if(error == nil) {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didReceivedUserDetails: resolutionStatus=%@, token=%@, expiresIn=%@", [self resolutionStatusToString:userDetails.resolutionStatus], userDetails.token, userDetails.expiresIn];
        
        // autofill box:
        if([self.smsCodeSessionTokenTextField.text isEqualToString:@""]) {
            self.smsCodeSessionTokenTextField.text = userDetails.token;
        }
    } else {
        self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didReceivedUserDetails: errorName=%@", [self vdfErrorCodeToString:[error code]]];
    }
    
    [self recalculateScrollViewContent];
}

- (void)didValidatedSMSToken:(VDFSmsValidationResponse *)response withError:(NSError *)error {
    self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didValidatedSMSToken: smsCode=%@, success=%i, errorName=%@", response.smsCode, response.isSucceded, error != nil ? [self vdfErrorCodeToString:[error code]] : @""];
    [self recalculateScrollViewContent];
}

- (void)didSMSPinRequested:(NSNumber *)isSuccess withError:(NSError *)error {
    self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n didSMSPinRequested: success=%@, errorName=%@", isSuccess, error != nil ? [self vdfErrorCodeToString:[error code]] : @""];
    [self recalculateScrollViewContent];
}

#pragma mark -
#pragma mark VDFMessageLogger Implementation

- (void)logMessage:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.displayLogSwitch isOn]) {
            self.outputTextView.text = [self.outputTextView.text stringByAppendingFormat:@"\n Log: %@", message];
            [self recalculateScrollViewContent];
        }
        NSLog(@"%@",message);
    });
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
