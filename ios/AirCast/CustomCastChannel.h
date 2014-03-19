//
//  CustomCastChannel.h
//  AirCast
//
//  Created by Renaud Bardet on 10/02/2014.
//  Copyright (c) 2014 renaudbardet. All rights reserved.
//

#import <GoogleCast/GoogleCast.h>

@protocol CustomCastChannelDelegate<NSObject>

@optional

/** Called when the channel receives a message */
- (void)didReceiveTextMessage:(NSString*) message forProtocol:(NSString*) protocol;

/** Called when the channel succefully connects to the device */
- (void)didConnectWithProtocol:(NSString*) protocol;

/** Called when the channel disconnects */
- (void)didDisconnectWithProtocol:(NSString*) protocol;;

@end

@interface CustomCastChannel : GCKCastChannel

@property(nonatomic, weak) id<CustomCastChannelDelegate> delegate;

@end