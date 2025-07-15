-- 引入配置文件
require 'config'

-- 预加载常用函数，提高性能
local match = string.match
local ngxmatch = ngx.re.match
local unescape = ngx.unescape_uri
local get_headers = ngx.req.get_headers
local optionIsOn = function(options)
    return options == "on" and true or false
end

-- 从config.lua加载并初始化全局变量
logpath = logdir
rulepath = RulePath
UrlDeny = optionIsOn(UrlDeny)
PostCheck = optionIsOn(postMatch)
CookieCheck = optionIsOn(cookieMatch)
WhiteCheck = optionIsOn(whiteModule)
PathInfoFix = optionIsOn(PathInfoFix)
attacklog = optionIsOn(attacklog)
CCDeny = optionIsOn(CCDeny)
Redirect = optionIsOn(Redirect)

-- 获取客户端IP地址
function getClientIp()
    local IP = ngx.var.remote_addr
    if IP == nil then
        IP = "unknown"
    end
    return IP
end

-- 写文件函数
function write(logfile, msg)
    local fd = io.open(logfile, "ab")
    if fd == nil then return end
    fd:write(msg)
    fd:flush()
    fd:close()
end

-- 记录攻击日志
function log(method, url, data, ruletag)
    if attacklog then
        local realIp = getClientIp()
        local ua = ngx.var.http_user_agent
        local servername = ngx.var.server_name
        local time = ngx.localtime()
        local line
        if ua then
            line = realIp.." ["..time.."] \""..method.." "..servername..url.."\" \""..data.."\"  \""..ua.."\" \""..ruletag.."\"\n"
        else
            line = realIp.." ["..time.."] \""..method.." "..servername..url.."\" \""..data.."\" - \""..ruletag.."\"\n"
        end
        local filename = logpath..'/'..servername.."_"..ngx.today().."_sec.log"
        write(filename, line)
    end
end

-- 读取规则文件函数
function read_rule(var)
    local file = io.open(rulepath..'/'..var, "r")
    if file == nil then
        return
    end
    local t = {}
    for line in file:lines() do
        table.insert(t, line)
    end
    file:close()
    return(t)
end

-- 加载所有规则到内存
urlrules = read_rule('url')
argsrules = read_rule('args')
uarules = read_rule('user-agent')
wturlrules = read_rule('whiteurl')
postrules = read_rule('post')
ckrules = read_rule('cookie')

-- 显示拦截页面
function say_html()
    if Redirect then
        ngx.header.content_type = "text/html"
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.say(html)
        ngx.exit(ngx.status)
    end
end

-- URL白名单检查
function whiteurl()
    if WhiteCheck and wturlrules then
        for _, rule in pairs(wturlrules) do
            if ngxmatch(ngx.var.uri, rule, "isjo") then
                return true
            end
        end
    end
    return false
end

-- 文件上传黑名单检查
function fileExtCheck(ext)
    local items = Set(black_fileExt)
    ext = string.lower(ext)
    if ext then
        for rule in pairs(items) do
            if ngx.re.match(ext, rule, "isjo") then
                log('POST', ngx.var.request_uri, "-", "file attack with ext "..ext)
                say_html()
            end
        end
    end
    return false
end

-- 将table转换为set，提高查询效率
function Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

-- URL参数检查
function args()
    if argsrules == nil then return false end
    for _, rule in pairs(argsrules) do
        local args = ngx.req.get_uri_args()
        for key, val in pairs(args) do
            local data
            if type(val) == 'table' then
                local t = {}
                for k, v in pairs(val) do
                    if v == true then
                        v = ""
                    end
                    table.insert(t, v)
                end
                data = table.concat(t, " ")
            else
                data = val
            end
            if data and type(data) ~= "boolean" and rule ~= "" and ngxmatch(unescape(data), rule, "isjo") then
                log('GET', ngx.var.request_uri, "-", rule)
                say_html()
                return true
            end
        end
    end
    return false
end

-- URL路径检查
function url()
    if UrlDeny and urlrules then
        for _, rule in pairs(urlrules) do
            if rule ~= "" and ngxmatch(ngx.var.request_uri, rule, "isjo") then
                log('GET', ngx.var.request_uri, "-", rule)
                say_html()
                return true
            end
        end
    end
    return false
end

-- UserAgent检查
function ua()
    if uarules == nil then return false end
    local ua = ngx.var.http_user_agent
    if ua ~= nil then
        for _, rule in pairs(uarules) do
            if rule ~= "" and ngxmatch(ua, rule, "isjo") then
                log('UA', ngx.var.request_uri, "-", rule)
                say_html()
                return true
            end
        end
    end
    return false
end

-- POST内容检查
function body(data)
    if postrules == nil then return false end
    for _, rule in pairs(postrules) do
        if rule ~= "" and data ~= "" and ngxmatch(unescape(data), rule, "isjo") then
            log('POST', ngx.var.request_uri, data, rule)
            say_html()
            return true
        end
    end
    return false
end

-- Cookie检查
function cookie()
    if CookieCheck and ckrules then
        local ck = ngx.var.http_cookie
        if ck then
            for _, rule in pairs(ckrules) do
                if rule ~= "" and ngxmatch(ck, rule, "isjo") then
                    log('Cookie', ngx.var.request_uri, "-", rule)
                    say_html()
                    return true
                end
            end
        end
    end
    return false
end

-- CC攻击防御检查
function denycc()
    if CCDeny then
        local uri = ngx.var.uri
        local CCcount = tonumber(string.match(CCrate, '(.*)/'))
        local CCseconds = tonumber(string.match(CCrate, '/(.*)'))
        local token = getClientIp()..uri
        local limit = ngx.shared.limit
        local req, _ = limit:get(token)
        if req then
            if req > CCcount then
                ngx.exit(503)
                return true
            else
                limit:incr(token, 1)
            end
        else
            limit:set(token, 1, CCseconds)
        end
    end
    return false
end

-- 获取POST上传文件的边界
function get_boundary()
    local header = get_headers()["content-type"]
    if not header then
        return nil
    end

    if type(header) == "table" then
        header = header[1]
    end

    local m = match(header, ";%s*boundary=\"([^\"]+)\"")
    if m then
        return m
    end

    return match(header, ";%s*boundary=([^\",;]+)")
end

-- IP白名单检查
function whiteip()
    if next(ipWhitelist) ~= nil then
        for _, ip in pairs(ipWhitelist) do
            local ok, err = ngx.re.match(getClientIp(), "^"..ip, "jo")
            if err then
                ngx.log(ngx.ERR, "invalid ip cidr while checking whiteip: ", ip, " err: ", err)
            elseif ok then
                return true
            end
        end
    end
    return false
end

-- IP黑名单检查
function blockip()
    if next(ipBlocklist) ~= nil then
        for _, ip in pairs(ipBlocklist) do
            local ok, err = ngx.re.match(getClientIp(), "^"..ip, "jo")
            if err then
                ngx.log(ngx.ERR, "invalid ip cidr while checking blockip: ", ip, " err: ", err)
            elseif ok then
                ngx.exit(403)
                return true
            end
        end
    end
    return false
end