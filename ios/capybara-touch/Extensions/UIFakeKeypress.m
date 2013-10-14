#import "UIFakeKeypress.h"
#import "GraphicsServices.h"
#import <dlfcn.h>
#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

@interface UIKeyboard : UIView

+ (UIKeyboard *)activeKeyboard;
- (id)_typeCharacter:(id)arg1 withError:(CGPoint)arg2 shouldTypeVariants:(BOOL)arg3 baseKeyForVariants:(BOOL)arg4;

@end

@implementation UIFakeKeypress

- (void)sendKeypressForChar:(NSString *)c {
    if (c.length > 1) {
        c = [c substringWithRange:NSMakeRange(0, 1)];
    }

    UIKeyboard *keyboard = [UIKeyboard activeKeyboard];
    if (keyboard) {
        [keyboard _typeCharacter:c withError:CGPointZero shouldTypeVariants:NO baseKeyForVariants:NO];
    }
}
@end
