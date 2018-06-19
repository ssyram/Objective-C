//
// Created by ssyram on 2018/6/17.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextCellDelegate.h"


@interface TextCell : UITableViewCell

@property (nonatomic, strong) id<TextCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property NSIndexPath *indexPath;

@end
