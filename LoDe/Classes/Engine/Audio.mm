//
//  Audio.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <OpenAL/oalStaticBufferExtension.h>
#import "Audio.h"

static const float MASTER_VOLUME = 1.0f;

void interruptionListenerCallback(void *inUserData, UInt32 interruptionState) {
	switch (interruptionState) {
		case kAudioSessionBeginInterruption:
			Audio::shared->haltOpenALSession();
			break;
		case kAudioSessionEndInterruption:
			Audio::shared->resumeOpenALSession();
			break;
	}
}

Audio *Audio::shared = nil;

void Audio::sharedNew(float musicVolume, float soundEffectVolume) {
	shared = new Audio(musicVolume, soundEffectVolume);
}

void Audio::sharedDelete() {
	delete(shared);
}

Audio::Audio(float musicVolume, float soundEffectVolume) {
	this->musicVolume = musicVolume;
	this->soundEffectVolume = soundEffectVolume;
	
	AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, NULL);
	UInt32 category = kAudioSessionCategory_AmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
	
	UInt32 propertySize;
	UInt32 audioIsAlreadyPlaying;
	
	propertySize = sizeof(UInt32);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &audioIsAlreadyPlaying);
	otherAudioPlaying = (audioIsAlreadyPlaying == 1);
	
	mDevice = alcOpenDevice(NULL);
	mContext = alcCreateContext(mDevice, NULL);
	alcMakeContextCurrent(mContext);
	
	// Get sources.
	alGenSources(1, &musicSource);
	alSourcef(musicSource, AL_PITCH, 1.0f);
	alSourcef(musicSource, AL_GAIN, musicVolume * MASTER_VOLUME);
}

Audio::~Audio() {
	for (map<NSString *, vector<NSUInteger> *>::const_iterator sources = soundEffectSources.begin(); sources != soundEffectSources.end(); sources++) {
		for (vector<NSUInteger>::const_iterator source = sources->second->begin(); source != sources->second->end(); source++) {
			alSourceStop(*source);
			alDeleteBuffers(1, &(*source));
		}
		delete(sources->second);
	}
	alSourceStop(musicSource);
	alDeleteBuffers(1, &musicSource);
	for (map<NSString *, NSUInteger>::const_iterator bufferPair = buffers.begin(); bufferPair != buffers.end(); bufferPair++) {
		alDeleteBuffers(1, &(bufferPair->second));
	}
	buffers.clear();
	for (map<NSString *, void *>::const_iterator bufferPair = dataBuffers.begin(); bufferPair != dataBuffers.end(); bufferPair++) {
		free(bufferPair->second);
	}
	dataBuffers.clear();
	
	alcDestroyContext(mContext);
	alcCloseDevice(mDevice);
}

BOOL Audio::isHeadset() {
	CFStringRef route;
	UInt32 size = sizeof(CFStringRef);
	OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &route);
	return !error && route && (CFStringCompare(route, CFSTR("Headphone"), 0) == kCFCompareEqualTo);		
}

void Audio::haltOpenALSession() {
	AudioSessionSetActive(false);
	alcMakeContextCurrent(NULL);
	alcSuspendContext(mContext);
}

void Audio::resumeOpenALSession() {
	// Reset audio session.
	UInt32 category = kAudioSessionCategory_AmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
	
	// Reactivate the current audio session.
	AudioSessionSetActive(true);
	
	// Restore open al context.
	alcMakeContextCurrent(mContext);
	
	// 'unpause' my context.
	alcProcessContext(mContext);
}

void Audio::playMusic(NSString *filename, BOOL loop) {
	// If we should not play the audio (because other audio is playing), then the audio will not be loaded.
	if (shared->buffers.find(filename) != shared->buffers.end()) {
		alSourcei(musicSource, AL_BUFFER, shared->buffers[filename]);
		alSourcei(musicSource, AL_LOOPING, loop ? AL_TRUE : AL_FALSE);
		alSourcePlay(musicSource);
	}
}

