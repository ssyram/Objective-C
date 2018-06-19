//
// Created by ssyram on 2018/6/12.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseFile.h"


@interface DetailDirectoryViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property DatabaseFile *f;

@end
