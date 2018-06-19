//
// Created by ssyram on 2018/6/17.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TextCellDelegate <NSObject>

- (void)editDidEndAtPath:(NSIndexPath *)indexPath;
- (void)minusDidPressedAtPath:(NSIndexPath *)indexPath;
- (void)plusButtonDidPressedAtPath:(NSIndexPath *)indexPath;
- (void)imageDidPressed;
- (void)editDidChangedAtPath:(NSIndexPath *)indexPath;

@end
