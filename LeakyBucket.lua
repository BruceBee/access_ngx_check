local redis = require "resty.redis";
local json = require "cjson";
local red = redis:new();

-- 流速/s
local flowRate = 5

-- 漏桶规模
local bucketSize = 5

-- 最后释放时间
local lastTimeKey = "lastTime"

-- 剩余水量
local leftStorgeKey = "leftStorge"


local err_data = {};
err_data['data'] = {};

red:set_timeout(2);

local ok, err = red:connect("127.0.0.1", 6379);

-- 漏桶释放
function refresh(red)
    local now = os.time()
    local lastTime = red:get(lastTimeKey)
    local f,m = math.modf((now - lastTime)*flowRate)
    local leftStorge = math.max(0, red:get(leftStorgeKey) - f )
    
    red:set(leftStorgeKey, leftStorge)
    red:set(lastTimeKey, now)
end


if not ok then
    ngx.log(ngx.INFO,  "connnect " .. err)
else
    -- 先释放流量
    refresh(red)

    -- 获取当前漏桶内剩余水量
    local currStorge, err = red:get(leftStorgeKey)
   
    
    -- 如果水桶已满
    if tonumber(currStorge) > bucketSize  then
        err_data['err_code'] = 1101;
        err_data['err_msg'] = '当前请求太多啦！请稍后再来';
        local err_data_json = json.encode(err_data);
        ngx.say(err_data_json)
    else
        -- 水桶未满，+1
        red:incr(leftStorgeKey)
        err_data['err_code'] = 0;
        err_data['err_msg'] = '剩余水量:'..currStorge;
        local err_data_json = json.encode(err_data);
        ngx.say(err_data_json)
    end
end

