library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rsa_v1_0 is
	generic (
		-- Users to add parameters here
        WIDTH : integer := 32;
        ADDR_WIDTH : integer := 32;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here
                -- Interface to the BRAM TXT module
		clka      : out std_logic;
        reseta    : out std_logic;
        ena       : out STD_LOGIC; 
        addra     : out STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0); 
        dina      : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        douta     : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        wea       : out STD_LOGIC_VECTOR (3 downto 0);
        
        -- Interface to the BRAM CRYPT module
		clkb      : out std_logic;
        resetb    : out std_logic;
        enb       : out STD_LOGIC;
        addrb     : out STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0); 
        dinb      : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        doutb     : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        web       : out STD_LOGIC_VECTOR (3 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end rsa_v1_0;

architecture arch_imp of rsa_v1_0 is
    component rsa is
        generic(WIDTH: positive :=32;
            ADDR_WIDTH : integer := 32          
             );
        Port ( 
            clk: in std_logic;
            reset: in std_logic;
            
            e_key: in std_logic_vector(WIDTH-1 downto 0);
            private_key: in std_logic_vector(WIDTH-1 downto 0);
            public_key: in std_logic_vector(WIDTH-1 downto 0);
            txt_length: in std_logic_vector(WIDTH-1 downto 0);
            start_enc: in std_logic;
            start_dec: in std_logic;
            
            --BRAM A
            a_addr_o: out std_logic_vector(ADDR_WIDTH-1 downto 0);
            a_data_i: in std_logic_vector(WIDTH-1 downto 0);
            a_en_o : out std_logic;
        
            --BRAM B
            b_addr_o: out std_logic_vector(ADDR_WIDTH-1 downto 0);
            b_data_o: out std_logic_vector(WIDTH-1 downto 0); --bilo size
            b_we_o : out std_logic_vector(3 downto 0);
        
        
            start: in std_logic;
            ready: out std_logic
        );
    end component;
	-- component declaration
	component rsa_v1_0_S00_AXI is
		generic (
		WIDTH : integer := 32;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
		);
		port (
		e_key_axi_o: out std_logic_vector(WIDTH-1 downto 0);
        private_key_axi_o: out std_logic_vector(WIDTH-1 downto 0);
        public_key_axi_o: out std_logic_vector(WIDTH-1 downto 0);
        txt_length_axi_o: out std_logic_vector(WIDTH-1 downto 0);
        start_enc_axi_o: out std_logic;
        start_dec_axi_o: out std_logic;
    
        start_axi_o: out std_logic;
        ready_axi_i: in std_logic;
        reset_axi_o: out std_logic;
        
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component rsa_v1_0_S00_AXI;
    signal reset_axi_s : std_logic;
    signal e_key_axi_s: std_logic_vector(WIDTH-1 downto 0);
    signal private_key_axi_s: std_logic_vector(WIDTH-1 downto 0);
    signal public_key_axi_s: std_logic_vector(WIDTH-1 downto 0);
    signal txt_length_axi_s: std_logic_vector(WIDTH-1 downto 0);
    signal start_enc_axi_s: std_logic;
    signal start_dec_axi_s: std_logic;

    signal start_axi_s: std_logic;
    signal ready_axi_s: std_logic;
begin

-- Instantiation of Axi Bus Interface S00_AXI
rsa_v1_0_S00_AXI_inst : rsa_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		e_key_axi_o => e_key_axi_s,
        private_key_axi_o => private_key_axi_s,
        public_key_axi_o => public_key_axi_s, 
        txt_length_axi_o => txt_length_axi_s,
        start_enc_axi_o => start_enc_axi_s,
        start_dec_axi_o => start_dec_axi_s,
        start_axi_o => start_axi_s,
        ready_axi_i => ready_axi_s,
        reset_axi_o => reset_axi_s,
        
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

    -- Add user logic here
    rsa_ins:rsa
    generic map(
        WIDTH => C_S00_AXI_DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH
    )
    port map(
        clk => s00_axi_aclk,
        reset=> reset_axi_s,
        
        e_key => e_key_axi_s,
        private_key => private_key_axi_s,
        public_key => public_key_axi_s,
        txt_length => txt_length_axi_s,
        start_enc => start_enc_axi_s,
        start_dec => start_dec_axi_s,
        
        a_addr_o => addra,
        a_data_i => douta,
        a_en_o => ena,
        
        b_addr_o => addrb,
        b_data_o => dinb,
        b_we_o => web,
    
        start => start_axi_s,
        ready => ready_axi_s 
    );
    
    clka   <= s00_axi_aclk;
	clkb   <= s00_axi_aclk;
	reseta <= '0';
	resetb <= '0';
	wea    <= "0000";
	enb <= '1';
	dina   <= (others=>'0');
	-- User logic ends

end arch_imp;
