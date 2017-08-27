//
//  ForumWebViewController.h
//
//  Created by 迪远 王 on 16/5/26.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseViewController.h"



@interface ForumWebViewController : ForumApiBaseViewController
@property(weak, nonatomic) IBOutlet UIWebView *webView;

@property(nonatomic, strong) UIImageView *animatedFromView;


- (IBAction)back:(UIBarButtonItem *)sender;

- (IBAction)showMoreAction:(UIBarButtonItem *)sender;

- (IBAction)changeNumber:(id)sender;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *pageNumber;

- (IBAction)reply:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *changePageButton;
@property (weak, nonatomic) IBOutlet UILabel *pageTitleTextView;
- (IBAction)firstPage:(id)sender;
- (IBAction)previousPage:(id)sender;
- (IBAction)lastPage:(id)sender;
- (IBAction)nextPage:(id)sender;

@end
