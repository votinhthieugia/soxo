//
//  Slider.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Engine.h"

class Slider {
private:
	float x;
	float y;
	float width;
	Screen *owner;
	int eventId;
	float arrowValue;
	Texture *pegTexture;

public:
	Slider(float x, float y, float width, float value, Screen *owner, int eventId);
	virtual ~Slider();

public:
	void update(float elapsedSeconds, vector<Touch *> *touches);
	void draw(float alpha = 1.0f);
};