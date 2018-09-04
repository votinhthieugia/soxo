//
//  TextureManager.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Texture.h"
#import "TextureManager.h"

map<int, Texture *> TextureManager::textures;

Texture *TextureManager::load(NSString *filename, int textureId, int numFrameColumns, int numFrameRows) {
	Texture *texture = new Texture(filename, numFrameColumns, numFrameRows);
	textures.insert(pair<int, Texture *>(textureId, texture));
	return texture;
}

Texture *TextureManager::get(int textureId) {
	return (textures)[textureId];
}

void TextureManager::unload(int textureId) {
	Texture *texture = textures[textureId];
	delete(texture);
	textures.erase(textureId);
}