//
//  Director.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Audio.h"
#import "Database.h"
#import "Director.h"
#import "EAGLView.h"
#import "Global.h"
#import "Glu.h"
#import "Screen.h"
#import "Screens.h"
#import "TextureManager.h"

Director *Director::shared = nil;

void Director::sharedNew(UIView *view) {
	shared = new Director(view);
}

void Director::sharedDelete() {
	delete(shared);
}

Director::Director(UIView *view) {
	eaglView = [[EAGLView alloc] initWithFrame:[view frame]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:GL_DEPTH_COMPONENT16_OES
							preserveBackbuffer:NO];
	[eaglView setOpaque:YES];
	[eaglView setUserInteractionEnabled:YES];
	[eaglView setMultipleTouchEnabled:YES];
	[eaglView setExclusiveTouch:YES];
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
	glFrontFace(GL_CW);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
	
	glViewport(0, 0, eaglView.frame.size.width, eaglView.frame.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60,
				   (GLfloat)eaglView.frame.size.width / eaglView.frame.size.height,
				   0.5f,
				   1500.0f);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt(eaglView.frame.size.width / 2,
			  eaglView.frame.size.height / 2,
			  Global::EYE_POSITION_Z,
			  eaglView.frame.size.width / 2,
			  eaglView.frame.size.height / 2,
			  0,
			  0.0f,
			  1.0f,
			  0.0f);
	
//	glTranslatef(160.0f, 240.0f, 0.0f);
//	glRotatef(180.0f, 1.0f, 0.0f, 0.0f);
//	glTranslatef(-160.0f, -240.0f, 0.0f);

	glTranslatef(160.0f, 240.0f, 0.0f);
	glRotatef(-90.0f, 0.0f, 0.0f, 1.0f);
	glRotatef(180.0f, 1.0f, 0.0f, 0.0f);
	glTranslatef(-240.0f, -160.0f, 0.0f);
	
	glClientActiveTexture(GL_TEXTURE1);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glActiveTexture(GL_TEXTURE1);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
	glClientActiveTexture(GL_TEXTURE0);
	glActiveTexture(GL_TEXTURE0);
	
	Global::sharedNew();
	Random::sharedNew();
	NetManager::sharedNew();
	
	[view addSubview:eaglView];
}

Director::~Director() {
	delete(currentScreen);
	NetManager::sharedDelete();
	Random::sharedDelete();
	Global::sharedDelete();
	glDisable(GL_CULL_FACE);
	glDisable(GL_BLEND);
	[eaglView release];
}

void Director::start() {
	currentScreen = new MainMenuScreen();
	currentScreenId = SCREEN_MAIN_MENU;
	previousScreenId = SCREEN_INVALID;
	nextScreenId = SCREEN_INVALID;
	
	gettimeofday(&lastUpdate, nil);
	while (YES) {
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES) == kCFRunLoopRunHandledSource);
		mainLoop();
		while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES) == kCFRunLoopRunHandledSource);
		[pool release];
	}
}

void Director::mainLoop() {
	struct timeval now;
	gettimeofday(&now, nil);
	
	// Limit the framerate to 20 frames per second.
	float elapsedSeconds = now.tv_sec - lastUpdate.tv_sec + (now.tv_usec - lastUpdate.tv_usec) / 1000000.0f;
	if (elapsedSeconds > 0.05f) {
		elapsedSeconds = 0.05f;
	}
	lastUpdate = now;
	if (nextScreenId != SCREEN_INVALID) {
		delete(currentScreen);
		
		previousScreenId = currentScreenId;
		currentScreenId = nextScreenId;
		nextScreenId = SCREEN_INVALID;
		
		switch (currentScreenId) {
			case SCREEN_MAIN_MENU:
				currentScreen = new MainMenuScreen();
				break;
			case SCREEN_RESULT:
				currentScreen = new ResultScreen();
				break;
			case SCREEN_DETAIL:
				currentScreen = new DetailScreen();
				break;
		}
	}
	
	currentScreen->update(elapsedSeconds, [eaglView activeTouches]);
	[eaglView handleAndClearEndedTouches];
	currentScreen->draw();
	
	[eaglView swapBuffers];
}

void Director::setNextScreen(int screenId) {
	nextScreenId = screenId;
}

void Director::pause() {
	currentScreen->pause();
}