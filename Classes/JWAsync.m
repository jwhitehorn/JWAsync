//
//  JWAsync.m
//  AsyncTools
//
//  Created by Jason Whitehorn on 6/6/14.
//  Copyright (c) 2014 Jason Whitehorn. All rights reserved.
//

#import "JWAsync.h"

@implementation JWAsync

static dispatch_queue_t queue;

+ (void) initialize {
    queue = dispatch_queue_create("JWAsync", DISPATCH_QUEUE_CONCURRENT);
}

+ (void) forever:(ContinuationBlock)block onError:(ContinuationBlock)exitBlock {
    dispatch_async(queue, ^{
        block(^(NSError *err){
            dispatch_async(queue, ^{
                if(err){
                    exitBlock(err); return;
                }
                [JWAsync forever:block onError:exitBlock];
            });
        });
    });
}

+ (void) whilst:(TruthBlock)truthBlock performAction:(ContinuationBlock)block onCompletion:(ContinuationBlock)exitBlock {
    dispatch_async(queue, ^{
        truthBlock( ^(bool keepGoing){
            dispatch_async(queue, ^{
                if(!keepGoing){
                    exitBlock(nil); return;
                }
                block(^(NSError *err){
                    dispatch_async(queue, ^{
                        if(err){
                            exitBlock(err); return;
                        }
                        [JWAsync whilst:truthBlock performAction:block onCompletion:exitBlock];
                    });
                });
            });
        });
    });
}

+ (void) map:(NSArray *) array transform:(TransformationBlock)map onCompletion:(CallbackBlock)callback {
    NSMutableArray *result = [NSMutableArray new];
    [self each:array onEach:^(id thing, ContinuationBlock next){
        
    } onCompletion:^(NSError *err){
        callback(err, result);
    }];
}

+ (void) reduce:(NSArray *)array startingState:(id)startingState transform:(ReductionBlock)reduceBlock onCompletion:(CallbackBlock)exitBlock {
    __block id currentState = startingState;
    [self each:array onEach:^(id item, ContinuationBlock next){
        reduceBlock(currentState, item, ^(NSError *err, id newState){
            currentState = newState;
            next(err);
        });
    } onCompletion:^(NSError *err){
        exitBlock(err, currentState);
    }];
}

+ (void) series:(NSArray *) blocks onCompletion:(ContinuationBlock)exitBlock {
    [self each:blocks onEach:^(ContinuationBlock block, ContinuationBlock next){
        block(next);
    } onCompletion:exitBlock];
}

+ (void) each:(NSArray *) array onEach:(ItteratorBlock)itterator onCompletion:(ContinuationBlock)exitBlock {
    dispatch_async(queue, ^{
        if(!array || [array count] == 0){
            exitBlock(nil); return;
        }
        NSMutableArray *arr = [array mutableCopy];
        id item = [arr objectAtIndex:0];
        [arr removeObjectAtIndex:0];
        
        itterator(item, ^(NSError *err){
            dispatch_async(queue, ^{
                if(err){
                    exitBlock(err); return;
                }
                [JWAsync each:arr onEach:itterator onCompletion:exitBlock];
            });
        });
    });
}

@end