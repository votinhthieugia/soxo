//
//  MainMenuScreen.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "BasicScreen.h"
#import "Engine.h"

class Button;
class Result;

class MainMenuScreen: public BasicScreen {
private:
	float totalElapsedSeconds;
	vector <Button *> buttons;
	Result *result;
		
public:
	MainMenuScreen();
	virtual ~MainMenuScreen();
	
public:
	virtual void handleEvent(int eventId, void *data = nil);
	
protected:
	virtual void updateState(int state, float elapsedSeconds, vector<Touch *> *touches);
	virtual void drawStateReady();
	virtual void drawStatePaused();
	virtual void enteringState(int state);
};