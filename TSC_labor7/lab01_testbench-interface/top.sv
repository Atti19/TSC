/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/

module top;
  timeunit 1ns/1ns; //directiva de compilator, care seteaza timpul de simulare ( rezolutia si timpul )

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // clock variables
  logic clk; //0,1,x,z x-unknown, z-undefined, sunt pe 1 bit
  logic test_clk;
  // interconnecting signals
  //logic          load_en; //enable
  //logic          reset_n; //reset_negat
  //opcode_t       opcode; //t-template, user-defined 
  //operand_t      operand_a, operand_b;
  //address_t      write_pointer, read_pointer;
  //instruction_t  instruction_word;

  // instantiate testbench and connect ports
  //instr_register_test test (
  //  .clk(test_clk),
  //  .load_en(load_en),
  //  .reset_n(reset_n),
  //  .operand_a(operand_a),
  //  .operand_b(operand_b),
  //  .opcode(opcode),
  //  .write_pointer(write_pointer),
  //  .read_pointer(read_pointer),
  //  .instruction_word(instruction_word)
  // );

  //// instantiate design and connect ports
//  instr_register dut (
//    .clk(clk),
//    .load_en(load_en),
//    .reset_n(reset_n),
//    .operand_a(operand_a),
//    .operand_b(operand_b),
//    .opcode(opcode),
//    .write_pointer(write_pointer),
//    .read_pointer(read_pointer),
//    .instruction_word(instruction_word)
//   );
  
  tb_ifc tbif(clk, test_clk);
  instr_register dut(
    .tbif(tbif)
  );
  
  instr_register_test test(
    .tbif(tbif)
  );
  // clock oscillators
  initial begin
    clk <= 0;
    forever #5  clk = ~clk; // #5-asteapta 5 unitati de timp
  end

  initial begin
    test_clk <=0;
    // offset test_clk edges from clk to prevent races between
    // the testbench and the design
    #4 forever begin
      #2ns test_clk = 1'b1;
      #8ns test_clk = 1'b0;
    end
  end

endmodule: top
