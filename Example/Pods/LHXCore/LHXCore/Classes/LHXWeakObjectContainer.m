//
//  LHXWeakObjectContainer.m
//  Pods
//
//  Created by Zitao Xiong on 6/16/16.
//
//

#import "LHXWeakObjectContainer.h"

@implementation LHXWeakObjectContainer
- (instancetype)initWithTarget:(id)target {
    if (!(self = [super init])) {
        return nil;
    }
    
    _target = target;
    
    return self;
}
@end
