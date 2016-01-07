//
//  HJDatabase.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/2.
//
//

#import "HJDatabase.h"
#import "SqliteUtils.h"

@implementation HJDatabase

#pragma mark databaseShareInstance
+ (HJDatabase *)shareInstance {
    static HJDatabase *hjdb = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        hjdb = [[HJDatabase alloc] init];
    });
    return hjdb;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *databasePath = [self databaseFilePath:@"CalendarApp.db"];
        self.DB = [FMDatabase databaseWithPath:databasePath];
        NSLog(@"self.databasePath :%@",databasePath);
        self.dbQueue = [[FMDatabaseQueue alloc] initWithPath:databasePath];//在多个线程来执行查询和更新时会使用这个对象，防止数据的错乱
        self.threadLock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

#pragma mark databaseFilePath
- (NSString *)databaseFilePath:(NSString *)fileName {
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[documentsPath objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return path;
}

#pragma mark operateDatabase
- (void)executeDB:(void (^)(FMDatabase *db))block {
    [self.threadLock lock];
    if(self.DB != nil)
    {
        if (![self.DB open]) {
            [self.DB open];
        }
        block(self.DB);
    }
    else
    {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            self.DB = db;
            if (![self.DB open]) {
                [self.DB open];
            }
            block(self.DB);
            [self.DB close];
            self.DB = nil;
        }];
    }
    [self.threadLock unlock];
}

#pragma mark tableIsExist
- (BOOL)isTableExist:(NSString *)tableName
{
    FMResultSet *rs = [self.DB executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark createTableSQL
- (NSString *)createTableSQL:(NSString *)tableName class:(Class)class {
    NSMutableDictionary *dict = [self propertysWithClass:class];
    NSArray *propertyNameAry = dict.allKeys;
    NSArray *propertyTypeAry = dict.allValues;
    NSString * createTableSql=[[NSString alloc] initWithString:[NSString stringWithFormat:@"CREATE TABLE if not exists %@ (serial integer  Primary Key Autoincrement ",tableName]];
    for (NSInteger i = 0; i < [propertyNameAry count]; i++) {
        NSString *propertyName = [propertyNameAry objectAtIndex:i];
        NSString *propertyType = [propertyTypeAry objectAtIndex:i];
        if ([propertyName isEqualToString:@"serial"]) {
            continue;
        }
        NSString * suffix = [propertyType substringToIndex:2];
        NSString *tempStr;
        if ([suffix isEqualToString:@"T@"] || [suffix isEqualToString:@"TB"] || [suffix isEqualToString:@"Tc"]) {
            tempStr=[NSString stringWithFormat:@",%@ varchar(1024)",propertyName];
        } else if ([suffix isEqualToString:@"Tq"] || [suffix isEqualToString:@"Ti"]) {
            tempStr=[NSString stringWithFormat:@",%@ integer",propertyName];
        }
        createTableSql = [createTableSql stringByAppendingString:tempStr];
    }
    createTableSql = [createTableSql stringByAppendingString:@")"];
    return createTableSql;
}

#pragma mark createInsertSQL
-(NSString*)createInsertSQL:(id)model tableName:(NSString*)tableName {
    NSDictionary * dict = [self modelToDictionary:model];
    NSString * sql;
    NSString * colStr = @"";
    NSString * valStr = @"";
    for(NSString * key in dict.allKeys){
        id value = [dict objectForKey:key];
        colStr = [colStr stringByAppendingString:[NSString stringWithFormat:@",%@",key]];
        valStr = [valStr stringByAppendingString:[NSString stringWithFormat:@",'%@'",value]];
    }
    if(colStr.length > 0){
        colStr = [colStr substringFromIndex:1];
    }
    if(valStr.length > 0) {
        valStr = [valStr substringFromIndex:1];
    }
    
    sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)",tableName,colStr,valStr];
    return sql;
}

#pragma mark createUpdateSQL
-(NSString*)createUpdateSQL:(id)model tableName:(NSString*)tableName primarykeyName:(NSString *)primarykeyName {
    NSDictionary *dict = [self modelToDictionary:model];
    NSString *sql = [NSString stringWithFormat:@"update %@ ",tableName];
    NSArray *array = dict.allKeys;
    for (int i = 0; i < array.count; i++) {
        NSString *key = array[i];
        id value = [dict objectForKey:key];
        if (i == dict.count - 1) {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@' ",key,value]];
        } else {
            if (i == 0) {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:@"set %@ = '%@',",key,value]];
            } else {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@',",key,value]];
            }
        }
    }
    NSString *where = [NSString stringWithFormat:@" where %@ = '%@'",primarykeyName,[model valueForKey:primarykeyName]];
    sql = [sql stringByAppendingString:where];
    return sql;
}

