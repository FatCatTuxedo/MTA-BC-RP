addEventHandler( "onClientResourceStart", resourceRoot,
    function()

        as = dxCreateTexture ( "pd.png" )
        asshader = dxCreateShader( "as.fx" )
        engineApplyShaderToWorldTexture ( asshader, "vehiclepoldecals128" )
		engineApplyShaderToWorldTexture ( asshader, "ambulan92decal128" )
        dxSetShaderValue ( asshader, "asTexture", as )   
    end
    )