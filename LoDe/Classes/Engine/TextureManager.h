//
//  TextureManager.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

#import <map>
using namespace std;

class DataBuffer;
class Texture;

class TextureManager {
private:
	static map<int, Texture *> textures;

public:
	static Texture *load(NSString *filename, int textureId, int numFrameColumns = 1, int numFrameRows = 1);
	static Texture *get(int textureId);
	static void unload(int textureId);
};