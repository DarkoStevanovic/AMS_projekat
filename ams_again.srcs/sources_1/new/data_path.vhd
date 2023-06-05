library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.all_pkg.all;

entity data_path is
generic (DATA_WIDTH : positive := 32);
port(
-- ********* Globalna sinhronizacija ******************
clk : in std_logic;
reset : in std_logic;
-- ********* Interfejs ka Memoriji za instrukcije *****
instr_mem_address_o : out std_logic_vector(31 downto 0);
instr_mem_read_i : in std_logic_vector(31 downto 0);
instruction_o : out std_logic_vector(31 downto 0);
-- ********* Interfejs ka Memoriji za podatke *****
data_mem_address_o : out std_logic_vector(31 downto 0);
data_mem_write_o : out std_logic_vector(31 downto 0);
data_mem_read_i : in std_logic_vector(31 downto 0);
-- ********* Kontrolni signali ************************
mem_to_reg_i : in std_logic;
alu_op_i : in std_logic_vector(4 downto 0);
pc_next_sel_i : in std_logic;
alu_src_i : in std_logic;
rd_we_i : in std_logic;
-- ********* Statusni signali *************************
branch_condition_o : out std_logic
-- ******************************************************
);
end entity;
architecture Behavioral of data_path is

	   --*********  INSTRUCTION FETCH  **************
	   
   signal pc_reg_if_s             : std_logic_vector (31 downto 0);
   signal pc_next_if_s            : std_logic_vector (31 downto 0);
   signal pc_adder_if_s           : std_logic_vector (31 downto 0);

   --*********  INSTRUCTION DECODE **************
   signal pc_adder_id_s           : std_logic_vector (31 downto 0);
   signal pc_reg_id_s             : std_logic_vector (31 downto 0);
   signal rs1_data_id_s           : std_logic_vector (31 downto 0);
   signal rs2_data_id_s           : std_logic_vector (31 downto 0);
   signal immediate_extended_id_s : std_logic_vector (31 downto 0);
   signal rs1_address_id_s        : std_logic_vector (4 downto 0);
   signal rs2_address_id_s        : std_logic_vector (4 downto 0);
   signal rd_address_id_s         : std_logic_vector (4 downto 0);
   signal if_id_reg_flush_s       : std_logic;

   --*********       EXECUTE       **************
   signal pc_adder_ex_s           : std_logic_vector (31 downto 0);
   signal pc_reg_ex_s             : std_logic_vector (31 downto 0);
   signal immediate_extended_ex_s : std_logic_vector (31 downto 0);
   signal alu_forward_a_ex_s      : std_logic_vector(31 downto 0);
   signal alu_forward_b_ex_s      : std_logic_vector(31 downto 0);
   signal b_ex_s                  : std_logic_vector(31 downto 0);
   signal alu_result_ex_s         : std_logic_vector(31 downto 0);
   signal rs1_data_ex_s           : std_logic_vector (31 downto 0);
   signal rs2_data_ex_s           : std_logic_vector (31 downto 0);
   signal rd_address_ex_s         : std_logic_vector (4 downto 0);

   --*********       MEMORY        **************
   signal alu_result_mem_s        : std_logic_vector(31 downto 0);
   signal rd_address_mem_s        : std_logic_vector (4 downto 0);
   signal rs2_data_mem_s          : std_logic_vector (31 downto 0);

   --*********      WRITEBACK      **************
   signal alu_result_wb_s         : std_logic_vector(31 downto 0);
   signal extended_data_wb_s      : std_logic_vector (31 downto 0);
   signal rd_data_wb_s            : std_logic_vector (31 downto 0);
   signal rd_address_wb_s         : std_logic_vector (4 downto 0);
   
   signal comp_s                  :signed;

begin

     --***********  Combinational logic  ***************


   --pc_adder_s update
   pc_adder_if_s <= std_logic_vector(unsigned(pc_reg_if_s) + to_unsigned(4, 32));



   --branch condition 
   branch_condition_o <='1' when ((signed(alu_forward_a_ex_s) = signed(alu_forward_b_ex_s))) else
                        '0';
   --pc_next mux
   with pc_next_sel_i select
      pc_next_if_s <=   pc_adder_if_s when '0',
						alu_result_ex_s when others;


 

   -- reg_bank rd_data update
	with mem_to_reg_i select
		rd_data_wb_s <=     extended_data_wb_s when '1',
							alu_result_wb_s when others;

   -- extend data based on type of load instruction
   with instr_mem_read_i(14 downto 12) select
      extended_data_wb_s <= 
      (31 downto 16 => data_mem_read_i(15)) & data_mem_read_i(15 downto 0) when "001",  --lh
      data_mem_read_i                                                      when others; --lw

   -- izvlacenje adresa iz instrukcija
   rs1_address_id_s <= instr_mem_read_i(19 downto 15);
   rs2_address_id_s <= instr_mem_read_i(24 downto 20);
   rd_address_id_s  <= instr_mem_read_i(11 downto 7);

   ------------Instance----------------
   --Register_bank
   rb1 : entity work.register_bank
      generic map (
         WIDTH => 32)
      port map (
         clk           => clk,
         reset         => reset,
         rd_we_i       => rd_we_i,
         rs1_address_i => rs1_address_id_s,
         rs2_address_i => rs2_address_id_s,
         rs1_data_o    => rs1_data_id_s,
         rs2_data_o    => rs2_data_id_s,
         rd_address_i  => rd_address_wb_s,
         rd_data_i     => rd_data_wb_s);

   --Immediate
   imm1 : entity work.immediate
      port map (
         instruction_i        => instr_mem_read_i,
         immediate_extended_o => immediate_extended_id_s);

   ALU1: entity work.ALU
      generic map (
         WIDTH => 32)
      port map (
         a_i    => alu_forward_a_ex_s,
         b_i    => b_ex_s,
         op_i   => alu_op_i,
         res_o  => alu_result_ex_s,
         comp_i =>comp_s);
         
	

   --------------------Izlazi-------------------
   --From instruction memory
   instr_mem_address_o <= pc_reg_if_s;
   --To data memory
   data_mem_address_o  <= alu_result_mem_s;
   data_mem_write_o    <= rs2_data_mem_s;

end architecture;