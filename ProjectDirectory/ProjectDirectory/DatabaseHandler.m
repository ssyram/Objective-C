//
// Created by ssyram on 2018/6/12.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "DatabaseHandler.h"
#import <sqlite3.h>

NSMutableArray<DatabaseFile *> *directoryData;
DatabaseFile *toPass;
NSUInteger nextPID;
BOOL finishInit = false;

typedef enum : NSUInteger {
    PeopleInfo,
    EmailList,
    PhoneNumList,
} tableType;
NSString *translateTableTypeIntoString(tableType t){
    switch (t) {
        case PeopleInfo:
            return @"PeopleInfo";
        case EmailList:
            return @"EmailList";
        case PhoneNumList:
            return @"PhoneNumList";
        default:
            return nil;
    }
}

@implementation DatabaseHandler
{
    sqlite3 *db;
    sqlite3_stmt *stmt;
}
+ (NSUInteger)assignNextPID{
    if (!finishInit)
        @throw [NSException exceptionWithName:@"must first finish init" reason:nil userInfo:nil];
    return nextPID++;
}
#define CONNECT_SUCCEED YES
+ (NSString *)databasePath
{
    NSString *dp = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [dp stringByAppendingPathComponent:@"sqliteDatabase.sqlite"];
}
- (BOOL)closeDatabase{
    if (sqlite3_close(db) == SQLITE_OK)
        return YES;
    @throw [NSException exceptionWithName:@"can't close database" reason:@"can't close database" userInfo:nil];
}
- (void)executeWithSentence:(NSString *)s{
    char *err;
    if (sqlite3_exec(db, s.UTF8String, NULL, NULL, &err) != SQLITE_OK){
        @throw [NSException exceptionWithName:[NSString stringWithFormat:@"execute %@ error", s] reason:[NSString stringWithFormat:@"error: %s", err] userInfo:nil];
    }
}
- (NSString *)searchWithTable:(tableType) t{
    return nil;
}
- (void)connectToDatabase
{
    if(sqlite3_open([DatabaseHandler databasePath].UTF8String, &db) == SQLITE_OK){
        NSLog(@"connect succeed!");
        return;
    }
    NSLog(@"connnect failed");
    @throw [NSException exceptionWithName:@"connect to database failed" reason:nil userInfo:nil];
}



- (BOOL)innerInitTables{
    [self connectToDatabase];
    
    
    NSString *tableFormat = @"CREATE TABLE IF NOT EXISTS %@ (%@);";
    NSString *refernceToPeopleInfo = @"FOREIGN KEY(pid) REFERENCES PeopleInfo(pid)";
    NSString *peopleInfoColumns = @"pid int64 primary key, name TEXT NOT NULL, birthday TEXT, remarks TEXT";
    NSString *createPeopleInfo = [NSString stringWithFormat:tableFormat, translateTableTypeIntoString(PeopleInfo), peopleInfoColumns];
    NSString *createEmailList = [NSString stringWithFormat:tableFormat, translateTableTypeIntoString(EmailList), [NSString stringWithFormat:@"pid INT64, email TEXT, PRIMARY KEY(pid, email), %@", refernceToPeopleInfo]];
    NSString *createPhoneNumberList = [NSString stringWithFormat:tableFormat, translateTableTypeIntoString(PhoneNumList), [NSString stringWithFormat:@"pid INT64, phoneNum TEXT, PRIMARY KEY(pid, phoneNum), %@", refernceToPeopleInfo]];
    char *err;
    
    if (sqlite3_exec(db, createPeopleInfo.UTF8String, NULL, NULL, &err) != SQLITE_OK){
        @throw [NSException exceptionWithName:@"add peopleInfo failed" reason:[NSString stringWithFormat:@"err: %s", err] userInfo:nil];
        return NO;
    }
    NSLog(@"add peopleInfo succeed!");
    if (sqlite3_exec(db, createEmailList.UTF8String, NULL, NULL, &err) != SQLITE_OK){
        @throw [NSException exceptionWithName:@"add emailList failed" reason:[NSString stringWithFormat:@"err: %s", err] userInfo:nil];
        return NO;
    }
    NSLog(@"add emailList succeed!");
    if (sqlite3_exec(db, createPhoneNumberList.UTF8String, NULL, NULL, &err) != SQLITE_OK){
        @throw [NSException exceptionWithName:@"add phoneNumberList failed" reason:[NSString stringWithFormat:@"err: %s", err] userInfo:nil];
        return NO;
    }
    NSLog(@"add phoneNumberList succeed!");
    
    NSLog(@"init tables succeed!");
    [self closeDatabase];
    return YES;
}
+ (BOOL)tryInitTables{
    return [[DatabaseHandler new] innerInitTables];
}


