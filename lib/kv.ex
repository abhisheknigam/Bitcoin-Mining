defmodule KV do 
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
   
  def get_str_from_server(server_name) do
    try do
      {:news,str,size} = GenServer.call({:chat_room,String.to_atom(server_name)},{:print_message,"karan"}, 20000)
      {:p_val,ret,hashed} = process_sha_256(str,size)  
      if(ret == "") do
        #GenServer.cast({:chat_room,:"karan@192.168.0.147"},{:print_answer,""})
      else 
        IO.puts "Found coin : "<>str
        GenServer.cast({:chat_room,String.to_atom(server_name)},{:print_answer,{:p_val,ret,hashed}})
      end
    catch
      :exit, _ -> "not really"
    rescue _ -> :ok
    end
    get_str_from_server(server_name)
  end

  def process_sha_256(str,l) do
    hashed = :crypto.hash(:sha256,str) |> Base.encode16
    
    substr = String.slice hashed, 0..l-1
    substr_chck = String.duplicate("0",l)
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

    IO.puts "server started "
    GenServer.start_link(__MODULE__, k, name: :chat_room)
    IO.puts "genserver started"
    server_mining()
    IO.gets ""
  end

  def get_ip_addr do
    {:ok,lst} = :inet.getif() 
    x = elem(List.first(lst),0)
    addr =  to_string(elem(x,0)) <> "." <>  to_string(elem(x,1)) <> "." <>  to_string(elem(x,2)) <> "." <>  to_string(elem(x,3))
    addr  
  end

  def server_mining() do
    start_client(get_ip_addr)
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
    
        for x <- 0..50000 do

          #Task.async(fn ->
            pid1 = spawn fn -> KV.get_str_from_server(server_name) end 
            IO.inspect (pid1)       
          #end)
          
        end  
          
        IO.puts "keyurr end "
        get_str_from_server(server_name)
        
  end


  ##server functions
    def init(count) do
      {:ok, count}
    end
    
    def add_message(message) do
      GenServer.cast(:chat_room, {:add_message, message})
    end
    def slice(message) do
      GenServer.call(:chat_room, {:slice_message, message})
    end
    def print_message(message) do
      GenServer.call(:chat_room, {:print_message, message})
    end
    def print_answer(message) do
      GenServer.cast(:chat_room, {:print_answer, message})
    end

    # server callbacks
    def handle_cast({:add_message ,new_message}, messages) do
      {:noreply, [new_message | messages]}
      end
      
    def handle_call({:print_message ,new_message}, _from,messages) do
      length=20
      cg_sub = :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, 20)
      cg_str = "karanacharekar;"<> cg_sub
      {:reply, {:news, cg_str,messages}, messages}
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
end


# Node.spawn_link :"karan@192.168.0.147", fn -> Example.add(2,3) end
# {:ok, msgReader} = Task.start_link(fn -> KV.readMsg end)
# iex --name "keyur@192.168.0.173" --cookie choco -S mix
# pid = Node.spawn_link(:"keyur@192.168.0.173",KV, :readMsg, [])
# send pid, {:another, "yes"}
# mix escript.build
# escript KV --name 192.168.0.173