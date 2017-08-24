//
//  ForumCreateNewThreadViewController.m
//
//  Created by 迪远 王 on 16/1/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumCreateNewThreadViewController.h"
#import "ForumApiHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <SVProgressHUD.h>
#import "LCActionSheet.h"
#import "ActionSheetStringPicker.h"
#import "AFNetworking.h"
#import "TransBundle.h"
#import "TransBundleDelegate.h"
#import "UIImage+Tint.h"
#import "LocalForumApi.h"

@interface ForumCreateNewThreadViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
        UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
        DeleteDelegate, TransBundleDelegate, UIScrollViewDelegate> {


    id<ForumBrowserDelegate> _forumApi;
    int forumId;
    UIImagePickerController *pickControl;
    NSMutableArray<UIImage *> *images;

    ViewForumPage *currentForumPage;

    NSArray *categorys;

    int categoryIndex;
}

@end

@implementation ForumCreateNewThreadViewController

- (void)transBundle:(TransBundle *)bundle {
    forumId = [bundle getIntValue:@"FORM_ID"];
    currentForumPage = [bundle getObjectValue:@"CREATE_THREAD_IN"];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    categoryIndex = 0;

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    _forumApi = [ForumApiHelper forumApi:localForumApi.currentForumHost];

    _selectPhotos.delegate = self;
    _selectPhotos.dataSource = self;
    _scrollView.delegate = self;

    //实例化照片选择控制器
    pickControl = [[UIImagePickerController alloc] init];
    //设置照片源
    [pickControl setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    //设置协议
    pickControl.delegate = self;
    //设置编辑
    [pickControl setAllowsEditing:NO];
    //选完图片之后回到的视图界面

    images = [NSMutableArray array];

    [SVProgressHUD showWithStatus:@"获取分类" maskType:SVProgressHUDMaskTypeBlack];
    NSString *fId = [NSString stringWithFormat:@"%d", forumId];
    [_forumApi listThreadCategory:fId handler:^(BOOL isSuccess, id message) {
        if (isSuccess){
            [SVProgressHUD dismiss];
            categorys = message;
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
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

    } failureBlock:nil];

}


+ (NSString *)mimeTypeForFileAtPath:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef) CFBridgingRetain([path pathExtension]), NULL);


    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }

    return nil;
//    return [NSMakeCollectable((NSString *)CFBridgingRelease(mimeType)) ];
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

    UIImage *scaleImage = [select scaleUIImage:CGSizeMake(800, 800)];

    [images addObject:scaleImage];

    [_selectPhotos reloadData];

    //选取完图片之后关闭视图
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *QuoteCellIdentifier = @"SelectPhotoCollectionViewCell";

    SelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QuoteCellIdentifier forIndexPath:indexPath];
    cell.deleteImageDelete = self;
    [cell setData:images[(NSUInteger) indexPath.row] forIndexPath:indexPath];
    return cell;

}

- (void)deleteCurrentImageForIndexPath:(NSIndexPath *)indexPath {
    [images removeObjectAtIndex:(NSUInteger) indexPath.row];
    [self.selectPhotos reloadData];
}


- (IBAction)createThread:(id)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    NSString *title = self.subject.text;
    NSString *message = self.message.text;

    NSString *category = self.category.titleLabel.text;

    if ([category isEqualToString:@"[请选分类]"]){
        [SVProgressHUD showErrorWithStatus:@"请选择分类" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }

    if (title.length < 1) {
        [SVProgressHUD showErrorWithStatus:@"标题太短" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在发送" maskType:SVProgressHUDMaskTypeBlack];

    NSMutableArray<NSData *> *uploadData = [NSMutableArray array];
    for (UIImage *image in images) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [uploadData addObject:data];
    }

    NSString *threadTitle = [category stringByAppendingString:title];

    [_forumApi createNewThreadWithCategory:category categoryIndex:categoryIndex + 1 withTitle:title andMessage:message withImages:[uploadData copy] inPage:currentForumPage handler:^(BOOL isSuccess, id message) {
        [self dismissViewControllerAnimated:YES completion:^{

        }];

        if (isSuccess) {
            [SVProgressHUD showSuccessWithStatus:@"发帖成功" maskType:SVProgressHUDMaskTypeBlack];
        } else {
            [SVProgressHUD showErrorWithStatus:@"发帖失败" maskType:SVProgressHUDMaskTypeBlack];
        }
    }];
}

- (IBAction)back:(id)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)pickPhoto:(id)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    LCActionSheet *itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"相册", @"拍照", @"取消"] redButtonIndex:2 clicked:^(NSInteger buttonIndex) {
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

- (IBAction)showCategory:(UIButton *)sender {

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择分类"
                                                                                rows:categorys
                                                                    initialSelection:categoryIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

                self.category.titleLabel.text = categorys[(NSUInteger) selectedIndex];
                categoryIndex = selectedIndex;


    }  cancelBlock:^(ActionSheetStringPicker *picker) {

    }  origin:sender];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] init];
    cancelItem.title = @"取消";
    [picker setCancelButton:cancelItem];

    UIBarButtonItem *queding = [[UIBarButtonItem alloc] init];
    queding.title = @"确定";
    [picker setDoneButton:queding];


    [picker showActionSheetPicker];
}
@end
