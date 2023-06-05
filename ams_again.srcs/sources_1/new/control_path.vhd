library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_path is
port (clk : in std_logic;
reset : in std_logic;
-- ********* Interfejs za prihvat instrukcije iz datapath-a*********
instruction_i : in std_logic_vector (31 downto 0);
-- ********* Kontrolni intefejs *************************************
mem_to_reg_o : out std_logic;
alu_op_o : out std_logic_vector(4 downto 0);
pc_next_sel_o : out std_logic;
alu_src_o : out std_logic;
rd_we_o : out std_logic;
--********** Ulazni Statusni interfejs**************************************
branch_condition_i : in std_logic;
--********** Izlazni Statusni interfejs**************************************
data_mem_we_o : out std_logic_vector(3 downto 0)
);
end entity;

architecture behavioral of control_path is

   
   --*********  INSTRUCTION DECODE **************
   signal branch_id_s       : std_logic;
   signal funct3_id_s       : std_logic_vector(2 downto 0);
   signal funct7_id_s       : std_logic_vector(6 downto 0);
   signal alu_2bit_op_id_s  : std_logic_vector(1 downto 0);
   
   signal control_pass_s    : std_logic;
   signal rs1_in_use_id_s   : std_logic;
   signal rs2_in_use_id_s   : std_logic;
   signal alu_src_b_id_s    : std_logic;

   signal data_mem_we_id_s  : std_logic;
   signal rd_we_id_s        : std_logic;
   signal mem_to_reg_id_s   : std_logic;
   signal rs1_address_id_s  : std_logic_vector (4 downto 0);
   signal rs2_address_id_s  : std_logic_vector (4 downto 0);
   signal rd_address_id_s   : std_logic_vector (4 downto 0);
   --*********       EXECUTE       **************

   signal funct3_ex_s       : std_logic_vector(2 downto 0);
   signal funct7_ex_s       : std_logic_vector(6 downto 0);
   signal alu_2bit_op_ex_s  : std_logic_vector(1 downto 0);

   signal alu_src_b_ex_s    : std_logic;

   signal data_mem_we_ex_s  : std_logic;
   signal rd_we_ex_s        : std_logic;
   signal mem_to_reg_ex_s   : std_logic;

   signal rs1_address_ex_s  : std_logic_vector (4 downto 0);
   signal rs2_address_ex_s  : std_logic_vector (4 downto 0);
   signal rd_address_ex_s   : std_logic_vector (4 downto 0);

   --*********       MEMORY        **************

   signal data_mem_we_mem_s : std_logic;
   signal rd_we_mem_s       : std_logic;
   signal mem_to_reg_mem_s  : std_logic;

   signal rd_address_mem_s  : std_logic_vector (4 downto 0);

   --*********      WRITEBACK      **************
   
   signal rd_we_wb_s        : std_logic;
   signal mem_to_reg_wb_s   : std_logic;
   signal rd_address_wb_s   : std_logic_vector (4 downto 0);

begin


   rs1_address_id_s <= instruction_i(19 downto 15);
   rs2_address_id_s <= instruction_i(24 downto 20);
   rd_address_id_s  <= instruction_i(11 downto 7);

   funct7_id_s <= instruction_i(31 downto 25);
   

   data_mem_write_decoder :
      data_mem_we_o <= "0001" when data_mem_we_mem_s = '1' else
                       "0011" when data_mem_we_mem_s = '1' else
                       "1111" when data_mem_we_mem_s = '1' else
                       "0000";











   --*********** Instantiation ******************

   -- Control decoder
   ctrl_dec : entity work.ctrl_decoder(behavioral)
      port map(
         opcode_i      => instruction_i(6 downto 0),
         branch_o => branch_id_s,
         mem_to_reg_o  => mem_to_reg_id_s,
         data_mem_we_o => data_mem_we_id_s,
         rd_we_o       => rd_we_id_s,

         alu_2bit_op_o => alu_2bit_op_id_s);

   -- ALU decoder
   alu_dec : entity work.alu_decoder(behavioral)
      port map(
         alu_2bit_op_i => alu_2bit_op_ex_s,
         funct3_i      => funct3_ex_s,
         funct7_i      => funct7_ex_s,
         alu_op_o      => alu_op_o);

end architecture;
