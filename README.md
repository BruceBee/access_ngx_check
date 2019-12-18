# access_ngx_check
openrestry Access control

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
