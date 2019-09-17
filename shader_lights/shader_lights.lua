texShader = dxCreateShader ( "shader/texreplace.fx" )
vehiclelights128 = dxCreateTexture("img/generic/vehiclelights128.png")
vehiclelightson128 = dxCreateTexture("generic/vehiclelightson128.png")

dxSetShaderValue(texShader,"gTexture",vehiclelights128)
engineApplyShaderToWorldTexture(texShader,"vehiclelights128")

dxSetShaderValue(texShader,"gTexture",vehiclelightson128)
engineApplyShaderToWorldTexture(texShader,"vehiclelightson128")

