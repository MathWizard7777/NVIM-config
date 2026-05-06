local uv = vim.loop

print("entered comp-connect init file")

local function start_competitive_server()
  print("starting competetive server")
  local server = uv.new_tcp()
  local port = 27121

  server:bind("127.0.0.1", port)
  server:listen(128, function(err)
    if err then return end
    
    local client = uv.new_tcp()
    server:accept(client)
    
    local request_data = ""

    print("listening?!")
    
    client:read_start(function(read_err, chunk)
      if read_err then return end
      
      if chunk then
        request_data = request_data .. chunk

        print("got data?!!")
        
        -- Check if we received the full HTTP request (ends with double CRLF if no body, 
        -- but we need to ensure the body is fully received for POST)
        if string.find(request_data, "\r\n\r\n") then
          -- Separate HTTP headers from JSON body
          local _, body_start = string.find(request_data, "\r\n\r\n")
          local json_body = string.sub(request_data, body_start + 1)
          
          -- Safely decode JSON
          local success, data = pcall(vim.fn.json_decode, json_body)
          if success and data and data.tests then
            
            -- Schedule file writing on the main Neovim thread
            vim.schedule(function()
              -- Create a clean directory name from the problem title
              local dir_name = data.name:gsub("[%s/\\?%%*:|\"<>]", "_")
              vim.fn.mkdir(dir_name, "p")
              
              -- Write each test case
              for i, test in ipairs(data.tests) do
                local input_file = io.open(dir_name .. "/input" .. i .. ".txt", "w")
                if input_file then
                  input_file:write(test.input)
                  input_file:close()
                end
                
                local output_file = io.open(dir_name .. "/output" .. i .. ".txt", "w")
                if output_file then
                  output_file:write(test.output)
                  output_file:close()
                end
              end
              
              print("🎉 Successfully saved " .. #data.tests .. " test cases to folder: " .. dir_name)
            end)
            
            -- Send HTTP 200 OK response back to the extension
            local response = "HTTP/1.1 200 OK\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
            client:write(response)
            client:close()
          end
        end
      else
        client:close()
      end
    end)
  end)
end

-- Start the server automatically
start_competitive_server()