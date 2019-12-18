# access_ngx_check
openrestry Access control

## Introduce
In order to keep the service running normally, we use lua scripts to control user requests in a hierarchical way,  
For example:  
If the number of requests in 10s reaches 1000, 20% of random requests will be rejected,  
If the number of requests in 10s reaches 2000, 40% of random requests will be rejected.  
  
And so on.  
You can customize any of the above parameters.  


## Preparatory
Make sure you have openrestry installed and we will replace nginx


## Usage
nginx.conf

```
...

location / {
        default_type application/json;
        lua_code_cache on;
       
        rewrite_by_lua_file /usr/local/openresty/nginx/conf/lua/access_ngx_check.lua;
        
        proxy_pass http://xxxx;
    }
...
```
