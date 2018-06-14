//
//  NSArray+RKSafe.m
//
//  Created by 李沛倬 on 2018/6/3.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import "NSArray+RKSafe.h"
#import <objc/runtime.h>

// MARK: - NSObject

@interface NSObject (RKSafe)

@end

@implementation NSObject (RKSafe)

static inline void swizzlingInstanceMethod(Class clazz, SEL originalSelector, SEL exchangeSelector) {
    
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    
    Method swizzledMethod = class_getInstanceMethod(clazz, exchangeSelector);
    
    if (class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(clazz, exchangeSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)printWarningWithMesaage:(NSString *)message {
    if (!onlyRelease) {
#ifdef DEBUG
        NSLog(@"\n");
        NSLog(@"=======!!Warning!!=======");
        NSLog(@"%@", message);
        NSLog(@"=======!!Warning!!=======");
        NSLog(@"\n");
#endif
    }
}

- (NSString *)makeClassName:(Class)cls AndMethod:(SEL)sel {
    NSString *str = [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass(cls), NSStringFromSelector(sel)];
    return str;
}

@end



// MARK: - NSArray

@implementation NSArray (RKSafe)

+ (void)load {
    
    if (onlyRelease) {
#ifdef DEBUG
#else
        [self swizzlingMethod];
#endif
    } else {
        [self swizzlingMethod];
    }
    
}

+ (void)swizzlingMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzlingInstanceMethod(objc_getClass("__NSArray0"), @selector(objectAtIndex:), @selector(rk_emptyArray_objectAtIndex:));
        swizzlingInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:), @selector(rk_arrayI_objectAtIndex:));
        swizzlingInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:), @selector(rk_arrayM_objectAtIndex:));
        swizzlingInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:), @selector(rk_singleObjectArrayI_objectAtIndex:));
        
        swizzlingInstanceMethod(objc_getClass("__NSArray0"), @selector(objectAtIndexedSubscript:), @selector(rk_emptyArray_objectAtIndexedSubscript:));
        swizzlingInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndexedSubscript:), @selector(rk_arrayI_objectAtIndexedSubscript:));
        swizzlingInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndexedSubscript:), @selector(rk_arrayM_objectAtIndexedSubscript:));
        swizzlingInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:), @selector(rk_singleObjectArrayI_objectAtIndexedSubscript:));
        
        swizzlingInstanceMethod(objc_getClass("__NSArrayM"), @selector(insertObject:atIndex:), @selector(rk_arrayM_insertObject:atIndex:));
        swizzlingInstanceMethod(objc_getClass("__NSArrayM"), @selector(setObject:atIndexedSubscript:), @selector(rk_arrayM_setObject:atIndexedSubscript:));
        swizzlingInstanceMethod(objc_getClass("__NSArrayM"), @selector(removeObjectsInRange:), @selector(rk_arrayM_removeObjectsInRange:));
        swizzlingInstanceMethod(objc_getClass("__NSArrayM"), @selector(replaceObjectAtIndex:withObject:), @selector(rk_arrayM_replaceObjectAtIndex:withObject:));
    });
}


// MARK: - Desc
- (NSString *)description {
    return [self localizedDescription];
}

- (NSString *)localizedDescription {
    NSMutableString *str = [NSMutableString stringWithString:@"[\n"];
    for (id obj in self) {
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            [str appendFormat:@"\t%@,\n", [obj localizedDescription]];
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            [str appendFormat:@"\t%@,\n", obj];
        } else {
            [str appendFormat:@"\t\"%@\",\n", obj];
        }
    }
    
    if ([str hasSuffix:@",\n"]) {
        [str replaceCharactersInRange:NSMakeRange(str.length - 2, 2) withString:@"\n"];
    }
    
    [str appendString:@"]"];
    
    return str;
}


// MARK: - Get Safe

