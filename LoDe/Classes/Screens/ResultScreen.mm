//
//  ResultScreen.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Button.h"
#import "Global.h"
#import "ResultScreen.h"

enum {
	EVENT_PAUSE,
};

enum {
	STATE_INVALID,
	STATE_TRANSITION_IN,
	STATE_READY,
	STATE_PAUSING,
	STATE_PAUSED,
	STATE_RESUMING,
	STATE_TRANSITION_OUT
};

ResultScreen::ResultScreen() {
	loadTextures();
	
	setState(STATE_TRANSITION_IN);
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
}

ResultScreen::~ResultScreen() {
	unloadTextures();
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
}

void ResultScreen::loadTextures() {
}

void ResultScreen::unloadTextures() {
}

void ResultScreen::setState(int nextState) {
	state = nextState;
	
	switch (state) {
		case STATE_TRANSITION_IN:
			transitionAlpha = 0.0f;
			transitionZ = 600.0f;
			break;
		case STATE_READY:
			transitionAlpha = 1.0f;
			transitionZ = 0.0f;
			break;
		case STATE_PAUSING:
			break;
		case STATE_PAUSED:
			break;
		case STATE_RESUMING:
			break;
		case STATE_TRANSITION_OUT:
			break;
	}
}

void ResultScreen::update(float elapsedSeconds, vector<Touch *> *touches) {
	switch (state) {
		case STATE_TRANSITION_IN:
			transitionAlpha += 1.5f * elapsedSeconds;
			if (transitionAlpha >= 1.0f) {
				transitionAlpha = 1.0f;
				setState(STATE_READY);
			} 
			transitionZ -= 900.0f * elapsedSeconds;
			if (transitionZ <= 0) {
				setState(STATE_READY);
			}
			break;
		case STATE_READY:
			updateStateReady(elapsedSeconds, touches);
			break;
		case STATE_PAUSING:
			setState(STATE_PAUSED);
			break;
		case STATE_PAUSED:
			break;
		case STATE_RESUMING:
			totalElapsedSeconds += elapsedSeconds;
			if (totalElapsedSeconds > 0.5f) {
				setState(STATE_READY);
			}
			break;
		case STATE_TRANSITION_OUT:
			transitionAlpha -= 1.5f * elapsedSeconds;
			if (transitionAlpha <= 0.0f) {
				transitionAlpha = 0.0f;
				Director::shared->setNextScreen(nextScreenIndex);
			} 
			transitionZ += 900.0f * elapsedSeconds;
			if (transitionZ >= 600.0f) {
				Director::shared->setNextScreen(nextScreenIndex);
			}
			break;
	}
}

void ResultScreen::updateStateReady(float elapsedSeconds, vector<Touch *> *touches) {
}

void ResultScreen::draw() {
	glPushMatrix();
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	DrawManager::setColor(1.0f, 1.0f, 1.0f, transitionAlpha);
	glTranslatef(0.0f, 0.0f, transitionZ);
	
	
	switch (state) {
		case STATE_TRANSITION_IN:
			break;
		case STATE_READY:
			break;
		case STATE_PAUSING:
		case STATE_PAUSED:
		case STATE_RESUMING:
			break;
		case STATE_TRANSITION_OUT:
			break;
	}
	
	glPopMatrix();
}

void ResultScreen::handleEvent(int eventId, void *data) {
	switch (eventId) {
//		case Global::Event::GAME_END:
//			break;
	}
}

void ResultScreen::pause() {
	handleEvent(EVENT_PAUSE);
}
