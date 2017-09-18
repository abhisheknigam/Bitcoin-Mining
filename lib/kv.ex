defmodule KV1 do 
  use GenServer

  def main(args) do
    args |> parse_args 
    #|> process
  end
  def process([]) do
      IO.puts "No arguments given"
  end
  
  def process(options) do
      IO.puts "Hello #{options[:name]}"
      c = options[:name]      
  end
   
  # def start_link do
  #   #Task.start_link(fn -> loop(%{}) end)
  #   # parent = self()
  #   #Task.start_link(fn -> sendMsg(parent) end)
  #   #get_str_from_server()
  #   IO.puts "keyurr "

  #   for x <- 0..20000 do
  #     Task.async(fn ->
  #       pid1 = spawn fn -> KV.get_str_from_server() end 
  #       IO.inspect (pid1)       
  #     end)
      
  #   end  
      
  #   IO.puts "keyurr end "
  #   pid1 = spawn fn -> KV.get_str_from_server() end
  #   IO.inspect (pid1)
  #   pid2 = spawn get_str_from_server
  #   IO.inspect (pid2) 
  # end

  def get_str_from_server(server_name) do
    
        {:news,str,size} = GenServer.call({:chat_room2,String.to_atom(server_name)},{:print_message,"karan"},:infinity)
        {:p_val,ret,hashed} = process_sha_256(str,size)  
        if(ret == "") do
          #GenServer.cast({:chat_room,:"karan@192.168.0.147"},{:print_answer,""})
        else 
          IO.puts "Found coin : "<>str
          GenServer.cast({:chat_room2,String.to_atom(server_name)},{:print_answer,{:p_val,ret,hashed}})
        end
      
    
    get_str_from_server(server_name)
  end

  def process_sha_256(str,l) do
    hashed = :crypto.hash(:sha256,str) |> Base.encode16
    
    #IO.puts "#{hashed}"
    substr = String.slice hashed, 0..l-1
    #IO.puts "#{substr}"
    substr_chck = String.duplicate("0",l)
    #IO.puts "#{substr_chck}"
    if substr == substr_chck do      
      {:p_val,str,hashed}
    else
      {:p_val,"",""}
    end
  end

  def parse_args(args) do
      {options, _, _} = OptionParser.parse(args,
        switches: [name: :string]
      )
      #IO.puts "#{options[:name]}"
      
       #options
       #IO.puts("hello")
       ipaddr = to_string options[:name]
       if(String.contains?(ipaddr,".") == true) do
           
          start_client(ipaddr)
      else
          start_server(elem(Integer.parse(ipaddr),0)) 
      end
   end

   def start_serv(k) do
    GenServer.start_link(__MODULE__, k, name: :chat_room)
   end
   
  def start_server(k) do
    
    server_name = "keyur@"<>get_ip_addr
    IO.puts server_name<>":: server  will start"

    Node.start(String.to_atom(server_name))
    
    Node.self |> IO.puts
    Node.get_cookie |> IO.puts
    Node.set_cookie :"choco"
    Node.get_cookie |> IO.puts
    #Node.connect(:"karan@192.168.0.147") 
   

    #connection end


    IO.puts "server started "
    
    GenServer.start_link(__MODULE__, k, name: :chat_room)
    IO.puts "genserver started"
    call_from_server(server_name)
    IO.gets ""
  end

  def get_ip_addr do
    {:ok,lst} = :inet.getif() 
    x = elem(List.last(lst),0)    
    addr =  to_string(elem(x,0)) <> "." <>  to_string(elem(x,1)) <> "." <>  to_string(elem(x,2)) <> "." <>  to_string(elem(x,3))
    addr  
  end

  def start_client(server_ip) do
    #connection 
    k =  "keyur@" <> get_ip_addr
    
    IO.puts k<>":: node will start"

    Node.start(String.to_atom(k))
    
    Node.self |> IO.puts
    Node.get_cookie |> IO.puts
    Node.set_cookie :"choco"
    Node.get_cookie |> IO.puts
    server_name = "keyur@"<>server_ip
    IO.puts server_name
    Node.connect(String.to_atom(server_name)) 
   

    #connection end


      IO.puts "client started "
    
        for x <- 0..25 do

          pid1 = spawn fn -> KV.get_str_from_server(server_name) end 
         # IO.inspect (pid1) 
          # Task.async(fn ->
          #   pid1 = spawn fn -> KV.get_str_from_server(server_name) end 
          #   IO.inspect (pid1)       
          # end)
          
        end  
          
        IO.puts "keyurr end "
        get_str_from_server(server_name)
        #IO.inspect (pid1)
        
  end

  def call_from_server(server_name) do
    IO.puts "client started "
    

        for x <- 0..25 do
          pid1 = spawn fn -> KV.get_str_from_server(server_name) end 
          IO.inspect (pid1) 
          # Task.async(fn ->
          #   pid1 = spawn fn -> KV.get_str_from_server(server_name) end 
          #   IO.inspect (pid1)       
          # end)
          
        end  
          
        IO.puts "keyurr end "
        get_str_from_server(server_name)
      
  end

  ##server functions
    def init(count) do
      {:ok, count}
    end
    
    def add_message(message) do
      GenServer.cast(:chat_room2, {:add_message, message})
    end
    def slice(message) do
      GenServer.call(:chat_room2, {:slice_message, message})
    end
    def print_message(message) do
      GenServer.call(:chat_room2, {:print_message, message})
    end
    def print_answer(message) do
      GenServer.cast(:chat_room2, {:print_answer, message})
    end

    # server callbacks
    def handle_cast({:add_message ,new_message}, messages) do
      {:noreply, [new_message | messages]}
      end
      
    def generate_string do
      length=20
      cg_sub = :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, 20)
      cg_str = "karanacharekar;"<> cg_sub
    end
      
    def handle_call({:print_message ,new_message}, _from,messages) do
      x = Task.async(&generate_string/0)  
      
      {:reply, {:news, Task.await(x),messages}, messages}
    end
      
    def handle_cast({:print_answer ,new_message},messages) do
      {:p_val,a,b} = new_message
      IO.puts " #{a} #{b}"
      {:noreply, messages}
    end
      
    def handle_call(:get_messages, _from, messages) do
      {:reply, messages, messages}
    end
      
    def handle_call({:slice_message,new_message}, _from, messages) do
      new = String.slice new_message , 0..3
      {:reply, new, messages}
    end
      
    
    # def get_messages do
    #   GenServer.call(:chat_room, :get_messages)
    # end

 

 

  


  

  

end


# Node.spawn_link :"karan@192.168.0.147", fn -> Example.add(2,3) end
# {:ok, msgReader} = Task.start_link(fn -> KV.readMsg end)
# iex --name "keyur@192.168.0.173" --cookie choco -S mix
# pid = Node.spawn_link(:"keyur@192.168.0.173",KV, :readMsg, [])
# send pid, {:another, "yes"}
# mix escript.build
# escript KV --name 192.168.0.173