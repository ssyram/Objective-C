//
// Created by ssyram on 2018/6/17.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "TextCell.h"


@interface TextCell()
@end

@implementation TextCell {

}

- (IBAction)editDidEnd:(id)sender {
    [_delegate editDidEndAtPath:self.indexPath];
}
- (IBAction)editChanged:(id)sender{
    [_delegate editDidChangedAtPath:self.indexPath];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //布局cell内部控件
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 82, 21)];
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(118, 7, 241, 30)];
        [self.textField addTarget:self action:@selector(editDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self.textField addTarget:self action:@selector(editChanged:) forControlEvents:UIControlEventEditingChanged];
        
        [self.contentView addSubview:self.descriptionLabel];
        [self.contentView addSubview:self.textField];
    }
    return self;
}
@end
