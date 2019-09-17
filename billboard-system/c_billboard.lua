--requestBrowserDomains({ "projectreality.site" })

function dxDrawImage3D(x,y,z,w,h,m,c,r,...)
        local lx, ly, lz = x+w, y+h, (z+tonumber(r or 0)) or z
    return dxDrawMaterialLine3D(x,y,z, lx, ly, lz, m, h, c , ...)
end

local webBrowser = createBrowser(848, 480, false, false)

function webBrowserRender()
	local x, y = 2128.1, -1782.5
	setBrowserVolume(webBrowser, 0)
	dxDrawMaterialLine3D(x, y, 33.166, x, y, 27, webBrowser, 17, tocolor(255, 255, 255, 255), x-180, y, 19)
end

function showBrowser()
	addEventHandler("onClientPreRender", root, webBrowserRender)
end
addEvent("billboard:show", true)
addEventHandler("billboard:show", getRootElement(), showBrowser)

function loadURL(link)
	loadBrowserURL(webBrowser, link)
end
addEvent("billboard:loadLink", true)
addEventHandler("billboard:loadLink", getRootElement(), loadURL)

function destroyBrowser()
	loadBrowserURL(webBrowser, "https://www.youtube.com/tv#/watch/video/idle?v=lf_wVfwpfp8")
	removeEventHandler("onClientPreRender", root, webBrowserRender)
	setBrowserVolume(webBrowser, 0)
end
addEvent("billboard:destroyBrowser", true)
addEventHandler("billboard:destroyBrowser", getRootElement(), destroyBrowser)