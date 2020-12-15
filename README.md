# access_ngx_check
openresty Access control policy. It includes counter、leaky bucket algorithm and token bucket algorithm .

## Introduce
In order to keep the service running normally, we use lua scripts to control user requests in a hierarchical way,  
For example:  

to Counter:
If the number of requests in 10s reaches 1000, 20% of random requests will be rejected,  
If the number of requests in 10s reaches 2000, 40% of random requests will be rejected.  

And so on.  
You can customize any of the above parameters.  


## Precondition
Make sure you have openresty installed and we will replace nginx


## Usage
nginx.conf

```
...

location / {
        default_type application/json;
        lua_code_cache on;
       
        # Counter
        rewrite_by_lua_file /usr/local/openresty/nginx/conf/lua/Counter.lua;
        
        # leaky bucket
        # rewrite_by_lua_file /usr/local/openresty/nginx/conf/lua/LeakyBucket.lua;
        
        # token bucket
        # rewrite_by_lua_file /usr/local/openresty/nginx/conf/lua/tokenBucket.lua;
        
        proxy_pass http://xxxx;
    }
...
```
