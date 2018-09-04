//
//  Button.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Button.h"
#import "Screen.h"

Button::Button(int textureIdOff, int textureIdOn, Screen *owner, int eventId) {
	textures.push_back(TextureManager::get(textureIdOff));
	textures.push_back(TextureManager::get(textureIdOn));
	this->owner = owner;
	eventIds.push_back(eventId);
	eventIds.push_back(eventId);
	hasTouchedLastFrame = NO;
	state = 0;
	canToggle = NO;
	offsetX = 0.0f;
	offsetY = 0.0f;
}

Button::~Button() {
}

void Button::update(float elapsedSeconds, vector<Touch *> *touches) {
	if (canToggle || state == 0) {
		BOOL hasTouched = NO;
		for (vector<Touch *>::const_iterator touch = touches->begin(); touch != touches->end(); touch++) {
			if ((*touch)->startedIn(x + offsetX, y + offsetY, width, height)) {
				hasTouched = YES;
				break;
			}
		}
		if (hasTouched && !hasTouchedLastFrame) {
			int previousState = state;
			state = (state + 1) % textures.size();
			owner->handleEvent(eventIds[previousState]);
		}
		hasTouchedLastFrame = hasTouched;
	}
}

void Button::draw() {
	textures[state]->draw(x, y);
}

void Button::reset() {
	if (!canToggle) {
		state = 0;
	}
}

void Button::disable() {
	if (!canToggle) {
		state = 1;
	}
}

void Button::setToggleState(int state) {
	this->state = state;
}