//
//  Slider.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Slider.h"

Slider::Slider(float x, float y, float width, float value, Screen *owner, int eventId) {
	this->x = x;
	this->y = y;
	this->width = width;
	this->arrowValue = value;
	this->owner = owner;
	this->eventId = eventId;
	pegTexture = TextureManager::get(TextureId::SLIDER);
}

Slider::~Slider() {
}

void Slider::update(float elapsedSeconds, vector<Touch *> *touches) {
	for (vector<Touch *>::const_iterator touch = touches->begin(); touch != touches->end(); touch++) {
		if ((*touch)->startedIn(x - 20.0f, y - 25.0f, width + 40.0f, 50.0f)) {
			arrowValue = ((*touch)->x - x) / width;
			arrowValue = MIN(arrowValue, 1.0f);
			arrowValue = MAX(arrowValue, 0.0f);
			owner->handleEvent(eventId, [NSNumber numberWithFloat:arrowValue]);
			break;
		}
	}
}

void Slider::draw(float alpha) {
	float arrowX = arrowValue * width + x;

	DrawManager::setColor(0.54f, 0.54f, 0.54f, alpha);
	Primitives::fillRect(x, y, width, 1.0f);

	DrawManager::setColor(0.32f, 0.32f, 0.32f, alpha);
	Primitives::fillRect(x, y + 1.0f, width, 1.0f);

	DrawManager::setColor(0.08f, 0.08f, 0.08f, alpha);
	Primitives::fillRect(x, y + 2.0f, width, 1.0f);

	DrawManager::setColor(1.0f, 1.0f, 1.0f, alpha);
	pegTexture->draw(arrowX - 12.0f, y - 11.0f);
}