- (NSMutableArray<DatabaseFile *> *)innerGetInitData{
    [self connectToDatabase];
    
    NSMutableArray<DatabaseFile *> *r = [NSMutableArray new];
    NSString *sentence = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY pid ASC;", translateTableTypeIntoString(PeopleInfo)];
    
//    dispatch_queue_t emq = dispatch_queue_create("email list mission queue", NULL);
//    void(^emqAppendForFile)(DatabaseFile *f) = ^(DatabaseFile *f){
//
//    };
//    dispatch_queue_t pnq = dispatch_queue_create("phone number list mission queue", NULL);
    void (^SQLPrepare)(NSString *sentence, sqlite3_stmt **st) = ^(NSString *sentence, sqlite3_stmt **st){
        if (sqlite3_prepare(self->db, sentence.UTF8String, -1, st, NULL) != SQLITE_OK){
            NSLog(@"error info: %s", sqlite3_errmsg(db));
            @throw [NSException exceptionWithName:@"select error" reason:[NSString stringWithFormat:@"error occurs when executing: %@", sentence] userInfo:nil];
        }
    };
    
    SQLPrepare(sentence, &stmt);
    
    NSString *(^selectForTableWithPID)(tableType t, NSUInteger pid) = ^NSString *(tableType t, NSUInteger pid){
        if (t == PhoneNumList)
            return [NSString stringWithFormat:@"SELECT phoneNum FROM %@ WHERE pid = \'%lu\'", translateTableTypeIntoString(PhoneNumList), (unsigned long)pid];
        else if (t == EmailList)
            return [NSString stringWithFormat:@"SELECT email FROM %@ WHERE pid = \'%lu\'", translateTableTypeIntoString(EmailList), (unsigned long)pid];
        @throw [NSException exceptionWithName:@"Inner Exception: call for not a supported table type to generate SELECT sentence" reason:nil userInfo:nil];
    };
    
    //create file and add to tdata
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        DatabaseFile *f = [DatabaseFile new];
        f.pid = sqlite3_column_int64(stmt, 0);
        f.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
        char *bd = (char *)sqlite3_column_text(stmt, 2);
        if (bd)
            f.birthday = [NSString stringWithUTF8String:bd];
        char *rmks = (char *)sqlite3_column_text(stmt, 3);
        if (rmks)
            f.remarks = [NSString stringWithUTF8String:rmks];
        
        
        
        sqlite3_stmt *plstmt;
        sqlite3_stmt *elstmt;
        SQLPrepare(selectForTableWithPID(PhoneNumList, f.pid), &plstmt);
        SQLPrepare(selectForTableWithPID(EmailList, f.pid), &elstmt);
        
        while (sqlite3_step(plstmt) == SQLITE_ROW)
            [f.phoneNumberList addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(plstmt, 0)]];
        
        while (sqlite3_step(elstmt) == SQLITE_ROW)
            [f.emailList addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(elstmt, 0)]];
        
        if (sqlite3_finalize(plstmt) != SQLITE_OK)
            @throw [NSException exceptionWithName:@"can't close phone number list stmt" reason:nil userInfo:nil];
        
        if (sqlite3_finalize(elstmt) != SQLITE_OK)
            @throw [NSException exceptionWithName:@"can't close email list stmt" reason:nil userInfo:nil];
        
        [r addObject:f];
    }
    
    if (sqlite3_finalize(stmt) != SQLITE_OK)
        @throw [NSException exceptionWithName:@"can't close stmt" reason:nil userInfo:nil];
    
    NSLog(@"prepare init database files succeed!");
    [self closeDatabase];
    return r;
}
+ (NSMutableArray<DatabaseFile *> *)getInitData{
    DatabaseHandler *dh = [DatabaseHandler new];
    NSMutableArray<DatabaseFile *> *r = [dh innerGetInitData];
    finishInit = true;
    if (r.count)
        nextPID = r.lastObject.pid + 1;
    else
        nextPID = 0;
    return r;
}



