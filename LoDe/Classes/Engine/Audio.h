//
//  Audio.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import <OpenAL/al.h>
#import <OpenAl/alc.h>
#import <Foundation/Foundation.h>
#import <sys/time.h>

#import <map>
#import <vector>
using namespace std;

class Audio {
private:
	ALCcontext *mContext;
	ALCdevice *mDevice;
	BOOL otherAudioPlaying;
	map<NSString *, NSUInteger> buffers;
	map<NSString *, void *> dataBuffers;
	NSUInteger musicSource;
	map<NSString *, vector<NSUInteger> *> soundEffectSources;
	float musicVolume;
	float soundEffectVolume;

public:
	static Audio *shared;	
	static void sharedNew(float musicVolume, float soundEffectVolume);
	static void sharedDelete();
	
private:
	Audio(float musicVolume, float soundEffectVolume);
	virtual ~Audio();
	
public:	
	void haltOpenALSession();
	void resumeOpenALSession();

	void load(NSString *filename, int numSources, void *data = nil);
	void unload(NSString *filename);

	void playMusic(NSString *filename, BOOL loop = NO);
	void playSoundEffect(NSString *filename, BOOL loop = NO);

	void stop(NSString *filename);
	void pause(NSString *filename);
	void stop();

	float getMusicVolume();
	float getSoundEffectVolume();

	void setMusicVolume(float volume);
	void setSoundEffectVolume(float volume);

	unsigned long getSize(NSString *filename);

	BOOL isIPodMusicPlaying();
	BOOL isHeadset();

private:
	void getOpenALAudioData(CFURLRef inFileURL,
							ALsizei *outDataSize,
							ALenum *outDataFormat,
							ALsizei *outSampleRate,
							void *outData);

	BOOL isOlderThan(struct timeval a, struct timeval b);
};