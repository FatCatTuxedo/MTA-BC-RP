texture asTexture;
 
technique TexReplace
{
    pass P0
    {
        Texture[0] = asTexture;
    }
}