- (BOOL)innerInsertWithDatabaseFile:(DatabaseFile *)f{
    [self connectToDatabase];
    
    NSMutableString *pifSentence = [NSMutableString stringWithFormat:@"INSERT INTO %@ VALUES(\'%lu\', \'%@\'", translateTableTypeIntoString(PeopleInfo), (unsigned long)f.pid, f.name];
    if (f.birthday)
        [pifSentence appendFormat:@", \'%@\'", f.birthday];
    else
        [pifSentence appendFormat:@", null"];
    if (f.remarks)
        [pifSentence appendFormat:@", \'%@\'", f.remarks];
    else
        [pifSentence appendFormat:@", null"];
    [pifSentence appendFormat:@");"];
    [self executeWithSentence:pifSentence];
    
    for (NSUInteger i = 0; i < f.phoneNumberList.count; ++i)
        [self executeWithSentence:[self insertGenerate:PhoneNumList forPID:f.pid andTargetString:[f.phoneNumberList objectAtIndex:i]]];
    
    for (NSUInteger i = 0; i < f.emailList.count; ++i)
        [self executeWithSentence:[self insertGenerate:EmailList forPID:f.pid andTargetString:[f.emailList objectAtIndex:i]]];
    
    [self closeDatabase];
    return YES;
}
+ (BOOL)insertWithDatabaseFile:(DatabaseFile *)f{
    if (directoryData.lastObject.pid < f.pid || !directoryData.count)
        [directoryData addObject:f];
    else
        for (NSUInteger i = 0; i < directoryData.count; ++i)
            if ([directoryData objectAtIndex:i].pid > f.pid){
                [directoryData insertObject:f atIndex:i];
                break;
            }
    return [[DatabaseHandler new] innerInsertWithDatabaseFile:f];
}





- (BOOL)innerDeleteWithPID:(NSUInteger)pid{
    [self connectToDatabase];
    
    [self totalDeleteWithTable:PhoneNumList PID:pid];
    [self totalDeleteWithTable:EmailList PID:pid];
    [self executeWithSentence:[self gnerateDeleteForTable:PeopleInfo withPID:pid]];
    
    [self closeDatabase];
    return YES;
}
+ (BOOL)deleteWithPID:(NSUInteger)pid{
    [directoryData removeObject:[DatabaseHandler findFileWithPID:pid]];
    return [[DatabaseHandler new] innerDeleteWithPID:pid];
}
+ (BOOL)deleteWithIndex:(NSUInteger)index
{
    NSUInteger pid = [directoryData objectAtIndex:index].pid;
    [directoryData removeObjectAtIndex:index];
    return [[DatabaseHandler new] innerDeleteWithPID:pid];
}



- (void)updateColumn:(NSString *)columnName withNewValue:(NSString *)v andPID:(NSUInteger)pid{
    NSString *pifSentence = [NSString stringWithFormat:@"UPDATE %@ SET %@ = \'%@\' WHERE pid = \'%lu\'", translateTableTypeIntoString(PeopleInfo), columnName, v, (unsigned long)pid];
    [self executeWithSentence:pifSentence];
}

- (BOOL)innerUpdatePeopleInfoWithPID:(NSUInteger)pid byNewFile:(DatabaseFile *)f withBitmap:(int)map{
    [self connectToDatabase];
    
    if (map&PIF_NAME_CHANGED)
        [self updateColumn:@"name" withNewValue:f.name andPID:f.pid];
    if (map&PIF_BIRTHDATY_CHANGED)
        [self updateColumn:@"birthday" withNewValue:f.birthday andPID:f.pid];
    if (map&PIF_REMARKS_CHANGED)
        [self updateColumn:@"remarks" withNewValue:f.remarks andPID:f.pid];
    
    [self closeDatabase];
    return YES;
}
+ (BOOL)updatePeopleInfoWithPID:(NSUInteger)pid byNewFile:(DatabaseFile *)f withBitmap:(int)map{
    return [[DatabaseHandler new] innerUpdatePeopleInfoWithPID:pid byNewFile:f withBitmap:(int)map];
}

- (NSString *)insertGenerate:(tableType)t forPID:(NSUInteger)pid andTargetString:(NSString *)s{
    return [NSString stringWithFormat:@"INSERT INTO %@ VALUES(\'%lu\', \'%@\')", translateTableTypeIntoString(t), (unsigned long)pid, s];
}

