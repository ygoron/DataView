//
//  BILogoff.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-21.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BILogoff.h"
#import "BI4RestConstants.h"
#import "WebiAppDelegate.h"

@implementation BILogoff

@synthesize connectorError;
@synthesize boxiError;
@synthesize delegate;



#pragma mark Logoff

-(void) logoffSessionSync:(Session *)session withToken:(NSString *)token{

    NSLog(@"Logoff Session (Sync) %@ With Token %@",session.name, token);
    self.biSession=session;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getLogoffURL:session]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    WebiAppDelegate *appDelegate= (id)[[UIApplication sharedApplication] delegate];
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:SAP_HTTP_TOKEN];
    [request setValue:[NSString stringWithFormat:@"%d", 0] forHTTPHeaderField:@"Content-Length"];
    session.cmsToken=nil;

#ifndef Prod
    NSString *returnString = [[NSString alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil] encoding:NSUTF8StringEncoding];
    NSLog(@"return String:%@",returnString);
#else
    (void) [[NSString alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil] encoding:NSUTF8StringEncoding];
#endif

//    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%@",@"Logoff (Sync) Completed:",[[NSString alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil] encoding:NSUTF8StringEncoding]]];
}

-(void) logoffSession:(Session *)session withToken:(NSString *)token{
    NSLog(@"Logoff Session %@ With Token %@",session.name, token);
    self.biSession=session;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getLogoffURL:session]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:SAP_HTTP_TOKEN];
    [request setValue:[NSString stringWithFormat:@"%d", 0] forHTTPHeaderField:@"Content-Length"];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];

    
}


-(NSURL *) getLogoffURL: (Session *) session{
    NSLog (@"Logoff URL Session Name:%@",session);
    NSURL *logoffUrl;
    NSString *host=[NSString stringWithFormat: @"%@:%@",session.cmsName,session.port] ;
    if ([session.isHttps integerValue]==1){
        logoffUrl=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@",session.cypressSDKBase,logoffPathPoint] ];
    }
    else{
        logoffUrl=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@",session.cypressSDKBase,logoffPathPoint]];
    }
    NSLog(@"URL:%@",logoffUrl);
    return  logoffUrl;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Logoff didFailWithError for session %@",self.biSession.name);
    NSLog(@"Connection failed: %@", [error localizedDescription]);
    connectorError =[[NSError alloc] init];
    connectorError=error;
    [self.delegate biLogoff:self didLogoff:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
//    NSString *receivedString = [[NSString alloc]  initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"Get Logoff Data:,%@",receivedString );
    _biSession.cmsToken=nil;
//        [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%@",@"Logoff (Async) Completed:",[[NSString alloc]  initWithData:responseData encoding:NSUTF8StringEncoding]]];
    [self.delegate biLogoff:self didLogoff:YES ];

}

@end
