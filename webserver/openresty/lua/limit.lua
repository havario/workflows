-- limit.lua

local limit_conn = require "resty.limit.conn"
local limit_req = require "resty.limit.req"

local ngx = ngx

-- 配置参数
-- 连接数限制
local CONN_SHM_NAME = "conn_limit_shm"  -- 共享内存名称
local CONN_LIMIT = 20                   -- 每个IP允许的最大并发连接数
local CONN_DELAY = 0                    -- 连接数超限不等待，直接拒绝 0: 拒绝 >0: 延迟

-- 请求速率限制
local REQ_SHM_NAME = "req_limit_shm"    -- 共享内存名称
local REQ_RATE = 50                     -- 允许的平均速率: 每秒50个请求
local REQ_BURST = 20                    -- 允许的突发请求数: 额外20个
local REQ_DURATION = 1                  -- 周期(秒)

-- 状态码
local TOO_MANY_REQUESTS = 503
local RETRY_AFTER_SECONDS = 1

-- 实例化限流
local conn_lim = limit_conn.new(CONN_SHM_NAME)
local req_lim = limit_req.new(REQ_SHM_NAME)

-- 确保实例化成功
if not conn_lim or not req_lim then
    ngx.log(ngx.ERR, "Failed to instantiate limit objects.")
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- 获取客户端IP作为限流键
local client_ip = ngx.var.remote_addr

if not client_ip then
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- 连接频率限制
local conn_status, conn_err = conn_lim:incoming(client_ip, CONN_LIMIT, CONN_DELAY)

if not conn_status then
    ngx.log(ngx.ERR, "lim:conn:incoming failed: ", conn_err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if conn_status == 2 or conn_status == 1 then -- 2: 拒绝 1: 延迟
    -- 如果超过连接数限制直接拒绝
    ngx.log(ngx.WARN, "Conn limit exceeded for IP: ", client_ip)
    ngx.header["Retry-After"] = RETRY_AFTER_SECONDS
    return ngx.exit(TOO_MANY_REQUESTS)
end

-- 请求频率限制
local req_delay_or_reject, req_err = req_lim:incoming(client_ip, REQ_RATE * REQ_DURATION, REQ_BURST * REQ_DURATION, REQ_DURATION)

if not req_delay_or_reject then
    ngx.log(ngx.ERR, "lim:req:incoming failed: ", req_err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- 如果超过请求速率限制，(返回值 >0 表示延迟或拒绝) 直接拒绝
if req_delay_or_reject > 0 then
    ngx.log(ngx.WARN, "Rate limit exceeded for IP: ", client_ip)
    ngx.header["Retry-After"] = RETRY_AFTER_SECONDS
    return ngx.exit(TOO_MANY_REQUESTS)
end

return
