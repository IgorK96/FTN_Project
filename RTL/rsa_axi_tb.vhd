----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2020 02:33:06 AM
-- Design Name: 
-- Module Name: rsa_axi_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rsa_axi_tb is

end rsa_axi_tb;

architecture Behavioral of rsa_axi_tb is
    
    constant DATA_WIDTH_c : integer := 32;
    constant ADDR_WIDTH_c : integer := 32; 
    constant MAX_SIZE_c : integer := 256;
	

    constant e_key_c : integer := 5;
    constant private_key_c : integer := 77;
    constant public_key_c : integer := 221;
    constant txt_length_c : integer := 7; 
    
    type mem_t is array (0 to txt_length_c) of integer;
    constant MEM_A_CONTENT: mem_t :=
    (1265592937,1265592937,1265592937,1265592937,5,6,7,8);
    --(9633868,9633868,1265592937,1265592937,5,6,7,8);

------------------------------------------------------------------
    signal clk_s: std_logic;
    signal reset_s: std_logic;

       
---------------------- RSA_IP core's address map-------------------------
    constant E_KEY_REG_ADDR_c : integer := 0;
    constant PRIVATE_KEY_REG_ADDR_c : integer := 4;
    constant PUBLIC_KEY_REG_ADDR_c : integer := 8;
    constant TXT_LENGTH_REG_ADDR_c : integer := 12;
    constant START_ENC_REG_ADDR_c : integer := 16;
    constant START_DEC_REG_ADDR_c : integer := 20;
    constant START_REG_ADDR_c : integer := 24;
    constant READY_REG_ADDR_c : integer := 32;
    
    
---------------------- Ports for BRAM Initialization ----------------------  
    signal tb_a_en_i      : std_logic;
    signal tb_a_addr_i    : std_logic_vector(ADDR_WIDTH_c-1 downto 0);
    signal tb_a_data_i    : std_logic_vector(DATA_WIDTH_c-1 downto 0);
    signal tb_a_we_i      : std_logic;
	
	signal tb_b_en_i      : std_logic;
    signal tb_b_addr_i    : std_logic_vector(ADDR_WIDTH_c-1 downto 0);
    signal tb_b_data_o    : std_logic_vector(DATA_WIDTH_c-1 downto 0);
    signal tb_b_we_i      : std_logic; 

------------------------- Ports to RSA_IP ---------------------------------
    signal ip_a_en     : std_logic;
    signal ip_a_we     : std_logic;
    signal ip_a_addr    : std_logic_vector(ADDR_WIDTH_c-1 downto 0);
    signal ip_a_data    : std_logic_vector(DATA_WIDTH_c-1 downto 0);
	
	signal ip_b_en      : std_logic;
    signal ip_b_addr    : std_logic_vector(ADDR_WIDTH_c-1 downto 0);
    signal ip_b_data    : std_logic_vector(DATA_WIDTH_c-1 downto 0);
    signal ip_b_we      : std_logic; 	


------------------- AXI Interfaces signals -------------------
    -- Parameters of Axi-Lite Slave Bus Interface S00_AXI
    constant C_S00_AXI_DATA_WIDTH_c : integer := 32;
    constant C_S00_AXI_ADDR_WIDTH_c : integer := 5;	--**
	
	
-- Ports of Axi-Lite Slave Bus Interface S00_AXI
    signal s00_axi_aclk_s : std_logic := '0';
    signal s00_axi_aresetn_s : std_logic := '1';
    signal s00_axi_awaddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_awprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_awvalid_s : std_logic := '0';
    signal s00_axi_awready_s : std_logic := '0';
    signal s00_axi_wdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_wstrb_s : std_logic_vector((C_S00_AXI_DATA_WIDTH_c/8)-1 downto 0) := (others => '0');
    signal s00_axi_wvalid_s : std_logic := '0';
    signal s00_axi_wready_s : std_logic := '0';
    signal s00_axi_bresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_bvalid_s : std_logic := '0';
    signal s00_axi_bready_s : std_logic := '0';
    signal s00_axi_araddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_arprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_arvalid_s : std_logic := '0';
    signal s00_axi_arready_s : std_logic := '0';
    signal s00_axi_rdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_rresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_rvalid_s : std_logic := '0';
    signal s00_axi_rready_s : std_logic := '0';
    
    
