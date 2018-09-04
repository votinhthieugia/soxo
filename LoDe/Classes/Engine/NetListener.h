//
//  NetListener.h
//  Copyright 2009 Alley:Labs. All rights reserved.
//

class NetListener {
public:
	virtual ~NetListener() {}

public:
	virtual void handleReceivedData(NSData *data) = 0;
	virtual void handleError(NSError *error) = 0;
};