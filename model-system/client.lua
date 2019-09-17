addEventHandler( "onClientResourceStart", resourceRoot,
function()
		local texture = dxCreateTexture ( "images/black.png", "dxt5" )
        local shader = dxCreateShader ( "texture.fx" )
        dxSetShaderValue ( shader, "gTexture", texture )
        engineApplyShaderToWorldTexture ( shader, "orange2" )
end)

addEventHandler( "onClientResourceStart", resourceRoot,
function()
		local texture = dxCreateTexture ( "images/logo.png", "dxt5" )
        local shader = dxCreateShader ( "texture.fx" )
        dxSetShaderValue ( shader, "gTexture", texture )
        engineApplyShaderToWorldTexture ( shader, "papercuts" )
end)

addEventHandler ( "onClientResourceStart", resourceRoot,
    function ( )
        local shader = dxCreateShader( "nodirt-shader.fx" )
        engineApplyShaderToWorldTexture( shader, "vehiclegrunge*" )
    end
)

addEventHandler( "onClientResourceStart", resourceRoot,
function()
		local texture = dxCreateTexture ( "images/fd.png", "dxt5" )
        local shader = dxCreateShader ( "texture.fx" )
        dxSetShaderValue ( shader, "gTexture", texture )
        engineApplyShaderToWorldTexture ( shader, "sfpd" )
end)

addEventHandler( "onClientResourceStart", resourceRoot,
function()
		local texture = dxCreateTexture ( "images/fd2.png", "dxt5" )
        local shader = dxCreateShader ( "texture.fx" )
        dxSetShaderValue ( shader, "gTexture", texture )
        engineApplyShaderToWorldTexture ( shader, "sw_med01" )
end)

addEventHandler( "onClientResourceStart", resourceRoot,
function()
		local texture = dxCreateTexture ( "images/doj.png", "dxt5" )
        local shader = dxCreateShader ( "texture.fx" )
        dxSetShaderValue ( shader, "gTexture", texture )
        engineApplyShaderToWorldTexture ( shader, "mp_pinemedical" )
end)

addEventHandler( "onClientResourceStart", resourceRoot,
function()
		local texture = dxCreateTexture ( "images/astro.png", "dxt5" )
        local shader = dxCreateShader ( "texture.fx" )
        dxSetShaderValue ( shader, "gTexture", texture )
        engineApplyShaderToWorldTexture ( shader, "bobobillboard1" )
end)


