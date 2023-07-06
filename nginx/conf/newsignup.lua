local mysql = require "resty.mysql"                                                                                                                                                                        
local json = require "cjson"                                                                                                                                                                               
                                                                                                                                                                                                           
local function create_mysql_connection()                                                                                                                                                                   
    local mysql_config = globe_config.mysql
    local db, err = mysql:new()
    if not db then
        ngx.log(ngx.ERR, "Failed to create MySQL connection: ", err)
        return nil, err
    end
    local ok, err = db:connect(mysql_config)

    if not ok then
        ngx.say("Failed to connect to MySQL: ", err)
        db:close()
        return nil, err
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