begin
    reset_s <= not s00_axi_aresetn_s; --reset for BRAM
    
clk_gen: process is
    begin
        clk_s <= '0', '1' after 50 ns;
        wait for 100 ns;
    end process;
stimulus_generator: process

begin
    report "Start !";
 
 -- reset AXI-lite interface. Reset will be 10 clock cycles wide
    s00_axi_aresetn_s <= '0';
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    -- release reset
    s00_axi_aresetn_s <= '1';
    wait until falling_edge(clk_s);
    
-- local reset for RSA module --
 
 
-------------------------------------------------------------------------------------------
    -- Load the elements values into the core
-------------------------------------------------------------------------------------------
--Loading elements into the core----
        wait until falling_edge(clk_s);
        for i in 0 to txt_length_c-1 loop -- bilo od 1
            wait until falling_edge(clk_s);
            tb_a_en_i <= '1';
            tb_a_addr_i <= conv_std_logic_vector(i*4, ADDR_WIDTH_c);
            tb_a_data_i <= conv_std_logic_vector(MEM_A_CONTENT(i), DATA_WIDTH_c);
            tb_a_we_i <= '1';
            
            wait until rising_edge(clk_s);
            tb_a_en_i <= '0';
            tb_a_we_i <= '0';
            
        end loop;
        tb_a_en_i <= '0';
        tb_a_we_i <= '0';
        
        
