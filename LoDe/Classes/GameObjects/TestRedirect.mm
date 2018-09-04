/*
 *  TestRedirect.mm
 *  LetterJump
 *
 *  Created by Doan Hoang Anh on 3/17/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "NetListener.h"
#import "TestRedirect.h"

TestRedirect::TestRedirect() {
	
}

TestRedirect::~TestRedirect() {
	
}

void TestRedirect::load() {
	NetManager::setListener(this);
	NetManager::get(@"http://ketqua.net/autocantuvi34.php?type=mb&ngay=03/06/2010", NO, NO);
}

void TestRedirect::handleReceivedData(NSData * data) {
	NSString *xml = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSASCIIStringEncoding];
	NSLog(@"xml %@", xml);
}

void TestRedirect::handleError(NSError *error) {
	printf("error");
}

