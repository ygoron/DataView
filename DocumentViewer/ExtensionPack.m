//
//  ExtensionPack.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-17.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "ExtensionPack.h"
#import "WebiAppDelegate.h"
#import "BI4RestConstants.h"
#import "SessionInfo.h"

@implementation ExtensionPack

{
    WebiAppDelegate *appDelegate;
    int operationcode;
    NSString *__cmsToken;
    
}

-(void)getExtensionPackInfoWithToken:(NSString *)cmsToken forExtensionPackUrl:(NSString *)urlString
{
    operationcode=FUNCTION_GET_SESSION;
    appDelegate= (id)[[UIApplication sharedApplication] delegate];
    __cmsToken=cmsToken;
    
    NSURL *url=[self getSessionInfoUrl:urlString];
    if (url!=nil){
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        if (_timeOut !=0)[request setTimeoutInterval:_timeOut];
        else {
            NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
            [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
        }
        NSLog(@"Request Timeout is Set to %f",request.timeoutInterval);
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
        (void)[[NSURLConnection alloc] initWithRequest:request delegate:self ];
    }
    
}

-(NSURL *) getSessionInfoUrl: (NSString *) urlPath
{
    NSString *stringUrl=[NSString stringWithFormat:@"%@%@",urlPath,@"/session.info"];
    NSLog(@"Url To Execute:%@",stringUrl);
    
    NSURL *url =[NSURL URLWithString:stringUrl];
    if (url && url.host && url.scheme){
        return url;
    }else{
        [self.delegate ExtensionPack:self didGetSessionInfo:nil forToken:__cmsToken withError: NSLocalizedString(@"Incorrect Extension Pack URL", nil) withSuccess:NO];
        return nil;
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse from URL %@",[response URL]);
    
    if ([response respondsToSelector:@selector(statusCode)])
    {
        _statusCode = [((NSHTTPURLResponse *)response) statusCode];
        responseData = [[NSMutableData alloc] init];
        
        
    }
    
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Get Extension Pack Info Failed: %@",[error localizedDescription]);
    [self.delegate ExtensionPack:self didGetSessionInfo:nil forToken:__cmsToken withError:error.localizedDescription withSuccess:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    
#ifdef Trace
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"ExtensionPack Response:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    
    // convert to JSON
    NSError *myError = nil;
    if (responseData !=nil){
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
        if (myError!=nil) {
            NSLog(@"Error:%@",myError.localizedDescription);
            [self.delegate ExtensionPack:self didGetSessionInfo:nil forToken:__cmsToken withError:myError.localizedDescription withSuccess:NO];
        }else{
            
            NSLog(@"Result:%@",responseDic);
            NSLog(@"All keys:%@",[responseDic allKeys]);
            
            
            switch (operationcode) {
                case FUNCTION_GET_SESSION:
                {
                    if ([responseDic isKindOfClass:[NSDictionary class]]){
                        SessionInfo *sessionInfo=[[SessionInfo alloc]init];
                        sessionInfo.httpCode=[[responseDic objectForKey:@"httpCode"] integerValue];
                        sessionInfo.message=[responseDic objectForKey:@"message"];
                        sessionInfo.biPlatformVersion=[[responseDic objectForKey:@"biPlatformVersion"] integerValue];
                        sessionInfo.mobileServiceVersion=[responseDic objectForKey:@"mobileServiceVersion"];
                        
                        if (sessionInfo.biPlatformVersion<=0){
                            NSLog(@"Message:%@",sessionInfo.message);
                            [self.delegate ExtensionPack:self didGetSessionInfo:nil forToken:__cmsToken withError:sessionInfo.message withSuccess:NO];
                        }
                        else
                            [self.delegate ExtensionPack:self didGetSessionInfo:sessionInfo forToken:__cmsToken withError:nil withSuccess:YES];
                        
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }else{
        [self.delegate ExtensionPack:self didGetSessionInfo:nil forToken:__cmsToken withError:NSLocalizedString(@"Failed", nil) withSuccess:NO];
    }
    
}


@end