-- Initialize the RSA core --
    ----------------------------------------------------------------------
    report "Loading the matrix dimensions information into the Matrix Multiplier core!";
 
    -- Set the value for e_key
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(E_KEY_REG_ADDR_c, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(e_key_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s); 


    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;


    -- Set the value for private_key
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(PRIVATE_KEY_REG_ADDR_c, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(private_key_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s); 


    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;

    -- Set the value for public_key
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(PUBLIC_KEY_REG_ADDR_c, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(public_key_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s); 

    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;


    --Set the value for txt_length_key
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(TXT_LENGTH_REG_ADDR_c, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(txt_length_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s); 


    --wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    
    --Set value for start_enc 
    wait until falling_edge(clk_s);
		s00_axi_awaddr_s <= conv_std_logic_vector(START_ENC_REG_ADDR_c, C_S00_AXI_ADDR_WIDTH_c);
		s00_axi_awvalid_s <= '1';
		s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c);
		s00_axi_wvalid_s <= '1';
		s00_axi_wstrb_s <= "1111";
		s00_axi_bready_s <= '1';
		wait until s00_axi_awready_s = '1';
		wait until s00_axi_awready_s = '0';
		wait until falling_edge(clk_s);
		s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
		s00_axi_awvalid_s <= '0';
		s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
		s00_axi_wvalid_s <= '0';
		s00_axi_wstrb_s <= "0000";
		wait until s00_axi_bvalid_s = '0';
		wait until falling_edge(clk_s);
		s00_axi_bready_s <= '0';
		wait until falling_edge(clk_s);
		-- wait for 5 falling edges of AXI-lite clock signal
		for i in 1 to 5 loop
			wait until falling_edge(clk_s);
		end loop;

    --Set value for start_dec 
    wait until falling_edge(clk_s);
		s00_axi_awaddr_s <= conv_std_logic_vector(START_DEC_REG_ADDR_c, C_S00_AXI_ADDR_WIDTH_c);
		s00_axi_awvalid_s <= '1';
		s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
		s00_axi_wvalid_s <= '1';
		s00_axi_wstrb_s <= "1111";
		s00_axi_bready_s <= '1';
		wait until s00_axi_awready_s = '1';
		wait until s00_axi_awready_s = '0';
		wait until falling_edge(clk_s);
		s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
		s00_axi_awvalid_s <= '0';
		s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
		s00_axi_wvalid_s <= '0';
		s00_axi_wstrb_s <= "0000";
		wait until s00_axi_bvalid_s = '0';
		wait until falling_edge(clk_s);
		s00_axi_bready_s <= '0';
		wait until falling_edge(clk_s);
		-- wait for 5 falling edges of AXI-lite clock signal
		for i in 1 to 5 loop
			wait until falling_edge(clk_s);
		end loop;

-------------------------------------------------------------------------------------------
    -- Load the elements values into the core
-------------------------------------------------------------------------------------------
--Loading elements into the core----
        wait until falling_edge(clk_s);
        for i in 0 to txt_length_c loop -- bilo od 1
            wait until falling_edge(clk_s);
            tb_a_en_i <= '1';
            tb_a_addr_i <= conv_std_logic_vector(i*4, ADDR_WIDTH_c);
            tb_a_data_i <= conv_std_logic_vector(MEM_A_CONTENT(i), DATA_WIDTH_c);
            tb_a_we_i <= '1';
            
            wait until rising_edge(clk_s);
            tb_a_en_i <= '0';
            tb_a_we_i <= '0';
            
        end loop;
        tb_a_en_i <= '0';
        tb_a_we_i <= '0';
        
        
 -----------Start for RSA module-------------
		wait until falling_edge(clk_s);
		s00_axi_awaddr_s <= conv_std_logic_vector(START_REG_ADDR_c, C_S00_AXI_ADDR_WIDTH_c);
		s00_axi_awvalid_s <= '1';
		s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c);
		s00_axi_wvalid_s <= '1';
		s00_axi_wstrb_s <= "1111";
		s00_axi_bready_s <= '1';
		wait until s00_axi_awready_s = '1';
		wait until s00_axi_awready_s = '0';
		wait until falling_edge(clk_s);
		s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
		s00_axi_awvalid_s <= '0';
		s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
		s00_axi_wvalid_s <= '0';
		s00_axi_wstrb_s <= "0000";
		wait until s00_axi_bvalid_s = '0';
		wait until falling_edge(clk_s);
		s00_axi_bready_s <= '0';
		wait until falling_edge(clk_s);
		-- wait for 5 falling edges of AXI-lite clock signal
		for i in 1 to 5 loop
			wait until falling_edge(clk_s);
		end loop; 
		
		      
	    report "Clearing the start bit!";
		--------------release start bit------------
		wait until falling_edge(clk_s);
		s00_axi_awaddr_s <= conv_std_logic_vector(START_REG_ADDR_c, C_S00_AXI_ADDR_WIDTH_c);
		s00_axi_awvalid_s <= '1';
		s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
		s00_axi_wvalid_s <= '1';
		s00_axi_wstrb_s <= "1111";
		s00_axi_bready_s <= '1';
		wait until s00_axi_awready_s = '1';
		wait until s00_axi_awready_s = '0';
		wait until falling_edge(clk_s);
		s00_axi_awaddr_s <= conv_std_logic_vector(4, C_S00_AXI_ADDR_WIDTH_c);
		s00_axi_awvalid_s <= '0';
		s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
		s00_axi_wvalid_s <= '0';
		s00_axi_wstrb_s <= "0000";
		wait until s00_axi_bvalid_s = '0';
		wait until falling_edge(clk_s);
		s00_axi_bready_s <= '0';
		wait until falling_edge(clk_s);

		report "Waiting for the encryption process to complete!";
		loop
			-- Read the content of the Status register
			wait until falling_edge(clk_s);
			s00_axi_araddr_s <= conv_std_logic_vector(READY_REG_ADDR_c, C_S00_AXI_ADDR_WIDTH_c);
			s00_axi_arvalid_s <= '1';
			s00_axi_rready_s <= '1';
			wait until s00_axi_arready_s = '1';
			wait until s00_axi_arready_s = '0';
			wait until falling_edge(clk_s);
			s00_axi_araddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
			s00_axi_arvalid_s <= '0';
			s00_axi_rready_s <= '0';

			-- Check is the 1st bit of the Status register set to one
			if (s00_axi_rdata_s(0) = '1') then
				-- convolution process completed
				exit;
			else
				wait for 1000 ns;
			end if;
		end loop;

		-- report "Reading the results of the B BRAM!";

		for k in 0 to txt_length_c-1 loop -- probaj od 1
			for i in 1 to 10 loop
			     wait until falling_edge(clk_s);
			end loop;
			tb_b_en_i <= '1';
			tb_b_we_i <= '0';
			tb_b_addr_i <= conv_std_logic_vector (k * 4, ADDR_WIDTH_c);

			wait until rising_edge(clk_s);
		end loop;

		tb_b_en_i <= '0';
		report "Finished!";
		wait;
	end process;
---------------------------------------------------------------------------
---- DUT --
---------------------------------------------------------------------------

uut: entity work.RSA_v1_0(arch_imp)
    generic map(
         WIDTH => DATA_WIDTH_c,
         ADDR_WIDTH => ADDR_WIDTH_c 
                )
    port map(
    -- Interface to the BRAM A module
        clka  => open,   
        reseta  => open,
        ena  => ip_a_en,   
        addra  => ip_a_addr,
        --dina  => open,  
        douta  => ip_a_data, 
        --wea  => open,    
         
    
    -- Interface to the BRAM B module
        clkb  => open,   
        resetb  => open,
        enb  => ip_b_en,   
        addrb  => ip_b_addr,
        dinb  => ip_b_data,  
        --doutb  => (others=>'0'),
        web  => ip_b_we, 
    
    
    -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk    => clk_s,
        s00_axi_aresetn => s00_axi_aresetn_s,
        s00_axi_awaddr  => s00_axi_awaddr_s,
        s00_axi_awprot  => s00_axi_awprot_s, 
        s00_axi_awvalid => s00_axi_awvalid_s,
        s00_axi_awready => s00_axi_awready_s,
        s00_axi_wdata   => s00_axi_wdata_s,
        s00_axi_wstrb   => s00_axi_wstrb_s,
        s00_axi_wvalid  => s00_axi_wvalid_s,
        s00_axi_wready  => s00_axi_wready_s,
        s00_axi_bresp   => s00_axi_bresp_s,
        s00_axi_bvalid  => s00_axi_bvalid_s,
        s00_axi_bready  => s00_axi_bready_s,
        s00_axi_araddr  => s00_axi_araddr_s,
        s00_axi_arprot  => s00_axi_arprot_s,
        s00_axi_arvalid => s00_axi_arvalid_s,
        s00_axi_arready => s00_axi_arready_s,
        s00_axi_rdata   => s00_axi_rdata_s,
        s00_axi_rresp   => s00_axi_rresp_s,
        s00_axi_rvalid  => s00_axi_rvalid_s,
        s00_axi_rready  => s00_axi_rready_s
        );

Bram_A: entity work.bram(beh)
    generic map(
                WIDTH       =>  DATA_WIDTH_c,
                --MAX_SIZE    =>  MAX_SIZE_c,
                WADDR       =>  ADDR_WIDTH_c
                )
    port map(
               clka => clk_s,
               clkb => clk_s,
	           reseta=> reset_s,
	           ena=>tb_a_en_i,
	           wea=> tb_a_we_i,
	           addra=> tb_a_addr_i,
	           dia=> tb_a_data_i,
	           doa=> open,
	
	           resetb=>reset_s,
	           enb=>ip_a_en,
	           web=>ip_a_we,
	           addrb=>ip_a_addr,
	           dib=>(others=>'0'),
	           dob=> ip_a_data
	        );

Bram_B: entity work.bram(beh)
    generic map(
                WIDTH       =>  DATA_WIDTH_c,
                --MAX_SIZE    =>  MAX_SIZE_c,
                WADDR       =>  ADDR_WIDTH_c
                )
    port map(
               clka => clk_s,
               clkb => clk_s,
	           reseta=> reset_s,
	           ena=>tb_b_en_i,
	           wea=> tb_b_we_i,
	           addra=> tb_b_addr_i,
	           dia=> (others=>'0'),
	           doa=> tb_b_data_o,
	
	           resetb=>reset_s,
	           enb=>ip_b_en,
	           web=>ip_b_we,
	           addrb=>ip_b_addr,
	           dib=>ip_b_data,
	           dob=>open
	        );    

end Behavioral;
