//
//  TTPSharedNetworkActivityIndicator.m
//  The Timothy Partnership iPad Application
//
//  Created by  on 24/06/13.
//  Copyright (c) 2013 Real World Technology Solutions Pty Ltd. All rights reserved.
//

#import "TTPSharedNetworkActivityIndicator.h"
#import <UIKit/UIKit.h>


static TTPSharedNetworkActivityIndicator *sharedNetworkActivityIndicator = nil;

@implementation TTPSharedNetworkActivityIndicator

+ (id) sharedNetworkActivityIndicator
{
    @synchronized(self)
    {
        if (!sharedNetworkActivityIndicator)
        {
            sharedNetworkActivityIndicator = [[self alloc] init];
        }
    }
    return sharedNetworkActivityIndicator;
}

- (void) setNetworkActivityCount:(int)networkActivityCount
{
    if (!networkActivityCount)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    else
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    _networkActivityCount = networkActivityCount;
}
@end
