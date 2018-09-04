//
//  Database.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Database.h"

Database::Database(NSString *dbName) {
	sqlite = nil;
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentFolderPath = [searchPaths objectAtIndex:0];
	NSString *databaseFilePath = [documentFolderPath stringByAppendingPathComponent:[dbName stringByAppendingString:@".db"]];

	if (![[NSFileManager defaultManager] fileExistsAtPath:databaseFilePath]) {
		NSString *backupDatabasePath = [[NSBundle mainBundle] pathForResource:dbName ofType:@"db"];
		if (backupDatabasePath) {
			[[NSFileManager defaultManager] copyItemAtPath:backupDatabasePath toPath:databaseFilePath error:nil];
		}
	}

	open(databaseFilePath);
}

Database::~Database() {
	close();
}

void Database::open(NSString *databaseFilePath) {
	sqlite3_open([databaseFilePath UTF8String], &sqlite);
}

void Database::close() {
	if (sqlite) {
		sqlite3_close(sqlite);
		sqlite = nil;
	}
}

NSArray *Database::select(NSString *sql, int *dataTypes, int numDataTypes) {
	sqlite3_stmt *statement = nil;
	NSMutableArray *results = [NSMutableArray array];

	if (sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		printf("error preparing select statement: %s\n", sqlite3_errmsg(sqlite));
		return results;
	}

	while (SQLITE_ROW == sqlite3_step(statement)) {
		NSMutableArray *row = [NSMutableArray arrayWithCapacity:numDataTypes];

		for (int i = 0; i < numDataTypes; i++) {
			switch (dataTypes[i]) {
				case SQLITE_TEXT:
					[row addObject:[[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, i)] autorelease]];
					break;
				case SQLITE_INTEGER:
					[row addObject:[NSNumber numberWithInt:sqlite3_column_int(statement, i)]];
					break;
				case SQLITE_FLOAT:
					[row addObject:[NSNumber numberWithFloat:sqlite3_column_double(statement, i)]];
					break;
				case SQLITE_BLOB: {
					const void *data = sqlite3_column_blob(statement, i);
					int length = sqlite3_column_bytes(statement, i);
					[row addObject:[NSData dataWithBytes:data length:length]];
					break;
				}
			}
		}

		[results addObject:row];
	}

	sqlite3_finalize(statement);

	return results;
}

int Database::insertBlob(NSString *sql, unsigned char *data, int size) {
	sqlite3_stmt *statement = nil;

	if (sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		printf( "error preparing insert statement: %s\n", sqlite3_errmsg(sqlite));
		return -1;
	}

	sqlite3_bind_blob(statement, 1, data, size, SQLITE_TRANSIENT);

	if (SQLITE_DONE != sqlite3_step(statement)) {
		printf("error while inserting data. '%s'", sqlite3_errmsg(sqlite));
		return -1;
	} 

	sqlite3_finalize(statement);

	return sqlite3_last_insert_rowid(sqlite);
}

int Database::insert(NSString *sql, NSArray *data, int *dataTypes, int numDataTypes) {
	sqlite3_stmt *statement = nil;

	if (sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		printf( "error preparing insert statement: %s\n", sqlite3_errmsg(sqlite));
		return -1;
	}

	for (int i = 0; i < numDataTypes; i++) {
		switch (dataTypes[i]) {
			case SQLITE_TEXT:
				sqlite3_bind_text(statement, i + 1, [[data objectAtIndex:i] UTF8String], -1, SQLITE_TRANSIENT);
				break;
			case SQLITE_INTEGER:
				sqlite3_bind_int(statement, i + 1, [[data objectAtIndex:i] intValue]);
				break;
			case SQLITE_FLOAT:
				sqlite3_bind_double(statement, i + 1, [[data objectAtIndex:i] floatValue]);
				break;
			case SQLITE_BLOB:
				sqlite3_bind_blob(statement, i + 1, [[data objectAtIndex:i] bytes], [[data objectAtIndex:i] length], SQLITE_TRANSIENT);
				break;
		}
	}

	if (SQLITE_DONE != sqlite3_step(statement)) {
		printf("error while inserting data. '%s'", sqlite3_errmsg(sqlite));
		return -1;
	} 

	sqlite3_finalize(statement);

	return sqlite3_last_insert_rowid(sqlite);
}

BOOL Database::update(NSString *sql, NSArray *data, int *dataTypes, int numDataTypes) {
	sqlite3_stmt *statement = nil;

	if (sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		printf("error preparing insert statement: %s\n", sqlite3_errmsg(sqlite));
		return NO;
	}

	for (int i = 0; i < numDataTypes; i++) {
		switch (dataTypes[i]) {
			case SQLITE_TEXT:
				sqlite3_bind_text(statement, i + 1, (const char*)[data objectAtIndex:i], -1, SQLITE_TRANSIENT);
				break;
			case SQLITE_INTEGER:
				sqlite3_bind_int(statement, i + 1, [[data objectAtIndex:i] intValue]);
				break;
			case SQLITE_FLOAT:
				sqlite3_bind_double(statement, i + 1, [[data objectAtIndex:i] floatValue]);
				break;
		}
	}

	if (SQLITE_DONE != sqlite3_step(statement)) {
		printf("error while updating data. '%s'", sqlite3_errmsg(sqlite));
		return NO;
	} 

	sqlite3_finalize(statement);

	return YES;
}

int Database::count(NSString *sql) {
	int count = -1;
	sqlite3_stmt *statement = nil;

	sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &statement, nil);

	if (SQLITE_ROW == sqlite3_step(statement)) {
		count = sqlite3_column_int(statement, 0);
	}

	sqlite3_finalize(statement);

	return count;
}