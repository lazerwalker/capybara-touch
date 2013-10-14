//
//  UIFakeKeypress.h
//  capybara-touch
//
//  Created by Michael Walker on 10/14/13.
//  Copyright (c) 2013 Michael Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UIFakeKeypress : NSObject

- (void)sendKeypressForChar:(NSString *)c;

@end
