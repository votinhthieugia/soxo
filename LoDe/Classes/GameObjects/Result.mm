//
//  Result.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Result.h"
#import <time.h>

int Result::NUM_LOADED = 0;
BOOL Result::LOADED = NO;

Result::Result(const char *data) {
	if (data) {
		for (int i = 0; i < NUM_DIGITS; i++) {
			numbers[i] = data[i] - 48;
		}
		couples = findCouples();
	}
	NetManager::setListener(this);
}

Result::~Result() {
		
}

int Result::numberAtIndex(int index) {
	return numbers[index];
}

int Result::deValue() {
	return numbers[3] * 10 + numbers[4];
}

vector<int> Result::findCouples() {
	vector<int> result;
	for (int i = 0; i < NUM_COUPLES; i++) {
		if (i < 10) {
			result.push_back(numbers[(i + 1) * 5 - 2] * 10 + numbers[(i + 1) * 5 - 1]);
		} else if (i < 20) {
			result.push_back(numbers[50 + (i - 9) * 4 - 2] * 10 + numbers[50 + (i - 9) * 4 - 1]);
		} else if (i < 23) {
			result.push_back(numbers[90 + (i - 20) * 3 - 2] * 10 + numbers[90 + (i - 20) * 3 - 1]);
		} else {
			result.push_back(numbers[99 + (i - 23) * 2 - 2] * 10 + numbers[99 + (i - 23) * 2 - 1]);
		}
	}
	return result;
}

BOOL Result::isStraightBridge(int couple) {
	for (vector<int>::const_iterator ele = couples.begin(); ele != couples.end(); ele++) {
		if (*ele == couple) {
			return YES;
		}
	}
	return NO;
}

BOOL Result::isReverseBridge(int couple) {
	for (vector<int>::const_iterator ele = couples.begin(); ele != couples.end(); ele++) {
		if (((*ele % 10) == (couple / 10)) && ((*ele / 10) == (couple % 10))) {
			return YES;
		}
	}
	return NO;
}

BOOL Result::isDe(int value) {
	return (value == couples.at(0));
}

BOOL Result::isReverseDe(int value) {
	return (((couples.at(0) % 10) == (value / 10)) && ((couples.at(0) / 10) == (value % 10)));
}

void Result::load(NSString *date) {
	NetManager::get([NSString stringWithFormat:@"http://ketqua.net/autocantuvi34.php?type=mb&%@", date], NO, NO);
}

void Result::loadAll() {
	time_t today;
	struct tm *tinfo;
	time(&today);
	tinfo = localtime(&today);
	char buffer[20];
	tinfo->tm_mday -= NUM_LOADED;
	mktime(tinfo);
//	strftime(buffer, 20, "%Y/%m/%d", tinfo);
	strftime(buffer, 20, "%d/%m/%Y", tinfo);
	load([NSString stringWithCString:buffer]);
}

void Result::saveToDB(NSString *date, NSString *data) {
}

void Result::handleReceivedData(NSData *data) {
	NSString *xml = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSASCIIStringEncoding];
	NSLog(@"xml %@", xml);
	NUM_LOADED++;
	if (NUM_LOADED < 10) {
		loadAll();
	}
}

void Result::handleError(NSError *error) {
	
}