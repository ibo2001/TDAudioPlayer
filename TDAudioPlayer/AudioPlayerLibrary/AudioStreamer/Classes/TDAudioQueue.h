//
//  TDAudioQueue.h
//  TDAudioPlayer
//
//  Created by Tony DiPasquale on 10/4/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum TDAudioQueueState {
    TDAudioQueueStateBuffering,
    TDAudioQueueStateStopped,
    TDAudioQueueStatePaused,
    TDAudioQueueStatePlaying
} TDAudioQueueState;

@class TDAudioQueue;

@protocol TDAudioQueueDelegate <NSObject>

- (void)audioQueueDidFinishPlaying;
- (void)audioQueueDidStartPlaying;

@end

@class TDAudioQueueBuffer;

@interface TDAudioQueue : NSObject

@property (assign, atomic) TDAudioQueueState state;
@property (assign, nonatomic) id<TDAudioQueueDelegate> delegate;

- (instancetype)initWithBasicDescription:(AudioStreamBasicDescription)basicDescription bufferCount:(UInt32)bufferCount bufferSize:(UInt32)bufferSize;
- (instancetype)initWithBasicDescription:(AudioStreamBasicDescription)basicDescription bufferCount:(UInt32)bufferCount bufferSize:(UInt32)bufferSize magicCookieData:(void *)magicCookieData magicCookieSize:(UInt32)magicCookieSize;

- (TDAudioQueueBuffer *)nextFreeBuffer;
- (void)enqueue;

- (void)play;
- (void)pause;
- (void)stop;
- (void)finish;

@end
