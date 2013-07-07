//
//  GetDocuments.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-21.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "GetDocuments.h"
#import "BI4RestConstants.h"

@implementation GetDocuments

@synthesize connectorError;
@synthesize boxiError;
@synthesize delegate;


#pragma mark getDocumentsURL
-(NSURL *) getDocumentsURL: (Session *) session{
    NSLog (@"GetDocuments URL fro Session Name:%@",session);
    NSURL *documentsUrl;
    NSString *host=[NSString stringWithFormat: @"%@:%@",session.cmsName,session.port] ;
    if ([session.isHttps integerValue]==1){
        documentsUrl=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@",session.webiRestSDKBase,getDocumentsPathPoint]];
    }
    else{
        documentsUrl=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@",session.webiRestSDKBase,getDocumentsPathPoint]];
    }
    NSLog(@"URL:%@",documentsUrl);
    return  documentsUrl;
}

#pragma mark getDocuments From Session
-(void) getDocumentsFromSession:(Session *)session{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getDocumentsURL:session]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:session.cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];

    
}
#pragma mark starting getting response from connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    responseData = [[NSMutableData alloc] init];
}

#pragma mark receiving data

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

#pragma mark failed with error

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error localizedDescription]);
    connectorError =[[NSError alloc] init];
    connectorError=error;
    [self.delegate getDocuments:self didGetDocuments:NO] ;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // show all values
    for(id key in res) {

        
        NSLog(@"key: %@", (NSString *)key);
        NSLog(@"value: %@", (NSString *)[res objectForKey:key]);
        
    }
    
    // extract specific value...
    NSArray *results = [res objectForKey:@"results"];
    
    for (NSDictionary *result in results) {
        NSLog(@"icon: %@", [result objectForKey:@"icon"]);
    }
    
    [self.delegate getDocuments:self didGetDocuments:YES];
    
}

@end
