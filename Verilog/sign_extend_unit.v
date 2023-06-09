module sign_extend_unit #(parameter SHORT_SIZE = 9, parameter LONG_SIZE = 16) (
  input [SHORT_SIZE - 1:0] short_operand,
  input enable,
  output [LONG_SIZE - 1:0] long_operand
  );
  assign long_operand = { {(LONG_SIZE - SHORT_SIZE){short_operand[SHORT_SIZE - 1]}}, short_operand[SHORT_SIZE - 1:0] };
endmodule