texShader = dxCreateShader ( "shader/texreplace.fx" )
plateback3 = dxCreateTexture("generic/plateback3.png")


dxSetShaderValue(texShader,"gTexture",plateback3)
engineApplyShaderToWorldTexture(texShader,"plateback1")
engineApplyShaderToWorldTexture(texShader,"plateback2")
engineApplyShaderToWorldTexture(texShader,"plateback3")
