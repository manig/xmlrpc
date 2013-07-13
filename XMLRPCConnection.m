#import "XMLRPCConnection.h"
#import "XMLRPCConnectionManager.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "NSStringAdditions.h"
#import "TTPSharedNetworkActivityIndicator.h"

@interface XMLRPCConnection (XMLRPCConnectionPrivate)

- (void)connection: (NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data;

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error;

#pragma mark -

- (BOOL)connection: (NSURLConnection *)connection canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace;

- (void)connection: (NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)connection: (NSURLConnection *)connection didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)connectionDidFinishLoading: (NSURLConnection *)connection;

@end

#pragma mark -

@implementation XMLRPCConnection

- (id)initWithXMLRPCRequest: (XMLRPCRequest *)request delegate: (id<XMLRPCConnectionDelegate>)delegate manager: (XMLRPCConnectionManager *)manager {
    self = [super init];
    if (self) {
        myManager = manager;
        myRequest = request;
        myIdentifier = [NSString stringByGeneratingUUID];
        myData = [[NSMutableData alloc] init];
        
        myConnection = [[NSURLConnection alloc] initWithRequest: [request request] delegate: self];
        //NSLog(@"request body %@", [[NSString alloc]initWithData: myConnection.originalRequest.HTTPBody encoding:NSUTF8StringEncoding]);

        myDelegate = delegate;
        
        if (myConnection)
        {
            TTPSharedNetworkActivityIndicator *sharedNetworkActivityIndicator = [TTPSharedNetworkActivityIndicator sharedNetworkActivityIndicator];
            sharedNetworkActivityIndicator.networkActivityCount ++;
        }
        else
        {
            return nil;
        }
    }
    
    return self;
}

#pragma mark -

+ (XMLRPCResponse *)sendSynchronousXMLRPCRequest: (XMLRPCRequest *)request error: (NSError **)error {
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest: [request request] returningResponse: &response error: error];
    
    if (response) {
        NSInteger statusCode = [response statusCode];
        
        if ((statusCode < 400) && data) {
            return [[XMLRPCResponse alloc] initWithData: data];
        }
    }
    
    return nil;
}

#pragma mark -

- (NSString *)identifier {
    return myIdentifier;
}

#pragma mark -

- (id<XMLRPCConnectionDelegate>)delegate {
    return myDelegate;
}

#pragma mark -

- (void)cancel {
    [myConnection cancel];
}

#pragma mark -


@end

#pragma mark -

@implementation XMLRPCConnection (XMLRPCConnectionPrivate)

- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    if([response respondsToSelector: @selector(statusCode)]) {
        int statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        if(statusCode >= 400) {
            NSError *error = [NSError errorWithDomain: @"HTTP" code: statusCode userInfo: nil];
            
            [myDelegate request: myRequest didFailWithError: error];
        } else if (statusCode == 304) {
            [myManager closeConnectionForIdentifier: myIdentifier];
        }
    }
    
    [myData setLength: 0];
}

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data {
    [myData appendData: data];
}

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error {
    XMLRPCRequest *request = myRequest;
    
    
    [myDelegate request: request didFailWithError: error];
    TTPSharedNetworkActivityIndicator *sharedNetworkActivityIndicator = [TTPSharedNetworkActivityIndicator sharedNetworkActivityIndicator];
    sharedNetworkActivityIndicator.networkActivityCount --;
    [myManager closeConnectionForIdentifier: myIdentifier];
}

#pragma mark -

- (BOOL)connection: (NSURLConnection *)connection canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace {
    return [myDelegate request: myRequest canAuthenticateAgainstProtectionSpace: protectionSpace];
}

- (void)connection: (NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    [myDelegate request: myRequest didReceiveAuthenticationChallenge: challenge];
}

- (void)connection: (NSURLConnection *)connection didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    [myDelegate request: myRequest didCancelAuthenticationChallenge: challenge];
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection
{
    if (myData && ([myData length] > 0))
    {
        XMLRPCResponse *response = [[XMLRPCResponse alloc] initWithData: myData];
        XMLRPCRequest *request = myRequest;

        //NSLog(@"xml response %@",response.object);

        [myDelegate request: request didReceiveResponse: response];
    }

    TTPSharedNetworkActivityIndicator *sharedNetworkActivityIndicator = [TTPSharedNetworkActivityIndicator sharedNetworkActivityIndicator];
    sharedNetworkActivityIndicator.networkActivityCount --;
    [myManager closeConnectionForIdentifier: myIdentifier];
}

@end
