//
//  BasicScreen.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "BasicScreen.h"
#import "Button.h"
#import "Global.h"

BasicScreen::BasicScreen() {
	nextScreenIndex = SCREEN_INVALID;
	state = STATE_INVALID;
	setState(STATE_TRANSITION_IN);
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
}

BasicScreen::~BasicScreen() {
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
}

void BasicScreen::update(float elapsedSeconds, vector<Touch *> *touches) {
	switch (state) {
		case STATE_TRANSITION_IN:
			transitionAlpha += 1.5f * elapsedSeconds;
			if (transitionAlpha >= 1.0f) {
				transitionAlpha = 1.0f;
				setState(STATE_WAITING_FOR_ZERO_TOUCHES);
			} 
			transitionZ -= 900.0f * elapsedSeconds;
			if (transitionZ <= 0) {
				setState(STATE_WAITING_FOR_ZERO_TOUCHES);
			}
			break;
		case STATE_WAITING_FOR_ZERO_TOUCHES:
			if (touches->size() == 0) {
				setState(STATE_READY);
			}
			break;
		case STATE_READY:
			updateState(STATE_READY, elapsedSeconds, touches);
			break;
		case STATE_PAUSING:
			pauseAlpha += 6.0 * elapsedSeconds;
			if (pauseAlpha >= 1.0f) {
				setState(STATE_PAUSED);
			}
			break;
		case STATE_PAUSED:
			updateState(STATE_PAUSED, elapsedSeconds, touches);
			break;
		case STATE_RESUMING:
			pauseAlpha -= 6.0 * elapsedSeconds;
			if (pauseAlpha <= 0.0f) {
				setState(STATE_WAITING_FOR_ZERO_TOUCHES);
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

void BasicScreen::draw() {
	glPushMatrix();
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	DrawManager::setColor(1.0f, 1.0f, 1.0f, transitionAlpha);
//	Primitives::fillRect(0.0f, 0.0f, 480.0f, 320.0f);
	glTranslatef(0.0f, 0.0f, transitionZ);
	
	drawStateReady();
	
	glPopMatrix();
	
	switch (state) {
		case STATE_PAUSING:
		case STATE_PAUSED:
		case STATE_RESUMING:
			drawStatePaused();
			break;
		case STATE_TRANSITION_IN:
		case STATE_TRANSITION_OUT:
			break;
	}
}

void BasicScreen::handleEvent(int eventId, void *data) {
}

void BasicScreen::setState(int nextState) {
	state = nextState;
	
	switch (state) {
		case STATE_TRANSITION_IN:
			transitionAlpha = 0.0f;
			transitionZ = 600.0f;
			break;
		case STATE_WAITING_FOR_ZERO_TOUCHES:
			transitionZ = 0.0f;
			transitionAlpha = 1.0f;
			break;
		case STATE_READY:
			pauseAlpha = 0.0f;
			break;
		case STATE_PAUSING:
			pauseAlpha = 0.0f;
			break;
		case STATE_PAUSED:
			pauseAlpha = 1.0f;
			break;
		case STATE_RESUMING:
			pauseAlpha = 1.0f;
			break;
		case STATE_TRANSITION_OUT:
			transitionAlpha = 1.0f;
			break;
	}
	
	if (state != STATE_TRANSITION_IN) {
		enteringState(state);
	}
}