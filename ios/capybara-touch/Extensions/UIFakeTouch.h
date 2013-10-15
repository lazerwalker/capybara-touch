#import <UIKit/UIKit.h>

@interface UIFakeTouch: NSObject

@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) CGPoint point;

- (instancetype)initInView:(UIView *)view point:(CGPoint)point;
- (void)sendTap;

@end


