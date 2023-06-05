library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all_pkg.all;

entity alu_decoder is
    port (
        --******** Controlpath inputs *********
        alu_2bit_op_i : in std_logic_vector(1 downto 0);
        --******** Instruction fields *******
        funct3_i : in std_logic_vector(2 downto 0);
        funct7_i : in std_logic_vector(6 downto 0);
        --******** Datapath outputs ********
        alu_op_o : out std_logic_vector(4 downto 0)
    );
end entity alu_decoder;

architecture behavioral of alu_decoder is
    signal funct7_5_s : std_logic;
begin

    funct7_5_s <= funct7_i(5);

    alu_dec : process(alu_2bit_op_i, funct3_i, funct7_i, funct7_5_s) is
    begin
        --default
        alu_op_o <= "00010"; -- add

        case alu_2bit_op_i is
            when "00" =>
                alu_op_o <= "00010"; -- add
            when "01" =>
                case funct3_i is
                    when "000" =>
                        alu_op_o <= "00000"; -- and
                    when "001" =>
                        alu_op_o <= "00001"; -- or
                    when "010" =>
                        alu_op_o <= "00010"; -- add
                        if funct7_5_s = '1' then
                            alu_op_o <= "00110"; -- sub
                        end if;
                    when "111" =>
                        alu_op_o <= "00101"; -- slt
                end case;
            when "10" =>
                case funct3_i is
                    when "010" =>
                        alu_op_o <= "00101"; -- slt
                    when "011" =>
                        alu_op_o <= "00111"; -- slti
                end case;
        end case;
    end process alu_dec;
   
end architecture behavioral;