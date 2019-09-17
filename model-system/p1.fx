texture p1Texture;
 
technique TexReplace
{
    pass P0
    {
        Texture[0] = p1Texture;
    }
}