-- 引入limit.req库，实现令牌桶算法
local limit_req = require "resty.limit.req"

-- 允许的平均速率为每秒20个请求
local rate = 20
-- 允许的瞬时并发请求数为10个
local burst = 10

-- 实例化限速器
-- 使用配置中定义的共享内存limit_req_store
local lim, err = limit_req.new("limit_req_store", rate, burst)
if not lim then
    ngx.log(ngx.ERR, "ddos: failed to instantiate resty.limit.req: ", err)
    -- 如果库初始化失败，为防止服务不可用，返回500错误
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- 获取客户端的真实IP地址
local key = ngx.var.http_x_real_ip or ngx.var.remote_addr

-- 对当前请求进行检查
local delay, excess = lim:incoming(key, true)

-- 如果excess > 0，说明请求速率过快，令牌桶已空
if excess then
    ngx.log(ngx.WARN, "ddos_guard: blocking request from IP: ", key, ", requests exceeded limit. ",
            "rate: ", rate, "/s, burst: ", burst)
    -- 直接拒绝请求，返回 429 Too Many Requests
    return ngx.exit(429)
end

-- 在速率限制内但需要等待的合法突发请求
if delay > 0 then
    -- 异步休眠，平滑后端服务器的压力
    ngx.sleep(delay)
end

-- 请求合法，继续后续处理流程