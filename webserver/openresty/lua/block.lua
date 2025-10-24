-- block.lua

-- 将openresty的正则匹配函数绑定到本地变量减少全局查找开销
local ngx = ngx
local regex_match = ngx.re.match

-- 定义敏感文件
local sensitive_files = {
    "^/\\.(?!well-known)(env|git|gitignore|htaccess|hg|svn|bzr|editorconfig|npmrc|bashrc|bash_profile|bash_history|[^/]+)$",
    "composer\\.(json|lock)$",
    "package\\.json$",
    "yarn\\.lock$",
    "\\.(bak|old|swp|~$|sql|db|dump|php~|conf~|ini~|log~|pyc|pyo|sqlite)$",
    "^/(wp-config\\.php|config\\.php|settings\\.php|database\\.yml|secrets\\.yaml)$",
    "^/(\\.DS_Store|Thumbs\\.db|\\.idea|\\.vscode)$"
}

-- 获取当前请求的URI路径不包括查询字符串
local request_uri = ngx.var.uri or ""

for _, pattern in ipairs(sensitive_files) do
    if regex_match(request_uri, pattern, "ioj") then
        return ngx.exit(444)
    end
end
