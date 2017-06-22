//
//  NSObject+DeallocLog.h
//  DragonMenuDemo
//
//  Created by Qitao Yang on 08/06/2017.
//  Copyright © 2017 LightHouseX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (DeallocLog)

@property (nonatomic, assign)BOOL lhx_shouldLogWhenDealloc;

- (NSString *_Nonnull)lhx_memoryAddress;

@end
