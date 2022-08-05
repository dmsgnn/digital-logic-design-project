---------------------------------------------------------------------------------- 
--
-- Final Exam of "Reti Logiche"
-- Prof. William Fornaciari - A.Y. 2020/2021
--
-- Giovanni Demasi
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
 port (
        i_clk       : in std_logic;
        i_rst       : in std_logic;
        i_start     : in std_logic;
        i_data      : in std_logic_vector(7 downto 0);
        o_address   : out std_logic_vector(15 downto 0);
        o_done      : out std_logic;
        o_en        : out std_logic;
        o_we        : out std_logic;
        o_data      : out std_logic_vector (7 downto 0)
     );
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is

type state_type is (IDLE, GET_COL, GET_ROW, COMP_DIM, CHECK_DIM, GET_FIRST, GET_MAXANDMIN, CHECK_MAXANDMIN, GET_SHIFT, COMP_SHIFT, GET_CURRENT, WRITE_VALUE, WAIT_DATA, END_STATE);

signal cur_state, next_state : state_type;

signal o_done_next, o_en_next, o_we_next : std_logic := '0';
signal o_data_next : std_logic_vector(7 downto 0) := "00000000";
signal o_address_next : std_logic_vector(15 downto 0) := "0000000000000000";

signal n_col, n_col_next : std_logic_vector (7 downto 0) := "00000000";
signal n_row, n_row_next : std_logic_vector (7 downto 0) := "00000000";

signal max_pixel, max_pixel_next : std_logic_vector (7 downto 0) := "00000000";
signal min_pixel, min_pixel_next : std_logic_vector (7 downto 0) := "00000000";

signal dimension, dimension_next : std_logic_vector (15 downto 0) := "0000000000000000";

signal shift, shift_next : integer range 0 to 8 := 0;

signal current_pixel, current_pixel_next : std_logic_vector (7 downto 0) := "00000000";

signal delta_plus, delta_plus_next : std_logic_vector(8 downto 0) := "000000000";