- (id)rk_emptyArray_objectAtIndex:(NSUInteger)index {
    [self printBeyondWarningWithIndex:index];
    return nil;
}

- (id)rk_arrayI_objectAtIndex:(NSUInteger)index {
    if(index < self.count){
        return [self rk_arrayI_objectAtIndex:index];
    }
    
    [self printBeyondWarningWithIndex:index];
    return nil;
}

- (id)rk_arrayM_objectAtIndex:(NSUInteger)index {
    if(index < self.count){
        return [self rk_arrayM_objectAtIndex:index];
    }
    
    [self printBeyondWarningWithIndex:index];
    return nil;
}

- (id)rk_singleObjectArrayI_objectAtIndex:(NSUInteger)index {
    if(index < self.count){
        return [self rk_singleObjectArrayI_objectAtIndex:index];
    }
    
    [self printBeyondWarningWithIndex:index];
    return nil;
}


- (id)rk_emptyArray_objectAtIndexedSubscript:(NSUInteger)index {
    [self printBeyondWarningWithIndex:index];
    return nil;
}

- (id)rk_arrayI_objectAtIndexedSubscript:(NSUInteger)index {
    if(index < self.count){
        return [self rk_arrayI_objectAtIndex:index];
    }
    
    [self printBeyondWarningWithIndex:index];
    return nil;
}

- (id)rk_arrayM_objectAtIndexedSubscript:(NSUInteger)index {
    if(index < self.count){
        return [self rk_arrayM_objectAtIndex:index];
    }
    
    [self printBeyondWarningWithIndex:index];
    return nil;
}

- (id)rk_singleObjectArrayI_objectAtIndexedSubscript:(NSUInteger)index {
    if(index < self.count){
        return [self rk_singleObjectArrayI_objectAtIndexedSubscript:index];
    }
    
    [self printBeyondWarningWithIndex:index];
    return nil;
}


// MARK: - Set Safe

- (void)rk_arrayM_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {
        NSString *msg = [NSString stringWithFormat:@"%@: insert object cannot be nil at %lu", [self makeClassName:self.class AndMethod:@selector(insertObject:atIndex:)], (unsigned long)index];
        [self printWarningWithMesaage:msg];
        return;
    }
    
    [self rk_arrayM_insertObject:anObject atIndex:index];
}

- (void)rk_arrayM_setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    if (!obj) {
        NSString *msg = [NSString stringWithFormat:@"%@: set object cannot be nil at %lu", [self makeClassName:self.class AndMethod:@selector(setObject:atIndexedSubscript:)], (unsigned long)idx];
        [self printWarningWithMesaage:msg];
        return;
    }
    
    [self rk_arrayM_setObject:obj atIndexedSubscript:idx];
}


// MARK: - Remove Safe

- (void)rk_arrayM_removeObjectsInRange:(NSRange)range {
    if (range.location > self.count || range.location+range.length > self.count) {
        NSString *msg = [NSString stringWithFormat:@"%@: range %@ extends beyond bounds [0 .. %lu]", [self makeClassName:self.class AndMethod:@selector(removeObjectsInRange:)] , NSStringFromRange(range), (unsigned long)self.count-1];
        [self printWarningWithMesaage:msg];
        return;
    }
    
    [self rk_arrayM_removeObjectsInRange:range];
}


// MARK: - Replace Safe
- (void)rk_arrayM_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (!anObject) {
        NSString *msg = [NSString stringWithFormat:@"%@: replace object cannot be nil at %lu", [self makeClassName:self.class AndMethod:@selector(replaceObjectAtIndex:withObject:)] , (unsigned long)index];
        [self printWarningWithMesaage:msg];
        return;
    }
    
    if (index < self.count) {
        [self rk_arrayM_replaceObjectAtIndex:index withObject:anObject];
        return;
    }
    
    [self printBeyondWarningWithIndex:index];
}




// MARK: - Private Method

