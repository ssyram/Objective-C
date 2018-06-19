//
// Created by ssyram on 2018/6/17.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "PlusCell.h"


@interface PlusCell()
@end

@implementation PlusCell {

}

- (IBAction)plusDidPressed:(id)sender {
    [_delegate plusButtonDidPressedAtPath:_indexPath];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //布局cell内部控件
        self.plusButton = [[UIButton alloc] initWithFrame:CGRectMake(167, 1, 41, 41)];
        [self.plusButton addTarget:self action:@selector(plusDidPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.plusButton setBackgroundImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
        
        [self.contentView addSubview:self.plusButton];
    }
    return self;
}

@end
