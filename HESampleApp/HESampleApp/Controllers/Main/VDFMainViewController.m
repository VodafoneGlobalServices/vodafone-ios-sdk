//
//  VDFMainViewController.m
//  HESampleApp
//
//  Created by Michał Szymańczyk on 14/07/14.
//  Copyright (c) 2014 Vodafone. All rights reserved.
//

#import "VDFMainViewController.h"
#import <MessageUI/MessageUI.h>
#import <VodafoneSDK/VodafoneSDK.h>

@interface VDFMainViewController ()

@property (nonatomic, strong) NSMutableString *loggedMessages;
@property (nonatomic, strong) NSMutableString *htmlOutput;
@property (nonatomic, strong) NSTimer *scrollViewUpdateTimer;

@property (weak, nonatomic) IBOutlet UISwitch *smsValidationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *smsCodeTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UISwitch *displayLogSwitch;
@property (weak, nonatomic) IBOutlet UITextField *imsiTextField;
@property (weak, nonatomic) IBOutlet UITextField *backendAppKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientAppSecretTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientAppKeyTextField;
@property (weak, nonatomic) IBOutlet UIWebView *outpuWebView;

- (IBAction)onAppIdSetButtonClick:(id)sender;
- (IBAction)onSmsCodeSendButtonClick:(id)sender;
- (IBAction)onRetrieveUserDetailsButtonClick:(id)sender;
- (IBAction)textFieldDidBeginEditing:(UITextField*)textField;
- (IBAction)textFieldDidEndEditing:(UITextField*)textField;
- (IBAction)onClearOutputButtonClick:(id)sender;
- (IBAction)onSendSMSPinButtonClick:(id)sender;
- (IBAction)onSendLogsButtonClick:(id)sender;
- (IBAction)onCancelRetrieveButtonClick:(id)sender;

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
    self.loggedMessages = [[NSMutableString alloc] init];
    self.htmlOutput = [[NSMutableString alloc] init];
    
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
    
    self.backendAppKeyTextField.text = @"6V8HQ9JCSeRBGDhLGRApx9GBaXqTKeuY";
    /*/
    self.clientAppKeyTextField.text = @"OliGwlb2dXiQNbFAJpDehfD2K02ywJHG";
    self.clientAppSecretTextField.text = @"4GJyNlfVqlqgd5TC";
    /*/
    self.clientAppKeyTextField.text = @"I1OpZaPfBcI378Bt7PBhQySW5Setb8eb";
    self.clientAppSecretTextField.text = @"k4l1RXZGqMnw2cD8";
    //*/
    
    self.imsiTextField.text = @"34678774201";
//    self.imsiTextField.text = @"491748862966"; //joaquim phone number
//    self.imsiTextField.text = @"204049810027400";
    
    self.displayLogSwitch.on = YES;
    
    [self recalculateScrollViewContent];
}

- (void)viewWillLayoutSubviews {
    [self recalculateScrollViewContent];
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSString*)vdfErrorCodeToString:(VDFErrorCode)errorCode {
    switch (errorCode) {
        case VDFErrorNoConnection: return @"VDFErrorNoConnection";
        case VDFErrorConnectionTimeout: return @"VDFErrorConnectionTimeout";
        case VDFErrorServerCommunication: return @"VDFErrorServerCommunication";
        case VDFErrorThrottlingLimitExceeded: return @"VDFErrorThrottlingLimitExceeded";
        case VDFErrorInvalidInput: return @"VDFErrorInvalidInput";
        case VDFErrorResolutionTimeout: return @"VDFErrorResolutionTimeout";
        case VDFErrorWrongSmsCode: return @"VDFErrorWrongSmsCode";
        case VDFErrorAuthorizationFailed: return @"VDFErrorAuthorizationFailed";
        case VDFErrorOperatorNotSupported: return @"VDFErrorOperatorNotSupported";
        default:
            return [NSString stringWithFormat:@"%i", errorCode];
    }
}

