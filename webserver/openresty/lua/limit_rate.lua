-- Description: This script implements a token bucket rate limiter to control request rates and ease ddos attacks.
--
-- Copyright (c) 2025 honeok <honeok@disroot.org>
--                           <i@honeok.com>
--
-- SPDX-License-Identifier: Apache-2.0

-- 引入limit.req库，实现令牌桶算法
local limit_req = require "resty.limit.req"

-- 允许的平均速率为每秒20个请求
local rate = 20
-- 允许的瞬时并发请求数为10个
local burst = 10

-- 实例化限速器，使用配置中定义的共享内存limit_req_store
local lim, err = limit_req.new("limit_req_store", rate, burst)
if not lim then
    ngx.log(ngx.ERR, "limit rate: failed to instantiate resty.limit.req: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- 获取客户端真实IP
local key = ngx.var.http_x_real_ip or ngx.var.http_cf_connecting_ip or ngx.var.http_do_cf_connecting_ip or ngx.var.remote_addr

-- 对当前请求进行检查
local delay, excess = lim:incoming(key, true)
if not delay then
    ngx.log(ngx.ERR, "limit rate: failed to process request for IP: ", key, ", error: ", excess)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- 如果excess > 0，说明请求速率过快，令牌桶已空
if excess > 0 then
    ngx.log(ngx.WARN, "limit rate: blocking request from IP: ", key, ", requests exceeded limit. ",
            "rate: ", rate, "/s, burst: ", burst)
    -- 设置Retry-After响应头，提示客户端等待时间
    ngx.header["Retry-After"] = math.ceil(delay)
    return ngx.exit(429)
end

-- 在速率限制内但需要等待的合法突发请求
if delay > 0 then
    -- 异步休眠，平滑后端服务器的压力
    ngx.sleep(delay)
end

-- 请求合法，继续后续处理流程
return ngx.exec('@proxy')