void Audio::playSoundEffect(NSString *filename, BOOL loop) {
	// If we should not play the audio (because iPod audio is playing), then the audio will not be loaded.
	if (shared->buffers.find(filename) != shared->buffers.end()) {
		vector<NSUInteger> *sources = shared->soundEffectSources[filename];
		if (sources) {
			ALenum state;
			for (vector<NSUInteger>::const_iterator source = sources->begin(); source != sources->end(); source++) {
				alGetSourcei(*source, AL_SOURCE_STATE, &state);
				if (state != AL_PLAYING) {
					alSourcei(*source, AL_BUFFER, shared->buffers[filename]);
					alSourcei(*source, AL_LOOPING, loop ? AL_TRUE : AL_FALSE);
					alSourcePlay(*source);
					break;
				}
			}
		}
	}
}

void Audio::stop() {
	alSourceStop(musicSource);
	alSourcei(musicSource, AL_BUFFER, 0);
	for (map<NSString *, vector<NSUInteger> *>::const_iterator sources = shared->soundEffectSources.begin(); sources != shared->soundEffectSources.end(); sources++) {
		for (vector<NSUInteger>::const_iterator source = sources->second->begin(); source != sources->second->end(); source++) {
			alSourceStop(*source);
			alSourcei(*source, AL_BUFFER, 0);
		}
	}
}

void Audio::stop(NSString *filename) {
	//NSNumber *numVal = [soundDictionary objectForKey:filename];
	//	if (numVal == nil) {
	//		return;
	//	}
	//	NSUInteger sourceID = [numVal unsignedIntValue];
	//	alSourceStop(sourceID);
}

void Audio::pause(NSString *filename) {
	//	NSNumber *numVal = [soundDictionary objectForKey:filename];
	//	if (numVal == nil) {
	//		return;
	//	}
	//	NSInteger sourceID = [numVal unsignedIntValue];
	//	alSourcePause(sourceID);
}

void Audio::load(NSString *filename, int numSources, void *data) {
	ALsizei size;
	ALenum format;
	ALsizei frequency;
	ALvoid *audioData;
	
	if (data == nil) {
		audioData = malloc(getSize(filename));
		dataBuffers[filename] = audioData;
	} else {
		audioData = data;
	}
	CFURLRef url = (CFURLRef)[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:nil]] retain];
	getOpenALAudioData(url, &size, &format, &frequency, audioData);
	CFRelease(url);
	
	NSUInteger bufferId;
	alGenBuffers(1, &bufferId);
	alBufferDataStaticProcPtr proc = (alBufferDataStaticProcPtr)alcGetProcAddress(nil, (const ALCchar *)"alBufferDataStatic");
	proc(bufferId, format, audioData, size, frequency);
	buffers[filename] = bufferId;
	
	vector<NSUInteger> *sources = new vector<NSUInteger>();
	for (int i = 0; i < numSources; i++) {
		NSUInteger sourceId;
		alGenSources(1, &sourceId);
		alSourcef(sourceId, AL_PITCH, 1.0f);
		alSourcef(sourceId, AL_GAIN, soundEffectVolume * MASTER_VOLUME);
		sources->push_back(sourceId);
	}
	soundEffectSources[filename] = sources;
}

void Audio::unload(NSString *filename) {
	if (shared->buffers.find(filename) != shared->buffers.end()) {
		alDeleteBuffers(1, &(shared->buffers[filename]));
		shared->buffers.erase(filename);
	}
	if (shared->dataBuffers.find(filename) != shared->dataBuffers.end()) {
		free(shared->dataBuffers[filename]);
		shared->dataBuffers.erase(filename);
	}
}