- (BOOL)innerInsertEmail:(NSString *)email forPID:(NSUInteger)pid{
    [self connectToDatabase];
    
    [self executeWithSentence:[self insertGenerate:EmailList forPID:pid andTargetString:email]];
    
    return YES;
}
+ (BOOL)insertEmail:(NSString *)email forPID:(NSUInteger)pid{
    [[DatabaseHandler findFileWithPID:pid].emailList addObject:email];
    return [[DatabaseHandler new] innerInsertEmail:email forPID:pid];
}



- (BOOL)innerInsertPhoneNum:(NSString *)phoneNum forPID:(NSUInteger)pid{
    [self connectToDatabase];
    
    [self executeWithSentence:[self insertGenerate:PhoneNumList forPID:pid andTargetString:phoneNum]];
    
    return YES;
}
+ (BOOL)insertPhoneNum:(NSString *)phoneNum forPID:(NSUInteger)pid{
    [[DatabaseHandler findFileWithPID:pid].phoneNumberList addObject:phoneNum];
    return [[DatabaseHandler new] innerInsertPhoneNum:phoneNum forPID:pid];
}


- (NSString *)gnerateDeleteForTable:(tableType)t withPID:(NSUInteger)pid{
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE pid = \'%lu\'", translateTableTypeIntoString(t), (unsigned long)pid];
}
- (NSString *)gnerateDeleteForTable:(tableType)t withPID:(NSUInteger)pid andTargetColumnName:(NSString *)columnName andTargetString:(NSString *)targetString{
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE pid = \'%lu\' AND %@ = \'%@\'", translateTableTypeIntoString(t), (unsigned long)pid, columnName, targetString];
}
- (void)innerDeleteEmail:(NSString *)email ForPID:(NSUInteger)pid{
    [self connectToDatabase];
    
    [self executeWithSentence:[self gnerateDeleteForTable:EmailList withPID:pid andTargetColumnName:@"email" andTargetString:email]];
}
+ (void)deleteEmail:(NSString *)email ForPID:(NSUInteger)pid{
    DatabaseFile *f = [DatabaseHandler findFileWithPID:pid];
    [f.emailList removeObject:email];
    [[DatabaseHandler new] innerDeleteEmail:email ForPID:pid];
}
- (void)innerDeletePhoneNum:(NSString *)pn ForPID:(NSUInteger)pid{
    [self connectToDatabase];
    
    [self executeWithSentence:[self gnerateDeleteForTable:PhoneNumList withPID:pid andTargetColumnName:@"phoneNum" andTargetString:pn]];
}
+ (void)deletePhoneNum:(NSString *)pn ForPID:(NSUInteger)pid{
    DatabaseFile *f = [DatabaseHandler findFileWithPID:pid];
    [f.phoneNumberList removeObject:pn];
    [[DatabaseHandler new] innerDeletePhoneNum:pn ForPID:pid];
}
+ (DatabaseFile *)findFileWithPID:(NSUInteger)pid{
    for (NSUInteger i = 0; i < directoryData.count; ++i)
        if ([directoryData objectAtIndex:i].pid == pid)
            return [directoryData objectAtIndex:i];
    return nil;
}


- (void)totalDeleteWithTable:(tableType)t PID:(NSUInteger)pid{
    [self executeWithSentence:[NSString stringWithFormat:@"DELETE FROM %@ WHERE pid = \'%lu\'", translateTableTypeIntoString(t), (unsigned long)pid]];
}

- (void)innerJustDeleteEmailForPID:(NSUInteger)pid{
    [self connectToDatabase];
    
    [self totalDeleteWithTable:EmailList PID:pid];
    
    [self closeDatabase];
}
+ (void)justDeleteEmailForPID:(NSUInteger)pid{
    [[DatabaseHandler new] innerJustDeleteEmailForPID:pid];
}
- (void)innerJustDeletePhoneNumForPID:(NSUInteger)pid{
    [self connectToDatabase];
    
    [self totalDeleteWithTable:PhoneNumList PID:pid];
    
    [self closeDatabase];
}
+ (void)justDeletePhoneNumForPID:(NSUInteger)pid{
    [[DatabaseHandler new] innerJustDeletePhoneNumForPID:pid];
}
@end
