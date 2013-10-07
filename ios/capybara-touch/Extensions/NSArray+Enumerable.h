@interface NSArray (Enumerable)

- (NSArray *)map:(id (^)(id obj, NSUInteger idx))block;

@end
