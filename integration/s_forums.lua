--PIXOTA

function GetThreadID() -- finds the smallest ID in the SQL instead of auto increment
	local resultt = mysql:forum_query_fetch_assoc("SELECT tid FROM mybbam_threads WHERE firstpost = 0 ORDER BY tid DESC LIMIT 1")
	if resultt then
		local idt = tonumber(resultt["tid"]) or nil
		return idt
	end
	return false
end

function GetPostID() -- finds the smallest ID in the SQL instead of auto increment
	local resultp = mysql:forum_query_fetch_assoc("SELECT pid FROM mybbam_posts WHERE tid = 0 ORDER BY pid DESC LIMIT 1")
	if resultp then
		local idp = tonumber(resultp["pid"]) or nil
		return idp
	end
	return false
end

function getForumPostCount(forumID)
	local resultp = mysql:forum_query_fetch_assoc("SELECT posts FROM mybbam_forums WHERE fid = " .. forumID .. " ORDER BY posts DESC LIMIT 1")
	if resultp then
		local idp = tonumber(resultp["posts"]) or nil
		return idp
	end
	return false
end

function getForumThreadCount(forumID)
	local resultp = mysql:forum_query_fetch_assoc("SELECT threads FROM mybbam_forums WHERE fid = " .. forumID .. " ORDER BY threads DESC LIMIT 1")
	if resultp then
		local idp = tonumber(resultp["threads"]) or nil
		return idp
	end
	return false
end

function createForumThread(thePlayer, poster, createInForumID, fTitle, fContent, MsgToPlayer, alertStaff)
	--local posterUsername = string.gsub(getElementData(poster, "account:username"), "_", " ")
	local posterUsername = 'Automatic Logger'--exports.mysql:escape_string(posterUsername)
	local posterID = 50--getElementData(poster, "account:id")
	
	fTitle = mysql:escape_string(fTitle)
	local content = "<center>[SIZE=6]"..fTitle.."[/SIZE]</center>[hr]"..fContent
	content = mysql:escape_string(content)
	
	--local first = exports.mysql:forum_query_insert_free("INSERT INTO xf_post SET like_users = '0', thread_id = '0', username = '"..posterUsername.."', user_id = '"..posterID.."', post_date = unix_timestamp(), message = '"..content.."', ip_id = '0', message_state = 'visible', position = '0'")
	local first = exports.mysql:forum_query_insert_free("INSERT INTO mybbam_posts SET tid='0', username='" .. posterUsername.. "', subject='" .. fTitle .. "', uid='" .. posterID.. "', dateline=unix_timestamp(), message='"..content.."', visible='1'")
	local firstID = GetPostID()
	
	--local second = exports.mysql:forum_query_insert_free("INSERT INTO xf_thread SET title = '" .. fTitle .. "', first_post_id = '0', last_post_date = unix_timestamp(), post_date = unix_timestamp(), node_id = '29', username = '"..posterUsername.."', user_id = '"..posterID.."', last_post_id = '0', last_post_username = '"..posterUsername.."', last_post_user_id = '"..posterID.."'")
	local second = exports.mysql:forum_query_insert_free("INSERT INTO mybbam_threads SET subject='" .. fTitle .. "', firstpost='0', lastpost=unix_timestamp(), dateline=unix_timestamp(), username='" .. posterUsername .. "', lastposter='" .. posterUsername .."', uid='" .. posterID .. "', lastposteruid='" .. posterID .. "', fid='" .. createInForumID .. "'")
	local secondID = GetThreadID()
	
	--exports.mysql:forum_query_free("UPDATE xf_post SET thread_id = '"..secondID.."' WHERE post_id = '"..firstID.."'")
	exports.mysql:forum_query_free("UPDATE mybbam_posts SET tid='" .. secondID .. "' WHERE pid='" .. firstID .. "'")
	
	--exports.mysql:forum_query_free("UPDATE xf_thread SET first_post_id = '"..firstID.."' AND last_post_id = '"..firstID.."' WHERE thread_id = "..secondID.."")
	exports.mysql:forum_query_free("UPDATE mybbam_threads SET firstpost='" .. firstID .. "' WHERE tid='" .. secondID .. "'")
	
	local totalPosts = getForumPostCount(createInForumID) + 1
	local totalThreads = getForumThreadCount(createInForumID) + 1
	exports.mysql:forum_query_free("UPDATE mybbam_forums SET threads='" .. totalThreads .. "', posts='" .. totalPosts .. "', lastpost=unix_timestamp(), lastposter='" .. posterUsername .. "', lastposteruid='" .. posterID .. "', lastposttid='" .. firstID .. "', lastpostsubject='" .. fTitle .. "' WHERE fid='" .. createInForumID .. "'")

	local totalPosts = getForumPostCount(102)
	local totalThreads = getForumThreadCount(102)
	exports.mysql:forum_query_free("UPDATE mybbam_forums SET threads='" .. totalThreads .. "', posts='" .. totalPosts .. "', lastpost=unix_timestamp(), lastposter='" .. posterUsername .. "', lastposteruid='" .. posterID .. "', lastposttid='" .. firstID .. "', lastpostsubject='" .. fTitle .. "' WHERE fid='102'")
	
	if MsgToPlayer then
		outputChatBox(MsgToPlayer..". URL: https://projectreality.site/showthread.php?tid="..secondID, thePlayer)
		--outputChatBox(MsgToPlayer..". URL: http://projectreality.cf/index.php?threads/"..secondID, thePlayer)
	end
	
	if alertStaff then
		exports.global:sendWrnToStaff(alertStaff..". URL: https://projectreality.site/showthread.php?tid="..secondID, "NPC")
		--exports.global:sendWrnToStaff(alertStaff..". URL: http://projectreality.cf/index.php?threads/"..secondID, "NPC")
	end
	return "https://projectreality.site/showthread.php?tid="..secondID
	--return "http://projectreality.cf/index.php?threads/"..secondID
end

function testShit()
	outputDebugString("test")
	createForumThread(1, 1, 103, "Test", "Pixota loves testing")
end
addCommandHandler("pixotatest", testShit, false, false)