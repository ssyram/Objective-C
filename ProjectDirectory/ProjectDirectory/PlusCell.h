//
// Created by ssyram on 2018/6/17.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextCellDelegate.h"


@interface PlusCell : UITableViewCell

@property (nonatomic, strong) id<TextCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property NSIndexPath *indexPath;

@end
