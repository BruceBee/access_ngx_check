local json = require "cjson";
local io = require("io");
local check = "on"
local count1 = 1000
local count2 = 2000
local count3 = 5000
local seconds = 10
local random_rate1 = 20
local random_rate2 = 50
local random_rate3 = 100
local err_data = {};
err_data['data'] = {};
err_data['err_code'] = 1101;
err_data['err_msg'] = '现在提交作业的人太多啦！请稍后再来';
local err_data_json = json.encode(err_data);
--local random_rate = math.random(1,100)
--math.randomseed(os.time())
--local random_rate = math.randomseed(tostring(os.time()):reverse():sub(1, 6))

function getParam()
    if "GET" == request_method then
        args = ngx.req.get_uri_args()
    elseif "POST" == request_method then
        ngx.req.read_body()
        args = ngx.req.get_post_args()
    end
    return args
end

function writerLog(str)
    local time = os.time()
    local date = os.date("%Y%m%d",time)
    local file = io.open("/usr/local/openresty/nginx/logs/"..tostring(date).."_log.log","a")
    --local file = io.open("/usr/local/openresty/nginx/logs/1.log","a")
    file:write(str.."\n")
    file:close();
end


function access_user_uri_check()
    if check == "on" then
        --local access_uri = ngx.var.host..ngx.var.uri
        --local access_uri = ngx.var.uri
        --local key = access_uri
        local limit = ngx.shared.limit
        local key = "request_count"
        local req

        math.randomseed(os.time())
        local random = math.random(1,100)
        if limit then
            req,_ = limit:get(key)
        end
        if req then
            if req >= count3 then
                if random < random_rate3 then
                    writerLog(key..":"..limit:get(key)) 
                    ngx.say(err_data_json)
                    ngx.exit(200)
                    return
                end
            end
            if req >= count2 then
                if random < random_rate2 then
                    writerLog(key..":"..limit:get(key))
                    ngx.say(err_data_json)
                    ngx.exit(200)
                    return
                end
            end
            if req >= count1 then
                if random < random_rate1 then
                    writerLog(key..":"..limit:get(key))
                    ngx.say(err_data_json)
                    ngx.exit(200)
                    return
                end
            end
            limit:incr(key,1)
        else
            limit:set(key,1,seconds)
        end
        writerLog(key..":"..limit:get(key))
    end

end

function myerrorhandler( err )
   ngx.say( "ERROR:", err )
end

status = xpcall( access_user_uri_check, myerrorhandler)
