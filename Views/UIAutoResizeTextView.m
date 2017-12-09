//
//  UIAutoResizeTextView.m
//
//  Created by 迪远 王 on 16/4/24.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "UIAutoResizeTextView.h"
#import "Forum.pch"

@implementation UIAutoResizeTextView {
    float topY;
}

- (void)didMoveToSuperview {
    topY = self.frame.origin.y + 64 + 10;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWillShow:(id)sender {

    CGRect keyboardFrame;


    [[[((NSNotification *) sender) userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];


    [UIView animateWithDuration:0.3 animations:^{

        CGRect frame = self.frame;

        float keyboardHeight = CGRectGetHeight(keyboardFrame);

        float fieldHeight = SCREEN_HEIGHT - topY - keyboardHeight;

        frame.size.height = fieldHeight;

        self.frame = frame;

    }];

}

- (void)keyboardWillHide:(id)sender {
    CGRect keyboardFrame;

    [[[((NSNotification *) sender) userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];


    [UIView animateWithDuration:0.3 animations:^{

        CGRect frame = self.frame;


        float fieldHeight = SCREEN_HEIGHT - topY;

        frame.size.height = fieldHeight;

        self.frame = frame;

    }];

}
@end
