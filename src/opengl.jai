gl_create_texture :: (width: u32, height: u32) -> u32
{
    format: GLenum = GL_RGBA;
    texture_id: u32;
	glGenTextures(1, *texture_id);
    glBindTexture(GL_TEXTURE_2D, texture_id);
    glTexImage2D(GL_TEXTURE_2D, 0, xx format, width, height, 0, format, GL_UNSIGNED_BYTE, null);

    return texture_id;
}

gl_create_texture_from_data :: (data: *u32, width: u32, height: u32) -> u32
{
    texture_id: u32;
	glGenTextures(1, *texture_id);

    if data 
    {
        format: GLenum = GL_RGBA;
        
        glBindTexture(GL_TEXTURE_2D, texture_id);
        glTexImage2D(GL_TEXTURE_2D, 0, xx format, xx width, xx height, 0, format, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    }

    return texture_id;
}

gl_update_texture :: (new_data: *u32, id: u32, width: u32, height: u32)
{
    // Bind the texture
    glBindTexture(GL_TEXTURE_2D, id);

    // Update the texture data
    format: GLenum = GL_RGBA;
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, xx width, xx height, format, GL_UNSIGNED_BYTE, new_data);

    // Unbind the texture
    glBindTexture(GL_TEXTURE_2D, 0);
}
