//
//  DetailScreen.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Engine.h"

class Button;

class DetailScreen: public Screen {
private:
	int state;
	int nextScreenIndex;
	float transitionAlpha;
	float transitionZ;
	float totalElapsedSeconds;
	
public:
	DetailScreen();
	virtual ~DetailScreen();
	
public:
	virtual void update(float elapsedSeconds, vector<Touch *> *touches);
	virtual void draw();
	virtual void handleEvent(int eventId, void *data = nil);
	virtual void pause();
	
private:
	void loadTextures();
	void unloadTextures();
	void setState(int nextState);
	void updateStateReady(float elapsedSeconds, vector<Touch *> *touches);
};
