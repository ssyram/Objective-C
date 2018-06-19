//
// Created by ssyram on 2018/6/17.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextCellDelegate.h"


@interface TextCellWithMinusButton : UITableViewCell

@property (nonatomic, strong) id<TextCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIButton *minusButton;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