void Audio::getOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei *outSampleRate, void *data) {
	SInt64 fileLengthInFrames = 0;
	AudioStreamBasicDescription fileFormat;
	UInt32 propertySize = sizeof(fileFormat);
	ExtAudioFileRef extRef = NULL;
	AudioStreamBasicDescription outputFormat;
	
	// Open a file with ExtAudioFileOpen()
	ExtAudioFileOpenURL(inFileURL, &extRef);
	
	// Get the audio data format
	ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &propertySize, &fileFormat);
	
	// Set the client format to 16 bit signed integer (native-endian) data
	// Maintain the channel count and sample rate of the original source format
	outputFormat.mSampleRate = fileFormat.mSampleRate;
	outputFormat.mChannelsPerFrame = fileFormat.mChannelsPerFrame;
	outputFormat.mFormatID = kAudioFormatLinearPCM;
	outputFormat.mBytesPerPacket = 2 * outputFormat.mChannelsPerFrame;
	outputFormat.mFramesPerPacket = 1;
	outputFormat.mBytesPerFrame = 2 * outputFormat.mChannelsPerFrame;
	outputFormat.mBitsPerChannel = 16;
	outputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	
	// Set the desired client (output) data format
	ExtAudioFileSetProperty(extRef, kExtAudioFileProperty_ClientDataFormat, sizeof(outputFormat), &outputFormat);
	
	// Get the total frame count
	propertySize = sizeof(fileLengthInFrames);
	ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &propertySize, &fileLengthInFrames);
	
	// Read all the data into memory
	UInt32 dataSize = fileLengthInFrames * outputFormat.mBytesPerFrame;
	AudioBufferList theDataBuffer;
	theDataBuffer.mNumberBuffers = 1;
	theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
	theDataBuffer.mBuffers[0].mNumberChannels = outputFormat.mChannelsPerFrame;
	theDataBuffer.mBuffers[0].mData = data;
	
	// Read the data into an AudioBufferList
	ExtAudioFileRead(extRef, (UInt32*)&fileLengthInFrames, &theDataBuffer);
	*outDataSize = (ALsizei)dataSize;
	*outDataFormat = (outputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
	*outSampleRate = (ALsizei)outputFormat.mSampleRate;
	
	ExtAudioFileDispose(extRef);
}

float Audio::getMusicVolume() {
	return musicVolume;
}

float Audio::getSoundEffectVolume() {
	return soundEffectVolume;
}

void Audio::setMusicVolume(float volume) {
	musicVolume = volume;
	alSourcef(musicSource, AL_GAIN, musicVolume * MASTER_VOLUME);
}

void Audio::setSoundEffectVolume(float volume) {
	soundEffectVolume = volume;
	for (map<NSString *, vector<NSUInteger> *>::const_iterator sources = shared->soundEffectSources.begin(); sources != shared->soundEffectSources.end(); sources++) {
		for (vector<NSUInteger>::const_iterator source = sources->second->begin(); source != sources->second->end(); source++) {
			alSourcef(*source, AL_GAIN, soundEffectVolume * MASTER_VOLUME);
		}
	}
}

unsigned long Audio::getSize(NSString *filename) {
	CFURLRef inFileURL = (CFURLRef)[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:nil]] retain];
	
	SInt64 fileLengthInFrames = 0;
	AudioStreamBasicDescription fileFormat;
	UInt32 propertySize = sizeof(fileFormat);
	ExtAudioFileRef extRef = NULL;
	
	// Open a file with ExtAudioFileOpen()
	ExtAudioFileOpenURL(inFileURL, &extRef);
	CFRelease(inFileURL);
	
	// Get the audio data format
	ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &propertySize, &fileFormat);
	
	// Get the total frame count
	propertySize = sizeof(fileLengthInFrames);
	ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &propertySize, &fileLengthInFrames);
	
	//	NSLog([NSString stringWithFormat:@"%@:%d", filename, fileLengthInFrames * 2 * fileFormat.mChannelsPerFrame]);
	
	// Get real size
	return fileLengthInFrames * 2 * fileFormat.mChannelsPerFrame;
}

BOOL Audio::isIPodMusicPlaying() {
	return otherAudioPlaying;
}

BOOL Audio::isOlderThan(struct timeval a, struct timeval b) {
	return (a.tv_sec < b.tv_sec) || (a.tv_sec == b.tv_sec && a.tv_usec < b.tv_usec);
}