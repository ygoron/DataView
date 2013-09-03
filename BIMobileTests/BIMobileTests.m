//
//  BIMobileTests.m
//  BIMobileTests
//
//  Created by Yuri Goron on 2013-09-01.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "BIMobileTests.h"
#import "DashboardViewController.h"


@implementation BIMobileTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testMobileLogon
{
    NSLog(@"Test Started");
    
    DashboardViewController *dbvc=[[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:nil];
    [dbvc loadDashBoard];
    [dbvc presentedViewController];
    
//    STFail(@"Unit tests are not implemented yet in BIMobileTests");
}


@end
