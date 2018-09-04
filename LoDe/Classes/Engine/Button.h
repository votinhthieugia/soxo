//
//  Button.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Engine.h"

class Screen;

class Button {
public:
	float x;
	float y;
	float width;
	float height;
	float offsetX;
	float offsetY;
	vector<int> eventIds;

private:
	Screen *owner;
	int state;
	BOOL hasTouchedLastFrame;
	vector<Texture *> textures;
	BOOL canToggle;

public:
	Button(int textureIdOff, int textureIdOn, Screen *owner, int eventId);
	virtual ~Button();

public:
	void update(float elapsedSeconds, vector<Touch *> *touches);
	void draw();
	void reset();
	void disable();
	void setToggleState(int state);
};