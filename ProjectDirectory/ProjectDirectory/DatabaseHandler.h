//
// Created by ssyram on 2018/6/12.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseFile.h"

extern NSMutableArray<DatabaseFile *> *directoryData;
extern DatabaseFile *toPass;

#define PIF_NAME_CHANGED 1
#define PIF_BIRTHDATY_CHANGED 2
#define PIF_REMARKS_CHANGED 4

@interface DatabaseHandler : NSObject

+ (NSString *)databasePath;
+ (BOOL)tryInitTables;
+ (NSUInteger)assignNextPID;
+ (NSMutableArray<DatabaseFile *> *)getInitData;
+ (BOOL)insertWithDatabaseFile:(DatabaseFile *)f;
+ (BOOL)deleteWithPID:(NSUInteger)pid;
+ (BOOL)deleteWithIndex:(NSUInteger)index;
+ (BOOL)updatePeopleInfoWithPID:(NSUInteger)pid byNewFile:(DatabaseFile *)f withBitmap:(int)map;
+ (BOOL)insertEmail:(NSString *)email forPID:(NSUInteger)pid;
+ (BOOL)insertPhoneNum:(NSString *)phoneNum forPID:(NSUInteger)pid;
//+ (void)deleteEmail:(NSString *)email ForPID:(NSUInteger)pid;
//+ (void)deletePhoneNum:(NSString *)phoneNum ForPID:(NSUInteger)pid;
+ (void)justDeleteEmailForPID:(NSUInteger)pid;
+ (void)justDeletePhoneNumForPID:(NSUInteger)pid;
+ (DatabaseFile *)findFileWithPID:(NSUInteger)pid;
//+ (void)rearangePIDWithArray:(NSMutableArray<DatabaseFile *> *)a;
//+ (DatabaseFile *)searchForAFileWithPhoneNumber:(NSString *)phoneNum;

@end
