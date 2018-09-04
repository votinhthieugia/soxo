//
//  Result.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Engine.h"
#import <vector>
#import <string.h>
using namespace std;

class Result : public NetListener {
public:
	static int NUM_LOADED;
	static BOOL LOADED;
	
public:
	enum {
		NUM_DIGITS = 107,
		NUM_COUPLES = 27
	};
	
	int numbers[NUM_DIGITS];
	vector<int> couples;
	
public:
	Result(const char *data);
	virtual ~Result();
	
public:
	int numberAtIndex(int index);
	int deValue();
	vector<int> findCouples();
	BOOL isStraightBridge(int couple);
	BOOL isReverseBridge(int couple);
	BOOL isDe(int value);
	BOOL isReverseDe(int value);
	
public:
	void load(NSString *date);
	void loadAll();
	void saveToDB(NSString *date, NSString *data);
	virtual void handleReceivedData(NSData *data);
	virtual void handleError(NSError *error);
};

