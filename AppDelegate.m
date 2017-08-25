//
//  AppDelegate.m
//
//  Created by WDY on 15/12/28.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "AppDelegate.h"
#import "ForumLoginViewController.h"

#import "ForumCoreDataManager.h"
#import "ApiTestViewController.h"
#import "NSUserDefaults+Setting.h"
#import <AVOSCloud.h>
#import "UIStoryboard+Forum.h"
#import "HPURLProtocol.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "ForumTabBarController.h"
#import "ForumTableViewController.h"
#import "Forums.h"
#import "LocalForumApi.h"
#import <UserNotifications/UserNotifications.h>

static BOOL API_DEBUG = NO;
static int DB_VERSION = 8;

@interface AppDelegate ()<UNUserNotificationCenterDelegate> {
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:200 * 1024 * 1024 diskCapacity:1024 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:cache];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    [HPURLProtocol registerURLProtocolIfNeed];

    // 这地方要换成你自己的ID，别用我这个，否则签名不对你也无法收到推送
    [AVOSCloud setApplicationId:@"B6mSTRMdobQQaYQmPCGdnlgW-gzGzoHsz" clientKey:@"FpkGpLzxCTCY5cRXEIPBA4aX"];

    application.applicationIconBadgeNumber = 0;

    if (API_DEBUG) {

        NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
        NSLog(@"infoDictionary %@",dic);

        NSString *versionCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSLog(@"versionCode %@",versionCode);
        
        ApiTestViewController *testController = [[ApiTestViewController alloc] init];
        self.window.rootViewController = testController;
        return YES;
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];//Documents目录

    NSLog(@"文件路径: %@", documentsDirectory);

    // 设置默认数值
    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictonary = [NSMutableDictionary dictionary];
    [dictonary setValue:@1 forKey:kSIGNATURE];
    [dictonary setValue:@1 forKey:kTOP_THREAD];
    [setting registerDefaults:dictonary];

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];

    if (localForumApi.currentForumHost){
        if (![localForumApi isHaveLogin:localForumApi.currentForumHost]){
            NSArray<Forums *> * loginForums = localForumApi.loginedSupportForums;
            if(loginForums != nil && loginForums.count >0){
                [localForumApi saveCurrentForumURL:loginForums.firstObject.url];
            }
        }

        BOOL isClearDB = NO;
        if ([localForumApi dbVersion] != DB_VERSION) {

            ForumCoreDataManager *formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];

            // 清空数据库
            [formManager deleteData];

            ForumCoreDataManager *userManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
            [userManager deleteData];

            [localForumApi setDBVersion:DB_VERSION];

            isClearDB = YES;
        }


        // 判断是否登录
        if (![localForumApi isHaveLoginForum] || isClearDB) {

            [self showReloginController:localForumApi];

        }
    } else {
        [self showReloginController:localForumApi];
    }




    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [self registerForRemoteNotification];

    if (launchOptions[@"UIApplicationLaunchOptionsShortcutItemKey"] == nil) {
        NSLog(@"UIApplicationLaunchOptionsShortcutItemKey yes");
        return YES;
    } else {
        NSLog(@"UIApplicationLaunchOptionsShortcutItemKey no");
        return NO;
    }
    
    return YES;
}

- (void)showReloginController:(LocalForumApi *)localForumApi {
    NSString *bundleId = [localForumApi bundleIdentifier];

    if ([bundleId isEqualToString:@"com.andforce.forum"]){
                [localForumApi clearCurrentForumURL];
                self.window.rootViewController = [[UIStoryboard mainStoryboard] finControllerById:@"ShowSupportForums"];
            } else{

                id<ForumConfigDelegate> api = [ForumApiHelper forumConfig:localForumApi.currentForumHost];
                NSString * cId = api.loginControllerId;
                [[UIStoryboard mainStoryboard] changeRootViewControllerTo:cId];

            }
}

/**
 * 初始化UNUserNotificationCenter
 */
- (void)registerForRemoteNotification {
    // iOS10 兼容
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter *uncenter = [UNUserNotificationCenter currentNotificationCenter];
        // 监听回调事件
        [uncenter setDelegate:self];
        //iOS10 使用以下方法注册，才能得到授权
        [uncenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound)
                                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                                    //TODO:授权状态改变
                                    NSLog(@"%@" , granted ? @"授权成功" : @"授权失败");
                                }];
        // 获取当前的通知授权状态, UNNotificationSettings
        [uncenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"%s\nline:%@\n-----\n%@\n\n", __func__, @(__LINE__), settings);
            /*
             UNAuthorizationStatusNotDetermined : 没有做出选择
             UNAuthorizationStatusDenied : 用户未授权
             UNAuthorizationStatusAuthorized ：用户已授权
             */
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                NSLog(@"未选择");
            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                NSLog(@"未授权");
            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                NSLog(@"已授权");
            }
        }];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIUserNotificationType types = UIUserNotificationTypeAlert |
                UIUserNotificationTypeBadge |
                UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];

        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge |
                UIRemoteNotificationTypeAlert |
                UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
#pragma clang diagnostic pop
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    if (/* DISABLES CODE */ (NO)){
        // 首先要想LeanCloud保存installation
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            if (!succeeded) {
                NSLog(@"Error-------> :%@", error);
            }

        }];
    } else {
        // 向系统申请推送服务
        [AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken];
    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {


    if (application.applicationState == UIApplicationStateActive) {
        // 转换成一个本地通知，显示到通知栏，你也可以直接显示出一个 alertView，只是那样稍显 aggressive：）
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [userInfo[@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>   didReceiveRemoteNotification   createLocale");
    } else {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>   didReceiveRemoteNotification  remote");
        [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}


- (NSArray *)flatForm:(Forum *)form {
    NSMutableArray *resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum *childForm in form.childForums) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.andforce.Forum" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"forum" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"forum.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

/** 处理shortcutItem */
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    if ([localForumApi isHaveLoginForum]){
        NSString *shortCutItemType = shortcutItem.type;

        ForumTabBarController * controller = (ForumTabBarController *) self.window.rootViewController;

        controller.selectedIndex = 2;
        ForumTableViewController * forumTableViewController = controller.selectedViewController.childViewControllers.firstObject;
        [forumTableViewController showControllerByShortCutItemType:shortCutItemType];
    }
}

@end