- (void)printBeyondWarningWithIndex:(NSUInteger)index {
    NSString *message = @"";
    if (self.count == 0) {
        message = [NSString stringWithFormat:@"index %lu beyond bounds empty array", (unsigned long)index];
    } else {
        message = [NSString stringWithFormat:@"index %lu beyond bounds [0 .. %lu]", (unsigned long)index, (unsigned long)self.count-1];
    }
    [self printWarningWithMesaage:message];
}

@end




// MARK: - NSDictionary

@implementation NSDictionary (RKSafe)

+ (void)load {
    
    if (onlyRelease) {
#ifdef DEBUG
#else
        [self swizzlingMethod];
#endif
    } else {
        [self swizzlingMethod];
    }
}

+ (void)swizzlingMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzlingInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(setObject:forKey:), @selector(rk_dictionaryM_setObject:forKey:));
        swizzlingInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(setObject:forKeyedSubscript:), @selector(rk_dictionaryM_setObject:forKeyedSubscript:));
        swizzlingInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(removeObjectForKey:), @selector(rk_dictionaryM_removeObjectForKey:));
        /**
         __NSDictionary0
         __NSSingleEntryDictionaryI
         */
    });
}

// MARK: - Desc

- (NSString *)description {
    return [self localizedDescription];
}

- (NSString *)localizedDescription {
    NSArray *allKeys = [self allKeys];
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"{\n"];
    for (NSString *key in allKeys) {
        id value = self[key];
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            [str appendFormat:@"\t\"%@\" : %@,\n",key, [value localizedDescription]];
        } else if ([value isKindOfClass:[NSNumber class]]) {
            [str appendFormat:@"\t\"%@\" : %@,\n",key, value];
        } else {
            [str appendFormat:@"\t\"%@\" : \"%@\",\n",key, value];
        }
    }
    
    if ([str hasSuffix:@",\n"]) {
        [str replaceCharactersInRange:NSMakeRange(str.length - 2, 2) withString:@"\n"];
    }
    
    [str appendString:@"}"];
    
    return str;
}



// MARK: - Set Safe

- (void)rk_dictionaryM_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!aKey) {
        NSString *message = [NSString stringWithFormat:@"%@: key cannot be nil", [self makeClassName:self.class AndMethod:@selector(setObject:forKey:)]];
        [self printWarningWithMesaage:message];
        return;
    }
    
    if (!anObject) {
        NSString *message = [NSString stringWithFormat:@"%@: value cannot be nil at key: %@", [self makeClassName:self.class AndMethod:@selector(setObject:forKey:)], aKey];
        [self printWarningWithMesaage:message];
        return;
    }
    
    [self rk_dictionaryM_setObject:anObject forKey:aKey];

}

- (void)rk_dictionaryM_setObject:(id)anObject forKeyedSubscript:(id<NSCopying>)aKey {
    if (!aKey) {
        NSString *message = [NSString stringWithFormat:@"%@: key cannot be nil", [self makeClassName:self.class AndMethod:@selector(setObject:forKeyedSubscript:)]];
        [self printWarningWithMesaage:message];
        return;
    }
    
    if (!anObject) {
        NSString *message = [NSString stringWithFormat:@"%@: value cannot be nil at key: %@", [self makeClassName:self.class AndMethod:@selector(setObject:forKeyedSubscript:)], aKey];
        [self printWarningWithMesaage:message];
        return;
    }
    
    [self rk_dictionaryM_setObject:anObject forKeyedSubscript:aKey];
}


// MARK: - Remove Safe

- (void)rk_dictionaryM_removeObjectForKey:(id)aKey {
    if (!aKey) {
        NSString *message = [NSString stringWithFormat:@"%@: key cannot be nil", [self makeClassName:self.class AndMethod:@selector(removeObject:)]];
        [self printWarningWithMesaage:message];
        return;
    }
    
    [self rk_dictionaryM_removeObjectForKey:aKey];
}





@end






















