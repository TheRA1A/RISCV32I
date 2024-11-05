module mem_access_control (
    input  logic [ 2:0] mem_size,
    input  logic [31:0] addr,
    output logic [ 3:0] byte_enable,
    input  logic [31:0] read_data,
    output logic [31:0] formatted_read_data
);
  always_comb begin
    // Default values
    byte_enable = 4'b0000;
    formatted_read_data = 32'b0;

    case (mem_size)
      3'b000: begin  // Byte
        case (addr[1:0])
          2'b00: begin
            byte_enable = 4'b0001;
            formatted_read_data = {{24{read_data[7]}}, read_data[7:0]};
          end
          2'b01: begin
            byte_enable = 4'b0010;
            formatted_read_data = {{24{read_data[15]}}, read_data[15:8]};
          end
          2'b10: begin
            byte_enable = 4'b0100;
            formatted_read_data = {{24{read_data[23]}}, read_data[23:16]};
          end
          2'b11: begin
            byte_enable = 4'b1000;
            formatted_read_data = {{24{read_data[31]}}, read_data[31:24]};
          end
        endcase
      end

      3'b001: begin  // Half-word
        case (addr[1])
          1'b0: begin
            byte_enable = 4'b0011;
            formatted_read_data = {{16{read_data[15]}}, read_data[15:0]};
          end
          1'b1: begin
            byte_enable = 4'b1100;
            formatted_read_data = {{16{read_data[31]}}, read_data[31:16]};
          end
        endcase
      end

      3'b010: begin  // Word
        byte_enable = 4'b1111;
        formatted_read_data = read_data;
      end

      default: begin
        byte_enable = 4'b0000;
        formatted_read_data = 32'b0;
      end
    endcase
  end
endmodule
