----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/14/2019 07:23:58 PM
-- Design Name: 
-- Module Name: rsa - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rsa is
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
	
	
    --txt_addr: out std_logic_vector(ADDR_WIDTH-1 downto 0);
    a_addr_o: out std_logic_vector(ADDR_WIDTH-1 downto 0);    
	--text_in: in std_logic_vector(WIDTH-1 downto 0);
	a_data_i: in std_logic_vector(WIDTH-1 downto 0);
	a_en_o: out std_logic;
	
	--crypt_addr: out std_logic_vector(ADDR_WIDTH-1 downto 0);
	b_addr_o: out std_logic_vector(ADDR_WIDTH-1 downto 0);
    --crypt: out std_logic_vector(WIDTH-1 downto 0); 
    b_data_o: out std_logic_vector(WIDTH-1 downto 0); 
    b_en_o: out std_logic;
    b_we_o: out std_logic;
    

    start: in std_logic;
    ready: out std_logic
  );
end rsa;

architecture Behavioral of rsa is

    type state_type is (IDLE, CHECK, LOAD_ENC, LOAD_DEC, ENC_L1, ENC_L2, ENC_L3, ENC_L4, DEC_L1, DEC_L2, DEC_L3, DEC_L4, CALC_ADDR, RESET_C);
    signal state_reg, state_next: state_type;
    signal e_key_reg, e_key_next: unsigned(WIDTH-1 downto 0);
	signal private_key_reg, private_key_next: unsigned(WIDTH-1 downto 0);
	signal public_key_reg, public_key_next: unsigned(WIDTH-1 downto 0);
    signal text_in_reg, text_in_next: unsigned((WIDTH/2)-1 downto 0); 
    signal crypt_reg, crypt_next: unsigned(WIDTH-1 downto 0);
    signal temp_reg,temp_next: unsigned(WIDTH-1 downto 0);
    signal i_reg,i_next: unsigned(WIDTH-1 downto 0);
	signal count_enc_reg, count_enc_next, counter_enc_out: unsigned(2 downto 0);
	signal count_dec_reg, count_dec_next, counter_dec_out: unsigned(1 downto 0);
    signal adder_out: unsigned(WIDTH-1 downto 0);
    signal op_out: unsigned(WIDTH-1 downto 0);
	signal txt_part_enc: unsigned(7 downto 0);
	signal txt_part_dec: unsigned((WIDTH/2)-1 downto 0);
	signal a_addr_reg, a_addr_next, a_addr_count, b_addr_reg, b_addr_next, b_addr_count: unsigned(ADDR_WIDTH-1 downto 0);
    
