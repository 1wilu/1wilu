local mysql = require "resty.mysql"                                                                                                                                                                        
local json = require "cjson"                                                                                                                                                                               
                                                                                                                                                                                                           
local function create_mysql_connection()                                                                                                                                                                   
    local db, err = mysql:new()                                                                                                                                                                            
    if not db then                                                                                                                                                                                         
        ngx.log(ngx.ERR,"failed to create mysql connextion:",err)                                                                                                                                          
        return nil,err                                                                                                                                                                                     
    end                                                                                                                                                                                                    
    local ok, err = db:connect{                                                                                                                                                                            
        host = "10.0.2.15",                                                                                                                                                                                
        port = 13306,                                                                                                                                                                                      
        database = "app",                                                                                                                                                                                  
        user = "root",                                                                                                                                                                                     
        password = "1234567",                                                                                                                                                                              
        charset = "utf8mb4",                                                                                                                                                                               
    }                                                                                                                                                                                                      
                                                                                                                                                                                                           
    if not ok then                                                                                                                                                                                         
        ngx.say("connect mysql failed:", err)                                                                                                                                                              
        db:close()                                                                                                                                                                                         
        return nil,err                                                                                                                                                                                     
    end                                                                                                                                                                                                    
    return db                                                                                                                                                                                              
end                                                                                                                                                                                                        
                                                                                                                                                                                                           
local function signup_handler()                                                                                                                                                                            
                                                                                                                                                                                                           
    ngx.req.read_body()                                                                                                                                                                                    
    local arg = ngx.req.get_post_args()                                                                                                                                                                    
                                                                                                                                                                                                           
    local username = arg.username                                                                                                                                                                          
    local password = arg.password                                                                                                                                                                          
    local repassword = arg.repassword                                                                                                                                                                      
                                                                                                                                                                                                           
    if not (username and password and repassword) then                                                                                                                                                     
        ngx.status = ngx.HTTP_BAD_REQUEST                                                                                                                                                                  
        ngx.say(json.encode({code = 1, msg = "Invalid parameters"}))                                                                                                                                       
        return                                                                                                                                                                                             
    end                                                                                                                                                                                                    
                                                                                                                                                                                                           
    if password ~= repassword then                                                                                                                                                                         
        ngx.status = ngx.HTTP_BAD_REQUEST                                                                                                                                                                  
        ngx.say(json.encode({code = 1, msg = "Passwords do not match"}))                                                                                                                                   
        return                                                                                                                                                                                             
    end                                                                                                                                                                                                   
     ngx.say(json.encode({code = 1, msg = username}))   
		ngx.say(json.encode({code = 1, msg = password}))   
		ngx.say(json.encode({code = 1, msg = repassword}))   

     local db, err = create_mysql_connection()                                                                                                                                                             
     if not db then                                                                                                                                                                                        
         ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR                                                                                                                                                       
         ngx.say(json.encode({ code = 1, msg = "Failed to connect to the database" }))                                                                                                                     
         ngx.log(ngx.ERR, "Failed to connect to the database: ", err)                                                                                                                                      
         return                                                                                                                                                                                            
     end                                                                                                                                                                                                                                                                                                                                                                                                   
    local userid = ngx.now()      

   local sqlstr = [[select * from user where username = "]] ..username..[["]]
      local res, err = db:query(sqlstr)
      if not res then
          ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
          ngx.say(json.encode({code = 1, msg = "failed to execute query"}))
          ngx.log(ngx.ERR,"failed to execute query")
          return
      end
    
    if #res > 0 then
        ngx.say(json.encode({code = 1, msg = "user already exist"}))
        return
    end
    sql = [[insert into user (user_id, username, password) values ( ]]..userid.. [[,"]] ..username..[[",]]..password..[[)]]                                                                                                                                                                                                       
    --local sql = "insert into user (user_id, username, password) values ("..userid..","..ngx.quote_sql_str(username)..","..ngx.quote_sql_str(password)..")"                                               
    ngx.say(json.encode({code = 1, msg = sql}))                                                                                                                                                                                                        
    --local sql = [[insert into user (user_id, username, password) values (23456,"ananimal","1234567")]]                                                                                                     
    local res, err = db:query(sql)                                                                                                                                                             
    if not res then                                                                                                                                                                                        
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR                                                                                                                                                        
        ngx.say(json.encode({code = 1, msg = "failed to save user"}))                                                                                                                                      
        ngx.log(ngx.ERR,"failed to save user")                                                                                                                                                             
        return                                                                                                                                                                                             
    end                                                                                                                                                                                                    
    ngx.log(ngx.INFO,"User registered:,",username)                                                                                                                                                         
    ngx.say(json.encode({code = 2, msg = "user resistered successfully"}))                                                                                                                                 
end                                                                                                                                                                                                        
                                                                                                                                                                                                           
ngx.req.read_body()                                                                                                                                                                                        
local uri_args = ngx.req.get_uri_args()                                                                                                                                                                                                                                                                                                                                                                
if ngx.req.get_method() == "POST" and uri_args and uri_args.action == "signup" then                                                                                                                        
    signup_handler()                                                                                                                                                                                       
else                                                                                                                                                                                                       
    ngx.status = ngx.HTTP_NOT_FOUND                                                                                                                                                                        
    ngx.say("page not found")                                                                                                                                                                              
end                                    
