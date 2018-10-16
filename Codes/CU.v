module controller(input[5:0] opcode, output WB_En,output[1:0] Mem_Signals, output[1:0] Branch_Type, output[3:0] Exe_Cmd, output isImm);

	case (opcode)
		6'b000000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b0000000000; // NOP
		6'b000001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000000000; // ADD
		6'b000011: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000000100; // SUB
		6'b000101: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000001000; // AND
		6'b000110: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000001010; // OR
		6'b000111: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000001100; // NOR
		6'b001000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000001110; // XOR
		6'b001001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000010000; // SLA
		6'b001010: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000010000; // SLL
		6'b001011: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000010010; // SRA
		6'b001100: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000010100; // SRL
		6'b100000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000000001; // ADDI
		6'b100001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1000000101; // SUBI
		6'b100100: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b1100000001; // LD
		6'b100101: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b0010000001; // ST
		6'b101000: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b0000100001; // BEZ
		6'b101001: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b0001000001; // BNE
		6'b101010: {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b0001000001; // JMP

		default : {WB_En, Mem_Signals, Branch_Type, Exe_Cmd, isImm} = 10'b0000000000; // NOP
	endcase

endmodule // controller