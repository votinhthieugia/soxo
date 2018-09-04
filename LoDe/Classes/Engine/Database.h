//
//  Database.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

class Database {
private:
	sqlite3 *sqlite;

public:
	Database(NSString *name);
	virtual ~Database();

public:
	NSArray *select(NSString *sql, int *dataTypes, int numDataTypes);
	int count(NSString *sql);
	int insertBlob(NSString *sql, unsigned char *data, int size);
	int insert(NSString *sql, NSArray *data, int *dataTypes, int numDataTypes);
	BOOL update(NSString *sql, NSArray *data = nil, int *dataTypes = nil, int numDataTypes = 0);

private:
	void open(NSString *databaseFilePath);
	void close();
};