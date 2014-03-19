//
//  CustomCastChannel.m
//  AirCast
//
//  Created by Renaud Bardet on 10/02/2014.
//  Copyright (c) 2014 renaudbardet. All rights reserved.
//

#import "CustomCastChannel.h"

@implementation CustomCastChannel

- (void)didReceiveTextMessage:(NSString *)message {
    [super didReceiveTextMessage:message];
    
    GCKLog(@"event from device: %@", message);
    
    if ([self.delegate respondsToSelector:@selector(didReceiveTextMessage:forProtocol:)]) {
        [self.delegate didReceiveTextMessage:message forProtocol:self.protocolNamespace];
    }
    
}

- (void)didConnect {
    [super didConnect];
    
    if([self.delegate respondsToSelector:@selector(didConnectWithProtocol:)])
        [self.delegate didConnectWithProtocol:self.protocolNamespace];
}

- (void)didDisconnect {
    [super didDisconnect];
    
    if([self.delegate respondsToSelector:@selector(didDisconnectWithProtocol:)])
        [self.delegate didDisconnectWithProtocol:self.protocolNamespace];
}

@end