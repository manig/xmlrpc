//
//  TTPSharedNetworkActivityIndicator.h
//  The Timothy Partnership iPad Application
//
//  Created by  on 24/06/13.
//  Copyright (c) 2013 Real World Technology Solutions Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPSharedNetworkActivityIndicator : NSObject

+ (id) sharedNetworkActivityIndicator;

@property (nonatomic) int networkActivityCount;

@end