#pragma mark getExistColumns
- (NSMutableArray*)getExistColumns:(sqlite3*)sqlite tableName:(NSString*)tableName{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName];
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK ) 	{
        NSLog(@"Error: failed to prepare statement.");
        return nil;
    }
    while (sqlite3_step(statement) == SQLITE_ROW) {
        char * c_column = (char *)sqlite3_column_text(statement, 1);
        BOOL isPrimaryKey = sqlite3_column_int(statement, 5);
        if(!isPrimaryKey){
            NSString *columnName = [NSString stringWithUTF8String:c_column];
            [array addObject:columnName];
        }
    }
    return array;
}

#pragma mark getUnExistColumns
- (NSMutableDictionary *)getUnExistColumns:(sqlite3*)sqlite tableName:(NSString*)tableName model:(id)model {
    NSMutableDictionary *columnsDict = [NSMutableDictionary dictionary];
    NSArray *existColumnArray = [self getExistColumns:sqlite tableName:tableName];
    NSMutableDictionary *dict = [self propertysWithClass:[model class]];
    NSArray *columnArray = dict.allKeys;
    if(existColumnArray.count == columnArray.count){
        return nil;
    }
    for(NSString *columnName in columnArray){
        if(![existColumnArray containsObject:columnName]){
            [columnsDict setObject:[dict objectForKey:columnName] forKey:columnName];
        }
    }
    return columnsDict;
}

#pragma mark addColumnsToTable
- (void)addColumn:(sqlite3*)sqlite tableName:(NSString*)tableName columnDict:(NSMutableDictionary *)columnDict {
    NSArray *propertyNameAry = columnDict.allKeys;
    NSArray *propertyTypeAry = columnDict.allValues;
    for (NSInteger i = 0; i < propertyNameAry.count; i++) {
        NSString *propertyName = [propertyNameAry objectAtIndex:i];
        NSString *propertyType = [propertyTypeAry objectAtIndex:i];
        NSString *suffix = [propertyType substringToIndex:2];
        NSString * sql;
        if ([suffix isEqualToString:@"T@"]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ varchar(1024)",tableName,propertyName];
        } else if ([suffix isEqualToString:@"Tq"]) {
            sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ integer",tableName,propertyName];
        }
        if(![SqliteUtils executeSql:sqlite Sql:sql]){
            NSLog(@"  alter table  Sql: %@  ",sql);
        }
    }
}

#pragma mark modify table
- (void)modifyTable:(sqlite3*)sqlite tableName:(NSString*)tableName model:(id)model {
    NSMutableDictionary *dict = [self getUnExistColumns:sqlite tableName:tableName model:model];
    [self addColumn:sqlite tableName:tableName columnDict:dict];
}

#pragma mark queryTableLineNumber
- (NSInteger)count:(NSString *)tableName {
    NSString *sql = [NSString stringWithFormat:@"select count(*) from table%@",tableName];
    __block NSInteger count = 0;
    [self executeDB:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            NSLog(@"返回表中数据的总条数==%d",[result intForColumnIndex:0]);
            count = [result intForColumnIndex:0];
        }
    }];
    return count;
}

#pragma mark deleteDataBase
- (void)deleteDB {
    NSString *dataBasePath = [self databaseFilePath:@"CalendarApp.db"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dataBasePath]) {
        [fm removeItemAtPath:dataBasePath error:nil];
        self.DB = nil;
        NSLog(@"删除数据库成功");
    }else {
        NSLog(@"删除数据库失败");
    }
}

- (void)deleteTableDatasource:(NSString *)tableName {
    [self executeDB:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@",tableName];
        BOOL succees = [db executeUpdate:sql];
        if (!succees) {
            NSLog(@"删除表数据失败");
        }
    }];
}