signal address_reg, address_next : std_logic_vector(15 downto 0) := "0000000000000000";

    
begin
process (i_clk, i_rst)
begin
    if (i_rst = '1') then
       o_en <= '1';
       o_we <= '0';
       o_address <= "0000000000000000";
	   n_col <= "00000000";
	   n_row <= "00000000";
	   max_pixel <= "00000000";
	   min_pixel <= "00000000";
	   dimension <= "0000000000000000";
	   shift <= 0;
	   current_pixel <= "00000000";
	   delta_plus <= "000000000";
	   address_reg <= "0000000000000000";
       cur_state <= IDLE;
    elsif (i_clk'event and i_clk='1') then
        o_done <= o_done_next;
        o_en <= o_en_next;
        o_we <= o_we_next;
        o_data <= o_data_next;
        o_address <= o_address_next;
	   n_col <= n_col_next;
	   n_row <= n_row_next;
	   max_pixel <= max_pixel_next;
	   min_pixel <= min_pixel_next;
	   dimension <= dimension_next;
	   shift <= shift_next;
	   current_pixel <= current_pixel_next;
	   delta_plus <= delta_plus_next;
	   address_reg <= address_next;
        cur_state <= next_state;
    end if;
end process;

process(cur_state, i_start, i_data, n_col, n_row, max_pixel, min_pixel, dimension, shift, current_pixel, delta_plus, address_reg)
begin
    o_done_next <= '0';
    o_en_next <= '1';
    o_we_next <= '0';
    o_data_next <= "00000000";
    o_address_next <= "0000000000000000";

    n_col_next <= n_col;
    n_row_next <= n_row;

    max_pixel_next <= max_pixel;
    min_pixel_next <= min_pixel;

    dimension_next <= dimension;

    shift_next <= shift;

    current_pixel_next <= current_pixel;

    delta_plus_next <= delta_plus;

    address_next <= address_reg;

    next_state <= cur_state;

    case cur_state is
        when IDLE =>
            if (i_start = '1') then
                o_en_next <= '1';
                o_we_next <= '0';
                o_address_next <= "0000000000000001";
                next_state <= GET_COL;
            end if;
        when GET_COL =>
            n_col_next <= i_data;
            o_en_next <= '1';
            o_we_next <= '0';
            o_address_next <= "0000000000000001";
            next_state <= GET_ROW;
        when GET_ROW =>
            n_row_next <= i_data;
            o_en_next <= '0';
            o_we_next <= '0';
            next_state <= COMP_DIM;
        when COMP_DIM =>
            if(n_col = "00000000") then
                o_en_next <= '1';
                o_we_next <= '0';
                o_address_next <= "0000000000000010";
                next_state <= CHECK_DIM;
            else
                dimension_next <= dimension + n_row;
                n_col_next <= n_col - "00000001";
                o_en_next <= '0';
                o_we_next <= '0';
                next_state <= COMP_DIM;
            end if;
        when CHECK_DIM =>
            if(dimension = "0000000000000000") then
                o_en_next <= '0';
                o_we_next <= '0';
                o_done_next <= '1';
                next_state <= END_STATE;
            else
            	o_en_next <= '1';
            	o_we_next <= '0';
            	o_address_next <= "0000000000000010";
            	next_state <= GET_FIRST;
	    end if;
        when GET_FIRST =>
            max_pixel_next <= i_data;
            min_pixel_next <= i_data;
            o_en_next <= '1';
            o_we_next <= '0';
            o_address_next <= "0000000000000011";
	    address_next <= "0000000000000011";
            next_state <= GET_MAXANDMIN;
        when GET_MAXANDMIN =>
            if(address_reg = dimension + "0000000000000011") then
                o_en_next <= '0';
                o_we_next <= '0';
                o_address_next <= "0000000000000010";
                next_state <= GET_SHIFT;
            else
            	current_pixel_next <= i_data;
            	o_en_next <= '0';
            	o_we_next <= '0';
            	next_state <= CHECK_MAXANDMIN;
            end if;
        when CHECK_MAXANDMIN =>
            if(current_pixel > max_pixel) then
                max_pixel_next <= current_pixel;
            elsif(current_pixel < min_pixel) then
                min_pixel_next <= current_pixel;
            end if;
            o_en_next <= '1';
            o_we_next <= '0';
	        address_next <= address_reg + "0000000000000001";
            o_address_next <= address_reg + "0000000000000001";
            next_state <= GET_MAXANDMIN;
        when GET_SHIFT =>
            delta_plus_next <= (("0" & max_pixel) - ("0" & min_pixel)) + "000000001";
            o_address_next <= "0000000000000010";
            o_en_next <= '1';
            o_we_next <= '0';
            next_state <= COMP_SHIFT;
        when COMP_SHIFT =>
            if(delta_plus(8) = '1') then
                shift_next <= 8 - 8;
            elsif(delta_plus(7) ='1') then
                shift_next <= 8 - 7;
            elsif(delta_plus(6) ='1') then
                shift_next <= 8 - 6;
            elsif(delta_plus(5) ='1') then
                shift_next <= 8 - 5;
            elsif(delta_plus(4) ='1') then
                shift_next <= 8 - 4;
            elsif(delta_plus(3) ='1') then
                shift_next <= 8 - 3;
            elsif(delta_plus(2) ='1') then
                shift_next <= 8 - 2;
            elsif(delta_plus(1) ='1') then
                shift_next <= 8 - 1;
            else
                shift_next <= 8;
            end if;
            o_address_next <= "0000000000000010";
            address_next <= "0000000000000010";
            o_en_next <= '1';
            o_we_next <= '0';
            next_state <= GET_CURRENT;
        when GET_CURRENT =>
            if(address_reg = dimension + "0000000000000010") then
                o_en_next <= '0';
                o_we_next <= '0';
                o_done_next <= '1';
                next_state <= END_STATE;
            else
                if(shift_left(unsigned("00000000" & i_data - ("00000000" & min_pixel)), shift) < "0000000011111111") then
                    o_data_next <= std_logic_vector(shift_left(unsigned("00000000" & i_data - ("00000000" & min_pixel)), shift) (7 downto 0)); 
                else
                    o_data_next <= "11111111";
                end if;
                o_en_next <= '1';
                o_we_next <= '1';
                o_address_next <= address_reg + dimension;
                next_state <= WRITE_VALUE;
            end if;
        when WRITE_VALUE =>
            address_next <= address_reg + "0000000000000001";
            o_address_next <= address_reg + "0000000000000001";
            o_en_next <= '1';
            o_we_next <= '0';
            next_state <= WAIT_DATA;
        when WAIT_DATA =>
            o_en_next <= '1';
            o_we_next <= '0';
            next_state <= GET_CURRENT;
        when END_STATE =>
            if(i_start = '0') then
               o_en_next <= '1';
	           n_col_next <= "00000000";
	           n_row_next <= "00000000";
	           max_pixel_next <= "00000000";
	           min_pixel_next <= "00000000";
	           dimension_next <= "0000000000000000";
	           shift_next <= 0;
	           current_pixel_next <= "00000000";
	           delta_plus_next <= "000000000";
	           address_next <= "0000000000000000";
               next_state <= IDLE;
             else
                o_done_next <= '1';
                next_state <= END_STATE;
             end if;
end case;
end process;
end Behavioral;
