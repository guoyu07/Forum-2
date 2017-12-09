//
//  ForumSearchViewController.h
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseTableViewController.h"

@interface ForumSearchViewController : ForumApiBaseTableViewController


@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;


- (IBAction)back:(id)sender;

@end
