//
//  ForumSeniorNewPostViewController.m
//
//  Created by 迪远 王 on 16/1/16.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSeniorNewPostViewController.h"

#import "SelectPhotoCollectionViewCell.h"
#import <SVProgressHUD.h>
#import "LCActionSheet.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TransBundleDelegate.h"
#import "TransBundle.h"
#import "UIImage+Tint.h"

@interface ForumSeniorNewPostViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,
        UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DeleteDelegate, TransBundleDelegate, UIScrollViewDelegate> {

    UIImagePickerController *pickControl;
    NSMutableArray<UIImage *> *images;
    NSString * userName;
    NSString *securityToken;

    int forumId;
    int threadId;
    NSString * postId;

    ViewThreadPage *replyThread;

    BOOL isQuoteReply;
}

@end

@implementation ForumSeniorNewPostViewController


- (void)transBundle:(TransBundle *)bundle {
    userName = [bundle getStringValue:@"USER_NAME"];
    threadId = [bundle getIntValue:@"THREAD_ID"];
    securityToken = [bundle getStringValue:@"SECYRITY_TOKEN"];
    forumId = [bundle getIntValue:@"FORM_ID"];
    int pid = [bundle getIntValue:@"POST_ID"];
    postId = [NSString stringWithFormat:@"%d", pid];

    replyThread = [bundle getObjectValue:@"QUICK_REPLY_THREAD"];

    isQuoteReply = [bundle getIntValue:@"ISQUOTEREPLY"] == 1;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    _insertCollectionView.delegate = self;
    _insertCollectionView.dataSource = self;
    _scrollView.delegate = self;

    //实例化照片选择控制器
    pickControl = [[UIImagePickerController alloc] init];

    //设置协议
    pickControl.delegate = self;
    //设置编辑
    [pickControl setAllowsEditing:NO];
    //选完图片之后回到的视图界面

    images = [NSMutableArray array];

    [self.replyContent becomeFirstResponder];

    if (userName != nil) {
        self.replyContent.text = [NSString stringWithFormat:@"@%@\n", userName];
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (long long)fileSizeAtPathWithString:(NSString *)filePath {


    NSFileManager *manager = [NSFileManager defaultManager];


    if ([manager fileExistsAtPath:filePath]) {

        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)fileSizeAtPath:(NSURL *)filePath {
    //return [self fileSizeAtPathWithString:filePath.path];
    ALAssetsLibrary *alLibrary = [[ALAssetsLibrary alloc] init];
    __block long long fileSize = (long long int) 0.0;

    [alLibrary assetForURL:filePath resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];

        fileSize = [representation size];


        NSLog(@"图片大小:   %lld", fileSize);

    }         failureBlock:nil];

}


- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *select = [info valueForKey:UIImagePickerControllerOriginalImage];

    NSURL *selectUrl = [info valueForKey:UIImagePickerControllerReferenceURL];

    [self fileSizeAtPath:selectUrl];

    CGSize maxImageSize = CGSizeMake(800, 800);

    [images addObject:[select scaleUIImage:maxImageSize]];

    [_insertCollectionView reloadData];

    //选取完图片之后关闭视图
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return images.count;
}


- (void)deleteCurrentImageForIndexPath:(NSIndexPath *)indexPath {
    [images removeObjectAtIndex:(NSUInteger) indexPath.row];
    [self.insertCollectionView reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *Identifier = @"SelectPhotoCollectionViewCell";

    SelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    cell.deleteImageDelete = self;

    [cell setData:images[(NSUInteger) indexPath.row] forIndexPath:indexPath];

    return cell;

}

- (IBAction)insertSmile:(id)sender {

}

- (IBAction)insertPhoto:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    LCActionSheet *itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"相册", @"拍照"] redButtonIndex:2 clicked:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [pickControl setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

            [self presentViewController:pickControl animated:YES completion:nil];
        } else if (buttonIndex == 1) {
            [pickControl setSourceType:UIImagePickerControllerSourceTypeCamera];

            [self presentViewController:pickControl animated:YES completion:nil];
        }
    }];

    [itemActionSheet show];

}

- (IBAction)back:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendSeniorMessage:(UIBarButtonItem *)sender {
    [self.replyContent resignFirstResponder];

    [SVProgressHUD showWithStatus:@"正在回复" maskType:SVProgressHUDMaskTypeBlack];

    NSMutableArray < NSData * > *uploadImages = [NSMutableArray array];
    for (UIImage *image in images) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [uploadImages addObject:data];
    }

    if (isQuoteReply){
        [self.forumApi quoteReplyPostWithMessage:self.replyContent.text withImages:uploadImages toPostId:postId thread:replyThread handler:^(BOOL isSuccess, id message) {
            if (isSuccess) {
                [SVProgressHUD showSuccessWithStatus:@"回复成功" maskType:SVProgressHUDMaskTypeBlack];

                ViewThreadPage *thread = message;

                TransBundle *bundle = [[TransBundle alloc] init];
                [bundle putObjectValue:thread forKey:@"Senior_Reply_Callback"];

                UITabBarController *presenting = (UITabBarController *) self.presentingViewController;
                UINavigationController *selected = presenting.selectedViewController;
                UIViewController *detail = selected.topViewController;

                [self dismissViewControllerAnimated:YES backToViewController:detail withBundle:bundle completion:^{

                }];

            } else {
                [SVProgressHUD showErrorWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
            }
        }];
    } else {
        [self.forumApi seniorReplyPostWithMessage:self.replyContent.text withImages:uploadImages toPostId:postId thread:replyThread handler:^(BOOL isSuccess, id message) {
            if (isSuccess) {
                [SVProgressHUD showSuccessWithStatus:@"回复成功" maskType:SVProgressHUDMaskTypeBlack];

                ViewThreadPage *thread = message;

                TransBundle *bundle = [[TransBundle alloc] init];
                [bundle putObjectValue:thread forKey:@"Senior_Reply_Callback"];

                UITabBarController *presenting = (UITabBarController *) self.presentingViewController;
                UINavigationController *selected = presenting.selectedViewController;
                UIViewController *detail = selected.topViewController;

                [self dismissViewControllerAnimated:YES backToViewController:detail withBundle:bundle completion:^{

                }];

            } else {
                [SVProgressHUD showErrorWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
            }
        }];
    }
}
@end