#pragma mark getClassPropertys
- (NSMutableDictionary *)propertysWithClass:(Class) class {
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i<outCount; i++)
    {
        const char *char_f =property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        const char * attributes = property_getAttributes(properties[i]);//获取属性类型
        NSString * typeAttribute=[NSString stringWithUTF8String:attributes];
        
        NSString * suffix = [typeAttribute substringToIndex:2];
        if([suffix isEqualToString:@"T{"]){//结构体类型
            continue;
        }else if([suffix isEqualToString:@"T@"]){//对象类型
//            NSRange rangeString = [typeAttribute rangeOfString:@"NSString"];
//            NSRange rangeNumber = [typeAttribute rangeOfString:@"NSNumber"];
//            NSRange rangeArray = [typeAttribute rangeOfString:@"NSArray"];
//            NSRange rangeMutableArray = [typeAttribute rangeOfString:@"NSMutableArray"];
//            NSRange rangeDate = [typeAttribute rangeOfString:@"NSDate"];
//            NSRange rangeDictionary = [typeAttribute rangeOfString:@"NSDictionary"];
//            NSRange rangeMutableDictionary = [typeAttribute rangeOfString:@"NSMutableDictionary"];
//            if (rangeString.location != NSNotFound || rangeNumber.location != NSNotFound || rangeDate.location != NSNotFound) {
//                [props setObject:typeAttribute forKey:propertyName];
//            }else if (rangeArray.location!=NSNotFound || rangeMutableArray.location!=NSNotFound) {
//                [props setObject:typeAttribute forKey:propertyName];
//            }else if (rangeDictionary.location!=NSNotFound || rangeMutableDictionary.location!=NSNotFound) {
//                [props setObject:typeAttribute forKey:propertyName];
//            }else {
//                continue;
//            }
            [props setObject:typeAttribute forKey:propertyName];
        }else {//基本数据类型
            [props setObject:typeAttribute forKey:propertyName];
        }
    }
    free(properties);
    properties = nil;
    return props;
}

#pragma mark model——》Dictionary
- (NSDictionary *)modelToDictionary:(id)model {
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (i = 0; i < outCount; i++) {
        const char * attributes = property_getAttributes(properties[i]);//获取属性类型
        NSString * typeName = [NSString stringWithUTF8String:attributes];
        
        NSString * suffix = [typeName substringToIndex:2];
        if([suffix isEqualToString:@"T{"]){//结构体类型
            continue;
        }else if([suffix isEqualToString:@"T@"]){//对象类型
            NSRange rangeString = [typeName rangeOfString:@"NSString"];
            NSRange rangeNumber = [typeName rangeOfString:@"NSNumber"];
            NSRange rangeArray = [typeName rangeOfString:@"NSArray"];
            NSRange rangeMutableArray = [typeName rangeOfString:@"NSMutableArray"];
            NSRange rangeDate = [typeName rangeOfString:@"NSDate"];
            NSRange rangeDictionary = [typeName rangeOfString:@"NSDictionary"];
            NSRange rangeMutableDictionary = [typeName rangeOfString:@"NSMutableDictionary"];

            if(rangeString.location!=NSNotFound || rangeNumber.location!=NSNotFound || rangeDate.location != NSNotFound) {
                objc_property_t property = properties[i];
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                id propertyValue = [model valueForKey:propertyName];
                if (propertyValue)
                    [props setObject:propertyValue forKey:propertyName];
            } else if(rangeArray.location!=NSNotFound || rangeMutableArray.location!=NSNotFound) {
                objc_property_t property = properties[i];
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                NSArray* propertyValue = [model valueForKey:propertyName];
                if([propertyValue.firstObject isKindOfClass:[NSString class]] || [propertyValue.firstObject isKindOfClass:[NSNumber class]]){
                    NSString *jsonStr = [self toJsonString:propertyValue];
                    if(jsonStr){
                        [props setObject:jsonStr forKey:propertyName];
                    }
                }else{
                    NSMutableArray * array = [[NSMutableArray alloc] init];
                    for(id model in propertyValue){
                        NSDictionary * dict = [self modelToDictionary:model];
                        [array addObject:dict];
                    }
                    NSString * jsonStr = [self toJsonString:array];
                    if(jsonStr){
                        [props setObject:jsonStr forKey:propertyName];
                    }
                }
            } else if (rangeMutableDictionary.location != NSNotFound || rangeDictionary.location != NSNotFound) {
                objc_property_t property = properties[i];
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                NSDictionary *propertyValue = [model valueForKey:propertyName];
                NSString *jsonStr = [self toJsonString:propertyValue];
                if (jsonStr) {
                    [props setObject:jsonStr forKey:propertyName];
                }
            } else{
                continue;
            }
        }else {//基本数据类型
            objc_property_t property = properties[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            id propertyValue = [model valueForKey:(NSString *)propertyName];
            if (propertyValue)
                [props setObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    return props;
}

#pragma mark object --> jsonString
- (NSString *)toJsonString:(id)object {
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&err];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (err) {
        NSLog(@"转json失败:%@",err);
        return nil;
    }
    return jsonStr;
}

#pragma mark jsonString --> object
- (id)arrayWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id object = [NSJSONSerialization JSONObjectWithData:jsonData
                    
                                                   options:NSJSONReadingMutableContainers
                    
                                                     error:&err];
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return object;
}

@end
