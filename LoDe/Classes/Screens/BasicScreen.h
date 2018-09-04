//
//  BasicScreen.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Engine.h"

class Button;

enum {
	STATE_INVALID,
	STATE_TRANSITION_IN,
	STATE_WAITING_FOR_ZERO_TOUCHES,
	STATE_READY,
	STATE_PAUSING,
	STATE_PAUSED,
	STATE_RESUMING,
	STATE_TRANSITION_OUT,
	STATE_SWITCHING_IN,
	STATE_SWITCHING_OUT
};

class BasicScreen : public Screen {
protected:
	int state;
	int nextScreenIndex;
	float pauseAlpha;
	float transitionAlpha;
	float transitionZ;
	
public:
	BasicScreen();
	virtual ~BasicScreen();
	
public:
	virtual void update(float elapsedSeconds, vector<Touch *> *touches);
	virtual void draw();
	virtual void handleEvent(int eventId, void *data = nil);
	
protected:
	virtual void updateState(int state, float elapsedSeconds, vector<Touch *> *touches) = 0;
	virtual void drawStateReady() = 0;
	virtual void drawStatePaused() = 0;
	virtual void enteringState(int state) = 0;
	
protected:
	void setState(int nextState);
};