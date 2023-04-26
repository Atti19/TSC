/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test(tb_ifc.TB tbif);
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  
  //timeunit 1ns/1ns;
  parameter NUMBER_OF_TRANSACTIONS = 10;
  parameter inc_or_rand = 0;
  parameter seed = 77777; //procedura prin care se initializeaza secventa de generare a numerelor random (pentru a reproduce sirul)
  rezultat_t expected_res;
      int counter = 0;

  function rezultat_t expected_calc;
    case(tbif.opcode)
      ZERO : return 0;
      PASSA: return instruction_word.operand_a;
      PASSB: return instruction_word.operand_b;
      ADD : return instruction_word.operand_a + instruction_word.operand_b;
      SUB : return instruction_word.operand_a - instruction_word.operand_b;
      MULT: return instruction_word.operand_a * instruction_word.operand_b;
      DIV : return instruction_word.operand_a / instruction_word.operand_b;
      MOD : return instruction_word.operand_a % instruction_word.operand_b;
      default: return 0;
    endcase
  endfunction: expected_calc

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    tbif.write_pointer  = 5'h00;         // initialize write pointer
    tbif.read_pointer   = 5'h1F;         // initialize read pointer
    tbif.load_en        = 1'b0;          // initialize load control line
    tbif.reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge tbif.test_clk) ;     // hold in reset for 2 clock cycles
    tbif.reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    //@(posedge test_clk) load_en = 1'b1;  // enable writing to register
    repeat (NUMBER_OF_TRANSACTIONS) begin
      @(posedge tbif.test_clk) begin
        tbif.load_en <= 1'b1;
        randomize_transaction;
      end             
      @(negedge tbif.test_clk) print_transaction;
    end
    @(posedge tbif.test_clk) tbif.load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<=NUMBER_OF_TRANSACTIONS; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      if(inc_or_rand == 0 || inc_or_rand == 1)
        @(posedge tbif.test_clk) tbif.read_pointer = i;
      if(inc_or_rand == 2 || inc_or_rand == 3)  
        @(posedge tbif.test_clk) tbif.read_pointer = $unsigned($urandom())%32;
      @(negedge tbif.test_clk) print_results;

     expected_res = expected_calc;

    if (expected_res != tbif.instruction_word.rez) begin
        counter++;
        $display("error at %0d, the expected is : %0d , actual is : %0d", tbif.read_pointer, expected_res, tbif.instruction_word.rez);
    end
    end
    if(counter == 0) begin
      $display("Test passed");
    end
    else begin
      $display("Test failed, errors: %0d", counter);
    end

    @(posedge tbif.test_clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    tbif.operand_a     <= $urandom()%16;                 // between -15 and 15
    tbif.operand_b     <= $unsigned($urandom())%16;            // between 0 and 15
    tbif.opcode        <= opcode_t'($unsigned($urandom())%8);  // between 0 and 7, cast to opcode_t type
    if (inc_or_rand == 1 || inc_or_rand == 3)
      tbif.write_pointer <= $unsigned($urandom())%32;
    if (inc_or_rand == 0 || inc_or_rand == 2) begin
    for (int i=0; i<=NUMBER_OF_TRANSACTIONS; i++) begin
      tbif.write_pointer <= i;
    end
    end
  endfunction: randomize_transaction



  function void print_transaction;
    $display("Writing to register location %0d: ", tbif.write_pointer);
    $display("  opcode = %0d (%s)", tbif.opcode, tbif.opcode.name);
    $display("  operand_a = %0d",   tbif.operand_a);
    $display("  operand_b = %0d\n", tbif.operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", tbif.read_pointer);
    $display("  opcode = %0d (%s)", tbif.instruction_word.opc, tbif.instruction_word.opc.name);
    $display("  operand_a = %0d",   tbif.instruction_word.op_a);
    $display("  operand_b = %0d",   tbif.instruction_word.op_b);
    $display("  rezultat = %0d\n",  tbif.instruction_word.rez);
  endfunction: print_results

endmodule: instr_register_test
