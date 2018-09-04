//
//  Random.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Random.h"

// Use arc4random, but make sure it works with float: #define ARC4RANDOM_MAX 0x100000000
#define ARC4RANDOM_MAX 0x100000000

Random *Random::shared = nil;

void Random::sharedNew() {
	shared = new Random();
}

void Random::sharedDelete() {
	delete(shared);
}

Random::Random() {
	for (int i = 0; i < 1024; i++) {
		randomFloats[i] = arc4random();
	}

	index = -1;
}

Random::~Random() {
}

float Random::randomFloat() {
	index = (index + 1) & 0x3FF;
	return randomFloats[index];
}