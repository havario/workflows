-- block.lua

-- 绑定常用函数减少全局查找
local ngx = ngx
local re_find = ngx.re.find
local log = ngx.log
local warn = ngx.WARN
local exit = ngx.exit

-- 获取请求URI和请求行
local request_uri = ngx.var.uri or ""
local request_line = ngx.var.request or ""
local query_args = ngx.var.args or ""
local full_url = request_uri .. (query_args ~= "" and "?" .. query_args or "")
local http_host = ngx.var.http_host or ""

-- 白名单
if re_find(full_url, "[?&]src=https?://blog\\.honeok\\.com/", "ioj") then
    return
end

if re_find(request_uri, "^/wp-admin($|/)", "ioj") then
    return
end

-- 拦截乱码请求
if re_find(request_line, "[\\x00-\\x1F\\x7F-\\xFF]", "jo") then
    log(warn, "Blocked malformed request: " .. request_line .. " from " .. ngx.var.remote_addr)
    return exit(444)
end

-- 非法请求行检查
if not re_find(request_line, "^(GET|POST|HEAD|PUT|DELETE|OPTIONS|PATCH) ", "ioj") then
    log(warn, "Invalid request line: " .. request_line .. " from " .. ngx.var.remote_addr)
    return exit(444)
end

-- 合并所有注入攻击正则
local injection_patterns = {
    -- Shell
    "[\\;\\|\\&\\`\\$\\(\\)]|\\r|\\n|\\x00",
    -- SQL
    "('|\"|--|;|\\*/|@@|char|exec|insert|select|drop|union|from|where|order|group|having|--|\\\\)",
    -- XSS / JavaScript
    "(<script|javascript:|on\\w+=|alert\\(|eval\\(|document\\.|window\\.|\\x3Cscript)",
    "(\\.\\./|%2e%2e/|%00|<!ENTITY|<xml|&\\(|\\)\\(|\\*\\))",
    "(os\\.execute|load|eval|base64_(decode|encode)|[^a-zA-Z0-9\\-\\.]http_host)"
}

-- 检查所有注入
local check_str = full_url .. http_host
for _, pattern in ipairs(injection_patterns) do
    if re_find(check_str, pattern, "ioj") then
        log(warn, "Blocked injection attack: " .. full_url .. " from " .. ngx.var.remote_addr)
        return exit(444)
    end
end

-- 敏感文件正则列表
local sensitive_files = {
    "^/\\.(?!well-known)(env|git|gitignore|htaccess|hg|svn|bzr|editorconfig|npmrc|bashrc|bash_profile|bash_history|[^/]+)$",
    "\\.(json|lock|bak|old|swp|~|sql|db|dump|php~|conf~|ini~|log~|pyc|pyo|sqlite)$",
    "^/(wp-config\\.php|config\\.php|settings\\.php|database\\.yml|secrets\\.yaml|\\.DS_Store|Thumbs\\.db|\\.idea|\\.vscode)$"
}

-- 检查敏感文件
for _, pattern in ipairs(sensitive_files) do
    if re_find(request_uri, pattern, "ioj") then
        log(warn, "Blocked sensitive file: " .. request_uri .. " from " .. ngx.var.remote_addr)
        return exit(444)
    end
end
