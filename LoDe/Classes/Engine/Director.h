//
//  Director.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/time.h>

enum {
	SCREEN_INVALID,
	SCREEN_MAIN_MENU,
	SCREEN_RESULT,
	SCREEN_DETAIL,
};

class Screen;
@class EAGLView;

class Director {
private:
	EAGLView *eaglView;
	struct timeval lastUpdate;
	Screen *currentScreen;
	int nextScreenId;
	
public:
	int previousScreenId;
	int currentScreenId;
	
public:
	static Director *shared;
	static void sharedNew(UIView *view);
	static void sharedDelete();
	
private:
	Director(UIView *view);
	virtual ~Director();
	
public:
	void start();
	void mainLoop();
	void setNextScreen(int screenId);
	void pause();
};