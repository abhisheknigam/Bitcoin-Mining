defmodule project1 do 
  use GenServer

  def main(args) do
    args |> process_arguments
  end

  def process_arguments(arguments) do
      {_, [input], _} = OptionParser.parse(arguments)
        ipaddr = to_string input
        if(String.contains?(ipaddr,".") == true) do
           start_client(ipaddr)
       else
           start_server(elem(Integer.parse(ipaddr),0)) 
       end
   end

  def get_k_value(server_name) do
    {:news,size} = GenServer.call({:bit_coin,String.to_atom(server_name)},{:print_message,"Keyur"}, :infinity)    
    size
  end

  def process_string(server_name,str,size) do
    try do
        {:p_val,ret,hashed} = generate_sha(str,size)  
        if(ret != "") do
          GenServer.cast({:bit_coin,String.to_atom(server_name)},{:print_answer,{:p_val,ret,hashed}})
        end
      rescue
        e in RuntimeError -> IO.puts("An error occurred: " <> e.message)
        pid1 = spawn_link fn -> KV.get_str_from_server(server_name,size) end
        IO.inspect (pid1)
      end
  end

  def iterate_list(server_name,list,size) do
    if length(list) > 0 do
      [x|list] = list
      process_string(server_name,x,size)
      iterate_list(server_name,list,size)
    end
  end

  def opt_util(server_name,size) do
    list = generate_string([])
    iterate_list(server_name,list,size)
    opt_util(server_name,size)
  end

  def get_str_from_server(server_name,size) do
      {:str_list,list} = GenServer.call({:bit_coin,String.to_atom(server_name)},{:get_string_list,"keyur"}, :infinity) 
      iterate_list(server_name,list,size)
      get_str_from_server(server_name,size)
  end

  def generate_sha(str,l) do
    hashed = :crypto.hash(:sha256,str) |> Base.encode16
    substr = String.slice hashed, 0..l-1
    substr_chck = String.duplicate("0",l)
    if substr == substr_chck do      
      {:p_val,str,hashed}
    else
      {:p_val,"",""}
    end
  end

  # def parse_args(args) do
  #     {options, _, _} = OptionParser.parse(args,
  #       switches: [name: :string]
  #     )
  #      ipaddr = to_string options[:name]
  #      if(String.contains?(ipaddr,".") == true) do
  #         start_client(ipaddr)
  #     else
  #         start_server(elem(Integer.parse(ipaddr),0)) 
  #     end
  #  end
   
  def start_server(k) do
    server_name = "keyur@"<>get_ip_addr()
    #IO.puts server_name<>":: server  will start"

    Node.start(String.to_atom(server_name))
    
    Node.set_cookie :"choco"
    Node.get_cookie

    IO.puts "server started "
    GenServer.start_link(__MODULE__, k, name: :bit_coin)
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
    start_client(get_ip_addr())
  end

  def start_client(server_ip) do
    k =  "keyur@" <> get_ip_addr()
    
    #IO.puts k<>":: node will start" 
    Node.start(String.to_atom(k))
    
    Node.set_cookie :"choco"
    Node.get_cookie
    server_name = "keyur@"<>server_ip
    IO.puts server_name
    Node.connect(String.to_atom(server_name)) 
    #connection end

    k_val = get_k_value(server_name)
    for x <- 0..8 do
        pid1 = spawn_link fn -> KV.get_str_from_server(server_name,k_val) end 
        spawn_link fn -> KV.opt_util(server_name,k_val) end
        #IO.inspect (pid1)       
    end  
          
    #IO.puts "keyur end "
    get_str_from_server(server_name,k_val)
        
  end


  ##server functions

    def init(count) do
      {:ok, count}
    end

    def add_message(message) do
      GenServer.cast(:bit_coin, {:add_message, message})
    end
    def slice(message) do
      GenServer.call(:bit_coin, {:slice_message, message})
    end
    def print_message(message) do

      GenServer.call(:bit_coin, {:print_message, message})
    end
    def get_string_list(message) do

      GenServer.call(:bit_coin, {:get_string_list, message})
    end
    
    def print_answer(message) do
      GenServer.cast(:bit_coin, {:print_answer, message})
    end

    # server callbacks
    def handle_cast({:add_message ,new_message}, messages) do
      {:noreply, [new_message | messages]}
      end
    
    

    def generate_string(list) do
      length=50
      cg_sub = :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
      a = Enum.to_list(0..9)
      b = for n <- ?a..?z, do: << n :: utf8 >>
      c = a++b
      cg = Enum.join(Enum.shuffle(c))
      len = Enum.random(Enum.concat([50..70]))
      String.slice cg, 0..len
      cg_str = "keyurbaldha;"<> cg_sub
      list  = [cg_str | list]
      if length(list) < 200 do
        generate_string(list)
      else
        list
      end
    end

    def handle_call({:print_message ,new_message}, _from, messages) do
      {:reply, {:news,messages}, messages}
    end

    def call_string_0 do
        generate_string([])
    end

    def handle_call({:get_string_list ,new_message}, _from, messages) do
      list = Task.async(&call_string_0/0)
      {:reply, {:str_list,Task.await(list,:infinity)}, messages}
    end
      
    def print_string(new_message, messages) do
      {:p_val,a,b} = new_message
      IO.puts " #{a} #{b}"
    end

    def handle_cast({:print_answer ,new_message},messages) do
      {:p_val,a,b} = new_message
      IO.puts " #{a} #{b}"
      {:noreply, messages}
    end
      
    def handle_call(:get_messages, _from, messages) do
      {:reply, messages, messages}
    end
end