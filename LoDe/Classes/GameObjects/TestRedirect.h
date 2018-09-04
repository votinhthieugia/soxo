/*
 *  TestRedirect.h
 *  LetterJump
 *
 *  Created by Doan Hoang Anh on 3/17/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "Engine.h"

class NetListener;

class TestRedirect : public NetListener {
public:
	TestRedirect();
	virtual ~TestRedirect();

public:
	void load();
	
public:
	virtual void handleReceivedData(NSData *data);
	virtual void handleError(NSError *error);
};

