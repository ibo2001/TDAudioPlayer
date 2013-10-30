//
//  TDAudioQueueBuffer.m
//  TDAudioPlayer
//
//  Created by Tony DiPasquale on 10/11/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import "TDAudioQueueBuffer.h"

const NSUInteger TDMaxPacketDescriptions = 512;

@interface TDAudioQueueBuffer ()

@property (assign, nonatomic) AudioQueueBufferRef audioQueueBuffer;
@property (assign, nonatomic) UInt32 size;
@property (assign, nonatomic) UInt32 fillPosition;
@property (assign, nonatomic) AudioStreamPacketDescription *packetDescriptions;
@property (assign, nonatomic) UInt32 numberOfPacketDescriptions;

@end

@implementation TDAudioQueueBuffer

- (instancetype)initWithAudioQueue:(AudioQueueRef)audioQueue size:(UInt32)size
{
    self = [super init];
    if (!self) return nil;

    self.size = size;
    self.fillPosition = 0;
    self.packetDescriptions = malloc(sizeof(AudioStreamPacketDescription) * TDMaxPacketDescriptions);
    self.numberOfPacketDescriptions = 0;

    OSStatus err = AudioQueueAllocateBuffer(audioQueue, self.size, &_audioQueueBuffer);

    if (err) {
        NSLog(@"Error allocating audio queue buffer");
        return nil;
    }

    return self;
}

- (NSInteger)fillWithData:(const void *)data length:(UInt32)length offset:(UInt32)offset
{
    // fill to brim since no packets
    if (self.fillPosition + length <= self.size) {
        memcpy((char *)(self.audioQueueBuffer->mAudioData + self.fillPosition), (const char *)(data + offset), length);
        self.fillPosition += length;
    } else {
        NSUInteger availableSpace = self.size - self.fillPosition;
        memcpy((char *)(self.audioQueueBuffer->mAudioData + self.fillPosition), (const char *)data, availableSpace);
        self.fillPosition = self.size;
        return length - availableSpace;
    }

    if (self.fillPosition == self.size) {
        return -1;
    }

    return 0;
}

- (BOOL)fillWithData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription
{
    if (self.fillPosition + packetDescription.mDataByteSize > self.size || self.numberOfPacketDescriptions == TDMaxPacketDescriptions) return NO;

    memcpy((char *)(self.audioQueueBuffer->mAudioData + self.fillPosition), (const char *)(data + packetDescription.mStartOffset), packetDescription.mDataByteSize);

    self.packetDescriptions[self.numberOfPacketDescriptions] = packetDescription;
    self.packetDescriptions[self.numberOfPacketDescriptions].mStartOffset = self.fillPosition;
    self.numberOfPacketDescriptions++;

    self.fillPosition += packetDescription.mDataByteSize;

    return YES;
}

- (void)enqueueWithAudioQueue:(AudioQueueRef)audioQueue
{
    self.audioQueueBuffer->mAudioDataByteSize = self.fillPosition;
    OSStatus err = AudioQueueEnqueueBuffer(audioQueue, self.audioQueueBuffer, self.numberOfPacketDescriptions, self.packetDescriptions);

    if (err) {
        NSLog(@"Error enqueueing audio buffer");
    }
}

- (void)reset
{
    self.fillPosition = 0;
    self.numberOfPacketDescriptions = 0;
}

- (BOOL)isEqual:(AudioQueueBufferRef)audioQueueBuffer
{
    return audioQueueBuffer == self.audioQueueBuffer;
}

- (void)freeFromAudioQueue:(AudioQueueRef)audioQueue
{
    AudioQueueFreeBuffer(audioQueue, self.audioQueueBuffer);
}

- (void)dealloc
{
    free(_packetDescriptions);
}

@end
