//
//  Random.h
//  Copyright 2009 Friends Group. All rights reserved.
//

// Returns a random float between -1 and 1.
#define RANDOM_MINUS1_1() (((float)Random::shared->randomFloat() / (float)0x7fffffff) - 1.0f)

// Returns a random float between 0 and 1.
#define RANDOM_0_1() ((Random::shared->randomFloat() / (float)0xffffffff))

class Random {
public:
	static Random *shared;
	static void sharedNew();
	static void sharedDelete();

public:
	Random();
	virtual ~Random();

public:
	float randomFloat();

private:
	float randomFloats[1024];
	int index;
};