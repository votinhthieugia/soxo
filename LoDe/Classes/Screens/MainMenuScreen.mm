//
//  MainMenuScreen.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Button.h"
#import "Global.h"
#import "MainMenuScreen.h"
#import "Result.h"

MainMenuScreen::MainMenuScreen() : BasicScreen() {
//	TextureManager::load(@"buttonPlay.png", TextureId::PLAY);
//	TextureManager::load(@"buttonSetting.png", TextureId::SETTING);
//	TextureManager::load(@"buttonHelp.png", TextureId::HELP);
//	TextureManager::load(@"buttonHighscore.png", TextureId::HIGH_SCORE);
//	
//	Button *button = new Button(TextureId::PLAY, TextureId::PLAY, this, EVENT_PLAY);
//	button->x = 20.0f;
//	button->y = 30.0f;
//	button->width = 150.0f;
//	button->height = 60.0f;
//	buttons.push_back(button);
	
	result = new Result(nil);
	result->loadAll();
	
//	titleTexture = new Texture(@"hoanganh", 100.0f, 30.0f, UITextAlignmentCenter, @"AmericanTypewriter-Bold", 20.0f);
	
	state = STATE_INVALID;
	setState(STATE_TRANSITION_IN);
}

MainMenuScreen::~MainMenuScreen() {
	setState(STATE_INVALID);
	for (vector<Button *>::const_iterator button = buttons.begin(); button != buttons.end(); button++) {
		delete(*button);
	}
	TextureManager::unload(TextureId::PLAY);
	TextureManager::unload(TextureId::SETTING);
	TextureManager::unload(TextureId::HELP);
	TextureManager::unload(TextureId::HIGH_SCORE);
}

void MainMenuScreen::updateState(int state, float elapsedSeconds, vector<Touch *> *touches) {
	switch (state) {
		case STATE_READY:
			for (vector<Button *>::const_iterator button = buttons.begin(); button != buttons.end(); button++) {
				(*button)->update(elapsedSeconds, touches);
			}
			break;
	}
}

void MainMenuScreen::drawStateReady() {
	for (vector<Button *>::const_iterator button = buttons.begin(); button != buttons.end(); button++) {
		(*button)->draw();
	}
}

void MainMenuScreen::handleEvent(int eventId, void *data) {
	switch (eventId) {
//		case EVENT_SELECT:
//			break;
//		case EVENT_SETTINGS:
//			break;
//		case EVENT_HELP:
//			break;
//		case EVENT_SCORES:
//			break;
//		case EVENT_PLAY:
//			nextScreenIndex = SCREEN_GAME;
//			setState(STATE_TRANSITION_OUT);
//			break;
	}
}

void MainMenuScreen::enteringState(int state) {
	switch (state) {
		case STATE_READY:
			break;
	}
}

void MainMenuScreen::drawStatePaused() {
}
