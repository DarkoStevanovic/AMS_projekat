library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all_pkg.all;

entity TOP_RISCV is
generic (DATA_WIDTH : positive := 32);
port(
-- ********* Globalna sinhronizacija ******************
clk : in std_logic;
reset : in std_logic;
-- ********* Interfejs ka Memoriji za instrukcije *****
instr_mem_address_o : out std_logic_vector (31 downto 0);
instr_mem_read_i : in std_logic_vector(31 downto 0);
-- ********* Interfejs ka Memoriji za podatke *********
data_mem_we_o : out std_logic_vector(3 downto 0);
data_mem_address_o : out std_logic_vector(31 downto 0);
data_mem_write_o : out std_logic_vector(31 downto 0);
data_mem_read_i : in std_logic_vector (31 downto 0));
end entity;

architecture structural of TOP_RISCV is
  -- Signals for connecting the control path and data path
  signal comp_s                   : signed(DATA_WIDTH - 1 downto 0);
  signal instr_mem_read_op_s      : std_logic_vector (31 downto 0);
  signal mem_to_reg_s             : std_logic;
  signal alu_op_s                 : std_logic_vector (4 downto 0);
  signal pc_next_sel_s            : std_logic;
  signal alu_src_s                : std_logic;
  signal rd_we_s                  : std_logic;
  signal data_mem_we_s            : std_logic_vector (3 downto 0);
  signal rs1_data_s               : std_logic_vector (DATA_WIDTH - 1 downto 0);
  signal rs2_data_s               : std_logic_vector (DATA_WIDTH - 1 downto 0);
  signal mem_data_s               : std_logic_vector (DATA_WIDTH - 1 downto 0);
  signal branch_condition_s       : std_logic;
  signal mem_address_s            : std_logic_vector (31 downto 0);
  signal mem_write_s              : std_logic_vector (DATA_WIDTH - 1 downto 0);
  signal rd_data_s                : std_logic_vector (DATA_WIDTH - 1 downto 0);
           
begin
     -- Data_path instance
   data_path_1: entity work.data_path
      port map (
            clk  => clk,
            reset => reset,
            instr_mem_address_o => instr_mem_address_o,
            instr_mem_read_i    => instr_mem_read_i,
            data_mem_address_o  => data_mem_address_o,
            data_mem_write_o    => data_mem_write_o,
            data_mem_read_i     => data_mem_read_i,
            mem_to_reg_i        => mem_to_reg_s,
            alu_op_i            => alu_op_s,
            rd_we_i             => rd_we_s,
            pc_next_sel_i       => pc_next_sel_s,
            alu_src_i           => alu_src_s,
            branch_condition_o  => branch_condition_s
        );
         
         -- Control_path instance
   control_path_1: entity work.control_path
      port map (
         -- global synchronization signals
         clk                 => clk,
         reset               => reset,
         -- instruction is read from memory
         instruction_i       => instr_mem_read_i,
         -- control signals are forwarded to data_path
         mem_to_reg_o        => mem_to_reg_s,
         alu_op_o            => alu_op_s,
         alu_src_o         => alu_src_s,
         rd_we_o             => rd_we_s,
         pc_next_sel_o       => pc_next_sel_s,
         -- control signals for forwarding
         branch_condition_i  => branch_condition_s
         );
   

end architecture;
