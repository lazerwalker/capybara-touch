// Copyright (c) 2012, Fuji Xerox Co., Ltd.
// All rights reserved.
// Author: Surendar Chandra, FX Palo Alto Laboratory, Inc.

#import <Foundation/Foundation.h>

@protocol TCPServerDelegate;

typedef enum {
    kTCPServerCouldNotBindToIPv4Address = 1,
    kTCPServerCouldNotBindToIPv6Address = 2,
    kTCPServerNoSocketsAvailable = 3,
} TCPServerErrorCode;

@interface TCPServer : NSObject {
@private
    id delegate;
    NSString *domain;
    NSString *name;
    NSString *type;
    uint16_t port;
    CFSocketRef ipv4socket;
    CFSocketRef ipv6socket;
    NSNetService *netService;
}

- (id<TCPServerDelegate>)delegate;
- (void)setDelegate:(id<TCPServerDelegate>)value;

- (NSString *)domain;
- (void)setDomain:(NSString *)value;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSString *)type;
- (void)setType:(NSString *)value;

- (uint16_t)port;
- (void)setPort:(uint16_t)value;

- (BOOL)start:(NSError **)error;
- (BOOL)stop;

- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr;
// called when a new connection comes in; by default, informs the delegate

@end

@protocol TCPServerDelegate
- (void)TCPServer:(TCPServer *)server didReceiveConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr;
// if the delegate implements this method, it is called when a new  
// connection comes in; a subclass may, of course, change that behavior
@end