- (NSString*)resolutionStatusToString:(VDFResolutionStatus)resolutionStatus {
    switch (resolutionStatus) {
        case VDFResolutionStatusCompleted: return @"VDFResolutionStatusCompleted";
        case VDFResolutionStatusUnableToResolve: return @"VDFResolutionStatusUnableToResolve";
        case VDFResolutionStatusValidationRequired: return @"VDFResolutionStatusValidationRequired";
        default:
            return [NSString stringWithFormat:@"%i", resolutionStatus];
    }
}


- (void)recalculateScrollViewContent {
    
    @synchronized(self.scrollView) {
        if(self.scrollViewUpdateTimer == nil) {
            self.scrollViewUpdateTimer =
            [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(onScrollViewUpdateTimerInvocation)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
}

- (void)onScrollViewUpdateTimerInvocation {
    
    @synchronized(self.scrollView) {
        CGRect frame = self.outpuWebView.frame;
        CGSize outputContentSize = [self.outpuWebView sizeThatFits:CGSizeMake([self.outpuWebView sizeThatFits:CGSizeZero].width, FLT_MAX)];
        if(frame.size.height != outputContentSize.height) {
            frame.size.height = outputContentSize.height;
            self.outpuWebView.frame = frame;
        }
        
        CGSize newSize = CGSizeMake(self.view.frame.size.width,520+outputContentSize.height);
        if(self.scrollView.contentSize.height != newSize.height) {
            [self.scrollView setContentSize:newSize];
        }

        self.scrollViewUpdateTimer = nil;
    }
}

- (IBAction)onAppIdSetButtonClick:(id)sender {
    [self hideKeyboard];
    
    @try {
        [VDFSettings initializeWithParams:@{ VDFClientAppKeySettingKey: self.clientAppKeyTextField.text,
                                             VDFClientAppSecretSettingKey: self.clientAppSecretTextField.text,
                                             VDFBackendAppKeySettingKey: self.backendAppKeyTextField.text }];
        [self logSDKInvocationMessage:@"SDK initialized"];
    }
    @catch (NSException *exception) {
        [self logException:exception];
    }
}

- (IBAction)onSmsCodeSendButtonClick:(id)sender {
    [self hideKeyboard];
    
    @try {
        [[VDFUsersService sharedInstance] validateSmsCode:self.smsCodeTextField.text];
    }
    @catch (NSException *exception) {
        [self logException:exception];
    }
}

- (IBAction)onRetrieveUserDetailsButtonClick:(id)sender {
    [self hideKeyboard];
    
    @try {
        VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:self.smsValidationSwitch.isOn];
        if(self.imsiTextField.text != nil && ![self.imsiTextField.text isEqualToString:@""]) {
            options.msisdn = self.imsiTextField.text;
        }
        [[VDFUsersService sharedInstance] retrieveUserDetails:options delegate:self];
    }
    @catch (NSException *exception) {
        [self logException:exception];
    }
}

- (IBAction)onSendSMSPinButtonClick:(id)sender {
    [self hideKeyboard];
    
    @try {
        [[VDFUsersService sharedInstance] sendSmsPin];
    }
    @catch (NSException *exception) {
        [self logException:exception];
    }
}

- (IBAction)onSendLogsButtonClick:(id)sender {
    if(![MFMailComposeViewController canSendMail]) {
        [self logInternalMessage:@"You do not have any email accounts configured on device."];
        return;
    }
    
    NSString *emailTitle = [NSString stringWithFormat: @"Seamless Id Error Report (%@)", [NSDate date]];
    NSString *messageBody = self.loggedMessages;
    NSArray *toRecipents = [NSArray arrayWithObject:@"michal.szymanczyk@mobica.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

- (IBAction)onCancelRetrieveButtonClick:(id)sender {
    [[VDFUsersService sharedInstance] cancelRetrieveUserDetails];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Implementation

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            [self logInternalMessage:@"Mail cancelled"];
            break;
        case MFMailComposeResultSaved:
            [self logInternalMessage:@"Mail saved"];
            break;
        case MFMailComposeResultSent:
            [self logInternalMessage:@"Mail sent"];
            break;
        case MFMailComposeResultFailed:
            [self logInternalMessage:[NSString stringWithFormat:@"Mail sent failure: %@", [error localizedDescription]]];
            break;
        default:
            break;
    }
    // dismiss email interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark VDFUsersServiceDelegate Implementation

-(void)didReceivedUserDetails:(VDFUserTokenDetails*)userDetails withError:(NSError*)error {
    if(error == nil) {
        [self logSDKInvocationMessage:[NSString stringWithFormat:@"didReceivedUserDetails: resolutionStatus=%@, token=%@, expiresIn=%@", [self resolutionStatusToString:userDetails.resolutionStatus], userDetails.token, userDetails.expiresIn]];
    } else {
        [self logSDKInvocationMessage:[NSString stringWithFormat:@"didReceivedUserDetails: errorName=%@", [self vdfErrorCodeToString:[error code]]]];
    }
}

- (void)didValidatedSMSToken:(VDFSmsValidationResponse *)response withError:(NSError *)error {
    [self logSDKInvocationMessage:[NSString stringWithFormat:@"didValidatedSMSToken: smsCode=%@, success=%i, errorName=%@", response.smsCode, response.isSucceded, error != nil ? [self vdfErrorCodeToString:[error code]] : @""]];
}

- (void)didSMSPinRequested:(NSNumber *)isSuccess withError:(NSError *)error {
    [self logSDKInvocationMessage:[NSString stringWithFormat:@"didSMSPinRequested: success=%@, errorName=%@", isSuccess, error != nil ? [self vdfErrorCodeToString:[error code]] : @""]];
}

- (void)logSDKInvocationMessage:(NSString*)message {
    // append for next use
    [self.loggedMessages appendString:message];
    [self.loggedMessages appendString:@"\n"];
    
    [self appendHtmlOutput:message color:@"lightGreen"];
//    NSLog(@"%@",message);
}

- (void)logInternalMessage:(NSString*)message {
    // append for next use
    [self.loggedMessages appendString:message];
    [self.loggedMessages appendString:@"\n"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
            [self appendHtmlOutput:message color:@"orange"];
        //        NSLog(@"%@",message);
    });
}

- (void)logException:(NSException*)exception {
    // append for next use
    NSString *message = [NSString stringWithFormat:@"Exception occured: %@\n", exception];
    [self.loggedMessages appendString:message];
    [self appendHtmlOutput:message color:@"red"];
    //        NSLog(@"%@",message);
}

- (void)appendHtmlOutput:(NSString*)message color:(NSString*)color {
    @synchronized(self.outpuWebView) {
        if(message != nil) {
            [self.htmlOutput appendFormat:@"<pre style=\"background-color: %@; margin-top: 5px;\">%@</pre>", color, message];
        }
        [self.outpuWebView loadHTMLString:[NSString stringWithFormat:@"<html><style type=\"text/css\">body pre { word-break: break-all; font-size: 10px; white-space: pre-wrap; padding: 5px; margin: 0px; border: 0px}</style><body>%@</body></html>", self.htmlOutput] baseURL:nil];
        [self recalculateScrollViewContent];
    }
}

#pragma mark -
#pragma mark VDFMessageLogger Implementation

- (void)logMessage:(NSString*)message ofType:(VDFLogMessageType)logType {
    
    // append for next use
    [self.loggedMessages appendString:message];
    [self.loggedMessages appendString:@"\n"];
    
    if(logType == VDFLogMessageInfoType) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.displayLogSwitch isOn]) {
                [self appendHtmlOutput:message color:@"lightGray"];
            }
//            NSLog(@"%@",message);
        });
    }
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
    [self.htmlOutput setString:@""];
    [self appendHtmlOutput:nil color:nil];
    [self.loggedMessages setString:@""];
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
