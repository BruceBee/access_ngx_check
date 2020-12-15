local redis = require "resty.redis";
local json = require "cjson";
local red = redis:new();

-- 令牌放入/s
local tokenRate = 5

-- 令牌桶规模
local bucketSize = 20

-- 最后存放令牌时间
local lastTimeKey = "lastTime"

-- 剩余token数
local leftTokenKey = "leftToken"


local err_data = {};
err_data['data'] = {};

red:set_timeout(2);

local ok, err = red:connect("127.0.0.1", 6379);


-- 生成令牌
function  addToken(red)
    local now = os.time()
    local lastTime = red:get(lastTimeKey)
    local f,m = math.modf((now - lastTime)*tokenRate)

    -- 先添加令牌,最多就是桶满
    local leftToken = math.min(bucketSize, red:get(leftTokenKey) + f)

    red:set(lastTimeKey, now)
    red:set(leftTokenKey, leftToken)
end

if not ok then
    ngx.log(ngx.INFO,  "connnect " .. err)
else
    -- 先添加令牌
    addToken(red)
    local currToken, err = red:get(leftTokenKey)

    if tonumber(currToken) < 1 then
        -- 当前没有令牌了
        err_data['err_code'] = 1101;
        err_data['err_msg'] = '现在请求太多啦！请稍后再来';
        local err_data_json = json.encode(err_data);
        ngx.say(err_data_json)
    else
	    -- 还有令牌，令牌减一
        red:decr(leftTokenKey)
    end
end