begin
--control path: state register
    process(clk,reset)
    begin
     if reset = '1' then
        state_reg <= idle;
     elsif (clk'event and clk = '1') then
        state_reg <= state_next;
     end if;
    end process; 


--control path: next_state/output logic
    process(state_reg, start, e_key_reg, private_key_reg, i_next, e_key, private_key, start_enc, start_dec, count_enc_reg,count_enc_next, count_dec_reg, a_addr_reg, a_addr_next, txt_length)
   
    
    begin
        case state_reg is
            when IDLE =>
                if (start = '1') then
                    state_next <= CHECK;
                else
                    state_next <= IDLE;
                end if;
				
            when CHECK =>
                if(start_enc = '1') then
                    state_next <= LOAD_ENC;
                elsif(start_dec = '1') then
                    state_next <= LOAD_DEC;
				else 
					state_next <= CHECK; 
                end if;
				
            when LOAD_ENC =>
                state_next <= ENC_L1;
				
            when LOAD_DEC =>
                state_next <= DEC_L1;
				
            when ENC_L1 =>
                if(i_next < (e_key_reg) )then
                    state_next <= ENC_L1;
                else
                    state_next <= ENC_L2;
                end if;

           when ENC_L2 =>
                state_next <= ENC_L3;

           when ENC_L3 =>
                state_next <= ENC_L4;

           when ENC_L4 =>
                if(count_enc_reg = "100")then
                    state_next <= CALC_ADDR;
                else
                    state_next <= LOAD_ENC;
                end if;
				
           when DEC_L1 =>
                if(i_next < private_key_reg ) then
                    state_next <= DEC_L1;
                else 
                    state_next <= DEC_L2;
                end if;
				
           when DEC_L2 =>
                state_next <= DEC_L3;
				
           when DEC_L3 =>
                state_next <= DEC_L4;

            when DEC_L4 =>
                if(count_enc_reg = "10")then
                    state_next <= CALC_ADDR;
                else
                    state_next <= LOAD_DEC;
                end if;     
				
           when CALC_ADDR =>
                if(a_addr_reg < unsigned(txt_length))then
                    state_next <= RESET_C;
                else
                    state_next <= IDLE;
                end if;
				
           when RESET_C =>
                    state_next <= CHECK;
                
        end case;
    end process;
     
     -- control path: output logic
    ready <= '1' when state_reg = IDLE else '0';
    
    --datapath: data register
    process(clk,reset)
    
    begin
        if(reset = '1')then
            e_key_reg <= (others => '0');
			private_key_reg <= (others => '0');
			public_key_reg <= (others => '0');
            text_in_reg <= (others => '0');
            crypt_reg <= (others => '0');
            i_reg <= (others => '0');
            temp_reg <= (others => '0');
			count_enc_reg <= (others => '0');
			count_dec_reg <= (others => '0');
			a_addr_reg <= (others => '0');
			b_addr_reg <= (others => '0');
        elsif(clk'event and clk = '1')then
            e_key_reg <= e_key_next;
			private_key_reg <= private_key_next;
			public_key_reg <= public_key_next;
            text_in_reg <= text_in_next;
            crypt_reg <= crypt_next;
            i_reg <= i_next;
            temp_reg <= temp_next;        
			count_enc_reg <= count_enc_next;
			count_dec_reg <= count_dec_next;
			a_addr_reg <= a_addr_next;
			b_addr_reg <= b_addr_next;
        end if;
    end process;
    
    --datapath: routing mux
    process(state_reg, i_reg, e_key_reg, e_key, e_key_next, private_key_next , private_key, private_key_reg, public_key, public_key_reg, a_data_i, text_in_reg, crypt_reg, temp_reg, op_out, adder_out, txt_part_enc, txt_part_dec, counter_enc_out, counter_dec_out, count_enc_reg, count_dec_reg, a_addr_reg, b_addr_reg, a_addr_count, b_addr_count)
           
        begin
        --default assignments
            e_key_next <= e_key_reg;
			private_key_next <= private_key_reg;
			public_key_next <= public_key_reg;
            text_in_next <= text_in_reg;
            crypt_next <= crypt_reg;
            i_next <= i_reg;
            temp_next <= temp_reg;        
			count_enc_next <= count_enc_reg;
			count_dec_next <= count_dec_reg;
			a_addr_next <= a_addr_reg;
			b_addr_next <= b_addr_reg;
            a_en_o <= '0';
            b_en_o <= '0';
            b_we_o <= '0';
        
        case state_reg is
            when IDLE =>
                crypt_next <= (others => '0');
                i_next <= (others => '0');
                count_enc_next <= (others => '0');
                count_dec_next <= (others => '0');
                a_addr_next <= (others => '0');
                b_addr_next <= (others => '0'); 

            when RESET_C =>
                count_enc_next <=(others => '0');
                count_dec_next <=(others => '0');

              when CHECK =>
                e_key_next <= unsigned(e_key);
				private_key_next <= unsigned(private_key);
				public_key_next <= unsigned(public_key);
                crypt_next <= (others => '0');
                i_next <= (others => '0');
                temp_next <= x"00000001";
                a_en_o <= '1'; --**


             when LOAD_ENC =>
                e_key_next <= unsigned(e_key);
				private_key_next <= unsigned(private_key);
				public_key_next <= unsigned(public_key);
                text_in_next <= "00000000" & txt_part_enc;
                crypt_next <= (others => '0');
                crypt_next <= crypt_reg;
                i_next <= (others => '0');
                temp_next <= x"00000001";
                a_en_o <= '1';

            when LOAD_DEC =>
                e_key_next <= unsigned(e_key);
				private_key_next <= unsigned(private_key);
				public_key_next <= unsigned(public_key);
                text_in_next <= txt_part_dec;
                crypt_next <= (others => '0');
                i_next <= (others => '0');
                temp_next <= x"00000001";
                a_en_o <= '1';
       
           when ENC_L1 =>
                i_next <= adder_out;
                temp_next <= ((temp_reg * text_in_reg) mod public_key_reg);    
                a_en_o <= '0';

           when DEC_L1 =>
                i_next <= adder_out;
                temp_next <= ((temp_reg * text_in_reg) mod public_key_reg); 
                a_en_o <= '0';

           when ENC_L2 =>
				count_enc_next <= counter_enc_out;

           when DEC_L2 =>
				count_dec_next <= counter_dec_out;
		   
		   when ENC_L3 =>
		        crypt_next <= temp_reg(WIDTH-1 downto 0); 

           when DEC_L3 =>
		        crypt_next <= temp_reg(WIDTH-1 downto 0); 

           when ENC_L4 =>
                b_addr_next <= b_addr_count;
                b_en_o <= '0'; 
                b_we_o <= '1';
           
           when DEC_L4 =>
                b_addr_next <= b_addr_count;
                b_en_o <= '0'; 
                b_we_o <= '1';
           

		    when CALC_ADDR =>
				a_addr_next <= a_addr_count;
			
        end case;
    end process;
    
    --datapath: functional units
    adder_out <= i_reg+1;
    counter_enc_out <= count_enc_reg+1;
	counter_dec_out <= count_dec_reg+1;
	a_addr_count <= a_addr_reg+4;
	b_addr_count <= b_addr_reg+4;
     


	with count_enc_reg select
		txt_part_enc <= unsigned(a_data_i(7 downto 0)) when "011",
		            unsigned(a_data_i(15 downto 8)) when "010",
		            unsigned(a_data_i(23 downto 16)) when "001",
		            unsigned(a_data_i(31 downto 24)) when "000",
		            "00000000" when others;
   with count_dec_reg select
		txt_part_dec <= unsigned(a_data_i(15 downto 0)) when "01",
		            unsigned(a_data_i(31 downto 16)) when "00",
		            "0000000000000000" when others;
  
    b_data_o <= std_logic_vector(crypt_reg);
    a_addr_o <= std_logic_vector(a_addr_reg);
    b_addr_o <= std_logic_vector(b_addr_reg);
     
end Behavioral;
