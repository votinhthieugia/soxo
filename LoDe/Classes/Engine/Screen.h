//
//  Screen.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <vector>
using namespace std;

class Touch;

class Screen {
public:
	virtual ~Screen();
	virtual void update(float elapsedSeconds, vector<Touch *> *touches) = 0;
	virtual void draw() = 0;
	virtual void handleEvent(int eventId, void *data = nil) = 0;
	virtual void pause();
	virtual void save();
};