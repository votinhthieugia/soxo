//
//  Touch.h
//  Copyright 2009 Alley Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vector>
using namespace std;

class Touch {
public:
	float x;
	float y;
	float startX;
	float startY;
	BOOL isCanceled;
	BOOL isHandled;
	BOOL isEnded;
	UITouch *uiTouch;

public:
	BOOL startedIn(float x, float y, float width, float height) const;
	BOOL isIn(float x, float y, float width, float height) const;

public:
	static Touch *getTouchStartedIn(vector<Touch *> *touches, float x, float y, float width, float height);
	static Touch *getActiveTouch(vector<Touch *> *touches, Touch *touch);
	static void removeTouch(vector<Touch *> *touches, Touch *touch);
};

inline BOOL Touch::startedIn(float x, float y, float width, float height) const {
	return (this->startX >= x) && (this->startX < x + width) &&
		   (this->startY >= y) && (this->startY < y + height);
}

inline BOOL Touch::isIn(float x, float y, float width, float height) const {
	return (this->x >= x) && (this->x < x + width) &&
		   (this->y >= y) && (this->y < y + height);
}

inline Touch *Touch::getTouchStartedIn(vector<Touch *> *touches, float x, float y, float width, float height) {
	for (vector<Touch *>::const_iterator touch = touches->begin(); touch != touches->end(); touch++) {
		if ((*touch)->startedIn(x, y, width, height)) {
			return *touch;
		}
	}

	return nil;
}

inline Touch *Touch::getActiveTouch(vector<Touch *> *touches, Touch *touch) {
	for (vector<Touch *>::const_iterator touchPointer = touches->begin(); touchPointer != touches->end(); touchPointer++) {
		if ((*touchPointer) == touch) {
			return touch;
		}
	}

	return nil;
}

inline void Touch::removeTouch(vector<Touch *> *touches, Touch *touch) {
	for (vector<Touch *>::iterator touchPointer = touches->begin(); touchPointer != touches->end(); touchPointer++) {
		if ((*touchPointer) == touch) {
			touches->erase(touchPointer);
			return;
		}
	}
}