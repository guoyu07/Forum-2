//
//  AutoRelayoutUITextView.h
//
//  Created by WDY on 16/1/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMiniHeight 30
#define kMaxHeight  180

@protocol AutoRelayoutUITextViewDelegate <NSObject>

@required
- (void)heightChanged:(CGFloat)height;

@end


@interface AutoRelayoutUITextView : UITextView

@property(nonatomic, strong) id <AutoRelayoutUITextViewDelegate> heightDelegate;


- (void)showPlaceHolder:(BOOL)show;

@end
