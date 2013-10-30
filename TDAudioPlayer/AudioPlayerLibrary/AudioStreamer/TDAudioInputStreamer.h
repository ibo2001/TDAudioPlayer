//
//  TDAudioInputStreamer.h
//  TDAudioPlayer
//
//  Created by Tony DiPasquale on 10/4/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>

extern NSString *const TDAudioInputStreamerDidFinishPlayingNotification;
extern NSString *const TDAudioInputStreamerDidStartPlayingNotification;

@interface TDAudioInputStreamer : NSObject

@property (assign, nonatomic) UInt32 audioStreamReadMaxLength;
@property (assign, nonatomic) UInt32 audioQueueBufferSize;
@property (assign, nonatomic) UInt32 audioQueueBufferCount;

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithInputStream:(NSInputStream *)inputStream;

- (void)start;

- (void)resume;
- (void)pause;
- (void)stop;

@end
