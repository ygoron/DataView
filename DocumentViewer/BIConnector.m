//
//  BIConnector.m
//  WebiViewer
//
//  Created by Yuri Goron on 2013-02-12.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIConnector.h"
#import "BI4RestConstants.h"
#import "WebiAppDelegate.h"

@implementation BIConnector
{
    UITextField *passwordTextField;
    WebiAppDelegate *appDelegate;
}
@synthesize url,user,password,authType;
@synthesize connectorError;
@synthesize cmsToken;
@synthesize biSession;
@synthesize boxiError;
@synthesize timeOut;



#pragma mark Get CMS Token



-(void) getCmsTokenWithSession:(Session *)session{
    appDelegate= (id)[[UIApplication sharedApplication] delegate];
    self.biSession=session;
    NSLog(@"getCmsTokenWithSession for Session %@",session.name);
    //    if (session.password==nil|| [session.password isEqualToString:@""]){
    if (session.password==nil  && [appDelegate.globalSettings.isSavePassword boolValue]==NO){
        NSLog(@"Password is null - proceed with password prompt");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password",nil) message:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Enter your password for:",nil),session.name] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Ok",nil), nil];
        alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alertView show];
    }else{
        //    if (session.password!=nil && ![session.password isEqualToString:@""]){
        [self processRequest];
        
    }
    
}

-(void) processRequest{

    appDelegate= (id)[[UIApplication sharedApplication] delegate];

    if (self.biSession==nil) self.biSession=appDelegate.activeSession;
    NSArray *keys = [NSArray arrayWithObjects:@"userName", @"password",@"auth", nil];
    NSArray *objects = [NSArray arrayWithObjects:self.biSession.userName, self.biSession.password,self.biSession.authType, nil];
    
    NSLog(@"Objects %@",objects);
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    if([NSJSONSerialization isValidJSONObject:jsonDictionary])
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String %@",jsonString);
    }
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getLogonURL:self.biSession]];
    if (timeOut !=0)[request setTimeoutInterval:timeOut];
    else {
        NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
        [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    }
    NSLog(@"Request Timeout is Set to %f",request.timeoutInterval);
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self ];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    passwordTextField=[alertView textFieldAtIndex:0];
    NSLog(@"password:%@",passwordTextField.text);
    
    self.biSession.password=passwordTextField.text;
    [self processRequest];
    
}

-(NSURL *) getLogonURL: (Session *) session{
    NSLog (@"Session Name:%@",session);
    NSURL *logonUrl;
    NSString *host=[NSString stringWithFormat: @"%@:%@",session.cmsName,session.port] ;
    if ([session.isHttps integerValue]==1){
        logonUrl=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@",session.cypressSDKBase,logonPathPoint]];
    }
    else{
        logonUrl=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@",session.cypressSDKBase,logonPathPoint]];
    }
    NSLog(@"URL:%@",logonUrl);
    return  logonUrl;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"BIConnector didFailWithError. %@ Session %@",[connection currentRequest],biSession.name);
    NSLog(@"BIConnector Connection failed: %@", [error localizedDescription]);
    connectorError =[[NSError alloc] init];
    connectorError=error;
    //[self.delegate biConnector:self didCreateCmsToken:self.cmsToken forSession:biSession] ;
    self.cmsToken=nil;
    NSLog (@"Delegate To:%@",self.delegate);
    [self.delegate biConnector:self didCreateCmsToken:self.cmsToken forSession:biSession] ;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    NSLog(@"Get CMS Token Data:,%@",[[NSString alloc]  initWithData:responseData encoding:NSUTF8StringEncoding] );
    [TestFlight passCheckpoint:@"CMS Token Created"];
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // show all values
    for(id key in res) {
        
        id value = [res objectForKey:key];
        
        NSString *keyAsString = (NSString *)key;
        NSString *valueAsString = (NSString *)value;
        
        NSLog(@"key: %@", keyAsString);
        NSLog(@"value: %@", valueAsString);
        
        if ([keyAsString isEqualToString:JSON_RESP_TOKEN]){
            self.cmsToken=valueAsString;
            biSession.cmsToken=valueAsString;
        } else if ([keyAsString isEqualToString:JSON_RESP_ERROR_MESSAGE]){
            self.boxiError=valueAsString;
//            if (passwordTextField!=nil) self.biSession.password=nil;
            if ([appDelegate.globalSettings.isSavePassword boolValue]==NO) self.biSession.password=nil;
        }
        
    }
    
    // extract specific value...
    NSArray *results = [res objectForKey:@"results"];
    
    for (NSDictionary *result in results) {
        NSLog(@"icon: %@", [result objectForKey:@"icon"]);
    }
    
    NSLog(@"Delegate %@",self.delegate);
    
    [self.delegate biConnector:self didCreateCmsToken:self.cmsToken forSession:biSession];
    
    
}

@end
