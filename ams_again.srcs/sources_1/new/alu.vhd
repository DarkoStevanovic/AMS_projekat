LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.math_real.all;
use work.all_pkg.all;
use ieee.numeric_std.all;

entity alu is
    generic (
        WIDTH: natural := 32
    );
    port (
        a_i : in std_logic_vector(WIDTH - 1 downto 0);
        b_i : in std_logic_vector(WIDTH - 1 downto 0);
        op_i : in std_logic_vector(4 downto 0);
        comp_i: in signed;      --zaboravio sam zasto sam ga dodao
        res_o : out std_logic_vector(WIDTH - 1 downto 0);
        zero_o : out std_logic;
        of_o : out std_logic
    );
end entity;

architecture Behavioral of alu is
signal add_r,sub_r,or_r,and_r,res_s : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
begin

    -- ALU Operation Implementations
    add_r <= std_logic_vector(signed(a_i) + signed(b_i));
    sub_r <= std_logic_vector(signed(a_i) - signed(b_i));
    or_r  <= a_i or b_i;
    and_r <= a_i and b_i;
    
    -- Result Selection based on Op-code
process(op_i)
begin
    case op_i is
        when "00000" => 
            res_s <= add_r;               -- Addition
        when "00001" => 
            res_s <= sub_r;               -- Subtraction
        when "00100" => 
            res_s <= or_r;                -- Bitwise OR
        when "00101" => 
            res_s <= and_r;               -- Bitwise AND
        when "01010" =>
            if signed(a_i) < signed(b_i) then  -- SLT
                res_s <= (others => '1');
            else
                res_s <= (others => '0');
            end if;
        when "01011" =>
            if signed(a_i) < signed(comp_i) then  -- SLTI
                res_s <= (others => '1');
            else
                res_s <= (others => '0');
            end if;
        when others => 
            res_s <= (others => '0');     -- default: set result to 0
    end case;
end process;

end architecture Behavioral;