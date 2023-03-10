/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/

module instr_register
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
(input  logic          clk,
 input  logic          load_en,
 input  logic          reset_n,
 input  operand_t      operand_a,
 input  operand_t      operand_b,
 input  opcode_t       opcode,
 input  address_t      write_pointer,
 input  address_t      read_pointer,
 output instruction_t  instruction_word
);
  timeunit 1ns/1ns;

  instruction_t  iw_reg [0:31];  // an array of instruction_word structures
  rezultat_t rez; 

  //functia care calculeaza rezultatul in functie de opcode
  function rezultat_t rezultat_c(input operand_t operand_a, operand_t operand_b, opcode_t opcode);
    case(opcode)
      ZERO : return 0;
      PASSA: return operand_a;
      PASSB: return operand_b;
      ADD : return operand_a + operand_b;
      SUB : return operand_a - operand_b;
      MULT: return operand_a * operand_b;
      DIV : return operand_a / operand_b;
      MOD : return operand_a % operand_b;
      default: return 0;
    endcase
  endfunction

  // write to the register
  always@(posedge clk, negedge reset_n)   // write into register
    if (!reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros
    end
    else if (load_en) begin
      rez = rezultat_c(operand_a, operand_b, opcode);
      iw_reg[write_pointer] = '{opcode,operand_a,operand_b, rez};
    end

  // read from the register
  assign instruction_word = iw_reg[read_pointer];  // continuously read from register
  
// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force operand_b = operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule: instr_register
