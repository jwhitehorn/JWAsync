//
//  JWAsync.h
//  AsyncTools
//
//  Created by Jason Whitehorn on 6/6/14.
//  Copyright (c) 2014 Jason Whitehorn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ CallbackBlock)(NSError *, id);
typedef void (^ ContinuationBlock)(NSError *);
typedef void (^ ItteratorBlock)(id, ContinuationBlock);
typedef void (^ ReductionBlock)(id, id, CallbackBlock);
typedef void (^ TransformationBlock)(id, CallbackBlock);
typedef void (^ TruthBlock)(void (^)(bool));
typedef void (^ EmptyBlock)(void);

void UI_THREAD(EmptyBlock block){
    if(![NSThread isMainThread]){
        dispatch_sync(dispatch_get_main_queue(), block);
    }
    block();
}

@interface JWAsync : NSObject

+ (void) forever:(ContinuationBlock)block onError:(ContinuationBlock)exitBlock;
+ (void) whilst:(TruthBlock)truthBlock performAction:(ContinuationBlock)block onCompletion:(ContinuationBlock)exitBlock;
+ (void) map:(NSArray *) array transform:(TransformationBlock)map onCompletion:(CallbackBlock)callback;
+ (void) reduce:(NSArray *)array startingState:(id)startingState transform:(ReductionBlock)reduceBlock onCompletion:(CallbackBlock)exitBlock;
+ (void) series:(NSArray *) blocks onCompletion:(ContinuationBlock)exitBlock;
+ (void) each:(NSArray *) array onEach:(ItteratorBlock)itterator onCompletion:(ContinuationBlock)exitBlock;

@end
