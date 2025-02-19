// Generator : SpinalHDL dev    git head : 81793df2c4f55a20f7eff1130c4bb74a4b11319f
// Component : EfxDMA
// Git hash  : 1558bdd6853dbd84203950b742f9be988c2ee970

`timescale 1ns/1ps

module EfxDMA (
  input  wire [13:0]   ctrl_PADDR,
  input  wire [0:0]    ctrl_PSEL,
  input  wire          ctrl_PENABLE,
  output wire          ctrl_PREADY,
  input  wire          ctrl_PWRITE,
  input  wire [31:0]   ctrl_PWDATA,
  output wire [31:0]   ctrl_PRDATA,
  output wire          ctrl_PSLVERROR,
  output wire [1:0]    ctrl_interrupts,
  output wire          read_arvalid,
  input  wire          read_arready,
  output wire [31:0]   read_araddr,
  output wire [3:0]    read_arregion,
  output wire [7:0]    read_arlen,
  output wire [2:0]    read_arsize,
  output wire [1:0]    read_arburst,
  output wire [0:0]    read_arlock,
  output wire [3:0]    read_arcache,
  output wire [3:0]    read_arqos,
  output wire [2:0]    read_arprot,
  input  wire          read_rvalid,
  output wire          read_rready,
  input  wire [127:0]  read_rdata,
  input  wire [1:0]    read_rresp,
  input  wire          read_rlast,
  output wire          write_awvalid,
  input  wire          write_awready,
  output wire [31:0]   write_awaddr,
  output wire [3:0]    write_awregion,
  output wire [7:0]    write_awlen,
  output wire [2:0]    write_awsize,
  output wire [1:0]    write_awburst,
  output wire [0:0]    write_awlock,
  output wire [3:0]    write_awcache,
  output wire [3:0]    write_awqos,
  output wire [2:0]    write_awprot,
  output wire          write_wvalid,
  input  wire          write_wready,
  output wire [127:0]  write_wdata,
  output wire [15:0]   write_wstrb,
  output wire          write_wlast,
  input  wire          write_bvalid,
  output wire          write_bready,
  input  wire [1:0]    write_bresp,
  input  wire          dat0_i_tvalid,
  output wire          dat0_i_tready,
  input  wire [7:0]    dat0_i_tdata,
  input  wire [0:0]    dat0_i_tkeep,
  input  wire [3:0]    dat0_i_tdest,
  input  wire          dat0_i_tlast,
  output wire          dat1_o_tvalid,
  input  wire          dat1_o_tready,
  output wire [7:0]    dat1_o_tdata,
  output wire [0:0]    dat1_o_tkeep,
  output wire [3:0]    dat1_o_tdest,
  output wire          dat1_o_tlast,
  output wire          io_0_descriptorUpdate,
  output wire          io_1_descriptorUpdate,
  input  wire          clk,
  input  wire          reset,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset,
  input  wire          dat0_i_clk,
  input  wire          dat0_i_reset,
  input  wire          dat1_o_clk,
  input  wire          dat1_o_reset
);

  wire                core_io_sgRead_cmd_valid;
  wire                core_io_sgRead_cmd_payload_last;
  wire       [0:0]    core_io_sgRead_cmd_payload_fragment_opcode;
  wire       [31:0]   core_io_sgRead_cmd_payload_fragment_address;
  wire       [4:0]    core_io_sgRead_cmd_payload_fragment_length;
  wire       [0:0]    core_io_sgRead_cmd_payload_fragment_context;
  wire                core_io_sgRead_rsp_ready;
  wire                core_io_sgWrite_cmd_valid;
  wire                core_io_sgWrite_cmd_payload_last;
  wire       [0:0]    core_io_sgWrite_cmd_payload_fragment_opcode;
  wire       [31:0]   core_io_sgWrite_cmd_payload_fragment_address;
  wire       [1:0]    core_io_sgWrite_cmd_payload_fragment_length;
  wire       [63:0]   core_io_sgWrite_cmd_payload_fragment_data;
  wire       [7:0]    core_io_sgWrite_cmd_payload_fragment_mask;
  wire       [0:0]    core_io_sgWrite_cmd_payload_fragment_context;
  wire                core_io_sgWrite_rsp_ready;
  wire                core_io_read_cmd_valid;
  wire                core_io_read_cmd_payload_last;
  wire       [0:0]    core_io_read_cmd_payload_fragment_opcode;
  wire       [31:0]   core_io_read_cmd_payload_fragment_address;
  wire       [10:0]   core_io_read_cmd_payload_fragment_length;
  wire       [17:0]   core_io_read_cmd_payload_fragment_context;
  wire                core_io_read_rsp_ready;
  wire                core_io_write_cmd_valid;
  wire                core_io_write_cmd_payload_last;
  wire       [0:0]    core_io_write_cmd_payload_fragment_opcode;
  wire       [31:0]   core_io_write_cmd_payload_fragment_address;
  wire       [10:0]   core_io_write_cmd_payload_fragment_length;
  wire       [63:0]   core_io_write_cmd_payload_fragment_data;
  wire       [7:0]    core_io_write_cmd_payload_fragment_mask;
  wire       [11:0]   core_io_write_cmd_payload_fragment_context;
  wire                core_io_write_rsp_ready;
  wire                core_io_outputs_0_valid;
  wire       [31:0]   core_io_outputs_0_payload_data;
  wire       [3:0]    core_io_outputs_0_payload_mask;
  wire       [3:0]    core_io_outputs_0_payload_sink;
  wire                core_io_outputs_0_payload_last;
  wire                core_io_inputs_0_ready;
  wire       [1:0]    core_io_interrupts;
  wire                core_io_ctrl_PREADY;
  wire       [31:0]   core_io_ctrl_PRDATA;
  wire                core_io_ctrl_PSLVERROR;
  wire                core_ll_0_descriptorUpdate;
  wire                core_ll_1_descriptorUpdate;
  wire                withCtrlCc_apbCc_io_input_PREADY;
  wire       [31:0]   withCtrlCc_apbCc_io_input_PRDATA;
  wire                withCtrlCc_apbCc_io_input_PSLVERROR;
  wire       [13:0]   withCtrlCc_apbCc_io_output_PADDR;
  wire       [0:0]    withCtrlCc_apbCc_io_output_PSEL;
  wire                withCtrlCc_apbCc_io_output_PENABLE;
  wire                withCtrlCc_apbCc_io_output_PWRITE;
  wire       [31:0]   withCtrlCc_apbCc_io_output_PWDATA;
  wire       [1:0]    io_interrupts_buffercc_io_dataOut;
  wire                bmbUpSizerBridge_io_input_cmd_ready;
  wire                bmbUpSizerBridge_io_input_rsp_valid;
  wire                bmbUpSizerBridge_io_input_rsp_payload_last;
  wire       [0:0]    bmbUpSizerBridge_io_input_rsp_payload_fragment_source;
  wire       [0:0]    bmbUpSizerBridge_io_input_rsp_payload_fragment_opcode;
  wire       [63:0]   bmbUpSizerBridge_io_input_rsp_payload_fragment_data;
  wire       [17:0]   bmbUpSizerBridge_io_input_rsp_payload_fragment_context;
  wire                bmbUpSizerBridge_io_output_cmd_valid;
  wire                bmbUpSizerBridge_io_output_cmd_payload_last;
  wire       [0:0]    bmbUpSizerBridge_io_output_cmd_payload_fragment_source;
  wire       [0:0]    bmbUpSizerBridge_io_output_cmd_payload_fragment_opcode;
  wire       [31:0]   bmbUpSizerBridge_io_output_cmd_payload_fragment_address;
  wire       [10:0]   bmbUpSizerBridge_io_output_cmd_payload_fragment_length;
  wire       [19:0]   bmbUpSizerBridge_io_output_cmd_payload_fragment_context;
  wire                bmbUpSizerBridge_io_output_rsp_ready;
  wire                readLogic_sourceRemover_io_input_cmd_ready;
  wire                readLogic_sourceRemover_io_input_rsp_valid;
  wire                readLogic_sourceRemover_io_input_rsp_payload_last;
  wire       [0:0]    readLogic_sourceRemover_io_input_rsp_payload_fragment_source;
  wire       [0:0]    readLogic_sourceRemover_io_input_rsp_payload_fragment_opcode;
  wire       [127:0]  readLogic_sourceRemover_io_input_rsp_payload_fragment_data;
  wire       [19:0]   readLogic_sourceRemover_io_input_rsp_payload_fragment_context;
  wire                readLogic_sourceRemover_io_output_cmd_valid;
  wire                readLogic_sourceRemover_io_output_cmd_payload_last;
  wire       [0:0]    readLogic_sourceRemover_io_output_cmd_payload_fragment_opcode;
  wire       [31:0]   readLogic_sourceRemover_io_output_cmd_payload_fragment_address;
  wire       [10:0]   readLogic_sourceRemover_io_output_cmd_payload_fragment_length;
  wire       [20:0]   readLogic_sourceRemover_io_output_cmd_payload_fragment_context;
  wire                readLogic_sourceRemover_io_output_rsp_ready;
  wire                readLogic_bridge_io_input_cmd_ready;
  wire                readLogic_bridge_io_input_rsp_valid;
  wire                readLogic_bridge_io_input_rsp_payload_last;
  wire       [0:0]    readLogic_bridge_io_input_rsp_payload_fragment_opcode;
  wire       [127:0]  readLogic_bridge_io_input_rsp_payload_fragment_data;
  wire       [20:0]   readLogic_bridge_io_input_rsp_payload_fragment_context;
  wire                readLogic_bridge_io_output_ar_valid;
  wire       [31:0]   readLogic_bridge_io_output_ar_payload_addr;
  wire       [7:0]    readLogic_bridge_io_output_ar_payload_len;
  wire       [2:0]    readLogic_bridge_io_output_ar_payload_size;
  wire       [3:0]    readLogic_bridge_io_output_ar_payload_cache;
  wire       [2:0]    readLogic_bridge_io_output_ar_payload_prot;
  wire                readLogic_bridge_io_output_r_ready;
  wire                bmbUpSizerBridge_1_io_input_cmd_ready;
  wire                bmbUpSizerBridge_1_io_input_rsp_valid;
  wire                bmbUpSizerBridge_1_io_input_rsp_payload_last;
  wire       [0:0]    bmbUpSizerBridge_1_io_input_rsp_payload_fragment_source;
  wire       [0:0]    bmbUpSizerBridge_1_io_input_rsp_payload_fragment_opcode;
  wire       [11:0]   bmbUpSizerBridge_1_io_input_rsp_payload_fragment_context;
  wire                bmbUpSizerBridge_1_io_output_cmd_valid;
  wire                bmbUpSizerBridge_1_io_output_cmd_payload_last;
  wire       [0:0]    bmbUpSizerBridge_1_io_output_cmd_payload_fragment_source;
  wire       [0:0]    bmbUpSizerBridge_1_io_output_cmd_payload_fragment_opcode;
  wire       [31:0]   bmbUpSizerBridge_1_io_output_cmd_payload_fragment_address;
  wire       [10:0]   bmbUpSizerBridge_1_io_output_cmd_payload_fragment_length;
  wire       [127:0]  bmbUpSizerBridge_1_io_output_cmd_payload_fragment_data;
  wire       [15:0]   bmbUpSizerBridge_1_io_output_cmd_payload_fragment_mask;
  wire       [11:0]   bmbUpSizerBridge_1_io_output_cmd_payload_fragment_context;
  wire                bmbUpSizerBridge_1_io_output_rsp_ready;
  wire                writeLogic_sourceRemover_io_input_cmd_ready;
  wire                writeLogic_sourceRemover_io_input_rsp_valid;
  wire                writeLogic_sourceRemover_io_input_rsp_payload_last;
  wire       [0:0]    writeLogic_sourceRemover_io_input_rsp_payload_fragment_source;
  wire       [0:0]    writeLogic_sourceRemover_io_input_rsp_payload_fragment_opcode;
  wire       [11:0]   writeLogic_sourceRemover_io_input_rsp_payload_fragment_context;
  wire                writeLogic_sourceRemover_io_output_cmd_valid;
  wire                writeLogic_sourceRemover_io_output_cmd_payload_last;
  wire       [0:0]    writeLogic_sourceRemover_io_output_cmd_payload_fragment_opcode;
  wire       [31:0]   writeLogic_sourceRemover_io_output_cmd_payload_fragment_address;
  wire       [10:0]   writeLogic_sourceRemover_io_output_cmd_payload_fragment_length;
  wire       [127:0]  writeLogic_sourceRemover_io_output_cmd_payload_fragment_data;
  wire       [15:0]   writeLogic_sourceRemover_io_output_cmd_payload_fragment_mask;
  wire       [12:0]   writeLogic_sourceRemover_io_output_cmd_payload_fragment_context;
  wire                writeLogic_sourceRemover_io_output_rsp_ready;
  wire                writeLogic_bridge_io_input_cmd_ready;
  wire                writeLogic_bridge_io_input_rsp_valid;
  wire                writeLogic_bridge_io_input_rsp_payload_last;
  wire       [0:0]    writeLogic_bridge_io_input_rsp_payload_fragment_opcode;
  wire       [12:0]   writeLogic_bridge_io_input_rsp_payload_fragment_context;
  wire                writeLogic_bridge_io_output_aw_valid;
  wire       [31:0]   writeLogic_bridge_io_output_aw_payload_addr;
  wire       [7:0]    writeLogic_bridge_io_output_aw_payload_len;
  wire       [2:0]    writeLogic_bridge_io_output_aw_payload_size;
  wire       [3:0]    writeLogic_bridge_io_output_aw_payload_cache;
  wire       [2:0]    writeLogic_bridge_io_output_aw_payload_prot;
  wire                writeLogic_bridge_io_output_w_valid;
  wire       [127:0]  writeLogic_bridge_io_output_w_payload_data;
  wire       [15:0]   writeLogic_bridge_io_output_w_payload_strb;
  wire                writeLogic_bridge_io_output_w_payload_last;
  wire                writeLogic_bridge_io_output_b_ready;
  wire                inputsAdapter_0_upsizer_logic_io_input_ready;
  wire                inputsAdapter_0_upsizer_logic_io_output_valid;
  wire       [31:0]   inputsAdapter_0_upsizer_logic_io_output_payload_data;
  wire       [3:0]    inputsAdapter_0_upsizer_logic_io_output_payload_mask;
  wire       [3:0]    inputsAdapter_0_upsizer_logic_io_output_payload_sink;
  wire                inputsAdapter_0_upsizer_logic_io_output_payload_last;
  wire                inputsAdapter_0_crossclock_fifo_io_push_ready;
  wire                inputsAdapter_0_crossclock_fifo_io_pop_valid;
  wire       [31:0]   inputsAdapter_0_crossclock_fifo_io_pop_payload_data;
  wire       [3:0]    inputsAdapter_0_crossclock_fifo_io_pop_payload_mask;
  wire       [3:0]    inputsAdapter_0_crossclock_fifo_io_pop_payload_sink;
  wire                inputsAdapter_0_crossclock_fifo_io_pop_payload_last;
  wire       [4:0]    inputsAdapter_0_crossclock_fifo_io_pushOccupancy;
  wire       [4:0]    inputsAdapter_0_crossclock_fifo_io_popOccupancy;
  wire                outputsAdapter_0_crossclock_fifo_io_push_ready;
  wire                outputsAdapter_0_crossclock_fifo_io_pop_valid;
  wire       [31:0]   outputsAdapter_0_crossclock_fifo_io_pop_payload_data;
  wire       [3:0]    outputsAdapter_0_crossclock_fifo_io_pop_payload_mask;
  wire       [3:0]    outputsAdapter_0_crossclock_fifo_io_pop_payload_sink;
  wire                outputsAdapter_0_crossclock_fifo_io_pop_payload_last;
  wire       [4:0]    outputsAdapter_0_crossclock_fifo_io_pushOccupancy;
  wire       [4:0]    outputsAdapter_0_crossclock_fifo_io_popOccupancy;
  wire                outputsAdapter_0_sparseDownsizer_logic_io_input_ready;
  wire                outputsAdapter_0_sparseDownsizer_logic_io_output_valid;
  wire       [7:0]    outputsAdapter_0_sparseDownsizer_logic_io_output_payload_data;
  wire       [0:0]    outputsAdapter_0_sparseDownsizer_logic_io_output_payload_mask;
  wire       [3:0]    outputsAdapter_0_sparseDownsizer_logic_io_output_payload_sink;
  wire                outputsAdapter_0_sparseDownsizer_logic_io_output_payload_last;
  wire                interconnect_read_aggregated_arbiter_io_inputs_0_cmd_ready;
  wire                interconnect_read_aggregated_arbiter_io_inputs_0_rsp_valid;
  wire                interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_last;
  wire       [0:0]    interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_opcode;
  wire       [63:0]   interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_data;
  wire       [0:0]    interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_context;
  wire                interconnect_read_aggregated_arbiter_io_inputs_1_cmd_ready;
  wire                interconnect_read_aggregated_arbiter_io_inputs_1_rsp_valid;
  wire                interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_last;
  wire       [0:0]    interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_opcode;
  wire       [63:0]   interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_data;
  wire       [17:0]   interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_context;
  wire                interconnect_read_aggregated_arbiter_io_output_cmd_valid;
  wire                interconnect_read_aggregated_arbiter_io_output_cmd_payload_last;
  wire       [0:0]    interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_source;
  wire       [0:0]    interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_opcode;
  wire       [31:0]   interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_address;
  wire       [10:0]   interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_length;
  wire       [17:0]   interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_context;
  wire                interconnect_read_aggregated_arbiter_io_output_rsp_ready;
  wire                interconnect_write_aggregated_arbiter_io_inputs_0_cmd_ready;
  wire                interconnect_write_aggregated_arbiter_io_inputs_0_rsp_valid;
  wire                interconnect_write_aggregated_arbiter_io_inputs_0_rsp_payload_last;
  wire       [0:0]    interconnect_write_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_opcode;
  wire       [0:0]    interconnect_write_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_context;
  wire                interconnect_write_aggregated_arbiter_io_inputs_1_cmd_ready;
  wire                interconnect_write_aggregated_arbiter_io_inputs_1_rsp_valid;
  wire                interconnect_write_aggregated_arbiter_io_inputs_1_rsp_payload_last;
  wire       [0:0]    interconnect_write_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_opcode;
  wire       [11:0]   interconnect_write_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_context;
  wire                interconnect_write_aggregated_arbiter_io_output_cmd_valid;
  wire                interconnect_write_aggregated_arbiter_io_output_cmd_payload_last;
  wire       [0:0]    interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_source;
  wire       [0:0]    interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_opcode;
  wire       [31:0]   interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_address;
  wire       [10:0]   interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_length;
  wire       [63:0]   interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_data;
  wire       [7:0]    interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_mask;
  wire       [11:0]   interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_context;
  wire                interconnect_write_aggregated_arbiter_io_output_rsp_ready;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_valid;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_ready;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_last;
  wire       [0:0]    interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_opcode;
  wire       [31:0]   interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_address;
  wire       [10:0]   interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_length;
  wire       [17:0]   interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_context;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_valid;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_ready;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_last;
  wire       [0:0]    interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_opcode;
  wire       [63:0]   interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_data;
  wire       [17:0]   interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_context;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_valid;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_ready;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_last;
  wire       [0:0]    interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_opcode;
  wire       [31:0]   interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_address;
  wire       [4:0]    interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_length;
  wire       [0:0]    interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_context;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_valid;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_ready;
  wire                interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_last;
  wire       [0:0]    interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_opcode;
  wire       [63:0]   interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_data;
  wire       [0:0]    interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_context;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_valid;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_ready;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_last;
  wire       [0:0]    interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_opcode;
  wire       [31:0]   interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_address;
  wire       [10:0]   interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_length;
  wire       [63:0]   interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_data;
  wire       [7:0]    interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_mask;
  wire       [11:0]   interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_context;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_valid;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_ready;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_last;
  wire       [0:0]    interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_opcode;
  wire       [11:0]   interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_context;
  wire                io_write_cmd_s2mPipe_valid;
  reg                 io_write_cmd_s2mPipe_ready;
  wire                io_write_cmd_s2mPipe_payload_last;
  wire       [0:0]    io_write_cmd_s2mPipe_payload_fragment_opcode;
  wire       [31:0]   io_write_cmd_s2mPipe_payload_fragment_address;
  wire       [10:0]   io_write_cmd_s2mPipe_payload_fragment_length;
  wire       [63:0]   io_write_cmd_s2mPipe_payload_fragment_data;
  wire       [7:0]    io_write_cmd_s2mPipe_payload_fragment_mask;
  wire       [11:0]   io_write_cmd_s2mPipe_payload_fragment_context;
  reg                 io_write_cmd_rValidN;
  reg                 io_write_cmd_rData_last;
  reg        [0:0]    io_write_cmd_rData_fragment_opcode;
  reg        [31:0]   io_write_cmd_rData_fragment_address;
  reg        [10:0]   io_write_cmd_rData_fragment_length;
  reg        [63:0]   io_write_cmd_rData_fragment_data;
  reg        [7:0]    io_write_cmd_rData_fragment_mask;
  reg        [11:0]   io_write_cmd_rData_fragment_context;
  wire                io_write_cmd_s2mPipe_m2sPipe_valid;
  wire                io_write_cmd_s2mPipe_m2sPipe_ready;
  wire                io_write_cmd_s2mPipe_m2sPipe_payload_last;
  wire       [0:0]    io_write_cmd_s2mPipe_m2sPipe_payload_fragment_opcode;
  wire       [31:0]   io_write_cmd_s2mPipe_m2sPipe_payload_fragment_address;
  wire       [10:0]   io_write_cmd_s2mPipe_m2sPipe_payload_fragment_length;
  wire       [63:0]   io_write_cmd_s2mPipe_m2sPipe_payload_fragment_data;
  wire       [7:0]    io_write_cmd_s2mPipe_m2sPipe_payload_fragment_mask;
  wire       [11:0]   io_write_cmd_s2mPipe_m2sPipe_payload_fragment_context;
  reg                 io_write_cmd_s2mPipe_rValid;
  reg                 io_write_cmd_s2mPipe_rData_last;
  reg        [0:0]    io_write_cmd_s2mPipe_rData_fragment_opcode;
  reg        [31:0]   io_write_cmd_s2mPipe_rData_fragment_address;
  reg        [10:0]   io_write_cmd_s2mPipe_rData_fragment_length;
  reg        [63:0]   io_write_cmd_s2mPipe_rData_fragment_data;
  reg        [7:0]    io_write_cmd_s2mPipe_rData_fragment_mask;
  reg        [11:0]   io_write_cmd_s2mPipe_rData_fragment_context;
  wire                when_Stream_l375;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_valid;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_ready;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_last;
  wire       [0:0]    interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_opcode;
  wire       [31:0]   interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_address;
  wire       [1:0]    interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_length;
  wire       [63:0]   interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_data;
  wire       [7:0]    interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_mask;
  wire       [0:0]    interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_context;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_valid;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_ready;
  wire                interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_last;
  wire       [0:0]    interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_opcode;
  wire       [0:0]    interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_context;
  wire                interconnect_read_aggregated_cmd_valid;
  wire                interconnect_read_aggregated_cmd_ready;
  wire                interconnect_read_aggregated_cmd_payload_last;
  wire       [0:0]    interconnect_read_aggregated_cmd_payload_fragment_source;
  wire       [0:0]    interconnect_read_aggregated_cmd_payload_fragment_opcode;
  wire       [31:0]   interconnect_read_aggregated_cmd_payload_fragment_address;
  wire       [10:0]   interconnect_read_aggregated_cmd_payload_fragment_length;
  wire       [17:0]   interconnect_read_aggregated_cmd_payload_fragment_context;
  wire                interconnect_read_aggregated_rsp_valid;
  wire                interconnect_read_aggregated_rsp_ready;
  wire                interconnect_read_aggregated_rsp_payload_last;
  wire       [0:0]    interconnect_read_aggregated_rsp_payload_fragment_source;
  wire       [0:0]    interconnect_read_aggregated_rsp_payload_fragment_opcode;
  wire       [63:0]   interconnect_read_aggregated_rsp_payload_fragment_data;
  wire       [17:0]   interconnect_read_aggregated_rsp_payload_fragment_context;
  wire                interconnect_write_aggregated_cmd_valid;
  reg                 interconnect_write_aggregated_cmd_ready;
  wire                interconnect_write_aggregated_cmd_payload_last;
  wire       [0:0]    interconnect_write_aggregated_cmd_payload_fragment_source;
  wire       [0:0]    interconnect_write_aggregated_cmd_payload_fragment_opcode;
  wire       [31:0]   interconnect_write_aggregated_cmd_payload_fragment_address;
  wire       [10:0]   interconnect_write_aggregated_cmd_payload_fragment_length;
  wire       [63:0]   interconnect_write_aggregated_cmd_payload_fragment_data;
  wire       [7:0]    interconnect_write_aggregated_cmd_payload_fragment_mask;
  wire       [11:0]   interconnect_write_aggregated_cmd_payload_fragment_context;
  wire                interconnect_write_aggregated_rsp_valid;
  wire                interconnect_write_aggregated_rsp_ready;
  wire                interconnect_write_aggregated_rsp_payload_last;
  wire       [0:0]    interconnect_write_aggregated_rsp_payload_fragment_source;
  wire       [0:0]    interconnect_write_aggregated_rsp_payload_fragment_opcode;
  wire       [11:0]   interconnect_write_aggregated_rsp_payload_fragment_context;
  wire                interconnect_read_aggregated_cmd_halfPipe_valid;
  wire                interconnect_read_aggregated_cmd_halfPipe_ready;
  wire                interconnect_read_aggregated_cmd_halfPipe_payload_last;
  wire       [0:0]    interconnect_read_aggregated_cmd_halfPipe_payload_fragment_source;
  wire       [0:0]    interconnect_read_aggregated_cmd_halfPipe_payload_fragment_opcode;
  wire       [31:0]   interconnect_read_aggregated_cmd_halfPipe_payload_fragment_address;
  wire       [10:0]   interconnect_read_aggregated_cmd_halfPipe_payload_fragment_length;
  wire       [17:0]   interconnect_read_aggregated_cmd_halfPipe_payload_fragment_context;
  reg                 interconnect_read_aggregated_cmd_rValid;
  wire                interconnect_read_aggregated_cmd_halfPipe_fire;
  reg                 interconnect_read_aggregated_cmd_rData_last;
  reg        [0:0]    interconnect_read_aggregated_cmd_rData_fragment_source;
  reg        [0:0]    interconnect_read_aggregated_cmd_rData_fragment_opcode;
  reg        [31:0]   interconnect_read_aggregated_cmd_rData_fragment_address;
  reg        [10:0]   interconnect_read_aggregated_cmd_rData_fragment_length;
  reg        [17:0]   interconnect_read_aggregated_cmd_rData_fragment_context;
  wire                readLogic_adapter_ar_valid;
  wire                readLogic_adapter_ar_ready;
  wire       [31:0]   readLogic_adapter_ar_payload_addr;
  wire       [3:0]    readLogic_adapter_ar_payload_region;
  wire       [7:0]    readLogic_adapter_ar_payload_len;
  wire       [2:0]    readLogic_adapter_ar_payload_size;
  wire       [1:0]    readLogic_adapter_ar_payload_burst;
  wire       [0:0]    readLogic_adapter_ar_payload_lock;
  wire       [3:0]    readLogic_adapter_ar_payload_cache;
  wire       [3:0]    readLogic_adapter_ar_payload_qos;
  wire       [2:0]    readLogic_adapter_ar_payload_prot;
  wire                readLogic_adapter_r_valid;
  wire                readLogic_adapter_r_ready;
  wire       [127:0]  readLogic_adapter_r_payload_data;
  wire       [1:0]    readLogic_adapter_r_payload_resp;
  wire                readLogic_adapter_r_payload_last;
  wire       [3:0]    _zz_readLogic_adapter_ar_payload_region;
  wire                readLogic_adapter_ar_halfPipe_valid;
  wire                readLogic_adapter_ar_halfPipe_ready;
  wire       [31:0]   readLogic_adapter_ar_halfPipe_payload_addr;
  wire       [3:0]    readLogic_adapter_ar_halfPipe_payload_region;
  wire       [7:0]    readLogic_adapter_ar_halfPipe_payload_len;
  wire       [2:0]    readLogic_adapter_ar_halfPipe_payload_size;
  wire       [1:0]    readLogic_adapter_ar_halfPipe_payload_burst;
  wire       [0:0]    readLogic_adapter_ar_halfPipe_payload_lock;
  wire       [3:0]    readLogic_adapter_ar_halfPipe_payload_cache;
  wire       [3:0]    readLogic_adapter_ar_halfPipe_payload_qos;
  wire       [2:0]    readLogic_adapter_ar_halfPipe_payload_prot;
  reg                 readLogic_adapter_ar_rValid;
  wire                readLogic_adapter_ar_halfPipe_fire;
  reg        [31:0]   readLogic_adapter_ar_rData_addr;
  reg        [3:0]    readLogic_adapter_ar_rData_region;
  reg        [7:0]    readLogic_adapter_ar_rData_len;
  reg        [2:0]    readLogic_adapter_ar_rData_size;
  reg        [1:0]    readLogic_adapter_ar_rData_burst;
  reg        [0:0]    readLogic_adapter_ar_rData_lock;
  reg        [3:0]    readLogic_adapter_ar_rData_cache;
  reg        [3:0]    readLogic_adapter_ar_rData_qos;
  reg        [2:0]    readLogic_adapter_ar_rData_prot;
  wire                read_r_s2mPipe_valid;
  reg                 read_r_s2mPipe_ready;
  wire       [127:0]  read_r_s2mPipe_payload_data;
  wire       [1:0]    read_r_s2mPipe_payload_resp;
  wire                read_r_s2mPipe_payload_last;
  reg                 read_r_rValidN;
  reg        [127:0]  read_r_rData_data;
  reg        [1:0]    read_r_rData_resp;
  reg                 read_r_rData_last;
  wire                readLogic_beforeQueue_valid;
  wire                readLogic_beforeQueue_ready;
  wire       [127:0]  readLogic_beforeQueue_payload_data;
  wire       [1:0]    readLogic_beforeQueue_payload_resp;
  wire                readLogic_beforeQueue_payload_last;
  reg                 read_r_s2mPipe_rValid;
  reg        [127:0]  read_r_s2mPipe_rData_data;
  reg        [1:0]    read_r_s2mPipe_rData_resp;
  reg                 read_r_s2mPipe_rData_last;
  wire                when_Stream_l375_1;
  wire                interconnect_write_aggregated_cmd_m2sPipe_valid;
  wire                interconnect_write_aggregated_cmd_m2sPipe_ready;
  wire                interconnect_write_aggregated_cmd_m2sPipe_payload_last;
  wire       [0:0]    interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_source;
  wire       [0:0]    interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_opcode;
  wire       [31:0]   interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_address;
  wire       [10:0]   interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_length;
  wire       [63:0]   interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_data;
  wire       [7:0]    interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_mask;
  wire       [11:0]   interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_context;
  reg                 interconnect_write_aggregated_cmd_rValid;
  reg                 interconnect_write_aggregated_cmd_rData_last;
  reg        [0:0]    interconnect_write_aggregated_cmd_rData_fragment_source;
  reg        [0:0]    interconnect_write_aggregated_cmd_rData_fragment_opcode;
  reg        [31:0]   interconnect_write_aggregated_cmd_rData_fragment_address;
  reg        [10:0]   interconnect_write_aggregated_cmd_rData_fragment_length;
  reg        [63:0]   interconnect_write_aggregated_cmd_rData_fragment_data;
  reg        [7:0]    interconnect_write_aggregated_cmd_rData_fragment_mask;
  reg        [11:0]   interconnect_write_aggregated_cmd_rData_fragment_context;
  wire                when_Stream_l375_2;
  wire                writeLogic_adapter_aw_valid;
  wire                writeLogic_adapter_aw_ready;
  wire       [31:0]   writeLogic_adapter_aw_payload_addr;
  wire       [3:0]    writeLogic_adapter_aw_payload_region;
  wire       [7:0]    writeLogic_adapter_aw_payload_len;
  wire       [2:0]    writeLogic_adapter_aw_payload_size;
  wire       [1:0]    writeLogic_adapter_aw_payload_burst;
  wire       [0:0]    writeLogic_adapter_aw_payload_lock;
  wire       [3:0]    writeLogic_adapter_aw_payload_cache;
  wire       [3:0]    writeLogic_adapter_aw_payload_qos;
  wire       [2:0]    writeLogic_adapter_aw_payload_prot;
  wire                writeLogic_adapter_w_valid;
  wire                writeLogic_adapter_w_ready;
  wire       [127:0]  writeLogic_adapter_w_payload_data;
  wire       [15:0]   writeLogic_adapter_w_payload_strb;
  wire                writeLogic_adapter_w_payload_last;
  wire                writeLogic_adapter_b_valid;
  wire                writeLogic_adapter_b_ready;
  wire       [1:0]    writeLogic_adapter_b_payload_resp;
  wire       [3:0]    _zz_writeLogic_adapter_aw_payload_region;
  wire                writeLogic_adapter_aw_halfPipe_valid;
  wire                writeLogic_adapter_aw_halfPipe_ready;
  wire       [31:0]   writeLogic_adapter_aw_halfPipe_payload_addr;
  wire       [3:0]    writeLogic_adapter_aw_halfPipe_payload_region;
  wire       [7:0]    writeLogic_adapter_aw_halfPipe_payload_len;
  wire       [2:0]    writeLogic_adapter_aw_halfPipe_payload_size;
  wire       [1:0]    writeLogic_adapter_aw_halfPipe_payload_burst;
  wire       [0:0]    writeLogic_adapter_aw_halfPipe_payload_lock;
  wire       [3:0]    writeLogic_adapter_aw_halfPipe_payload_cache;
  wire       [3:0]    writeLogic_adapter_aw_halfPipe_payload_qos;
  wire       [2:0]    writeLogic_adapter_aw_halfPipe_payload_prot;
  reg                 writeLogic_adapter_aw_rValid;
  wire                writeLogic_adapter_aw_halfPipe_fire;
  reg        [31:0]   writeLogic_adapter_aw_rData_addr;
  reg        [3:0]    writeLogic_adapter_aw_rData_region;
  reg        [7:0]    writeLogic_adapter_aw_rData_len;
  reg        [2:0]    writeLogic_adapter_aw_rData_size;
  reg        [1:0]    writeLogic_adapter_aw_rData_burst;
  reg        [0:0]    writeLogic_adapter_aw_rData_lock;
  reg        [3:0]    writeLogic_adapter_aw_rData_cache;
  reg        [3:0]    writeLogic_adapter_aw_rData_qos;
  reg        [2:0]    writeLogic_adapter_aw_rData_prot;
  wire                writeLogic_adapter_w_s2mPipe_valid;
  reg                 writeLogic_adapter_w_s2mPipe_ready;
  wire       [127:0]  writeLogic_adapter_w_s2mPipe_payload_data;
  wire       [15:0]   writeLogic_adapter_w_s2mPipe_payload_strb;
  wire                writeLogic_adapter_w_s2mPipe_payload_last;
  reg                 writeLogic_adapter_w_rValidN;
  reg        [127:0]  writeLogic_adapter_w_rData_data;
  reg        [15:0]   writeLogic_adapter_w_rData_strb;
  reg                 writeLogic_adapter_w_rData_last;
  wire                writeLogic_adapter_w_s2mPipe_m2sPipe_valid;
  wire                writeLogic_adapter_w_s2mPipe_m2sPipe_ready;
  wire       [127:0]  writeLogic_adapter_w_s2mPipe_m2sPipe_payload_data;
  wire       [15:0]   writeLogic_adapter_w_s2mPipe_m2sPipe_payload_strb;
  wire                writeLogic_adapter_w_s2mPipe_m2sPipe_payload_last;
  reg                 writeLogic_adapter_w_s2mPipe_rValid;
  reg        [127:0]  writeLogic_adapter_w_s2mPipe_rData_data;
  reg        [15:0]   writeLogic_adapter_w_s2mPipe_rData_strb;
  reg                 writeLogic_adapter_w_s2mPipe_rData_last;
  wire                when_Stream_l375_3;
  wire                write_b_halfPipe_valid;
  wire                write_b_halfPipe_ready;
  wire       [1:0]    write_b_halfPipe_payload_resp;
  reg                 write_b_rValid;
  wire                write_b_halfPipe_fire;
  reg        [1:0]    write_b_rData_resp;
  wire                io_pop_s2mPipe_valid;
  reg                 io_pop_s2mPipe_ready;
  wire       [31:0]   io_pop_s2mPipe_payload_data;
  wire       [3:0]    io_pop_s2mPipe_payload_mask;
  wire       [3:0]    io_pop_s2mPipe_payload_sink;
  wire                io_pop_s2mPipe_payload_last;
  reg                 io_pop_rValidN;
  reg        [31:0]   io_pop_rData_data;
  reg        [3:0]    io_pop_rData_mask;
  reg        [3:0]    io_pop_rData_sink;
  reg                 io_pop_rData_last;
  wire                io_pop_s2mPipe_m2sPipe_valid;
  wire                io_pop_s2mPipe_m2sPipe_ready;
  wire       [31:0]   io_pop_s2mPipe_m2sPipe_payload_data;
  wire       [3:0]    io_pop_s2mPipe_m2sPipe_payload_mask;
  wire       [3:0]    io_pop_s2mPipe_m2sPipe_payload_sink;
  wire                io_pop_s2mPipe_m2sPipe_payload_last;
  reg                 io_pop_s2mPipe_rValid;
  reg        [31:0]   io_pop_s2mPipe_rData_data;
  reg        [3:0]    io_pop_s2mPipe_rData_mask;
  reg        [3:0]    io_pop_s2mPipe_rData_sink;
  reg                 io_pop_s2mPipe_rData_last;
  wire                when_Stream_l375_4;
  wire                io_outputs_0_s2mPipe_valid;
  reg                 io_outputs_0_s2mPipe_ready;
  wire       [31:0]   io_outputs_0_s2mPipe_payload_data;
  wire       [3:0]    io_outputs_0_s2mPipe_payload_mask;
  wire       [3:0]    io_outputs_0_s2mPipe_payload_sink;
  wire                io_outputs_0_s2mPipe_payload_last;
  reg                 io_outputs_0_rValidN;
  reg        [31:0]   io_outputs_0_rData_data;
  reg        [3:0]    io_outputs_0_rData_mask;
  reg        [3:0]    io_outputs_0_rData_sink;
  reg                 io_outputs_0_rData_last;
  wire                outputsAdapter_0_ptr_valid;
  wire                outputsAdapter_0_ptr_ready;
  wire       [31:0]   outputsAdapter_0_ptr_payload_data;
  wire       [3:0]    outputsAdapter_0_ptr_payload_mask;
  wire       [3:0]    outputsAdapter_0_ptr_payload_sink;
  wire                outputsAdapter_0_ptr_payload_last;
  reg                 io_outputs_0_s2mPipe_rValid;
  reg        [31:0]   io_outputs_0_s2mPipe_rData_data;
  reg        [3:0]    io_outputs_0_s2mPipe_rData_mask;
  reg        [3:0]    io_outputs_0_s2mPipe_rData_sink;
  reg                 io_outputs_0_s2mPipe_rData_last;
  wire                when_Stream_l375_5;

  EfxDMA_Core core (
    .io_sgRead_cmd_valid                     (core_io_sgRead_cmd_valid                                                                                     ), //o
    .io_sgRead_cmd_ready                     (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_ready                          ), //i
    .io_sgRead_cmd_payload_last              (core_io_sgRead_cmd_payload_last                                                                              ), //o
    .io_sgRead_cmd_payload_fragment_opcode   (core_io_sgRead_cmd_payload_fragment_opcode                                                                   ), //o
    .io_sgRead_cmd_payload_fragment_address  (core_io_sgRead_cmd_payload_fragment_address[31:0]                                                            ), //o
    .io_sgRead_cmd_payload_fragment_length   (core_io_sgRead_cmd_payload_fragment_length[4:0]                                                              ), //o
    .io_sgRead_cmd_payload_fragment_context  (core_io_sgRead_cmd_payload_fragment_context                                                                  ), //o
    .io_sgRead_rsp_valid                     (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_valid                          ), //i
    .io_sgRead_rsp_ready                     (core_io_sgRead_rsp_ready                                                                                     ), //o
    .io_sgRead_rsp_payload_last              (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_last                   ), //i
    .io_sgRead_rsp_payload_fragment_opcode   (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_opcode        ), //i
    .io_sgRead_rsp_payload_fragment_data     (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_data[63:0]    ), //i
    .io_sgRead_rsp_payload_fragment_context  (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_context       ), //i
    .io_sgWrite_cmd_valid                    (core_io_sgWrite_cmd_valid                                                                                    ), //o
    .io_sgWrite_cmd_ready                    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_ready                         ), //i
    .io_sgWrite_cmd_payload_last             (core_io_sgWrite_cmd_payload_last                                                                             ), //o
    .io_sgWrite_cmd_payload_fragment_opcode  (core_io_sgWrite_cmd_payload_fragment_opcode                                                                  ), //o
    .io_sgWrite_cmd_payload_fragment_address (core_io_sgWrite_cmd_payload_fragment_address[31:0]                                                           ), //o
    .io_sgWrite_cmd_payload_fragment_length  (core_io_sgWrite_cmd_payload_fragment_length[1:0]                                                             ), //o
    .io_sgWrite_cmd_payload_fragment_data    (core_io_sgWrite_cmd_payload_fragment_data[63:0]                                                              ), //o
    .io_sgWrite_cmd_payload_fragment_mask    (core_io_sgWrite_cmd_payload_fragment_mask[7:0]                                                               ), //o
    .io_sgWrite_cmd_payload_fragment_context (core_io_sgWrite_cmd_payload_fragment_context                                                                 ), //o
    .io_sgWrite_rsp_valid                    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_valid                         ), //i
    .io_sgWrite_rsp_ready                    (core_io_sgWrite_rsp_ready                                                                                    ), //o
    .io_sgWrite_rsp_payload_last             (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_last                  ), //i
    .io_sgWrite_rsp_payload_fragment_opcode  (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_opcode       ), //i
    .io_sgWrite_rsp_payload_fragment_context (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_context      ), //i
    .io_read_cmd_valid                       (core_io_read_cmd_valid                                                                                       ), //o
    .io_read_cmd_ready                       (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_ready                          ), //i
    .io_read_cmd_payload_last                (core_io_read_cmd_payload_last                                                                                ), //o
    .io_read_cmd_payload_fragment_opcode     (core_io_read_cmd_payload_fragment_opcode                                                                     ), //o
    .io_read_cmd_payload_fragment_address    (core_io_read_cmd_payload_fragment_address[31:0]                                                              ), //o
    .io_read_cmd_payload_fragment_length     (core_io_read_cmd_payload_fragment_length[10:0]                                                               ), //o
    .io_read_cmd_payload_fragment_context    (core_io_read_cmd_payload_fragment_context[17:0]                                                              ), //o
    .io_read_rsp_valid                       (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_valid                          ), //i
    .io_read_rsp_ready                       (core_io_read_rsp_ready                                                                                       ), //o
    .io_read_rsp_payload_last                (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_last                   ), //i
    .io_read_rsp_payload_fragment_opcode     (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_opcode        ), //i
    .io_read_rsp_payload_fragment_data       (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_data[63:0]    ), //i
    .io_read_rsp_payload_fragment_context    (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_context[17:0] ), //i
    .io_write_cmd_valid                      (core_io_write_cmd_valid                                                                                      ), //o
    .io_write_cmd_ready                      (io_write_cmd_rValidN                                                                                         ), //i
    .io_write_cmd_payload_last               (core_io_write_cmd_payload_last                                                                               ), //o
    .io_write_cmd_payload_fragment_opcode    (core_io_write_cmd_payload_fragment_opcode                                                                    ), //o
    .io_write_cmd_payload_fragment_address   (core_io_write_cmd_payload_fragment_address[31:0]                                                             ), //o
    .io_write_cmd_payload_fragment_length    (core_io_write_cmd_payload_fragment_length[10:0]                                                              ), //o
    .io_write_cmd_payload_fragment_data      (core_io_write_cmd_payload_fragment_data[63:0]                                                                ), //o
    .io_write_cmd_payload_fragment_mask      (core_io_write_cmd_payload_fragment_mask[7:0]                                                                 ), //o
    .io_write_cmd_payload_fragment_context   (core_io_write_cmd_payload_fragment_context[11:0]                                                             ), //o
    .io_write_rsp_valid                      (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_valid                         ), //i
    .io_write_rsp_ready                      (core_io_write_rsp_ready                                                                                      ), //o
    .io_write_rsp_payload_last               (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_last                  ), //i
    .io_write_rsp_payload_fragment_opcode    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_opcode       ), //i
    .io_write_rsp_payload_fragment_context   (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_context[11:0]), //i
    .io_outputs_0_valid                      (core_io_outputs_0_valid                                                                                      ), //o
    .io_outputs_0_ready                      (io_outputs_0_rValidN                                                                                         ), //i
    .io_outputs_0_payload_data               (core_io_outputs_0_payload_data[31:0]                                                                         ), //o
    .io_outputs_0_payload_mask               (core_io_outputs_0_payload_mask[3:0]                                                                          ), //o
    .io_outputs_0_payload_sink               (core_io_outputs_0_payload_sink[3:0]                                                                          ), //o
    .io_outputs_0_payload_last               (core_io_outputs_0_payload_last                                                                               ), //o
    .io_inputs_0_valid                       (io_pop_s2mPipe_m2sPipe_valid                                                                                 ), //i
    .io_inputs_0_ready                       (core_io_inputs_0_ready                                                                                       ), //o
    .io_inputs_0_payload_data                (io_pop_s2mPipe_m2sPipe_payload_data[31:0]                                                                    ), //i
    .io_inputs_0_payload_mask                (io_pop_s2mPipe_m2sPipe_payload_mask[3:0]                                                                     ), //i
    .io_inputs_0_payload_sink                (io_pop_s2mPipe_m2sPipe_payload_sink[3:0]                                                                     ), //i
    .io_inputs_0_payload_last                (io_pop_s2mPipe_m2sPipe_payload_last                                                                          ), //i
    .io_interrupts                           (core_io_interrupts[1:0]                                                                                      ), //o
    .io_ctrl_PADDR                           (withCtrlCc_apbCc_io_output_PADDR[13:0]                                                                       ), //i
    .io_ctrl_PSEL                            (withCtrlCc_apbCc_io_output_PSEL                                                                              ), //i
    .io_ctrl_PENABLE                         (withCtrlCc_apbCc_io_output_PENABLE                                                                           ), //i
    .io_ctrl_PREADY                          (core_io_ctrl_PREADY                                                                                          ), //o
    .io_ctrl_PWRITE                          (withCtrlCc_apbCc_io_output_PWRITE                                                                            ), //i
    .io_ctrl_PWDATA                          (withCtrlCc_apbCc_io_output_PWDATA[31:0]                                                                      ), //i
    .io_ctrl_PRDATA                          (core_io_ctrl_PRDATA[31:0]                                                                                    ), //o
    .io_ctrl_PSLVERROR                       (core_io_ctrl_PSLVERROR                                                                                       ), //o
    .ll_0_descriptorUpdate                   (core_ll_0_descriptorUpdate                                                                                   ), //o
    .ll_1_descriptorUpdate                   (core_ll_1_descriptorUpdate                                                                                   ), //o
    .clk                                     (clk                                                                                                          ), //i
    .reset                                   (reset                                                                                                        )  //i
  );
  EfxDMA_Apb3CC withCtrlCc_apbCc (
    .io_input_PADDR      (ctrl_PADDR[13:0]                       ), //i
    .io_input_PSEL       (ctrl_PSEL                              ), //i
    .io_input_PENABLE    (ctrl_PENABLE                           ), //i
    .io_input_PREADY     (withCtrlCc_apbCc_io_input_PREADY       ), //o
    .io_input_PWRITE     (ctrl_PWRITE                            ), //i
    .io_input_PWDATA     (ctrl_PWDATA[31:0]                      ), //i
    .io_input_PRDATA     (withCtrlCc_apbCc_io_input_PRDATA[31:0] ), //o
    .io_input_PSLVERROR  (withCtrlCc_apbCc_io_input_PSLVERROR    ), //o
    .io_output_PADDR     (withCtrlCc_apbCc_io_output_PADDR[13:0] ), //o
    .io_output_PSEL      (withCtrlCc_apbCc_io_output_PSEL        ), //o
    .io_output_PENABLE   (withCtrlCc_apbCc_io_output_PENABLE     ), //o
    .io_output_PREADY    (core_io_ctrl_PREADY                    ), //i
    .io_output_PWRITE    (withCtrlCc_apbCc_io_output_PWRITE      ), //o
    .io_output_PWDATA    (withCtrlCc_apbCc_io_output_PWDATA[31:0]), //o
    .io_output_PRDATA    (core_io_ctrl_PRDATA[31:0]              ), //i
    .io_output_PSLVERROR (core_io_ctrl_PSLVERROR                 ), //i
    .ctrl_clk            (ctrl_clk                               ), //i
    .ctrl_reset          (ctrl_reset                             ), //i
    .clk                 (clk                                    ), //i
    .reset               (reset                                  )  //i
  );
  (* keep_hierarchy = "TRUE" *) EfxDMA_BufferCC_6 io_interrupts_buffercc (
    .io_dataIn  (core_io_interrupts[1:0]               ), //i
    .io_dataOut (io_interrupts_buffercc_io_dataOut[1:0]), //o
    .ctrl_clk   (ctrl_clk                              ), //i
    .ctrl_reset (ctrl_reset                            )  //i
  );
  EfxDMA_BmbUpSizerBridge bmbUpSizerBridge (
    .io_input_cmd_valid                     (interconnect_read_aggregated_cmd_halfPipe_valid                         ), //i
    .io_input_cmd_ready                     (bmbUpSizerBridge_io_input_cmd_ready                                     ), //o
    .io_input_cmd_payload_last              (interconnect_read_aggregated_cmd_halfPipe_payload_last                  ), //i
    .io_input_cmd_payload_fragment_source   (interconnect_read_aggregated_cmd_halfPipe_payload_fragment_source       ), //i
    .io_input_cmd_payload_fragment_opcode   (interconnect_read_aggregated_cmd_halfPipe_payload_fragment_opcode       ), //i
    .io_input_cmd_payload_fragment_address  (interconnect_read_aggregated_cmd_halfPipe_payload_fragment_address[31:0]), //i
    .io_input_cmd_payload_fragment_length   (interconnect_read_aggregated_cmd_halfPipe_payload_fragment_length[10:0] ), //i
    .io_input_cmd_payload_fragment_context  (interconnect_read_aggregated_cmd_halfPipe_payload_fragment_context[17:0]), //i
    .io_input_rsp_valid                     (bmbUpSizerBridge_io_input_rsp_valid                                     ), //o
    .io_input_rsp_ready                     (interconnect_read_aggregated_rsp_ready                                  ), //i
    .io_input_rsp_payload_last              (bmbUpSizerBridge_io_input_rsp_payload_last                              ), //o
    .io_input_rsp_payload_fragment_source   (bmbUpSizerBridge_io_input_rsp_payload_fragment_source                   ), //o
    .io_input_rsp_payload_fragment_opcode   (bmbUpSizerBridge_io_input_rsp_payload_fragment_opcode                   ), //o
    .io_input_rsp_payload_fragment_data     (bmbUpSizerBridge_io_input_rsp_payload_fragment_data[63:0]               ), //o
    .io_input_rsp_payload_fragment_context  (bmbUpSizerBridge_io_input_rsp_payload_fragment_context[17:0]            ), //o
    .io_output_cmd_valid                    (bmbUpSizerBridge_io_output_cmd_valid                                    ), //o
    .io_output_cmd_ready                    (readLogic_sourceRemover_io_input_cmd_ready                              ), //i
    .io_output_cmd_payload_last             (bmbUpSizerBridge_io_output_cmd_payload_last                             ), //o
    .io_output_cmd_payload_fragment_source  (bmbUpSizerBridge_io_output_cmd_payload_fragment_source                  ), //o
    .io_output_cmd_payload_fragment_opcode  (bmbUpSizerBridge_io_output_cmd_payload_fragment_opcode                  ), //o
    .io_output_cmd_payload_fragment_address (bmbUpSizerBridge_io_output_cmd_payload_fragment_address[31:0]           ), //o
    .io_output_cmd_payload_fragment_length  (bmbUpSizerBridge_io_output_cmd_payload_fragment_length[10:0]            ), //o
    .io_output_cmd_payload_fragment_context (bmbUpSizerBridge_io_output_cmd_payload_fragment_context[19:0]           ), //o
    .io_output_rsp_valid                    (readLogic_sourceRemover_io_input_rsp_valid                              ), //i
    .io_output_rsp_ready                    (bmbUpSizerBridge_io_output_rsp_ready                                    ), //o
    .io_output_rsp_payload_last             (readLogic_sourceRemover_io_input_rsp_payload_last                       ), //i
    .io_output_rsp_payload_fragment_source  (readLogic_sourceRemover_io_input_rsp_payload_fragment_source            ), //i
    .io_output_rsp_payload_fragment_opcode  (readLogic_sourceRemover_io_input_rsp_payload_fragment_opcode            ), //i
    .io_output_rsp_payload_fragment_data    (readLogic_sourceRemover_io_input_rsp_payload_fragment_data[127:0]       ), //i
    .io_output_rsp_payload_fragment_context (readLogic_sourceRemover_io_input_rsp_payload_fragment_context[19:0]     ), //i
    .clk                                    (clk                                                                     ), //i
    .reset                                  (reset                                                                   )  //i
  );
  EfxDMA_BmbSourceRemover readLogic_sourceRemover (
    .io_input_cmd_valid                     (bmbUpSizerBridge_io_output_cmd_valid                                ), //i
    .io_input_cmd_ready                     (readLogic_sourceRemover_io_input_cmd_ready                          ), //o
    .io_input_cmd_payload_last              (bmbUpSizerBridge_io_output_cmd_payload_last                         ), //i
    .io_input_cmd_payload_fragment_source   (bmbUpSizerBridge_io_output_cmd_payload_fragment_source              ), //i
    .io_input_cmd_payload_fragment_opcode   (bmbUpSizerBridge_io_output_cmd_payload_fragment_opcode              ), //i
    .io_input_cmd_payload_fragment_address  (bmbUpSizerBridge_io_output_cmd_payload_fragment_address[31:0]       ), //i
    .io_input_cmd_payload_fragment_length   (bmbUpSizerBridge_io_output_cmd_payload_fragment_length[10:0]        ), //i
    .io_input_cmd_payload_fragment_context  (bmbUpSizerBridge_io_output_cmd_payload_fragment_context[19:0]       ), //i
    .io_input_rsp_valid                     (readLogic_sourceRemover_io_input_rsp_valid                          ), //o
    .io_input_rsp_ready                     (bmbUpSizerBridge_io_output_rsp_ready                                ), //i
    .io_input_rsp_payload_last              (readLogic_sourceRemover_io_input_rsp_payload_last                   ), //o
    .io_input_rsp_payload_fragment_source   (readLogic_sourceRemover_io_input_rsp_payload_fragment_source        ), //o
    .io_input_rsp_payload_fragment_opcode   (readLogic_sourceRemover_io_input_rsp_payload_fragment_opcode        ), //o
    .io_input_rsp_payload_fragment_data     (readLogic_sourceRemover_io_input_rsp_payload_fragment_data[127:0]   ), //o
    .io_input_rsp_payload_fragment_context  (readLogic_sourceRemover_io_input_rsp_payload_fragment_context[19:0] ), //o
    .io_output_cmd_valid                    (readLogic_sourceRemover_io_output_cmd_valid                         ), //o
    .io_output_cmd_ready                    (readLogic_bridge_io_input_cmd_ready                                 ), //i
    .io_output_cmd_payload_last             (readLogic_sourceRemover_io_output_cmd_payload_last                  ), //o
    .io_output_cmd_payload_fragment_opcode  (readLogic_sourceRemover_io_output_cmd_payload_fragment_opcode       ), //o
    .io_output_cmd_payload_fragment_address (readLogic_sourceRemover_io_output_cmd_payload_fragment_address[31:0]), //o
    .io_output_cmd_payload_fragment_length  (readLogic_sourceRemover_io_output_cmd_payload_fragment_length[10:0] ), //o
    .io_output_cmd_payload_fragment_context (readLogic_sourceRemover_io_output_cmd_payload_fragment_context[20:0]), //o
    .io_output_rsp_valid                    (readLogic_bridge_io_input_rsp_valid                                 ), //i
    .io_output_rsp_ready                    (readLogic_sourceRemover_io_output_rsp_ready                         ), //o
    .io_output_rsp_payload_last             (readLogic_bridge_io_input_rsp_payload_last                          ), //i
    .io_output_rsp_payload_fragment_opcode  (readLogic_bridge_io_input_rsp_payload_fragment_opcode               ), //i
    .io_output_rsp_payload_fragment_data    (readLogic_bridge_io_input_rsp_payload_fragment_data[127:0]          ), //i
    .io_output_rsp_payload_fragment_context (readLogic_bridge_io_input_rsp_payload_fragment_context[20:0]        )  //i
  );
  EfxDMA_BmbToAxi4ReadOnlyBridge readLogic_bridge (
    .io_input_cmd_valid                    (readLogic_sourceRemover_io_output_cmd_valid                         ), //i
    .io_input_cmd_ready                    (readLogic_bridge_io_input_cmd_ready                                 ), //o
    .io_input_cmd_payload_last             (readLogic_sourceRemover_io_output_cmd_payload_last                  ), //i
    .io_input_cmd_payload_fragment_opcode  (readLogic_sourceRemover_io_output_cmd_payload_fragment_opcode       ), //i
    .io_input_cmd_payload_fragment_address (readLogic_sourceRemover_io_output_cmd_payload_fragment_address[31:0]), //i
    .io_input_cmd_payload_fragment_length  (readLogic_sourceRemover_io_output_cmd_payload_fragment_length[10:0] ), //i
    .io_input_cmd_payload_fragment_context (readLogic_sourceRemover_io_output_cmd_payload_fragment_context[20:0]), //i
    .io_input_rsp_valid                    (readLogic_bridge_io_input_rsp_valid                                 ), //o
    .io_input_rsp_ready                    (readLogic_sourceRemover_io_output_rsp_ready                         ), //i
    .io_input_rsp_payload_last             (readLogic_bridge_io_input_rsp_payload_last                          ), //o
    .io_input_rsp_payload_fragment_opcode  (readLogic_bridge_io_input_rsp_payload_fragment_opcode               ), //o
    .io_input_rsp_payload_fragment_data    (readLogic_bridge_io_input_rsp_payload_fragment_data[127:0]          ), //o
    .io_input_rsp_payload_fragment_context (readLogic_bridge_io_input_rsp_payload_fragment_context[20:0]        ), //o
    .io_output_ar_valid                    (readLogic_bridge_io_output_ar_valid                                 ), //o
    .io_output_ar_ready                    (readLogic_adapter_ar_ready                                          ), //i
    .io_output_ar_payload_addr             (readLogic_bridge_io_output_ar_payload_addr[31:0]                    ), //o
    .io_output_ar_payload_len              (readLogic_bridge_io_output_ar_payload_len[7:0]                      ), //o
    .io_output_ar_payload_size             (readLogic_bridge_io_output_ar_payload_size[2:0]                     ), //o
    .io_output_ar_payload_cache            (readLogic_bridge_io_output_ar_payload_cache[3:0]                    ), //o
    .io_output_ar_payload_prot             (readLogic_bridge_io_output_ar_payload_prot[2:0]                     ), //o
    .io_output_r_valid                     (readLogic_adapter_r_valid                                           ), //i
    .io_output_r_ready                     (readLogic_bridge_io_output_r_ready                                  ), //o
    .io_output_r_payload_data              (readLogic_adapter_r_payload_data[127:0]                             ), //i
    .io_output_r_payload_resp              (readLogic_adapter_r_payload_resp[1:0]                               ), //i
    .io_output_r_payload_last              (readLogic_adapter_r_payload_last                                    ), //i
    .clk                                   (clk                                                                 ), //i
    .reset                                 (reset                                                               )  //i
  );
  EfxDMA_BmbUpSizerBridge_1 bmbUpSizerBridge_1 (
    .io_input_cmd_valid                     (interconnect_write_aggregated_cmd_m2sPipe_valid                         ), //i
    .io_input_cmd_ready                     (bmbUpSizerBridge_1_io_input_cmd_ready                                   ), //o
    .io_input_cmd_payload_last              (interconnect_write_aggregated_cmd_m2sPipe_payload_last                  ), //i
    .io_input_cmd_payload_fragment_source   (interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_source       ), //i
    .io_input_cmd_payload_fragment_opcode   (interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_opcode       ), //i
    .io_input_cmd_payload_fragment_address  (interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_address[31:0]), //i
    .io_input_cmd_payload_fragment_length   (interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_length[10:0] ), //i
    .io_input_cmd_payload_fragment_data     (interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_data[63:0]   ), //i
    .io_input_cmd_payload_fragment_mask     (interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_mask[7:0]    ), //i
    .io_input_cmd_payload_fragment_context  (interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_context[11:0]), //i
    .io_input_rsp_valid                     (bmbUpSizerBridge_1_io_input_rsp_valid                                   ), //o
    .io_input_rsp_ready                     (interconnect_write_aggregated_rsp_ready                                 ), //i
    .io_input_rsp_payload_last              (bmbUpSizerBridge_1_io_input_rsp_payload_last                            ), //o
    .io_input_rsp_payload_fragment_source   (bmbUpSizerBridge_1_io_input_rsp_payload_fragment_source                 ), //o
    .io_input_rsp_payload_fragment_opcode   (bmbUpSizerBridge_1_io_input_rsp_payload_fragment_opcode                 ), //o
    .io_input_rsp_payload_fragment_context  (bmbUpSizerBridge_1_io_input_rsp_payload_fragment_context[11:0]          ), //o
    .io_output_cmd_valid                    (bmbUpSizerBridge_1_io_output_cmd_valid                                  ), //o
    .io_output_cmd_ready                    (writeLogic_sourceRemover_io_input_cmd_ready                             ), //i
    .io_output_cmd_payload_last             (bmbUpSizerBridge_1_io_output_cmd_payload_last                           ), //o
    .io_output_cmd_payload_fragment_source  (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_source                ), //o
    .io_output_cmd_payload_fragment_opcode  (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_opcode                ), //o
    .io_output_cmd_payload_fragment_address (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_address[31:0]         ), //o
    .io_output_cmd_payload_fragment_length  (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_length[10:0]          ), //o
    .io_output_cmd_payload_fragment_data    (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_data[127:0]           ), //o
    .io_output_cmd_payload_fragment_mask    (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_mask[15:0]            ), //o
    .io_output_cmd_payload_fragment_context (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_context[11:0]         ), //o
    .io_output_rsp_valid                    (writeLogic_sourceRemover_io_input_rsp_valid                             ), //i
    .io_output_rsp_ready                    (bmbUpSizerBridge_1_io_output_rsp_ready                                  ), //o
    .io_output_rsp_payload_last             (writeLogic_sourceRemover_io_input_rsp_payload_last                      ), //i
    .io_output_rsp_payload_fragment_source  (writeLogic_sourceRemover_io_input_rsp_payload_fragment_source           ), //i
    .io_output_rsp_payload_fragment_opcode  (writeLogic_sourceRemover_io_input_rsp_payload_fragment_opcode           ), //i
    .io_output_rsp_payload_fragment_context (writeLogic_sourceRemover_io_input_rsp_payload_fragment_context[11:0]    ), //i
    .clk                                    (clk                                                                     ), //i
    .reset                                  (reset                                                                   )  //i
  );
  EfxDMA_BmbSourceRemover_1 writeLogic_sourceRemover (
    .io_input_cmd_valid                     (bmbUpSizerBridge_1_io_output_cmd_valid                               ), //i
    .io_input_cmd_ready                     (writeLogic_sourceRemover_io_input_cmd_ready                          ), //o
    .io_input_cmd_payload_last              (bmbUpSizerBridge_1_io_output_cmd_payload_last                        ), //i
    .io_input_cmd_payload_fragment_source   (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_source             ), //i
    .io_input_cmd_payload_fragment_opcode   (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_opcode             ), //i
    .io_input_cmd_payload_fragment_address  (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_address[31:0]      ), //i
    .io_input_cmd_payload_fragment_length   (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_length[10:0]       ), //i
    .io_input_cmd_payload_fragment_data     (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_data[127:0]        ), //i
    .io_input_cmd_payload_fragment_mask     (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_mask[15:0]         ), //i
    .io_input_cmd_payload_fragment_context  (bmbUpSizerBridge_1_io_output_cmd_payload_fragment_context[11:0]      ), //i
    .io_input_rsp_valid                     (writeLogic_sourceRemover_io_input_rsp_valid                          ), //o
    .io_input_rsp_ready                     (bmbUpSizerBridge_1_io_output_rsp_ready                               ), //i
    .io_input_rsp_payload_last              (writeLogic_sourceRemover_io_input_rsp_payload_last                   ), //o
    .io_input_rsp_payload_fragment_source   (writeLogic_sourceRemover_io_input_rsp_payload_fragment_source        ), //o
    .io_input_rsp_payload_fragment_opcode   (writeLogic_sourceRemover_io_input_rsp_payload_fragment_opcode        ), //o
    .io_input_rsp_payload_fragment_context  (writeLogic_sourceRemover_io_input_rsp_payload_fragment_context[11:0] ), //o
    .io_output_cmd_valid                    (writeLogic_sourceRemover_io_output_cmd_valid                         ), //o
    .io_output_cmd_ready                    (writeLogic_bridge_io_input_cmd_ready                                 ), //i
    .io_output_cmd_payload_last             (writeLogic_sourceRemover_io_output_cmd_payload_last                  ), //o
    .io_output_cmd_payload_fragment_opcode  (writeLogic_sourceRemover_io_output_cmd_payload_fragment_opcode       ), //o
    .io_output_cmd_payload_fragment_address (writeLogic_sourceRemover_io_output_cmd_payload_fragment_address[31:0]), //o
    .io_output_cmd_payload_fragment_length  (writeLogic_sourceRemover_io_output_cmd_payload_fragment_length[10:0] ), //o
    .io_output_cmd_payload_fragment_data    (writeLogic_sourceRemover_io_output_cmd_payload_fragment_data[127:0]  ), //o
    .io_output_cmd_payload_fragment_mask    (writeLogic_sourceRemover_io_output_cmd_payload_fragment_mask[15:0]   ), //o
    .io_output_cmd_payload_fragment_context (writeLogic_sourceRemover_io_output_cmd_payload_fragment_context[12:0]), //o
    .io_output_rsp_valid                    (writeLogic_bridge_io_input_rsp_valid                                 ), //i
    .io_output_rsp_ready                    (writeLogic_sourceRemover_io_output_rsp_ready                         ), //o
    .io_output_rsp_payload_last             (writeLogic_bridge_io_input_rsp_payload_last                          ), //i
    .io_output_rsp_payload_fragment_opcode  (writeLogic_bridge_io_input_rsp_payload_fragment_opcode               ), //i
    .io_output_rsp_payload_fragment_context (writeLogic_bridge_io_input_rsp_payload_fragment_context[12:0]        )  //i
  );
  EfxDMA_BmbToAxi4WriteOnlyBridge writeLogic_bridge (
    .io_input_cmd_valid                    (writeLogic_sourceRemover_io_output_cmd_valid                         ), //i
    .io_input_cmd_ready                    (writeLogic_bridge_io_input_cmd_ready                                 ), //o
    .io_input_cmd_payload_last             (writeLogic_sourceRemover_io_output_cmd_payload_last                  ), //i
    .io_input_cmd_payload_fragment_opcode  (writeLogic_sourceRemover_io_output_cmd_payload_fragment_opcode       ), //i
    .io_input_cmd_payload_fragment_address (writeLogic_sourceRemover_io_output_cmd_payload_fragment_address[31:0]), //i
    .io_input_cmd_payload_fragment_length  (writeLogic_sourceRemover_io_output_cmd_payload_fragment_length[10:0] ), //i
    .io_input_cmd_payload_fragment_data    (writeLogic_sourceRemover_io_output_cmd_payload_fragment_data[127:0]  ), //i
    .io_input_cmd_payload_fragment_mask    (writeLogic_sourceRemover_io_output_cmd_payload_fragment_mask[15:0]   ), //i
    .io_input_cmd_payload_fragment_context (writeLogic_sourceRemover_io_output_cmd_payload_fragment_context[12:0]), //i
    .io_input_rsp_valid                    (writeLogic_bridge_io_input_rsp_valid                                 ), //o
    .io_input_rsp_ready                    (writeLogic_sourceRemover_io_output_rsp_ready                         ), //i
    .io_input_rsp_payload_last             (writeLogic_bridge_io_input_rsp_payload_last                          ), //o
    .io_input_rsp_payload_fragment_opcode  (writeLogic_bridge_io_input_rsp_payload_fragment_opcode               ), //o
    .io_input_rsp_payload_fragment_context (writeLogic_bridge_io_input_rsp_payload_fragment_context[12:0]        ), //o
    .io_output_aw_valid                    (writeLogic_bridge_io_output_aw_valid                                 ), //o
    .io_output_aw_ready                    (writeLogic_adapter_aw_ready                                          ), //i
    .io_output_aw_payload_addr             (writeLogic_bridge_io_output_aw_payload_addr[31:0]                    ), //o
    .io_output_aw_payload_len              (writeLogic_bridge_io_output_aw_payload_len[7:0]                      ), //o
    .io_output_aw_payload_size             (writeLogic_bridge_io_output_aw_payload_size[2:0]                     ), //o
    .io_output_aw_payload_cache            (writeLogic_bridge_io_output_aw_payload_cache[3:0]                    ), //o
    .io_output_aw_payload_prot             (writeLogic_bridge_io_output_aw_payload_prot[2:0]                     ), //o
    .io_output_w_valid                     (writeLogic_bridge_io_output_w_valid                                  ), //o
    .io_output_w_ready                     (writeLogic_adapter_w_ready                                           ), //i
    .io_output_w_payload_data              (writeLogic_bridge_io_output_w_payload_data[127:0]                    ), //o
    .io_output_w_payload_strb              (writeLogic_bridge_io_output_w_payload_strb[15:0]                     ), //o
    .io_output_w_payload_last              (writeLogic_bridge_io_output_w_payload_last                           ), //o
    .io_output_b_valid                     (writeLogic_adapter_b_valid                                           ), //i
    .io_output_b_ready                     (writeLogic_bridge_io_output_b_ready                                  ), //o
    .io_output_b_payload_resp              (writeLogic_adapter_b_payload_resp[1:0]                               ), //i
    .clk                                   (clk                                                                  ), //i
    .reset                                 (reset                                                                )  //i
  );
  EfxDMA_BsbUpSizerDense inputsAdapter_0_upsizer_logic (
    .io_input_valid         (dat0_i_tvalid                                             ), //i
    .io_input_ready         (inputsAdapter_0_upsizer_logic_io_input_ready              ), //o
    .io_input_payload_data  (dat0_i_tdata[7:0]                                         ), //i
    .io_input_payload_mask  (dat0_i_tkeep                                              ), //i
    .io_input_payload_sink  (dat0_i_tdest[3:0]                                         ), //i
    .io_input_payload_last  (dat0_i_tlast                                              ), //i
    .io_output_valid        (inputsAdapter_0_upsizer_logic_io_output_valid             ), //o
    .io_output_ready        (inputsAdapter_0_crossclock_fifo_io_push_ready             ), //i
    .io_output_payload_data (inputsAdapter_0_upsizer_logic_io_output_payload_data[31:0]), //o
    .io_output_payload_mask (inputsAdapter_0_upsizer_logic_io_output_payload_mask[3:0] ), //o
    .io_output_payload_sink (inputsAdapter_0_upsizer_logic_io_output_payload_sink[3:0] ), //o
    .io_output_payload_last (inputsAdapter_0_upsizer_logic_io_output_payload_last      ), //o
    .dat0_i_clk             (dat0_i_clk                                                ), //i
    .dat0_i_reset           (dat0_i_reset                                              )  //i
  );
  EfxDMA_StreamFifoCC inputsAdapter_0_crossclock_fifo (
    .io_push_valid        (inputsAdapter_0_upsizer_logic_io_output_valid             ), //i
    .io_push_ready        (inputsAdapter_0_crossclock_fifo_io_push_ready             ), //o
    .io_push_payload_data (inputsAdapter_0_upsizer_logic_io_output_payload_data[31:0]), //i
    .io_push_payload_mask (inputsAdapter_0_upsizer_logic_io_output_payload_mask[3:0] ), //i
    .io_push_payload_sink (inputsAdapter_0_upsizer_logic_io_output_payload_sink[3:0] ), //i
    .io_push_payload_last (inputsAdapter_0_upsizer_logic_io_output_payload_last      ), //i
    .io_pop_valid         (inputsAdapter_0_crossclock_fifo_io_pop_valid              ), //o
    .io_pop_ready         (io_pop_rValidN                                            ), //i
    .io_pop_payload_data  (inputsAdapter_0_crossclock_fifo_io_pop_payload_data[31:0] ), //o
    .io_pop_payload_mask  (inputsAdapter_0_crossclock_fifo_io_pop_payload_mask[3:0]  ), //o
    .io_pop_payload_sink  (inputsAdapter_0_crossclock_fifo_io_pop_payload_sink[3:0]  ), //o
    .io_pop_payload_last  (inputsAdapter_0_crossclock_fifo_io_pop_payload_last       ), //o
    .io_pushOccupancy     (inputsAdapter_0_crossclock_fifo_io_pushOccupancy[4:0]     ), //o
    .io_popOccupancy      (inputsAdapter_0_crossclock_fifo_io_popOccupancy[4:0]      ), //o
    .dat0_i_clk           (dat0_i_clk                                                ), //i
    .dat0_i_reset         (dat0_i_reset                                              ), //i
    .clk                  (clk                                                       ), //i
    .reset                (reset                                                     )  //i
  );
  EfxDMA_StreamFifoCC_1 outputsAdapter_0_crossclock_fifo (
    .io_push_valid        (outputsAdapter_0_ptr_valid                                ), //i
    .io_push_ready        (outputsAdapter_0_crossclock_fifo_io_push_ready            ), //o
    .io_push_payload_data (outputsAdapter_0_ptr_payload_data[31:0]                   ), //i
    .io_push_payload_mask (outputsAdapter_0_ptr_payload_mask[3:0]                    ), //i
    .io_push_payload_sink (outputsAdapter_0_ptr_payload_sink[3:0]                    ), //i
    .io_push_payload_last (outputsAdapter_0_ptr_payload_last                         ), //i
    .io_pop_valid         (outputsAdapter_0_crossclock_fifo_io_pop_valid             ), //o
    .io_pop_ready         (outputsAdapter_0_sparseDownsizer_logic_io_input_ready     ), //i
    .io_pop_payload_data  (outputsAdapter_0_crossclock_fifo_io_pop_payload_data[31:0]), //o
    .io_pop_payload_mask  (outputsAdapter_0_crossclock_fifo_io_pop_payload_mask[3:0] ), //o
    .io_pop_payload_sink  (outputsAdapter_0_crossclock_fifo_io_pop_payload_sink[3:0] ), //o
    .io_pop_payload_last  (outputsAdapter_0_crossclock_fifo_io_pop_payload_last      ), //o
    .io_pushOccupancy     (outputsAdapter_0_crossclock_fifo_io_pushOccupancy[4:0]    ), //o
    .io_popOccupancy      (outputsAdapter_0_crossclock_fifo_io_popOccupancy[4:0]     ), //o
    .clk                  (clk                                                       ), //i
    .reset                (reset                                                     ), //i
    .dat1_o_clk           (dat1_o_clk                                                ), //i
    .dat1_o_reset         (dat1_o_reset                                              )  //i
  );
  EfxDMA_BsbDownSizerSparse outputsAdapter_0_sparseDownsizer_logic (
    .io_input_valid         (outputsAdapter_0_crossclock_fifo_io_pop_valid                     ), //i
    .io_input_ready         (outputsAdapter_0_sparseDownsizer_logic_io_input_ready             ), //o
    .io_input_payload_data  (outputsAdapter_0_crossclock_fifo_io_pop_payload_data[31:0]        ), //i
    .io_input_payload_mask  (outputsAdapter_0_crossclock_fifo_io_pop_payload_mask[3:0]         ), //i
    .io_input_payload_sink  (outputsAdapter_0_crossclock_fifo_io_pop_payload_sink[3:0]         ), //i
    .io_input_payload_last  (outputsAdapter_0_crossclock_fifo_io_pop_payload_last              ), //i
    .io_output_valid        (outputsAdapter_0_sparseDownsizer_logic_io_output_valid            ), //o
    .io_output_ready        (dat1_o_tready                                                     ), //i
    .io_output_payload_data (outputsAdapter_0_sparseDownsizer_logic_io_output_payload_data[7:0]), //o
    .io_output_payload_mask (outputsAdapter_0_sparseDownsizer_logic_io_output_payload_mask     ), //o
    .io_output_payload_sink (outputsAdapter_0_sparseDownsizer_logic_io_output_payload_sink[3:0]), //o
    .io_output_payload_last (outputsAdapter_0_sparseDownsizer_logic_io_output_payload_last     ), //o
    .dat1_o_clk             (dat1_o_clk                                                        ), //i
    .dat1_o_reset           (dat1_o_reset                                                      )  //i
  );
  EfxDMA_BmbArbiter interconnect_read_aggregated_arbiter (
    .io_inputs_0_cmd_valid                    (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_valid                         ), //i
    .io_inputs_0_cmd_ready                    (interconnect_read_aggregated_arbiter_io_inputs_0_cmd_ready                                                  ), //o
    .io_inputs_0_cmd_payload_last             (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_last                  ), //i
    .io_inputs_0_cmd_payload_fragment_opcode  (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_opcode       ), //i
    .io_inputs_0_cmd_payload_fragment_address (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_address[31:0]), //i
    .io_inputs_0_cmd_payload_fragment_length  (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_length[4:0]  ), //i
    .io_inputs_0_cmd_payload_fragment_context (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_context      ), //i
    .io_inputs_0_rsp_valid                    (interconnect_read_aggregated_arbiter_io_inputs_0_rsp_valid                                                  ), //o
    .io_inputs_0_rsp_ready                    (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_ready                         ), //i
    .io_inputs_0_rsp_payload_last             (interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_last                                           ), //o
    .io_inputs_0_rsp_payload_fragment_opcode  (interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_opcode                                ), //o
    .io_inputs_0_rsp_payload_fragment_data    (interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_data[63:0]                            ), //o
    .io_inputs_0_rsp_payload_fragment_context (interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_context                               ), //o
    .io_inputs_1_cmd_valid                    (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_valid                         ), //i
    .io_inputs_1_cmd_ready                    (interconnect_read_aggregated_arbiter_io_inputs_1_cmd_ready                                                  ), //o
    .io_inputs_1_cmd_payload_last             (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_last                  ), //i
    .io_inputs_1_cmd_payload_fragment_opcode  (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_opcode       ), //i
    .io_inputs_1_cmd_payload_fragment_address (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_address[31:0]), //i
    .io_inputs_1_cmd_payload_fragment_length  (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_length[10:0] ), //i
    .io_inputs_1_cmd_payload_fragment_context (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_context[17:0]), //i
    .io_inputs_1_rsp_valid                    (interconnect_read_aggregated_arbiter_io_inputs_1_rsp_valid                                                  ), //o
    .io_inputs_1_rsp_ready                    (interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_ready                         ), //i
    .io_inputs_1_rsp_payload_last             (interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_last                                           ), //o
    .io_inputs_1_rsp_payload_fragment_opcode  (interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_opcode                                ), //o
    .io_inputs_1_rsp_payload_fragment_data    (interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_data[63:0]                            ), //o
    .io_inputs_1_rsp_payload_fragment_context (interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_context[17:0]                         ), //o
    .io_output_cmd_valid                      (interconnect_read_aggregated_arbiter_io_output_cmd_valid                                                    ), //o
    .io_output_cmd_ready                      (interconnect_read_aggregated_cmd_ready                                                                      ), //i
    .io_output_cmd_payload_last               (interconnect_read_aggregated_arbiter_io_output_cmd_payload_last                                             ), //o
    .io_output_cmd_payload_fragment_source    (interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_source                                  ), //o
    .io_output_cmd_payload_fragment_opcode    (interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_opcode                                  ), //o
    .io_output_cmd_payload_fragment_address   (interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_address[31:0]                           ), //o
    .io_output_cmd_payload_fragment_length    (interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_length[10:0]                            ), //o
    .io_output_cmd_payload_fragment_context   (interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_context[17:0]                           ), //o
    .io_output_rsp_valid                      (interconnect_read_aggregated_rsp_valid                                                                      ), //i
    .io_output_rsp_ready                      (interconnect_read_aggregated_arbiter_io_output_rsp_ready                                                    ), //o
    .io_output_rsp_payload_last               (interconnect_read_aggregated_rsp_payload_last                                                               ), //i
    .io_output_rsp_payload_fragment_source    (interconnect_read_aggregated_rsp_payload_fragment_source                                                    ), //i
    .io_output_rsp_payload_fragment_opcode    (interconnect_read_aggregated_rsp_payload_fragment_opcode                                                    ), //i
    .io_output_rsp_payload_fragment_data      (interconnect_read_aggregated_rsp_payload_fragment_data[63:0]                                                ), //i
    .io_output_rsp_payload_fragment_context   (interconnect_read_aggregated_rsp_payload_fragment_context[17:0]                                             ), //i
    .clk                                      (clk                                                                                                         ), //i
    .reset                                    (reset                                                                                                       )  //i
  );
  EfxDMA_BmbArbiter_1 interconnect_write_aggregated_arbiter (
    .io_inputs_0_cmd_valid                    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_valid                         ), //i
    .io_inputs_0_cmd_ready                    (interconnect_write_aggregated_arbiter_io_inputs_0_cmd_ready                                                  ), //o
    .io_inputs_0_cmd_payload_last             (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_last                  ), //i
    .io_inputs_0_cmd_payload_fragment_opcode  (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_opcode       ), //i
    .io_inputs_0_cmd_payload_fragment_address (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_address[31:0]), //i
    .io_inputs_0_cmd_payload_fragment_length  (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_length[1:0]  ), //i
    .io_inputs_0_cmd_payload_fragment_data    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_data[63:0]   ), //i
    .io_inputs_0_cmd_payload_fragment_mask    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_mask[7:0]    ), //i
    .io_inputs_0_cmd_payload_fragment_context (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_context      ), //i
    .io_inputs_0_rsp_valid                    (interconnect_write_aggregated_arbiter_io_inputs_0_rsp_valid                                                  ), //o
    .io_inputs_0_rsp_ready                    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_ready                         ), //i
    .io_inputs_0_rsp_payload_last             (interconnect_write_aggregated_arbiter_io_inputs_0_rsp_payload_last                                           ), //o
    .io_inputs_0_rsp_payload_fragment_opcode  (interconnect_write_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_opcode                                ), //o
    .io_inputs_0_rsp_payload_fragment_context (interconnect_write_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_context                               ), //o
    .io_inputs_1_cmd_valid                    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_valid                         ), //i
    .io_inputs_1_cmd_ready                    (interconnect_write_aggregated_arbiter_io_inputs_1_cmd_ready                                                  ), //o
    .io_inputs_1_cmd_payload_last             (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_last                  ), //i
    .io_inputs_1_cmd_payload_fragment_opcode  (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_opcode       ), //i
    .io_inputs_1_cmd_payload_fragment_address (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_address[31:0]), //i
    .io_inputs_1_cmd_payload_fragment_length  (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_length[10:0] ), //i
    .io_inputs_1_cmd_payload_fragment_data    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_data[63:0]   ), //i
    .io_inputs_1_cmd_payload_fragment_mask    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_mask[7:0]    ), //i
    .io_inputs_1_cmd_payload_fragment_context (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_context[11:0]), //i
    .io_inputs_1_rsp_valid                    (interconnect_write_aggregated_arbiter_io_inputs_1_rsp_valid                                                  ), //o
    .io_inputs_1_rsp_ready                    (interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_ready                         ), //i
    .io_inputs_1_rsp_payload_last             (interconnect_write_aggregated_arbiter_io_inputs_1_rsp_payload_last                                           ), //o
    .io_inputs_1_rsp_payload_fragment_opcode  (interconnect_write_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_opcode                                ), //o
    .io_inputs_1_rsp_payload_fragment_context (interconnect_write_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_context[11:0]                         ), //o
    .io_output_cmd_valid                      (interconnect_write_aggregated_arbiter_io_output_cmd_valid                                                    ), //o
    .io_output_cmd_ready                      (interconnect_write_aggregated_cmd_ready                                                                      ), //i
    .io_output_cmd_payload_last               (interconnect_write_aggregated_arbiter_io_output_cmd_payload_last                                             ), //o
    .io_output_cmd_payload_fragment_source    (interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_source                                  ), //o
    .io_output_cmd_payload_fragment_opcode    (interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_opcode                                  ), //o
    .io_output_cmd_payload_fragment_address   (interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_address[31:0]                           ), //o
    .io_output_cmd_payload_fragment_length    (interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_length[10:0]                            ), //o
    .io_output_cmd_payload_fragment_data      (interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_data[63:0]                              ), //o
    .io_output_cmd_payload_fragment_mask      (interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_mask[7:0]                               ), //o
    .io_output_cmd_payload_fragment_context   (interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_context[11:0]                           ), //o
    .io_output_rsp_valid                      (interconnect_write_aggregated_rsp_valid                                                                      ), //i
    .io_output_rsp_ready                      (interconnect_write_aggregated_arbiter_io_output_rsp_ready                                                    ), //o
    .io_output_rsp_payload_last               (interconnect_write_aggregated_rsp_payload_last                                                               ), //i
    .io_output_rsp_payload_fragment_source    (interconnect_write_aggregated_rsp_payload_fragment_source                                                    ), //i
    .io_output_rsp_payload_fragment_opcode    (interconnect_write_aggregated_rsp_payload_fragment_opcode                                                    ), //i
    .io_output_rsp_payload_fragment_context   (interconnect_write_aggregated_rsp_payload_fragment_context[11:0]                                             ), //i
    .clk                                      (clk                                                                                                          ), //i
    .reset                                    (reset                                                                                                        )  //i
  );
  assign io_0_descriptorUpdate = core_ll_0_descriptorUpdate;
  assign io_1_descriptorUpdate = core_ll_1_descriptorUpdate;
  assign ctrl_PREADY = withCtrlCc_apbCc_io_input_PREADY;
  assign ctrl_PRDATA = withCtrlCc_apbCc_io_input_PRDATA;
  assign ctrl_PSLVERROR = withCtrlCc_apbCc_io_input_PSLVERROR;
  assign ctrl_interrupts = io_interrupts_buffercc_io_dataOut;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_valid = core_io_read_cmd_valid;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_ready = core_io_read_rsp_ready;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_last = core_io_read_cmd_payload_last;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_opcode = core_io_read_cmd_payload_fragment_opcode;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_address = core_io_read_cmd_payload_fragment_address;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_length = core_io_read_cmd_payload_fragment_length;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_context = core_io_read_cmd_payload_fragment_context;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_valid = core_io_sgRead_cmd_valid;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_ready = core_io_sgRead_rsp_ready;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_last = core_io_sgRead_cmd_payload_last;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_opcode = core_io_sgRead_cmd_payload_fragment_opcode;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_address = core_io_sgRead_cmd_payload_fragment_address;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_length = core_io_sgRead_cmd_payload_fragment_length;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_context = core_io_sgRead_cmd_payload_fragment_context;
  assign io_write_cmd_s2mPipe_valid = (core_io_write_cmd_valid || (! io_write_cmd_rValidN));
  assign io_write_cmd_s2mPipe_payload_last = (io_write_cmd_rValidN ? core_io_write_cmd_payload_last : io_write_cmd_rData_last);
  assign io_write_cmd_s2mPipe_payload_fragment_opcode = (io_write_cmd_rValidN ? core_io_write_cmd_payload_fragment_opcode : io_write_cmd_rData_fragment_opcode);
  assign io_write_cmd_s2mPipe_payload_fragment_address = (io_write_cmd_rValidN ? core_io_write_cmd_payload_fragment_address : io_write_cmd_rData_fragment_address);
  assign io_write_cmd_s2mPipe_payload_fragment_length = (io_write_cmd_rValidN ? core_io_write_cmd_payload_fragment_length : io_write_cmd_rData_fragment_length);
  assign io_write_cmd_s2mPipe_payload_fragment_data = (io_write_cmd_rValidN ? core_io_write_cmd_payload_fragment_data : io_write_cmd_rData_fragment_data);
  assign io_write_cmd_s2mPipe_payload_fragment_mask = (io_write_cmd_rValidN ? core_io_write_cmd_payload_fragment_mask : io_write_cmd_rData_fragment_mask);
  assign io_write_cmd_s2mPipe_payload_fragment_context = (io_write_cmd_rValidN ? core_io_write_cmd_payload_fragment_context : io_write_cmd_rData_fragment_context);
  always @(*) begin
    io_write_cmd_s2mPipe_ready = io_write_cmd_s2mPipe_m2sPipe_ready;
    if(when_Stream_l375) begin
      io_write_cmd_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l375 = (! io_write_cmd_s2mPipe_m2sPipe_valid);
  assign io_write_cmd_s2mPipe_m2sPipe_valid = io_write_cmd_s2mPipe_rValid;
  assign io_write_cmd_s2mPipe_m2sPipe_payload_last = io_write_cmd_s2mPipe_rData_last;
  assign io_write_cmd_s2mPipe_m2sPipe_payload_fragment_opcode = io_write_cmd_s2mPipe_rData_fragment_opcode;
  assign io_write_cmd_s2mPipe_m2sPipe_payload_fragment_address = io_write_cmd_s2mPipe_rData_fragment_address;
  assign io_write_cmd_s2mPipe_m2sPipe_payload_fragment_length = io_write_cmd_s2mPipe_rData_fragment_length;
  assign io_write_cmd_s2mPipe_m2sPipe_payload_fragment_data = io_write_cmd_s2mPipe_rData_fragment_data;
  assign io_write_cmd_s2mPipe_m2sPipe_payload_fragment_mask = io_write_cmd_s2mPipe_rData_fragment_mask;
  assign io_write_cmd_s2mPipe_m2sPipe_payload_fragment_context = io_write_cmd_s2mPipe_rData_fragment_context;
  assign io_write_cmd_s2mPipe_m2sPipe_ready = interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_ready;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_valid = io_write_cmd_s2mPipe_m2sPipe_valid;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_ready = core_io_write_rsp_ready;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_last = io_write_cmd_s2mPipe_m2sPipe_payload_last;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_opcode = io_write_cmd_s2mPipe_m2sPipe_payload_fragment_opcode;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_address = io_write_cmd_s2mPipe_m2sPipe_payload_fragment_address;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_length = io_write_cmd_s2mPipe_m2sPipe_payload_fragment_length;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_data = io_write_cmd_s2mPipe_m2sPipe_payload_fragment_data;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_mask = io_write_cmd_s2mPipe_m2sPipe_payload_fragment_mask;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_payload_fragment_context = io_write_cmd_s2mPipe_m2sPipe_payload_fragment_context;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_valid = core_io_sgWrite_cmd_valid;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_ready = core_io_sgWrite_rsp_ready;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_last = core_io_sgWrite_cmd_payload_last;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_opcode = core_io_sgWrite_cmd_payload_fragment_opcode;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_address = core_io_sgWrite_cmd_payload_fragment_address;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_length = core_io_sgWrite_cmd_payload_fragment_length;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_data = core_io_sgWrite_cmd_payload_fragment_data;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_mask = core_io_sgWrite_cmd_payload_fragment_mask;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_payload_fragment_context = core_io_sgWrite_cmd_payload_fragment_context;
  assign interconnect_read_aggregated_cmd_halfPipe_fire = (interconnect_read_aggregated_cmd_halfPipe_valid && interconnect_read_aggregated_cmd_halfPipe_ready);
  assign interconnect_read_aggregated_cmd_ready = (! interconnect_read_aggregated_cmd_rValid);
  assign interconnect_read_aggregated_cmd_halfPipe_valid = interconnect_read_aggregated_cmd_rValid;
  assign interconnect_read_aggregated_cmd_halfPipe_payload_last = interconnect_read_aggregated_cmd_rData_last;
  assign interconnect_read_aggregated_cmd_halfPipe_payload_fragment_source = interconnect_read_aggregated_cmd_rData_fragment_source;
  assign interconnect_read_aggregated_cmd_halfPipe_payload_fragment_opcode = interconnect_read_aggregated_cmd_rData_fragment_opcode;
  assign interconnect_read_aggregated_cmd_halfPipe_payload_fragment_address = interconnect_read_aggregated_cmd_rData_fragment_address;
  assign interconnect_read_aggregated_cmd_halfPipe_payload_fragment_length = interconnect_read_aggregated_cmd_rData_fragment_length;
  assign interconnect_read_aggregated_cmd_halfPipe_payload_fragment_context = interconnect_read_aggregated_cmd_rData_fragment_context;
  assign interconnect_read_aggregated_cmd_halfPipe_ready = bmbUpSizerBridge_io_input_cmd_ready;
  assign interconnect_read_aggregated_rsp_valid = bmbUpSizerBridge_io_input_rsp_valid;
  assign interconnect_read_aggregated_rsp_payload_last = bmbUpSizerBridge_io_input_rsp_payload_last;
  assign interconnect_read_aggregated_rsp_payload_fragment_source = bmbUpSizerBridge_io_input_rsp_payload_fragment_source;
  assign interconnect_read_aggregated_rsp_payload_fragment_opcode = bmbUpSizerBridge_io_input_rsp_payload_fragment_opcode;
  assign interconnect_read_aggregated_rsp_payload_fragment_data = bmbUpSizerBridge_io_input_rsp_payload_fragment_data;
  assign interconnect_read_aggregated_rsp_payload_fragment_context = bmbUpSizerBridge_io_input_rsp_payload_fragment_context;
  assign readLogic_adapter_ar_valid = readLogic_bridge_io_output_ar_valid;
  assign readLogic_adapter_ar_payload_addr = readLogic_bridge_io_output_ar_payload_addr;
  assign _zz_readLogic_adapter_ar_payload_region[3 : 0] = 4'b0000;
  assign readLogic_adapter_ar_payload_region = _zz_readLogic_adapter_ar_payload_region;
  assign readLogic_adapter_ar_payload_len = readLogic_bridge_io_output_ar_payload_len;
  assign readLogic_adapter_ar_payload_size = readLogic_bridge_io_output_ar_payload_size;
  assign readLogic_adapter_ar_payload_burst = 2'b01;
  assign readLogic_adapter_ar_payload_lock = 1'b0;
  assign readLogic_adapter_ar_payload_cache = readLogic_bridge_io_output_ar_payload_cache;
  assign readLogic_adapter_ar_payload_qos = 4'b0000;
  assign readLogic_adapter_ar_payload_prot = readLogic_bridge_io_output_ar_payload_prot;
  assign readLogic_adapter_r_ready = readLogic_bridge_io_output_r_ready;
  assign readLogic_adapter_ar_halfPipe_fire = (readLogic_adapter_ar_halfPipe_valid && readLogic_adapter_ar_halfPipe_ready);
  assign readLogic_adapter_ar_ready = (! readLogic_adapter_ar_rValid);
  assign readLogic_adapter_ar_halfPipe_valid = readLogic_adapter_ar_rValid;
  assign readLogic_adapter_ar_halfPipe_payload_addr = readLogic_adapter_ar_rData_addr;
  assign readLogic_adapter_ar_halfPipe_payload_region = readLogic_adapter_ar_rData_region;
  assign readLogic_adapter_ar_halfPipe_payload_len = readLogic_adapter_ar_rData_len;
  assign readLogic_adapter_ar_halfPipe_payload_size = readLogic_adapter_ar_rData_size;
  assign readLogic_adapter_ar_halfPipe_payload_burst = readLogic_adapter_ar_rData_burst;
  assign readLogic_adapter_ar_halfPipe_payload_lock = readLogic_adapter_ar_rData_lock;
  assign readLogic_adapter_ar_halfPipe_payload_cache = readLogic_adapter_ar_rData_cache;
  assign readLogic_adapter_ar_halfPipe_payload_qos = readLogic_adapter_ar_rData_qos;
  assign readLogic_adapter_ar_halfPipe_payload_prot = readLogic_adapter_ar_rData_prot;
  assign read_arvalid = readLogic_adapter_ar_halfPipe_valid;
  assign readLogic_adapter_ar_halfPipe_ready = read_arready;
  assign read_araddr = readLogic_adapter_ar_halfPipe_payload_addr;
  assign read_arregion = readLogic_adapter_ar_halfPipe_payload_region;
  assign read_arlen = readLogic_adapter_ar_halfPipe_payload_len;
  assign read_arsize = readLogic_adapter_ar_halfPipe_payload_size;
  assign read_arburst = readLogic_adapter_ar_halfPipe_payload_burst;
  assign read_arlock = readLogic_adapter_ar_halfPipe_payload_lock;
  assign read_arcache = readLogic_adapter_ar_halfPipe_payload_cache;
  assign read_arqos = readLogic_adapter_ar_halfPipe_payload_qos;
  assign read_arprot = readLogic_adapter_ar_halfPipe_payload_prot;
  assign read_rready = read_r_rValidN;
  assign read_r_s2mPipe_valid = (read_rvalid || (! read_r_rValidN));
  assign read_r_s2mPipe_payload_data = (read_r_rValidN ? read_rdata : read_r_rData_data);
  assign read_r_s2mPipe_payload_resp = (read_r_rValidN ? read_rresp : read_r_rData_resp);
  assign read_r_s2mPipe_payload_last = (read_r_rValidN ? read_rlast : read_r_rData_last);
  always @(*) begin
    read_r_s2mPipe_ready = readLogic_beforeQueue_ready;
    if(when_Stream_l375_1) begin
      read_r_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l375_1 = (! readLogic_beforeQueue_valid);
  assign readLogic_beforeQueue_valid = read_r_s2mPipe_rValid;
  assign readLogic_beforeQueue_payload_data = read_r_s2mPipe_rData_data;
  assign readLogic_beforeQueue_payload_resp = read_r_s2mPipe_rData_resp;
  assign readLogic_beforeQueue_payload_last = read_r_s2mPipe_rData_last;
  assign readLogic_adapter_r_valid = readLogic_beforeQueue_valid;
  assign readLogic_beforeQueue_ready = readLogic_adapter_r_ready;
  assign readLogic_adapter_r_payload_data = readLogic_beforeQueue_payload_data;
  assign readLogic_adapter_r_payload_resp = readLogic_beforeQueue_payload_resp;
  assign readLogic_adapter_r_payload_last = readLogic_beforeQueue_payload_last;
  always @(*) begin
    interconnect_write_aggregated_cmd_ready = interconnect_write_aggregated_cmd_m2sPipe_ready;
    if(when_Stream_l375_2) begin
      interconnect_write_aggregated_cmd_ready = 1'b1;
    end
  end

  assign when_Stream_l375_2 = (! interconnect_write_aggregated_cmd_m2sPipe_valid);
  assign interconnect_write_aggregated_cmd_m2sPipe_valid = interconnect_write_aggregated_cmd_rValid;
  assign interconnect_write_aggregated_cmd_m2sPipe_payload_last = interconnect_write_aggregated_cmd_rData_last;
  assign interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_source = interconnect_write_aggregated_cmd_rData_fragment_source;
  assign interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_opcode = interconnect_write_aggregated_cmd_rData_fragment_opcode;
  assign interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_address = interconnect_write_aggregated_cmd_rData_fragment_address;
  assign interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_length = interconnect_write_aggregated_cmd_rData_fragment_length;
  assign interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_data = interconnect_write_aggregated_cmd_rData_fragment_data;
  assign interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_mask = interconnect_write_aggregated_cmd_rData_fragment_mask;
  assign interconnect_write_aggregated_cmd_m2sPipe_payload_fragment_context = interconnect_write_aggregated_cmd_rData_fragment_context;
  assign interconnect_write_aggregated_cmd_m2sPipe_ready = bmbUpSizerBridge_1_io_input_cmd_ready;
  assign interconnect_write_aggregated_rsp_valid = bmbUpSizerBridge_1_io_input_rsp_valid;
  assign interconnect_write_aggregated_rsp_payload_last = bmbUpSizerBridge_1_io_input_rsp_payload_last;
  assign interconnect_write_aggregated_rsp_payload_fragment_source = bmbUpSizerBridge_1_io_input_rsp_payload_fragment_source;
  assign interconnect_write_aggregated_rsp_payload_fragment_opcode = bmbUpSizerBridge_1_io_input_rsp_payload_fragment_opcode;
  assign interconnect_write_aggregated_rsp_payload_fragment_context = bmbUpSizerBridge_1_io_input_rsp_payload_fragment_context;
  assign writeLogic_adapter_aw_valid = writeLogic_bridge_io_output_aw_valid;
  assign writeLogic_adapter_aw_payload_addr = writeLogic_bridge_io_output_aw_payload_addr;
  assign _zz_writeLogic_adapter_aw_payload_region[3 : 0] = 4'b0000;
  assign writeLogic_adapter_aw_payload_region = _zz_writeLogic_adapter_aw_payload_region;
  assign writeLogic_adapter_aw_payload_len = writeLogic_bridge_io_output_aw_payload_len;
  assign writeLogic_adapter_aw_payload_size = writeLogic_bridge_io_output_aw_payload_size;
  assign writeLogic_adapter_aw_payload_burst = 2'b01;
  assign writeLogic_adapter_aw_payload_lock = 1'b0;
  assign writeLogic_adapter_aw_payload_cache = writeLogic_bridge_io_output_aw_payload_cache;
  assign writeLogic_adapter_aw_payload_qos = 4'b0000;
  assign writeLogic_adapter_aw_payload_prot = writeLogic_bridge_io_output_aw_payload_prot;
  assign writeLogic_adapter_w_valid = writeLogic_bridge_io_output_w_valid;
  assign writeLogic_adapter_w_payload_data = writeLogic_bridge_io_output_w_payload_data;
  assign writeLogic_adapter_w_payload_strb = writeLogic_bridge_io_output_w_payload_strb;
  assign writeLogic_adapter_w_payload_last = writeLogic_bridge_io_output_w_payload_last;
  assign writeLogic_adapter_b_ready = writeLogic_bridge_io_output_b_ready;
  assign writeLogic_adapter_aw_halfPipe_fire = (writeLogic_adapter_aw_halfPipe_valid && writeLogic_adapter_aw_halfPipe_ready);
  assign writeLogic_adapter_aw_ready = (! writeLogic_adapter_aw_rValid);
  assign writeLogic_adapter_aw_halfPipe_valid = writeLogic_adapter_aw_rValid;
  assign writeLogic_adapter_aw_halfPipe_payload_addr = writeLogic_adapter_aw_rData_addr;
  assign writeLogic_adapter_aw_halfPipe_payload_region = writeLogic_adapter_aw_rData_region;
  assign writeLogic_adapter_aw_halfPipe_payload_len = writeLogic_adapter_aw_rData_len;
  assign writeLogic_adapter_aw_halfPipe_payload_size = writeLogic_adapter_aw_rData_size;
  assign writeLogic_adapter_aw_halfPipe_payload_burst = writeLogic_adapter_aw_rData_burst;
  assign writeLogic_adapter_aw_halfPipe_payload_lock = writeLogic_adapter_aw_rData_lock;
  assign writeLogic_adapter_aw_halfPipe_payload_cache = writeLogic_adapter_aw_rData_cache;
  assign writeLogic_adapter_aw_halfPipe_payload_qos = writeLogic_adapter_aw_rData_qos;
  assign writeLogic_adapter_aw_halfPipe_payload_prot = writeLogic_adapter_aw_rData_prot;
  assign write_awvalid = writeLogic_adapter_aw_halfPipe_valid;
  assign writeLogic_adapter_aw_halfPipe_ready = write_awready;
  assign write_awaddr = writeLogic_adapter_aw_halfPipe_payload_addr;
  assign write_awregion = writeLogic_adapter_aw_halfPipe_payload_region;
  assign write_awlen = writeLogic_adapter_aw_halfPipe_payload_len;
  assign write_awsize = writeLogic_adapter_aw_halfPipe_payload_size;
  assign write_awburst = writeLogic_adapter_aw_halfPipe_payload_burst;
  assign write_awlock = writeLogic_adapter_aw_halfPipe_payload_lock;
  assign write_awcache = writeLogic_adapter_aw_halfPipe_payload_cache;
  assign write_awqos = writeLogic_adapter_aw_halfPipe_payload_qos;
  assign write_awprot = writeLogic_adapter_aw_halfPipe_payload_prot;
  assign writeLogic_adapter_w_ready = writeLogic_adapter_w_rValidN;
  assign writeLogic_adapter_w_s2mPipe_valid = (writeLogic_adapter_w_valid || (! writeLogic_adapter_w_rValidN));
  assign writeLogic_adapter_w_s2mPipe_payload_data = (writeLogic_adapter_w_rValidN ? writeLogic_adapter_w_payload_data : writeLogic_adapter_w_rData_data);
  assign writeLogic_adapter_w_s2mPipe_payload_strb = (writeLogic_adapter_w_rValidN ? writeLogic_adapter_w_payload_strb : writeLogic_adapter_w_rData_strb);
  assign writeLogic_adapter_w_s2mPipe_payload_last = (writeLogic_adapter_w_rValidN ? writeLogic_adapter_w_payload_last : writeLogic_adapter_w_rData_last);
  always @(*) begin
    writeLogic_adapter_w_s2mPipe_ready = writeLogic_adapter_w_s2mPipe_m2sPipe_ready;
    if(when_Stream_l375_3) begin
      writeLogic_adapter_w_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l375_3 = (! writeLogic_adapter_w_s2mPipe_m2sPipe_valid);
  assign writeLogic_adapter_w_s2mPipe_m2sPipe_valid = writeLogic_adapter_w_s2mPipe_rValid;
  assign writeLogic_adapter_w_s2mPipe_m2sPipe_payload_data = writeLogic_adapter_w_s2mPipe_rData_data;
  assign writeLogic_adapter_w_s2mPipe_m2sPipe_payload_strb = writeLogic_adapter_w_s2mPipe_rData_strb;
  assign writeLogic_adapter_w_s2mPipe_m2sPipe_payload_last = writeLogic_adapter_w_s2mPipe_rData_last;
  assign write_wvalid = writeLogic_adapter_w_s2mPipe_m2sPipe_valid;
  assign writeLogic_adapter_w_s2mPipe_m2sPipe_ready = write_wready;
  assign write_wdata = writeLogic_adapter_w_s2mPipe_m2sPipe_payload_data;
  assign write_wstrb = writeLogic_adapter_w_s2mPipe_m2sPipe_payload_strb;
  assign write_wlast = writeLogic_adapter_w_s2mPipe_m2sPipe_payload_last;
  assign write_b_halfPipe_fire = (write_b_halfPipe_valid && write_b_halfPipe_ready);
  assign write_bready = (! write_b_rValid);
  assign write_b_halfPipe_valid = write_b_rValid;
  assign write_b_halfPipe_payload_resp = write_b_rData_resp;
  assign writeLogic_adapter_b_valid = write_b_halfPipe_valid;
  assign write_b_halfPipe_ready = writeLogic_adapter_b_ready;
  assign writeLogic_adapter_b_payload_resp = write_b_halfPipe_payload_resp;
  assign dat0_i_tready = inputsAdapter_0_upsizer_logic_io_input_ready;
  assign io_pop_s2mPipe_valid = (inputsAdapter_0_crossclock_fifo_io_pop_valid || (! io_pop_rValidN));
  assign io_pop_s2mPipe_payload_data = (io_pop_rValidN ? inputsAdapter_0_crossclock_fifo_io_pop_payload_data : io_pop_rData_data);
  assign io_pop_s2mPipe_payload_mask = (io_pop_rValidN ? inputsAdapter_0_crossclock_fifo_io_pop_payload_mask : io_pop_rData_mask);
  assign io_pop_s2mPipe_payload_sink = (io_pop_rValidN ? inputsAdapter_0_crossclock_fifo_io_pop_payload_sink : io_pop_rData_sink);
  assign io_pop_s2mPipe_payload_last = (io_pop_rValidN ? inputsAdapter_0_crossclock_fifo_io_pop_payload_last : io_pop_rData_last);
  always @(*) begin
    io_pop_s2mPipe_ready = io_pop_s2mPipe_m2sPipe_ready;
    if(when_Stream_l375_4) begin
      io_pop_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l375_4 = (! io_pop_s2mPipe_m2sPipe_valid);
  assign io_pop_s2mPipe_m2sPipe_valid = io_pop_s2mPipe_rValid;
  assign io_pop_s2mPipe_m2sPipe_payload_data = io_pop_s2mPipe_rData_data;
  assign io_pop_s2mPipe_m2sPipe_payload_mask = io_pop_s2mPipe_rData_mask;
  assign io_pop_s2mPipe_m2sPipe_payload_sink = io_pop_s2mPipe_rData_sink;
  assign io_pop_s2mPipe_m2sPipe_payload_last = io_pop_s2mPipe_rData_last;
  assign io_pop_s2mPipe_m2sPipe_ready = core_io_inputs_0_ready;
  assign io_outputs_0_s2mPipe_valid = (core_io_outputs_0_valid || (! io_outputs_0_rValidN));
  assign io_outputs_0_s2mPipe_payload_data = (io_outputs_0_rValidN ? core_io_outputs_0_payload_data : io_outputs_0_rData_data);
  assign io_outputs_0_s2mPipe_payload_mask = (io_outputs_0_rValidN ? core_io_outputs_0_payload_mask : io_outputs_0_rData_mask);
  assign io_outputs_0_s2mPipe_payload_sink = (io_outputs_0_rValidN ? core_io_outputs_0_payload_sink : io_outputs_0_rData_sink);
  assign io_outputs_0_s2mPipe_payload_last = (io_outputs_0_rValidN ? core_io_outputs_0_payload_last : io_outputs_0_rData_last);
  always @(*) begin
    io_outputs_0_s2mPipe_ready = outputsAdapter_0_ptr_ready;
    if(when_Stream_l375_5) begin
      io_outputs_0_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l375_5 = (! outputsAdapter_0_ptr_valid);
  assign outputsAdapter_0_ptr_valid = io_outputs_0_s2mPipe_rValid;
  assign outputsAdapter_0_ptr_payload_data = io_outputs_0_s2mPipe_rData_data;
  assign outputsAdapter_0_ptr_payload_mask = io_outputs_0_s2mPipe_rData_mask;
  assign outputsAdapter_0_ptr_payload_sink = io_outputs_0_s2mPipe_rData_sink;
  assign outputsAdapter_0_ptr_payload_last = io_outputs_0_s2mPipe_rData_last;
  assign outputsAdapter_0_ptr_ready = outputsAdapter_0_crossclock_fifo_io_push_ready;
  assign dat1_o_tvalid = outputsAdapter_0_sparseDownsizer_logic_io_output_valid;
  assign dat1_o_tdata = outputsAdapter_0_sparseDownsizer_logic_io_output_payload_data;
  assign dat1_o_tkeep = outputsAdapter_0_sparseDownsizer_logic_io_output_payload_mask;
  assign dat1_o_tdest = outputsAdapter_0_sparseDownsizer_logic_io_output_payload_sink;
  assign dat1_o_tlast = outputsAdapter_0_sparseDownsizer_logic_io_output_payload_last;
  assign interconnect_read_aggregated_cmd_valid = interconnect_read_aggregated_arbiter_io_output_cmd_valid;
  assign interconnect_read_aggregated_rsp_ready = interconnect_read_aggregated_arbiter_io_output_rsp_ready;
  assign interconnect_read_aggregated_cmd_payload_last = interconnect_read_aggregated_arbiter_io_output_cmd_payload_last;
  assign interconnect_read_aggregated_cmd_payload_fragment_source = interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_source;
  assign interconnect_read_aggregated_cmd_payload_fragment_opcode = interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_opcode;
  assign interconnect_read_aggregated_cmd_payload_fragment_address = interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_address;
  assign interconnect_read_aggregated_cmd_payload_fragment_length = interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_length;
  assign interconnect_read_aggregated_cmd_payload_fragment_context = interconnect_read_aggregated_arbiter_io_output_cmd_payload_fragment_context;
  assign interconnect_write_aggregated_cmd_valid = interconnect_write_aggregated_arbiter_io_output_cmd_valid;
  assign interconnect_write_aggregated_rsp_ready = interconnect_write_aggregated_arbiter_io_output_rsp_ready;
  assign interconnect_write_aggregated_cmd_payload_last = interconnect_write_aggregated_arbiter_io_output_cmd_payload_last;
  assign interconnect_write_aggregated_cmd_payload_fragment_source = interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_source;
  assign interconnect_write_aggregated_cmd_payload_fragment_opcode = interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_opcode;
  assign interconnect_write_aggregated_cmd_payload_fragment_address = interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_address;
  assign interconnect_write_aggregated_cmd_payload_fragment_length = interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_length;
  assign interconnect_write_aggregated_cmd_payload_fragment_data = interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_data;
  assign interconnect_write_aggregated_cmd_payload_fragment_mask = interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_mask;
  assign interconnect_write_aggregated_cmd_payload_fragment_context = interconnect_write_aggregated_arbiter_io_output_cmd_payload_fragment_context;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_ready = interconnect_read_aggregated_arbiter_io_inputs_0_cmd_ready;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_valid = interconnect_read_aggregated_arbiter_io_inputs_0_rsp_valid;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_last = interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_last;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_opcode = interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_opcode;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_data = interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_data;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_context = interconnect_read_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_context;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_ready = interconnect_read_aggregated_arbiter_io_inputs_1_cmd_ready;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_valid = interconnect_read_aggregated_arbiter_io_inputs_1_rsp_valid;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_last = interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_last;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_opcode = interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_opcode;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_data = interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_data;
  assign interconnect_read_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_context = interconnect_read_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_context;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_cmd_ready = interconnect_write_aggregated_arbiter_io_inputs_0_cmd_ready;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_valid = interconnect_write_aggregated_arbiter_io_inputs_0_rsp_valid;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_last = interconnect_write_aggregated_arbiter_io_inputs_0_rsp_payload_last;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_opcode = interconnect_write_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_opcode;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_0_decoder_rsp_payload_fragment_context = interconnect_write_aggregated_arbiter_io_inputs_0_rsp_payload_fragment_context;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_cmd_ready = interconnect_write_aggregated_arbiter_io_inputs_1_cmd_ready;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_valid = interconnect_write_aggregated_arbiter_io_inputs_1_rsp_valid;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_last = interconnect_write_aggregated_arbiter_io_inputs_1_rsp_payload_last;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_opcode = interconnect_write_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_opcode;
  assign interconnect_write_aggregated_slaveModel_arbiterGen_logic_sorted_1_decoder_rsp_payload_fragment_context = interconnect_write_aggregated_arbiter_io_inputs_1_rsp_payload_fragment_context;
  always @(posedge clk) begin
    if(reset) begin
      io_write_cmd_rValidN <= 1'b1;
      io_write_cmd_s2mPipe_rValid <= 1'b0;
      interconnect_read_aggregated_cmd_rValid <= 1'b0;
      readLogic_adapter_ar_rValid <= 1'b0;
      read_r_rValidN <= 1'b1;
      read_r_s2mPipe_rValid <= 1'b0;
      interconnect_write_aggregated_cmd_rValid <= 1'b0;
      writeLogic_adapter_aw_rValid <= 1'b0;
      writeLogic_adapter_w_rValidN <= 1'b1;
      writeLogic_adapter_w_s2mPipe_rValid <= 1'b0;
      write_b_rValid <= 1'b0;
      io_pop_rValidN <= 1'b1;
      io_pop_s2mPipe_rValid <= 1'b0;
      io_outputs_0_rValidN <= 1'b1;
      io_outputs_0_s2mPipe_rValid <= 1'b0;
    end else begin
      if(core_io_write_cmd_valid) begin
        io_write_cmd_rValidN <= 1'b0;
      end
      if(io_write_cmd_s2mPipe_ready) begin
        io_write_cmd_rValidN <= 1'b1;
      end
      if(io_write_cmd_s2mPipe_ready) begin
        io_write_cmd_s2mPipe_rValid <= io_write_cmd_s2mPipe_valid;
      end
      if(interconnect_read_aggregated_cmd_valid) begin
        interconnect_read_aggregated_cmd_rValid <= 1'b1;
      end
      if(interconnect_read_aggregated_cmd_halfPipe_fire) begin
        interconnect_read_aggregated_cmd_rValid <= 1'b0;
      end
      if(readLogic_adapter_ar_valid) begin
        readLogic_adapter_ar_rValid <= 1'b1;
      end
      if(readLogic_adapter_ar_halfPipe_fire) begin
        readLogic_adapter_ar_rValid <= 1'b0;
      end
      if(read_rvalid) begin
        read_r_rValidN <= 1'b0;
      end
      if(read_r_s2mPipe_ready) begin
        read_r_rValidN <= 1'b1;
      end
      if(read_r_s2mPipe_ready) begin
        read_r_s2mPipe_rValid <= read_r_s2mPipe_valid;
      end
      if(interconnect_write_aggregated_cmd_ready) begin
        interconnect_write_aggregated_cmd_rValid <= interconnect_write_aggregated_cmd_valid;
      end
      if(writeLogic_adapter_aw_valid) begin
        writeLogic_adapter_aw_rValid <= 1'b1;
      end
      if(writeLogic_adapter_aw_halfPipe_fire) begin
        writeLogic_adapter_aw_rValid <= 1'b0;
      end
      if(writeLogic_adapter_w_valid) begin
        writeLogic_adapter_w_rValidN <= 1'b0;
      end
      if(writeLogic_adapter_w_s2mPipe_ready) begin
        writeLogic_adapter_w_rValidN <= 1'b1;
      end
      if(writeLogic_adapter_w_s2mPipe_ready) begin
        writeLogic_adapter_w_s2mPipe_rValid <= writeLogic_adapter_w_s2mPipe_valid;
      end
      if(write_bvalid) begin
        write_b_rValid <= 1'b1;
      end
      if(write_b_halfPipe_fire) begin
        write_b_rValid <= 1'b0;
      end
      if(inputsAdapter_0_crossclock_fifo_io_pop_valid) begin
        io_pop_rValidN <= 1'b0;
      end
      if(io_pop_s2mPipe_ready) begin
        io_pop_rValidN <= 1'b1;
      end
      if(io_pop_s2mPipe_ready) begin
        io_pop_s2mPipe_rValid <= io_pop_s2mPipe_valid;
      end
      if(core_io_outputs_0_valid) begin
        io_outputs_0_rValidN <= 1'b0;
      end
      if(io_outputs_0_s2mPipe_ready) begin
        io_outputs_0_rValidN <= 1'b1;
      end
      if(io_outputs_0_s2mPipe_ready) begin
        io_outputs_0_s2mPipe_rValid <= io_outputs_0_s2mPipe_valid;
      end
    end
  end

  always @(posedge clk) begin
    if(io_write_cmd_rValidN) begin
      io_write_cmd_rData_last <= core_io_write_cmd_payload_last;
      io_write_cmd_rData_fragment_opcode <= core_io_write_cmd_payload_fragment_opcode;
      io_write_cmd_rData_fragment_address <= core_io_write_cmd_payload_fragment_address;
      io_write_cmd_rData_fragment_length <= core_io_write_cmd_payload_fragment_length;
      io_write_cmd_rData_fragment_data <= core_io_write_cmd_payload_fragment_data;
      io_write_cmd_rData_fragment_mask <= core_io_write_cmd_payload_fragment_mask;
      io_write_cmd_rData_fragment_context <= core_io_write_cmd_payload_fragment_context;
    end
    if(io_write_cmd_s2mPipe_ready) begin
      io_write_cmd_s2mPipe_rData_last <= io_write_cmd_s2mPipe_payload_last;
      io_write_cmd_s2mPipe_rData_fragment_opcode <= io_write_cmd_s2mPipe_payload_fragment_opcode;
      io_write_cmd_s2mPipe_rData_fragment_address <= io_write_cmd_s2mPipe_payload_fragment_address;
      io_write_cmd_s2mPipe_rData_fragment_length <= io_write_cmd_s2mPipe_payload_fragment_length;
      io_write_cmd_s2mPipe_rData_fragment_data <= io_write_cmd_s2mPipe_payload_fragment_data;
      io_write_cmd_s2mPipe_rData_fragment_mask <= io_write_cmd_s2mPipe_payload_fragment_mask;
      io_write_cmd_s2mPipe_rData_fragment_context <= io_write_cmd_s2mPipe_payload_fragment_context;
    end
    if(interconnect_read_aggregated_cmd_ready) begin
      interconnect_read_aggregated_cmd_rData_last <= interconnect_read_aggregated_cmd_payload_last;
      interconnect_read_aggregated_cmd_rData_fragment_source <= interconnect_read_aggregated_cmd_payload_fragment_source;
      interconnect_read_aggregated_cmd_rData_fragment_opcode <= interconnect_read_aggregated_cmd_payload_fragment_opcode;
      interconnect_read_aggregated_cmd_rData_fragment_address <= interconnect_read_aggregated_cmd_payload_fragment_address;
      interconnect_read_aggregated_cmd_rData_fragment_length <= interconnect_read_aggregated_cmd_payload_fragment_length;
      interconnect_read_aggregated_cmd_rData_fragment_context <= interconnect_read_aggregated_cmd_payload_fragment_context;
    end
    if(readLogic_adapter_ar_ready) begin
      readLogic_adapter_ar_rData_addr <= readLogic_adapter_ar_payload_addr;
      readLogic_adapter_ar_rData_region <= readLogic_adapter_ar_payload_region;
      readLogic_adapter_ar_rData_len <= readLogic_adapter_ar_payload_len;
      readLogic_adapter_ar_rData_size <= readLogic_adapter_ar_payload_size;
      readLogic_adapter_ar_rData_burst <= readLogic_adapter_ar_payload_burst;
      readLogic_adapter_ar_rData_lock <= readLogic_adapter_ar_payload_lock;
      readLogic_adapter_ar_rData_cache <= readLogic_adapter_ar_payload_cache;
      readLogic_adapter_ar_rData_qos <= readLogic_adapter_ar_payload_qos;
      readLogic_adapter_ar_rData_prot <= readLogic_adapter_ar_payload_prot;
    end
    if(read_rready) begin
      read_r_rData_data <= read_rdata;
      read_r_rData_resp <= read_rresp;
      read_r_rData_last <= read_rlast;
    end
    if(read_r_s2mPipe_ready) begin
      read_r_s2mPipe_rData_data <= read_r_s2mPipe_payload_data;
      read_r_s2mPipe_rData_resp <= read_r_s2mPipe_payload_resp;
      read_r_s2mPipe_rData_last <= read_r_s2mPipe_payload_last;
    end
    if(interconnect_write_aggregated_cmd_ready) begin
      interconnect_write_aggregated_cmd_rData_last <= interconnect_write_aggregated_cmd_payload_last;
      interconnect_write_aggregated_cmd_rData_fragment_source <= interconnect_write_aggregated_cmd_payload_fragment_source;
      interconnect_write_aggregated_cmd_rData_fragment_opcode <= interconnect_write_aggregated_cmd_payload_fragment_opcode;
      interconnect_write_aggregated_cmd_rData_fragment_address <= interconnect_write_aggregated_cmd_payload_fragment_address;
      interconnect_write_aggregated_cmd_rData_fragment_length <= interconnect_write_aggregated_cmd_payload_fragment_length;
      interconnect_write_aggregated_cmd_rData_fragment_data <= interconnect_write_aggregated_cmd_payload_fragment_data;
      interconnect_write_aggregated_cmd_rData_fragment_mask <= interconnect_write_aggregated_cmd_payload_fragment_mask;
      interconnect_write_aggregated_cmd_rData_fragment_context <= interconnect_write_aggregated_cmd_payload_fragment_context;
    end
    if(writeLogic_adapter_aw_ready) begin
      writeLogic_adapter_aw_rData_addr <= writeLogic_adapter_aw_payload_addr;
      writeLogic_adapter_aw_rData_region <= writeLogic_adapter_aw_payload_region;
      writeLogic_adapter_aw_rData_len <= writeLogic_adapter_aw_payload_len;
      writeLogic_adapter_aw_rData_size <= writeLogic_adapter_aw_payload_size;
      writeLogic_adapter_aw_rData_burst <= writeLogic_adapter_aw_payload_burst;
      writeLogic_adapter_aw_rData_lock <= writeLogic_adapter_aw_payload_lock;
      writeLogic_adapter_aw_rData_cache <= writeLogic_adapter_aw_payload_cache;
      writeLogic_adapter_aw_rData_qos <= writeLogic_adapter_aw_payload_qos;
      writeLogic_adapter_aw_rData_prot <= writeLogic_adapter_aw_payload_prot;
    end
    if(writeLogic_adapter_w_ready) begin
      writeLogic_adapter_w_rData_data <= writeLogic_adapter_w_payload_data;
      writeLogic_adapter_w_rData_strb <= writeLogic_adapter_w_payload_strb;
      writeLogic_adapter_w_rData_last <= writeLogic_adapter_w_payload_last;
    end
    if(writeLogic_adapter_w_s2mPipe_ready) begin
      writeLogic_adapter_w_s2mPipe_rData_data <= writeLogic_adapter_w_s2mPipe_payload_data;
      writeLogic_adapter_w_s2mPipe_rData_strb <= writeLogic_adapter_w_s2mPipe_payload_strb;
      writeLogic_adapter_w_s2mPipe_rData_last <= writeLogic_adapter_w_s2mPipe_payload_last;
    end
    if(write_bready) begin
      write_b_rData_resp <= write_bresp;
    end
    if(io_pop_rValidN) begin
      io_pop_rData_data <= inputsAdapter_0_crossclock_fifo_io_pop_payload_data;
      io_pop_rData_mask <= inputsAdapter_0_crossclock_fifo_io_pop_payload_mask;
      io_pop_rData_sink <= inputsAdapter_0_crossclock_fifo_io_pop_payload_sink;
      io_pop_rData_last <= inputsAdapter_0_crossclock_fifo_io_pop_payload_last;
    end
    if(io_pop_s2mPipe_ready) begin
      io_pop_s2mPipe_rData_data <= io_pop_s2mPipe_payload_data;
      io_pop_s2mPipe_rData_mask <= io_pop_s2mPipe_payload_mask;
      io_pop_s2mPipe_rData_sink <= io_pop_s2mPipe_payload_sink;
      io_pop_s2mPipe_rData_last <= io_pop_s2mPipe_payload_last;
    end
    if(io_outputs_0_rValidN) begin
      io_outputs_0_rData_data <= core_io_outputs_0_payload_data;
      io_outputs_0_rData_mask <= core_io_outputs_0_payload_mask;
      io_outputs_0_rData_sink <= core_io_outputs_0_payload_sink;
      io_outputs_0_rData_last <= core_io_outputs_0_payload_last;
    end
    if(io_outputs_0_s2mPipe_ready) begin
      io_outputs_0_s2mPipe_rData_data <= io_outputs_0_s2mPipe_payload_data;
      io_outputs_0_s2mPipe_rData_mask <= io_outputs_0_s2mPipe_payload_mask;
      io_outputs_0_s2mPipe_rData_sink <= io_outputs_0_s2mPipe_payload_sink;
      io_outputs_0_s2mPipe_rData_last <= io_outputs_0_s2mPipe_payload_last;
    end
  end


endmodule

module EfxDMA_BmbArbiter_1 (
  input  wire          io_inputs_0_cmd_valid,
  output wire          io_inputs_0_cmd_ready,
  input  wire          io_inputs_0_cmd_payload_last,
  input  wire [0:0]    io_inputs_0_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_inputs_0_cmd_payload_fragment_address,
  input  wire [1:0]    io_inputs_0_cmd_payload_fragment_length,
  input  wire [63:0]   io_inputs_0_cmd_payload_fragment_data,
  input  wire [7:0]    io_inputs_0_cmd_payload_fragment_mask,
  input  wire [0:0]    io_inputs_0_cmd_payload_fragment_context,
  output wire          io_inputs_0_rsp_valid,
  input  wire          io_inputs_0_rsp_ready,
  output wire          io_inputs_0_rsp_payload_last,
  output wire [0:0]    io_inputs_0_rsp_payload_fragment_opcode,
  output wire [0:0]    io_inputs_0_rsp_payload_fragment_context,
  input  wire          io_inputs_1_cmd_valid,
  output wire          io_inputs_1_cmd_ready,
  input  wire          io_inputs_1_cmd_payload_last,
  input  wire [0:0]    io_inputs_1_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_inputs_1_cmd_payload_fragment_address,
  input  wire [10:0]   io_inputs_1_cmd_payload_fragment_length,
  input  wire [63:0]   io_inputs_1_cmd_payload_fragment_data,
  input  wire [7:0]    io_inputs_1_cmd_payload_fragment_mask,
  input  wire [11:0]   io_inputs_1_cmd_payload_fragment_context,
  output wire          io_inputs_1_rsp_valid,
  input  wire          io_inputs_1_rsp_ready,
  output wire          io_inputs_1_rsp_payload_last,
  output wire [0:0]    io_inputs_1_rsp_payload_fragment_opcode,
  output wire [11:0]   io_inputs_1_rsp_payload_fragment_context,
  output wire          io_output_cmd_valid,
  input  wire          io_output_cmd_ready,
  output wire          io_output_cmd_payload_last,
  output wire [0:0]    io_output_cmd_payload_fragment_source,
  output wire [0:0]    io_output_cmd_payload_fragment_opcode,
  output wire [31:0]   io_output_cmd_payload_fragment_address,
  output wire [10:0]   io_output_cmd_payload_fragment_length,
  output wire [63:0]   io_output_cmd_payload_fragment_data,
  output wire [7:0]    io_output_cmd_payload_fragment_mask,
  output wire [11:0]   io_output_cmd_payload_fragment_context,
  input  wire          io_output_rsp_valid,
  output wire          io_output_rsp_ready,
  input  wire          io_output_rsp_payload_last,
  input  wire [0:0]    io_output_rsp_payload_fragment_source,
  input  wire [0:0]    io_output_rsp_payload_fragment_opcode,
  input  wire [11:0]   io_output_rsp_payload_fragment_context,
  input  wire          clk,
  input  wire          reset
);

  wire       [10:0]   memory_arbiter_io_inputs_0_payload_fragment_length;
  wire       [11:0]   memory_arbiter_io_inputs_0_payload_fragment_context;
  wire                memory_arbiter_io_inputs_0_ready;
  wire                memory_arbiter_io_inputs_1_ready;
  wire                memory_arbiter_io_output_valid;
  wire                memory_arbiter_io_output_payload_last;
  wire       [0:0]    memory_arbiter_io_output_payload_fragment_source;
  wire       [0:0]    memory_arbiter_io_output_payload_fragment_opcode;
  wire       [31:0]   memory_arbiter_io_output_payload_fragment_address;
  wire       [10:0]   memory_arbiter_io_output_payload_fragment_length;
  wire       [63:0]   memory_arbiter_io_output_payload_fragment_data;
  wire       [7:0]    memory_arbiter_io_output_payload_fragment_mask;
  wire       [11:0]   memory_arbiter_io_output_payload_fragment_context;
  wire       [0:0]    memory_arbiter_io_chosen;
  wire       [1:0]    memory_arbiter_io_chosenOH;
  wire       [1:0]    _zz_io_output_cmd_payload_fragment_source;
  reg                 _zz_io_output_rsp_ready;
  wire       [0:0]    memory_rspSel;

  assign _zz_io_output_cmd_payload_fragment_source = {memory_arbiter_io_output_payload_fragment_source,memory_arbiter_io_chosen};
  EfxDMA_StreamArbiter_1 memory_arbiter (
    .io_inputs_0_valid                    (io_inputs_0_cmd_valid                                    ), //i
    .io_inputs_0_ready                    (memory_arbiter_io_inputs_0_ready                         ), //o
    .io_inputs_0_payload_last             (io_inputs_0_cmd_payload_last                             ), //i
    .io_inputs_0_payload_fragment_source  (1'b0                                                     ), //i
    .io_inputs_0_payload_fragment_opcode  (io_inputs_0_cmd_payload_fragment_opcode                  ), //i
    .io_inputs_0_payload_fragment_address (io_inputs_0_cmd_payload_fragment_address[31:0]           ), //i
    .io_inputs_0_payload_fragment_length  (memory_arbiter_io_inputs_0_payload_fragment_length[10:0] ), //i
    .io_inputs_0_payload_fragment_data    (io_inputs_0_cmd_payload_fragment_data[63:0]              ), //i
    .io_inputs_0_payload_fragment_mask    (io_inputs_0_cmd_payload_fragment_mask[7:0]               ), //i
    .io_inputs_0_payload_fragment_context (memory_arbiter_io_inputs_0_payload_fragment_context[11:0]), //i
    .io_inputs_1_valid                    (io_inputs_1_cmd_valid                                    ), //i
    .io_inputs_1_ready                    (memory_arbiter_io_inputs_1_ready                         ), //o
    .io_inputs_1_payload_last             (io_inputs_1_cmd_payload_last                             ), //i
    .io_inputs_1_payload_fragment_source  (1'b0                                                     ), //i
    .io_inputs_1_payload_fragment_opcode  (io_inputs_1_cmd_payload_fragment_opcode                  ), //i
    .io_inputs_1_payload_fragment_address (io_inputs_1_cmd_payload_fragment_address[31:0]           ), //i
    .io_inputs_1_payload_fragment_length  (io_inputs_1_cmd_payload_fragment_length[10:0]            ), //i
    .io_inputs_1_payload_fragment_data    (io_inputs_1_cmd_payload_fragment_data[63:0]              ), //i
    .io_inputs_1_payload_fragment_mask    (io_inputs_1_cmd_payload_fragment_mask[7:0]               ), //i
    .io_inputs_1_payload_fragment_context (io_inputs_1_cmd_payload_fragment_context[11:0]           ), //i
    .io_output_valid                      (memory_arbiter_io_output_valid                           ), //o
    .io_output_ready                      (io_output_cmd_ready                                      ), //i
    .io_output_payload_last               (memory_arbiter_io_output_payload_last                    ), //o
    .io_output_payload_fragment_source    (memory_arbiter_io_output_payload_fragment_source         ), //o
    .io_output_payload_fragment_opcode    (memory_arbiter_io_output_payload_fragment_opcode         ), //o
    .io_output_payload_fragment_address   (memory_arbiter_io_output_payload_fragment_address[31:0]  ), //o
    .io_output_payload_fragment_length    (memory_arbiter_io_output_payload_fragment_length[10:0]   ), //o
    .io_output_payload_fragment_data      (memory_arbiter_io_output_payload_fragment_data[63:0]     ), //o
    .io_output_payload_fragment_mask      (memory_arbiter_io_output_payload_fragment_mask[7:0]      ), //o
    .io_output_payload_fragment_context   (memory_arbiter_io_output_payload_fragment_context[11:0]  ), //o
    .io_chosen                            (memory_arbiter_io_chosen                                 ), //o
    .io_chosenOH                          (memory_arbiter_io_chosenOH[1:0]                          ), //o
    .clk                                  (clk                                                      ), //i
    .reset                                (reset                                                    )  //i
  );
  always @(*) begin
    case(memory_rspSel)
      1'b0 : _zz_io_output_rsp_ready = io_inputs_0_rsp_ready;
      default : _zz_io_output_rsp_ready = io_inputs_1_rsp_ready;
    endcase
  end

  assign io_inputs_0_cmd_ready = memory_arbiter_io_inputs_0_ready;
  assign memory_arbiter_io_inputs_0_payload_fragment_length = {9'd0, io_inputs_0_cmd_payload_fragment_length};
  assign memory_arbiter_io_inputs_0_payload_fragment_context = {11'd0, io_inputs_0_cmd_payload_fragment_context};
  assign io_inputs_1_cmd_ready = memory_arbiter_io_inputs_1_ready;
  assign io_output_cmd_valid = memory_arbiter_io_output_valid;
  assign io_output_cmd_payload_last = memory_arbiter_io_output_payload_last;
  assign io_output_cmd_payload_fragment_opcode = memory_arbiter_io_output_payload_fragment_opcode;
  assign io_output_cmd_payload_fragment_address = memory_arbiter_io_output_payload_fragment_address;
  assign io_output_cmd_payload_fragment_length = memory_arbiter_io_output_payload_fragment_length;
  assign io_output_cmd_payload_fragment_data = memory_arbiter_io_output_payload_fragment_data;
  assign io_output_cmd_payload_fragment_mask = memory_arbiter_io_output_payload_fragment_mask;
  assign io_output_cmd_payload_fragment_context = memory_arbiter_io_output_payload_fragment_context;
  assign io_output_cmd_payload_fragment_source = _zz_io_output_cmd_payload_fragment_source[0:0];
  assign memory_rspSel = io_output_rsp_payload_fragment_source[0 : 0];
  assign io_inputs_0_rsp_valid = (io_output_rsp_valid && (memory_rspSel == 1'b0));
  assign io_inputs_0_rsp_payload_last = io_output_rsp_payload_last;
  assign io_inputs_0_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_inputs_0_rsp_payload_fragment_context = io_output_rsp_payload_fragment_context[0:0];
  assign io_inputs_1_rsp_valid = (io_output_rsp_valid && (memory_rspSel == 1'b1));
  assign io_inputs_1_rsp_payload_last = io_output_rsp_payload_last;
  assign io_inputs_1_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_inputs_1_rsp_payload_fragment_context = io_output_rsp_payload_fragment_context;
  assign io_output_rsp_ready = _zz_io_output_rsp_ready;

endmodule

module EfxDMA_BmbArbiter (
  input  wire          io_inputs_0_cmd_valid,
  output wire          io_inputs_0_cmd_ready,
  input  wire          io_inputs_0_cmd_payload_last,
  input  wire [0:0]    io_inputs_0_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_inputs_0_cmd_payload_fragment_address,
  input  wire [4:0]    io_inputs_0_cmd_payload_fragment_length,
  input  wire [0:0]    io_inputs_0_cmd_payload_fragment_context,
  output wire          io_inputs_0_rsp_valid,
  input  wire          io_inputs_0_rsp_ready,
  output wire          io_inputs_0_rsp_payload_last,
  output wire [0:0]    io_inputs_0_rsp_payload_fragment_opcode,
  output wire [63:0]   io_inputs_0_rsp_payload_fragment_data,
  output wire [0:0]    io_inputs_0_rsp_payload_fragment_context,
  input  wire          io_inputs_1_cmd_valid,
  output wire          io_inputs_1_cmd_ready,
  input  wire          io_inputs_1_cmd_payload_last,
  input  wire [0:0]    io_inputs_1_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_inputs_1_cmd_payload_fragment_address,
  input  wire [10:0]   io_inputs_1_cmd_payload_fragment_length,
  input  wire [17:0]   io_inputs_1_cmd_payload_fragment_context,
  output wire          io_inputs_1_rsp_valid,
  input  wire          io_inputs_1_rsp_ready,
  output wire          io_inputs_1_rsp_payload_last,
  output wire [0:0]    io_inputs_1_rsp_payload_fragment_opcode,
  output wire [63:0]   io_inputs_1_rsp_payload_fragment_data,
  output wire [17:0]   io_inputs_1_rsp_payload_fragment_context,
  output wire          io_output_cmd_valid,
  input  wire          io_output_cmd_ready,
  output wire          io_output_cmd_payload_last,
  output wire [0:0]    io_output_cmd_payload_fragment_source,
  output wire [0:0]    io_output_cmd_payload_fragment_opcode,
  output wire [31:0]   io_output_cmd_payload_fragment_address,
  output wire [10:0]   io_output_cmd_payload_fragment_length,
  output wire [17:0]   io_output_cmd_payload_fragment_context,
  input  wire          io_output_rsp_valid,
  output wire          io_output_rsp_ready,
  input  wire          io_output_rsp_payload_last,
  input  wire [0:0]    io_output_rsp_payload_fragment_source,
  input  wire [0:0]    io_output_rsp_payload_fragment_opcode,
  input  wire [63:0]   io_output_rsp_payload_fragment_data,
  input  wire [17:0]   io_output_rsp_payload_fragment_context,
  input  wire          clk,
  input  wire          reset
);

  wire       [10:0]   memory_arbiter_io_inputs_0_payload_fragment_length;
  wire       [17:0]   memory_arbiter_io_inputs_0_payload_fragment_context;
  wire                memory_arbiter_io_inputs_0_ready;
  wire                memory_arbiter_io_inputs_1_ready;
  wire                memory_arbiter_io_output_valid;
  wire                memory_arbiter_io_output_payload_last;
  wire       [0:0]    memory_arbiter_io_output_payload_fragment_source;
  wire       [0:0]    memory_arbiter_io_output_payload_fragment_opcode;
  wire       [31:0]   memory_arbiter_io_output_payload_fragment_address;
  wire       [10:0]   memory_arbiter_io_output_payload_fragment_length;
  wire       [17:0]   memory_arbiter_io_output_payload_fragment_context;
  wire       [0:0]    memory_arbiter_io_chosen;
  wire       [1:0]    memory_arbiter_io_chosenOH;
  wire       [1:0]    _zz_io_output_cmd_payload_fragment_source;
  reg                 _zz_io_output_rsp_ready;
  wire       [0:0]    memory_rspSel;

  assign _zz_io_output_cmd_payload_fragment_source = {memory_arbiter_io_output_payload_fragment_source,memory_arbiter_io_chosen};
  EfxDMA_StreamArbiter memory_arbiter (
    .io_inputs_0_valid                    (io_inputs_0_cmd_valid                                    ), //i
    .io_inputs_0_ready                    (memory_arbiter_io_inputs_0_ready                         ), //o
    .io_inputs_0_payload_last             (io_inputs_0_cmd_payload_last                             ), //i
    .io_inputs_0_payload_fragment_source  (1'b0                                                     ), //i
    .io_inputs_0_payload_fragment_opcode  (io_inputs_0_cmd_payload_fragment_opcode                  ), //i
    .io_inputs_0_payload_fragment_address (io_inputs_0_cmd_payload_fragment_address[31:0]           ), //i
    .io_inputs_0_payload_fragment_length  (memory_arbiter_io_inputs_0_payload_fragment_length[10:0] ), //i
    .io_inputs_0_payload_fragment_context (memory_arbiter_io_inputs_0_payload_fragment_context[17:0]), //i
    .io_inputs_1_valid                    (io_inputs_1_cmd_valid                                    ), //i
    .io_inputs_1_ready                    (memory_arbiter_io_inputs_1_ready                         ), //o
    .io_inputs_1_payload_last             (io_inputs_1_cmd_payload_last                             ), //i
    .io_inputs_1_payload_fragment_source  (1'b0                                                     ), //i
    .io_inputs_1_payload_fragment_opcode  (io_inputs_1_cmd_payload_fragment_opcode                  ), //i
    .io_inputs_1_payload_fragment_address (io_inputs_1_cmd_payload_fragment_address[31:0]           ), //i
    .io_inputs_1_payload_fragment_length  (io_inputs_1_cmd_payload_fragment_length[10:0]            ), //i
    .io_inputs_1_payload_fragment_context (io_inputs_1_cmd_payload_fragment_context[17:0]           ), //i
    .io_output_valid                      (memory_arbiter_io_output_valid                           ), //o
    .io_output_ready                      (io_output_cmd_ready                                      ), //i
    .io_output_payload_last               (memory_arbiter_io_output_payload_last                    ), //o
    .io_output_payload_fragment_source    (memory_arbiter_io_output_payload_fragment_source         ), //o
    .io_output_payload_fragment_opcode    (memory_arbiter_io_output_payload_fragment_opcode         ), //o
    .io_output_payload_fragment_address   (memory_arbiter_io_output_payload_fragment_address[31:0]  ), //o
    .io_output_payload_fragment_length    (memory_arbiter_io_output_payload_fragment_length[10:0]   ), //o
    .io_output_payload_fragment_context   (memory_arbiter_io_output_payload_fragment_context[17:0]  ), //o
    .io_chosen                            (memory_arbiter_io_chosen                                 ), //o
    .io_chosenOH                          (memory_arbiter_io_chosenOH[1:0]                          ), //o
    .clk                                  (clk                                                      ), //i
    .reset                                (reset                                                    )  //i
  );
  always @(*) begin
    case(memory_rspSel)
      1'b0 : _zz_io_output_rsp_ready = io_inputs_0_rsp_ready;
      default : _zz_io_output_rsp_ready = io_inputs_1_rsp_ready;
    endcase
  end

  assign io_inputs_0_cmd_ready = memory_arbiter_io_inputs_0_ready;
  assign memory_arbiter_io_inputs_0_payload_fragment_length = {6'd0, io_inputs_0_cmd_payload_fragment_length};
  assign memory_arbiter_io_inputs_0_payload_fragment_context = {17'd0, io_inputs_0_cmd_payload_fragment_context};
  assign io_inputs_1_cmd_ready = memory_arbiter_io_inputs_1_ready;
  assign io_output_cmd_valid = memory_arbiter_io_output_valid;
  assign io_output_cmd_payload_last = memory_arbiter_io_output_payload_last;
  assign io_output_cmd_payload_fragment_opcode = memory_arbiter_io_output_payload_fragment_opcode;
  assign io_output_cmd_payload_fragment_address = memory_arbiter_io_output_payload_fragment_address;
  assign io_output_cmd_payload_fragment_length = memory_arbiter_io_output_payload_fragment_length;
  assign io_output_cmd_payload_fragment_context = memory_arbiter_io_output_payload_fragment_context;
  assign io_output_cmd_payload_fragment_source = _zz_io_output_cmd_payload_fragment_source[0:0];
  assign memory_rspSel = io_output_rsp_payload_fragment_source[0 : 0];
  assign io_inputs_0_rsp_valid = (io_output_rsp_valid && (memory_rspSel == 1'b0));
  assign io_inputs_0_rsp_payload_last = io_output_rsp_payload_last;
  assign io_inputs_0_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_inputs_0_rsp_payload_fragment_data = io_output_rsp_payload_fragment_data;
  assign io_inputs_0_rsp_payload_fragment_context = io_output_rsp_payload_fragment_context[0:0];
  assign io_inputs_1_rsp_valid = (io_output_rsp_valid && (memory_rspSel == 1'b1));
  assign io_inputs_1_rsp_payload_last = io_output_rsp_payload_last;
  assign io_inputs_1_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_inputs_1_rsp_payload_fragment_data = io_output_rsp_payload_fragment_data;
  assign io_inputs_1_rsp_payload_fragment_context = io_output_rsp_payload_fragment_context;
  assign io_output_rsp_ready = _zz_io_output_rsp_ready;

endmodule

module EfxDMA_BsbDownSizerSparse (
  input  wire          io_input_valid,
  output wire          io_input_ready,
  input  wire [31:0]   io_input_payload_data,
  input  wire [3:0]    io_input_payload_mask,
  input  wire [3:0]    io_input_payload_sink,
  input  wire          io_input_payload_last,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire [7:0]    io_output_payload_data,
  output wire [0:0]    io_output_payload_mask,
  output wire [3:0]    io_output_payload_sink,
  output wire          io_output_payload_last,
  input  wire          dat1_o_clk,
  input  wire          dat1_o_reset
);

  reg        [7:0]    _zz_io_output_payload_data;
  reg        [0:0]    _zz_io_output_payload_mask;
  reg        [1:0]    counter;
  wire                end_1;
  wire                io_output_fire;

  always @(*) begin
    case(counter)
      2'b00 : begin
        _zz_io_output_payload_data = io_input_payload_data[7 : 0];
        _zz_io_output_payload_mask = io_input_payload_mask[0 : 0];
      end
      2'b01 : begin
        _zz_io_output_payload_data = io_input_payload_data[15 : 8];
        _zz_io_output_payload_mask = io_input_payload_mask[1 : 1];
      end
      2'b10 : begin
        _zz_io_output_payload_data = io_input_payload_data[23 : 16];
        _zz_io_output_payload_mask = io_input_payload_mask[2 : 2];
      end
      default : begin
        _zz_io_output_payload_data = io_input_payload_data[31 : 24];
        _zz_io_output_payload_mask = io_input_payload_mask[3 : 3];
      end
    endcase
  end

  assign end_1 = (counter == 2'b11);
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign io_input_ready = (io_output_ready && end_1);
  assign io_output_valid = io_input_valid;
  assign io_output_payload_data = _zz_io_output_payload_data;
  assign io_output_payload_mask = _zz_io_output_payload_mask;
  assign io_output_payload_sink = io_input_payload_sink;
  assign io_output_payload_last = (io_input_payload_last && end_1);
  always @(posedge dat1_o_clk) begin
    if(dat1_o_reset) begin
      counter <= 2'b00;
    end else begin
      if(io_output_fire) begin
        counter <= (counter + 2'b01);
      end
    end
  end


endmodule

module EfxDMA_StreamFifoCC_1 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [31:0]   io_push_payload_data,
  input  wire [3:0]    io_push_payload_mask,
  input  wire [3:0]    io_push_payload_sink,
  input  wire          io_push_payload_last,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [31:0]   io_pop_payload_data,
  output wire [3:0]    io_pop_payload_mask,
  output wire [3:0]    io_pop_payload_sink,
  output wire          io_pop_payload_last,
  output wire [4:0]    io_pushOccupancy,
  output wire [4:0]    io_popOccupancy,
  input  wire          clk,
  input  wire          reset,
  input  wire          dat1_o_clk,
  input  wire          dat1_o_reset
);

  reg        [40:0]   ram_spinal_port1;
  wire       [4:0]    popToPushGray_buffercc_io_dataOut;
  wire       [4:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [4:0]    _zz_pushCC_pushPtrGray;
  wire       [3:0]    _zz_ram_port;
  wire       [40:0]   _zz_ram_port_1;
  wire       [4:0]    _zz_popCC_popPtrGray;
  reg                 _zz_1;
  wire       [4:0]    popToPushGray;
  wire       [4:0]    pushToPopGray;
  reg        [4:0]    pushCC_pushPtr;
  wire       [4:0]    pushCC_pushPtrPlus;
  wire                io_push_fire;
  reg        [4:0]    pushCC_pushPtrGray;
  wire       [4:0]    pushCC_popPtrGray;
  wire                pushCC_full;
  wire                _zz_io_pushOccupancy;
  wire                _zz_io_pushOccupancy_1;
  wire                _zz_io_pushOccupancy_2;
  wire                _zz_io_pushOccupancy_3;
  reg        [4:0]    popCC_popPtr;
  (* keep , syn_keep *) wire       [4:0]    popCC_popPtrPlus /* synthesis syn_keep = 1 */ ;
  wire       [4:0]    popCC_popPtrGray;
  wire       [4:0]    popCC_pushPtrGray;
  wire                popCC_addressGen_valid;
  reg                 popCC_addressGen_ready;
  wire       [3:0]    popCC_addressGen_payload;
  wire                popCC_empty;
  wire                popCC_addressGen_fire;
  wire                popCC_readArbitation_valid;
  wire                popCC_readArbitation_ready;
  wire       [3:0]    popCC_readArbitation_payload;
  reg                 popCC_addressGen_rValid;
  reg        [3:0]    popCC_addressGen_rData;
  wire                when_Stream_l375;
  wire                popCC_readPort_cmd_valid;
  wire       [3:0]    popCC_readPort_cmd_payload;
  wire       [31:0]   popCC_readPort_rsp_data;
  wire       [3:0]    popCC_readPort_rsp_mask;
  wire       [3:0]    popCC_readPort_rsp_sink;
  wire                popCC_readPort_rsp_last;
  wire       [40:0]   _zz_popCC_readPort_rsp_data;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [31:0]   popCC_readArbitation_translated_payload_data;
  wire       [3:0]    popCC_readArbitation_translated_payload_mask;
  wire       [3:0]    popCC_readArbitation_translated_payload_sink;
  wire                popCC_readArbitation_translated_payload_last;
  wire                popCC_readArbitation_fire;
  reg        [4:0]    popCC_ptrToPush;
  reg        [4:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  wire                _zz_io_popOccupancy_2;
  wire                _zz_io_popOccupancy_3;
  reg [40:0] ram [0:15];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[3:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_last,{io_push_payload_sink,{io_push_payload_mask,io_push_payload_data}}};
  always @(posedge clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge dat1_o_clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) EfxDMA_BufferCC_3 popToPushGray_buffercc (
    .io_dataIn  (popToPushGray[4:0]                    ), //i
    .io_dataOut (popToPushGray_buffercc_io_dataOut[4:0]), //o
    .clk        (clk                                   ), //i
    .reset      (reset                                 )  //i
  );
  (* keep_hierarchy = "TRUE" *) EfxDMA_BufferCC_5 pushToPopGray_buffercc (
    .io_dataIn    (pushToPopGray[4:0]                    ), //i
    .io_dataOut   (pushToPopGray_buffercc_io_dataOut[4:0]), //o
    .dat1_o_clk   (dat1_o_clk                            ), //i
    .dat1_o_reset (dat1_o_reset                          )  //i
  );
  always @(*) begin
    _zz_1 = 1'b0;
    if(io_push_fire) begin
      _zz_1 = 1'b1;
    end
  end

  assign pushCC_pushPtrPlus = (pushCC_pushPtr + 5'h01);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign pushCC_popPtrGray = popToPushGray_buffercc_io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[4 : 3] == (~ pushCC_popPtrGray[4 : 3])) && (pushCC_pushPtrGray[2 : 0] == pushCC_popPtrGray[2 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_io_pushOccupancy = (pushCC_popPtrGray[1] ^ _zz_io_pushOccupancy_1);
  assign _zz_io_pushOccupancy_1 = (pushCC_popPtrGray[2] ^ _zz_io_pushOccupancy_2);
  assign _zz_io_pushOccupancy_2 = (pushCC_popPtrGray[3] ^ _zz_io_pushOccupancy_3);
  assign _zz_io_pushOccupancy_3 = pushCC_popPtrGray[4];
  assign io_pushOccupancy = (pushCC_pushPtr - {_zz_io_pushOccupancy_3,{_zz_io_pushOccupancy_2,{_zz_io_pushOccupancy_1,{_zz_io_pushOccupancy,(pushCC_popPtrGray[0] ^ _zz_io_pushOccupancy)}}}});
  assign popCC_popPtrPlus = (popCC_popPtr + 5'h01);
  assign popCC_popPtrGray = (_zz_popCC_popPtrGray ^ popCC_popPtr);
  assign popCC_pushPtrGray = pushToPopGray_buffercc_io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign popCC_addressGen_valid = (! popCC_empty);
  assign popCC_addressGen_payload = popCC_popPtr[3:0];
  assign popCC_addressGen_fire = (popCC_addressGen_valid && popCC_addressGen_ready);
  always @(*) begin
    popCC_addressGen_ready = popCC_readArbitation_ready;
    if(when_Stream_l375) begin
      popCC_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l375 = (! popCC_readArbitation_valid);
  assign popCC_readArbitation_valid = popCC_addressGen_rValid;
  assign popCC_readArbitation_payload = popCC_addressGen_rData;
  assign _zz_popCC_readPort_rsp_data = ram_spinal_port1;
  assign popCC_readPort_rsp_data = _zz_popCC_readPort_rsp_data[31 : 0];
  assign popCC_readPort_rsp_mask = _zz_popCC_readPort_rsp_data[35 : 32];
  assign popCC_readPort_rsp_sink = _zz_popCC_readPort_rsp_data[39 : 36];
  assign popCC_readPort_rsp_last = _zz_popCC_readPort_rsp_data[40];
  assign popCC_readPort_cmd_valid = popCC_addressGen_fire;
  assign popCC_readPort_cmd_payload = popCC_addressGen_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_data = popCC_readPort_rsp_data;
  assign popCC_readArbitation_translated_payload_mask = popCC_readPort_rsp_mask;
  assign popCC_readArbitation_translated_payload_sink = popCC_readPort_rsp_sink;
  assign popCC_readArbitation_translated_payload_last = popCC_readPort_rsp_last;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_data = popCC_readArbitation_translated_payload_data;
  assign io_pop_payload_mask = popCC_readArbitation_translated_payload_mask;
  assign io_pop_payload_sink = popCC_readArbitation_translated_payload_sink;
  assign io_pop_payload_last = popCC_readArbitation_translated_payload_last;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = (popCC_pushPtrGray[2] ^ _zz_io_popOccupancy_2);
  assign _zz_io_popOccupancy_2 = (popCC_pushPtrGray[3] ^ _zz_io_popOccupancy_3);
  assign _zz_io_popOccupancy_3 = popCC_pushPtrGray[4];
  assign io_popOccupancy = ({_zz_io_popOccupancy_3,{_zz_io_popOccupancy_2,{_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}}}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  always @(posedge clk) begin
    if(reset) begin
      pushCC_pushPtr <= 5'h0;
      pushCC_pushPtrGray <= 5'h0;
    end else begin
      if(io_push_fire) begin
        pushCC_pushPtrGray <= (_zz_pushCC_pushPtrGray ^ pushCC_pushPtrPlus);
      end
      if(io_push_fire) begin
        pushCC_pushPtr <= pushCC_pushPtrPlus;
      end
    end
  end

  always @(posedge dat1_o_clk) begin
    if(dat1_o_reset) begin
      popCC_popPtr <= 5'h0;
      popCC_addressGen_rValid <= 1'b0;
      popCC_ptrToPush <= 5'h0;
      popCC_ptrToOccupancy <= 5'h0;
    end else begin
      if(popCC_addressGen_fire) begin
        popCC_popPtr <= popCC_popPtrPlus;
      end
      if(popCC_addressGen_ready) begin
        popCC_addressGen_rValid <= popCC_addressGen_valid;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToPush <= popCC_popPtrGray;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToOccupancy <= popCC_popPtr;
      end
    end
  end

  always @(posedge dat1_o_clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module EfxDMA_StreamFifoCC (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [31:0]   io_push_payload_data,
  input  wire [3:0]    io_push_payload_mask,
  input  wire [3:0]    io_push_payload_sink,
  input  wire          io_push_payload_last,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [31:0]   io_pop_payload_data,
  output wire [3:0]    io_pop_payload_mask,
  output wire [3:0]    io_pop_payload_sink,
  output wire          io_pop_payload_last,
  output wire [4:0]    io_pushOccupancy,
  output wire [4:0]    io_popOccupancy,
  input  wire          dat0_i_clk,
  input  wire          dat0_i_reset,
  input  wire          clk,
  input  wire          reset
);

  reg        [40:0]   ram_spinal_port1;
  wire       [4:0]    popToPushGray_buffercc_io_dataOut;
  wire       [4:0]    pushToPopGray_buffercc_io_dataOut;
  wire       [4:0]    _zz_pushCC_pushPtrGray;
  wire       [3:0]    _zz_ram_port;
  wire       [40:0]   _zz_ram_port_1;
  wire       [4:0]    _zz_popCC_popPtrGray;
  reg                 _zz_1;
  wire       [4:0]    popToPushGray;
  wire       [4:0]    pushToPopGray;
  reg        [4:0]    pushCC_pushPtr;
  wire       [4:0]    pushCC_pushPtrPlus;
  wire                io_push_fire;
  reg        [4:0]    pushCC_pushPtrGray;
  wire       [4:0]    pushCC_popPtrGray;
  wire                pushCC_full;
  wire                _zz_io_pushOccupancy;
  wire                _zz_io_pushOccupancy_1;
  wire                _zz_io_pushOccupancy_2;
  wire                _zz_io_pushOccupancy_3;
  reg        [4:0]    popCC_popPtr;
  (* keep , syn_keep *) wire       [4:0]    popCC_popPtrPlus /* synthesis syn_keep = 1 */ ;
  wire       [4:0]    popCC_popPtrGray;
  wire       [4:0]    popCC_pushPtrGray;
  wire                popCC_addressGen_valid;
  reg                 popCC_addressGen_ready;
  wire       [3:0]    popCC_addressGen_payload;
  wire                popCC_empty;
  wire                popCC_addressGen_fire;
  wire                popCC_readArbitation_valid;
  wire                popCC_readArbitation_ready;
  wire       [3:0]    popCC_readArbitation_payload;
  reg                 popCC_addressGen_rValid;
  reg        [3:0]    popCC_addressGen_rData;
  wire                when_Stream_l375;
  wire                popCC_readPort_cmd_valid;
  wire       [3:0]    popCC_readPort_cmd_payload;
  wire       [31:0]   popCC_readPort_rsp_data;
  wire       [3:0]    popCC_readPort_rsp_mask;
  wire       [3:0]    popCC_readPort_rsp_sink;
  wire                popCC_readPort_rsp_last;
  wire       [40:0]   _zz_popCC_readPort_rsp_data;
  wire                popCC_readArbitation_translated_valid;
  wire                popCC_readArbitation_translated_ready;
  wire       [31:0]   popCC_readArbitation_translated_payload_data;
  wire       [3:0]    popCC_readArbitation_translated_payload_mask;
  wire       [3:0]    popCC_readArbitation_translated_payload_sink;
  wire                popCC_readArbitation_translated_payload_last;
  wire                popCC_readArbitation_fire;
  reg        [4:0]    popCC_ptrToPush;
  reg        [4:0]    popCC_ptrToOccupancy;
  wire                _zz_io_popOccupancy;
  wire                _zz_io_popOccupancy_1;
  wire                _zz_io_popOccupancy_2;
  wire                _zz_io_popOccupancy_3;
  reg [40:0] ram [0:15];

  assign _zz_pushCC_pushPtrGray = (pushCC_pushPtrPlus >>> 1'b1);
  assign _zz_ram_port = pushCC_pushPtr[3:0];
  assign _zz_popCC_popPtrGray = (popCC_popPtr >>> 1'b1);
  assign _zz_ram_port_1 = {io_push_payload_last,{io_push_payload_sink,{io_push_payload_mask,io_push_payload_data}}};
  always @(posedge dat0_i_clk) begin
    if(_zz_1) begin
      ram[_zz_ram_port] <= _zz_ram_port_1;
    end
  end

  always @(posedge clk) begin
    if(popCC_readPort_cmd_valid) begin
      ram_spinal_port1 <= ram[popCC_readPort_cmd_payload];
    end
  end

  (* keep_hierarchy = "TRUE" *) EfxDMA_BufferCC_2 popToPushGray_buffercc (
    .io_dataIn    (popToPushGray[4:0]                    ), //i
    .io_dataOut   (popToPushGray_buffercc_io_dataOut[4:0]), //o
    .dat0_i_clk   (dat0_i_clk                            ), //i
    .dat0_i_reset (dat0_i_reset                          )  //i
  );
  (* keep_hierarchy = "TRUE" *) EfxDMA_BufferCC_3 pushToPopGray_buffercc (
    .io_dataIn  (pushToPopGray[4:0]                    ), //i
    .io_dataOut (pushToPopGray_buffercc_io_dataOut[4:0]), //o
    .clk        (clk                                   ), //i
    .reset      (reset                                 )  //i
  );
  always @(*) begin
    _zz_1 = 1'b0;
    if(io_push_fire) begin
      _zz_1 = 1'b1;
    end
  end

  assign pushCC_pushPtrPlus = (pushCC_pushPtr + 5'h01);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign pushCC_popPtrGray = popToPushGray_buffercc_io_dataOut;
  assign pushCC_full = ((pushCC_pushPtrGray[4 : 3] == (~ pushCC_popPtrGray[4 : 3])) && (pushCC_pushPtrGray[2 : 0] == pushCC_popPtrGray[2 : 0]));
  assign io_push_ready = (! pushCC_full);
  assign _zz_io_pushOccupancy = (pushCC_popPtrGray[1] ^ _zz_io_pushOccupancy_1);
  assign _zz_io_pushOccupancy_1 = (pushCC_popPtrGray[2] ^ _zz_io_pushOccupancy_2);
  assign _zz_io_pushOccupancy_2 = (pushCC_popPtrGray[3] ^ _zz_io_pushOccupancy_3);
  assign _zz_io_pushOccupancy_3 = pushCC_popPtrGray[4];
  assign io_pushOccupancy = (pushCC_pushPtr - {_zz_io_pushOccupancy_3,{_zz_io_pushOccupancy_2,{_zz_io_pushOccupancy_1,{_zz_io_pushOccupancy,(pushCC_popPtrGray[0] ^ _zz_io_pushOccupancy)}}}});
  assign popCC_popPtrPlus = (popCC_popPtr + 5'h01);
  assign popCC_popPtrGray = (_zz_popCC_popPtrGray ^ popCC_popPtr);
  assign popCC_pushPtrGray = pushToPopGray_buffercc_io_dataOut;
  assign popCC_empty = (popCC_popPtrGray == popCC_pushPtrGray);
  assign popCC_addressGen_valid = (! popCC_empty);
  assign popCC_addressGen_payload = popCC_popPtr[3:0];
  assign popCC_addressGen_fire = (popCC_addressGen_valid && popCC_addressGen_ready);
  always @(*) begin
    popCC_addressGen_ready = popCC_readArbitation_ready;
    if(when_Stream_l375) begin
      popCC_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l375 = (! popCC_readArbitation_valid);
  assign popCC_readArbitation_valid = popCC_addressGen_rValid;
  assign popCC_readArbitation_payload = popCC_addressGen_rData;
  assign _zz_popCC_readPort_rsp_data = ram_spinal_port1;
  assign popCC_readPort_rsp_data = _zz_popCC_readPort_rsp_data[31 : 0];
  assign popCC_readPort_rsp_mask = _zz_popCC_readPort_rsp_data[35 : 32];
  assign popCC_readPort_rsp_sink = _zz_popCC_readPort_rsp_data[39 : 36];
  assign popCC_readPort_rsp_last = _zz_popCC_readPort_rsp_data[40];
  assign popCC_readPort_cmd_valid = popCC_addressGen_fire;
  assign popCC_readPort_cmd_payload = popCC_addressGen_payload;
  assign popCC_readArbitation_translated_valid = popCC_readArbitation_valid;
  assign popCC_readArbitation_ready = popCC_readArbitation_translated_ready;
  assign popCC_readArbitation_translated_payload_data = popCC_readPort_rsp_data;
  assign popCC_readArbitation_translated_payload_mask = popCC_readPort_rsp_mask;
  assign popCC_readArbitation_translated_payload_sink = popCC_readPort_rsp_sink;
  assign popCC_readArbitation_translated_payload_last = popCC_readPort_rsp_last;
  assign io_pop_valid = popCC_readArbitation_translated_valid;
  assign popCC_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_data = popCC_readArbitation_translated_payload_data;
  assign io_pop_payload_mask = popCC_readArbitation_translated_payload_mask;
  assign io_pop_payload_sink = popCC_readArbitation_translated_payload_sink;
  assign io_pop_payload_last = popCC_readArbitation_translated_payload_last;
  assign popCC_readArbitation_fire = (popCC_readArbitation_valid && popCC_readArbitation_ready);
  assign _zz_io_popOccupancy = (popCC_pushPtrGray[1] ^ _zz_io_popOccupancy_1);
  assign _zz_io_popOccupancy_1 = (popCC_pushPtrGray[2] ^ _zz_io_popOccupancy_2);
  assign _zz_io_popOccupancy_2 = (popCC_pushPtrGray[3] ^ _zz_io_popOccupancy_3);
  assign _zz_io_popOccupancy_3 = popCC_pushPtrGray[4];
  assign io_popOccupancy = ({_zz_io_popOccupancy_3,{_zz_io_popOccupancy_2,{_zz_io_popOccupancy_1,{_zz_io_popOccupancy,(popCC_pushPtrGray[0] ^ _zz_io_popOccupancy)}}}} - popCC_ptrToOccupancy);
  assign pushToPopGray = pushCC_pushPtrGray;
  assign popToPushGray = popCC_ptrToPush;
  always @(posedge dat0_i_clk) begin
    if(dat0_i_reset) begin
      pushCC_pushPtr <= 5'h0;
      pushCC_pushPtrGray <= 5'h0;
    end else begin
      if(io_push_fire) begin
        pushCC_pushPtrGray <= (_zz_pushCC_pushPtrGray ^ pushCC_pushPtrPlus);
      end
      if(io_push_fire) begin
        pushCC_pushPtr <= pushCC_pushPtrPlus;
      end
    end
  end

  always @(posedge clk) begin
    if(reset) begin
      popCC_popPtr <= 5'h0;
      popCC_addressGen_rValid <= 1'b0;
      popCC_ptrToPush <= 5'h0;
      popCC_ptrToOccupancy <= 5'h0;
    end else begin
      if(popCC_addressGen_fire) begin
        popCC_popPtr <= popCC_popPtrPlus;
      end
      if(popCC_addressGen_ready) begin
        popCC_addressGen_rValid <= popCC_addressGen_valid;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToPush <= popCC_popPtrGray;
      end
      if(popCC_readArbitation_fire) begin
        popCC_ptrToOccupancy <= popCC_popPtr;
      end
    end
  end

  always @(posedge clk) begin
    if(popCC_addressGen_ready) begin
      popCC_addressGen_rData <= popCC_addressGen_payload;
    end
  end


endmodule

module EfxDMA_BsbUpSizerDense (
  input  wire          io_input_valid,
  output wire          io_input_ready,
  input  wire [7:0]    io_input_payload_data,
  input  wire [0:0]    io_input_payload_mask,
  input  wire [3:0]    io_input_payload_sink,
  input  wire          io_input_payload_last,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire [31:0]   io_output_payload_data,
  output wire [3:0]    io_output_payload_mask,
  output wire [3:0]    io_output_payload_sink,
  output wire          io_output_payload_last,
  input  wire          dat0_i_clk,
  input  wire          dat0_i_reset
);

  reg                 valid;
  reg        [1:0]    counter;
  reg        [31:0]   buffer_data;
  reg        [3:0]    buffer_mask;
  reg        [3:0]    buffer_sink;
  reg                 buffer_last;
  wire                full;
  wire                canAggregate;
  wire                onOutput;
  wire       [1:0]    counterSample;
  wire                io_output_fire;
  wire                io_input_fire;
  wire       [3:0]    _zz_1;
  wire       [3:0]    _zz_2;

  assign full = ((counter == 2'b00) || buffer_last);
  assign canAggregate = ((((valid && (! buffer_last)) && (! full)) && 1'b1) && (buffer_sink == io_input_payload_sink));
  assign counterSample = (canAggregate ? counter : 2'b00);
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign io_input_fire = (io_input_valid && io_input_ready);
  assign _zz_1 = ({3'd0,1'b1} <<< counterSample);
  assign _zz_2 = ({3'd0,1'b1} <<< counterSample);
  assign io_output_valid = (valid && ((valid && full) || (io_input_valid && (! canAggregate))));
  assign io_output_payload_data = buffer_data;
  assign io_output_payload_mask = buffer_mask;
  assign io_output_payload_sink = buffer_sink;
  assign io_output_payload_last = buffer_last;
  assign io_input_ready = (((! valid) || canAggregate) || io_output_ready);
  always @(posedge dat0_i_clk) begin
    if(dat0_i_reset) begin
      valid <= 1'b0;
      counter <= 2'b00;
      buffer_last <= 1'b0;
      buffer_mask <= 4'b0000;
    end else begin
      if(io_output_fire) begin
        valid <= 1'b0;
        buffer_mask <= 4'b0000;
      end
      if(io_input_fire) begin
        valid <= 1'b1;
        if(_zz_2[0]) begin
          buffer_mask[0 : 0] <= io_input_payload_mask;
        end
        if(_zz_2[1]) begin
          buffer_mask[1 : 1] <= io_input_payload_mask;
        end
        if(_zz_2[2]) begin
          buffer_mask[2 : 2] <= io_input_payload_mask;
        end
        if(_zz_2[3]) begin
          buffer_mask[3 : 3] <= io_input_payload_mask;
        end
        buffer_last <= io_input_payload_last;
        counter <= (counterSample + 2'b01);
      end
    end
  end

  always @(posedge dat0_i_clk) begin
    if(io_input_fire) begin
      buffer_sink <= io_input_payload_sink;
      if(_zz_1[0]) begin
        buffer_data[7 : 0] <= io_input_payload_data;
      end
      if(_zz_1[1]) begin
        buffer_data[15 : 8] <= io_input_payload_data;
      end
      if(_zz_1[2]) begin
        buffer_data[23 : 16] <= io_input_payload_data;
      end
      if(_zz_1[3]) begin
        buffer_data[31 : 24] <= io_input_payload_data;
      end
    end
  end


endmodule

module EfxDMA_BmbToAxi4WriteOnlyBridge (
  input  wire          io_input_cmd_valid,
  output wire          io_input_cmd_ready,
  input  wire          io_input_cmd_payload_last,
  input  wire [0:0]    io_input_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_input_cmd_payload_fragment_address,
  input  wire [10:0]   io_input_cmd_payload_fragment_length,
  input  wire [127:0]  io_input_cmd_payload_fragment_data,
  input  wire [15:0]   io_input_cmd_payload_fragment_mask,
  input  wire [12:0]   io_input_cmd_payload_fragment_context,
  output wire          io_input_rsp_valid,
  input  wire          io_input_rsp_ready,
  output wire          io_input_rsp_payload_last,
  output wire [0:0]    io_input_rsp_payload_fragment_opcode,
  output wire [12:0]   io_input_rsp_payload_fragment_context,
  output wire          io_output_aw_valid,
  input  wire          io_output_aw_ready,
  output wire [31:0]   io_output_aw_payload_addr,
  output wire [7:0]    io_output_aw_payload_len,
  output wire [2:0]    io_output_aw_payload_size,
  output wire [3:0]    io_output_aw_payload_cache,
  output wire [2:0]    io_output_aw_payload_prot,
  output wire          io_output_w_valid,
  input  wire          io_output_w_ready,
  output wire [127:0]  io_output_w_payload_data,
  output wire [15:0]   io_output_w_payload_strb,
  output wire          io_output_w_payload_last,
  input  wire          io_output_b_valid,
  output wire          io_output_b_ready,
  input  wire [1:0]    io_output_b_payload_resp,
  input  wire          clk,
  input  wire          reset
);

  reg                 contextRemover_io_output_cmd_ready;
  reg        [0:0]    contextRemover_io_output_rsp_payload_fragment_opcode;
  wire                contextRemover_io_input_cmd_ready;
  wire                contextRemover_io_input_rsp_valid;
  wire                contextRemover_io_input_rsp_payload_last;
  wire       [0:0]    contextRemover_io_input_rsp_payload_fragment_opcode;
  wire       [12:0]   contextRemover_io_input_rsp_payload_fragment_context;
  wire                contextRemover_io_output_cmd_valid;
  wire                contextRemover_io_output_cmd_payload_last;
  wire       [0:0]    contextRemover_io_output_cmd_payload_fragment_opcode;
  wire       [31:0]   contextRemover_io_output_cmd_payload_fragment_address;
  wire       [10:0]   contextRemover_io_output_cmd_payload_fragment_length;
  wire       [127:0]  contextRemover_io_output_cmd_payload_fragment_data;
  wire       [15:0]   contextRemover_io_output_cmd_payload_fragment_mask;
  wire                contextRemover_io_output_rsp_ready;
  wire       [11:0]   _zz_io_output_aw_payload_len;
  wire       [11:0]   _zz_io_output_aw_payload_len_1;
  wire       [3:0]    _zz_io_output_aw_payload_len_2;
  wire                cmdFork_valid;
  reg                 cmdFork_ready;
  wire                cmdFork_payload_last;
  wire       [0:0]    cmdFork_payload_fragment_opcode;
  wire       [31:0]   cmdFork_payload_fragment_address;
  wire       [10:0]   cmdFork_payload_fragment_length;
  wire       [127:0]  cmdFork_payload_fragment_data;
  wire       [15:0]   cmdFork_payload_fragment_mask;
  wire                dataFork_valid;
  wire                dataFork_ready;
  wire                dataFork_payload_last;
  wire       [0:0]    dataFork_payload_fragment_opcode;
  wire       [31:0]   dataFork_payload_fragment_address;
  wire       [10:0]   dataFork_payload_fragment_length;
  wire       [127:0]  dataFork_payload_fragment_data;
  wire       [15:0]   dataFork_payload_fragment_mask;
  reg                 contextRemover_io_output_cmd_fork2_logic_linkEnable_0;
  reg                 contextRemover_io_output_cmd_fork2_logic_linkEnable_1;
  wire                when_Stream_l1063;
  wire                when_Stream_l1063_1;
  wire                cmdFork_fire;
  wire                dataFork_fire;
  wire                contextRemover_io_output_cmd_fire;
  reg                 contextRemover_io_output_cmd_payload_first;
  wire                when_Stream_l445;
  reg                 cmdStage_valid;
  wire                cmdStage_ready;
  wire                cmdStage_payload_last;
  wire       [0:0]    cmdStage_payload_fragment_opcode;
  wire       [31:0]   cmdStage_payload_fragment_address;
  wire       [10:0]   cmdStage_payload_fragment_length;
  wire       [127:0]  cmdStage_payload_fragment_data;
  wire       [15:0]   cmdStage_payload_fragment_mask;
  wire                when_BmbToAxi4Bridge_l297;

  assign _zz_io_output_aw_payload_len = ({1'b0,cmdStage_payload_fragment_length} + _zz_io_output_aw_payload_len_1);
  assign _zz_io_output_aw_payload_len_2 = cmdStage_payload_fragment_address[3 : 0];
  assign _zz_io_output_aw_payload_len_1 = {8'd0, _zz_io_output_aw_payload_len_2};
  EfxDMA_BmbContextRemover_1 contextRemover (
    .io_input_cmd_valid                     (io_input_cmd_valid                                         ), //i
    .io_input_cmd_ready                     (contextRemover_io_input_cmd_ready                          ), //o
    .io_input_cmd_payload_last              (io_input_cmd_payload_last                                  ), //i
    .io_input_cmd_payload_fragment_opcode   (io_input_cmd_payload_fragment_opcode                       ), //i
    .io_input_cmd_payload_fragment_address  (io_input_cmd_payload_fragment_address[31:0]                ), //i
    .io_input_cmd_payload_fragment_length   (io_input_cmd_payload_fragment_length[10:0]                 ), //i
    .io_input_cmd_payload_fragment_data     (io_input_cmd_payload_fragment_data[127:0]                  ), //i
    .io_input_cmd_payload_fragment_mask     (io_input_cmd_payload_fragment_mask[15:0]                   ), //i
    .io_input_cmd_payload_fragment_context  (io_input_cmd_payload_fragment_context[12:0]                ), //i
    .io_input_rsp_valid                     (contextRemover_io_input_rsp_valid                          ), //o
    .io_input_rsp_ready                     (io_input_rsp_ready                                         ), //i
    .io_input_rsp_payload_last              (contextRemover_io_input_rsp_payload_last                   ), //o
    .io_input_rsp_payload_fragment_opcode   (contextRemover_io_input_rsp_payload_fragment_opcode        ), //o
    .io_input_rsp_payload_fragment_context  (contextRemover_io_input_rsp_payload_fragment_context[12:0] ), //o
    .io_output_cmd_valid                    (contextRemover_io_output_cmd_valid                         ), //o
    .io_output_cmd_ready                    (contextRemover_io_output_cmd_ready                         ), //i
    .io_output_cmd_payload_last             (contextRemover_io_output_cmd_payload_last                  ), //o
    .io_output_cmd_payload_fragment_opcode  (contextRemover_io_output_cmd_payload_fragment_opcode       ), //o
    .io_output_cmd_payload_fragment_address (contextRemover_io_output_cmd_payload_fragment_address[31:0]), //o
    .io_output_cmd_payload_fragment_length  (contextRemover_io_output_cmd_payload_fragment_length[10:0] ), //o
    .io_output_cmd_payload_fragment_data    (contextRemover_io_output_cmd_payload_fragment_data[127:0]  ), //o
    .io_output_cmd_payload_fragment_mask    (contextRemover_io_output_cmd_payload_fragment_mask[15:0]   ), //o
    .io_output_rsp_valid                    (io_output_b_valid                                          ), //i
    .io_output_rsp_ready                    (contextRemover_io_output_rsp_ready                         ), //o
    .io_output_rsp_payload_last             (1'b1                                                       ), //i
    .io_output_rsp_payload_fragment_opcode  (contextRemover_io_output_rsp_payload_fragment_opcode       ), //i
    .clk                                    (clk                                                        ), //i
    .reset                                  (reset                                                      )  //i
  );
  assign io_input_cmd_ready = contextRemover_io_input_cmd_ready;
  assign io_input_rsp_valid = contextRemover_io_input_rsp_valid;
  assign io_input_rsp_payload_last = contextRemover_io_input_rsp_payload_last;
  assign io_input_rsp_payload_fragment_opcode = contextRemover_io_input_rsp_payload_fragment_opcode;
  assign io_input_rsp_payload_fragment_context = contextRemover_io_input_rsp_payload_fragment_context;
  always @(*) begin
    contextRemover_io_output_cmd_ready = 1'b1;
    if(when_Stream_l1063) begin
      contextRemover_io_output_cmd_ready = 1'b0;
    end
    if(when_Stream_l1063_1) begin
      contextRemover_io_output_cmd_ready = 1'b0;
    end
  end

  assign when_Stream_l1063 = ((! cmdFork_ready) && contextRemover_io_output_cmd_fork2_logic_linkEnable_0);
  assign when_Stream_l1063_1 = ((! dataFork_ready) && contextRemover_io_output_cmd_fork2_logic_linkEnable_1);
  assign cmdFork_valid = (contextRemover_io_output_cmd_valid && contextRemover_io_output_cmd_fork2_logic_linkEnable_0);
  assign cmdFork_payload_last = contextRemover_io_output_cmd_payload_last;
  assign cmdFork_payload_fragment_opcode = contextRemover_io_output_cmd_payload_fragment_opcode;
  assign cmdFork_payload_fragment_address = contextRemover_io_output_cmd_payload_fragment_address;
  assign cmdFork_payload_fragment_length = contextRemover_io_output_cmd_payload_fragment_length;
  assign cmdFork_payload_fragment_data = contextRemover_io_output_cmd_payload_fragment_data;
  assign cmdFork_payload_fragment_mask = contextRemover_io_output_cmd_payload_fragment_mask;
  assign cmdFork_fire = (cmdFork_valid && cmdFork_ready);
  assign dataFork_valid = (contextRemover_io_output_cmd_valid && contextRemover_io_output_cmd_fork2_logic_linkEnable_1);
  assign dataFork_payload_last = contextRemover_io_output_cmd_payload_last;
  assign dataFork_payload_fragment_opcode = contextRemover_io_output_cmd_payload_fragment_opcode;
  assign dataFork_payload_fragment_address = contextRemover_io_output_cmd_payload_fragment_address;
  assign dataFork_payload_fragment_length = contextRemover_io_output_cmd_payload_fragment_length;
  assign dataFork_payload_fragment_data = contextRemover_io_output_cmd_payload_fragment_data;
  assign dataFork_payload_fragment_mask = contextRemover_io_output_cmd_payload_fragment_mask;
  assign dataFork_fire = (dataFork_valid && dataFork_ready);
  assign contextRemover_io_output_cmd_fire = (contextRemover_io_output_cmd_valid && contextRemover_io_output_cmd_ready);
  assign when_Stream_l445 = (! contextRemover_io_output_cmd_payload_first);
  always @(*) begin
    cmdStage_valid = cmdFork_valid;
    if(when_Stream_l445) begin
      cmdStage_valid = 1'b0;
    end
  end

  always @(*) begin
    cmdFork_ready = cmdStage_ready;
    if(when_Stream_l445) begin
      cmdFork_ready = 1'b1;
    end
  end

  assign cmdStage_payload_last = cmdFork_payload_last;
  assign cmdStage_payload_fragment_opcode = cmdFork_payload_fragment_opcode;
  assign cmdStage_payload_fragment_address = cmdFork_payload_fragment_address;
  assign cmdStage_payload_fragment_length = cmdFork_payload_fragment_length;
  assign cmdStage_payload_fragment_data = cmdFork_payload_fragment_data;
  assign cmdStage_payload_fragment_mask = cmdFork_payload_fragment_mask;
  assign io_output_aw_valid = cmdStage_valid;
  assign cmdStage_ready = io_output_aw_ready;
  assign io_output_aw_payload_addr = cmdStage_payload_fragment_address;
  assign io_output_aw_payload_len = _zz_io_output_aw_payload_len[11 : 4];
  assign io_output_aw_payload_size = 3'b100;
  assign io_output_aw_payload_prot = 3'b010;
  assign io_output_aw_payload_cache = 4'b1111;
  assign io_output_w_valid = dataFork_valid;
  assign dataFork_ready = io_output_w_ready;
  assign io_output_w_payload_data = dataFork_payload_fragment_data;
  assign io_output_w_payload_strb = dataFork_payload_fragment_mask;
  assign io_output_w_payload_last = dataFork_payload_last;
  assign io_output_b_ready = contextRemover_io_output_rsp_ready;
  assign when_BmbToAxi4Bridge_l297 = (io_output_b_payload_resp == 2'b00);
  always @(*) begin
    if(when_BmbToAxi4Bridge_l297) begin
      contextRemover_io_output_rsp_payload_fragment_opcode = 1'b0;
    end else begin
      contextRemover_io_output_rsp_payload_fragment_opcode = 1'b1;
    end
  end

  always @(posedge clk) begin
    if(reset) begin
      contextRemover_io_output_cmd_fork2_logic_linkEnable_0 <= 1'b1;
      contextRemover_io_output_cmd_fork2_logic_linkEnable_1 <= 1'b1;
      contextRemover_io_output_cmd_payload_first <= 1'b1;
    end else begin
      if(cmdFork_fire) begin
        contextRemover_io_output_cmd_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(dataFork_fire) begin
        contextRemover_io_output_cmd_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(contextRemover_io_output_cmd_ready) begin
        contextRemover_io_output_cmd_fork2_logic_linkEnable_0 <= 1'b1;
        contextRemover_io_output_cmd_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(contextRemover_io_output_cmd_fire) begin
        contextRemover_io_output_cmd_payload_first <= contextRemover_io_output_cmd_payload_last;
      end
    end
  end


endmodule

module EfxDMA_BmbSourceRemover_1 (
  input  wire          io_input_cmd_valid,
  output wire          io_input_cmd_ready,
  input  wire          io_input_cmd_payload_last,
  input  wire [0:0]    io_input_cmd_payload_fragment_source,
  input  wire [0:0]    io_input_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_input_cmd_payload_fragment_address,
  input  wire [10:0]   io_input_cmd_payload_fragment_length,
  input  wire [127:0]  io_input_cmd_payload_fragment_data,
  input  wire [15:0]   io_input_cmd_payload_fragment_mask,
  input  wire [11:0]   io_input_cmd_payload_fragment_context,
  output wire          io_input_rsp_valid,
  input  wire          io_input_rsp_ready,
  output wire          io_input_rsp_payload_last,
  output wire [0:0]    io_input_rsp_payload_fragment_source,
  output wire [0:0]    io_input_rsp_payload_fragment_opcode,
  output wire [11:0]   io_input_rsp_payload_fragment_context,
  output wire          io_output_cmd_valid,
  input  wire          io_output_cmd_ready,
  output wire          io_output_cmd_payload_last,
  output wire [0:0]    io_output_cmd_payload_fragment_opcode,
  output wire [31:0]   io_output_cmd_payload_fragment_address,
  output wire [10:0]   io_output_cmd_payload_fragment_length,
  output wire [127:0]  io_output_cmd_payload_fragment_data,
  output wire [15:0]   io_output_cmd_payload_fragment_mask,
  output wire [12:0]   io_output_cmd_payload_fragment_context,
  input  wire          io_output_rsp_valid,
  output wire          io_output_rsp_ready,
  input  wire          io_output_rsp_payload_last,
  input  wire [0:0]    io_output_rsp_payload_fragment_opcode,
  input  wire [12:0]   io_output_rsp_payload_fragment_context
);

  wire       [0:0]    cmdContext_source;
  wire       [11:0]   cmdContext_context;
  wire       [0:0]    rspContext_source;
  wire       [11:0]   rspContext_context;
  wire       [12:0]   _zz_rspContext_source;

  assign cmdContext_source = io_input_cmd_payload_fragment_source;
  assign cmdContext_context = io_input_cmd_payload_fragment_context;
  assign io_output_cmd_valid = io_input_cmd_valid;
  assign io_input_cmd_ready = io_output_cmd_ready;
  assign io_output_cmd_payload_last = io_input_cmd_payload_last;
  assign io_output_cmd_payload_fragment_opcode = io_input_cmd_payload_fragment_opcode;
  assign io_output_cmd_payload_fragment_address = io_input_cmd_payload_fragment_address;
  assign io_output_cmd_payload_fragment_length = io_input_cmd_payload_fragment_length;
  assign io_output_cmd_payload_fragment_data = io_input_cmd_payload_fragment_data;
  assign io_output_cmd_payload_fragment_mask = io_input_cmd_payload_fragment_mask;
  assign io_output_cmd_payload_fragment_context = {cmdContext_context,cmdContext_source};
  assign _zz_rspContext_source = io_output_rsp_payload_fragment_context;
  assign rspContext_source = _zz_rspContext_source[0 : 0];
  assign rspContext_context = _zz_rspContext_source[12 : 1];
  assign io_input_rsp_valid = io_output_rsp_valid;
  assign io_output_rsp_ready = io_input_rsp_ready;
  assign io_input_rsp_payload_last = io_output_rsp_payload_last;
  assign io_input_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_input_rsp_payload_fragment_source = rspContext_source;
  assign io_input_rsp_payload_fragment_context = rspContext_context;

endmodule

module EfxDMA_BmbUpSizerBridge_1 (
  input  wire          io_input_cmd_valid,
  output wire          io_input_cmd_ready,
  input  wire          io_input_cmd_payload_last,
  input  wire [0:0]    io_input_cmd_payload_fragment_source,
  input  wire [0:0]    io_input_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_input_cmd_payload_fragment_address,
  input  wire [10:0]   io_input_cmd_payload_fragment_length,
  input  wire [63:0]   io_input_cmd_payload_fragment_data,
  input  wire [7:0]    io_input_cmd_payload_fragment_mask,
  input  wire [11:0]   io_input_cmd_payload_fragment_context,
  output wire          io_input_rsp_valid,
  input  wire          io_input_rsp_ready,
  output wire          io_input_rsp_payload_last,
  output wire [0:0]    io_input_rsp_payload_fragment_source,
  output wire [0:0]    io_input_rsp_payload_fragment_opcode,
  output wire [11:0]   io_input_rsp_payload_fragment_context,
  output wire          io_output_cmd_valid,
  input  wire          io_output_cmd_ready,
  output wire          io_output_cmd_payload_last,
  output wire [0:0]    io_output_cmd_payload_fragment_source,
  output wire [0:0]    io_output_cmd_payload_fragment_opcode,
  output wire [31:0]   io_output_cmd_payload_fragment_address,
  output wire [10:0]   io_output_cmd_payload_fragment_length,
  output reg  [127:0]  io_output_cmd_payload_fragment_data,
  output reg  [15:0]   io_output_cmd_payload_fragment_mask,
  output wire [11:0]   io_output_cmd_payload_fragment_context,
  input  wire          io_output_rsp_valid,
  output wire          io_output_rsp_ready,
  input  wire          io_output_rsp_payload_last,
  input  wire [0:0]    io_output_rsp_payload_fragment_source,
  input  wire [0:0]    io_output_rsp_payload_fragment_opcode,
  input  wire [11:0]   io_output_rsp_payload_fragment_context,
  input  wire          clk,
  input  wire          reset
);

  wire       [0:0]    cmdArea_selStart;
  wire       [11:0]   cmdArea_context_context;
  reg        [63:0]   cmdArea_writeLogic_dataRegs_0;
  reg        [7:0]    cmdArea_writeLogic_maskRegs_0;
  reg        [0:0]    cmdArea_writeLogic_selReg;
  wire                io_input_cmd_fire;
  reg                 io_input_cmd_payload_first;
  wire       [0:0]    cmdArea_writeLogic_sel;
  wire       [63:0]   cmdArea_writeLogic_outputData_0;
  wire       [63:0]   cmdArea_writeLogic_outputData_1;
  wire       [7:0]    cmdArea_writeLogic_outputMask_0;
  wire       [7:0]    cmdArea_writeLogic_outputMask_1;
  wire                when_BmbUpSizerBridge_l85;
  wire                when_BmbUpSizerBridge_l95;
  wire                io_output_cmd_fire;
  wire                io_output_cmd_isStall;
  wire       [11:0]   rspArea_context_context;

  assign cmdArea_selStart = io_input_cmd_payload_fragment_address[3 : 3];
  assign cmdArea_context_context = io_input_cmd_payload_fragment_context;
  assign io_output_cmd_payload_last = io_input_cmd_payload_last;
  assign io_output_cmd_payload_fragment_opcode = io_input_cmd_payload_fragment_opcode;
  assign io_output_cmd_payload_fragment_address = io_input_cmd_payload_fragment_address;
  assign io_output_cmd_payload_fragment_length = io_input_cmd_payload_fragment_length;
  assign io_output_cmd_payload_fragment_source = io_input_cmd_payload_fragment_source;
  assign io_output_cmd_payload_fragment_context = cmdArea_context_context;
  assign io_input_cmd_fire = (io_input_cmd_valid && io_input_cmd_ready);
  assign cmdArea_writeLogic_sel = (io_input_cmd_payload_first ? cmdArea_selStart : cmdArea_writeLogic_selReg);
  assign cmdArea_writeLogic_outputData_0 = io_output_cmd_payload_fragment_data[63 : 0];
  assign cmdArea_writeLogic_outputData_1 = io_output_cmd_payload_fragment_data[127 : 64];
  assign cmdArea_writeLogic_outputMask_0 = io_output_cmd_payload_fragment_mask[7 : 0];
  assign cmdArea_writeLogic_outputMask_1 = io_output_cmd_payload_fragment_mask[15 : 8];
  always @(*) begin
    io_output_cmd_payload_fragment_data[63 : 0] = io_input_cmd_payload_fragment_data;
    if(when_BmbUpSizerBridge_l85) begin
      io_output_cmd_payload_fragment_data[63 : 0] = cmdArea_writeLogic_dataRegs_0;
    end
    io_output_cmd_payload_fragment_data[127 : 64] = io_input_cmd_payload_fragment_data;
  end

  assign when_BmbUpSizerBridge_l85 = ((! io_input_cmd_payload_first) && (cmdArea_writeLogic_selReg != 1'b0));
  always @(*) begin
    io_output_cmd_payload_fragment_mask[7 : 0] = ((cmdArea_writeLogic_sel == 1'b0) ? io_input_cmd_payload_fragment_mask : cmdArea_writeLogic_maskRegs_0);
    io_output_cmd_payload_fragment_mask[15 : 8] = ((cmdArea_writeLogic_sel == 1'b1) ? io_input_cmd_payload_fragment_mask : 8'h0);
  end

  assign when_BmbUpSizerBridge_l95 = (io_input_cmd_valid && (cmdArea_writeLogic_sel == 1'b0));
  assign io_output_cmd_fire = (io_output_cmd_valid && io_output_cmd_ready);
  assign io_output_cmd_valid = (io_input_cmd_valid && ((cmdArea_writeLogic_sel == 1'b1) || io_input_cmd_payload_last));
  assign io_output_cmd_isStall = (io_output_cmd_valid && (! io_output_cmd_ready));
  assign io_input_cmd_ready = (! io_output_cmd_isStall);
  assign rspArea_context_context = io_output_rsp_payload_fragment_context[11 : 0];
  assign io_input_rsp_valid = io_output_rsp_valid;
  assign io_input_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_input_rsp_payload_fragment_source = io_output_rsp_payload_fragment_source;
  assign io_input_rsp_payload_fragment_context = rspArea_context_context;
  assign io_input_rsp_payload_last = io_output_rsp_payload_last;
  assign io_output_rsp_ready = io_input_rsp_ready;
  always @(posedge clk) begin
    if(reset) begin
      cmdArea_writeLogic_maskRegs_0 <= 8'h0;
      io_input_cmd_payload_first <= 1'b1;
    end else begin
      if(io_input_cmd_fire) begin
        io_input_cmd_payload_first <= io_input_cmd_payload_last;
      end
      if(when_BmbUpSizerBridge_l95) begin
        cmdArea_writeLogic_maskRegs_0 <= io_input_cmd_payload_fragment_mask;
      end
      if(io_output_cmd_fire) begin
        cmdArea_writeLogic_maskRegs_0 <= 8'h0;
      end
    end
  end

  always @(posedge clk) begin
    if(io_input_cmd_fire) begin
      cmdArea_writeLogic_selReg <= (cmdArea_writeLogic_sel + 1'b1);
    end
    if(!when_BmbUpSizerBridge_l85) begin
      cmdArea_writeLogic_dataRegs_0 <= io_input_cmd_payload_fragment_data;
    end
  end


endmodule

module EfxDMA_BmbToAxi4ReadOnlyBridge (
  input  wire          io_input_cmd_valid,
  output wire          io_input_cmd_ready,
  input  wire          io_input_cmd_payload_last,
  input  wire [0:0]    io_input_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_input_cmd_payload_fragment_address,
  input  wire [10:0]   io_input_cmd_payload_fragment_length,
  input  wire [20:0]   io_input_cmd_payload_fragment_context,
  output wire          io_input_rsp_valid,
  input  wire          io_input_rsp_ready,
  output wire          io_input_rsp_payload_last,
  output wire [0:0]    io_input_rsp_payload_fragment_opcode,
  output wire [127:0]  io_input_rsp_payload_fragment_data,
  output wire [20:0]   io_input_rsp_payload_fragment_context,
  output wire          io_output_ar_valid,
  input  wire          io_output_ar_ready,
  output wire [31:0]   io_output_ar_payload_addr,
  output wire [7:0]    io_output_ar_payload_len,
  output wire [2:0]    io_output_ar_payload_size,
  output wire [3:0]    io_output_ar_payload_cache,
  output wire [2:0]    io_output_ar_payload_prot,
  input  wire          io_output_r_valid,
  output wire          io_output_r_ready,
  input  wire [127:0]  io_output_r_payload_data,
  input  wire [1:0]    io_output_r_payload_resp,
  input  wire          io_output_r_payload_last,
  input  wire          clk,
  input  wire          reset
);

  reg        [0:0]    contextRemover_io_output_rsp_payload_fragment_opcode;
  wire                contextRemover_io_input_cmd_ready;
  wire                contextRemover_io_input_rsp_valid;
  wire                contextRemover_io_input_rsp_payload_last;
  wire       [0:0]    contextRemover_io_input_rsp_payload_fragment_opcode;
  wire       [127:0]  contextRemover_io_input_rsp_payload_fragment_data;
  wire       [20:0]   contextRemover_io_input_rsp_payload_fragment_context;
  wire                contextRemover_io_output_cmd_valid;
  wire                contextRemover_io_output_cmd_payload_last;
  wire       [0:0]    contextRemover_io_output_cmd_payload_fragment_opcode;
  wire       [31:0]   contextRemover_io_output_cmd_payload_fragment_address;
  wire       [10:0]   contextRemover_io_output_cmd_payload_fragment_length;
  wire                contextRemover_io_output_rsp_ready;
  wire       [11:0]   _zz_io_output_ar_payload_len;
  wire       [11:0]   _zz_io_output_ar_payload_len_1;
  wire       [3:0]    _zz_io_output_ar_payload_len_2;
  wire                when_BmbToAxi4Bridge_l243;

  assign _zz_io_output_ar_payload_len = ({1'b0,contextRemover_io_output_cmd_payload_fragment_length} + _zz_io_output_ar_payload_len_1);
  assign _zz_io_output_ar_payload_len_2 = contextRemover_io_output_cmd_payload_fragment_address[3 : 0];
  assign _zz_io_output_ar_payload_len_1 = {8'd0, _zz_io_output_ar_payload_len_2};
  EfxDMA_BmbContextRemover contextRemover (
    .io_input_cmd_valid                     (io_input_cmd_valid                                         ), //i
    .io_input_cmd_ready                     (contextRemover_io_input_cmd_ready                          ), //o
    .io_input_cmd_payload_last              (io_input_cmd_payload_last                                  ), //i
    .io_input_cmd_payload_fragment_opcode   (io_input_cmd_payload_fragment_opcode                       ), //i
    .io_input_cmd_payload_fragment_address  (io_input_cmd_payload_fragment_address[31:0]                ), //i
    .io_input_cmd_payload_fragment_length   (io_input_cmd_payload_fragment_length[10:0]                 ), //i
    .io_input_cmd_payload_fragment_context  (io_input_cmd_payload_fragment_context[20:0]                ), //i
    .io_input_rsp_valid                     (contextRemover_io_input_rsp_valid                          ), //o
    .io_input_rsp_ready                     (io_input_rsp_ready                                         ), //i
    .io_input_rsp_payload_last              (contextRemover_io_input_rsp_payload_last                   ), //o
    .io_input_rsp_payload_fragment_opcode   (contextRemover_io_input_rsp_payload_fragment_opcode        ), //o
    .io_input_rsp_payload_fragment_data     (contextRemover_io_input_rsp_payload_fragment_data[127:0]   ), //o
    .io_input_rsp_payload_fragment_context  (contextRemover_io_input_rsp_payload_fragment_context[20:0] ), //o
    .io_output_cmd_valid                    (contextRemover_io_output_cmd_valid                         ), //o
    .io_output_cmd_ready                    (io_output_ar_ready                                         ), //i
    .io_output_cmd_payload_last             (contextRemover_io_output_cmd_payload_last                  ), //o
    .io_output_cmd_payload_fragment_opcode  (contextRemover_io_output_cmd_payload_fragment_opcode       ), //o
    .io_output_cmd_payload_fragment_address (contextRemover_io_output_cmd_payload_fragment_address[31:0]), //o
    .io_output_cmd_payload_fragment_length  (contextRemover_io_output_cmd_payload_fragment_length[10:0] ), //o
    .io_output_rsp_valid                    (io_output_r_valid                                          ), //i
    .io_output_rsp_ready                    (contextRemover_io_output_rsp_ready                         ), //o
    .io_output_rsp_payload_last             (io_output_r_payload_last                                   ), //i
    .io_output_rsp_payload_fragment_opcode  (contextRemover_io_output_rsp_payload_fragment_opcode       ), //i
    .io_output_rsp_payload_fragment_data    (io_output_r_payload_data[127:0]                            ), //i
    .clk                                    (clk                                                        ), //i
    .reset                                  (reset                                                      )  //i
  );
  assign io_input_cmd_ready = contextRemover_io_input_cmd_ready;
  assign io_input_rsp_valid = contextRemover_io_input_rsp_valid;
  assign io_input_rsp_payload_last = contextRemover_io_input_rsp_payload_last;
  assign io_input_rsp_payload_fragment_opcode = contextRemover_io_input_rsp_payload_fragment_opcode;
  assign io_input_rsp_payload_fragment_data = contextRemover_io_input_rsp_payload_fragment_data;
  assign io_input_rsp_payload_fragment_context = contextRemover_io_input_rsp_payload_fragment_context;
  assign io_output_ar_valid = contextRemover_io_output_cmd_valid;
  assign io_output_ar_payload_addr = contextRemover_io_output_cmd_payload_fragment_address;
  assign io_output_ar_payload_len = _zz_io_output_ar_payload_len[11 : 4];
  assign io_output_ar_payload_size = 3'b100;
  assign io_output_ar_payload_prot = 3'b010;
  assign io_output_ar_payload_cache = 4'b1111;
  assign io_output_r_ready = contextRemover_io_output_rsp_ready;
  assign when_BmbToAxi4Bridge_l243 = (io_output_r_payload_resp == 2'b00);
  always @(*) begin
    if(when_BmbToAxi4Bridge_l243) begin
      contextRemover_io_output_rsp_payload_fragment_opcode = 1'b0;
    end else begin
      contextRemover_io_output_rsp_payload_fragment_opcode = 1'b1;
    end
  end


endmodule

module EfxDMA_BmbSourceRemover (
  input  wire          io_input_cmd_valid,
  output wire          io_input_cmd_ready,
  input  wire          io_input_cmd_payload_last,
  input  wire [0:0]    io_input_cmd_payload_fragment_source,
  input  wire [0:0]    io_input_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_input_cmd_payload_fragment_address,
  input  wire [10:0]   io_input_cmd_payload_fragment_length,
  input  wire [19:0]   io_input_cmd_payload_fragment_context,
  output wire          io_input_rsp_valid,
  input  wire          io_input_rsp_ready,
  output wire          io_input_rsp_payload_last,
  output wire [0:0]    io_input_rsp_payload_fragment_source,
  output wire [0:0]    io_input_rsp_payload_fragment_opcode,
  output wire [127:0]  io_input_rsp_payload_fragment_data,
  output wire [19:0]   io_input_rsp_payload_fragment_context,
  output wire          io_output_cmd_valid,
  input  wire          io_output_cmd_ready,
  output wire          io_output_cmd_payload_last,
  output wire [0:0]    io_output_cmd_payload_fragment_opcode,
  output wire [31:0]   io_output_cmd_payload_fragment_address,
  output wire [10:0]   io_output_cmd_payload_fragment_length,
  output wire [20:0]   io_output_cmd_payload_fragment_context,
  input  wire          io_output_rsp_valid,
  output wire          io_output_rsp_ready,
  input  wire          io_output_rsp_payload_last,
  input  wire [0:0]    io_output_rsp_payload_fragment_opcode,
  input  wire [127:0]  io_output_rsp_payload_fragment_data,
  input  wire [20:0]   io_output_rsp_payload_fragment_context
);

  wire       [0:0]    cmdContext_source;
  wire       [19:0]   cmdContext_context;
  wire       [0:0]    rspContext_source;
  wire       [19:0]   rspContext_context;
  wire       [20:0]   _zz_rspContext_source;

  assign cmdContext_source = io_input_cmd_payload_fragment_source;
  assign cmdContext_context = io_input_cmd_payload_fragment_context;
  assign io_output_cmd_valid = io_input_cmd_valid;
  assign io_input_cmd_ready = io_output_cmd_ready;
  assign io_output_cmd_payload_last = io_input_cmd_payload_last;
  assign io_output_cmd_payload_fragment_opcode = io_input_cmd_payload_fragment_opcode;
  assign io_output_cmd_payload_fragment_address = io_input_cmd_payload_fragment_address;
  assign io_output_cmd_payload_fragment_length = io_input_cmd_payload_fragment_length;
  assign io_output_cmd_payload_fragment_context = {cmdContext_context,cmdContext_source};
  assign _zz_rspContext_source = io_output_rsp_payload_fragment_context;
  assign rspContext_source = _zz_rspContext_source[0 : 0];
  assign rspContext_context = _zz_rspContext_source[20 : 1];
  assign io_input_rsp_valid = io_output_rsp_valid;
  assign io_output_rsp_ready = io_input_rsp_ready;
  assign io_input_rsp_payload_last = io_output_rsp_payload_last;
  assign io_input_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_input_rsp_payload_fragment_data = io_output_rsp_payload_fragment_data;
  assign io_input_rsp_payload_fragment_source = rspContext_source;
  assign io_input_rsp_payload_fragment_context = rspContext_context;

endmodule

module EfxDMA_BmbUpSizerBridge (
  input  wire          io_input_cmd_valid,
  output wire          io_input_cmd_ready,
  input  wire          io_input_cmd_payload_last,
  input  wire [0:0]    io_input_cmd_payload_fragment_source,
  input  wire [0:0]    io_input_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_input_cmd_payload_fragment_address,
  input  wire [10:0]   io_input_cmd_payload_fragment_length,
  input  wire [17:0]   io_input_cmd_payload_fragment_context,
  output wire          io_input_rsp_valid,
  input  wire          io_input_rsp_ready,
  output reg           io_input_rsp_payload_last,
  output wire [0:0]    io_input_rsp_payload_fragment_source,
  output wire [0:0]    io_input_rsp_payload_fragment_opcode,
  output wire [63:0]   io_input_rsp_payload_fragment_data,
  output wire [17:0]   io_input_rsp_payload_fragment_context,
  output wire          io_output_cmd_valid,
  input  wire          io_output_cmd_ready,
  output wire          io_output_cmd_payload_last,
  output wire [0:0]    io_output_cmd_payload_fragment_source,
  output wire [0:0]    io_output_cmd_payload_fragment_opcode,
  output wire [31:0]   io_output_cmd_payload_fragment_address,
  output wire [10:0]   io_output_cmd_payload_fragment_length,
  output wire [19:0]   io_output_cmd_payload_fragment_context,
  input  wire          io_output_rsp_valid,
  output wire          io_output_rsp_ready,
  input  wire          io_output_rsp_payload_last,
  input  wire [0:0]    io_output_rsp_payload_fragment_source,
  input  wire [0:0]    io_output_rsp_payload_fragment_opcode,
  input  wire [127:0]  io_output_rsp_payload_fragment_data,
  input  wire [19:0]   io_output_rsp_payload_fragment_context,
  input  wire          clk,
  input  wire          reset
);

  wire       [8:0]    _zz_cmdArea_context_selEnd;
  wire       [8:0]    _zz_cmdArea_context_selEnd_1;
  wire       [0:0]    _zz_cmdArea_context_selEnd_2;
  wire       [11:0]   _zz_cmdArea_context_selEnd_3;
  wire       [11:0]   _zz_cmdArea_context_selEnd_4;
  wire       [2:0]    _zz_cmdArea_context_selEnd_5;
  reg        [63:0]   _zz_io_input_rsp_payload_fragment_data;
  wire       [0:0]    cmdArea_selStart;
  wire       [0:0]    cmdArea_context_selStart;
  wire       [0:0]    cmdArea_context_selEnd;
  wire       [17:0]   cmdArea_context_context;
  wire       [0:0]    rspArea_context_selStart;
  wire       [0:0]    rspArea_context_selEnd;
  wire       [17:0]   rspArea_context_context;
  wire       [19:0]   _zz_rspArea_context_selStart;
  reg        [0:0]    rspArea_readLogic_selReg;
  wire                io_input_rsp_fire;
  reg                 io_input_rsp_payload_first;
  wire       [0:0]    rspArea_readLogic_sel;
  wire                when_BmbUpSizerBridge_l133;

  assign _zz_cmdArea_context_selEnd = (_zz_cmdArea_context_selEnd_1 + _zz_cmdArea_context_selEnd_3[11 : 3]);
  assign _zz_cmdArea_context_selEnd_2 = io_input_cmd_payload_fragment_address[3 : 3];
  assign _zz_cmdArea_context_selEnd_1 = {8'd0, _zz_cmdArea_context_selEnd_2};
  assign _zz_cmdArea_context_selEnd_3 = ({1'b0,io_input_cmd_payload_fragment_length} + _zz_cmdArea_context_selEnd_4);
  assign _zz_cmdArea_context_selEnd_5 = io_input_cmd_payload_fragment_address[2 : 0];
  assign _zz_cmdArea_context_selEnd_4 = {9'd0, _zz_cmdArea_context_selEnd_5};
  always @(*) begin
    case(rspArea_readLogic_sel)
      1'b0 : _zz_io_input_rsp_payload_fragment_data = io_output_rsp_payload_fragment_data[63 : 0];
      default : _zz_io_input_rsp_payload_fragment_data = io_output_rsp_payload_fragment_data[127 : 64];
    endcase
  end

  assign cmdArea_selStart = io_input_cmd_payload_fragment_address[3 : 3];
  assign cmdArea_context_context = io_input_cmd_payload_fragment_context;
  assign cmdArea_context_selStart = cmdArea_selStart;
  assign cmdArea_context_selEnd = _zz_cmdArea_context_selEnd[0:0];
  assign io_output_cmd_payload_last = io_input_cmd_payload_last;
  assign io_output_cmd_payload_fragment_opcode = io_input_cmd_payload_fragment_opcode;
  assign io_output_cmd_payload_fragment_address = io_input_cmd_payload_fragment_address;
  assign io_output_cmd_payload_fragment_length = io_input_cmd_payload_fragment_length;
  assign io_output_cmd_payload_fragment_source = io_input_cmd_payload_fragment_source;
  assign io_output_cmd_payload_fragment_context = {cmdArea_context_context,{cmdArea_context_selEnd,cmdArea_context_selStart}};
  assign io_output_cmd_valid = io_input_cmd_valid;
  assign io_input_cmd_ready = io_output_cmd_ready;
  assign _zz_rspArea_context_selStart = io_output_rsp_payload_fragment_context;
  assign rspArea_context_selStart = _zz_rspArea_context_selStart[0 : 0];
  assign rspArea_context_selEnd = _zz_rspArea_context_selStart[1 : 1];
  assign rspArea_context_context = _zz_rspArea_context_selStart[19 : 2];
  assign io_input_rsp_valid = io_output_rsp_valid;
  assign io_input_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_input_rsp_payload_fragment_source = io_output_rsp_payload_fragment_source;
  assign io_input_rsp_payload_fragment_context = rspArea_context_context;
  assign io_input_rsp_fire = (io_input_rsp_valid && io_input_rsp_ready);
  assign rspArea_readLogic_sel = (io_input_rsp_payload_first ? rspArea_context_selStart : rspArea_readLogic_selReg);
  always @(*) begin
    io_input_rsp_payload_last = (io_output_rsp_payload_last && (rspArea_readLogic_sel == rspArea_context_selEnd));
    if(when_BmbUpSizerBridge_l133) begin
      io_input_rsp_payload_last = 1'b0;
    end
  end

  assign io_output_rsp_ready = (io_input_rsp_ready && (io_input_rsp_payload_last || (rspArea_readLogic_sel == 1'b1)));
  assign when_BmbUpSizerBridge_l133 = (rspArea_context_selEnd != rspArea_readLogic_sel);
  assign io_input_rsp_payload_fragment_data = _zz_io_input_rsp_payload_fragment_data;
  always @(posedge clk) begin
    if(reset) begin
      io_input_rsp_payload_first <= 1'b1;
    end else begin
      if(io_input_rsp_fire) begin
        io_input_rsp_payload_first <= io_input_rsp_payload_last;
      end
    end
  end

  always @(posedge clk) begin
    rspArea_readLogic_selReg <= rspArea_readLogic_sel;
    if(io_input_rsp_fire) begin
      rspArea_readLogic_selReg <= (rspArea_readLogic_sel + 1'b1);
    end
  end


endmodule

module EfxDMA_BufferCC_6 (
  input  wire [1:0]    io_dataIn,
  output wire [1:0]    io_dataOut,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  (* async_reg = "true" *) reg        [1:0]    buffers_0;
  (* async_reg = "true" *) reg        [1:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end


endmodule

module EfxDMA_Apb3CC (
  input  wire [13:0]   io_input_PADDR,
  input  wire [0:0]    io_input_PSEL,
  input  wire          io_input_PENABLE,
  output wire          io_input_PREADY,
  input  wire          io_input_PWRITE,
  input  wire [31:0]   io_input_PWDATA,
  output wire [31:0]   io_input_PRDATA,
  output wire          io_input_PSLVERROR,
  output wire [13:0]   io_output_PADDR,
  output reg  [0:0]    io_output_PSEL,
  output reg           io_output_PENABLE,
  input  wire          io_output_PREADY,
  output wire          io_output_PWRITE,
  output wire [31:0]   io_output_PWDATA,
  input  wire [31:0]   io_output_PRDATA,
  input  wire          io_output_PSLVERROR,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset,
  input  wire          clk,
  input  wire          reset
);

  wire                flowCCUnsafeByToggle_io_output_valid;
  wire       [13:0]   flowCCUnsafeByToggle_io_output_payload_PADDR;
  wire                flowCCUnsafeByToggle_io_output_payload_PWRITE;
  wire       [31:0]   flowCCUnsafeByToggle_io_output_payload_PWDATA;
  wire                flowCCUnsafeByToggle_1_io_output_valid;
  wire       [31:0]   flowCCUnsafeByToggle_1_io_output_payload_PRDATA;
  wire                flowCCUnsafeByToggle_1_io_output_payload_PSLVERROR;
  wire                inputLogic_inputCmd_valid;
  wire       [13:0]   inputLogic_inputCmd_payload_PADDR;
  wire                inputLogic_inputCmd_payload_PWRITE;
  wire       [31:0]   inputLogic_inputCmd_payload_PWDATA;
  wire                inputLogic_inputRsp_valid;
  wire       [31:0]   inputLogic_inputRsp_payload_PRDATA;
  wire                inputLogic_inputRsp_payload_PSLVERROR;
  reg                 inputLogic_state;
  wire                flowCCUnsafeByToggle_io_output_toStream_valid;
  reg                 flowCCUnsafeByToggle_io_output_toStream_ready;
  wire       [13:0]   flowCCUnsafeByToggle_io_output_toStream_payload_PADDR;
  wire                flowCCUnsafeByToggle_io_output_toStream_payload_PWRITE;
  wire       [31:0]   flowCCUnsafeByToggle_io_output_toStream_payload_PWDATA;
  wire                outputLogic_outputCmd_valid;
  reg                 outputLogic_outputCmd_ready;
  wire       [13:0]   outputLogic_outputCmd_payload_PADDR;
  wire                outputLogic_outputCmd_payload_PWRITE;
  wire       [31:0]   outputLogic_outputCmd_payload_PWDATA;
  reg                 flowCCUnsafeByToggle_io_output_toStream_rValid;
  wire                flowCCUnsafeByToggle_io_output_toStream_fire;
  (* async_reg = "true" *) reg        [13:0]   flowCCUnsafeByToggle_io_output_toStream_rData_PADDR;
  (* async_reg = "true" *) reg                 flowCCUnsafeByToggle_io_output_toStream_rData_PWRITE;
  (* async_reg = "true" *) reg        [31:0]   flowCCUnsafeByToggle_io_output_toStream_rData_PWDATA;
  wire                when_Stream_l375;
  reg                 outputLogic_state;
  wire                when_Apb3CCToggle_l81;
  wire                outputLogic_outputRsp_valid;
  wire       [31:0]   outputLogic_outputRsp_payload_PRDATA;
  wire                outputLogic_outputRsp_payload_PSLVERROR;
  wire                outputLogic_outputCmd_fire;

  EfxDMA_FlowCCUnsafeByToggle flowCCUnsafeByToggle (
    .io_input_valid           (inputLogic_inputCmd_valid                          ), //i
    .io_input_payload_PADDR   (inputLogic_inputCmd_payload_PADDR[13:0]            ), //i
    .io_input_payload_PWRITE  (inputLogic_inputCmd_payload_PWRITE                 ), //i
    .io_input_payload_PWDATA  (inputLogic_inputCmd_payload_PWDATA[31:0]           ), //i
    .io_output_valid          (flowCCUnsafeByToggle_io_output_valid               ), //o
    .io_output_payload_PADDR  (flowCCUnsafeByToggle_io_output_payload_PADDR[13:0] ), //o
    .io_output_payload_PWRITE (flowCCUnsafeByToggle_io_output_payload_PWRITE      ), //o
    .io_output_payload_PWDATA (flowCCUnsafeByToggle_io_output_payload_PWDATA[31:0]), //o
    .ctrl_clk                 (ctrl_clk                                           ), //i
    .ctrl_reset               (ctrl_reset                                         ), //i
    .clk                      (clk                                                ), //i
    .reset                    (reset                                              )  //i
  );
  EfxDMA_FlowCCUnsafeByToggle_1 flowCCUnsafeByToggle_1 (
    .io_input_valid              (outputLogic_outputRsp_valid                          ), //i
    .io_input_payload_PRDATA     (outputLogic_outputRsp_payload_PRDATA[31:0]           ), //i
    .io_input_payload_PSLVERROR  (outputLogic_outputRsp_payload_PSLVERROR              ), //i
    .io_output_valid             (flowCCUnsafeByToggle_1_io_output_valid               ), //o
    .io_output_payload_PRDATA    (flowCCUnsafeByToggle_1_io_output_payload_PRDATA[31:0]), //o
    .io_output_payload_PSLVERROR (flowCCUnsafeByToggle_1_io_output_payload_PSLVERROR   ), //o
    .clk                         (clk                                                  ), //i
    .reset                       (reset                                                ), //i
    .ctrl_clk                    (ctrl_clk                                             ), //i
    .ctrl_reset                  (ctrl_reset                                           )  //i
  );
  assign inputLogic_inputCmd_valid = ((io_input_PSEL[0] && io_input_PENABLE) && (! inputLogic_state));
  assign inputLogic_inputCmd_payload_PADDR = io_input_PADDR;
  assign inputLogic_inputCmd_payload_PWRITE = io_input_PWRITE;
  assign inputLogic_inputCmd_payload_PWDATA = io_input_PWDATA;
  assign io_input_PREADY = inputLogic_inputRsp_valid;
  assign io_input_PRDATA = inputLogic_inputRsp_payload_PRDATA;
  assign io_input_PSLVERROR = inputLogic_inputRsp_payload_PSLVERROR;
  assign flowCCUnsafeByToggle_io_output_toStream_valid = flowCCUnsafeByToggle_io_output_valid;
  assign flowCCUnsafeByToggle_io_output_toStream_payload_PADDR = flowCCUnsafeByToggle_io_output_payload_PADDR;
  assign flowCCUnsafeByToggle_io_output_toStream_payload_PWRITE = flowCCUnsafeByToggle_io_output_payload_PWRITE;
  assign flowCCUnsafeByToggle_io_output_toStream_payload_PWDATA = flowCCUnsafeByToggle_io_output_payload_PWDATA;
  assign flowCCUnsafeByToggle_io_output_toStream_fire = (flowCCUnsafeByToggle_io_output_toStream_valid && flowCCUnsafeByToggle_io_output_toStream_ready);
  always @(*) begin
    flowCCUnsafeByToggle_io_output_toStream_ready = outputLogic_outputCmd_ready;
    if(when_Stream_l375) begin
      flowCCUnsafeByToggle_io_output_toStream_ready = 1'b1;
    end
  end

  assign when_Stream_l375 = (! outputLogic_outputCmd_valid);
  assign outputLogic_outputCmd_valid = flowCCUnsafeByToggle_io_output_toStream_rValid;
  assign outputLogic_outputCmd_payload_PADDR = flowCCUnsafeByToggle_io_output_toStream_rData_PADDR;
  assign outputLogic_outputCmd_payload_PWRITE = flowCCUnsafeByToggle_io_output_toStream_rData_PWRITE;
  assign outputLogic_outputCmd_payload_PWDATA = flowCCUnsafeByToggle_io_output_toStream_rData_PWDATA;
  always @(*) begin
    io_output_PENABLE = 1'b0;
    if(outputLogic_outputCmd_valid) begin
      if(when_Apb3CCToggle_l81) begin
        io_output_PENABLE = 1'b0;
      end else begin
        io_output_PENABLE = 1'b1;
      end
    end
  end

  always @(*) begin
    io_output_PSEL = 1'b0;
    if(outputLogic_outputCmd_valid) begin
      io_output_PSEL = 1'b1;
    end
  end

  assign io_output_PADDR = outputLogic_outputCmd_payload_PADDR;
  assign io_output_PWDATA = outputLogic_outputCmd_payload_PWDATA;
  assign io_output_PWRITE = outputLogic_outputCmd_payload_PWRITE;
  always @(*) begin
    outputLogic_outputCmd_ready = 1'b0;
    if(outputLogic_outputCmd_valid) begin
      if(!when_Apb3CCToggle_l81) begin
        if(io_output_PREADY) begin
          outputLogic_outputCmd_ready = 1'b1;
        end
      end
    end
  end

  assign when_Apb3CCToggle_l81 = (! outputLogic_state);
  assign outputLogic_outputCmd_fire = (outputLogic_outputCmd_valid && outputLogic_outputCmd_ready);
  assign outputLogic_outputRsp_valid = outputLogic_outputCmd_fire;
  assign outputLogic_outputRsp_payload_PRDATA = io_output_PRDATA;
  assign outputLogic_outputRsp_payload_PSLVERROR = io_output_PSLVERROR;
  assign inputLogic_inputRsp_valid = flowCCUnsafeByToggle_1_io_output_valid;
  assign inputLogic_inputRsp_payload_PRDATA = flowCCUnsafeByToggle_1_io_output_payload_PRDATA;
  assign inputLogic_inputRsp_payload_PSLVERROR = flowCCUnsafeByToggle_1_io_output_payload_PSLVERROR;
  always @(posedge ctrl_clk) begin
    if(ctrl_reset) begin
      inputLogic_state <= 1'b0;
    end else begin
      if(inputLogic_inputCmd_valid) begin
        inputLogic_state <= 1'b1;
      end
      if(inputLogic_inputRsp_valid) begin
        inputLogic_state <= 1'b0;
      end
    end
  end

  always @(posedge clk) begin
    if(reset) begin
      flowCCUnsafeByToggle_io_output_toStream_rValid <= 1'b0;
      outputLogic_state <= 1'b0;
    end else begin
      if(flowCCUnsafeByToggle_io_output_toStream_ready) begin
        flowCCUnsafeByToggle_io_output_toStream_rValid <= flowCCUnsafeByToggle_io_output_toStream_valid;
      end
      if(outputLogic_outputCmd_valid) begin
        if(when_Apb3CCToggle_l81) begin
          outputLogic_state <= 1'b1;
        end else begin
          if(io_output_PREADY) begin
            outputLogic_state <= 1'b0;
          end
        end
      end
    end
  end

  always @(posedge clk) begin
    if(flowCCUnsafeByToggle_io_output_toStream_fire) begin
      flowCCUnsafeByToggle_io_output_toStream_rData_PADDR <= flowCCUnsafeByToggle_io_output_toStream_payload_PADDR;
      flowCCUnsafeByToggle_io_output_toStream_rData_PWRITE <= flowCCUnsafeByToggle_io_output_toStream_payload_PWRITE;
      flowCCUnsafeByToggle_io_output_toStream_rData_PWDATA <= flowCCUnsafeByToggle_io_output_toStream_payload_PWDATA;
    end
  end


endmodule

module EfxDMA_Core (
  output wire          io_sgRead_cmd_valid,
  input  wire          io_sgRead_cmd_ready,
  output wire          io_sgRead_cmd_payload_last,
  output wire [0:0]    io_sgRead_cmd_payload_fragment_opcode,
  output wire [31:0]   io_sgRead_cmd_payload_fragment_address,
  output wire [4:0]    io_sgRead_cmd_payload_fragment_length,
  output wire [0:0]    io_sgRead_cmd_payload_fragment_context,
  input  wire          io_sgRead_rsp_valid,
  output wire          io_sgRead_rsp_ready,
  input  wire          io_sgRead_rsp_payload_last,
  input  wire [0:0]    io_sgRead_rsp_payload_fragment_opcode,
  input  wire [63:0]   io_sgRead_rsp_payload_fragment_data,
  input  wire [0:0]    io_sgRead_rsp_payload_fragment_context,
  output wire          io_sgWrite_cmd_valid,
  input  wire          io_sgWrite_cmd_ready,
  output wire          io_sgWrite_cmd_payload_last,
  output wire [0:0]    io_sgWrite_cmd_payload_fragment_opcode,
  output wire [31:0]   io_sgWrite_cmd_payload_fragment_address,
  output wire [1:0]    io_sgWrite_cmd_payload_fragment_length,
  output reg  [63:0]   io_sgWrite_cmd_payload_fragment_data,
  output reg  [7:0]    io_sgWrite_cmd_payload_fragment_mask,
  output wire [0:0]    io_sgWrite_cmd_payload_fragment_context,
  input  wire          io_sgWrite_rsp_valid,
  output wire          io_sgWrite_rsp_ready,
  input  wire          io_sgWrite_rsp_payload_last,
  input  wire [0:0]    io_sgWrite_rsp_payload_fragment_opcode,
  input  wire [0:0]    io_sgWrite_rsp_payload_fragment_context,
  output reg           io_read_cmd_valid,
  input  wire          io_read_cmd_ready,
  output wire          io_read_cmd_payload_last,
  output wire [0:0]    io_read_cmd_payload_fragment_opcode,
  output wire [31:0]   io_read_cmd_payload_fragment_address,
  output wire [10:0]   io_read_cmd_payload_fragment_length,
  output wire [17:0]   io_read_cmd_payload_fragment_context,
  input  wire          io_read_rsp_valid,
  output wire          io_read_rsp_ready,
  input  wire          io_read_rsp_payload_last,
  input  wire [0:0]    io_read_rsp_payload_fragment_opcode,
  input  wire [63:0]   io_read_rsp_payload_fragment_data,
  input  wire [17:0]   io_read_rsp_payload_fragment_context,
  output wire          io_write_cmd_valid,
  input  wire          io_write_cmd_ready,
  output wire          io_write_cmd_payload_last,
  output wire [0:0]    io_write_cmd_payload_fragment_opcode,
  output wire [31:0]   io_write_cmd_payload_fragment_address,
  output wire [10:0]   io_write_cmd_payload_fragment_length,
  output wire [63:0]   io_write_cmd_payload_fragment_data,
  output wire [7:0]    io_write_cmd_payload_fragment_mask,
  output wire [11:0]   io_write_cmd_payload_fragment_context,
  input  wire          io_write_rsp_valid,
  output wire          io_write_rsp_ready,
  input  wire          io_write_rsp_payload_last,
  input  wire [0:0]    io_write_rsp_payload_fragment_opcode,
  input  wire [11:0]   io_write_rsp_payload_fragment_context,
  output wire          io_outputs_0_valid,
  input  wire          io_outputs_0_ready,
  output wire [31:0]   io_outputs_0_payload_data,
  output wire [3:0]    io_outputs_0_payload_mask,
  output wire [3:0]    io_outputs_0_payload_sink,
  output wire          io_outputs_0_payload_last,
  input  wire          io_inputs_0_valid,
  output reg           io_inputs_0_ready,
  input  wire [31:0]   io_inputs_0_payload_data,
  input  wire [3:0]    io_inputs_0_payload_mask,
  input  wire [3:0]    io_inputs_0_payload_sink,
  input  wire          io_inputs_0_payload_last,
  output reg  [1:0]    io_interrupts,
  input  wire [13:0]   io_ctrl_PADDR,
  input  wire [0:0]    io_ctrl_PSEL,
  input  wire          io_ctrl_PENABLE,
  output wire          io_ctrl_PREADY,
  input  wire          io_ctrl_PWRITE,
  input  wire [31:0]   io_ctrl_PWDATA,
  output reg  [31:0]   io_ctrl_PRDATA,
  output wire          io_ctrl_PSLVERROR,
  output wire          ll_0_descriptorUpdate,
  output wire          ll_1_descriptorUpdate,
  input  wire          clk,
  input  wire          reset
);

  wire       [12:0]   memory_core_io_writes_0_cmd_payload_address;
  wire       [5:0]    memory_core_io_writes_0_cmd_payload_context;
  wire       [12:0]   memory_core_io_writes_1_cmd_payload_address;
  reg        [7:0]    memory_core_io_writes_1_cmd_payload_mask;
  wire       [5:0]    memory_core_io_writes_1_cmd_payload_context;
  wire                memory_core_io_reads_0_cmd_valid;
  wire       [12:0]   memory_core_io_reads_0_cmd_payload_address;
  wire       [2:0]    memory_core_io_reads_0_cmd_payload_context;
  wire       [12:0]   memory_core_io_reads_1_cmd_payload_address;
  wire       [14:0]   memory_core_io_reads_1_cmd_payload_context;
  wire       [7:0]    b2m_fsm_aggregate_engine_io_input_payload_mask;
  wire                b2m_fsm_aggregate_engine_io_flush;
  wire       [2:0]    b2m_fsm_aggregate_engine_io_offset;
  wire                memory_core_io_writes_0_cmd_ready;
  wire                memory_core_io_writes_0_rsp_valid;
  wire       [5:0]    memory_core_io_writes_0_rsp_payload_context;
  wire                memory_core_io_writes_1_cmd_ready;
  wire                memory_core_io_writes_1_rsp_valid;
  wire       [5:0]    memory_core_io_writes_1_rsp_payload_context;
  wire                memory_core_io_reads_0_cmd_ready;
  wire                memory_core_io_reads_0_rsp_valid;
  wire       [31:0]   memory_core_io_reads_0_rsp_payload_data;
  wire       [3:0]    memory_core_io_reads_0_rsp_payload_mask;
  wire       [2:0]    memory_core_io_reads_0_rsp_payload_context;
  wire                memory_core_io_reads_1_cmd_ready;
  wire                memory_core_io_reads_1_rsp_valid;
  wire       [63:0]   memory_core_io_reads_1_rsp_payload_data;
  wire       [7:0]    memory_core_io_reads_1_rsp_payload_mask;
  wire       [14:0]   memory_core_io_reads_1_rsp_payload_context;
  wire                b2m_fsm_aggregate_engine_io_input_ready;
  wire       [63:0]   b2m_fsm_aggregate_engine_io_output_data;
  wire       [7:0]    b2m_fsm_aggregate_engine_io_output_mask;
  wire                b2m_fsm_aggregate_engine_io_output_consumed;
  wire       [2:0]    b2m_fsm_aggregate_engine_io_output_usedUntil;
  wire       [26:0]   _zz_channels_0_bytesProbe_value;
  wire       [26:0]   _zz_channels_0_bytesProbe_value_1;
  wire       [15:0]   _zz_channels_0_fifo_pop_withOverride_backupNext;
  wire       [15:0]   _zz_channels_0_fifo_pop_withOverride_exposed;
  wire       [26:0]   _zz_channels_0_pop_b2m_selfFlush;
  wire       [15:0]   _zz_channels_0_pop_b2m_request;
  wire       [13:0]   _zz_channels_0_pop_b2m_request_1;
  wire       [12:0]   _zz_channels_0_pop_b2m_request_2;
  wire       [3:0]    _zz_channels_0_pop_b2m_memPending;
  wire       [3:0]    _zz_channels_0_pop_b2m_memPending_1;
  wire       [0:0]    _zz_channels_0_pop_b2m_memPending_2;
  wire       [3:0]    _zz_channels_0_pop_b2m_memPending_3;
  wire       [0:0]    _zz_channels_0_pop_b2m_memPending_4;
  wire       [13:0]   _zz_channels_0_fifo_push_available;
  wire       [26:0]   _zz_channels_1_bytesProbe_value;
  wire       [26:0]   _zz_channels_1_bytesProbe_value_1;
  wire       [15:0]   _zz_channels_1_fifo_pop_withoutOverride_exposed;
  wire       [3:0]    _zz_channels_1_push_m2b_memPending;
  wire       [3:0]    _zz_channels_1_push_m2b_memPending_1;
  wire       [0:0]    _zz_channels_1_push_m2b_memPending_2;
  wire       [3:0]    _zz_channels_1_push_m2b_memPending_3;
  wire       [0:0]    _zz_channels_1_push_m2b_memPending_4;
  wire       [13:0]   _zz_channels_1_push_m2b_loadRequest;
  wire       [8:0]    _zz_channels_1_push_m2b_loadRequest_1;
  wire       [25:0]   _zz_when_DmaSg_l486;
  wire       [13:0]   _zz_channels_1_fifo_push_available;
  wire       [0:0]    _zz_s2b_0_cmd_firsts;
  wire       [4:0]    _zz_s2b_0_cmd_firsts_1;
  reg        [2:0]    _zz_s2b_0_cmd_byteCount_8;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount_9;
  reg        [2:0]    _zz_s2b_0_cmd_byteCount_10;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount_11;
  wire       [0:0]    _zz_s2b_0_cmd_byteCount_12;
  wire       [1:0]    _zz__zz_m2b_cmd_s0_priority_chosenOh_2;
  wire       [1:0]    _zz__zz_m2b_cmd_s0_priority_chosenOh_2_1;
  wire       [0:0]    _zz__zz_m2b_cmd_s0_priority_chosenOh_2_2;
  reg        [0:0]    _zz__zz_m2b_cmd_s0_priority_chosenOh_2_3;
  wire       [25:0]   _zz_m2b_cmd_s0_length;
  wire       [25:0]   _zz_m2b_cmd_s0_length_1;
  wire       [25:0]   _zz_m2b_cmd_s0_length_2;
  wire       [25:0]   _zz_m2b_cmd_s0_lastBurst;
  wire       [31:0]   _zz_m2b_cmd_s1_context_stop;
  wire       [31:0]   _zz_m2b_cmd_s1_context_stop_1;
  wire       [31:0]   _zz_m2b_cmd_s1_addressNext;
  wire       [31:0]   _zz_m2b_cmd_s1_addressNext_1;
  wire       [25:0]   _zz_m2b_cmd_s1_byteLeftNext;
  wire       [25:0]   _zz_m2b_cmd_s1_byteLeftNext_1;
  wire       [11:0]   _zz_m2b_cmd_s1_fifoPushDecr;
  wire       [10:0]   _zz_m2b_cmd_s1_fifoPushDecr_1;
  wire       [10:0]   _zz_m2b_cmd_s1_fifoPushDecr_2;
  wire       [2:0]    _zz_m2b_cmd_s1_fifoPushDecr_3;
  wire       [11:0]   _zz_m2b_cmd_s1_fifoPushDecr_4;
  wire       [1:0]    _zz_m2b_cmd_s1_fifoPushDecr_5;
  wire       [1:0]    _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2;
  wire       [1:0]    _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_1;
  wire       [0:0]    _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_2;
  reg        [0:0]    _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_3;
  wire       [0:0]    _zz_when;
  wire       [11:0]   _zz_b2m_fsm_bytesInBurstP1;
  wire       [1:0]    _zz_b2m_fsm_bytesInBurstP1_1;
  wire       [31:0]   _zz_b2m_fsm_addressNext;
  wire       [26:0]   _zz_b2m_fsm_bytesLeftNext;
  wire       [12:0]   _zz_b2m_fsm_bytesLeftNext_1;
  wire       [25:0]   _zz__zz_b2m_fsm_sel_bytesInBurst_1;
  wire       [25:0]   _zz__zz_b2m_fsm_sel_bytesInBurst_1_1;
  wire       [10:0]   _zz__zz_b2m_fsm_sel_bytesInBurst_2;
  wire       [25:0]   _zz_b2m_fsm_sel_bytesInBurst_3;
  wire       [25:0]   _zz_b2m_fsm_sel_bytesInBurst_4;
  wire       [25:0]   _zz_b2m_fsm_sel_bytesInBurst_5;
  wire       [15:0]   _zz_b2m_fsm_fifoCompletion;
  wire       [15:0]   _zz_b2m_fsm_fifoCompletion_1;
  wire       [10:0]   _zz_b2m_fsm_beatCounter;
  wire       [10:0]   _zz_b2m_fsm_beatCounter_1;
  wire       [2:0]    _zz_b2m_fsm_beatCounter_2;
  wire       [13:0]   _zz_b2m_fsm_sel_ptr;
  wire       [2:0]    _zz_b2m_fsm_aggregate_bytesToSkipMask;
  wire                _zz_b2m_fsm_aggregate_bytesToSkipMask_1;
  wire                _zz_b2m_fsm_aggregate_bytesToSkipMask_2;
  wire                _zz_b2m_fsm_aggregate_bytesToSkipMask_3;
  wire       [0:0]    _zz_b2m_fsm_aggregate_bytesToSkipMask_4;
  wire       [1:0]    _zz_b2m_fsm_aggregate_bytesToSkipMask_5;
  wire       [2:0]    _zz_b2m_fsm_cmd_maskLastTriggerComb;
  wire       [2:0]    _zz_b2m_fsm_cmd_maskLast;
  wire                _zz_b2m_fsm_cmd_maskLast_1;
  wire                _zz_b2m_fsm_cmd_maskLast_2;
  wire       [2:0]    _zz_b2m_fsm_cmd_maskFirst;
  wire                _zz_b2m_fsm_cmd_maskFirst_1;
  wire                _zz_b2m_fsm_cmd_maskFirst_2;
  wire       [0:0]    _zz_when_1;
  wire       [0:0]    _zz_when_2;
  wire       [1:0]    _zz__zz_ll_arbiter_head_1;
  wire       [1:0]    _zz__zz_ll_arbiter_head_1_1;
  wire       [1:0]    _zz_ll_arbiter_head_2;
  wire       [1:0]    _zz_ll_arbiter_isJustASink;
  wire       [1:0]    _zz_ll_arbiter_doDescriptorStall;
  wire       [1:0]    _zz_ll_arbiter_onSgStream;
  wire       [1:0]    _zz_ll_cmd_ptr;
  wire       [1:0]    _zz_ll_cmd_ptrNext;
  wire       [1:0]    _zz_ll_cmd_endOfPacket;
  wire       [0:0]    _zz_channels_0_channelStart;
  wire       [0:0]    _zz_channels_0_ctrl_kick;
  wire       [0:0]    _zz_channels_0_channelStart_1;
  wire       [0:0]    _zz_channels_0_ll_sgStart;
  wire       [0:0]    _zz_channels_0_interrupts_completion_valid;
  wire       [0:0]    _zz_channels_0_interrupts_onChannelCompletion_valid;
  wire       [0:0]    _zz_channels_0_interrupts_onLinkedListUpdate_valid;
  wire       [0:0]    _zz_channels_0_interrupts_s2mPacket_valid;
  wire       [0:0]    _zz_channels_1_channelStart;
  wire       [0:0]    _zz_channels_1_ctrl_kick;
  wire       [0:0]    _zz_channels_1_channelStart_1;
  wire       [0:0]    _zz_channels_1_ll_sgStart;
  wire       [0:0]    _zz_channels_1_interrupts_completion_valid;
  wire       [0:0]    _zz_channels_1_interrupts_onChannelCompletion_valid;
  wire       [0:0]    _zz_channels_1_interrupts_onLinkedListUpdate_valid;
  wire       [31:0]   _zz_io_ctrl_PRDATA;
  wire       [31:0]   _zz_io_ctrl_PRDATA_1;
  wire       [13:0]   _zz_channels_0_fifo_push_ptrIncr_value;
  wire       [0:0]    _zz_channels_0_fifo_push_ptrIncr_value_1;
  wire       [15:0]   _zz_channels_0_fifo_pop_bytesIncr_value_1;
  wire       [2:0]    _zz_channels_0_fifo_pop_bytesIncr_value_2;
  wire       [13:0]   _zz_channels_0_fifo_pop_ptrIncr_value;
  wire       [1:0]    _zz_channels_0_fifo_pop_ptrIncr_value_1;
  wire       [13:0]   _zz_channels_1_fifo_push_ptrIncr_value_1;
  wire       [1:0]    _zz_channels_1_fifo_push_ptrIncr_value_2;
  wire       [15:0]   _zz_channels_1_fifo_pop_bytesIncr_value_1;
  wire       [3:0]    _zz_channels_1_fifo_pop_bytesIncr_value_2;
  wire       [3:0]    _zz_channels_1_fifo_pop_bytesIncr_value_3;
  wire       [13:0]   _zz_channels_1_fifo_pop_ptrIncr_value;
  wire       [0:0]    _zz_channels_1_fifo_pop_ptrIncr_value_1;
  wire                ctrl_readErrorFlag;
  wire                ctrl_writeErrorFlag;
  wire                ctrl_askWrite;
  wire                ctrl_askRead;
  wire                ctrl_doWrite;
  wire                ctrl_doRead;
  reg                 channels_0_channelStart;
  reg                 channels_0_channelStop;
  reg                 channels_0_channelCompletion;
  reg                 channels_0_channelValid;
  reg                 channels_0_descriptorStart;
  reg                 channels_0_descriptorCompletion;
  reg                 channels_0_descriptorValid;
  reg        [25:0]   channels_0_bytes;
  reg        [1:0]    channels_0_priority;
  reg        [1:0]    channels_0_weight;
  reg                 channels_0_readyToStop;
  reg        [26:0]   channels_0_bytesProbe_value;
  reg                 channels_0_bytesProbe_incr_valid;
  reg        [10:0]   channels_0_bytesProbe_incr_payload;
  reg                 channels_0_ctrl_kick;
  reg                 channels_0_ll_sgStart;
  reg                 channels_0_ll_valid;
  reg                 channels_0_ll_onSgStream;
  reg                 channels_0_ll_head;
  reg                 channels_0_ll_justASync;
  reg                 channels_0_ll_waitDone;
  reg                 channels_0_ll_readDone;
  reg                 channels_0_ll_writeDone;
  reg                 channels_0_ll_gotDescriptorStall;
  reg                 channels_0_ll_controlNoCompletion;
  reg                 channels_0_ll_packet;
  reg                 channels_0_ll_requireSync;
  reg        [31:0]   channels_0_ll_ptr;
  reg        [31:0]   channels_0_ll_ptrNext;
  wire                channels_0_ll_requestLl;
  reg                 channels_0_ll_descriptorUpdated;
  wire                when_DmaSg_l318;
  wire                when_DmaSg_l320;
  wire                when_DmaSg_l322;
  wire                when_DmaSg_l328;
  wire       [13:0]   channels_0_fifo_base;
  wire       [13:0]   channels_0_fifo_words;
  reg        [13:0]   channels_0_fifo_push_available;
  wire       [13:0]   channels_0_fifo_push_availableDecr;
  reg        [13:0]   channels_0_fifo_push_ptr;
  wire       [13:0]   channels_0_fifo_push_ptrWithBase;
  wire       [13:0]   channels_0_fifo_push_ptrIncr_value;
  reg        [13:0]   channels_0_fifo_pop_ptr;
  wire       [15:0]   channels_0_fifo_pop_bytes;
  wire       [13:0]   channels_0_fifo_pop_ptrWithBase;
  wire       [15:0]   channels_0_fifo_pop_bytesIncr_value;
  wire       [15:0]   channels_0_fifo_pop_bytesDecr_value;
  wire                channels_0_fifo_pop_empty;
  wire       [13:0]   channels_0_fifo_pop_ptrIncr_value;
  reg        [15:0]   channels_0_fifo_pop_withOverride_backup;
  wire       [15:0]   channels_0_fifo_pop_withOverride_backupNext;
  reg                 channels_0_fifo_pop_withOverride_load;
  reg                 channels_0_fifo_pop_withOverride_unload;
  reg        [15:0]   channels_0_fifo_pop_withOverride_exposed;
  reg                 channels_0_fifo_pop_withOverride_valid;
  wire                when_DmaSg_l409;
  wire                channels_0_fifo_empty;
  reg                 channels_0_push_memory;
  reg                 channels_0_push_s2b_completionOnLast;
  reg                 channels_0_push_s2b_packetEvent;
  reg                 channels_0_push_s2b_packetLock;
  reg                 channels_0_push_s2b_waitFirst;
  wire                when_DmaSg_l457;
  reg                 channels_0_pop_memory;
  wire       [10:0]   channels_0_pop_b2m_bytePerBurst;
  reg                 channels_0_pop_b2m_fire;
  reg                 channels_0_pop_b2m_waitFinalRsp;
  reg                 channels_0_pop_b2m_flush;
  reg                 channels_0_pop_b2m_packetSync;
  reg                 channels_0_pop_b2m_packet;
  wire                when_DmaSg_l505;
  reg                 channels_0_pop_b2m_memRsp;
  reg        [3:0]    channels_0_pop_b2m_memPending;
  reg        [31:0]   channels_0_pop_b2m_address;
  reg        [26:0]   channels_0_pop_b2m_bytesLeft;
  wire                channels_0_pop_b2m_selfFlush;
  wire                channels_0_pop_b2m_request;
  reg        [2:0]    channels_0_pop_b2m_bytesToSkip;
  reg        [15:0]   channels_0_pop_b2m_decrBytes;
  reg                 channels_0_pop_b2m_memPendingInc;
  wire                when_DmaSg_l523;
  wire                when_DmaSg_l532;
  wire                when_DmaSg_l536;
  wire                when_DmaSg_l547;
  wire                when_DmaSg_l563;
  wire                channels_0_readyForChannelCompletion;
  wire                when_DmaSg_l575;
  reg                 _zz_when_DmaSg_l593;
  wire                when_DmaSg_l593;
  wire                channels_0_s2b_full;
  reg        [13:0]   channels_0_fifo_pop_ptrIncr_value_regNext;
  wire                when_DmaSg_l255;
  reg                 channels_0_interrupts_completion_enable;
  reg                 channels_0_interrupts_completion_valid;
  wire                when_DmaSg_l255_1;
  wire                when_DmaSg_l255_2;
  reg                 channels_0_interrupts_onChannelCompletion_enable;
  reg                 channels_0_interrupts_onChannelCompletion_valid;
  wire                when_DmaSg_l255_3;
  reg                 channels_0_interrupts_onLinkedListUpdate_enable;
  reg                 channels_0_interrupts_onLinkedListUpdate_valid;
  wire                when_DmaSg_l255_4;
  reg                 channels_0_interrupts_s2mPacket_enable;
  reg                 channels_0_interrupts_s2mPacket_valid;
  wire                when_DmaSg_l255_5;
  wire                when_DmaSg_l625;
  reg                 channels_1_channelStart;
  reg                 channels_1_channelStop;
  reg                 channels_1_channelCompletion;
  reg                 channels_1_channelValid;
  reg                 channels_1_descriptorStart;
  reg                 channels_1_descriptorCompletion;
  reg                 channels_1_descriptorValid;
  reg        [25:0]   channels_1_bytes;
  reg        [1:0]    channels_1_priority;
  reg        [1:0]    channels_1_weight;
  reg                 channels_1_readyToStop;
  reg        [26:0]   channels_1_bytesProbe_value;
  reg                 channels_1_bytesProbe_incr_valid;
  reg        [10:0]   channels_1_bytesProbe_incr_payload;
  reg                 channels_1_ctrl_kick;
  reg                 channels_1_ll_sgStart;
  reg                 channels_1_ll_valid;
  reg                 channels_1_ll_onSgStream;
  reg                 channels_1_ll_head;
  reg                 channels_1_ll_justASync;
  reg                 channels_1_ll_waitDone;
  reg                 channels_1_ll_readDone;
  reg                 channels_1_ll_writeDone;
  reg                 channels_1_ll_gotDescriptorStall;
  reg                 channels_1_ll_controlNoCompletion;
  reg                 channels_1_ll_packet;
  reg                 channels_1_ll_requireSync;
  reg        [31:0]   channels_1_ll_ptr;
  reg        [31:0]   channels_1_ll_ptrNext;
  wire                channels_1_ll_requestLl;
  reg                 channels_1_ll_descriptorUpdated;
  wire                when_DmaSg_l318_1;
  wire                when_DmaSg_l320_1;
  wire                when_DmaSg_l322_1;
  wire                when_DmaSg_l328_1;
  wire       [13:0]   channels_1_fifo_base;
  wire       [13:0]   channels_1_fifo_words;
  reg        [13:0]   channels_1_fifo_push_available;
  reg        [13:0]   channels_1_fifo_push_availableDecr;
  reg        [13:0]   channels_1_fifo_push_ptr;
  wire       [13:0]   channels_1_fifo_push_ptrWithBase;
  wire       [13:0]   channels_1_fifo_push_ptrIncr_value;
  reg        [13:0]   channels_1_fifo_pop_ptr;
  wire       [15:0]   channels_1_fifo_pop_bytes;
  wire       [13:0]   channels_1_fifo_pop_ptrWithBase;
  wire       [15:0]   channels_1_fifo_pop_bytesIncr_value;
  wire       [15:0]   channels_1_fifo_pop_bytesDecr_value;
  wire                channels_1_fifo_pop_empty;
  wire       [13:0]   channels_1_fifo_pop_ptrIncr_value;
  reg        [15:0]   channels_1_fifo_pop_withoutOverride_exposed;
  wire                channels_1_fifo_empty;
  reg                 channels_1_push_memory;
  reg        [31:0]   channels_1_push_m2b_address;
  wire       [10:0]   channels_1_push_m2b_bytePerBurst;
  reg                 channels_1_push_m2b_loadDone;
  reg        [25:0]   channels_1_push_m2b_bytesLeft;
  reg        [3:0]    channels_1_push_m2b_memPending;
  reg                 channels_1_push_m2b_memPendingIncr;
  reg                 channels_1_push_m2b_memPendingDecr;
  reg                 channels_1_push_m2b_loadRequest;
  reg                 channels_1_pop_memory;
  reg                 channels_1_pop_b2s_last;
  reg        [3:0]    channels_1_pop_b2s_sinkId;
  reg                 channels_1_pop_b2s_veryLastTrigger;
  reg                 channels_1_pop_b2s_veryLastValid;
  wire                when_DmaSg_l474;
  reg        [13:0]   channels_1_pop_b2s_veryLastPtr;
  reg                 channels_1_pop_b2s_veryLastEndPacket;
  wire                when_DmaSg_l483;
  wire                when_DmaSg_l486;
  wire                when_DmaSg_l562;
  reg                 channels_1_readyForChannelCompletion;
  wire                when_DmaSg_l566;
  wire                when_DmaSg_l575_1;
  reg                 _zz_when_DmaSg_l593_1;
  wire                when_DmaSg_l593_1;
  wire                channels_1_s2b_full;
  reg        [13:0]   channels_1_fifo_pop_ptrIncr_value_regNext;
  wire                when_DmaSg_l255_6;
  reg                 channels_1_interrupts_completion_enable;
  reg                 channels_1_interrupts_completion_valid;
  wire                when_DmaSg_l255_7;
  wire                when_DmaSg_l255_8;
  reg                 channels_1_interrupts_onChannelCompletion_enable;
  reg                 channels_1_interrupts_onChannelCompletion_valid;
  wire                when_DmaSg_l255_9;
  reg                 channels_1_interrupts_onLinkedListUpdate_enable;
  reg                 channels_1_interrupts_onLinkedListUpdate_valid;
  wire                when_DmaSg_l255_10;
  wire                when_DmaSg_l625_1;
  wire                io_inputs_0_fire;
  wire                when_package_l12;
  reg                 io_inputs_0_payload_last_regNextWhen;
  wire                when_package_l12_1;
  reg                 io_inputs_0_payload_last_regNextWhen_1;
  wire                when_package_l12_2;
  reg                 io_inputs_0_payload_last_regNextWhen_2;
  wire                when_package_l12_3;
  reg                 io_inputs_0_payload_last_regNextWhen_3;
  wire                when_package_l12_4;
  reg                 io_inputs_0_payload_last_regNextWhen_4;
  wire                when_package_l12_5;
  reg                 io_inputs_0_payload_last_regNextWhen_5;
  wire                when_package_l12_6;
  reg                 io_inputs_0_payload_last_regNextWhen_6;
  wire                when_package_l12_7;
  reg                 io_inputs_0_payload_last_regNextWhen_7;
  wire                when_package_l12_8;
  reg                 io_inputs_0_payload_last_regNextWhen_8;
  wire                when_package_l12_9;
  reg                 io_inputs_0_payload_last_regNextWhen_9;
  wire                when_package_l12_10;
  reg                 io_inputs_0_payload_last_regNextWhen_10;
  wire                when_package_l12_11;
  reg                 io_inputs_0_payload_last_regNextWhen_11;
  wire                when_package_l12_12;
  reg                 io_inputs_0_payload_last_regNextWhen_12;
  wire                when_package_l12_13;
  reg                 io_inputs_0_payload_last_regNextWhen_13;
  wire                when_package_l12_14;
  reg                 io_inputs_0_payload_last_regNextWhen_14;
  wire                when_package_l12_15;
  reg                 io_inputs_0_payload_last_regNextWhen_15;
  wire       [15:0]   s2b_0_cmd_firsts;
  wire                s2b_0_cmd_first;
  wire       [0:0]    s2b_0_cmd_channelsOh;
  wire                s2b_0_cmd_noHit;
  wire       [0:0]    s2b_0_cmd_channelsFull;
  reg                 io_inputs_0_thrown_valid;
  wire                io_inputs_0_thrown_ready;
  wire       [31:0]   io_inputs_0_thrown_payload_data;
  wire       [3:0]    io_inputs_0_thrown_payload_mask;
  wire       [3:0]    io_inputs_0_thrown_payload_sink;
  wire                io_inputs_0_thrown_payload_last;
  wire                _zz_io_inputs_0_thrown_ready;
  wire                s2b_0_cmd_sinkHalted_valid;
  wire                s2b_0_cmd_sinkHalted_ready;
  wire       [31:0]   s2b_0_cmd_sinkHalted_payload_data;
  wire       [3:0]    s2b_0_cmd_sinkHalted_payload_mask;
  wire       [3:0]    s2b_0_cmd_sinkHalted_payload_sink;
  wire                s2b_0_cmd_sinkHalted_payload_last;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount_1;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount_2;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount_3;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount_4;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount_5;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount_6;
  wire       [2:0]    _zz_s2b_0_cmd_byteCount_7;
  wire       [2:0]    s2b_0_cmd_byteCount;
  wire       [0:0]    s2b_0_cmd_context_channel;
  wire       [2:0]    s2b_0_cmd_context_bytes;
  wire                s2b_0_cmd_context_flush;
  wire                s2b_0_cmd_context_packet;
  wire                memory_core_io_writes_0_cmd_fire;
  wire                when_DmaSg_l665;
  wire       [0:0]    s2b_0_rsp_context_channel;
  wire       [2:0]    s2b_0_rsp_context_bytes;
  wire                s2b_0_rsp_context_flush;
  wire                s2b_0_rsp_context_packet;
  wire       [5:0]    _zz_s2b_0_rsp_context_channel;
  wire                _zz_channels_0_fifo_pop_bytesIncr_value;
  wire                when_DmaSg_l679;
  wire                when_DmaSg_l681;
  wire                when_DmaSg_l682;
  wire       [0:0]    b2s_0_cmd_channelsOh;
  wire       [0:0]    b2s_0_cmd_context_channel;
  wire                b2s_0_cmd_context_veryLast;
  wire                b2s_0_cmd_context_endPacket;
  wire       [13:0]   b2s_0_cmd_veryLastPtr;
  wire       [13:0]   b2s_0_cmd_address;
  wire       [0:0]    b2s_0_rsp_context_channel;
  wire                b2s_0_rsp_context_veryLast;
  wire                b2s_0_rsp_context_endPacket;
  wire       [2:0]    _zz_b2s_0_rsp_context_channel;
  wire                io_outputs_0_fire;
  wire                when_DmaSg_l725;
  wire                when_DmaSg_l726;
  reg                 m2b_cmd_s0_valid;
  wire       [1:0]    _zz_m2b_cmd_s0_priority_masked;
  wire       [0:0]    m2b_cmd_s0_priority_masked;
  reg        [0:0]    m2b_cmd_s0_priority_roundRobins_0;
  reg        [0:0]    m2b_cmd_s0_priority_roundRobins_1;
  reg        [0:0]    m2b_cmd_s0_priority_roundRobins_2;
  reg        [0:0]    m2b_cmd_s0_priority_roundRobins_3;
  reg        [1:0]    m2b_cmd_s0_priority_counter;
  wire       [0:0]    _zz_m2b_cmd_s0_priority_chosenOh;
  wire       [1:0]    _zz_m2b_cmd_s0_priority_chosenOh_1;
  wire       [1:0]    _zz_m2b_cmd_s0_priority_chosenOh_2;
  wire       [0:0]    m2b_cmd_s0_priority_chosenOh;
  wire                m2b_cmd_s0_priority_weightLast;
  wire       [0:0]    m2b_cmd_s0_priority_contextNext;
  wire                when_DmaSg_l758;
  wire                when_DmaSg_l760;
  wire                when_DmaSg_l763;
  wire                when_DmaSg_l763_1;
  wire                when_DmaSg_l763_2;
  wire                when_DmaSg_l763_3;
  wire                when_DmaSg_l773;
  wire       [31:0]   m2b_cmd_s0_address;
  wire       [25:0]   m2b_cmd_s0_bytesLeft;
  wire       [10:0]   m2b_cmd_s0_readAddressBurstRange;
  wire       [10:0]   m2b_cmd_s0_lengthHead;
  wire       [10:0]   m2b_cmd_s0_length;
  wire                m2b_cmd_s0_lastBurst;
  reg                 m2b_cmd_s1_valid;
  reg        [31:0]   m2b_cmd_s1_address;
  reg        [10:0]   m2b_cmd_s1_length;
  reg                 m2b_cmd_s1_lastBurst;
  reg        [25:0]   m2b_cmd_s1_bytesLeft;
  wire       [2:0]    m2b_cmd_s1_context_start;
  wire       [2:0]    m2b_cmd_s1_context_stop;
  wire       [10:0]   m2b_cmd_s1_context_length;
  wire                m2b_cmd_s1_context_last;
  wire       [31:0]   m2b_cmd_s1_addressNext;
  wire       [25:0]   m2b_cmd_s1_byteLeftNext;
  wire       [9:0]    m2b_cmd_s1_fifoPushDecr;
  wire                when_DmaSg_l828;
  wire       [2:0]    m2b_rsp_context_start;
  wire       [2:0]    m2b_rsp_context_stop;
  wire       [10:0]   m2b_rsp_context_length;
  wire                m2b_rsp_context_last;
  wire       [17:0]   _zz_m2b_rsp_context_start;
  wire                m2b_rsp_veryLast;
  wire                io_read_rsp_fire;
  wire                when_DmaSg_l847;
  wire                when_DmaSg_l848;
  reg                 m2b_rsp_first;
  wire                m2b_rsp_writeContext_last;
  wire                m2b_rsp_writeContext_lastOfBurst;
  wire       [3:0]    m2b_rsp_writeContext_loadByteInNextBeat;
  wire                memory_core_io_writes_1_cmd_fire;
  wire                _zz_channels_1_fifo_push_ptrIncr_value;
  wire                when_DmaSg_l874;
  wire                m2b_writeRsp_context_last;
  wire                m2b_writeRsp_context_lastOfBurst;
  wire       [3:0]    m2b_writeRsp_context_loadByteInNextBeat;
  wire       [5:0]    _zz_m2b_writeRsp_context_last;
  wire                _zz_channels_1_fifo_pop_bytesIncr_value;
  wire                when_DmaSg_l893;
  reg                 b2m_fsm_sel_valid;
  reg                 b2m_fsm_sel_ready;
  reg        [10:0]   b2m_fsm_sel_bytePerBurst;
  reg        [10:0]   b2m_fsm_sel_bytesInBurst;
  reg        [15:0]   b2m_fsm_sel_bytesInFifo;
  reg        [31:0]   b2m_fsm_sel_address;
  reg        [13:0]   b2m_fsm_sel_ptr;
  reg        [13:0]   b2m_fsm_sel_ptrMask;
  reg                 b2m_fsm_sel_flush;
  reg                 b2m_fsm_sel_packet;
  reg        [25:0]   b2m_fsm_sel_bytesLeft;
  reg                 b2m_fsm_arbiter_logic_valid;
  wire       [1:0]    _zz_b2m_fsm_arbiter_logic_priority_masked;
  wire       [0:0]    b2m_fsm_arbiter_logic_priority_masked;
  reg        [0:0]    b2m_fsm_arbiter_logic_priority_roundRobins_0;
  reg        [0:0]    b2m_fsm_arbiter_logic_priority_roundRobins_1;
  reg        [0:0]    b2m_fsm_arbiter_logic_priority_roundRobins_2;
  reg        [0:0]    b2m_fsm_arbiter_logic_priority_roundRobins_3;
  reg        [1:0]    b2m_fsm_arbiter_logic_priority_counter;
  wire       [0:0]    _zz_b2m_fsm_arbiter_logic_priority_chosenOh;
  wire       [1:0]    _zz_b2m_fsm_arbiter_logic_priority_chosenOh_1;
  wire       [1:0]    _zz_b2m_fsm_arbiter_logic_priority_chosenOh_2;
  wire       [0:0]    b2m_fsm_arbiter_logic_priority_chosenOh;
  wire                b2m_fsm_arbiter_logic_priority_weightLast;
  wire       [0:0]    b2m_fsm_arbiter_logic_priority_contextNext;
  wire                when_DmaSg_l758_1;
  wire                when_DmaSg_l760_1;
  wire                when_DmaSg_l763_4;
  wire                when_DmaSg_l763_5;
  wire                when_DmaSg_l763_6;
  wire                when_DmaSg_l763_7;
  wire                when_DmaSg_l773_1;
  wire                when_DmaSg_l935;
  wire       [11:0]   b2m_fsm_bytesInBurstP1;
  wire       [31:0]   b2m_fsm_addressNext;
  wire       [26:0]   b2m_fsm_bytesLeftNext;
  wire                b2m_fsm_isFinalCmd;
  reg        [7:0]    b2m_fsm_beatCounter;
  reg                 b2m_fsm_sel_valid_regNext;
  wire                b2m_fsm_s0;
  reg                 b2m_fsm_s1;
  reg                 b2m_fsm_s2;
  wire                when_DmaSg_l986;
  wire       [15:0]   _zz_b2m_fsm_sel_bytesInBurst;
  wire       [25:0]   _zz_b2m_fsm_sel_bytesInBurst_1;
  wire       [10:0]   _zz_b2m_fsm_sel_bytesInBurst_2;
  wire                b2m_fsm_fifoCompletion;
  wire                when_DmaSg_l996;
  wire                when_DmaSg_l1001;
  reg                 b2m_fsm_toggle;
  wire                when_DmaSg_l1013;
  wire       [13:0]   b2m_fsm_fetch_context_ptr;
  wire                b2m_fsm_fetch_context_toggle;
  wire                when_DmaSg_l1033;
  wire       [13:0]   b2m_fsm_aggregate_context_ptr;
  wire                b2m_fsm_aggregate_context_toggle;
  wire       [14:0]   _zz_b2m_fsm_aggregate_context_ptr;
  wire                memory_core_io_reads_1_rsp_s2mPipe_valid;
  reg                 memory_core_io_reads_1_rsp_s2mPipe_ready;
  wire       [63:0]   memory_core_io_reads_1_rsp_s2mPipe_payload_data;
  wire       [7:0]    memory_core_io_reads_1_rsp_s2mPipe_payload_mask;
  wire       [14:0]   memory_core_io_reads_1_rsp_s2mPipe_payload_context;
  reg                 memory_core_io_reads_1_rsp_rValidN;
  reg        [63:0]   memory_core_io_reads_1_rsp_rData_data;
  reg        [7:0]    memory_core_io_reads_1_rsp_rData_mask;
  reg        [14:0]   memory_core_io_reads_1_rsp_rData_context;
  wire                when_Stream_l445;
  reg                 b2m_fsm_aggregate_memoryPort_valid;
  wire                b2m_fsm_aggregate_memoryPort_ready;
  wire       [63:0]   b2m_fsm_aggregate_memoryPort_payload_data;
  wire       [7:0]    b2m_fsm_aggregate_memoryPort_payload_mask;
  wire       [14:0]   b2m_fsm_aggregate_memoryPort_payload_context;
  reg                 b2m_fsm_aggregate_first;
  wire                b2m_fsm_aggregate_memoryPort_fire;
  wire                when_DmaSg_l1050;
  wire       [2:0]    b2m_fsm_aggregate_bytesToSkip;
  wire       [7:0]    b2m_fsm_aggregate_bytesToSkipMask;
  reg                 _zz_io_flush;
  wire       [2:0]    b2m_fsm_cmd_maskFirstTrigger;
  wire       [2:0]    b2m_fsm_cmd_maskLastTriggerComb;
  reg        [2:0]    b2m_fsm_cmd_maskLastTriggerReg;
  reg        [7:0]    b2m_fsm_cmd_maskLast;
  wire       [7:0]    b2m_fsm_cmd_maskFirst;
  wire                b2m_fsm_cmd_enoughAggregation;
  wire                io_write_cmd_fire;
  reg                 io_write_cmd_payload_first;
  wire                b2m_fsm_cmd_doPtrIncr;
  wire       [10:0]   b2m_fsm_cmd_context_length;
  wire                b2m_fsm_cmd_context_doPacketSync;
  wire                when_DmaSg_l1102;
  wire       [10:0]   b2m_rsp_context_length;
  wire                b2m_rsp_context_doPacketSync;
  wire       [11:0]   _zz_b2m_rsp_context_length;
  wire                io_write_rsp_fire;
  wire                when_DmaSg_l1116;
  wire       [1:0]    _zz_ll_arbiter_head;
  wire                _zz_ll_arbiter_head_1;
  wire                ll_arbiter_head;
  wire                ll_arbiter_isJustASink;
  wire                ll_arbiter_doDescriptorStall;
  wire                ll_arbiter_onSgStream;
  reg                 ll_cmd_valid;
  wire                when_DmaSg_l1149;
  reg                 ll_cmd_oh_0;
  reg                 ll_cmd_oh_1;
  wire                when_DmaSg_l1148;
  reg        [31:0]   ll_cmd_ptr;
  wire                when_DmaSg_l1148_1;
  reg        [31:0]   ll_cmd_ptrNext;
  wire                when_DmaSg_l1148_2;
  reg        [26:0]   ll_cmd_bytesDone;
  wire                when_DmaSg_l1148_3;
  reg                 ll_cmd_endOfPacket;
  wire                when_DmaSg_l1154;
  reg                 ll_cmd_isJustASink;
  wire                when_DmaSg_l1155;
  reg                 ll_cmd_doDescriptorStall;
  wire                when_DmaSg_l1156;
  reg                 ll_cmd_onSgStream;
  reg                 ll_cmd_readFired;
  reg                 ll_cmd_writeFired;
  wire                when_DmaSg_l1160;
  wire                when_DmaSg_l1161;
  wire                when_DmaSg_l1169;
  wire                when_DmaSg_l1169_1;
  wire                when_DmaSg_l1177;
  wire       [0:0]    ll_cmd_context_channel;
  wire       [3:0]    ll_cmd_writeMaskSplit_0;
  wire       [3:0]    ll_cmd_writeMaskSplit_1;
  wire       [31:0]   ll_cmd_writeDataSplit_0;
  wire       [31:0]   ll_cmd_writeDataSplit_1;
  wire                io_sgRead_cmd_fire;
  wire                io_sgWrite_cmd_fire;
  wire       [0:0]    ll_readRsp_context_channel;
  wire       [1:0]    _zz_ll_readRsp_oh_0;
  wire                ll_readRsp_oh_0;
  wire                ll_readRsp_oh_1;
  reg        [1:0]    ll_readRsp_beatCounter;
  reg                 ll_readRsp_completed;
  wire                io_sgRead_rsp_fire;
  wire                when_DmaSg_l1248;
  wire                when_DmaSg_l1248_1;
  wire                when_DmaSg_l1248_2;
  wire                when_DmaSg_l1248_3;
  wire                when_DmaSg_l1248_4;
  wire                when_DmaSg_l1248_5;
  wire                when_DmaSg_l1248_6;
  wire                when_DmaSg_l1271;
  wire       [0:0]    ll_writeRsp_context_channel;
  wire       [1:0]    _zz_ll_writeRsp_oh_0;
  wire                ll_writeRsp_oh_0;
  wire                ll_writeRsp_oh_1;
  wire                io_sgWrite_rsp_fire;
  reg                 when_BusSlaveFactory_l377;
  wire                when_BusSlaveFactory_l379;
  reg                 when_BusSlaveFactory_l377_1;
  wire                when_BusSlaveFactory_l379_1;
  reg                 when_BusSlaveFactory_l377_2;
  wire                when_BusSlaveFactory_l379_2;
  reg                 when_BusSlaveFactory_l377_3;
  wire                when_BusSlaveFactory_l379_3;
  reg                 when_BusSlaveFactory_l341;
  wire                when_BusSlaveFactory_l347;
  reg                 when_BusSlaveFactory_l341_1;
  wire                when_BusSlaveFactory_l347_1;
  reg                 when_BusSlaveFactory_l341_2;
  wire                when_BusSlaveFactory_l347_2;
  reg                 when_BusSlaveFactory_l341_3;
  wire                when_BusSlaveFactory_l347_3;
  reg                 when_BusSlaveFactory_l377_4;
  wire                when_BusSlaveFactory_l379_4;
  reg                 when_BusSlaveFactory_l377_5;
  wire                when_BusSlaveFactory_l379_5;
  reg                 when_BusSlaveFactory_l377_6;
  wire                when_BusSlaveFactory_l379_6;
  reg                 when_BusSlaveFactory_l377_7;
  wire                when_BusSlaveFactory_l379_7;
  reg                 when_BusSlaveFactory_l341_4;
  wire                when_BusSlaveFactory_l347_4;
  reg                 when_BusSlaveFactory_l341_5;
  wire                when_BusSlaveFactory_l347_5;
  reg                 when_BusSlaveFactory_l341_6;
  wire                when_BusSlaveFactory_l347_6;
  wire                when_Apb3SlaveFactory_l81;
  wire                when_Apb3SlaveFactory_l81_1;
  wire                when_Apb3SlaveFactory_l81_2;
  wire                when_Apb3SlaveFactory_l81_3;
  function [7:0] zz_io_sgWrite_cmd_payload_fragment_mask(input dummy);
    begin
      zz_io_sgWrite_cmd_payload_fragment_mask[7 : 4] = 4'b0000;
      zz_io_sgWrite_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
    end
  endfunction
  wire [7:0] _zz_1;

  assign _zz_channels_0_bytesProbe_value = (channels_0_bytesProbe_value + _zz_channels_0_bytesProbe_value_1);
  assign _zz_channels_0_bytesProbe_value_1 = {16'd0, channels_0_bytesProbe_incr_payload};
  assign _zz_channels_0_fifo_pop_withOverride_backupNext = (channels_0_fifo_pop_withOverride_backup + channels_0_fifo_pop_bytesIncr_value);
  assign _zz_channels_0_fifo_pop_withOverride_exposed = (channels_0_fifo_pop_withOverride_exposed - channels_0_fifo_pop_bytesDecr_value);
  assign _zz_channels_0_pop_b2m_selfFlush = {11'd0, channels_0_fifo_pop_bytes};
  assign _zz_channels_0_pop_b2m_request = {5'd0, channels_0_pop_b2m_bytePerBurst};
  assign _zz_channels_0_pop_b2m_request_2 = (channels_0_fifo_words >>> 1'd1);
  assign _zz_channels_0_pop_b2m_request_1 = {1'd0, _zz_channels_0_pop_b2m_request_2};
  assign _zz_channels_0_pop_b2m_memPending = (channels_0_pop_b2m_memPending + _zz_channels_0_pop_b2m_memPending_1);
  assign _zz_channels_0_pop_b2m_memPending_2 = channels_0_pop_b2m_memPendingInc;
  assign _zz_channels_0_pop_b2m_memPending_1 = {3'd0, _zz_channels_0_pop_b2m_memPending_2};
  assign _zz_channels_0_pop_b2m_memPending_4 = channels_0_pop_b2m_memRsp;
  assign _zz_channels_0_pop_b2m_memPending_3 = {3'd0, _zz_channels_0_pop_b2m_memPending_4};
  assign _zz_channels_0_fifo_push_available = (channels_0_fifo_push_available + channels_0_fifo_pop_ptrIncr_value_regNext);
  assign _zz_channels_1_bytesProbe_value = (channels_1_bytesProbe_value + _zz_channels_1_bytesProbe_value_1);
  assign _zz_channels_1_bytesProbe_value_1 = {16'd0, channels_1_bytesProbe_incr_payload};
  assign _zz_channels_1_fifo_pop_withoutOverride_exposed = (channels_1_fifo_pop_withoutOverride_exposed + channels_1_fifo_pop_bytesIncr_value);
  assign _zz_channels_1_push_m2b_memPending = (channels_1_push_m2b_memPending + _zz_channels_1_push_m2b_memPending_1);
  assign _zz_channels_1_push_m2b_memPending_2 = channels_1_push_m2b_memPendingIncr;
  assign _zz_channels_1_push_m2b_memPending_1 = {3'd0, _zz_channels_1_push_m2b_memPending_2};
  assign _zz_channels_1_push_m2b_memPending_4 = channels_1_push_m2b_memPendingDecr;
  assign _zz_channels_1_push_m2b_memPending_3 = {3'd0, _zz_channels_1_push_m2b_memPending_4};
  assign _zz_channels_1_push_m2b_loadRequest_1 = (channels_1_push_m2b_bytePerBurst >>> 2'd2);
  assign _zz_channels_1_push_m2b_loadRequest = {5'd0, _zz_channels_1_push_m2b_loadRequest_1};
  assign _zz_when_DmaSg_l486 = {15'd0, channels_1_push_m2b_bytePerBurst};
  assign _zz_channels_1_fifo_push_available = (channels_1_fifo_push_available + channels_1_fifo_pop_ptrIncr_value_regNext);
  assign _zz_s2b_0_cmd_byteCount_12 = s2b_0_cmd_sinkHalted_payload_mask[3];
  assign _zz_s2b_0_cmd_byteCount_11 = {2'd0, _zz_s2b_0_cmd_byteCount_12};
  assign _zz__zz_m2b_cmd_s0_priority_chosenOh_2 = (_zz_m2b_cmd_s0_priority_chosenOh_1 - _zz__zz_m2b_cmd_s0_priority_chosenOh_2_1);
  assign _zz__zz_m2b_cmd_s0_priority_chosenOh_2_2 = _zz__zz_m2b_cmd_s0_priority_chosenOh_2_3;
  assign _zz__zz_m2b_cmd_s0_priority_chosenOh_2_1 = {1'd0, _zz__zz_m2b_cmd_s0_priority_chosenOh_2_2};
  assign _zz_m2b_cmd_s0_length = ((_zz_m2b_cmd_s0_length_1 < m2b_cmd_s0_bytesLeft) ? _zz_m2b_cmd_s0_length_2 : m2b_cmd_s0_bytesLeft);
  assign _zz_m2b_cmd_s0_length_1 = {15'd0, m2b_cmd_s0_lengthHead};
  assign _zz_m2b_cmd_s0_length_2 = {15'd0, m2b_cmd_s0_lengthHead};
  assign _zz_m2b_cmd_s0_lastBurst = {15'd0, m2b_cmd_s0_length};
  assign _zz_m2b_cmd_s1_context_stop = (m2b_cmd_s1_address + _zz_m2b_cmd_s1_context_stop_1);
  assign _zz_m2b_cmd_s1_context_stop_1 = {21'd0, m2b_cmd_s1_length};
  assign _zz_m2b_cmd_s1_addressNext = (m2b_cmd_s1_address + _zz_m2b_cmd_s1_addressNext_1);
  assign _zz_m2b_cmd_s1_addressNext_1 = {21'd0, m2b_cmd_s1_length};
  assign _zz_m2b_cmd_s1_byteLeftNext = (m2b_cmd_s1_bytesLeft - _zz_m2b_cmd_s1_byteLeftNext_1);
  assign _zz_m2b_cmd_s1_byteLeftNext_1 = {15'd0, m2b_cmd_s1_length};
  assign _zz_m2b_cmd_s1_fifoPushDecr = ({1'b0,(_zz_m2b_cmd_s1_fifoPushDecr_1 | 11'h007)} + _zz_m2b_cmd_s1_fifoPushDecr_4);
  assign _zz_m2b_cmd_s1_fifoPushDecr_1 = (_zz_m2b_cmd_s1_fifoPushDecr_2 + io_read_cmd_payload_fragment_length);
  assign _zz_m2b_cmd_s1_fifoPushDecr_3 = m2b_cmd_s1_address[2 : 0];
  assign _zz_m2b_cmd_s1_fifoPushDecr_2 = {8'd0, _zz_m2b_cmd_s1_fifoPushDecr_3};
  assign _zz_m2b_cmd_s1_fifoPushDecr_5 = {1'b0,1'b1};
  assign _zz_m2b_cmd_s1_fifoPushDecr_4 = {10'd0, _zz_m2b_cmd_s1_fifoPushDecr_5};
  assign _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2 = (_zz_b2m_fsm_arbiter_logic_priority_chosenOh_1 - _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_1);
  assign _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_2 = _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_3;
  assign _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_1 = {1'd0, _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_2};
  assign _zz_when = 1'b1;
  assign _zz_b2m_fsm_bytesInBurstP1_1 = {1'b0,1'b1};
  assign _zz_b2m_fsm_bytesInBurstP1 = {10'd0, _zz_b2m_fsm_bytesInBurstP1_1};
  assign _zz_b2m_fsm_addressNext = {20'd0, b2m_fsm_bytesInBurstP1};
  assign _zz_b2m_fsm_bytesLeftNext_1 = {1'b0,b2m_fsm_bytesInBurstP1};
  assign _zz_b2m_fsm_bytesLeftNext = {14'd0, _zz_b2m_fsm_bytesLeftNext_1};
  assign _zz__zz_b2m_fsm_sel_bytesInBurst_1 = {10'd0, _zz_b2m_fsm_sel_bytesInBurst};
  assign _zz__zz_b2m_fsm_sel_bytesInBurst_1_1 = {10'd0, _zz_b2m_fsm_sel_bytesInBurst};
  assign _zz__zz_b2m_fsm_sel_bytesInBurst_2 = b2m_fsm_sel_address[10:0];
  assign _zz_b2m_fsm_sel_bytesInBurst_3 = ((_zz_b2m_fsm_sel_bytesInBurst_1 < _zz_b2m_fsm_sel_bytesInBurst_4) ? _zz_b2m_fsm_sel_bytesInBurst_1 : _zz_b2m_fsm_sel_bytesInBurst_5);
  assign _zz_b2m_fsm_sel_bytesInBurst_4 = {15'd0, _zz_b2m_fsm_sel_bytesInBurst_2};
  assign _zz_b2m_fsm_sel_bytesInBurst_5 = {15'd0, _zz_b2m_fsm_sel_bytesInBurst_2};
  assign _zz_b2m_fsm_fifoCompletion = {5'd0, b2m_fsm_sel_bytesInBurst};
  assign _zz_b2m_fsm_fifoCompletion_1 = (b2m_fsm_sel_bytesInFifo - 16'h0001);
  assign _zz_b2m_fsm_beatCounter = (_zz_b2m_fsm_beatCounter_1 + b2m_fsm_sel_bytesInBurst);
  assign _zz_b2m_fsm_beatCounter_2 = b2m_fsm_sel_address[2 : 0];
  assign _zz_b2m_fsm_beatCounter_1 = {8'd0, _zz_b2m_fsm_beatCounter_2};
  assign _zz_b2m_fsm_sel_ptr = (b2m_fsm_sel_ptr + 14'h0002);
  assign _zz_b2m_fsm_cmd_maskLastTriggerComb = b2m_fsm_sel_bytesInBurst[2:0];
  assign _zz_when_1 = 1'b1;
  assign _zz_when_2 = 1'b1;
  assign _zz__zz_ll_arbiter_head_1 = (_zz_ll_arbiter_head & (~ _zz__zz_ll_arbiter_head_1_1));
  assign _zz__zz_ll_arbiter_head_1_1 = (_zz_ll_arbiter_head - 2'b01);
  assign _zz_ll_arbiter_head_2 = {_zz_ll_arbiter_head_1,channels_0_ll_requestLl};
  assign _zz_ll_arbiter_isJustASink = {_zz_ll_arbiter_head_1,channels_0_ll_requestLl};
  assign _zz_ll_arbiter_doDescriptorStall = {_zz_ll_arbiter_head_1,channels_0_ll_requestLl};
  assign _zz_ll_arbiter_onSgStream = {_zz_ll_arbiter_head_1,channels_0_ll_requestLl};
  assign _zz_ll_cmd_ptr = {_zz_ll_arbiter_head_1,channels_0_ll_requestLl};
  assign _zz_ll_cmd_ptrNext = {_zz_ll_arbiter_head_1,channels_0_ll_requestLl};
  assign _zz_ll_cmd_endOfPacket = {_zz_ll_arbiter_head_1,channels_0_ll_requestLl};
  assign _zz_channels_0_channelStart = 1'b1;
  assign _zz_channels_0_ctrl_kick = 1'b1;
  assign _zz_channels_0_channelStart_1 = 1'b1;
  assign _zz_channels_0_ll_sgStart = 1'b1;
  assign _zz_channels_0_interrupts_completion_valid = 1'b0;
  assign _zz_channels_0_interrupts_onChannelCompletion_valid = 1'b0;
  assign _zz_channels_0_interrupts_onLinkedListUpdate_valid = 1'b0;
  assign _zz_channels_0_interrupts_s2mPacket_valid = 1'b0;
  assign _zz_channels_1_channelStart = 1'b1;
  assign _zz_channels_1_ctrl_kick = 1'b1;
  assign _zz_channels_1_channelStart_1 = 1'b1;
  assign _zz_channels_1_ll_sgStart = 1'b1;
  assign _zz_channels_1_interrupts_completion_valid = 1'b0;
  assign _zz_channels_1_interrupts_onChannelCompletion_valid = 1'b0;
  assign _zz_channels_1_interrupts_onLinkedListUpdate_valid = 1'b0;
  assign _zz_io_ctrl_PRDATA = channels_0_ll_ptr;
  assign _zz_io_ctrl_PRDATA_1 = channels_1_ll_ptr;
  assign _zz_channels_0_fifo_push_ptrIncr_value_1 = ((when_DmaSg_l665 && (|s2b_0_cmd_sinkHalted_payload_mask)) ? 1'b1 : 1'b0);
  assign _zz_channels_0_fifo_push_ptrIncr_value = {13'd0, _zz_channels_0_fifo_push_ptrIncr_value_1};
  assign _zz_channels_0_fifo_pop_bytesIncr_value_2 = (_zz_channels_0_fifo_pop_bytesIncr_value ? s2b_0_rsp_context_bytes : 3'b000);
  assign _zz_channels_0_fifo_pop_bytesIncr_value_1 = {13'd0, _zz_channels_0_fifo_pop_bytesIncr_value_2};
  assign _zz_channels_0_fifo_pop_ptrIncr_value_1 = ((b2m_fsm_cmd_doPtrIncr && 1'b1) ? 2'b10 : 2'b00);
  assign _zz_channels_0_fifo_pop_ptrIncr_value = {12'd0, _zz_channels_0_fifo_pop_ptrIncr_value_1};
  assign _zz_channels_1_fifo_push_ptrIncr_value_2 = (_zz_channels_1_fifo_push_ptrIncr_value ? 2'b10 : 2'b00);
  assign _zz_channels_1_fifo_push_ptrIncr_value_1 = {12'd0, _zz_channels_1_fifo_push_ptrIncr_value_2};
  assign _zz_channels_1_fifo_pop_bytesIncr_value_2 = (_zz_channels_1_fifo_pop_bytesIncr_value ? _zz_channels_1_fifo_pop_bytesIncr_value_3 : 4'b0000);
  assign _zz_channels_1_fifo_pop_bytesIncr_value_1 = {12'd0, _zz_channels_1_fifo_pop_bytesIncr_value_2};
  assign _zz_channels_1_fifo_pop_bytesIncr_value_3 = (m2b_writeRsp_context_loadByteInNextBeat + 4'b0001);
  assign _zz_channels_1_fifo_pop_ptrIncr_value_1 = ((b2s_0_cmd_channelsOh[0] && memory_core_io_reads_0_cmd_ready) ? 1'b1 : 1'b0);
  assign _zz_channels_1_fifo_pop_ptrIncr_value = {13'd0, _zz_channels_1_fifo_pop_ptrIncr_value_1};
  assign _zz_s2b_0_cmd_byteCount_9 = {s2b_0_cmd_sinkHalted_payload_mask[2],{s2b_0_cmd_sinkHalted_payload_mask[1],s2b_0_cmd_sinkHalted_payload_mask[0]}};
  assign _zz_s2b_0_cmd_firsts = io_inputs_0_payload_last_regNextWhen_5;
  assign _zz_s2b_0_cmd_firsts_1 = {io_inputs_0_payload_last_regNextWhen_4,{io_inputs_0_payload_last_regNextWhen_3,{io_inputs_0_payload_last_regNextWhen_2,{io_inputs_0_payload_last_regNextWhen_1,io_inputs_0_payload_last_regNextWhen}}}};
  assign _zz_b2m_fsm_aggregate_bytesToSkipMask = 3'b101;
  assign _zz_b2m_fsm_aggregate_bytesToSkipMask_1 = (! b2m_fsm_aggregate_first);
  assign _zz_b2m_fsm_aggregate_bytesToSkipMask_2 = (b2m_fsm_aggregate_bytesToSkip <= 3'b100);
  assign _zz_b2m_fsm_aggregate_bytesToSkipMask_3 = ((! b2m_fsm_aggregate_first) || (b2m_fsm_aggregate_bytesToSkip <= 3'b011));
  assign _zz_b2m_fsm_aggregate_bytesToSkipMask_4 = ((! b2m_fsm_aggregate_first) || (b2m_fsm_aggregate_bytesToSkip <= 3'b010));
  assign _zz_b2m_fsm_aggregate_bytesToSkipMask_5 = {((! b2m_fsm_aggregate_first) || (b2m_fsm_aggregate_bytesToSkip <= 3'b001)),((! b2m_fsm_aggregate_first) || (b2m_fsm_aggregate_bytesToSkip <= 3'b000))};
  assign _zz_b2m_fsm_cmd_maskLast = 3'b010;
  assign _zz_b2m_fsm_cmd_maskLast_1 = (3'b001 <= b2m_fsm_cmd_maskLastTriggerComb);
  assign _zz_b2m_fsm_cmd_maskLast_2 = (3'b000 <= b2m_fsm_cmd_maskLastTriggerComb);
  assign _zz_b2m_fsm_cmd_maskFirst = 3'b010;
  assign _zz_b2m_fsm_cmd_maskFirst_1 = (b2m_fsm_cmd_maskFirstTrigger <= 3'b001);
  assign _zz_b2m_fsm_cmd_maskFirst_2 = (b2m_fsm_cmd_maskFirstTrigger <= 3'b000);
  EfxDMA_DmaMemoryCore memory_core (
    .io_writes_0_cmd_valid            (s2b_0_cmd_sinkHalted_valid                       ), //i
    .io_writes_0_cmd_ready            (memory_core_io_writes_0_cmd_ready                ), //o
    .io_writes_0_cmd_payload_address  (memory_core_io_writes_0_cmd_payload_address[12:0]), //i
    .io_writes_0_cmd_payload_data     (s2b_0_cmd_sinkHalted_payload_data[31:0]          ), //i
    .io_writes_0_cmd_payload_mask     (s2b_0_cmd_sinkHalted_payload_mask[3:0]           ), //i
    .io_writes_0_cmd_payload_priority (channels_0_priority[1:0]                         ), //i
    .io_writes_0_cmd_payload_context  (memory_core_io_writes_0_cmd_payload_context[5:0] ), //i
    .io_writes_0_rsp_valid            (memory_core_io_writes_0_rsp_valid                ), //o
    .io_writes_0_rsp_payload_context  (memory_core_io_writes_0_rsp_payload_context[5:0] ), //o
    .io_writes_1_cmd_valid            (io_read_rsp_valid                                ), //i
    .io_writes_1_cmd_ready            (memory_core_io_writes_1_cmd_ready                ), //o
    .io_writes_1_cmd_payload_address  (memory_core_io_writes_1_cmd_payload_address[12:0]), //i
    .io_writes_1_cmd_payload_data     (io_read_rsp_payload_fragment_data[63:0]          ), //i
    .io_writes_1_cmd_payload_mask     (memory_core_io_writes_1_cmd_payload_mask[7:0]    ), //i
    .io_writes_1_cmd_payload_context  (memory_core_io_writes_1_cmd_payload_context[5:0] ), //i
    .io_writes_1_rsp_valid            (memory_core_io_writes_1_rsp_valid                ), //o
    .io_writes_1_rsp_payload_context  (memory_core_io_writes_1_rsp_payload_context[5:0] ), //o
    .io_reads_0_cmd_valid             (memory_core_io_reads_0_cmd_valid                 ), //i
    .io_reads_0_cmd_ready             (memory_core_io_reads_0_cmd_ready                 ), //o
    .io_reads_0_cmd_payload_address   (memory_core_io_reads_0_cmd_payload_address[12:0] ), //i
    .io_reads_0_cmd_payload_priority  (channels_1_priority[1:0]                         ), //i
    .io_reads_0_cmd_payload_context   (memory_core_io_reads_0_cmd_payload_context[2:0]  ), //i
    .io_reads_0_rsp_valid             (memory_core_io_reads_0_rsp_valid                 ), //o
    .io_reads_0_rsp_ready             (io_outputs_0_ready                               ), //i
    .io_reads_0_rsp_payload_data      (memory_core_io_reads_0_rsp_payload_data[31:0]    ), //o
    .io_reads_0_rsp_payload_mask      (memory_core_io_reads_0_rsp_payload_mask[3:0]     ), //o
    .io_reads_0_rsp_payload_context   (memory_core_io_reads_0_rsp_payload_context[2:0]  ), //o
    .io_reads_1_cmd_valid             (b2m_fsm_sel_valid                                ), //i
    .io_reads_1_cmd_ready             (memory_core_io_reads_1_cmd_ready                 ), //o
    .io_reads_1_cmd_payload_address   (memory_core_io_reads_1_cmd_payload_address[12:0] ), //i
    .io_reads_1_cmd_payload_context   (memory_core_io_reads_1_cmd_payload_context[14:0] ), //i
    .io_reads_1_rsp_valid             (memory_core_io_reads_1_rsp_valid                 ), //o
    .io_reads_1_rsp_ready             (memory_core_io_reads_1_rsp_rValidN               ), //i
    .io_reads_1_rsp_payload_data      (memory_core_io_reads_1_rsp_payload_data[63:0]    ), //o
    .io_reads_1_rsp_payload_mask      (memory_core_io_reads_1_rsp_payload_mask[7:0]     ), //o
    .io_reads_1_rsp_payload_context   (memory_core_io_reads_1_rsp_payload_context[14:0] ), //o
    .clk                              (clk                                              ), //i
    .reset                            (reset                                            )  //i
  );
  EfxDMA_Aggregator b2m_fsm_aggregate_engine (
    .io_input_valid         (b2m_fsm_aggregate_memoryPort_valid                 ), //i
    .io_input_ready         (b2m_fsm_aggregate_engine_io_input_ready            ), //o
    .io_input_payload_data  (b2m_fsm_aggregate_memoryPort_payload_data[63:0]    ), //i
    .io_input_payload_mask  (b2m_fsm_aggregate_engine_io_input_payload_mask[7:0]), //i
    .io_output_data         (b2m_fsm_aggregate_engine_io_output_data[63:0]      ), //o
    .io_output_mask         (b2m_fsm_aggregate_engine_io_output_mask[7:0]       ), //o
    .io_output_enough       (b2m_fsm_cmd_enoughAggregation                      ), //i
    .io_output_consume      (io_write_cmd_fire                                  ), //i
    .io_output_consumed     (b2m_fsm_aggregate_engine_io_output_consumed        ), //o
    .io_output_lastByteUsed (b2m_fsm_cmd_maskLastTriggerReg[2:0]                ), //i
    .io_output_usedUntil    (b2m_fsm_aggregate_engine_io_output_usedUntil[2:0]  ), //o
    .io_flush               (b2m_fsm_aggregate_engine_io_flush                  ), //i
    .io_offset              (b2m_fsm_aggregate_engine_io_offset[2:0]            ), //i
    .io_burstLength         (b2m_fsm_sel_bytesInBurst[10:0]                     ), //i
    .clk                    (clk                                                ), //i
    .reset                  (reset                                              )  //i
  );
  always @(*) begin
    case(_zz_s2b_0_cmd_byteCount_9)
      3'b000 : _zz_s2b_0_cmd_byteCount_8 = _zz_s2b_0_cmd_byteCount;
      3'b001 : _zz_s2b_0_cmd_byteCount_8 = _zz_s2b_0_cmd_byteCount_1;
      3'b010 : _zz_s2b_0_cmd_byteCount_8 = _zz_s2b_0_cmd_byteCount_2;
      3'b011 : _zz_s2b_0_cmd_byteCount_8 = _zz_s2b_0_cmd_byteCount_3;
      3'b100 : _zz_s2b_0_cmd_byteCount_8 = _zz_s2b_0_cmd_byteCount_4;
      3'b101 : _zz_s2b_0_cmd_byteCount_8 = _zz_s2b_0_cmd_byteCount_5;
      3'b110 : _zz_s2b_0_cmd_byteCount_8 = _zz_s2b_0_cmd_byteCount_6;
      default : _zz_s2b_0_cmd_byteCount_8 = _zz_s2b_0_cmd_byteCount_7;
    endcase
  end

  always @(*) begin
    case(_zz_s2b_0_cmd_byteCount_11)
      3'b000 : _zz_s2b_0_cmd_byteCount_10 = _zz_s2b_0_cmd_byteCount;
      3'b001 : _zz_s2b_0_cmd_byteCount_10 = _zz_s2b_0_cmd_byteCount_1;
      3'b010 : _zz_s2b_0_cmd_byteCount_10 = _zz_s2b_0_cmd_byteCount_2;
      3'b011 : _zz_s2b_0_cmd_byteCount_10 = _zz_s2b_0_cmd_byteCount_3;
      3'b100 : _zz_s2b_0_cmd_byteCount_10 = _zz_s2b_0_cmd_byteCount_4;
      3'b101 : _zz_s2b_0_cmd_byteCount_10 = _zz_s2b_0_cmd_byteCount_5;
      3'b110 : _zz_s2b_0_cmd_byteCount_10 = _zz_s2b_0_cmd_byteCount_6;
      default : _zz_s2b_0_cmd_byteCount_10 = _zz_s2b_0_cmd_byteCount_7;
    endcase
  end

  always @(*) begin
    case(_zz_m2b_cmd_s0_priority_masked)
      2'b00 : _zz__zz_m2b_cmd_s0_priority_chosenOh_2_3 = m2b_cmd_s0_priority_roundRobins_0;
      2'b01 : _zz__zz_m2b_cmd_s0_priority_chosenOh_2_3 = m2b_cmd_s0_priority_roundRobins_1;
      2'b10 : _zz__zz_m2b_cmd_s0_priority_chosenOh_2_3 = m2b_cmd_s0_priority_roundRobins_2;
      default : _zz__zz_m2b_cmd_s0_priority_chosenOh_2_3 = m2b_cmd_s0_priority_roundRobins_3;
    endcase
  end

  always @(*) begin
    case(_zz_b2m_fsm_arbiter_logic_priority_masked)
      2'b00 : _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_3 = b2m_fsm_arbiter_logic_priority_roundRobins_0;
      2'b01 : _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_3 = b2m_fsm_arbiter_logic_priority_roundRobins_1;
      2'b10 : _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_3 = b2m_fsm_arbiter_logic_priority_roundRobins_2;
      default : _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2_3 = b2m_fsm_arbiter_logic_priority_roundRobins_3;
    endcase
  end

  assign ctrl_readErrorFlag = 1'b0;
  assign ctrl_writeErrorFlag = 1'b0;
  assign io_ctrl_PREADY = 1'b1;
  always @(*) begin
    io_ctrl_PRDATA = 32'h0;
    case(io_ctrl_PADDR)
      14'h002c : begin
        io_ctrl_PRDATA[0 : 0] = channels_0_channelValid;
      end
      14'h0054 : begin
        io_ctrl_PRDATA[0 : 0] = channels_0_interrupts_completion_valid;
        io_ctrl_PRDATA[2 : 2] = channels_0_interrupts_onChannelCompletion_valid;
        io_ctrl_PRDATA[3 : 3] = channels_0_interrupts_onLinkedListUpdate_valid;
        io_ctrl_PRDATA[4 : 4] = channels_0_interrupts_s2mPacket_valid;
      end
      14'h0060 : begin
        io_ctrl_PRDATA[26 : 0] = channels_0_bytesProbe_value;
      end
      14'h00ac : begin
        io_ctrl_PRDATA[0 : 0] = channels_1_channelValid;
      end
      14'h00d4 : begin
        io_ctrl_PRDATA[0 : 0] = channels_1_interrupts_completion_valid;
        io_ctrl_PRDATA[2 : 2] = channels_1_interrupts_onChannelCompletion_valid;
        io_ctrl_PRDATA[3 : 3] = channels_1_interrupts_onLinkedListUpdate_valid;
      end
      14'h00e0 : begin
        io_ctrl_PRDATA[26 : 0] = channels_1_bytesProbe_value;
      end
      default : begin
      end
    endcase
    if(when_Apb3SlaveFactory_l81_1) begin
      io_ctrl_PRDATA[31 : 0] = _zz_io_ctrl_PRDATA[31 : 0];
    end
    if(when_Apb3SlaveFactory_l81_3) begin
      io_ctrl_PRDATA[31 : 0] = _zz_io_ctrl_PRDATA_1[31 : 0];
    end
  end

  assign ctrl_askWrite = ((io_ctrl_PSEL[0] && io_ctrl_PENABLE) && io_ctrl_PWRITE);
  assign ctrl_askRead = ((io_ctrl_PSEL[0] && io_ctrl_PENABLE) && (! io_ctrl_PWRITE));
  assign ctrl_doWrite = (((io_ctrl_PSEL[0] && io_ctrl_PENABLE) && io_ctrl_PREADY) && io_ctrl_PWRITE);
  assign ctrl_doRead = (((io_ctrl_PSEL[0] && io_ctrl_PENABLE) && io_ctrl_PREADY) && (! io_ctrl_PWRITE));
  assign io_ctrl_PSLVERROR = ((ctrl_doWrite && ctrl_writeErrorFlag) || (ctrl_doRead && ctrl_readErrorFlag));
  always @(*) begin
    channels_0_channelStart = 1'b0;
    if(when_BusSlaveFactory_l377) begin
      if(when_BusSlaveFactory_l379) begin
        channels_0_channelStart = _zz_channels_0_channelStart[0];
      end
    end
    if(when_BusSlaveFactory_l377_2) begin
      if(when_BusSlaveFactory_l379_2) begin
        channels_0_channelStart = _zz_channels_0_channelStart_1[0];
      end
    end
  end

  always @(*) begin
    channels_0_channelCompletion = 1'b0;
    if(channels_0_channelValid) begin
      if(channels_0_channelStop) begin
        if(channels_0_readyToStop) begin
          channels_0_channelCompletion = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    channels_0_descriptorStart = 1'b0;
    if(channels_0_ctrl_kick) begin
      channels_0_descriptorStart = 1'b1;
    end
    if(when_DmaSg_l318) begin
      if(when_DmaSg_l320) begin
        if(when_DmaSg_l322) begin
          channels_0_descriptorStart = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    channels_0_descriptorCompletion = 1'b0;
    if(channels_0_pop_b2m_packetSync) begin
      if(when_DmaSg_l532) begin
        if(channels_0_push_s2b_completionOnLast) begin
          channels_0_descriptorCompletion = 1'b1;
        end
      end
    end
    if(when_DmaSg_l547) begin
      channels_0_descriptorCompletion = 1'b1;
    end
    if(channels_0_channelValid) begin
      if(channels_0_channelStop) begin
        if(channels_0_readyToStop) begin
          channels_0_descriptorCompletion = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    channels_0_readyToStop = 1'b1;
    if(channels_0_ll_waitDone) begin
      channels_0_readyToStop = 1'b0;
    end
    if(when_DmaSg_l563) begin
      channels_0_readyToStop = 1'b0;
    end
  end

  always @(*) begin
    channels_0_bytesProbe_incr_valid = 1'b0;
    if(io_write_rsp_fire) begin
      if(when_DmaSg_l1116) begin
        channels_0_bytesProbe_incr_valid = 1'b1;
      end
    end
  end

  always @(*) begin
    channels_0_bytesProbe_incr_payload = 11'bxxxxxxxxxxx;
    if(io_write_rsp_fire) begin
      if(when_DmaSg_l1116) begin
        channels_0_bytesProbe_incr_payload = b2m_rsp_context_length;
      end
    end
  end

  always @(*) begin
    channels_0_ll_sgStart = 1'b0;
    if(when_BusSlaveFactory_l377_3) begin
      if(when_BusSlaveFactory_l379_3) begin
        channels_0_ll_sgStart = _zz_channels_0_ll_sgStart[0];
      end
    end
  end

  assign channels_0_ll_requestLl = ((((channels_0_channelValid && channels_0_ll_valid) && (! channels_0_channelStop)) && (! channels_0_ll_waitDone)) && ((! channels_0_descriptorValid) || channels_0_ll_requireSync));
  always @(*) begin
    channels_0_ll_descriptorUpdated = 1'b0;
    if(when_DmaSg_l318) begin
      if(when_DmaSg_l328) begin
        channels_0_ll_descriptorUpdated = 1'b1;
      end
    end
  end

  assign when_DmaSg_l318 = (((channels_0_ll_valid && channels_0_ll_waitDone) && channels_0_ll_writeDone) && channels_0_ll_readDone);
  assign when_DmaSg_l320 = (! channels_0_ll_justASync);
  assign when_DmaSg_l322 = (! channels_0_ll_gotDescriptorStall);
  assign when_DmaSg_l328 = (! channels_0_ll_head);
  assign channels_0_fifo_base = 14'h0;
  assign channels_0_fifo_words = 14'h0fff;
  assign channels_0_fifo_push_availableDecr = 14'h0;
  assign channels_0_fifo_push_ptrWithBase = ((channels_0_fifo_base & (~ channels_0_fifo_words)) | (channels_0_fifo_push_ptr & channels_0_fifo_words));
  assign channels_0_fifo_pop_ptrWithBase = ((channels_0_fifo_base & (~ channels_0_fifo_words)) | (channels_0_fifo_pop_ptr & channels_0_fifo_words));
  assign channels_0_fifo_pop_empty = (channels_0_fifo_pop_ptr == channels_0_fifo_push_ptr);
  assign channels_0_fifo_pop_withOverride_backupNext = (_zz_channels_0_fifo_pop_withOverride_backupNext - channels_0_fifo_pop_bytesDecr_value);
  always @(*) begin
    channels_0_fifo_pop_withOverride_load = 1'b0;
    if(when_DmaSg_l457) begin
      channels_0_fifo_pop_withOverride_load = 1'b1;
    end
  end

  always @(*) begin
    channels_0_fifo_pop_withOverride_unload = 1'b0;
    if(channels_0_pop_b2m_packetSync) begin
      channels_0_fifo_pop_withOverride_unload = 1'b1;
    end
  end

  assign when_DmaSg_l409 = (channels_0_channelStart || channels_0_fifo_pop_withOverride_unload);
  assign channels_0_fifo_pop_bytes = channels_0_fifo_pop_withOverride_exposed;
  assign channels_0_fifo_empty = (channels_0_fifo_push_ptr == channels_0_fifo_pop_ptr);
  always @(*) begin
    channels_0_push_s2b_packetEvent = 1'b0;
    if(when_DmaSg_l679) begin
      channels_0_push_s2b_packetEvent = 1'b1;
    end
  end

  assign when_DmaSg_l457 = (channels_0_push_s2b_packetEvent && channels_0_push_s2b_completionOnLast);
  assign channels_0_pop_b2m_bytePerBurst = 11'h3ff;
  always @(*) begin
    channels_0_pop_b2m_fire = 1'b0;
    if(when_DmaSg_l935) begin
      if(_zz_when[0]) begin
        channels_0_pop_b2m_fire = 1'b1;
      end
    end
  end

  always @(*) begin
    channels_0_pop_b2m_packetSync = 1'b0;
    if(when_DmaSg_l523) begin
      if(channels_0_pop_b2m_packet) begin
        channels_0_pop_b2m_packetSync = 1'b1;
      end
    end
    if(io_write_rsp_fire) begin
      if(when_DmaSg_l1116) begin
        if(b2m_rsp_context_doPacketSync) begin
          channels_0_pop_b2m_packetSync = 1'b1;
        end
      end
    end
  end

  assign when_DmaSg_l505 = (channels_0_channelStart || channels_0_pop_b2m_fire);
  always @(*) begin
    channels_0_pop_b2m_memRsp = 1'b0;
    if(io_write_rsp_fire) begin
      if(_zz_when_2[0]) begin
        channels_0_pop_b2m_memRsp = 1'b1;
      end
    end
  end

  assign channels_0_pop_b2m_selfFlush = (channels_0_pop_b2m_bytesLeft < _zz_channels_0_pop_b2m_selfFlush);
  assign channels_0_pop_b2m_request = ((((((channels_0_descriptorValid && (! channels_0_channelStop)) && (! channels_0_pop_b2m_waitFinalRsp)) && channels_0_pop_memory) && ((_zz_channels_0_pop_b2m_request < channels_0_fifo_pop_bytes) || (((channels_0_fifo_push_available < _zz_channels_0_pop_b2m_request_1) || channels_0_pop_b2m_flush) || channels_0_pop_b2m_selfFlush))) && (channels_0_fifo_pop_bytes != 16'h0)) && (channels_0_pop_b2m_memPending != 4'b1111));
  always @(*) begin
    channels_0_pop_b2m_memPendingInc = 1'b0;
    if(when_DmaSg_l758_1) begin
      if(when_DmaSg_l773_1) begin
        channels_0_pop_b2m_memPendingInc = 1'b1;
      end
    end
  end

  always @(*) begin
    channels_0_pop_b2m_decrBytes = 16'h0;
    if(b2m_fsm_s1) begin
      if(when_DmaSg_l996) begin
        channels_0_pop_b2m_decrBytes = {4'd0, b2m_fsm_bytesInBurstP1};
      end
    end
  end

  assign when_DmaSg_l523 = ((channels_0_pop_b2m_memPending == 4'b0000) && (channels_0_fifo_pop_bytes == 16'h0));
  assign when_DmaSg_l532 = (channels_0_descriptorValid && (! channels_0_push_memory));
  assign when_DmaSg_l536 = (! channels_0_pop_b2m_waitFinalRsp);
  assign when_DmaSg_l547 = ((channels_0_descriptorValid && (channels_0_pop_b2m_memPending == 4'b0000)) && channels_0_pop_b2m_waitFinalRsp);
  assign when_DmaSg_l563 = (channels_0_pop_b2m_memPending != 4'b0000);
  assign channels_0_readyForChannelCompletion = 1'b1;
  assign when_DmaSg_l575 = (! channels_0_descriptorValid);
  always @(*) begin
    _zz_when_DmaSg_l593 = 1'b1;
    if(channels_0_ctrl_kick) begin
      _zz_when_DmaSg_l593 = 1'b0;
    end
    if(channels_0_ll_valid) begin
      _zz_when_DmaSg_l593 = 1'b0;
    end
  end

  assign when_DmaSg_l593 = (_zz_when_DmaSg_l593 && channels_0_readyForChannelCompletion);
  assign channels_0_s2b_full = (channels_0_fifo_push_available < 14'h0002);
  assign when_DmaSg_l255 = (channels_0_descriptorValid && channels_0_descriptorCompletion);
  assign when_DmaSg_l255_1 = (! channels_0_interrupts_completion_enable);
  assign when_DmaSg_l255_2 = (channels_0_channelValid && channels_0_channelCompletion);
  assign when_DmaSg_l255_3 = (! channels_0_interrupts_onChannelCompletion_enable);
  assign when_DmaSg_l255_4 = (! channels_0_interrupts_onLinkedListUpdate_enable);
  assign when_DmaSg_l255_5 = (! channels_0_interrupts_s2mPacket_enable);
  assign when_DmaSg_l625 = (channels_0_channelStart || channels_0_descriptorStart);
  always @(*) begin
    channels_1_channelStart = 1'b0;
    if(when_BusSlaveFactory_l377_4) begin
      if(when_BusSlaveFactory_l379_4) begin
        channels_1_channelStart = _zz_channels_1_channelStart[0];
      end
    end
    if(when_BusSlaveFactory_l377_6) begin
      if(when_BusSlaveFactory_l379_6) begin
        channels_1_channelStart = _zz_channels_1_channelStart_1[0];
      end
    end
  end

  always @(*) begin
    channels_1_channelCompletion = 1'b0;
    if(channels_1_channelValid) begin
      if(channels_1_channelStop) begin
        if(channels_1_readyToStop) begin
          channels_1_channelCompletion = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    channels_1_descriptorStart = 1'b0;
    if(channels_1_ctrl_kick) begin
      channels_1_descriptorStart = 1'b1;
    end
    if(when_DmaSg_l318_1) begin
      if(when_DmaSg_l320_1) begin
        if(when_DmaSg_l322_1) begin
          channels_1_descriptorStart = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    channels_1_descriptorCompletion = 1'b0;
    if(when_DmaSg_l483) begin
      channels_1_descriptorCompletion = 1'b1;
    end
    if(channels_1_channelValid) begin
      if(channels_1_channelStop) begin
        if(channels_1_readyToStop) begin
          channels_1_descriptorCompletion = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    channels_1_readyToStop = 1'b1;
    if(channels_1_ll_waitDone) begin
      channels_1_readyToStop = 1'b0;
    end
    if(when_DmaSg_l562) begin
      channels_1_readyToStop = 1'b0;
    end
  end

  always @(*) begin
    channels_1_bytesProbe_incr_valid = 1'b0;
    if(when_DmaSg_l874) begin
      channels_1_bytesProbe_incr_valid = 1'b1;
    end
  end

  always @(*) begin
    channels_1_bytesProbe_incr_payload = 11'bxxxxxxxxxxx;
    if(when_DmaSg_l874) begin
      channels_1_bytesProbe_incr_payload = m2b_rsp_context_length;
    end
  end

  always @(*) begin
    channels_1_ll_sgStart = 1'b0;
    if(when_BusSlaveFactory_l377_7) begin
      if(when_BusSlaveFactory_l379_7) begin
        channels_1_ll_sgStart = _zz_channels_1_ll_sgStart[0];
      end
    end
  end

  assign channels_1_ll_requestLl = ((((channels_1_channelValid && channels_1_ll_valid) && (! channels_1_channelStop)) && (! channels_1_ll_waitDone)) && ((! channels_1_descriptorValid) || channels_1_ll_requireSync));
  always @(*) begin
    channels_1_ll_descriptorUpdated = 1'b0;
    if(when_DmaSg_l318_1) begin
      if(when_DmaSg_l328_1) begin
        channels_1_ll_descriptorUpdated = 1'b1;
      end
    end
  end

  assign when_DmaSg_l318_1 = (((channels_1_ll_valid && channels_1_ll_waitDone) && channels_1_ll_writeDone) && channels_1_ll_readDone);
  assign when_DmaSg_l320_1 = (! channels_1_ll_justASync);
  assign when_DmaSg_l322_1 = (! channels_1_ll_gotDescriptorStall);
  assign when_DmaSg_l328_1 = (! channels_1_ll_head);
  assign channels_1_fifo_base = 14'h1000;
  assign channels_1_fifo_words = 14'h0fff;
  always @(*) begin
    channels_1_fifo_push_availableDecr = 14'h0;
    if(m2b_cmd_s1_valid) begin
      if(io_read_cmd_ready) begin
        if(when_DmaSg_l828) begin
          channels_1_fifo_push_availableDecr = {4'd0, m2b_cmd_s1_fifoPushDecr};
        end
      end
    end
  end

  assign channels_1_fifo_push_ptrWithBase = ((channels_1_fifo_base & (~ channels_1_fifo_words)) | (channels_1_fifo_push_ptr & channels_1_fifo_words));
  assign channels_1_fifo_pop_ptrWithBase = ((channels_1_fifo_base & (~ channels_1_fifo_words)) | (channels_1_fifo_pop_ptr & channels_1_fifo_words));
  assign channels_1_fifo_pop_empty = (channels_1_fifo_pop_ptr == channels_1_fifo_push_ptr);
  assign channels_1_fifo_pop_bytes = channels_1_fifo_pop_withoutOverride_exposed;
  assign channels_1_fifo_empty = (channels_1_fifo_push_ptr == channels_1_fifo_pop_ptr);
  assign channels_1_push_m2b_bytePerBurst = 11'h3ff;
  always @(*) begin
    channels_1_push_m2b_memPendingIncr = 1'b0;
    if(when_DmaSg_l758) begin
      if(when_DmaSg_l773) begin
        channels_1_push_m2b_memPendingIncr = 1'b1;
      end
    end
  end

  always @(*) begin
    channels_1_push_m2b_memPendingDecr = 1'b0;
    if(when_DmaSg_l893) begin
      channels_1_push_m2b_memPendingDecr = 1'b1;
    end
  end

  always @(*) begin
    channels_1_push_m2b_loadRequest = (((((channels_1_descriptorValid && (! channels_1_channelStop)) && (! channels_1_push_m2b_loadDone)) && channels_1_push_memory) && (_zz_channels_1_push_m2b_loadRequest < channels_1_fifo_push_available)) && (channels_1_push_m2b_memPending != 4'b1111));
    if(when_DmaSg_l486) begin
      channels_1_push_m2b_loadRequest = 1'b0;
    end
  end

  always @(*) begin
    channels_1_pop_b2s_veryLastTrigger = 1'b0;
    if(when_DmaSg_l847) begin
      if(when_DmaSg_l848) begin
        channels_1_pop_b2s_veryLastTrigger = 1'b1;
      end
    end
  end

  assign when_DmaSg_l474 = (channels_1_pop_b2s_veryLastTrigger && channels_1_pop_b2s_last);
  assign when_DmaSg_l483 = ((((channels_1_descriptorValid && (! channels_1_pop_memory)) && channels_1_push_memory) && channels_1_push_m2b_loadDone) && (channels_1_push_m2b_memPending == 4'b0000));
  assign when_DmaSg_l486 = (((! channels_1_pop_memory) && channels_1_pop_b2s_veryLastValid) && (channels_1_push_m2b_bytesLeft <= _zz_when_DmaSg_l486));
  assign when_DmaSg_l562 = (channels_1_push_m2b_memPending != 4'b0000);
  always @(*) begin
    channels_1_readyForChannelCompletion = 1'b1;
    if(when_DmaSg_l566) begin
      channels_1_readyForChannelCompletion = 1'b0;
    end
  end

  assign when_DmaSg_l566 = ((! channels_1_pop_memory) && (! channels_1_fifo_pop_empty));
  assign when_DmaSg_l575_1 = (! channels_1_descriptorValid);
  always @(*) begin
    _zz_when_DmaSg_l593_1 = 1'b1;
    if(channels_1_ctrl_kick) begin
      _zz_when_DmaSg_l593_1 = 1'b0;
    end
    if(channels_1_ll_valid) begin
      _zz_when_DmaSg_l593_1 = 1'b0;
    end
  end

  assign when_DmaSg_l593_1 = (_zz_when_DmaSg_l593_1 && channels_1_readyForChannelCompletion);
  assign channels_1_s2b_full = (channels_1_fifo_push_available < 14'h0002);
  assign when_DmaSg_l255_6 = (channels_1_descriptorValid && channels_1_descriptorCompletion);
  assign when_DmaSg_l255_7 = (! channels_1_interrupts_completion_enable);
  assign when_DmaSg_l255_8 = (channels_1_channelValid && channels_1_channelCompletion);
  assign when_DmaSg_l255_9 = (! channels_1_interrupts_onChannelCompletion_enable);
  assign when_DmaSg_l255_10 = (! channels_1_interrupts_onLinkedListUpdate_enable);
  assign when_DmaSg_l625_1 = (channels_1_channelStart || channels_1_descriptorStart);
  assign io_inputs_0_fire = (io_inputs_0_valid && io_inputs_0_ready);
  assign when_package_l12 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b0000));
  assign when_package_l12_1 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b0001));
  assign when_package_l12_2 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b0010));
  assign when_package_l12_3 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b0011));
  assign when_package_l12_4 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b0100));
  assign when_package_l12_5 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b0101));
  assign when_package_l12_6 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b0110));
  assign when_package_l12_7 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b0111));
  assign when_package_l12_8 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b1000));
  assign when_package_l12_9 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b1001));
  assign when_package_l12_10 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b1010));
  assign when_package_l12_11 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b1011));
  assign when_package_l12_12 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b1100));
  assign when_package_l12_13 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b1101));
  assign when_package_l12_14 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b1110));
  assign when_package_l12_15 = (io_inputs_0_fire && (io_inputs_0_payload_sink == 4'b1111));
  assign s2b_0_cmd_firsts = {io_inputs_0_payload_last_regNextWhen_15,{io_inputs_0_payload_last_regNextWhen_14,{io_inputs_0_payload_last_regNextWhen_13,{io_inputs_0_payload_last_regNextWhen_12,{io_inputs_0_payload_last_regNextWhen_11,{io_inputs_0_payload_last_regNextWhen_10,{io_inputs_0_payload_last_regNextWhen_9,{io_inputs_0_payload_last_regNextWhen_8,{io_inputs_0_payload_last_regNextWhen_7,{io_inputs_0_payload_last_regNextWhen_6,{_zz_s2b_0_cmd_firsts,_zz_s2b_0_cmd_firsts_1}}}}}}}}}}};
  assign s2b_0_cmd_first = s2b_0_cmd_firsts[io_inputs_0_payload_sink];
  assign s2b_0_cmd_channelsOh = ((((channels_0_channelValid && (s2b_0_cmd_first || (! channels_0_push_s2b_waitFirst))) && (! channels_0_push_memory)) && 1'b1) && (io_inputs_0_payload_sink == 4'b0000));
  assign s2b_0_cmd_noHit = (! (|s2b_0_cmd_channelsOh));
  assign s2b_0_cmd_channelsFull = (channels_0_s2b_full || (channels_0_push_s2b_packetLock && io_inputs_0_payload_last));
  always @(*) begin
    io_inputs_0_thrown_valid = io_inputs_0_valid;
    if(s2b_0_cmd_noHit) begin
      io_inputs_0_thrown_valid = 1'b0;
    end
  end

  always @(*) begin
    io_inputs_0_ready = io_inputs_0_thrown_ready;
    if(s2b_0_cmd_noHit) begin
      io_inputs_0_ready = 1'b1;
    end
  end

  assign io_inputs_0_thrown_payload_data = io_inputs_0_payload_data;
  assign io_inputs_0_thrown_payload_mask = io_inputs_0_payload_mask;
  assign io_inputs_0_thrown_payload_sink = io_inputs_0_payload_sink;
  assign io_inputs_0_thrown_payload_last = io_inputs_0_payload_last;
  assign _zz_io_inputs_0_thrown_ready = (! (|(s2b_0_cmd_channelsOh & s2b_0_cmd_channelsFull)));
  assign s2b_0_cmd_sinkHalted_valid = (io_inputs_0_thrown_valid && _zz_io_inputs_0_thrown_ready);
  assign io_inputs_0_thrown_ready = (s2b_0_cmd_sinkHalted_ready && _zz_io_inputs_0_thrown_ready);
  assign s2b_0_cmd_sinkHalted_payload_data = io_inputs_0_thrown_payload_data;
  assign s2b_0_cmd_sinkHalted_payload_mask = io_inputs_0_thrown_payload_mask;
  assign s2b_0_cmd_sinkHalted_payload_sink = io_inputs_0_thrown_payload_sink;
  assign s2b_0_cmd_sinkHalted_payload_last = io_inputs_0_thrown_payload_last;
  assign _zz_s2b_0_cmd_byteCount = 3'b000;
  assign _zz_s2b_0_cmd_byteCount_1 = 3'b001;
  assign _zz_s2b_0_cmd_byteCount_2 = 3'b001;
  assign _zz_s2b_0_cmd_byteCount_3 = 3'b010;
  assign _zz_s2b_0_cmd_byteCount_4 = 3'b001;
  assign _zz_s2b_0_cmd_byteCount_5 = 3'b010;
  assign _zz_s2b_0_cmd_byteCount_6 = 3'b010;
  assign _zz_s2b_0_cmd_byteCount_7 = 3'b011;
  assign s2b_0_cmd_byteCount = (_zz_s2b_0_cmd_byteCount_8 + _zz_s2b_0_cmd_byteCount_10);
  assign s2b_0_cmd_context_channel = s2b_0_cmd_channelsOh;
  assign s2b_0_cmd_context_bytes = s2b_0_cmd_byteCount;
  assign s2b_0_cmd_context_flush = io_inputs_0_payload_last;
  assign s2b_0_cmd_context_packet = io_inputs_0_payload_last;
  assign s2b_0_cmd_sinkHalted_ready = memory_core_io_writes_0_cmd_ready;
  assign memory_core_io_writes_0_cmd_payload_address = channels_0_fifo_push_ptrWithBase[12:0];
  assign memory_core_io_writes_0_cmd_payload_context = {s2b_0_cmd_context_packet,{s2b_0_cmd_context_flush,{s2b_0_cmd_context_bytes,s2b_0_cmd_context_channel}}};
  assign memory_core_io_writes_0_cmd_fire = (s2b_0_cmd_sinkHalted_valid && memory_core_io_writes_0_cmd_ready);
  assign when_DmaSg_l665 = (s2b_0_cmd_channelsOh[0] && memory_core_io_writes_0_cmd_fire);
  assign _zz_s2b_0_rsp_context_channel = memory_core_io_writes_0_rsp_payload_context;
  assign s2b_0_rsp_context_channel = _zz_s2b_0_rsp_context_channel[0 : 0];
  assign s2b_0_rsp_context_bytes = _zz_s2b_0_rsp_context_channel[3 : 1];
  assign s2b_0_rsp_context_flush = _zz_s2b_0_rsp_context_channel[4];
  assign s2b_0_rsp_context_packet = _zz_s2b_0_rsp_context_channel[5];
  assign _zz_channels_0_fifo_pop_bytesIncr_value = (memory_core_io_writes_0_rsp_valid && s2b_0_rsp_context_channel[0]);
  assign when_DmaSg_l679 = (_zz_channels_0_fifo_pop_bytesIncr_value && s2b_0_rsp_context_packet);
  assign when_DmaSg_l681 = (_zz_channels_0_fifo_pop_bytesIncr_value && s2b_0_rsp_context_flush);
  assign when_DmaSg_l682 = (_zz_channels_0_fifo_pop_bytesIncr_value && s2b_0_rsp_context_packet);
  assign b2s_0_cmd_channelsOh = (((channels_1_channelValid && (! channels_1_pop_memory)) && 1'b1) && (! channels_1_fifo_pop_empty));
  assign b2s_0_cmd_veryLastPtr = channels_1_pop_b2s_veryLastPtr;
  assign b2s_0_cmd_address = channels_1_fifo_pop_ptrWithBase;
  assign b2s_0_cmd_context_channel = b2s_0_cmd_channelsOh;
  assign b2s_0_cmd_context_veryLast = ((channels_1_pop_b2s_veryLastValid && (b2s_0_cmd_address[13 : 1] == b2s_0_cmd_veryLastPtr[13 : 1])) && (b2s_0_cmd_address[0 : 0] == 1'b1));
  assign b2s_0_cmd_context_endPacket = channels_1_pop_b2s_veryLastEndPacket;
  assign memory_core_io_reads_0_cmd_valid = (|b2s_0_cmd_channelsOh);
  assign memory_core_io_reads_0_cmd_payload_address = b2s_0_cmd_address[12:0];
  assign memory_core_io_reads_0_cmd_payload_context = {b2s_0_cmd_context_endPacket,{b2s_0_cmd_context_veryLast,b2s_0_cmd_context_channel}};
  assign _zz_b2s_0_rsp_context_channel = memory_core_io_reads_0_rsp_payload_context;
  assign b2s_0_rsp_context_channel = _zz_b2s_0_rsp_context_channel[0 : 0];
  assign b2s_0_rsp_context_veryLast = _zz_b2s_0_rsp_context_channel[1];
  assign b2s_0_rsp_context_endPacket = _zz_b2s_0_rsp_context_channel[2];
  assign io_outputs_0_valid = memory_core_io_reads_0_rsp_valid;
  assign io_outputs_0_payload_data = memory_core_io_reads_0_rsp_payload_data;
  assign io_outputs_0_payload_mask = memory_core_io_reads_0_rsp_payload_mask;
  assign io_outputs_0_payload_sink = channels_1_pop_b2s_sinkId;
  assign io_outputs_0_payload_last = (b2s_0_rsp_context_veryLast && b2s_0_rsp_context_endPacket);
  assign io_outputs_0_fire = (io_outputs_0_valid && io_outputs_0_ready);
  assign when_DmaSg_l725 = (io_outputs_0_fire && b2s_0_rsp_context_veryLast);
  assign when_DmaSg_l726 = b2s_0_rsp_context_channel[0];
  assign _zz_m2b_cmd_s0_priority_masked = channels_1_priority;
  assign m2b_cmd_s0_priority_masked = (channels_1_push_m2b_loadRequest && (channels_1_priority == _zz_m2b_cmd_s0_priority_masked));
  assign _zz_m2b_cmd_s0_priority_chosenOh = m2b_cmd_s0_priority_masked;
  assign _zz_m2b_cmd_s0_priority_chosenOh_1 = {_zz_m2b_cmd_s0_priority_chosenOh,_zz_m2b_cmd_s0_priority_chosenOh};
  assign _zz_m2b_cmd_s0_priority_chosenOh_2 = (_zz_m2b_cmd_s0_priority_chosenOh_1 & (~ _zz__zz_m2b_cmd_s0_priority_chosenOh_2));
  assign m2b_cmd_s0_priority_chosenOh = (_zz_m2b_cmd_s0_priority_chosenOh_2[1 : 1] | _zz_m2b_cmd_s0_priority_chosenOh_2[0 : 0]);
  assign m2b_cmd_s0_priority_weightLast = (channels_1_weight == m2b_cmd_s0_priority_counter);
  assign m2b_cmd_s0_priority_contextNext = (m2b_cmd_s0_priority_weightLast ? m2b_cmd_s0_priority_chosenOh[0 : 0] : m2b_cmd_s0_priority_chosenOh);
  assign when_DmaSg_l758 = (! m2b_cmd_s0_valid);
  assign when_DmaSg_l760 = (|channels_1_push_m2b_loadRequest);
  assign when_DmaSg_l763 = (2'b00 == _zz_m2b_cmd_s0_priority_masked);
  assign when_DmaSg_l763_1 = (2'b01 == _zz_m2b_cmd_s0_priority_masked);
  assign when_DmaSg_l763_2 = (2'b10 == _zz_m2b_cmd_s0_priority_masked);
  assign when_DmaSg_l763_3 = (2'b11 == _zz_m2b_cmd_s0_priority_masked);
  assign when_DmaSg_l773 = (channels_1_push_m2b_loadRequest && m2b_cmd_s0_priority_chosenOh[0]);
  assign m2b_cmd_s0_address = channels_1_push_m2b_address;
  assign m2b_cmd_s0_bytesLeft = channels_1_push_m2b_bytesLeft;
  assign m2b_cmd_s0_readAddressBurstRange = m2b_cmd_s0_address[10 : 0];
  assign m2b_cmd_s0_lengthHead = ((~ m2b_cmd_s0_readAddressBurstRange) & channels_1_push_m2b_bytePerBurst);
  assign m2b_cmd_s0_length = _zz_m2b_cmd_s0_length[10:0];
  assign m2b_cmd_s0_lastBurst = (m2b_cmd_s0_bytesLeft == _zz_m2b_cmd_s0_lastBurst);
  assign m2b_cmd_s1_context_start = m2b_cmd_s1_address[2:0];
  assign m2b_cmd_s1_context_stop = _zz_m2b_cmd_s1_context_stop[2:0];
  assign m2b_cmd_s1_context_last = m2b_cmd_s1_lastBurst;
  assign m2b_cmd_s1_context_length = m2b_cmd_s1_length;
  always @(*) begin
    io_read_cmd_valid = 1'b0;
    if(m2b_cmd_s1_valid) begin
      io_read_cmd_valid = 1'b1;
    end
  end

  assign io_read_cmd_payload_last = 1'b1;
  assign io_read_cmd_payload_fragment_opcode = 1'b0;
  assign io_read_cmd_payload_fragment_address = m2b_cmd_s1_address;
  assign io_read_cmd_payload_fragment_length = m2b_cmd_s1_length;
  assign io_read_cmd_payload_fragment_context = {m2b_cmd_s1_context_last,{m2b_cmd_s1_context_length,{m2b_cmd_s1_context_stop,m2b_cmd_s1_context_start}}};
  assign m2b_cmd_s1_addressNext = (_zz_m2b_cmd_s1_addressNext + 32'h00000001);
  assign m2b_cmd_s1_byteLeftNext = (_zz_m2b_cmd_s1_byteLeftNext - 26'h0000001);
  assign m2b_cmd_s1_fifoPushDecr = (_zz_m2b_cmd_s1_fifoPushDecr >>> 2'd2);
  assign when_DmaSg_l828 = 1'b1;
  assign _zz_m2b_rsp_context_start = io_read_rsp_payload_fragment_context;
  assign m2b_rsp_context_start = _zz_m2b_rsp_context_start[2 : 0];
  assign m2b_rsp_context_stop = _zz_m2b_rsp_context_start[5 : 3];
  assign m2b_rsp_context_length = _zz_m2b_rsp_context_start[16 : 6];
  assign m2b_rsp_context_last = _zz_m2b_rsp_context_start[17];
  assign m2b_rsp_veryLast = (m2b_rsp_context_last && io_read_rsp_payload_last);
  assign io_read_rsp_fire = (io_read_rsp_valid && io_read_rsp_ready);
  assign when_DmaSg_l847 = (io_read_rsp_fire && m2b_rsp_veryLast);
  assign when_DmaSg_l848 = 1'b1;
  always @(*) begin
    memory_core_io_writes_1_cmd_payload_mask[0] = ((! (m2b_rsp_first && (3'b000 < m2b_rsp_context_start))) && (! (io_read_rsp_payload_last && (m2b_rsp_context_stop < 3'b000))));
    memory_core_io_writes_1_cmd_payload_mask[1] = ((! (m2b_rsp_first && (3'b001 < m2b_rsp_context_start))) && (! (io_read_rsp_payload_last && (m2b_rsp_context_stop < 3'b001))));
    memory_core_io_writes_1_cmd_payload_mask[2] = ((! (m2b_rsp_first && (3'b010 < m2b_rsp_context_start))) && (! (io_read_rsp_payload_last && (m2b_rsp_context_stop < 3'b010))));
    memory_core_io_writes_1_cmd_payload_mask[3] = ((! (m2b_rsp_first && (3'b011 < m2b_rsp_context_start))) && (! (io_read_rsp_payload_last && (m2b_rsp_context_stop < 3'b011))));
    memory_core_io_writes_1_cmd_payload_mask[4] = ((! (m2b_rsp_first && (3'b100 < m2b_rsp_context_start))) && (! (io_read_rsp_payload_last && (m2b_rsp_context_stop < 3'b100))));
    memory_core_io_writes_1_cmd_payload_mask[5] = ((! (m2b_rsp_first && (3'b101 < m2b_rsp_context_start))) && (! (io_read_rsp_payload_last && (m2b_rsp_context_stop < 3'b101))));
    memory_core_io_writes_1_cmd_payload_mask[6] = ((! (m2b_rsp_first && (3'b110 < m2b_rsp_context_start))) && (! (io_read_rsp_payload_last && (m2b_rsp_context_stop < 3'b110))));
    memory_core_io_writes_1_cmd_payload_mask[7] = ((! (m2b_rsp_first && (3'b111 < m2b_rsp_context_start))) && (! (io_read_rsp_payload_last && (m2b_rsp_context_stop < 3'b111))));
  end

  assign m2b_rsp_writeContext_last = m2b_rsp_veryLast;
  assign m2b_rsp_writeContext_lastOfBurst = io_read_rsp_payload_last;
  assign m2b_rsp_writeContext_loadByteInNextBeat = ({1'b0,(io_read_rsp_payload_last ? m2b_rsp_context_stop : 3'b111)} - {1'b0,(m2b_rsp_first ? m2b_rsp_context_start : 3'b000)});
  assign memory_core_io_writes_1_cmd_payload_address = channels_1_fifo_push_ptrWithBase[12:0];
  assign io_read_rsp_ready = memory_core_io_writes_1_cmd_ready;
  assign memory_core_io_writes_1_cmd_payload_context = {m2b_rsp_writeContext_loadByteInNextBeat,{m2b_rsp_writeContext_lastOfBurst,m2b_rsp_writeContext_last}};
  assign memory_core_io_writes_1_cmd_fire = (io_read_rsp_valid && memory_core_io_writes_1_cmd_ready);
  assign _zz_channels_1_fifo_push_ptrIncr_value = (memory_core_io_writes_1_cmd_fire && 1'b1);
  assign when_DmaSg_l874 = (_zz_channels_1_fifo_push_ptrIncr_value && io_read_rsp_payload_last);
  assign _zz_m2b_writeRsp_context_last = memory_core_io_writes_1_rsp_payload_context;
  assign m2b_writeRsp_context_last = _zz_m2b_writeRsp_context_last[0];
  assign m2b_writeRsp_context_lastOfBurst = _zz_m2b_writeRsp_context_last[1];
  assign m2b_writeRsp_context_loadByteInNextBeat = _zz_m2b_writeRsp_context_last[5 : 2];
  assign _zz_channels_1_fifo_pop_bytesIncr_value = (memory_core_io_writes_1_rsp_valid && 1'b1);
  assign when_DmaSg_l893 = (_zz_channels_1_fifo_pop_bytesIncr_value && m2b_writeRsp_context_lastOfBurst);
  assign _zz_b2m_fsm_arbiter_logic_priority_masked = channels_0_priority;
  assign b2m_fsm_arbiter_logic_priority_masked = (channels_0_pop_b2m_request && (channels_0_priority == _zz_b2m_fsm_arbiter_logic_priority_masked));
  assign _zz_b2m_fsm_arbiter_logic_priority_chosenOh = b2m_fsm_arbiter_logic_priority_masked;
  assign _zz_b2m_fsm_arbiter_logic_priority_chosenOh_1 = {_zz_b2m_fsm_arbiter_logic_priority_chosenOh,_zz_b2m_fsm_arbiter_logic_priority_chosenOh};
  assign _zz_b2m_fsm_arbiter_logic_priority_chosenOh_2 = (_zz_b2m_fsm_arbiter_logic_priority_chosenOh_1 & (~ _zz__zz_b2m_fsm_arbiter_logic_priority_chosenOh_2));
  assign b2m_fsm_arbiter_logic_priority_chosenOh = (_zz_b2m_fsm_arbiter_logic_priority_chosenOh_2[1 : 1] | _zz_b2m_fsm_arbiter_logic_priority_chosenOh_2[0 : 0]);
  assign b2m_fsm_arbiter_logic_priority_weightLast = (channels_0_weight == b2m_fsm_arbiter_logic_priority_counter);
  assign b2m_fsm_arbiter_logic_priority_contextNext = (b2m_fsm_arbiter_logic_priority_weightLast ? b2m_fsm_arbiter_logic_priority_chosenOh[0 : 0] : b2m_fsm_arbiter_logic_priority_chosenOh);
  assign when_DmaSg_l758_1 = (! b2m_fsm_arbiter_logic_valid);
  assign when_DmaSg_l760_1 = (|channels_0_pop_b2m_request);
  assign when_DmaSg_l763_4 = (2'b00 == _zz_b2m_fsm_arbiter_logic_priority_masked);
  assign when_DmaSg_l763_5 = (2'b01 == _zz_b2m_fsm_arbiter_logic_priority_masked);
  assign when_DmaSg_l763_6 = (2'b10 == _zz_b2m_fsm_arbiter_logic_priority_masked);
  assign when_DmaSg_l763_7 = (2'b11 == _zz_b2m_fsm_arbiter_logic_priority_masked);
  assign when_DmaSg_l773_1 = (channels_0_pop_b2m_request && b2m_fsm_arbiter_logic_priority_chosenOh[0]);
  assign when_DmaSg_l935 = ((! b2m_fsm_sel_valid) && b2m_fsm_arbiter_logic_valid);
  assign b2m_fsm_bytesInBurstP1 = ({1'b0,b2m_fsm_sel_bytesInBurst} + _zz_b2m_fsm_bytesInBurstP1);
  assign b2m_fsm_addressNext = (b2m_fsm_sel_address + _zz_b2m_fsm_addressNext);
  assign b2m_fsm_bytesLeftNext = ({1'b0,b2m_fsm_sel_bytesLeft} - _zz_b2m_fsm_bytesLeftNext);
  assign b2m_fsm_isFinalCmd = b2m_fsm_bytesLeftNext[26];
  assign b2m_fsm_s0 = (b2m_fsm_sel_valid && (! b2m_fsm_sel_valid_regNext));
  assign when_DmaSg_l986 = (! b2m_fsm_sel_valid);
  assign _zz_b2m_fsm_sel_bytesInBurst = (b2m_fsm_sel_bytesInFifo - 16'h0001);
  assign _zz_b2m_fsm_sel_bytesInBurst_1 = ((_zz__zz_b2m_fsm_sel_bytesInBurst_1 < b2m_fsm_sel_bytesLeft) ? _zz__zz_b2m_fsm_sel_bytesInBurst_1_1 : b2m_fsm_sel_bytesLeft);
  assign _zz_b2m_fsm_sel_bytesInBurst_2 = (b2m_fsm_sel_bytePerBurst - (_zz__zz_b2m_fsm_sel_bytesInBurst_2 & b2m_fsm_sel_bytePerBurst));
  assign b2m_fsm_fifoCompletion = (_zz_b2m_fsm_fifoCompletion == _zz_b2m_fsm_fifoCompletion_1);
  assign when_DmaSg_l996 = 1'b1;
  assign when_DmaSg_l1001 = (! b2m_fsm_fifoCompletion);
  assign when_DmaSg_l1013 = (b2m_fsm_sel_valid && b2m_fsm_sel_ready);
  always @(*) begin
    b2m_fsm_sel_ready = 1'b0;
    if(when_DmaSg_l1102) begin
      b2m_fsm_sel_ready = 1'b1;
    end
  end

  assign b2m_fsm_fetch_context_ptr = channels_0_fifo_pop_ptr;
  assign b2m_fsm_fetch_context_toggle = b2m_fsm_toggle;
  assign memory_core_io_reads_1_cmd_payload_address = b2m_fsm_sel_ptr[12:0];
  assign memory_core_io_reads_1_cmd_payload_context = {b2m_fsm_fetch_context_toggle,b2m_fsm_fetch_context_ptr};
  assign when_DmaSg_l1033 = (b2m_fsm_sel_valid && memory_core_io_reads_1_cmd_ready);
  assign _zz_b2m_fsm_aggregate_context_ptr = memory_core_io_reads_1_rsp_payload_context;
  assign b2m_fsm_aggregate_context_ptr = _zz_b2m_fsm_aggregate_context_ptr[13 : 0];
  assign b2m_fsm_aggregate_context_toggle = _zz_b2m_fsm_aggregate_context_ptr[14];
  assign memory_core_io_reads_1_rsp_s2mPipe_valid = (memory_core_io_reads_1_rsp_valid || (! memory_core_io_reads_1_rsp_rValidN));
  assign memory_core_io_reads_1_rsp_s2mPipe_payload_data = (memory_core_io_reads_1_rsp_rValidN ? memory_core_io_reads_1_rsp_payload_data : memory_core_io_reads_1_rsp_rData_data);
  assign memory_core_io_reads_1_rsp_s2mPipe_payload_mask = (memory_core_io_reads_1_rsp_rValidN ? memory_core_io_reads_1_rsp_payload_mask : memory_core_io_reads_1_rsp_rData_mask);
  assign memory_core_io_reads_1_rsp_s2mPipe_payload_context = (memory_core_io_reads_1_rsp_rValidN ? memory_core_io_reads_1_rsp_payload_context : memory_core_io_reads_1_rsp_rData_context);
  assign when_Stream_l445 = (b2m_fsm_aggregate_context_toggle != b2m_fsm_toggle);
  always @(*) begin
    b2m_fsm_aggregate_memoryPort_valid = memory_core_io_reads_1_rsp_s2mPipe_valid;
    if(when_Stream_l445) begin
      b2m_fsm_aggregate_memoryPort_valid = 1'b0;
    end
  end

  always @(*) begin
    memory_core_io_reads_1_rsp_s2mPipe_ready = b2m_fsm_aggregate_memoryPort_ready;
    if(when_Stream_l445) begin
      memory_core_io_reads_1_rsp_s2mPipe_ready = 1'b1;
    end
  end

  assign b2m_fsm_aggregate_memoryPort_payload_data = memory_core_io_reads_1_rsp_s2mPipe_payload_data;
  assign b2m_fsm_aggregate_memoryPort_payload_mask = memory_core_io_reads_1_rsp_s2mPipe_payload_mask;
  assign b2m_fsm_aggregate_memoryPort_payload_context = memory_core_io_reads_1_rsp_s2mPipe_payload_context;
  assign b2m_fsm_aggregate_memoryPort_fire = (b2m_fsm_aggregate_memoryPort_valid && b2m_fsm_aggregate_memoryPort_ready);
  assign when_DmaSg_l1050 = (! (b2m_fsm_sel_valid && (! b2m_fsm_sel_ready)));
  assign b2m_fsm_aggregate_bytesToSkip = channels_0_pop_b2m_bytesToSkip;
  assign b2m_fsm_aggregate_bytesToSkipMask = {((! b2m_fsm_aggregate_first) || (b2m_fsm_aggregate_bytesToSkip <= 3'b111)),{((! b2m_fsm_aggregate_first) || (b2m_fsm_aggregate_bytesToSkip <= 3'b110)),{((! b2m_fsm_aggregate_first) || (b2m_fsm_aggregate_bytesToSkip <= _zz_b2m_fsm_aggregate_bytesToSkipMask)),{(_zz_b2m_fsm_aggregate_bytesToSkipMask_1 || _zz_b2m_fsm_aggregate_bytesToSkipMask_2),{_zz_b2m_fsm_aggregate_bytesToSkipMask_3,{_zz_b2m_fsm_aggregate_bytesToSkipMask_4,_zz_b2m_fsm_aggregate_bytesToSkipMask_5}}}}}};
  assign b2m_fsm_aggregate_memoryPort_ready = b2m_fsm_aggregate_engine_io_input_ready;
  assign b2m_fsm_aggregate_engine_io_input_payload_mask = (b2m_fsm_aggregate_memoryPort_payload_mask & b2m_fsm_aggregate_bytesToSkipMask);
  assign b2m_fsm_aggregate_engine_io_offset = b2m_fsm_sel_address[2:0];
  assign b2m_fsm_aggregate_engine_io_flush = (! _zz_io_flush);
  assign b2m_fsm_cmd_maskFirstTrigger = b2m_fsm_sel_address[2:0];
  assign b2m_fsm_cmd_maskLastTriggerComb = (b2m_fsm_cmd_maskFirstTrigger + _zz_b2m_fsm_cmd_maskLastTriggerComb);
  assign b2m_fsm_cmd_maskFirst = {(b2m_fsm_cmd_maskFirstTrigger <= 3'b111),{(b2m_fsm_cmd_maskFirstTrigger <= 3'b110),{(b2m_fsm_cmd_maskFirstTrigger <= 3'b101),{(b2m_fsm_cmd_maskFirstTrigger <= 3'b100),{(b2m_fsm_cmd_maskFirstTrigger <= 3'b011),{(b2m_fsm_cmd_maskFirstTrigger <= _zz_b2m_fsm_cmd_maskFirst),{_zz_b2m_fsm_cmd_maskFirst_1,_zz_b2m_fsm_cmd_maskFirst_2}}}}}}};
  assign b2m_fsm_cmd_enoughAggregation = (((b2m_fsm_s2 && b2m_fsm_sel_valid) && (! b2m_fsm_aggregate_engine_io_flush)) && (io_write_cmd_payload_last ? ((b2m_fsm_aggregate_engine_io_output_mask & b2m_fsm_cmd_maskLast) == b2m_fsm_cmd_maskLast) : (&b2m_fsm_aggregate_engine_io_output_mask)));
  assign io_write_cmd_fire = (io_write_cmd_valid && io_write_cmd_ready);
  assign io_write_cmd_valid = b2m_fsm_cmd_enoughAggregation;
  assign io_write_cmd_payload_last = (b2m_fsm_beatCounter == 8'h0);
  assign io_write_cmd_payload_fragment_address = b2m_fsm_sel_address;
  assign io_write_cmd_payload_fragment_opcode = 1'b1;
  assign io_write_cmd_payload_fragment_data = b2m_fsm_aggregate_engine_io_output_data;
  assign io_write_cmd_payload_fragment_mask = (~ ((io_write_cmd_payload_first ? (~ b2m_fsm_cmd_maskFirst) : 8'h0) | (io_write_cmd_payload_last ? (~ b2m_fsm_cmd_maskLast) : 8'h0)));
  assign io_write_cmd_payload_fragment_length = b2m_fsm_sel_bytesInBurst;
  assign b2m_fsm_cmd_doPtrIncr = (b2m_fsm_sel_valid && (b2m_fsm_aggregate_engine_io_output_consumed || ((io_write_cmd_fire && io_write_cmd_payload_last) && (b2m_fsm_aggregate_engine_io_output_usedUntil == 3'b111))));
  assign b2m_fsm_cmd_context_length = b2m_fsm_sel_bytesInBurst;
  assign b2m_fsm_cmd_context_doPacketSync = (b2m_fsm_sel_packet && b2m_fsm_fifoCompletion);
  assign io_write_cmd_payload_fragment_context = {b2m_fsm_cmd_context_doPacketSync,b2m_fsm_cmd_context_length};
  assign when_DmaSg_l1102 = (io_write_cmd_fire && io_write_cmd_payload_last);
  assign io_write_rsp_ready = 1'b1;
  assign _zz_b2m_rsp_context_length = io_write_rsp_payload_fragment_context;
  assign b2m_rsp_context_length = _zz_b2m_rsp_context_length[10 : 0];
  assign b2m_rsp_context_doPacketSync = _zz_b2m_rsp_context_length[11];
  assign io_write_rsp_fire = (io_write_rsp_valid && io_write_rsp_ready);
  assign when_DmaSg_l1116 = 1'b1;
  assign _zz_ll_arbiter_head = {channels_1_ll_requestLl,channels_0_ll_requestLl};
  assign _zz_ll_arbiter_head_1 = _zz__zz_ll_arbiter_head_1[1];
  assign ll_arbiter_head = (_zz_ll_arbiter_head_2[0] ? channels_0_ll_head : channels_1_ll_head);
  assign ll_arbiter_isJustASink = (_zz_ll_arbiter_isJustASink[0] ? channels_0_descriptorValid : channels_1_descriptorValid);
  assign ll_arbiter_doDescriptorStall = (_zz_ll_arbiter_doDescriptorStall[0] ? ((! channels_0_ll_controlNoCompletion) || channels_0_ll_gotDescriptorStall) : ((! channels_1_ll_controlNoCompletion) || channels_1_ll_gotDescriptorStall));
  assign ll_arbiter_onSgStream = (_zz_ll_arbiter_onSgStream[0] ? channels_0_ll_onSgStream : channels_1_ll_onSgStream);
  assign when_DmaSg_l1149 = (! ll_cmd_valid);
  assign when_DmaSg_l1148 = (! ll_cmd_valid);
  assign when_DmaSg_l1148_1 = (! ll_cmd_valid);
  assign when_DmaSg_l1148_2 = (! ll_cmd_valid);
  assign when_DmaSg_l1148_3 = (! ll_cmd_valid);
  assign when_DmaSg_l1154 = (! ll_cmd_valid);
  assign when_DmaSg_l1155 = (! ll_cmd_valid);
  assign when_DmaSg_l1156 = (! ll_cmd_valid);
  assign when_DmaSg_l1160 = (! ll_cmd_valid);
  assign when_DmaSg_l1161 = (|{_zz_ll_arbiter_head_1,channels_0_ll_requestLl});
  assign when_DmaSg_l1169 = (! ll_arbiter_isJustASink);
  assign when_DmaSg_l1169_1 = (! ll_arbiter_isJustASink);
  assign when_DmaSg_l1177 = (ll_cmd_writeFired && ll_cmd_readFired);
  assign ll_cmd_context_channel = ll_cmd_oh_1;
  assign io_sgRead_cmd_valid = ((ll_cmd_valid && (! ll_cmd_readFired)) && (! ll_cmd_onSgStream));
  assign io_sgRead_cmd_payload_last = 1'b1;
  assign io_sgRead_cmd_payload_fragment_address = {ll_cmd_ptrNext[31 : 5],5'h0};
  assign io_sgRead_cmd_payload_fragment_length = 5'h1f;
  assign io_sgRead_cmd_payload_fragment_opcode = 1'b0;
  assign io_sgRead_cmd_payload_fragment_context = ll_cmd_context_channel;
  assign io_sgWrite_cmd_valid = ((ll_cmd_valid && (! ll_cmd_writeFired)) && (! ll_cmd_onSgStream));
  assign io_sgWrite_cmd_payload_last = 1'b1;
  assign io_sgWrite_cmd_payload_fragment_address = {ll_cmd_ptr[31 : 5],5'h0};
  assign io_sgWrite_cmd_payload_fragment_length = 2'b11;
  assign io_sgWrite_cmd_payload_fragment_opcode = 1'b1;
  assign io_sgWrite_cmd_payload_fragment_context = ll_cmd_context_channel;
  assign ll_cmd_writeMaskSplit_0 = io_sgWrite_cmd_payload_fragment_mask[3 : 0];
  assign ll_cmd_writeMaskSplit_1 = io_sgWrite_cmd_payload_fragment_mask[7 : 4];
  assign ll_cmd_writeDataSplit_0 = io_sgWrite_cmd_payload_fragment_data[31 : 0];
  assign ll_cmd_writeDataSplit_1 = io_sgWrite_cmd_payload_fragment_data[63 : 32];
  assign _zz_1 = zz_io_sgWrite_cmd_payload_fragment_mask(1'b0);
  always @(*) io_sgWrite_cmd_payload_fragment_mask = _zz_1;
  always @(*) begin
    io_sgWrite_cmd_payload_fragment_data[63 : 32] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    io_sgWrite_cmd_payload_fragment_data[31 : 0] = 32'h0;
    io_sgWrite_cmd_payload_fragment_data[26 : 0] = ll_cmd_bytesDone;
    io_sgWrite_cmd_payload_fragment_data[30] = ll_cmd_endOfPacket;
    io_sgWrite_cmd_payload_fragment_data[31] = ((! ll_cmd_isJustASink) && ll_cmd_doDescriptorStall);
  end

  assign io_sgRead_cmd_fire = (io_sgRead_cmd_valid && io_sgRead_cmd_ready);
  assign io_sgWrite_cmd_fire = (io_sgWrite_cmd_valid && io_sgWrite_cmd_ready);
  assign ll_readRsp_context_channel = io_sgRead_rsp_payload_fragment_context[0 : 0];
  assign _zz_ll_readRsp_oh_0 = (2'b01 <<< ll_readRsp_context_channel);
  assign ll_readRsp_oh_0 = _zz_ll_readRsp_oh_0[0];
  assign ll_readRsp_oh_1 = _zz_ll_readRsp_oh_0[1];
  assign io_sgRead_rsp_ready = 1'b1;
  assign io_sgRead_rsp_fire = (io_sgRead_rsp_valid && io_sgRead_rsp_ready);
  assign when_DmaSg_l1248 = (2'b01 == ll_readRsp_beatCounter);
  assign when_DmaSg_l1248_1 = (2'b10 == ll_readRsp_beatCounter);
  assign when_DmaSg_l1248_2 = (2'b11 == ll_readRsp_beatCounter);
  assign when_DmaSg_l1248_3 = (2'b00 == ll_readRsp_beatCounter);
  assign when_DmaSg_l1248_4 = (2'b00 == ll_readRsp_beatCounter);
  assign when_DmaSg_l1248_5 = (2'b00 == ll_readRsp_beatCounter);
  assign when_DmaSg_l1248_6 = (2'b00 == ll_readRsp_beatCounter);
  assign when_DmaSg_l1271 = (io_sgRead_rsp_fire && io_sgRead_rsp_payload_last);
  assign ll_writeRsp_context_channel = io_sgWrite_rsp_payload_fragment_context[0 : 0];
  assign _zz_ll_writeRsp_oh_0 = (2'b01 <<< ll_writeRsp_context_channel);
  assign ll_writeRsp_oh_0 = _zz_ll_writeRsp_oh_0[0];
  assign ll_writeRsp_oh_1 = _zz_ll_writeRsp_oh_0[1];
  assign io_sgWrite_rsp_ready = 1'b1;
  assign io_sgWrite_rsp_fire = (io_sgWrite_rsp_valid && io_sgWrite_rsp_ready);
  always @(*) begin
    io_interrupts = 2'b00;
    if(channels_0_interrupts_completion_valid) begin
      io_interrupts[0] = 1'b1;
    end
    if(channels_0_interrupts_onChannelCompletion_valid) begin
      io_interrupts[0] = 1'b1;
    end
    if(channels_0_interrupts_onLinkedListUpdate_valid) begin
      io_interrupts[0] = 1'b1;
    end
    if(channels_0_interrupts_s2mPacket_valid) begin
      io_interrupts[0] = 1'b1;
    end
    if(channels_1_interrupts_completion_valid) begin
      io_interrupts[1] = 1'b1;
    end
    if(channels_1_interrupts_onChannelCompletion_valid) begin
      io_interrupts[1] = 1'b1;
    end
    if(channels_1_interrupts_onLinkedListUpdate_valid) begin
      io_interrupts[1] = 1'b1;
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377 = 1'b0;
    case(io_ctrl_PADDR)
      14'h002c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379 = io_ctrl_PWDATA[0];
  always @(*) begin
    when_BusSlaveFactory_l377_1 = 1'b0;
    case(io_ctrl_PADDR)
      14'h002c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_1 = io_ctrl_PWDATA[0];
  always @(*) begin
    when_BusSlaveFactory_l377_2 = 1'b0;
    case(io_ctrl_PADDR)
      14'h002c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_2 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_2 = io_ctrl_PWDATA[4];
  always @(*) begin
    when_BusSlaveFactory_l377_3 = 1'b0;
    case(io_ctrl_PADDR)
      14'h002c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_3 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_3 = io_ctrl_PWDATA[4];
  always @(*) begin
    when_BusSlaveFactory_l341 = 1'b0;
    case(io_ctrl_PADDR)
      14'h0054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347 = io_ctrl_PWDATA[0];
  always @(*) begin
    when_BusSlaveFactory_l341_1 = 1'b0;
    case(io_ctrl_PADDR)
      14'h0054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_1 = io_ctrl_PWDATA[2];
  always @(*) begin
    when_BusSlaveFactory_l341_2 = 1'b0;
    case(io_ctrl_PADDR)
      14'h0054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_2 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_2 = io_ctrl_PWDATA[3];
  always @(*) begin
    when_BusSlaveFactory_l341_3 = 1'b0;
    case(io_ctrl_PADDR)
      14'h0054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_3 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_3 = io_ctrl_PWDATA[4];
  always @(*) begin
    when_BusSlaveFactory_l377_4 = 1'b0;
    case(io_ctrl_PADDR)
      14'h00ac : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_4 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_4 = io_ctrl_PWDATA[0];
  always @(*) begin
    when_BusSlaveFactory_l377_5 = 1'b0;
    case(io_ctrl_PADDR)
      14'h00ac : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_5 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_5 = io_ctrl_PWDATA[0];
  always @(*) begin
    when_BusSlaveFactory_l377_6 = 1'b0;
    case(io_ctrl_PADDR)
      14'h00ac : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_6 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_6 = io_ctrl_PWDATA[4];
  always @(*) begin
    when_BusSlaveFactory_l377_7 = 1'b0;
    case(io_ctrl_PADDR)
      14'h00ac : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_7 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_7 = io_ctrl_PWDATA[4];
  always @(*) begin
    when_BusSlaveFactory_l341_4 = 1'b0;
    case(io_ctrl_PADDR)
      14'h00d4 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_4 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_4 = io_ctrl_PWDATA[0];
  always @(*) begin
    when_BusSlaveFactory_l341_5 = 1'b0;
    case(io_ctrl_PADDR)
      14'h00d4 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_5 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_5 = io_ctrl_PWDATA[2];
  always @(*) begin
    when_BusSlaveFactory_l341_6 = 1'b0;
    case(io_ctrl_PADDR)
      14'h00d4 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_6 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_6 = io_ctrl_PWDATA[3];
  assign when_Apb3SlaveFactory_l81 = ((io_ctrl_PADDR & (~ 14'h0003)) == 14'h0010);
  assign when_Apb3SlaveFactory_l81_1 = ((io_ctrl_PADDR & (~ 14'h0003)) == 14'h0070);
  assign when_Apb3SlaveFactory_l81_2 = ((io_ctrl_PADDR & (~ 14'h0003)) == 14'h0080);
  assign when_Apb3SlaveFactory_l81_3 = ((io_ctrl_PADDR & (~ 14'h0003)) == 14'h00f0);
  assign channels_0_fifo_push_ptrIncr_value = _zz_channels_0_fifo_push_ptrIncr_value;
  assign channels_0_fifo_pop_bytesIncr_value = _zz_channels_0_fifo_pop_bytesIncr_value_1;
  assign channels_0_fifo_pop_bytesDecr_value = channels_0_pop_b2m_decrBytes;
  assign channels_0_fifo_pop_ptrIncr_value = _zz_channels_0_fifo_pop_ptrIncr_value;
  assign channels_1_fifo_push_ptrIncr_value = _zz_channels_1_fifo_push_ptrIncr_value_1;
  assign channels_1_fifo_pop_bytesIncr_value = _zz_channels_1_fifo_pop_bytesIncr_value_1;
  assign channels_1_fifo_pop_bytesDecr_value = 16'h0;
  assign channels_1_fifo_pop_ptrIncr_value = _zz_channels_1_fifo_pop_ptrIncr_value;
  assign ll_0_descriptorUpdate = (channels_0_ll_descriptorUpdated && (! channels_0_ll_gotDescriptorStall));
  assign ll_1_descriptorUpdate = (channels_1_ll_descriptorUpdated && (! channels_1_ll_gotDescriptorStall));
  always @(posedge clk) begin
    if(reset) begin
      channels_0_channelValid <= 1'b0;
      channels_0_descriptorValid <= 1'b0;
      channels_0_priority <= 2'b00;
      channels_0_weight <= 2'b00;
      channels_0_ctrl_kick <= 1'b0;
      channels_0_ll_valid <= 1'b0;
      channels_0_ll_onSgStream <= 1'b0;
      channels_0_pop_b2m_memPending <= 4'b0000;
      channels_0_interrupts_completion_enable <= 1'b0;
      channels_0_interrupts_completion_valid <= 1'b0;
      channels_0_interrupts_onChannelCompletion_enable <= 1'b0;
      channels_0_interrupts_onChannelCompletion_valid <= 1'b0;
      channels_0_interrupts_onLinkedListUpdate_enable <= 1'b0;
      channels_0_interrupts_onLinkedListUpdate_valid <= 1'b0;
      channels_0_interrupts_s2mPacket_enable <= 1'b0;
      channels_0_interrupts_s2mPacket_valid <= 1'b0;
      channels_1_channelValid <= 1'b0;
      channels_1_descriptorValid <= 1'b0;
      channels_1_priority <= 2'b00;
      channels_1_weight <= 2'b00;
      channels_1_ctrl_kick <= 1'b0;
      channels_1_ll_valid <= 1'b0;
      channels_1_ll_onSgStream <= 1'b0;
      channels_1_push_m2b_loadDone <= 1'b1;
      channels_1_push_m2b_memPending <= 4'b0000;
      channels_1_interrupts_completion_enable <= 1'b0;
      channels_1_interrupts_completion_valid <= 1'b0;
      channels_1_interrupts_onChannelCompletion_enable <= 1'b0;
      channels_1_interrupts_onChannelCompletion_valid <= 1'b0;
      channels_1_interrupts_onLinkedListUpdate_enable <= 1'b0;
      channels_1_interrupts_onLinkedListUpdate_valid <= 1'b0;
      io_inputs_0_payload_last_regNextWhen <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_1 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_2 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_3 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_4 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_5 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_6 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_7 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_8 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_9 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_10 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_11 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_12 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_13 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_14 <= 1'b1;
      io_inputs_0_payload_last_regNextWhen_15 <= 1'b1;
      m2b_cmd_s0_valid <= 1'b0;
      m2b_cmd_s0_priority_roundRobins_0 <= 1'b1;
      m2b_cmd_s0_priority_roundRobins_1 <= 1'b1;
      m2b_cmd_s0_priority_roundRobins_2 <= 1'b1;
      m2b_cmd_s0_priority_roundRobins_3 <= 1'b1;
      m2b_cmd_s0_priority_counter <= 2'b00;
      m2b_cmd_s1_valid <= 1'b0;
      m2b_rsp_first <= 1'b1;
      b2m_fsm_sel_valid <= 1'b0;
      b2m_fsm_arbiter_logic_valid <= 1'b0;
      b2m_fsm_arbiter_logic_priority_roundRobins_0 <= 1'b1;
      b2m_fsm_arbiter_logic_priority_roundRobins_1 <= 1'b1;
      b2m_fsm_arbiter_logic_priority_roundRobins_2 <= 1'b1;
      b2m_fsm_arbiter_logic_priority_roundRobins_3 <= 1'b1;
      b2m_fsm_arbiter_logic_priority_counter <= 2'b00;
      b2m_fsm_sel_valid_regNext <= 1'b0;
      b2m_fsm_s1 <= 1'b0;
      b2m_fsm_s2 <= 1'b0;
      b2m_fsm_toggle <= 1'b0;
      memory_core_io_reads_1_rsp_rValidN <= 1'b1;
      _zz_io_flush <= 1'b0;
      io_write_cmd_payload_first <= 1'b1;
      ll_cmd_valid <= 1'b0;
      ll_readRsp_beatCounter <= 2'b00;
    end else begin
      if(channels_0_channelStart) begin
        channels_0_channelValid <= 1'b1;
      end
      if(channels_0_channelCompletion) begin
        channels_0_channelValid <= 1'b0;
      end
      if(channels_0_descriptorStart) begin
        channels_0_descriptorValid <= 1'b1;
      end
      if(channels_0_descriptorCompletion) begin
        channels_0_descriptorValid <= 1'b0;
      end
      channels_0_ctrl_kick <= 1'b0;
      if(channels_0_channelCompletion) begin
        channels_0_ctrl_kick <= 1'b0;
      end
      if(when_DmaSg_l318) begin
        if(when_DmaSg_l320) begin
          if(!when_DmaSg_l322) begin
            channels_0_ll_valid <= 1'b0;
          end
        end
      end
      if(channels_0_ll_sgStart) begin
        channels_0_ll_valid <= 1'b1;
      end
      if(channels_0_channelCompletion) begin
        channels_0_ll_valid <= 1'b0;
      end
      channels_0_pop_b2m_memPending <= (_zz_channels_0_pop_b2m_memPending - _zz_channels_0_pop_b2m_memPending_3);
      if(when_DmaSg_l255) begin
        channels_0_interrupts_completion_valid <= 1'b1;
      end
      if(when_DmaSg_l255_1) begin
        channels_0_interrupts_completion_valid <= 1'b0;
      end
      if(when_DmaSg_l255_2) begin
        channels_0_interrupts_onChannelCompletion_valid <= 1'b1;
      end
      if(when_DmaSg_l255_3) begin
        channels_0_interrupts_onChannelCompletion_valid <= 1'b0;
      end
      if(channels_0_ll_descriptorUpdated) begin
        channels_0_interrupts_onLinkedListUpdate_valid <= 1'b1;
      end
      if(when_DmaSg_l255_4) begin
        channels_0_interrupts_onLinkedListUpdate_valid <= 1'b0;
      end
      if(channels_0_pop_b2m_packetSync) begin
        channels_0_interrupts_s2mPacket_valid <= 1'b1;
      end
      if(when_DmaSg_l255_5) begin
        channels_0_interrupts_s2mPacket_valid <= 1'b0;
      end
      if(channels_1_channelStart) begin
        channels_1_channelValid <= 1'b1;
      end
      if(channels_1_channelCompletion) begin
        channels_1_channelValid <= 1'b0;
      end
      if(channels_1_descriptorStart) begin
        channels_1_descriptorValid <= 1'b1;
      end
      if(channels_1_descriptorCompletion) begin
        channels_1_descriptorValid <= 1'b0;
      end
      channels_1_ctrl_kick <= 1'b0;
      if(channels_1_channelCompletion) begin
        channels_1_ctrl_kick <= 1'b0;
      end
      if(when_DmaSg_l318_1) begin
        if(when_DmaSg_l320_1) begin
          if(!when_DmaSg_l322_1) begin
            channels_1_ll_valid <= 1'b0;
          end
        end
      end
      if(channels_1_ll_sgStart) begin
        channels_1_ll_valid <= 1'b1;
      end
      if(channels_1_channelCompletion) begin
        channels_1_ll_valid <= 1'b0;
      end
      channels_1_push_m2b_memPending <= (_zz_channels_1_push_m2b_memPending - _zz_channels_1_push_m2b_memPending_3);
      if(channels_1_descriptorStart) begin
        channels_1_push_m2b_loadDone <= 1'b0;
      end
      if(when_DmaSg_l255_6) begin
        channels_1_interrupts_completion_valid <= 1'b1;
      end
      if(when_DmaSg_l255_7) begin
        channels_1_interrupts_completion_valid <= 1'b0;
      end
      if(when_DmaSg_l255_8) begin
        channels_1_interrupts_onChannelCompletion_valid <= 1'b1;
      end
      if(when_DmaSg_l255_9) begin
        channels_1_interrupts_onChannelCompletion_valid <= 1'b0;
      end
      if(channels_1_ll_descriptorUpdated) begin
        channels_1_interrupts_onLinkedListUpdate_valid <= 1'b1;
      end
      if(when_DmaSg_l255_10) begin
        channels_1_interrupts_onLinkedListUpdate_valid <= 1'b0;
      end
      if(when_package_l12) begin
        io_inputs_0_payload_last_regNextWhen <= io_inputs_0_payload_last;
      end
      if(when_package_l12_1) begin
        io_inputs_0_payload_last_regNextWhen_1 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_2) begin
        io_inputs_0_payload_last_regNextWhen_2 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_3) begin
        io_inputs_0_payload_last_regNextWhen_3 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_4) begin
        io_inputs_0_payload_last_regNextWhen_4 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_5) begin
        io_inputs_0_payload_last_regNextWhen_5 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_6) begin
        io_inputs_0_payload_last_regNextWhen_6 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_7) begin
        io_inputs_0_payload_last_regNextWhen_7 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_8) begin
        io_inputs_0_payload_last_regNextWhen_8 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_9) begin
        io_inputs_0_payload_last_regNextWhen_9 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_10) begin
        io_inputs_0_payload_last_regNextWhen_10 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_11) begin
        io_inputs_0_payload_last_regNextWhen_11 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_12) begin
        io_inputs_0_payload_last_regNextWhen_12 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_13) begin
        io_inputs_0_payload_last_regNextWhen_13 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_14) begin
        io_inputs_0_payload_last_regNextWhen_14 <= io_inputs_0_payload_last;
      end
      if(when_package_l12_15) begin
        io_inputs_0_payload_last_regNextWhen_15 <= io_inputs_0_payload_last;
      end
      if(when_DmaSg_l758) begin
        if(when_DmaSg_l760) begin
          m2b_cmd_s0_valid <= 1'b1;
          if(when_DmaSg_l763) begin
            m2b_cmd_s0_priority_roundRobins_0 <= m2b_cmd_s0_priority_contextNext;
          end
          if(when_DmaSg_l763_1) begin
            m2b_cmd_s0_priority_roundRobins_1 <= m2b_cmd_s0_priority_contextNext;
          end
          if(when_DmaSg_l763_2) begin
            m2b_cmd_s0_priority_roundRobins_2 <= m2b_cmd_s0_priority_contextNext;
          end
          if(when_DmaSg_l763_3) begin
            m2b_cmd_s0_priority_roundRobins_3 <= m2b_cmd_s0_priority_contextNext;
          end
          m2b_cmd_s0_priority_counter <= (m2b_cmd_s0_priority_counter + 2'b01);
          if(m2b_cmd_s0_priority_weightLast) begin
            m2b_cmd_s0_priority_counter <= 2'b00;
          end
        end
      end
      if(m2b_cmd_s0_valid) begin
        m2b_cmd_s1_valid <= 1'b1;
      end
      if(m2b_cmd_s1_valid) begin
        if(io_read_cmd_ready) begin
          m2b_cmd_s0_valid <= 1'b0;
          m2b_cmd_s1_valid <= 1'b0;
          if(when_DmaSg_l828) begin
            if(m2b_cmd_s1_lastBurst) begin
              channels_1_push_m2b_loadDone <= 1'b1;
            end
          end
        end
      end
      if(io_read_rsp_fire) begin
        m2b_rsp_first <= io_read_rsp_payload_last;
      end
      if(when_DmaSg_l758_1) begin
        if(when_DmaSg_l760_1) begin
          b2m_fsm_arbiter_logic_valid <= 1'b1;
          if(when_DmaSg_l763_4) begin
            b2m_fsm_arbiter_logic_priority_roundRobins_0 <= b2m_fsm_arbiter_logic_priority_contextNext;
          end
          if(when_DmaSg_l763_5) begin
            b2m_fsm_arbiter_logic_priority_roundRobins_1 <= b2m_fsm_arbiter_logic_priority_contextNext;
          end
          if(when_DmaSg_l763_6) begin
            b2m_fsm_arbiter_logic_priority_roundRobins_2 <= b2m_fsm_arbiter_logic_priority_contextNext;
          end
          if(when_DmaSg_l763_7) begin
            b2m_fsm_arbiter_logic_priority_roundRobins_3 <= b2m_fsm_arbiter_logic_priority_contextNext;
          end
          b2m_fsm_arbiter_logic_priority_counter <= (b2m_fsm_arbiter_logic_priority_counter + 2'b01);
          if(b2m_fsm_arbiter_logic_priority_weightLast) begin
            b2m_fsm_arbiter_logic_priority_counter <= 2'b00;
          end
        end
      end
      if(b2m_fsm_sel_ready) begin
        b2m_fsm_sel_valid <= 1'b0;
        if(b2m_fsm_sel_valid) begin
          b2m_fsm_arbiter_logic_valid <= 1'b0;
        end
      end
      if(when_DmaSg_l935) begin
        b2m_fsm_sel_valid <= 1'b1;
      end
      b2m_fsm_sel_valid_regNext <= b2m_fsm_sel_valid;
      b2m_fsm_s1 <= b2m_fsm_s0;
      if(b2m_fsm_s1) begin
        b2m_fsm_s2 <= 1'b1;
      end
      if(when_DmaSg_l986) begin
        b2m_fsm_s2 <= 1'b0;
      end
      if(when_DmaSg_l1013) begin
        b2m_fsm_toggle <= (! b2m_fsm_toggle);
      end
      if(memory_core_io_reads_1_rsp_valid) begin
        memory_core_io_reads_1_rsp_rValidN <= 1'b0;
      end
      if(memory_core_io_reads_1_rsp_s2mPipe_ready) begin
        memory_core_io_reads_1_rsp_rValidN <= 1'b1;
      end
      _zz_io_flush <= (b2m_fsm_sel_valid && (! b2m_fsm_sel_ready));
      if(io_write_cmd_fire) begin
        io_write_cmd_payload_first <= io_write_cmd_payload_last;
      end
      if(when_DmaSg_l1160) begin
        if(when_DmaSg_l1161) begin
          ll_cmd_valid <= 1'b1;
        end
      end else begin
        if(when_DmaSg_l1177) begin
          ll_cmd_valid <= 1'b0;
        end
      end
      if(io_sgRead_rsp_fire) begin
        ll_readRsp_beatCounter <= (ll_readRsp_beatCounter + 2'b01);
      end
      if(when_BusSlaveFactory_l377_1) begin
        if(when_BusSlaveFactory_l379_1) begin
          channels_0_ctrl_kick <= _zz_channels_0_ctrl_kick[0];
        end
      end
      if(when_BusSlaveFactory_l341) begin
        if(when_BusSlaveFactory_l347) begin
          channels_0_interrupts_completion_valid <= _zz_channels_0_interrupts_completion_valid[0];
        end
      end
      if(when_BusSlaveFactory_l341_1) begin
        if(when_BusSlaveFactory_l347_1) begin
          channels_0_interrupts_onChannelCompletion_valid <= _zz_channels_0_interrupts_onChannelCompletion_valid[0];
        end
      end
      if(when_BusSlaveFactory_l341_2) begin
        if(when_BusSlaveFactory_l347_2) begin
          channels_0_interrupts_onLinkedListUpdate_valid <= _zz_channels_0_interrupts_onLinkedListUpdate_valid[0];
        end
      end
      if(when_BusSlaveFactory_l341_3) begin
        if(when_BusSlaveFactory_l347_3) begin
          channels_0_interrupts_s2mPacket_valid <= _zz_channels_0_interrupts_s2mPacket_valid[0];
        end
      end
      if(when_BusSlaveFactory_l377_5) begin
        if(when_BusSlaveFactory_l379_5) begin
          channels_1_ctrl_kick <= _zz_channels_1_ctrl_kick[0];
        end
      end
      if(when_BusSlaveFactory_l341_4) begin
        if(when_BusSlaveFactory_l347_4) begin
          channels_1_interrupts_completion_valid <= _zz_channels_1_interrupts_completion_valid[0];
        end
      end
      if(when_BusSlaveFactory_l341_5) begin
        if(when_BusSlaveFactory_l347_5) begin
          channels_1_interrupts_onChannelCompletion_valid <= _zz_channels_1_interrupts_onChannelCompletion_valid[0];
        end
      end
      if(when_BusSlaveFactory_l341_6) begin
        if(when_BusSlaveFactory_l347_6) begin
          channels_1_interrupts_onLinkedListUpdate_valid <= _zz_channels_1_interrupts_onLinkedListUpdate_valid[0];
        end
      end
      case(io_ctrl_PADDR)
        14'h0078 : begin
          if(ctrl_doWrite) begin
            channels_0_ll_onSgStream <= io_ctrl_PWDATA[0];
          end
        end
        14'h0044 : begin
          if(ctrl_doWrite) begin
            channels_0_priority <= io_ctrl_PWDATA[1 : 0];
            channels_0_weight <= io_ctrl_PWDATA[9 : 8];
          end
        end
        14'h0050 : begin
          if(ctrl_doWrite) begin
            channels_0_interrupts_completion_enable <= io_ctrl_PWDATA[0];
            channels_0_interrupts_onChannelCompletion_enable <= io_ctrl_PWDATA[2];
            channels_0_interrupts_onLinkedListUpdate_enable <= io_ctrl_PWDATA[3];
            channels_0_interrupts_s2mPacket_enable <= io_ctrl_PWDATA[4];
          end
        end
        14'h00f8 : begin
          if(ctrl_doWrite) begin
            channels_1_ll_onSgStream <= io_ctrl_PWDATA[0];
          end
        end
        14'h00c4 : begin
          if(ctrl_doWrite) begin
            channels_1_priority <= io_ctrl_PWDATA[1 : 0];
            channels_1_weight <= io_ctrl_PWDATA[9 : 8];
          end
        end
        14'h00d0 : begin
          if(ctrl_doWrite) begin
            channels_1_interrupts_completion_enable <= io_ctrl_PWDATA[0];
            channels_1_interrupts_onChannelCompletion_enable <= io_ctrl_PWDATA[2];
            channels_1_interrupts_onLinkedListUpdate_enable <= io_ctrl_PWDATA[3];
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    if(channels_0_bytesProbe_incr_valid) begin
      channels_0_bytesProbe_value <= (_zz_channels_0_bytesProbe_value + 27'h0000001);
    end
    if(channels_0_descriptorStart) begin
      channels_0_ll_packet <= 1'b0;
    end
    if(channels_0_descriptorStart) begin
      channels_0_ll_requireSync <= 1'b0;
    end
    if(when_DmaSg_l318) begin
      channels_0_ll_waitDone <= 1'b0;
      if(when_DmaSg_l320) begin
        channels_0_ll_head <= 1'b0;
      end
    end
    if(channels_0_channelStart) begin
      channels_0_ll_waitDone <= 1'b0;
      channels_0_ll_head <= 1'b1;
    end
    channels_0_fifo_push_ptr <= (channels_0_fifo_push_ptr + channels_0_fifo_push_ptrIncr_value);
    if(channels_0_channelStart) begin
      channels_0_fifo_push_ptr <= 14'h0;
    end
    channels_0_fifo_pop_ptr <= (channels_0_fifo_pop_ptr + channels_0_fifo_pop_ptrIncr_value);
    channels_0_fifo_pop_withOverride_backup <= channels_0_fifo_pop_withOverride_backupNext;
    if(when_DmaSg_l409) begin
      channels_0_fifo_pop_withOverride_valid <= 1'b0;
    end
    if(channels_0_fifo_pop_withOverride_load) begin
      channels_0_fifo_pop_withOverride_valid <= 1'b1;
    end
    channels_0_fifo_pop_withOverride_exposed <= ((! channels_0_fifo_pop_withOverride_valid) ? channels_0_fifo_pop_withOverride_backupNext : _zz_channels_0_fifo_pop_withOverride_exposed);
    if(channels_0_channelStart) begin
      channels_0_fifo_pop_withOverride_backup <= 16'h0;
      channels_0_fifo_pop_withOverride_valid <= 1'b0;
    end
    if(channels_0_channelStart) begin
      channels_0_push_s2b_packetLock <= 1'b0;
    end
    if(channels_0_pop_b2m_fire) begin
      channels_0_pop_b2m_flush <= 1'b0;
    end
    if(when_DmaSg_l505) begin
      channels_0_pop_b2m_packet <= 1'b0;
    end
    if(when_DmaSg_l523) begin
      channels_0_pop_b2m_flush <= 1'b0;
      channels_0_pop_b2m_packet <= 1'b0;
    end
    if(channels_0_pop_b2m_packetSync) begin
      channels_0_push_s2b_packetLock <= 1'b0;
      if(when_DmaSg_l532) begin
        if(!channels_0_push_s2b_completionOnLast) begin
          if(when_DmaSg_l536) begin
            channels_0_ll_requireSync <= 1'b1;
          end
        end
        channels_0_ll_packet <= 1'b1;
      end
    end
    if(channels_0_channelStart) begin
      channels_0_pop_b2m_bytesToSkip <= 3'b000;
      channels_0_pop_b2m_flush <= 1'b0;
    end
    if(channels_0_descriptorStart) begin
      channels_0_pop_b2m_bytesLeft <= {1'd0, channels_0_bytes};
      channels_0_pop_b2m_waitFinalRsp <= 1'b0;
    end
    if(channels_0_channelValid) begin
      if(!channels_0_channelStop) begin
        if(when_DmaSg_l575) begin
          if(when_DmaSg_l593) begin
            channels_0_channelStop <= 1'b1;
          end
        end
      end
    end
    channels_0_fifo_pop_ptrIncr_value_regNext <= channels_0_fifo_pop_ptrIncr_value;
    channels_0_fifo_push_available <= (_zz_channels_0_fifo_push_available - (channels_0_push_memory ? channels_0_fifo_push_availableDecr : channels_0_fifo_push_ptrIncr_value));
    if(channels_0_channelStart) begin
      channels_0_fifo_push_ptr <= 14'h0;
      channels_0_fifo_push_available <= (channels_0_fifo_words + 14'h0001);
      channels_0_fifo_pop_ptr <= 14'h0;
    end
    if(when_DmaSg_l625) begin
      channels_0_bytesProbe_value <= 27'h0;
    end
    if(channels_1_bytesProbe_incr_valid) begin
      channels_1_bytesProbe_value <= (_zz_channels_1_bytesProbe_value + 27'h0000001);
    end
    if(channels_1_descriptorStart) begin
      channels_1_ll_packet <= 1'b0;
    end
    if(channels_1_descriptorStart) begin
      channels_1_ll_requireSync <= 1'b0;
    end
    if(when_DmaSg_l318_1) begin
      channels_1_ll_waitDone <= 1'b0;
      if(when_DmaSg_l320_1) begin
        channels_1_ll_head <= 1'b0;
      end
    end
    if(channels_1_channelStart) begin
      channels_1_ll_waitDone <= 1'b0;
      channels_1_ll_head <= 1'b1;
    end
    channels_1_fifo_push_ptr <= (channels_1_fifo_push_ptr + channels_1_fifo_push_ptrIncr_value);
    if(channels_1_channelStart) begin
      channels_1_fifo_push_ptr <= 14'h0;
    end
    channels_1_fifo_pop_ptr <= (channels_1_fifo_pop_ptr + channels_1_fifo_pop_ptrIncr_value);
    channels_1_fifo_pop_withoutOverride_exposed <= (_zz_channels_1_fifo_pop_withoutOverride_exposed - channels_1_fifo_pop_bytesDecr_value);
    if(channels_1_channelStart) begin
      channels_1_fifo_pop_withoutOverride_exposed <= 16'h0;
    end
    if(channels_1_descriptorStart) begin
      channels_1_push_m2b_bytesLeft <= channels_1_bytes;
    end
    if(when_DmaSg_l474) begin
      channels_1_pop_b2s_veryLastValid <= 1'b1;
    end
    if(channels_1_pop_b2s_veryLastTrigger) begin
      channels_1_pop_b2s_veryLastPtr <= channels_1_fifo_push_ptrWithBase;
      channels_1_pop_b2s_veryLastEndPacket <= channels_1_pop_b2s_last;
    end
    if(channels_1_channelStart) begin
      channels_1_pop_b2s_veryLastValid <= 1'b0;
    end
    if(channels_1_channelValid) begin
      if(!channels_1_channelStop) begin
        if(when_DmaSg_l575_1) begin
          if(when_DmaSg_l593_1) begin
            channels_1_channelStop <= 1'b1;
          end
        end
      end
    end
    channels_1_fifo_pop_ptrIncr_value_regNext <= channels_1_fifo_pop_ptrIncr_value;
    channels_1_fifo_push_available <= (_zz_channels_1_fifo_push_available - (channels_1_push_memory ? channels_1_fifo_push_availableDecr : channels_1_fifo_push_ptrIncr_value));
    if(channels_1_channelStart) begin
      channels_1_fifo_push_ptr <= 14'h0;
      channels_1_fifo_push_available <= (channels_1_fifo_words + 14'h0001);
      channels_1_fifo_pop_ptr <= 14'h0;
    end
    if(when_DmaSg_l625_1) begin
      channels_1_bytesProbe_value <= 27'h0;
    end
    if(when_DmaSg_l665) begin
      channels_0_push_s2b_waitFirst <= 1'b0;
      if(io_inputs_0_payload_last) begin
        channels_0_push_s2b_packetLock <= 1'b1;
      end
    end
    if(when_DmaSg_l681) begin
      channels_0_pop_b2m_flush <= 1'b1;
    end
    if(when_DmaSg_l682) begin
      channels_0_pop_b2m_packet <= 1'b1;
    end
    if(when_DmaSg_l725) begin
      if(when_DmaSg_l726) begin
        channels_1_pop_b2s_veryLastValid <= 1'b0;
      end
    end
    m2b_cmd_s1_address <= m2b_cmd_s0_address;
    m2b_cmd_s1_length <= m2b_cmd_s0_length;
    m2b_cmd_s1_lastBurst <= m2b_cmd_s0_lastBurst;
    m2b_cmd_s1_bytesLeft <= m2b_cmd_s0_bytesLeft;
    if(m2b_cmd_s1_valid) begin
      if(io_read_cmd_ready) begin
        if(when_DmaSg_l828) begin
          channels_1_push_m2b_address <= m2b_cmd_s1_addressNext;
          channels_1_push_m2b_bytesLeft <= m2b_cmd_s1_byteLeftNext;
        end
      end
    end
    if(when_DmaSg_l935) begin
      b2m_fsm_sel_address <= channels_0_pop_b2m_address;
      b2m_fsm_sel_ptr <= channels_0_fifo_pop_ptrWithBase;
      b2m_fsm_sel_ptrMask <= channels_0_fifo_words;
      b2m_fsm_sel_bytePerBurst <= channels_0_pop_b2m_bytePerBurst;
      b2m_fsm_sel_bytesInFifo <= channels_0_fifo_pop_bytes;
      b2m_fsm_sel_flush <= channels_0_pop_b2m_flush;
      b2m_fsm_sel_packet <= channels_0_pop_b2m_packet;
      b2m_fsm_sel_bytesLeft <= channels_0_pop_b2m_bytesLeft[25:0];
    end
    if(b2m_fsm_s0) begin
      b2m_fsm_sel_bytesInBurst <= _zz_b2m_fsm_sel_bytesInBurst_3[10:0];
    end
    if(b2m_fsm_s1) begin
      b2m_fsm_beatCounter <= (_zz_b2m_fsm_beatCounter >>> 2'd3);
      if(when_DmaSg_l996) begin
        channels_0_pop_b2m_address <= b2m_fsm_addressNext;
        channels_0_pop_b2m_bytesLeft <= b2m_fsm_bytesLeftNext;
        if(b2m_fsm_isFinalCmd) begin
          channels_0_pop_b2m_waitFinalRsp <= 1'b1;
        end
        if(when_DmaSg_l1001) begin
          if(b2m_fsm_sel_flush) begin
            channels_0_pop_b2m_flush <= 1'b1;
          end
          if(b2m_fsm_sel_packet) begin
            channels_0_pop_b2m_packet <= 1'b1;
          end
        end
      end
    end
    if(when_DmaSg_l1033) begin
      b2m_fsm_sel_ptr <= ((b2m_fsm_sel_ptr & (~ b2m_fsm_sel_ptrMask)) | (_zz_b2m_fsm_sel_ptr & b2m_fsm_sel_ptrMask));
    end
    if(memory_core_io_reads_1_rsp_rValidN) begin
      memory_core_io_reads_1_rsp_rData_data <= memory_core_io_reads_1_rsp_payload_data;
      memory_core_io_reads_1_rsp_rData_mask <= memory_core_io_reads_1_rsp_payload_mask;
      memory_core_io_reads_1_rsp_rData_context <= memory_core_io_reads_1_rsp_payload_context;
    end
    if(b2m_fsm_aggregate_memoryPort_fire) begin
      b2m_fsm_aggregate_first <= 1'b0;
    end
    if(when_DmaSg_l1050) begin
      b2m_fsm_aggregate_first <= 1'b1;
    end
    b2m_fsm_cmd_maskLastTriggerReg <= b2m_fsm_cmd_maskLastTriggerComb;
    b2m_fsm_cmd_maskLast <= {(3'b111 <= b2m_fsm_cmd_maskLastTriggerComb),{(3'b110 <= b2m_fsm_cmd_maskLastTriggerComb),{(3'b101 <= b2m_fsm_cmd_maskLastTriggerComb),{(3'b100 <= b2m_fsm_cmd_maskLastTriggerComb),{(3'b011 <= b2m_fsm_cmd_maskLastTriggerComb),{(_zz_b2m_fsm_cmd_maskLast <= b2m_fsm_cmd_maskLastTriggerComb),{_zz_b2m_fsm_cmd_maskLast_1,_zz_b2m_fsm_cmd_maskLast_2}}}}}}};
    if(io_write_cmd_fire) begin
      b2m_fsm_beatCounter <= (b2m_fsm_beatCounter - 8'h01);
    end
    if(when_DmaSg_l1102) begin
      if(_zz_when_1[0]) begin
        channels_0_pop_b2m_bytesToSkip <= (b2m_fsm_aggregate_engine_io_output_usedUntil + 3'b001);
      end
    end
    if(when_DmaSg_l1149) begin
      ll_cmd_oh_0 <= channels_0_ll_requestLl;
      ll_cmd_oh_1 <= _zz_ll_arbiter_head_1;
    end
    if(when_DmaSg_l1148) begin
      ll_cmd_ptr <= (_zz_ll_cmd_ptr[0] ? channels_0_ll_ptr : channels_1_ll_ptr);
    end
    if(when_DmaSg_l1148_1) begin
      ll_cmd_ptrNext <= (_zz_ll_cmd_ptrNext[0] ? channels_0_ll_ptrNext : channels_1_ll_ptrNext);
    end
    if(when_DmaSg_l1148_2) begin
      ll_cmd_bytesDone <= channels_0_bytesProbe_value;
    end
    if(when_DmaSg_l1148_3) begin
      ll_cmd_endOfPacket <= (_zz_ll_cmd_endOfPacket[0] ? channels_0_ll_packet : channels_1_ll_packet);
    end
    if(when_DmaSg_l1154) begin
      ll_cmd_isJustASink <= ll_arbiter_isJustASink;
    end
    if(when_DmaSg_l1155) begin
      ll_cmd_doDescriptorStall <= ll_arbiter_doDescriptorStall;
    end
    if(when_DmaSg_l1156) begin
      ll_cmd_onSgStream <= ll_arbiter_onSgStream;
    end
    if(when_DmaSg_l1160) begin
      ll_cmd_oh_0 <= channels_0_ll_requestLl;
      ll_cmd_oh_1 <= _zz_ll_arbiter_head_1;
      if(channels_0_ll_requestLl) begin
        channels_0_ll_waitDone <= 1'b1;
        channels_0_ll_writeDone <= ll_arbiter_head;
        channels_0_ll_justASync <= ll_arbiter_isJustASink;
        channels_0_ll_packet <= 1'b0;
        channels_0_ll_requireSync <= 1'b0;
        if(when_DmaSg_l1169) begin
          channels_0_ll_ptr <= channels_0_ll_ptrNext;
        end
        channels_0_ll_readDone <= ll_arbiter_isJustASink;
      end
      if(_zz_ll_arbiter_head_1) begin
        channels_1_ll_waitDone <= 1'b1;
        channels_1_ll_writeDone <= ll_arbiter_head;
        channels_1_ll_justASync <= ll_arbiter_isJustASink;
        channels_1_ll_packet <= 1'b0;
        channels_1_ll_requireSync <= 1'b0;
        if(when_DmaSg_l1169_1) begin
          channels_1_ll_ptr <= channels_1_ll_ptrNext;
        end
        channels_1_ll_readDone <= ll_arbiter_isJustASink;
      end
      ll_cmd_readFired <= ll_arbiter_isJustASink;
      ll_cmd_writeFired <= ll_arbiter_head;
    end
    if(io_sgRead_cmd_fire) begin
      ll_cmd_readFired <= 1'b1;
    end
    if(io_sgWrite_cmd_fire) begin
      ll_cmd_writeFired <= 1'b1;
    end
    if(io_sgRead_rsp_fire) begin
      if(when_DmaSg_l1248) begin
        if(ll_readRsp_oh_1) begin
          channels_1_push_m2b_address <= io_sgRead_rsp_payload_fragment_data[31 : 0];
        end
      end
      if(when_DmaSg_l1248_1) begin
        if(ll_readRsp_oh_0) begin
          channels_0_pop_b2m_address <= io_sgRead_rsp_payload_fragment_data[31 : 0];
        end
      end
      if(when_DmaSg_l1248_2) begin
        if(ll_readRsp_oh_0) begin
          channels_0_ll_ptrNext <= io_sgRead_rsp_payload_fragment_data[31 : 0];
        end
        if(ll_readRsp_oh_1) begin
          channels_1_ll_ptrNext <= io_sgRead_rsp_payload_fragment_data[31 : 0];
        end
      end
      if(when_DmaSg_l1248_3) begin
        if(ll_readRsp_oh_0) begin
          channels_0_bytes <= io_sgRead_rsp_payload_fragment_data[57 : 32];
        end
        if(ll_readRsp_oh_1) begin
          channels_1_bytes <= io_sgRead_rsp_payload_fragment_data[57 : 32];
        end
      end
      if(when_DmaSg_l1248_4) begin
        if(ll_readRsp_oh_0) begin
          channels_0_ll_controlNoCompletion <= io_sgRead_rsp_payload_fragment_data[63];
        end
        if(ll_readRsp_oh_1) begin
          channels_1_ll_controlNoCompletion <= io_sgRead_rsp_payload_fragment_data[63];
        end
      end
      if(when_DmaSg_l1248_5) begin
        if(ll_readRsp_oh_1) begin
          channels_1_pop_b2s_last <= io_sgRead_rsp_payload_fragment_data[62];
        end
      end
      if(when_DmaSg_l1248_6) begin
        if(ll_readRsp_oh_0) begin
          channels_0_ll_gotDescriptorStall <= io_sgRead_rsp_payload_fragment_data[31];
        end
        if(ll_readRsp_oh_1) begin
          channels_1_ll_gotDescriptorStall <= io_sgRead_rsp_payload_fragment_data[31];
        end
      end
      if(when_DmaSg_l1271) begin
        if(ll_readRsp_oh_0) begin
          channels_0_ll_readDone <= 1'b1;
        end
        if(ll_readRsp_oh_1) begin
          channels_1_ll_readDone <= 1'b1;
        end
      end
    end
    if(io_sgWrite_rsp_fire) begin
      if(ll_writeRsp_oh_0) begin
        channels_0_ll_writeDone <= 1'b1;
      end
      if(ll_writeRsp_oh_1) begin
        channels_1_ll_writeDone <= 1'b1;
      end
    end
    case(io_ctrl_PADDR)
      14'h000c : begin
        if(ctrl_doWrite) begin
          channels_0_push_memory <= io_ctrl_PWDATA[12];
          channels_0_push_s2b_completionOnLast <= io_ctrl_PWDATA[13];
          channels_0_push_s2b_waitFirst <= io_ctrl_PWDATA[14];
        end
      end
      14'h001c : begin
        if(ctrl_doWrite) begin
          channels_0_pop_memory <= io_ctrl_PWDATA[12];
        end
      end
      14'h002c : begin
        if(ctrl_doWrite) begin
          channels_0_channelStop <= io_ctrl_PWDATA[2];
        end
      end
      14'h0020 : begin
        if(ctrl_doWrite) begin
          channels_0_bytes <= io_ctrl_PWDATA[25 : 0];
        end
      end
      14'h008c : begin
        if(ctrl_doWrite) begin
          channels_1_push_memory <= io_ctrl_PWDATA[12];
        end
      end
      14'h0098 : begin
        if(ctrl_doWrite) begin
          channels_1_pop_b2s_sinkId <= io_ctrl_PWDATA[19 : 16];
        end
      end
      14'h009c : begin
        if(ctrl_doWrite) begin
          channels_1_pop_memory <= io_ctrl_PWDATA[12];
          channels_1_pop_b2s_last <= io_ctrl_PWDATA[13];
        end
      end
      14'h00ac : begin
        if(ctrl_doWrite) begin
          channels_1_channelStop <= io_ctrl_PWDATA[2];
        end
      end
      14'h00a0 : begin
        if(ctrl_doWrite) begin
          channels_1_bytes <= io_ctrl_PWDATA[25 : 0];
        end
      end
      default : begin
      end
    endcase
    if(when_Apb3SlaveFactory_l81) begin
      if(ctrl_doWrite) begin
        channels_0_pop_b2m_address[31 : 0] <= io_ctrl_PWDATA[31 : 0];
      end
    end
    if(when_Apb3SlaveFactory_l81_1) begin
      if(ctrl_doWrite) begin
        channels_0_ll_ptrNext[31 : 0] <= io_ctrl_PWDATA[31 : 0];
      end
    end
    if(when_Apb3SlaveFactory_l81_2) begin
      if(ctrl_doWrite) begin
        channels_1_push_m2b_address[31 : 0] <= io_ctrl_PWDATA[31 : 0];
      end
    end
    if(when_Apb3SlaveFactory_l81_3) begin
      if(ctrl_doWrite) begin
        channels_1_ll_ptrNext[31 : 0] <= io_ctrl_PWDATA[31 : 0];
      end
    end
  end


endmodule

module EfxDMA_StreamArbiter_1 (
  input  wire          io_inputs_0_valid,
  output wire          io_inputs_0_ready,
  input  wire          io_inputs_0_payload_last,
  input  wire [0:0]    io_inputs_0_payload_fragment_source,
  input  wire [0:0]    io_inputs_0_payload_fragment_opcode,
  input  wire [31:0]   io_inputs_0_payload_fragment_address,
  input  wire [10:0]   io_inputs_0_payload_fragment_length,
  input  wire [63:0]   io_inputs_0_payload_fragment_data,
  input  wire [7:0]    io_inputs_0_payload_fragment_mask,
  input  wire [11:0]   io_inputs_0_payload_fragment_context,
  input  wire          io_inputs_1_valid,
  output wire          io_inputs_1_ready,
  input  wire          io_inputs_1_payload_last,
  input  wire [0:0]    io_inputs_1_payload_fragment_source,
  input  wire [0:0]    io_inputs_1_payload_fragment_opcode,
  input  wire [31:0]   io_inputs_1_payload_fragment_address,
  input  wire [10:0]   io_inputs_1_payload_fragment_length,
  input  wire [63:0]   io_inputs_1_payload_fragment_data,
  input  wire [7:0]    io_inputs_1_payload_fragment_mask,
  input  wire [11:0]   io_inputs_1_payload_fragment_context,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire          io_output_payload_last,
  output wire [0:0]    io_output_payload_fragment_source,
  output wire [0:0]    io_output_payload_fragment_opcode,
  output wire [31:0]   io_output_payload_fragment_address,
  output wire [10:0]   io_output_payload_fragment_length,
  output wire [63:0]   io_output_payload_fragment_data,
  output wire [7:0]    io_output_payload_fragment_mask,
  output wire [11:0]   io_output_payload_fragment_context,
  output wire [0:0]    io_chosen,
  output wire [1:0]    io_chosenOH,
  input  wire          clk,
  input  wire          reset
);

  wire       [3:0]    _zz__zz_maskProposal_0_2;
  wire       [3:0]    _zz__zz_maskProposal_0_2_1;
  wire       [1:0]    _zz__zz_maskProposal_0_2_2;
  reg                 locked;
  wire                maskProposal_0;
  wire                maskProposal_1;
  reg                 maskLocked_0;
  reg                 maskLocked_1;
  wire                maskRouted_0;
  wire                maskRouted_1;
  wire       [1:0]    _zz_maskProposal_0;
  wire       [3:0]    _zz_maskProposal_0_1;
  wire       [3:0]    _zz_maskProposal_0_2;
  wire       [1:0]    _zz_maskProposal_0_3;
  wire                io_output_fire;
  wire                when_Stream_l683;
  wire                _zz_io_chosen;

  assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
  assign _zz__zz_maskProposal_0_2_2 = {maskLocked_0,maskLocked_1};
  assign _zz__zz_maskProposal_0_2_1 = {2'd0, _zz__zz_maskProposal_0_2_2};
  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign maskRouted_1 = (locked ? maskLocked_1 : maskProposal_1);
  assign _zz_maskProposal_0 = {io_inputs_1_valid,io_inputs_0_valid};
  assign _zz_maskProposal_0_1 = {_zz_maskProposal_0,_zz_maskProposal_0};
  assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~ _zz__zz_maskProposal_0_2));
  assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[3 : 2] | _zz_maskProposal_0_2[1 : 0]);
  assign maskProposal_0 = _zz_maskProposal_0_3[0];
  assign maskProposal_1 = _zz_maskProposal_0_3[1];
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign when_Stream_l683 = (io_output_fire && io_output_payload_last);
  assign io_output_valid = ((io_inputs_0_valid && maskRouted_0) || (io_inputs_1_valid && maskRouted_1));
  assign io_output_payload_last = (maskRouted_0 ? io_inputs_0_payload_last : io_inputs_1_payload_last);
  assign io_output_payload_fragment_source = (maskRouted_0 ? io_inputs_0_payload_fragment_source : io_inputs_1_payload_fragment_source);
  assign io_output_payload_fragment_opcode = (maskRouted_0 ? io_inputs_0_payload_fragment_opcode : io_inputs_1_payload_fragment_opcode);
  assign io_output_payload_fragment_address = (maskRouted_0 ? io_inputs_0_payload_fragment_address : io_inputs_1_payload_fragment_address);
  assign io_output_payload_fragment_length = (maskRouted_0 ? io_inputs_0_payload_fragment_length : io_inputs_1_payload_fragment_length);
  assign io_output_payload_fragment_data = (maskRouted_0 ? io_inputs_0_payload_fragment_data : io_inputs_1_payload_fragment_data);
  assign io_output_payload_fragment_mask = (maskRouted_0 ? io_inputs_0_payload_fragment_mask : io_inputs_1_payload_fragment_mask);
  assign io_output_payload_fragment_context = (maskRouted_0 ? io_inputs_0_payload_fragment_context : io_inputs_1_payload_fragment_context);
  assign io_inputs_0_ready = (maskRouted_0 && io_output_ready);
  assign io_inputs_1_ready = (maskRouted_1 && io_output_ready);
  assign io_chosenOH = {maskRouted_1,maskRouted_0};
  assign _zz_io_chosen = io_chosenOH[1];
  assign io_chosen = _zz_io_chosen;
  always @(posedge clk) begin
    if(reset) begin
      locked <= 1'b0;
      maskLocked_0 <= 1'b0;
      maskLocked_1 <= 1'b1;
    end else begin
      if(io_output_valid) begin
        maskLocked_0 <= maskRouted_0;
        maskLocked_1 <= maskRouted_1;
      end
      if(io_output_valid) begin
        locked <= 1'b1;
      end
      if(when_Stream_l683) begin
        locked <= 1'b0;
      end
    end
  end


endmodule

module EfxDMA_StreamArbiter (
  input  wire          io_inputs_0_valid,
  output wire          io_inputs_0_ready,
  input  wire          io_inputs_0_payload_last,
  input  wire [0:0]    io_inputs_0_payload_fragment_source,
  input  wire [0:0]    io_inputs_0_payload_fragment_opcode,
  input  wire [31:0]   io_inputs_0_payload_fragment_address,
  input  wire [10:0]   io_inputs_0_payload_fragment_length,
  input  wire [17:0]   io_inputs_0_payload_fragment_context,
  input  wire          io_inputs_1_valid,
  output wire          io_inputs_1_ready,
  input  wire          io_inputs_1_payload_last,
  input  wire [0:0]    io_inputs_1_payload_fragment_source,
  input  wire [0:0]    io_inputs_1_payload_fragment_opcode,
  input  wire [31:0]   io_inputs_1_payload_fragment_address,
  input  wire [10:0]   io_inputs_1_payload_fragment_length,
  input  wire [17:0]   io_inputs_1_payload_fragment_context,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire          io_output_payload_last,
  output wire [0:0]    io_output_payload_fragment_source,
  output wire [0:0]    io_output_payload_fragment_opcode,
  output wire [31:0]   io_output_payload_fragment_address,
  output wire [10:0]   io_output_payload_fragment_length,
  output wire [17:0]   io_output_payload_fragment_context,
  output wire [0:0]    io_chosen,
  output wire [1:0]    io_chosenOH,
  input  wire          clk,
  input  wire          reset
);

  wire       [3:0]    _zz__zz_maskProposal_0_2;
  wire       [3:0]    _zz__zz_maskProposal_0_2_1;
  wire       [1:0]    _zz__zz_maskProposal_0_2_2;
  reg                 locked;
  wire                maskProposal_0;
  wire                maskProposal_1;
  reg                 maskLocked_0;
  reg                 maskLocked_1;
  wire                maskRouted_0;
  wire                maskRouted_1;
  wire       [1:0]    _zz_maskProposal_0;
  wire       [3:0]    _zz_maskProposal_0_1;
  wire       [3:0]    _zz_maskProposal_0_2;
  wire       [1:0]    _zz_maskProposal_0_3;
  wire                io_output_fire;
  wire                when_Stream_l683;
  wire                _zz_io_chosen;

  assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
  assign _zz__zz_maskProposal_0_2_2 = {maskLocked_0,maskLocked_1};
  assign _zz__zz_maskProposal_0_2_1 = {2'd0, _zz__zz_maskProposal_0_2_2};
  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign maskRouted_1 = (locked ? maskLocked_1 : maskProposal_1);
  assign _zz_maskProposal_0 = {io_inputs_1_valid,io_inputs_0_valid};
  assign _zz_maskProposal_0_1 = {_zz_maskProposal_0,_zz_maskProposal_0};
  assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~ _zz__zz_maskProposal_0_2));
  assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[3 : 2] | _zz_maskProposal_0_2[1 : 0]);
  assign maskProposal_0 = _zz_maskProposal_0_3[0];
  assign maskProposal_1 = _zz_maskProposal_0_3[1];
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign when_Stream_l683 = (io_output_fire && io_output_payload_last);
  assign io_output_valid = ((io_inputs_0_valid && maskRouted_0) || (io_inputs_1_valid && maskRouted_1));
  assign io_output_payload_last = (maskRouted_0 ? io_inputs_0_payload_last : io_inputs_1_payload_last);
  assign io_output_payload_fragment_source = (maskRouted_0 ? io_inputs_0_payload_fragment_source : io_inputs_1_payload_fragment_source);
  assign io_output_payload_fragment_opcode = (maskRouted_0 ? io_inputs_0_payload_fragment_opcode : io_inputs_1_payload_fragment_opcode);
  assign io_output_payload_fragment_address = (maskRouted_0 ? io_inputs_0_payload_fragment_address : io_inputs_1_payload_fragment_address);
  assign io_output_payload_fragment_length = (maskRouted_0 ? io_inputs_0_payload_fragment_length : io_inputs_1_payload_fragment_length);
  assign io_output_payload_fragment_context = (maskRouted_0 ? io_inputs_0_payload_fragment_context : io_inputs_1_payload_fragment_context);
  assign io_inputs_0_ready = (maskRouted_0 && io_output_ready);
  assign io_inputs_1_ready = (maskRouted_1 && io_output_ready);
  assign io_chosenOH = {maskRouted_1,maskRouted_0};
  assign _zz_io_chosen = io_chosenOH[1];
  assign io_chosen = _zz_io_chosen;
  always @(posedge clk) begin
    if(reset) begin
      locked <= 1'b0;
      maskLocked_0 <= 1'b0;
      maskLocked_1 <= 1'b1;
    end else begin
      if(io_output_valid) begin
        maskLocked_0 <= maskRouted_0;
        maskLocked_1 <= maskRouted_1;
      end
      if(io_output_valid) begin
        locked <= 1'b1;
      end
      if(when_Stream_l683) begin
        locked <= 1'b0;
      end
    end
  end


endmodule

module EfxDMA_BufferCC_5 (
  input  wire [4:0]    io_dataIn,
  output wire [4:0]    io_dataOut,
  input  wire          dat1_o_clk,
  input  wire          dat1_o_reset
);

  (* async_reg = "true" *) reg        [4:0]    buffers_0;
  (* async_reg = "true" *) reg        [4:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge dat1_o_clk) begin
    if(dat1_o_reset) begin
      buffers_0 <= 5'h0;
      buffers_1 <= 5'h0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

//EfxDMA_BufferCC_4 replaced by EfxDMA_BufferCC_3

module EfxDMA_BufferCC_3 (
  input  wire [4:0]    io_dataIn,
  output wire [4:0]    io_dataOut,
  input  wire          clk,
  input  wire          reset
);

  (* async_reg = "true" *) reg        [4:0]    buffers_0;
  (* async_reg = "true" *) reg        [4:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge clk) begin
    if(reset) begin
      buffers_0 <= 5'h0;
      buffers_1 <= 5'h0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module EfxDMA_BufferCC_2 (
  input  wire [4:0]    io_dataIn,
  output wire [4:0]    io_dataOut,
  input  wire          dat0_i_clk,
  input  wire          dat0_i_reset
);

  (* async_reg = "true" *) reg        [4:0]    buffers_0;
  (* async_reg = "true" *) reg        [4:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge dat0_i_clk) begin
    if(dat0_i_reset) begin
      buffers_0 <= 5'h0;
      buffers_1 <= 5'h0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module EfxDMA_BmbContextRemover_1 (
  input  wire          io_input_cmd_valid,
  output reg           io_input_cmd_ready,
  input  wire          io_input_cmd_payload_last,
  input  wire [0:0]    io_input_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_input_cmd_payload_fragment_address,
  input  wire [10:0]   io_input_cmd_payload_fragment_length,
  input  wire [127:0]  io_input_cmd_payload_fragment_data,
  input  wire [15:0]   io_input_cmd_payload_fragment_mask,
  input  wire [12:0]   io_input_cmd_payload_fragment_context,
  output wire          io_input_rsp_valid,
  input  wire          io_input_rsp_ready,
  output wire          io_input_rsp_payload_last,
  output wire [0:0]    io_input_rsp_payload_fragment_opcode,
  output wire [12:0]   io_input_rsp_payload_fragment_context,
  output wire          io_output_cmd_valid,
  input  wire          io_output_cmd_ready,
  output wire          io_output_cmd_payload_last,
  output wire [0:0]    io_output_cmd_payload_fragment_opcode,
  output wire [31:0]   io_output_cmd_payload_fragment_address,
  output wire [10:0]   io_output_cmd_payload_fragment_length,
  output wire [127:0]  io_output_cmd_payload_fragment_data,
  output wire [15:0]   io_output_cmd_payload_fragment_mask,
  input  wire          io_output_rsp_valid,
  output wire          io_output_rsp_ready,
  input  wire          io_output_rsp_payload_last,
  input  wire [0:0]    io_output_rsp_payload_fragment_opcode,
  input  wire          clk,
  input  wire          reset
);

  reg                 fifoFork_thrown_translated_fifo_io_pop_ready;
  wire                fifoFork_thrown_translated_fifo_io_push_ready;
  wire                fifoFork_thrown_translated_fifo_io_pop_valid;
  wire       [12:0]   fifoFork_thrown_translated_fifo_io_pop_payload_context;
  wire       [2:0]    fifoFork_thrown_translated_fifo_io_occupancy;
  wire       [2:0]    fifoFork_thrown_translated_fifo_io_availability;
  wire                fifoFork_valid;
  reg                 fifoFork_ready;
  wire                fifoFork_payload_last;
  wire       [0:0]    fifoFork_payload_fragment_opcode;
  wire       [31:0]   fifoFork_payload_fragment_address;
  wire       [10:0]   fifoFork_payload_fragment_length;
  wire       [127:0]  fifoFork_payload_fragment_data;
  wire       [15:0]   fifoFork_payload_fragment_mask;
  wire       [12:0]   fifoFork_payload_fragment_context;
  wire                cmdFork_valid;
  wire                cmdFork_ready;
  wire                cmdFork_payload_last;
  wire       [0:0]    cmdFork_payload_fragment_opcode;
  wire       [31:0]   cmdFork_payload_fragment_address;
  wire       [10:0]   cmdFork_payload_fragment_length;
  wire       [127:0]  cmdFork_payload_fragment_data;
  wire       [15:0]   cmdFork_payload_fragment_mask;
  wire       [12:0]   cmdFork_payload_fragment_context;
  reg                 io_input_cmd_fork2_logic_linkEnable_0;
  reg                 io_input_cmd_fork2_logic_linkEnable_1;
  wire                when_Stream_l1063;
  wire                when_Stream_l1063_1;
  wire                fifoFork_fire;
  wire                cmdFork_fire;
  wire       [12:0]   pushCtx_context;
  reg                 fifoFork_payload_first;
  wire                when_Stream_l445;
  reg                 fifoFork_thrown_valid;
  wire                fifoFork_thrown_ready;
  wire                fifoFork_thrown_payload_last;
  wire       [0:0]    fifoFork_thrown_payload_fragment_opcode;
  wire       [31:0]   fifoFork_thrown_payload_fragment_address;
  wire       [10:0]   fifoFork_thrown_payload_fragment_length;
  wire       [127:0]  fifoFork_thrown_payload_fragment_data;
  wire       [15:0]   fifoFork_thrown_payload_fragment_mask;
  wire       [12:0]   fifoFork_thrown_payload_fragment_context;
  wire                fifoFork_thrown_translated_valid;
  wire                fifoFork_thrown_translated_ready;
  wire       [12:0]   fifoFork_thrown_translated_payload_context;
  wire                popCtx_valid;
  wire                popCtx_ready;
  wire       [12:0]   popCtx_payload_context;
  reg                 fifoFork_thrown_translated_fifo_io_pop_rValid;
  reg        [12:0]   fifoFork_thrown_translated_fifo_io_pop_rData_context;
  wire                when_Stream_l375;
  wire                _zz_io_input_rsp_valid;

  EfxDMA_StreamFifo_1 fifoFork_thrown_translated_fifo (
    .io_push_valid           (fifoFork_thrown_translated_valid                            ), //i
    .io_push_ready           (fifoFork_thrown_translated_fifo_io_push_ready               ), //o
    .io_push_payload_context (fifoFork_thrown_translated_payload_context[12:0]            ), //i
    .io_pop_valid            (fifoFork_thrown_translated_fifo_io_pop_valid                ), //o
    .io_pop_ready            (fifoFork_thrown_translated_fifo_io_pop_ready                ), //i
    .io_pop_payload_context  (fifoFork_thrown_translated_fifo_io_pop_payload_context[12:0]), //o
    .io_flush                (1'b0                                                        ), //i
    .io_occupancy            (fifoFork_thrown_translated_fifo_io_occupancy[2:0]           ), //o
    .io_availability         (fifoFork_thrown_translated_fifo_io_availability[2:0]        ), //o
    .clk                     (clk                                                         ), //i
    .reset                   (reset                                                       )  //i
  );
  always @(*) begin
    io_input_cmd_ready = 1'b1;
    if(when_Stream_l1063) begin
      io_input_cmd_ready = 1'b0;
    end
    if(when_Stream_l1063_1) begin
      io_input_cmd_ready = 1'b0;
    end
  end

  assign when_Stream_l1063 = ((! fifoFork_ready) && io_input_cmd_fork2_logic_linkEnable_0);
  assign when_Stream_l1063_1 = ((! cmdFork_ready) && io_input_cmd_fork2_logic_linkEnable_1);
  assign fifoFork_valid = (io_input_cmd_valid && io_input_cmd_fork2_logic_linkEnable_0);
  assign fifoFork_payload_last = io_input_cmd_payload_last;
  assign fifoFork_payload_fragment_opcode = io_input_cmd_payload_fragment_opcode;
  assign fifoFork_payload_fragment_address = io_input_cmd_payload_fragment_address;
  assign fifoFork_payload_fragment_length = io_input_cmd_payload_fragment_length;
  assign fifoFork_payload_fragment_data = io_input_cmd_payload_fragment_data;
  assign fifoFork_payload_fragment_mask = io_input_cmd_payload_fragment_mask;
  assign fifoFork_payload_fragment_context = io_input_cmd_payload_fragment_context;
  assign fifoFork_fire = (fifoFork_valid && fifoFork_ready);
  assign cmdFork_valid = (io_input_cmd_valid && io_input_cmd_fork2_logic_linkEnable_1);
  assign cmdFork_payload_last = io_input_cmd_payload_last;
  assign cmdFork_payload_fragment_opcode = io_input_cmd_payload_fragment_opcode;
  assign cmdFork_payload_fragment_address = io_input_cmd_payload_fragment_address;
  assign cmdFork_payload_fragment_length = io_input_cmd_payload_fragment_length;
  assign cmdFork_payload_fragment_data = io_input_cmd_payload_fragment_data;
  assign cmdFork_payload_fragment_mask = io_input_cmd_payload_fragment_mask;
  assign cmdFork_payload_fragment_context = io_input_cmd_payload_fragment_context;
  assign cmdFork_fire = (cmdFork_valid && cmdFork_ready);
  assign io_output_cmd_valid = cmdFork_valid;
  assign cmdFork_ready = io_output_cmd_ready;
  assign io_output_cmd_payload_last = cmdFork_payload_last;
  assign io_output_cmd_payload_fragment_opcode = cmdFork_payload_fragment_opcode;
  assign io_output_cmd_payload_fragment_address = cmdFork_payload_fragment_address;
  assign io_output_cmd_payload_fragment_length = cmdFork_payload_fragment_length;
  assign io_output_cmd_payload_fragment_data = cmdFork_payload_fragment_data;
  assign io_output_cmd_payload_fragment_mask = cmdFork_payload_fragment_mask;
  assign pushCtx_context = fifoFork_payload_fragment_context;
  assign when_Stream_l445 = (! fifoFork_payload_first);
  always @(*) begin
    fifoFork_thrown_valid = fifoFork_valid;
    if(when_Stream_l445) begin
      fifoFork_thrown_valid = 1'b0;
    end
  end

  always @(*) begin
    fifoFork_ready = fifoFork_thrown_ready;
    if(when_Stream_l445) begin
      fifoFork_ready = 1'b1;
    end
  end

  assign fifoFork_thrown_payload_last = fifoFork_payload_last;
  assign fifoFork_thrown_payload_fragment_opcode = fifoFork_payload_fragment_opcode;
  assign fifoFork_thrown_payload_fragment_address = fifoFork_payload_fragment_address;
  assign fifoFork_thrown_payload_fragment_length = fifoFork_payload_fragment_length;
  assign fifoFork_thrown_payload_fragment_data = fifoFork_payload_fragment_data;
  assign fifoFork_thrown_payload_fragment_mask = fifoFork_payload_fragment_mask;
  assign fifoFork_thrown_payload_fragment_context = fifoFork_payload_fragment_context;
  assign fifoFork_thrown_translated_valid = fifoFork_thrown_valid;
  assign fifoFork_thrown_ready = fifoFork_thrown_translated_ready;
  assign fifoFork_thrown_translated_payload_context = pushCtx_context;
  assign fifoFork_thrown_translated_ready = fifoFork_thrown_translated_fifo_io_push_ready;
  always @(*) begin
    fifoFork_thrown_translated_fifo_io_pop_ready = popCtx_ready;
    if(when_Stream_l375) begin
      fifoFork_thrown_translated_fifo_io_pop_ready = 1'b1;
    end
  end

  assign when_Stream_l375 = (! popCtx_valid);
  assign popCtx_valid = fifoFork_thrown_translated_fifo_io_pop_rValid;
  assign popCtx_payload_context = fifoFork_thrown_translated_fifo_io_pop_rData_context;
  assign popCtx_ready = ((io_output_rsp_valid && io_output_rsp_payload_last) && io_input_rsp_ready);
  assign _zz_io_input_rsp_valid = (! (! popCtx_valid));
  assign io_output_rsp_ready = (io_input_rsp_ready && _zz_io_input_rsp_valid);
  assign io_input_rsp_valid = (io_output_rsp_valid && _zz_io_input_rsp_valid);
  assign io_input_rsp_payload_last = io_output_rsp_payload_last;
  assign io_input_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_input_rsp_payload_fragment_context = popCtx_payload_context;
  always @(posedge clk) begin
    if(reset) begin
      io_input_cmd_fork2_logic_linkEnable_0 <= 1'b1;
      io_input_cmd_fork2_logic_linkEnable_1 <= 1'b1;
      fifoFork_payload_first <= 1'b1;
      fifoFork_thrown_translated_fifo_io_pop_rValid <= 1'b0;
    end else begin
      if(fifoFork_fire) begin
        io_input_cmd_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdFork_fire) begin
        io_input_cmd_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_input_cmd_ready) begin
        io_input_cmd_fork2_logic_linkEnable_0 <= 1'b1;
        io_input_cmd_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(fifoFork_fire) begin
        fifoFork_payload_first <= fifoFork_payload_last;
      end
      if(fifoFork_thrown_translated_fifo_io_pop_ready) begin
        fifoFork_thrown_translated_fifo_io_pop_rValid <= fifoFork_thrown_translated_fifo_io_pop_valid;
      end
    end
  end

  always @(posedge clk) begin
    if(fifoFork_thrown_translated_fifo_io_pop_ready) begin
      fifoFork_thrown_translated_fifo_io_pop_rData_context <= fifoFork_thrown_translated_fifo_io_pop_payload_context;
    end
  end


endmodule

module EfxDMA_BmbContextRemover (
  input  wire          io_input_cmd_valid,
  output reg           io_input_cmd_ready,
  input  wire          io_input_cmd_payload_last,
  input  wire [0:0]    io_input_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_input_cmd_payload_fragment_address,
  input  wire [10:0]   io_input_cmd_payload_fragment_length,
  input  wire [20:0]   io_input_cmd_payload_fragment_context,
  output wire          io_input_rsp_valid,
  input  wire          io_input_rsp_ready,
  output wire          io_input_rsp_payload_last,
  output wire [0:0]    io_input_rsp_payload_fragment_opcode,
  output wire [127:0]  io_input_rsp_payload_fragment_data,
  output wire [20:0]   io_input_rsp_payload_fragment_context,
  output wire          io_output_cmd_valid,
  input  wire          io_output_cmd_ready,
  output wire          io_output_cmd_payload_last,
  output wire [0:0]    io_output_cmd_payload_fragment_opcode,
  output wire [31:0]   io_output_cmd_payload_fragment_address,
  output wire [10:0]   io_output_cmd_payload_fragment_length,
  input  wire          io_output_rsp_valid,
  output wire          io_output_rsp_ready,
  input  wire          io_output_rsp_payload_last,
  input  wire [0:0]    io_output_rsp_payload_fragment_opcode,
  input  wire [127:0]  io_output_rsp_payload_fragment_data,
  input  wire          clk,
  input  wire          reset
);

  reg                 fifoFork_thrown_translated_fifo_io_pop_ready;
  wire                fifoFork_thrown_translated_fifo_io_push_ready;
  wire                fifoFork_thrown_translated_fifo_io_pop_valid;
  wire       [20:0]   fifoFork_thrown_translated_fifo_io_pop_payload_context;
  wire       [2:0]    fifoFork_thrown_translated_fifo_io_occupancy;
  wire       [2:0]    fifoFork_thrown_translated_fifo_io_availability;
  wire                fifoFork_valid;
  reg                 fifoFork_ready;
  wire                fifoFork_payload_last;
  wire       [0:0]    fifoFork_payload_fragment_opcode;
  wire       [31:0]   fifoFork_payload_fragment_address;
  wire       [10:0]   fifoFork_payload_fragment_length;
  wire       [20:0]   fifoFork_payload_fragment_context;
  wire                cmdFork_valid;
  wire                cmdFork_ready;
  wire                cmdFork_payload_last;
  wire       [0:0]    cmdFork_payload_fragment_opcode;
  wire       [31:0]   cmdFork_payload_fragment_address;
  wire       [10:0]   cmdFork_payload_fragment_length;
  wire       [20:0]   cmdFork_payload_fragment_context;
  reg                 io_input_cmd_fork2_logic_linkEnable_0;
  reg                 io_input_cmd_fork2_logic_linkEnable_1;
  wire                when_Stream_l1063;
  wire                when_Stream_l1063_1;
  wire                fifoFork_fire;
  wire                cmdFork_fire;
  wire       [20:0]   pushCtx_context;
  reg                 fifoFork_payload_first;
  wire                when_Stream_l445;
  reg                 fifoFork_thrown_valid;
  wire                fifoFork_thrown_ready;
  wire                fifoFork_thrown_payload_last;
  wire       [0:0]    fifoFork_thrown_payload_fragment_opcode;
  wire       [31:0]   fifoFork_thrown_payload_fragment_address;
  wire       [10:0]   fifoFork_thrown_payload_fragment_length;
  wire       [20:0]   fifoFork_thrown_payload_fragment_context;
  wire                fifoFork_thrown_translated_valid;
  wire                fifoFork_thrown_translated_ready;
  wire       [20:0]   fifoFork_thrown_translated_payload_context;
  wire                popCtx_valid;
  wire                popCtx_ready;
  wire       [20:0]   popCtx_payload_context;
  reg                 fifoFork_thrown_translated_fifo_io_pop_rValid;
  reg        [20:0]   fifoFork_thrown_translated_fifo_io_pop_rData_context;
  wire                when_Stream_l375;
  wire                _zz_io_input_rsp_valid;

  EfxDMA_StreamFifo fifoFork_thrown_translated_fifo (
    .io_push_valid           (fifoFork_thrown_translated_valid                            ), //i
    .io_push_ready           (fifoFork_thrown_translated_fifo_io_push_ready               ), //o
    .io_push_payload_context (fifoFork_thrown_translated_payload_context[20:0]            ), //i
    .io_pop_valid            (fifoFork_thrown_translated_fifo_io_pop_valid                ), //o
    .io_pop_ready            (fifoFork_thrown_translated_fifo_io_pop_ready                ), //i
    .io_pop_payload_context  (fifoFork_thrown_translated_fifo_io_pop_payload_context[20:0]), //o
    .io_flush                (1'b0                                                        ), //i
    .io_occupancy            (fifoFork_thrown_translated_fifo_io_occupancy[2:0]           ), //o
    .io_availability         (fifoFork_thrown_translated_fifo_io_availability[2:0]        ), //o
    .clk                     (clk                                                         ), //i
    .reset                   (reset                                                       )  //i
  );
  always @(*) begin
    io_input_cmd_ready = 1'b1;
    if(when_Stream_l1063) begin
      io_input_cmd_ready = 1'b0;
    end
    if(when_Stream_l1063_1) begin
      io_input_cmd_ready = 1'b0;
    end
  end

  assign when_Stream_l1063 = ((! fifoFork_ready) && io_input_cmd_fork2_logic_linkEnable_0);
  assign when_Stream_l1063_1 = ((! cmdFork_ready) && io_input_cmd_fork2_logic_linkEnable_1);
  assign fifoFork_valid = (io_input_cmd_valid && io_input_cmd_fork2_logic_linkEnable_0);
  assign fifoFork_payload_last = io_input_cmd_payload_last;
  assign fifoFork_payload_fragment_opcode = io_input_cmd_payload_fragment_opcode;
  assign fifoFork_payload_fragment_address = io_input_cmd_payload_fragment_address;
  assign fifoFork_payload_fragment_length = io_input_cmd_payload_fragment_length;
  assign fifoFork_payload_fragment_context = io_input_cmd_payload_fragment_context;
  assign fifoFork_fire = (fifoFork_valid && fifoFork_ready);
  assign cmdFork_valid = (io_input_cmd_valid && io_input_cmd_fork2_logic_linkEnable_1);
  assign cmdFork_payload_last = io_input_cmd_payload_last;
  assign cmdFork_payload_fragment_opcode = io_input_cmd_payload_fragment_opcode;
  assign cmdFork_payload_fragment_address = io_input_cmd_payload_fragment_address;
  assign cmdFork_payload_fragment_length = io_input_cmd_payload_fragment_length;
  assign cmdFork_payload_fragment_context = io_input_cmd_payload_fragment_context;
  assign cmdFork_fire = (cmdFork_valid && cmdFork_ready);
  assign io_output_cmd_valid = cmdFork_valid;
  assign cmdFork_ready = io_output_cmd_ready;
  assign io_output_cmd_payload_last = cmdFork_payload_last;
  assign io_output_cmd_payload_fragment_opcode = cmdFork_payload_fragment_opcode;
  assign io_output_cmd_payload_fragment_address = cmdFork_payload_fragment_address;
  assign io_output_cmd_payload_fragment_length = cmdFork_payload_fragment_length;
  assign pushCtx_context = fifoFork_payload_fragment_context;
  assign when_Stream_l445 = (! fifoFork_payload_first);
  always @(*) begin
    fifoFork_thrown_valid = fifoFork_valid;
    if(when_Stream_l445) begin
      fifoFork_thrown_valid = 1'b0;
    end
  end

  always @(*) begin
    fifoFork_ready = fifoFork_thrown_ready;
    if(when_Stream_l445) begin
      fifoFork_ready = 1'b1;
    end
  end

  assign fifoFork_thrown_payload_last = fifoFork_payload_last;
  assign fifoFork_thrown_payload_fragment_opcode = fifoFork_payload_fragment_opcode;
  assign fifoFork_thrown_payload_fragment_address = fifoFork_payload_fragment_address;
  assign fifoFork_thrown_payload_fragment_length = fifoFork_payload_fragment_length;
  assign fifoFork_thrown_payload_fragment_context = fifoFork_payload_fragment_context;
  assign fifoFork_thrown_translated_valid = fifoFork_thrown_valid;
  assign fifoFork_thrown_ready = fifoFork_thrown_translated_ready;
  assign fifoFork_thrown_translated_payload_context = pushCtx_context;
  assign fifoFork_thrown_translated_ready = fifoFork_thrown_translated_fifo_io_push_ready;
  always @(*) begin
    fifoFork_thrown_translated_fifo_io_pop_ready = popCtx_ready;
    if(when_Stream_l375) begin
      fifoFork_thrown_translated_fifo_io_pop_ready = 1'b1;
    end
  end

  assign when_Stream_l375 = (! popCtx_valid);
  assign popCtx_valid = fifoFork_thrown_translated_fifo_io_pop_rValid;
  assign popCtx_payload_context = fifoFork_thrown_translated_fifo_io_pop_rData_context;
  assign popCtx_ready = ((io_output_rsp_valid && io_output_rsp_payload_last) && io_input_rsp_ready);
  assign _zz_io_input_rsp_valid = (! (! popCtx_valid));
  assign io_output_rsp_ready = (io_input_rsp_ready && _zz_io_input_rsp_valid);
  assign io_input_rsp_valid = (io_output_rsp_valid && _zz_io_input_rsp_valid);
  assign io_input_rsp_payload_last = io_output_rsp_payload_last;
  assign io_input_rsp_payload_fragment_opcode = io_output_rsp_payload_fragment_opcode;
  assign io_input_rsp_payload_fragment_data = io_output_rsp_payload_fragment_data;
  assign io_input_rsp_payload_fragment_context = popCtx_payload_context;
  always @(posedge clk) begin
    if(reset) begin
      io_input_cmd_fork2_logic_linkEnable_0 <= 1'b1;
      io_input_cmd_fork2_logic_linkEnable_1 <= 1'b1;
      fifoFork_payload_first <= 1'b1;
      fifoFork_thrown_translated_fifo_io_pop_rValid <= 1'b0;
    end else begin
      if(fifoFork_fire) begin
        io_input_cmd_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdFork_fire) begin
        io_input_cmd_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_input_cmd_ready) begin
        io_input_cmd_fork2_logic_linkEnable_0 <= 1'b1;
        io_input_cmd_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(fifoFork_fire) begin
        fifoFork_payload_first <= fifoFork_payload_last;
      end
      if(fifoFork_thrown_translated_fifo_io_pop_ready) begin
        fifoFork_thrown_translated_fifo_io_pop_rValid <= fifoFork_thrown_translated_fifo_io_pop_valid;
      end
    end
  end

  always @(posedge clk) begin
    if(fifoFork_thrown_translated_fifo_io_pop_ready) begin
      fifoFork_thrown_translated_fifo_io_pop_rData_context <= fifoFork_thrown_translated_fifo_io_pop_payload_context;
    end
  end


endmodule

module EfxDMA_FlowCCUnsafeByToggle_1 (
  input  wire          io_input_valid,
  input  wire [31:0]   io_input_payload_PRDATA,
  input  wire          io_input_payload_PSLVERROR,
  output wire          io_output_valid,
  output wire [31:0]   io_output_payload_PRDATA,
  output wire          io_output_payload_PSLVERROR,
  input  wire          clk,
  input  wire          reset,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire                inputArea_target_buffercc_io_dataOut;
  reg                 inputArea_target;
  reg        [31:0]   inputArea_data_PRDATA;
  reg                 inputArea_data_PSLVERROR;
  wire                outputArea_target;
  reg                 outputArea_hit;
  wire                outputArea_flow_valid;
  wire       [31:0]   outputArea_flow_payload_PRDATA;
  wire                outputArea_flow_payload_PSLVERROR;
  reg                 outputArea_flow_m2sPipe_valid;
  (* async_reg = "true" *) reg        [31:0]   outputArea_flow_m2sPipe_payload_PRDATA;
  (* async_reg = "true" *) reg                 outputArea_flow_m2sPipe_payload_PSLVERROR;

  (* keep_hierarchy = "TRUE" *) EfxDMA_BufferCC_1 inputArea_target_buffercc (
    .io_dataIn  (inputArea_target                    ), //i
    .io_dataOut (inputArea_target_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                            ), //i
    .ctrl_reset (ctrl_reset                          )  //i
  );
  assign outputArea_target = inputArea_target_buffercc_io_dataOut;
  assign outputArea_flow_valid = (outputArea_target != outputArea_hit);
  assign outputArea_flow_payload_PRDATA = inputArea_data_PRDATA;
  assign outputArea_flow_payload_PSLVERROR = inputArea_data_PSLVERROR;
  assign io_output_valid = outputArea_flow_m2sPipe_valid;
  assign io_output_payload_PRDATA = outputArea_flow_m2sPipe_payload_PRDATA;
  assign io_output_payload_PSLVERROR = outputArea_flow_m2sPipe_payload_PSLVERROR;
  always @(posedge clk) begin
    if(reset) begin
      inputArea_target <= 1'b0;
    end else begin
      if(io_input_valid) begin
        inputArea_target <= (! inputArea_target);
      end
    end
  end

  always @(posedge clk) begin
    if(io_input_valid) begin
      inputArea_data_PRDATA <= io_input_payload_PRDATA;
      inputArea_data_PSLVERROR <= io_input_payload_PSLVERROR;
    end
  end

  always @(posedge ctrl_clk) begin
    if(ctrl_reset) begin
      outputArea_flow_m2sPipe_valid <= 1'b0;
      outputArea_hit <= 1'b0;
    end else begin
      outputArea_hit <= outputArea_target;
      outputArea_flow_m2sPipe_valid <= outputArea_flow_valid;
    end
  end

  always @(posedge ctrl_clk) begin
    if(outputArea_flow_valid) begin
      outputArea_flow_m2sPipe_payload_PRDATA <= outputArea_flow_payload_PRDATA;
      outputArea_flow_m2sPipe_payload_PSLVERROR <= outputArea_flow_payload_PSLVERROR;
    end
  end


endmodule

module EfxDMA_FlowCCUnsafeByToggle (
  input  wire          io_input_valid,
  input  wire [13:0]   io_input_payload_PADDR,
  input  wire          io_input_payload_PWRITE,
  input  wire [31:0]   io_input_payload_PWDATA,
  output wire          io_output_valid,
  output wire [13:0]   io_output_payload_PADDR,
  output wire          io_output_payload_PWRITE,
  output wire [31:0]   io_output_payload_PWDATA,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset,
  input  wire          clk,
  input  wire          reset
);

  wire                inputArea_target_buffercc_io_dataOut;
  reg                 inputArea_target;
  reg        [13:0]   inputArea_data_PADDR;
  reg                 inputArea_data_PWRITE;
  reg        [31:0]   inputArea_data_PWDATA;
  wire                outputArea_target;
  reg                 outputArea_hit;
  wire                outputArea_flow_valid;
  wire       [13:0]   outputArea_flow_payload_PADDR;
  wire                outputArea_flow_payload_PWRITE;
  wire       [31:0]   outputArea_flow_payload_PWDATA;

  (* keep_hierarchy = "TRUE" *) EfxDMA_BufferCC inputArea_target_buffercc (
    .io_dataIn  (inputArea_target                    ), //i
    .io_dataOut (inputArea_target_buffercc_io_dataOut), //o
    .clk        (clk                                 ), //i
    .reset      (reset                               )  //i
  );
  assign outputArea_target = inputArea_target_buffercc_io_dataOut;
  assign outputArea_flow_valid = (outputArea_target != outputArea_hit);
  assign outputArea_flow_payload_PADDR = inputArea_data_PADDR;
  assign outputArea_flow_payload_PWRITE = inputArea_data_PWRITE;
  assign outputArea_flow_payload_PWDATA = inputArea_data_PWDATA;
  assign io_output_valid = outputArea_flow_valid;
  assign io_output_payload_PADDR = outputArea_flow_payload_PADDR;
  assign io_output_payload_PWRITE = outputArea_flow_payload_PWRITE;
  assign io_output_payload_PWDATA = outputArea_flow_payload_PWDATA;
  always @(posedge ctrl_clk) begin
    if(ctrl_reset) begin
      inputArea_target <= 1'b0;
    end else begin
      if(io_input_valid) begin
        inputArea_target <= (! inputArea_target);
      end
    end
  end

  always @(posedge ctrl_clk) begin
    if(io_input_valid) begin
      inputArea_data_PADDR <= io_input_payload_PADDR;
      inputArea_data_PWRITE <= io_input_payload_PWRITE;
      inputArea_data_PWDATA <= io_input_payload_PWDATA;
    end
  end

  always @(posedge clk) begin
    if(reset) begin
      outputArea_hit <= 1'b0;
    end else begin
      outputArea_hit <= outputArea_target;
    end
  end


endmodule

module EfxDMA_Aggregator (
  input  wire          io_input_valid,
  output reg           io_input_ready,
  input  wire [63:0]   io_input_payload_data,
  input  wire [7:0]    io_input_payload_mask,
  output reg  [63:0]   io_output_data,
  output reg  [7:0]    io_output_mask,
  input  wire          io_output_enough,
  input  wire          io_output_consume,
  output wire          io_output_consumed,
  input  wire [2:0]    io_output_lastByteUsed,
  output wire [2:0]    io_output_usedUntil,
  input  wire          io_flush,
  input  wire [2:0]    io_offset,
  input  wire [10:0]   io_burstLength,
  input  wire          clk,
  input  wire          reset
);

  reg        [0:0]    _zz_s0_countOnesLogic_0_1;
  wire       [0:0]    _zz_s0_countOnesLogic_0_2;
  reg        [1:0]    _zz_s0_countOnesLogic_1_1;
  wire       [1:0]    _zz_s0_countOnesLogic_1_2;
  reg        [1:0]    _zz_s0_countOnesLogic_2_1;
  wire       [2:0]    _zz_s0_countOnesLogic_2_2;
  reg        [2:0]    _zz_s0_countOnesLogic_3_9;
  wire       [2:0]    _zz_s0_countOnesLogic_3_10;
  reg        [2:0]    _zz_s0_countOnesLogic_3_11;
  wire       [2:0]    _zz_s0_countOnesLogic_3_12;
  wire       [0:0]    _zz_s0_countOnesLogic_3_13;
  reg        [2:0]    _zz_s0_countOnesLogic_4_9;
  wire       [2:0]    _zz_s0_countOnesLogic_4_10;
  reg        [2:0]    _zz_s0_countOnesLogic_4_11;
  wire       [2:0]    _zz_s0_countOnesLogic_4_12;
  wire       [1:0]    _zz_s0_countOnesLogic_4_13;
  reg        [2:0]    _zz_s0_countOnesLogic_5_9;
  wire       [2:0]    _zz_s0_countOnesLogic_5_10;
  reg        [2:0]    _zz_s0_countOnesLogic_5_11;
  wire       [2:0]    _zz_s0_countOnesLogic_5_12;
  wire       [2:0]    _zz_s0_countOnesLogic_6_9;
  reg        [2:0]    _zz_s0_countOnesLogic_6_10;
  wire       [2:0]    _zz_s0_countOnesLogic_6_11;
  reg        [2:0]    _zz_s0_countOnesLogic_6_12;
  wire       [2:0]    _zz_s0_countOnesLogic_6_13;
  reg        [2:0]    _zz_s0_countOnesLogic_6_14;
  wire       [2:0]    _zz_s0_countOnesLogic_6_15;
  wire       [0:0]    _zz_s0_countOnesLogic_6_16;
  wire       [3:0]    _zz_s0_countOnesLogic_7_8;
  reg        [3:0]    _zz_s0_countOnesLogic_7_9;
  wire       [2:0]    _zz_s0_countOnesLogic_7_10;
  reg        [3:0]    _zz_s0_countOnesLogic_7_11;
  wire       [2:0]    _zz_s0_countOnesLogic_7_12;
  reg        [3:0]    _zz_s0_countOnesLogic_7_13;
  wire       [2:0]    _zz_s0_countOnesLogic_7_14;
  wire       [1:0]    _zz_s0_countOnesLogic_7_15;
  wire       [3:0]    _zz_s1_offsetNext;
  wire       [11:0]   _zz_s1_byteCounter;
  wire       [2:0]    _zz_s1_inputIndexes_1;
  wire       [2:0]    _zz_s1_inputIndexes_2;
  wire       [2:0]    _zz_s1_inputIndexes_3;
  wire       [2:0]    _zz_s1_outputPayload_selValid_56;
  wire       [11:0]   _zz_when_DmaSg_l1464;
  reg        [7:0]    _zz_s2_byteLogic_0_inputData;
  reg        [7:0]    _zz_s2_byteLogic_1_inputData;
  reg        [7:0]    _zz_s2_byteLogic_2_inputData;
  reg        [7:0]    _zz_s2_byteLogic_3_inputData;
  reg        [7:0]    _zz_s2_byteLogic_4_inputData;
  reg        [7:0]    _zz_s2_byteLogic_5_inputData;
  reg        [7:0]    _zz_s2_byteLogic_6_inputData;
  reg        [7:0]    _zz_s2_byteLogic_7_inputData;
  reg        [2:0]    _zz_io_output_usedUntil_3;
  wire       [2:0]    _zz_io_output_usedUntil_4;
  wire                s0_input_valid;
  wire                s0_input_ready;
  wire       [63:0]   s0_input_payload_data;
  wire       [7:0]    s0_input_payload_mask;
  reg                 io_input_rValid;
  reg        [63:0]   io_input_rData_data;
  reg        [7:0]    io_input_rData_mask;
  wire                when_Stream_l375;
  wire                _zz_s0_countOnesLogic_0;
  wire                _zz_s0_countOnesLogic_1;
  wire                _zz_s0_countOnesLogic_2;
  wire                _zz_s0_countOnesLogic_3;
  wire                _zz_s0_countOnesLogic_4;
  wire                _zz_s0_countOnesLogic_5;
  wire                _zz_s0_countOnesLogic_6;
  wire       [0:0]    s0_countOnesLogic_0;
  wire       [1:0]    s0_countOnesLogic_1;
  wire       [1:0]    s0_countOnesLogic_2;
  wire       [2:0]    _zz_s0_countOnesLogic_3_1;
  wire       [2:0]    _zz_s0_countOnesLogic_3_2;
  wire       [2:0]    _zz_s0_countOnesLogic_3_3;
  wire       [2:0]    _zz_s0_countOnesLogic_3_4;
  wire       [2:0]    _zz_s0_countOnesLogic_3_5;
  wire       [2:0]    _zz_s0_countOnesLogic_3_6;
  wire       [2:0]    _zz_s0_countOnesLogic_3_7;
  wire       [2:0]    _zz_s0_countOnesLogic_3_8;
  wire       [2:0]    s0_countOnesLogic_3;
  wire       [2:0]    _zz_s0_countOnesLogic_4_1;
  wire       [2:0]    _zz_s0_countOnesLogic_4_2;
  wire       [2:0]    _zz_s0_countOnesLogic_4_3;
  wire       [2:0]    _zz_s0_countOnesLogic_4_4;
  wire       [2:0]    _zz_s0_countOnesLogic_4_5;
  wire       [2:0]    _zz_s0_countOnesLogic_4_6;
  wire       [2:0]    _zz_s0_countOnesLogic_4_7;
  wire       [2:0]    _zz_s0_countOnesLogic_4_8;
  wire       [2:0]    s0_countOnesLogic_4;
  wire       [2:0]    _zz_s0_countOnesLogic_5_1;
  wire       [2:0]    _zz_s0_countOnesLogic_5_2;
  wire       [2:0]    _zz_s0_countOnesLogic_5_3;
  wire       [2:0]    _zz_s0_countOnesLogic_5_4;
  wire       [2:0]    _zz_s0_countOnesLogic_5_5;
  wire       [2:0]    _zz_s0_countOnesLogic_5_6;
  wire       [2:0]    _zz_s0_countOnesLogic_5_7;
  wire       [2:0]    _zz_s0_countOnesLogic_5_8;
  wire       [2:0]    s0_countOnesLogic_5;
  wire       [2:0]    _zz_s0_countOnesLogic_6_1;
  wire       [2:0]    _zz_s0_countOnesLogic_6_2;
  wire       [2:0]    _zz_s0_countOnesLogic_6_3;
  wire       [2:0]    _zz_s0_countOnesLogic_6_4;
  wire       [2:0]    _zz_s0_countOnesLogic_6_5;
  wire       [2:0]    _zz_s0_countOnesLogic_6_6;
  wire       [2:0]    _zz_s0_countOnesLogic_6_7;
  wire       [2:0]    _zz_s0_countOnesLogic_6_8;
  wire       [2:0]    s0_countOnesLogic_6;
  wire       [3:0]    _zz_s0_countOnesLogic_7;
  wire       [3:0]    _zz_s0_countOnesLogic_7_1;
  wire       [3:0]    _zz_s0_countOnesLogic_7_2;
  wire       [3:0]    _zz_s0_countOnesLogic_7_3;
  wire       [3:0]    _zz_s0_countOnesLogic_7_4;
  wire       [3:0]    _zz_s0_countOnesLogic_7_5;
  wire       [3:0]    _zz_s0_countOnesLogic_7_6;
  wire       [3:0]    _zz_s0_countOnesLogic_7_7;
  wire       [3:0]    s0_countOnesLogic_7;
  wire       [63:0]   s0_outputPayload_cmd_data;
  wire       [7:0]    s0_outputPayload_cmd_mask;
  wire       [0:0]    s0_outputPayload_countOnes_0;
  wire       [1:0]    s0_outputPayload_countOnes_1;
  wire       [1:0]    s0_outputPayload_countOnes_2;
  wire       [2:0]    s0_outputPayload_countOnes_3;
  wire       [2:0]    s0_outputPayload_countOnes_4;
  wire       [2:0]    s0_outputPayload_countOnes_5;
  wire       [2:0]    s0_outputPayload_countOnes_6;
  wire       [3:0]    s0_outputPayload_countOnes_7;
  wire                s0_output_valid;
  reg                 s0_output_ready;
  wire       [63:0]   s0_output_payload_cmd_data;
  wire       [7:0]    s0_output_payload_cmd_mask;
  wire       [0:0]    s0_output_payload_countOnes_0;
  wire       [1:0]    s0_output_payload_countOnes_1;
  wire       [1:0]    s0_output_payload_countOnes_2;
  wire       [2:0]    s0_output_payload_countOnes_3;
  wire       [2:0]    s0_output_payload_countOnes_4;
  wire       [2:0]    s0_output_payload_countOnes_5;
  wire       [2:0]    s0_output_payload_countOnes_6;
  wire       [3:0]    s0_output_payload_countOnes_7;
  wire                s1_input_valid;
  wire                s1_input_ready;
  wire       [63:0]   s1_input_payload_cmd_data;
  wire       [7:0]    s1_input_payload_cmd_mask;
  wire       [0:0]    s1_input_payload_countOnes_0;
  wire       [1:0]    s1_input_payload_countOnes_1;
  wire       [1:0]    s1_input_payload_countOnes_2;
  wire       [2:0]    s1_input_payload_countOnes_3;
  wire       [2:0]    s1_input_payload_countOnes_4;
  wire       [2:0]    s1_input_payload_countOnes_5;
  wire       [2:0]    s1_input_payload_countOnes_6;
  wire       [3:0]    s1_input_payload_countOnes_7;
  reg                 s0_output_rValid;
  reg        [63:0]   s0_output_rData_cmd_data;
  reg        [7:0]    s0_output_rData_cmd_mask;
  reg        [0:0]    s0_output_rData_countOnes_0;
  reg        [1:0]    s0_output_rData_countOnes_1;
  reg        [1:0]    s0_output_rData_countOnes_2;
  reg        [2:0]    s0_output_rData_countOnes_3;
  reg        [2:0]    s0_output_rData_countOnes_4;
  reg        [2:0]    s0_output_rData_countOnes_5;
  reg        [2:0]    s0_output_rData_countOnes_6;
  reg        [3:0]    s0_output_rData_countOnes_7;
  wire                when_Stream_l375_1;
  reg        [2:0]    s1_offset;
  wire       [3:0]    s1_offsetNext;
  wire                s1_input_fire;
  reg        [11:0]   s1_byteCounter;
  wire       [2:0]    s1_inputIndexes_0;
  wire       [2:0]    s1_inputIndexes_1;
  wire       [2:0]    s1_inputIndexes_2;
  wire       [2:0]    s1_inputIndexes_3;
  wire       [2:0]    s1_inputIndexes_4;
  wire       [2:0]    s1_inputIndexes_5;
  wire       [2:0]    s1_inputIndexes_6;
  wire       [2:0]    s1_inputIndexes_7;
  wire       [63:0]   s1_outputPayload_cmd_data;
  wire       [7:0]    s1_outputPayload_cmd_mask;
  wire       [2:0]    s1_outputPayload_index_0;
  wire       [2:0]    s1_outputPayload_index_1;
  wire       [2:0]    s1_outputPayload_index_2;
  wire       [2:0]    s1_outputPayload_index_3;
  wire       [2:0]    s1_outputPayload_index_4;
  wire       [2:0]    s1_outputPayload_index_5;
  wire       [2:0]    s1_outputPayload_index_6;
  wire       [2:0]    s1_outputPayload_index_7;
  wire                s1_outputPayload_last;
  wire       [2:0]    s1_outputPayload_sel_0;
  wire       [2:0]    s1_outputPayload_sel_1;
  wire       [2:0]    s1_outputPayload_sel_2;
  wire       [2:0]    s1_outputPayload_sel_3;
  wire       [2:0]    s1_outputPayload_sel_4;
  wire       [2:0]    s1_outputPayload_sel_5;
  wire       [2:0]    s1_outputPayload_sel_6;
  wire       [2:0]    s1_outputPayload_sel_7;
  reg        [7:0]    s1_outputPayload_selValid;
  wire                _zz_s1_outputPayload_selValid;
  wire                _zz_s1_outputPayload_selValid_1;
  wire                _zz_s1_outputPayload_selValid_2;
  wire                _zz_s1_outputPayload_selValid_3;
  wire                _zz_s1_outputPayload_selValid_4;
  wire                _zz_s1_outputPayload_selValid_5;
  wire                _zz_s1_outputPayload_selValid_6;
  wire                _zz_s1_outputPayload_sel_0;
  wire                _zz_s1_outputPayload_sel_0_1;
  wire                _zz_s1_outputPayload_sel_0_2;
  wire                _zz_s1_outputPayload_selValid_7;
  wire                _zz_s1_outputPayload_selValid_8;
  wire                _zz_s1_outputPayload_selValid_9;
  wire                _zz_s1_outputPayload_selValid_10;
  wire                _zz_s1_outputPayload_selValid_11;
  wire                _zz_s1_outputPayload_selValid_12;
  wire                _zz_s1_outputPayload_selValid_13;
  wire                _zz_s1_outputPayload_sel_1;
  wire                _zz_s1_outputPayload_sel_1_1;
  wire                _zz_s1_outputPayload_sel_1_2;
  wire                _zz_s1_outputPayload_selValid_14;
  wire                _zz_s1_outputPayload_selValid_15;
  wire                _zz_s1_outputPayload_selValid_16;
  wire                _zz_s1_outputPayload_selValid_17;
  wire                _zz_s1_outputPayload_selValid_18;
  wire                _zz_s1_outputPayload_selValid_19;
  wire                _zz_s1_outputPayload_selValid_20;
  wire                _zz_s1_outputPayload_sel_2;
  wire                _zz_s1_outputPayload_sel_2_1;
  wire                _zz_s1_outputPayload_sel_2_2;
  wire                _zz_s1_outputPayload_selValid_21;
  wire                _zz_s1_outputPayload_selValid_22;
  wire                _zz_s1_outputPayload_selValid_23;
  wire                _zz_s1_outputPayload_selValid_24;
  wire                _zz_s1_outputPayload_selValid_25;
  wire                _zz_s1_outputPayload_selValid_26;
  wire                _zz_s1_outputPayload_selValid_27;
  wire                _zz_s1_outputPayload_sel_3;
  wire                _zz_s1_outputPayload_sel_3_1;
  wire                _zz_s1_outputPayload_sel_3_2;
  wire                _zz_s1_outputPayload_selValid_28;
  wire                _zz_s1_outputPayload_selValid_29;
  wire                _zz_s1_outputPayload_selValid_30;
  wire                _zz_s1_outputPayload_selValid_31;
  wire                _zz_s1_outputPayload_selValid_32;
  wire                _zz_s1_outputPayload_selValid_33;
  wire                _zz_s1_outputPayload_selValid_34;
  wire                _zz_s1_outputPayload_sel_4;
  wire                _zz_s1_outputPayload_sel_4_1;
  wire                _zz_s1_outputPayload_sel_4_2;
  wire                _zz_s1_outputPayload_selValid_35;
  wire                _zz_s1_outputPayload_selValid_36;
  wire                _zz_s1_outputPayload_selValid_37;
  wire                _zz_s1_outputPayload_selValid_38;
  wire                _zz_s1_outputPayload_selValid_39;
  wire                _zz_s1_outputPayload_selValid_40;
  wire                _zz_s1_outputPayload_selValid_41;
  wire                _zz_s1_outputPayload_sel_5;
  wire                _zz_s1_outputPayload_sel_5_1;
  wire                _zz_s1_outputPayload_sel_5_2;
  wire                _zz_s1_outputPayload_selValid_42;
  wire                _zz_s1_outputPayload_selValid_43;
  wire                _zz_s1_outputPayload_selValid_44;
  wire                _zz_s1_outputPayload_selValid_45;
  wire                _zz_s1_outputPayload_selValid_46;
  wire                _zz_s1_outputPayload_selValid_47;
  wire                _zz_s1_outputPayload_selValid_48;
  wire                _zz_s1_outputPayload_sel_6;
  wire                _zz_s1_outputPayload_sel_6_1;
  wire                _zz_s1_outputPayload_sel_6_2;
  wire                _zz_s1_outputPayload_selValid_49;
  wire                _zz_s1_outputPayload_selValid_50;
  wire                _zz_s1_outputPayload_selValid_51;
  wire                _zz_s1_outputPayload_selValid_52;
  wire                _zz_s1_outputPayload_selValid_53;
  wire                _zz_s1_outputPayload_selValid_54;
  wire                _zz_s1_outputPayload_selValid_55;
  wire                _zz_s1_outputPayload_sel_7;
  wire                _zz_s1_outputPayload_sel_7_1;
  wire                _zz_s1_outputPayload_sel_7_2;
  wire                s1_output_valid;
  reg                 s1_output_ready;
  wire       [63:0]   s1_output_payload_cmd_data;
  wire       [7:0]    s1_output_payload_cmd_mask;
  wire       [2:0]    s1_output_payload_index_0;
  wire       [2:0]    s1_output_payload_index_1;
  wire       [2:0]    s1_output_payload_index_2;
  wire       [2:0]    s1_output_payload_index_3;
  wire       [2:0]    s1_output_payload_index_4;
  wire       [2:0]    s1_output_payload_index_5;
  wire       [2:0]    s1_output_payload_index_6;
  wire       [2:0]    s1_output_payload_index_7;
  wire                s1_output_payload_last;
  wire       [2:0]    s1_output_payload_sel_0;
  wire       [2:0]    s1_output_payload_sel_1;
  wire       [2:0]    s1_output_payload_sel_2;
  wire       [2:0]    s1_output_payload_sel_3;
  wire       [2:0]    s1_output_payload_sel_4;
  wire       [2:0]    s1_output_payload_sel_5;
  wire       [2:0]    s1_output_payload_sel_6;
  wire       [2:0]    s1_output_payload_sel_7;
  wire       [7:0]    s1_output_payload_selValid;
  wire                s2_input_valid;
  reg                 s2_input_ready;
  wire       [63:0]   s2_input_payload_cmd_data;
  wire       [7:0]    s2_input_payload_cmd_mask;
  wire       [2:0]    s2_input_payload_index_0;
  wire       [2:0]    s2_input_payload_index_1;
  wire       [2:0]    s2_input_payload_index_2;
  wire       [2:0]    s2_input_payload_index_3;
  wire       [2:0]    s2_input_payload_index_4;
  wire       [2:0]    s2_input_payload_index_5;
  wire       [2:0]    s2_input_payload_index_6;
  wire       [2:0]    s2_input_payload_index_7;
  wire                s2_input_payload_last;
  wire       [2:0]    s2_input_payload_sel_0;
  wire       [2:0]    s2_input_payload_sel_1;
  wire       [2:0]    s2_input_payload_sel_2;
  wire       [2:0]    s2_input_payload_sel_3;
  wire       [2:0]    s2_input_payload_sel_4;
  wire       [2:0]    s2_input_payload_sel_5;
  wire       [2:0]    s2_input_payload_sel_6;
  wire       [2:0]    s2_input_payload_sel_7;
  wire       [7:0]    s2_input_payload_selValid;
  reg                 s1_output_rValid;
  reg        [63:0]   s1_output_rData_cmd_data;
  reg        [7:0]    s1_output_rData_cmd_mask;
  reg        [2:0]    s1_output_rData_index_0;
  reg        [2:0]    s1_output_rData_index_1;
  reg        [2:0]    s1_output_rData_index_2;
  reg        [2:0]    s1_output_rData_index_3;
  reg        [2:0]    s1_output_rData_index_4;
  reg        [2:0]    s1_output_rData_index_5;
  reg        [2:0]    s1_output_rData_index_6;
  reg        [2:0]    s1_output_rData_index_7;
  reg                 s1_output_rData_last;
  reg        [2:0]    s1_output_rData_sel_0;
  reg        [2:0]    s1_output_rData_sel_1;
  reg        [2:0]    s1_output_rData_sel_2;
  reg        [2:0]    s1_output_rData_sel_3;
  reg        [2:0]    s1_output_rData_sel_4;
  reg        [2:0]    s1_output_rData_sel_5;
  reg        [2:0]    s1_output_rData_sel_6;
  reg        [2:0]    s1_output_rData_sel_7;
  reg        [7:0]    s1_output_rData_selValid;
  wire                when_Stream_l375_2;
  wire                when_DmaSg_l1464;
  wire                s2_input_fire;
  wire       [7:0]    s2_inputDataBytes_0;
  wire       [7:0]    s2_inputDataBytes_1;
  wire       [7:0]    s2_inputDataBytes_2;
  wire       [7:0]    s2_inputDataBytes_3;
  wire       [7:0]    s2_inputDataBytes_4;
  wire       [7:0]    s2_inputDataBytes_5;
  wire       [7:0]    s2_inputDataBytes_6;
  wire       [7:0]    s2_inputDataBytes_7;
  reg                 s2_byteLogic_0_buffer_valid;
  reg        [7:0]    s2_byteLogic_0_buffer_data;
  wire                s2_byteLogic_0_lastUsed;
  wire                s2_byteLogic_0_inputMask;
  wire       [7:0]    s2_byteLogic_0_inputData;
  wire                s2_byteLogic_0_outputMask;
  wire       [7:0]    s2_byteLogic_0_outputData;
  wire                when_DmaSg_l1493;
  reg                 s2_byteLogic_1_buffer_valid;
  reg        [7:0]    s2_byteLogic_1_buffer_data;
  wire                s2_byteLogic_1_lastUsed;
  wire                s2_byteLogic_1_inputMask;
  wire       [7:0]    s2_byteLogic_1_inputData;
  wire                s2_byteLogic_1_outputMask;
  wire       [7:0]    s2_byteLogic_1_outputData;
  wire                when_DmaSg_l1493_1;
  reg                 s2_byteLogic_2_buffer_valid;
  reg        [7:0]    s2_byteLogic_2_buffer_data;
  wire                s2_byteLogic_2_lastUsed;
  wire                s2_byteLogic_2_inputMask;
  wire       [7:0]    s2_byteLogic_2_inputData;
  wire                s2_byteLogic_2_outputMask;
  wire       [7:0]    s2_byteLogic_2_outputData;
  wire                when_DmaSg_l1493_2;
  reg                 s2_byteLogic_3_buffer_valid;
  reg        [7:0]    s2_byteLogic_3_buffer_data;
  wire                s2_byteLogic_3_lastUsed;
  wire                s2_byteLogic_3_inputMask;
  wire       [7:0]    s2_byteLogic_3_inputData;
  wire                s2_byteLogic_3_outputMask;
  wire       [7:0]    s2_byteLogic_3_outputData;
  wire                when_DmaSg_l1493_3;
  reg                 s2_byteLogic_4_buffer_valid;
  reg        [7:0]    s2_byteLogic_4_buffer_data;
  wire                s2_byteLogic_4_lastUsed;
  wire                s2_byteLogic_4_inputMask;
  wire       [7:0]    s2_byteLogic_4_inputData;
  wire                s2_byteLogic_4_outputMask;
  wire       [7:0]    s2_byteLogic_4_outputData;
  wire                when_DmaSg_l1493_4;
  reg                 s2_byteLogic_5_buffer_valid;
  reg        [7:0]    s2_byteLogic_5_buffer_data;
  wire                s2_byteLogic_5_lastUsed;
  wire                s2_byteLogic_5_inputMask;
  wire       [7:0]    s2_byteLogic_5_inputData;
  wire                s2_byteLogic_5_outputMask;
  wire       [7:0]    s2_byteLogic_5_outputData;
  wire                when_DmaSg_l1493_5;
  reg                 s2_byteLogic_6_buffer_valid;
  reg        [7:0]    s2_byteLogic_6_buffer_data;
  wire                s2_byteLogic_6_lastUsed;
  wire                s2_byteLogic_6_inputMask;
  wire       [7:0]    s2_byteLogic_6_inputData;
  wire                s2_byteLogic_6_outputMask;
  wire       [7:0]    s2_byteLogic_6_outputData;
  wire                when_DmaSg_l1493_6;
  reg                 s2_byteLogic_7_buffer_valid;
  reg        [7:0]    s2_byteLogic_7_buffer_data;
  wire                s2_byteLogic_7_lastUsed;
  wire                s2_byteLogic_7_inputMask;
  wire       [7:0]    s2_byteLogic_7_inputData;
  wire                s2_byteLogic_7_outputMask;
  wire       [7:0]    s2_byteLogic_7_outputData;
  wire                when_DmaSg_l1493_7;
  wire                _zz_io_output_usedUntil;
  wire                _zz_io_output_usedUntil_1;
  wire                _zz_io_output_usedUntil_2;

  assign _zz_s0_countOnesLogic_3_13 = _zz_s0_countOnesLogic_3;
  assign _zz_s0_countOnesLogic_3_12 = {2'd0, _zz_s0_countOnesLogic_3_13};
  assign _zz_s0_countOnesLogic_4_13 = {_zz_s0_countOnesLogic_4,_zz_s0_countOnesLogic_3};
  assign _zz_s0_countOnesLogic_4_12 = {1'd0, _zz_s0_countOnesLogic_4_13};
  assign _zz_s0_countOnesLogic_6_9 = (_zz_s0_countOnesLogic_6_10 + _zz_s0_countOnesLogic_6_12);
  assign _zz_s0_countOnesLogic_6_16 = _zz_s0_countOnesLogic_6;
  assign _zz_s0_countOnesLogic_6_15 = {2'd0, _zz_s0_countOnesLogic_6_16};
  assign _zz_s0_countOnesLogic_7_8 = (_zz_s0_countOnesLogic_7_9 + _zz_s0_countOnesLogic_7_11);
  assign _zz_s0_countOnesLogic_7_15 = {s0_input_payload_mask[7],_zz_s0_countOnesLogic_6};
  assign _zz_s0_countOnesLogic_7_14 = {1'd0, _zz_s0_countOnesLogic_7_15};
  assign _zz_s1_offsetNext = {1'd0, s1_offset};
  assign _zz_s1_byteCounter = {8'd0, s1_input_payload_countOnes_7};
  assign _zz_s1_inputIndexes_1 = {2'd0, s1_input_payload_countOnes_0};
  assign _zz_s1_inputIndexes_2 = {1'd0, s1_input_payload_countOnes_1};
  assign _zz_s1_inputIndexes_3 = {1'd0, s1_input_payload_countOnes_2};
  assign _zz_when_DmaSg_l1464 = {1'd0, io_burstLength};
  assign _zz_s0_countOnesLogic_0_2 = _zz_s0_countOnesLogic_0;
  assign _zz_s0_countOnesLogic_1_2 = {_zz_s0_countOnesLogic_1,_zz_s0_countOnesLogic_0};
  assign _zz_s0_countOnesLogic_2_2 = {_zz_s0_countOnesLogic_2,{_zz_s0_countOnesLogic_1,_zz_s0_countOnesLogic_0}};
  assign _zz_s0_countOnesLogic_3_10 = {_zz_s0_countOnesLogic_2,{_zz_s0_countOnesLogic_1,_zz_s0_countOnesLogic_0}};
  assign _zz_s0_countOnesLogic_4_10 = {_zz_s0_countOnesLogic_2,{_zz_s0_countOnesLogic_1,_zz_s0_countOnesLogic_0}};
  assign _zz_s0_countOnesLogic_5_10 = {_zz_s0_countOnesLogic_2,{_zz_s0_countOnesLogic_1,_zz_s0_countOnesLogic_0}};
  assign _zz_s0_countOnesLogic_5_12 = {_zz_s0_countOnesLogic_5,{_zz_s0_countOnesLogic_4,_zz_s0_countOnesLogic_3}};
  assign _zz_s0_countOnesLogic_6_11 = {_zz_s0_countOnesLogic_2,{_zz_s0_countOnesLogic_1,_zz_s0_countOnesLogic_0}};
  assign _zz_s0_countOnesLogic_6_13 = {_zz_s0_countOnesLogic_5,{_zz_s0_countOnesLogic_4,_zz_s0_countOnesLogic_3}};
  assign _zz_s0_countOnesLogic_7_10 = {_zz_s0_countOnesLogic_2,{_zz_s0_countOnesLogic_1,_zz_s0_countOnesLogic_0}};
  assign _zz_s0_countOnesLogic_7_12 = {_zz_s0_countOnesLogic_5,{_zz_s0_countOnesLogic_4,_zz_s0_countOnesLogic_3}};
  assign _zz_io_output_usedUntil_4 = {_zz_io_output_usedUntil_2,{_zz_io_output_usedUntil_1,_zz_io_output_usedUntil}};
  assign _zz_s1_outputPayload_selValid_56 = 3'b000;
  always @(*) begin
    case(_zz_s0_countOnesLogic_0_2)
      1'b0 : _zz_s0_countOnesLogic_0_1 = 1'b0;
      default : _zz_s0_countOnesLogic_0_1 = 1'b1;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_1_2)
      2'b00 : _zz_s0_countOnesLogic_1_1 = 2'b00;
      2'b01 : _zz_s0_countOnesLogic_1_1 = 2'b01;
      2'b10 : _zz_s0_countOnesLogic_1_1 = 2'b01;
      default : _zz_s0_countOnesLogic_1_1 = 2'b10;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_2_2)
      3'b000 : _zz_s0_countOnesLogic_2_1 = 2'b00;
      3'b001 : _zz_s0_countOnesLogic_2_1 = 2'b01;
      3'b010 : _zz_s0_countOnesLogic_2_1 = 2'b01;
      3'b011 : _zz_s0_countOnesLogic_2_1 = 2'b10;
      3'b100 : _zz_s0_countOnesLogic_2_1 = 2'b01;
      3'b101 : _zz_s0_countOnesLogic_2_1 = 2'b10;
      3'b110 : _zz_s0_countOnesLogic_2_1 = 2'b10;
      default : _zz_s0_countOnesLogic_2_1 = 2'b11;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_3_10)
      3'b000 : _zz_s0_countOnesLogic_3_9 = _zz_s0_countOnesLogic_3_1;
      3'b001 : _zz_s0_countOnesLogic_3_9 = _zz_s0_countOnesLogic_3_2;
      3'b010 : _zz_s0_countOnesLogic_3_9 = _zz_s0_countOnesLogic_3_3;
      3'b011 : _zz_s0_countOnesLogic_3_9 = _zz_s0_countOnesLogic_3_4;
      3'b100 : _zz_s0_countOnesLogic_3_9 = _zz_s0_countOnesLogic_3_5;
      3'b101 : _zz_s0_countOnesLogic_3_9 = _zz_s0_countOnesLogic_3_6;
      3'b110 : _zz_s0_countOnesLogic_3_9 = _zz_s0_countOnesLogic_3_7;
      default : _zz_s0_countOnesLogic_3_9 = _zz_s0_countOnesLogic_3_8;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_3_12)
      3'b000 : _zz_s0_countOnesLogic_3_11 = _zz_s0_countOnesLogic_3_1;
      3'b001 : _zz_s0_countOnesLogic_3_11 = _zz_s0_countOnesLogic_3_2;
      3'b010 : _zz_s0_countOnesLogic_3_11 = _zz_s0_countOnesLogic_3_3;
      3'b011 : _zz_s0_countOnesLogic_3_11 = _zz_s0_countOnesLogic_3_4;
      3'b100 : _zz_s0_countOnesLogic_3_11 = _zz_s0_countOnesLogic_3_5;
      3'b101 : _zz_s0_countOnesLogic_3_11 = _zz_s0_countOnesLogic_3_6;
      3'b110 : _zz_s0_countOnesLogic_3_11 = _zz_s0_countOnesLogic_3_7;
      default : _zz_s0_countOnesLogic_3_11 = _zz_s0_countOnesLogic_3_8;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_4_10)
      3'b000 : _zz_s0_countOnesLogic_4_9 = _zz_s0_countOnesLogic_4_1;
      3'b001 : _zz_s0_countOnesLogic_4_9 = _zz_s0_countOnesLogic_4_2;
      3'b010 : _zz_s0_countOnesLogic_4_9 = _zz_s0_countOnesLogic_4_3;
      3'b011 : _zz_s0_countOnesLogic_4_9 = _zz_s0_countOnesLogic_4_4;
      3'b100 : _zz_s0_countOnesLogic_4_9 = _zz_s0_countOnesLogic_4_5;
      3'b101 : _zz_s0_countOnesLogic_4_9 = _zz_s0_countOnesLogic_4_6;
      3'b110 : _zz_s0_countOnesLogic_4_9 = _zz_s0_countOnesLogic_4_7;
      default : _zz_s0_countOnesLogic_4_9 = _zz_s0_countOnesLogic_4_8;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_4_12)
      3'b000 : _zz_s0_countOnesLogic_4_11 = _zz_s0_countOnesLogic_4_1;
      3'b001 : _zz_s0_countOnesLogic_4_11 = _zz_s0_countOnesLogic_4_2;
      3'b010 : _zz_s0_countOnesLogic_4_11 = _zz_s0_countOnesLogic_4_3;
      3'b011 : _zz_s0_countOnesLogic_4_11 = _zz_s0_countOnesLogic_4_4;
      3'b100 : _zz_s0_countOnesLogic_4_11 = _zz_s0_countOnesLogic_4_5;
      3'b101 : _zz_s0_countOnesLogic_4_11 = _zz_s0_countOnesLogic_4_6;
      3'b110 : _zz_s0_countOnesLogic_4_11 = _zz_s0_countOnesLogic_4_7;
      default : _zz_s0_countOnesLogic_4_11 = _zz_s0_countOnesLogic_4_8;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_5_10)
      3'b000 : _zz_s0_countOnesLogic_5_9 = _zz_s0_countOnesLogic_5_1;
      3'b001 : _zz_s0_countOnesLogic_5_9 = _zz_s0_countOnesLogic_5_2;
      3'b010 : _zz_s0_countOnesLogic_5_9 = _zz_s0_countOnesLogic_5_3;
      3'b011 : _zz_s0_countOnesLogic_5_9 = _zz_s0_countOnesLogic_5_4;
      3'b100 : _zz_s0_countOnesLogic_5_9 = _zz_s0_countOnesLogic_5_5;
      3'b101 : _zz_s0_countOnesLogic_5_9 = _zz_s0_countOnesLogic_5_6;
      3'b110 : _zz_s0_countOnesLogic_5_9 = _zz_s0_countOnesLogic_5_7;
      default : _zz_s0_countOnesLogic_5_9 = _zz_s0_countOnesLogic_5_8;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_5_12)
      3'b000 : _zz_s0_countOnesLogic_5_11 = _zz_s0_countOnesLogic_5_1;
      3'b001 : _zz_s0_countOnesLogic_5_11 = _zz_s0_countOnesLogic_5_2;
      3'b010 : _zz_s0_countOnesLogic_5_11 = _zz_s0_countOnesLogic_5_3;
      3'b011 : _zz_s0_countOnesLogic_5_11 = _zz_s0_countOnesLogic_5_4;
      3'b100 : _zz_s0_countOnesLogic_5_11 = _zz_s0_countOnesLogic_5_5;
      3'b101 : _zz_s0_countOnesLogic_5_11 = _zz_s0_countOnesLogic_5_6;
      3'b110 : _zz_s0_countOnesLogic_5_11 = _zz_s0_countOnesLogic_5_7;
      default : _zz_s0_countOnesLogic_5_11 = _zz_s0_countOnesLogic_5_8;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_6_11)
      3'b000 : _zz_s0_countOnesLogic_6_10 = _zz_s0_countOnesLogic_6_1;
      3'b001 : _zz_s0_countOnesLogic_6_10 = _zz_s0_countOnesLogic_6_2;
      3'b010 : _zz_s0_countOnesLogic_6_10 = _zz_s0_countOnesLogic_6_3;
      3'b011 : _zz_s0_countOnesLogic_6_10 = _zz_s0_countOnesLogic_6_4;
      3'b100 : _zz_s0_countOnesLogic_6_10 = _zz_s0_countOnesLogic_6_5;
      3'b101 : _zz_s0_countOnesLogic_6_10 = _zz_s0_countOnesLogic_6_6;
      3'b110 : _zz_s0_countOnesLogic_6_10 = _zz_s0_countOnesLogic_6_7;
      default : _zz_s0_countOnesLogic_6_10 = _zz_s0_countOnesLogic_6_8;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_6_13)
      3'b000 : _zz_s0_countOnesLogic_6_12 = _zz_s0_countOnesLogic_6_1;
      3'b001 : _zz_s0_countOnesLogic_6_12 = _zz_s0_countOnesLogic_6_2;
      3'b010 : _zz_s0_countOnesLogic_6_12 = _zz_s0_countOnesLogic_6_3;
      3'b011 : _zz_s0_countOnesLogic_6_12 = _zz_s0_countOnesLogic_6_4;
      3'b100 : _zz_s0_countOnesLogic_6_12 = _zz_s0_countOnesLogic_6_5;
      3'b101 : _zz_s0_countOnesLogic_6_12 = _zz_s0_countOnesLogic_6_6;
      3'b110 : _zz_s0_countOnesLogic_6_12 = _zz_s0_countOnesLogic_6_7;
      default : _zz_s0_countOnesLogic_6_12 = _zz_s0_countOnesLogic_6_8;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_6_15)
      3'b000 : _zz_s0_countOnesLogic_6_14 = _zz_s0_countOnesLogic_6_1;
      3'b001 : _zz_s0_countOnesLogic_6_14 = _zz_s0_countOnesLogic_6_2;
      3'b010 : _zz_s0_countOnesLogic_6_14 = _zz_s0_countOnesLogic_6_3;
      3'b011 : _zz_s0_countOnesLogic_6_14 = _zz_s0_countOnesLogic_6_4;
      3'b100 : _zz_s0_countOnesLogic_6_14 = _zz_s0_countOnesLogic_6_5;
      3'b101 : _zz_s0_countOnesLogic_6_14 = _zz_s0_countOnesLogic_6_6;
      3'b110 : _zz_s0_countOnesLogic_6_14 = _zz_s0_countOnesLogic_6_7;
      default : _zz_s0_countOnesLogic_6_14 = _zz_s0_countOnesLogic_6_8;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_7_10)
      3'b000 : _zz_s0_countOnesLogic_7_9 = _zz_s0_countOnesLogic_7;
      3'b001 : _zz_s0_countOnesLogic_7_9 = _zz_s0_countOnesLogic_7_1;
      3'b010 : _zz_s0_countOnesLogic_7_9 = _zz_s0_countOnesLogic_7_2;
      3'b011 : _zz_s0_countOnesLogic_7_9 = _zz_s0_countOnesLogic_7_3;
      3'b100 : _zz_s0_countOnesLogic_7_9 = _zz_s0_countOnesLogic_7_4;
      3'b101 : _zz_s0_countOnesLogic_7_9 = _zz_s0_countOnesLogic_7_5;
      3'b110 : _zz_s0_countOnesLogic_7_9 = _zz_s0_countOnesLogic_7_6;
      default : _zz_s0_countOnesLogic_7_9 = _zz_s0_countOnesLogic_7_7;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_7_12)
      3'b000 : _zz_s0_countOnesLogic_7_11 = _zz_s0_countOnesLogic_7;
      3'b001 : _zz_s0_countOnesLogic_7_11 = _zz_s0_countOnesLogic_7_1;
      3'b010 : _zz_s0_countOnesLogic_7_11 = _zz_s0_countOnesLogic_7_2;
      3'b011 : _zz_s0_countOnesLogic_7_11 = _zz_s0_countOnesLogic_7_3;
      3'b100 : _zz_s0_countOnesLogic_7_11 = _zz_s0_countOnesLogic_7_4;
      3'b101 : _zz_s0_countOnesLogic_7_11 = _zz_s0_countOnesLogic_7_5;
      3'b110 : _zz_s0_countOnesLogic_7_11 = _zz_s0_countOnesLogic_7_6;
      default : _zz_s0_countOnesLogic_7_11 = _zz_s0_countOnesLogic_7_7;
    endcase
  end

  always @(*) begin
    case(_zz_s0_countOnesLogic_7_14)
      3'b000 : _zz_s0_countOnesLogic_7_13 = _zz_s0_countOnesLogic_7;
      3'b001 : _zz_s0_countOnesLogic_7_13 = _zz_s0_countOnesLogic_7_1;
      3'b010 : _zz_s0_countOnesLogic_7_13 = _zz_s0_countOnesLogic_7_2;
      3'b011 : _zz_s0_countOnesLogic_7_13 = _zz_s0_countOnesLogic_7_3;
      3'b100 : _zz_s0_countOnesLogic_7_13 = _zz_s0_countOnesLogic_7_4;
      3'b101 : _zz_s0_countOnesLogic_7_13 = _zz_s0_countOnesLogic_7_5;
      3'b110 : _zz_s0_countOnesLogic_7_13 = _zz_s0_countOnesLogic_7_6;
      default : _zz_s0_countOnesLogic_7_13 = _zz_s0_countOnesLogic_7_7;
    endcase
  end

  always @(*) begin
    case(s2_input_payload_sel_0)
      3'b000 : _zz_s2_byteLogic_0_inputData = s2_inputDataBytes_0;
      3'b001 : _zz_s2_byteLogic_0_inputData = s2_inputDataBytes_1;
      3'b010 : _zz_s2_byteLogic_0_inputData = s2_inputDataBytes_2;
      3'b011 : _zz_s2_byteLogic_0_inputData = s2_inputDataBytes_3;
      3'b100 : _zz_s2_byteLogic_0_inputData = s2_inputDataBytes_4;
      3'b101 : _zz_s2_byteLogic_0_inputData = s2_inputDataBytes_5;
      3'b110 : _zz_s2_byteLogic_0_inputData = s2_inputDataBytes_6;
      default : _zz_s2_byteLogic_0_inputData = s2_inputDataBytes_7;
    endcase
  end

  always @(*) begin
    case(s2_input_payload_sel_1)
      3'b000 : _zz_s2_byteLogic_1_inputData = s2_inputDataBytes_0;
      3'b001 : _zz_s2_byteLogic_1_inputData = s2_inputDataBytes_1;
      3'b010 : _zz_s2_byteLogic_1_inputData = s2_inputDataBytes_2;
      3'b011 : _zz_s2_byteLogic_1_inputData = s2_inputDataBytes_3;
      3'b100 : _zz_s2_byteLogic_1_inputData = s2_inputDataBytes_4;
      3'b101 : _zz_s2_byteLogic_1_inputData = s2_inputDataBytes_5;
      3'b110 : _zz_s2_byteLogic_1_inputData = s2_inputDataBytes_6;
      default : _zz_s2_byteLogic_1_inputData = s2_inputDataBytes_7;
    endcase
  end

  always @(*) begin
    case(s2_input_payload_sel_2)
      3'b000 : _zz_s2_byteLogic_2_inputData = s2_inputDataBytes_0;
      3'b001 : _zz_s2_byteLogic_2_inputData = s2_inputDataBytes_1;
      3'b010 : _zz_s2_byteLogic_2_inputData = s2_inputDataBytes_2;
      3'b011 : _zz_s2_byteLogic_2_inputData = s2_inputDataBytes_3;
      3'b100 : _zz_s2_byteLogic_2_inputData = s2_inputDataBytes_4;
      3'b101 : _zz_s2_byteLogic_2_inputData = s2_inputDataBytes_5;
      3'b110 : _zz_s2_byteLogic_2_inputData = s2_inputDataBytes_6;
      default : _zz_s2_byteLogic_2_inputData = s2_inputDataBytes_7;
    endcase
  end

  always @(*) begin
    case(s2_input_payload_sel_3)
      3'b000 : _zz_s2_byteLogic_3_inputData = s2_inputDataBytes_0;
      3'b001 : _zz_s2_byteLogic_3_inputData = s2_inputDataBytes_1;
      3'b010 : _zz_s2_byteLogic_3_inputData = s2_inputDataBytes_2;
      3'b011 : _zz_s2_byteLogic_3_inputData = s2_inputDataBytes_3;
      3'b100 : _zz_s2_byteLogic_3_inputData = s2_inputDataBytes_4;
      3'b101 : _zz_s2_byteLogic_3_inputData = s2_inputDataBytes_5;
      3'b110 : _zz_s2_byteLogic_3_inputData = s2_inputDataBytes_6;
      default : _zz_s2_byteLogic_3_inputData = s2_inputDataBytes_7;
    endcase
  end

  always @(*) begin
    case(s2_input_payload_sel_4)
      3'b000 : _zz_s2_byteLogic_4_inputData = s2_inputDataBytes_0;
      3'b001 : _zz_s2_byteLogic_4_inputData = s2_inputDataBytes_1;
      3'b010 : _zz_s2_byteLogic_4_inputData = s2_inputDataBytes_2;
      3'b011 : _zz_s2_byteLogic_4_inputData = s2_inputDataBytes_3;
      3'b100 : _zz_s2_byteLogic_4_inputData = s2_inputDataBytes_4;
      3'b101 : _zz_s2_byteLogic_4_inputData = s2_inputDataBytes_5;
      3'b110 : _zz_s2_byteLogic_4_inputData = s2_inputDataBytes_6;
      default : _zz_s2_byteLogic_4_inputData = s2_inputDataBytes_7;
    endcase
  end

  always @(*) begin
    case(s2_input_payload_sel_5)
      3'b000 : _zz_s2_byteLogic_5_inputData = s2_inputDataBytes_0;
      3'b001 : _zz_s2_byteLogic_5_inputData = s2_inputDataBytes_1;
      3'b010 : _zz_s2_byteLogic_5_inputData = s2_inputDataBytes_2;
      3'b011 : _zz_s2_byteLogic_5_inputData = s2_inputDataBytes_3;
      3'b100 : _zz_s2_byteLogic_5_inputData = s2_inputDataBytes_4;
      3'b101 : _zz_s2_byteLogic_5_inputData = s2_inputDataBytes_5;
      3'b110 : _zz_s2_byteLogic_5_inputData = s2_inputDataBytes_6;
      default : _zz_s2_byteLogic_5_inputData = s2_inputDataBytes_7;
    endcase
  end

  always @(*) begin
    case(s2_input_payload_sel_6)
      3'b000 : _zz_s2_byteLogic_6_inputData = s2_inputDataBytes_0;
      3'b001 : _zz_s2_byteLogic_6_inputData = s2_inputDataBytes_1;
      3'b010 : _zz_s2_byteLogic_6_inputData = s2_inputDataBytes_2;
      3'b011 : _zz_s2_byteLogic_6_inputData = s2_inputDataBytes_3;
      3'b100 : _zz_s2_byteLogic_6_inputData = s2_inputDataBytes_4;
      3'b101 : _zz_s2_byteLogic_6_inputData = s2_inputDataBytes_5;
      3'b110 : _zz_s2_byteLogic_6_inputData = s2_inputDataBytes_6;
      default : _zz_s2_byteLogic_6_inputData = s2_inputDataBytes_7;
    endcase
  end

  always @(*) begin
    case(s2_input_payload_sel_7)
      3'b000 : _zz_s2_byteLogic_7_inputData = s2_inputDataBytes_0;
      3'b001 : _zz_s2_byteLogic_7_inputData = s2_inputDataBytes_1;
      3'b010 : _zz_s2_byteLogic_7_inputData = s2_inputDataBytes_2;
      3'b011 : _zz_s2_byteLogic_7_inputData = s2_inputDataBytes_3;
      3'b100 : _zz_s2_byteLogic_7_inputData = s2_inputDataBytes_4;
      3'b101 : _zz_s2_byteLogic_7_inputData = s2_inputDataBytes_5;
      3'b110 : _zz_s2_byteLogic_7_inputData = s2_inputDataBytes_6;
      default : _zz_s2_byteLogic_7_inputData = s2_inputDataBytes_7;
    endcase
  end

  always @(*) begin
    case(_zz_io_output_usedUntil_4)
      3'b000 : _zz_io_output_usedUntil_3 = s2_input_payload_sel_0;
      3'b001 : _zz_io_output_usedUntil_3 = s2_input_payload_sel_1;
      3'b010 : _zz_io_output_usedUntil_3 = s2_input_payload_sel_2;
      3'b011 : _zz_io_output_usedUntil_3 = s2_input_payload_sel_3;
      3'b100 : _zz_io_output_usedUntil_3 = s2_input_payload_sel_4;
      3'b101 : _zz_io_output_usedUntil_3 = s2_input_payload_sel_5;
      3'b110 : _zz_io_output_usedUntil_3 = s2_input_payload_sel_6;
      default : _zz_io_output_usedUntil_3 = s2_input_payload_sel_7;
    endcase
  end

  always @(*) begin
    io_input_ready = s0_input_ready;
    if(when_Stream_l375) begin
      io_input_ready = 1'b1;
    end
  end

  assign when_Stream_l375 = (! s0_input_valid);
  assign s0_input_valid = io_input_rValid;
  assign s0_input_payload_data = io_input_rData_data;
  assign s0_input_payload_mask = io_input_rData_mask;
  assign _zz_s0_countOnesLogic_0 = s0_input_payload_mask[0];
  assign _zz_s0_countOnesLogic_1 = s0_input_payload_mask[1];
  assign _zz_s0_countOnesLogic_2 = s0_input_payload_mask[2];
  assign _zz_s0_countOnesLogic_3 = s0_input_payload_mask[3];
  assign _zz_s0_countOnesLogic_4 = s0_input_payload_mask[4];
  assign _zz_s0_countOnesLogic_5 = s0_input_payload_mask[5];
  assign _zz_s0_countOnesLogic_6 = s0_input_payload_mask[6];
  assign s0_countOnesLogic_0 = _zz_s0_countOnesLogic_0_1;
  assign s0_countOnesLogic_1 = _zz_s0_countOnesLogic_1_1;
  assign s0_countOnesLogic_2 = _zz_s0_countOnesLogic_2_1;
  assign _zz_s0_countOnesLogic_3_1 = 3'b000;
  assign _zz_s0_countOnesLogic_3_2 = 3'b001;
  assign _zz_s0_countOnesLogic_3_3 = 3'b001;
  assign _zz_s0_countOnesLogic_3_4 = 3'b010;
  assign _zz_s0_countOnesLogic_3_5 = 3'b001;
  assign _zz_s0_countOnesLogic_3_6 = 3'b010;
  assign _zz_s0_countOnesLogic_3_7 = 3'b010;
  assign _zz_s0_countOnesLogic_3_8 = 3'b011;
  assign s0_countOnesLogic_3 = (_zz_s0_countOnesLogic_3_9 + _zz_s0_countOnesLogic_3_11);
  assign _zz_s0_countOnesLogic_4_1 = 3'b000;
  assign _zz_s0_countOnesLogic_4_2 = 3'b001;
  assign _zz_s0_countOnesLogic_4_3 = 3'b001;
  assign _zz_s0_countOnesLogic_4_4 = 3'b010;
  assign _zz_s0_countOnesLogic_4_5 = 3'b001;
  assign _zz_s0_countOnesLogic_4_6 = 3'b010;
  assign _zz_s0_countOnesLogic_4_7 = 3'b010;
  assign _zz_s0_countOnesLogic_4_8 = 3'b011;
  assign s0_countOnesLogic_4 = (_zz_s0_countOnesLogic_4_9 + _zz_s0_countOnesLogic_4_11);
  assign _zz_s0_countOnesLogic_5_1 = 3'b000;
  assign _zz_s0_countOnesLogic_5_2 = 3'b001;
  assign _zz_s0_countOnesLogic_5_3 = 3'b001;
  assign _zz_s0_countOnesLogic_5_4 = 3'b010;
  assign _zz_s0_countOnesLogic_5_5 = 3'b001;
  assign _zz_s0_countOnesLogic_5_6 = 3'b010;
  assign _zz_s0_countOnesLogic_5_7 = 3'b010;
  assign _zz_s0_countOnesLogic_5_8 = 3'b011;
  assign s0_countOnesLogic_5 = (_zz_s0_countOnesLogic_5_9 + _zz_s0_countOnesLogic_5_11);
  assign _zz_s0_countOnesLogic_6_1 = 3'b000;
  assign _zz_s0_countOnesLogic_6_2 = 3'b001;
  assign _zz_s0_countOnesLogic_6_3 = 3'b001;
  assign _zz_s0_countOnesLogic_6_4 = 3'b010;
  assign _zz_s0_countOnesLogic_6_5 = 3'b001;
  assign _zz_s0_countOnesLogic_6_6 = 3'b010;
  assign _zz_s0_countOnesLogic_6_7 = 3'b010;
  assign _zz_s0_countOnesLogic_6_8 = 3'b011;
  assign s0_countOnesLogic_6 = (_zz_s0_countOnesLogic_6_9 + _zz_s0_countOnesLogic_6_14);
  assign _zz_s0_countOnesLogic_7 = 4'b0000;
  assign _zz_s0_countOnesLogic_7_1 = 4'b0001;
  assign _zz_s0_countOnesLogic_7_2 = 4'b0001;
  assign _zz_s0_countOnesLogic_7_3 = 4'b0010;
  assign _zz_s0_countOnesLogic_7_4 = 4'b0001;
  assign _zz_s0_countOnesLogic_7_5 = 4'b0010;
  assign _zz_s0_countOnesLogic_7_6 = 4'b0010;
  assign _zz_s0_countOnesLogic_7_7 = 4'b0011;
  assign s0_countOnesLogic_7 = (_zz_s0_countOnesLogic_7_8 + _zz_s0_countOnesLogic_7_13);
  assign s0_outputPayload_cmd_data = s0_input_payload_data;
  assign s0_outputPayload_cmd_mask = s0_input_payload_mask;
  assign s0_outputPayload_countOnes_0 = s0_countOnesLogic_0;
  assign s0_outputPayload_countOnes_1 = s0_countOnesLogic_1;
  assign s0_outputPayload_countOnes_2 = s0_countOnesLogic_2;
  assign s0_outputPayload_countOnes_3 = s0_countOnesLogic_3;
  assign s0_outputPayload_countOnes_4 = s0_countOnesLogic_4;
  assign s0_outputPayload_countOnes_5 = s0_countOnesLogic_5;
  assign s0_outputPayload_countOnes_6 = s0_countOnesLogic_6;
  assign s0_outputPayload_countOnes_7 = s0_countOnesLogic_7;
  assign s0_output_valid = s0_input_valid;
  assign s0_input_ready = s0_output_ready;
  assign s0_output_payload_cmd_data = s0_outputPayload_cmd_data;
  assign s0_output_payload_cmd_mask = s0_outputPayload_cmd_mask;
  assign s0_output_payload_countOnes_0 = s0_outputPayload_countOnes_0;
  assign s0_output_payload_countOnes_1 = s0_outputPayload_countOnes_1;
  assign s0_output_payload_countOnes_2 = s0_outputPayload_countOnes_2;
  assign s0_output_payload_countOnes_3 = s0_outputPayload_countOnes_3;
  assign s0_output_payload_countOnes_4 = s0_outputPayload_countOnes_4;
  assign s0_output_payload_countOnes_5 = s0_outputPayload_countOnes_5;
  assign s0_output_payload_countOnes_6 = s0_outputPayload_countOnes_6;
  assign s0_output_payload_countOnes_7 = s0_outputPayload_countOnes_7;
  always @(*) begin
    s0_output_ready = s1_input_ready;
    if(when_Stream_l375_1) begin
      s0_output_ready = 1'b1;
    end
  end

  assign when_Stream_l375_1 = (! s1_input_valid);
  assign s1_input_valid = s0_output_rValid;
  assign s1_input_payload_cmd_data = s0_output_rData_cmd_data;
  assign s1_input_payload_cmd_mask = s0_output_rData_cmd_mask;
  assign s1_input_payload_countOnes_0 = s0_output_rData_countOnes_0;
  assign s1_input_payload_countOnes_1 = s0_output_rData_countOnes_1;
  assign s1_input_payload_countOnes_2 = s0_output_rData_countOnes_2;
  assign s1_input_payload_countOnes_3 = s0_output_rData_countOnes_3;
  assign s1_input_payload_countOnes_4 = s0_output_rData_countOnes_4;
  assign s1_input_payload_countOnes_5 = s0_output_rData_countOnes_5;
  assign s1_input_payload_countOnes_6 = s0_output_rData_countOnes_6;
  assign s1_input_payload_countOnes_7 = s0_output_rData_countOnes_7;
  assign s1_offsetNext = (_zz_s1_offsetNext + s1_input_payload_countOnes_7);
  assign s1_input_fire = (s1_input_valid && s1_input_ready);
  assign s1_inputIndexes_0 = (3'b000 + s1_offset);
  assign s1_inputIndexes_1 = (_zz_s1_inputIndexes_1 + s1_offset);
  assign s1_inputIndexes_2 = (_zz_s1_inputIndexes_2 + s1_offset);
  assign s1_inputIndexes_3 = (_zz_s1_inputIndexes_3 + s1_offset);
  assign s1_inputIndexes_4 = (s1_input_payload_countOnes_3 + s1_offset);
  assign s1_inputIndexes_5 = (s1_input_payload_countOnes_4 + s1_offset);
  assign s1_inputIndexes_6 = (s1_input_payload_countOnes_5 + s1_offset);
  assign s1_inputIndexes_7 = (s1_input_payload_countOnes_6 + s1_offset);
  assign s1_outputPayload_cmd_data = s1_input_payload_cmd_data;
  assign s1_outputPayload_cmd_mask = s1_input_payload_cmd_mask;
  assign s1_outputPayload_index_0 = s1_inputIndexes_0;
  assign s1_outputPayload_index_1 = s1_inputIndexes_1;
  assign s1_outputPayload_index_2 = s1_inputIndexes_2;
  assign s1_outputPayload_index_3 = s1_inputIndexes_3;
  assign s1_outputPayload_index_4 = s1_inputIndexes_4;
  assign s1_outputPayload_index_5 = s1_inputIndexes_5;
  assign s1_outputPayload_index_6 = s1_inputIndexes_6;
  assign s1_outputPayload_index_7 = s1_inputIndexes_7;
  assign s1_outputPayload_last = s1_offsetNext[3];
  assign _zz_s1_outputPayload_selValid = (s1_input_payload_cmd_mask[1] && (s1_inputIndexes_1 == 3'b000));
  assign _zz_s1_outputPayload_selValid_1 = (s1_input_payload_cmd_mask[2] && (s1_inputIndexes_2 == 3'b000));
  assign _zz_s1_outputPayload_selValid_2 = (s1_input_payload_cmd_mask[3] && (s1_inputIndexes_3 == 3'b000));
  assign _zz_s1_outputPayload_selValid_3 = (s1_input_payload_cmd_mask[4] && (s1_inputIndexes_4 == 3'b000));
  assign _zz_s1_outputPayload_selValid_4 = (s1_input_payload_cmd_mask[5] && (s1_inputIndexes_5 == 3'b000));
  assign _zz_s1_outputPayload_selValid_5 = (s1_input_payload_cmd_mask[6] && (s1_inputIndexes_6 == 3'b000));
  assign _zz_s1_outputPayload_selValid_6 = (s1_input_payload_cmd_mask[7] && (s1_inputIndexes_7 == 3'b000));
  assign _zz_s1_outputPayload_sel_0 = (((_zz_s1_outputPayload_selValid || _zz_s1_outputPayload_selValid_2) || _zz_s1_outputPayload_selValid_4) || _zz_s1_outputPayload_selValid_6);
  assign _zz_s1_outputPayload_sel_0_1 = (((_zz_s1_outputPayload_selValid_1 || _zz_s1_outputPayload_selValid_2) || _zz_s1_outputPayload_selValid_5) || _zz_s1_outputPayload_selValid_6);
  assign _zz_s1_outputPayload_sel_0_2 = (((_zz_s1_outputPayload_selValid_3 || _zz_s1_outputPayload_selValid_4) || _zz_s1_outputPayload_selValid_5) || _zz_s1_outputPayload_selValid_6);
  assign s1_outputPayload_sel_0 = {_zz_s1_outputPayload_sel_0_2,{_zz_s1_outputPayload_sel_0_1,_zz_s1_outputPayload_sel_0}};
  always @(*) begin
    s1_outputPayload_selValid[0] = ((|{_zz_s1_outputPayload_selValid_6,{_zz_s1_outputPayload_selValid_5,{_zz_s1_outputPayload_selValid_4,{_zz_s1_outputPayload_selValid_3,{_zz_s1_outputPayload_selValid_2,{_zz_s1_outputPayload_selValid_1,{_zz_s1_outputPayload_selValid,(s1_input_payload_cmd_mask[0] && (s1_inputIndexes_0 == _zz_s1_outputPayload_selValid_56))}}}}}}}) && s1_outputPayload_cmd_mask[s1_outputPayload_sel_0]);
    s1_outputPayload_selValid[1] = ((|{_zz_s1_outputPayload_selValid_13,{_zz_s1_outputPayload_selValid_12,{_zz_s1_outputPayload_selValid_11,{_zz_s1_outputPayload_selValid_10,{_zz_s1_outputPayload_selValid_9,{_zz_s1_outputPayload_selValid_8,{_zz_s1_outputPayload_selValid_7,(s1_input_payload_cmd_mask[0] && (s1_inputIndexes_0 == 3'b001))}}}}}}}) && s1_outputPayload_cmd_mask[s1_outputPayload_sel_1]);
    s1_outputPayload_selValid[2] = ((|{_zz_s1_outputPayload_selValid_20,{_zz_s1_outputPayload_selValid_19,{_zz_s1_outputPayload_selValid_18,{_zz_s1_outputPayload_selValid_17,{_zz_s1_outputPayload_selValid_16,{_zz_s1_outputPayload_selValid_15,{_zz_s1_outputPayload_selValid_14,(s1_input_payload_cmd_mask[0] && (s1_inputIndexes_0 == 3'b010))}}}}}}}) && s1_outputPayload_cmd_mask[s1_outputPayload_sel_2]);
    s1_outputPayload_selValid[3] = ((|{_zz_s1_outputPayload_selValid_27,{_zz_s1_outputPayload_selValid_26,{_zz_s1_outputPayload_selValid_25,{_zz_s1_outputPayload_selValid_24,{_zz_s1_outputPayload_selValid_23,{_zz_s1_outputPayload_selValid_22,{_zz_s1_outputPayload_selValid_21,(s1_input_payload_cmd_mask[0] && (s1_inputIndexes_0 == 3'b011))}}}}}}}) && s1_outputPayload_cmd_mask[s1_outputPayload_sel_3]);
    s1_outputPayload_selValid[4] = ((|{_zz_s1_outputPayload_selValid_34,{_zz_s1_outputPayload_selValid_33,{_zz_s1_outputPayload_selValid_32,{_zz_s1_outputPayload_selValid_31,{_zz_s1_outputPayload_selValid_30,{_zz_s1_outputPayload_selValid_29,{_zz_s1_outputPayload_selValid_28,(s1_input_payload_cmd_mask[0] && (s1_inputIndexes_0 == 3'b100))}}}}}}}) && s1_outputPayload_cmd_mask[s1_outputPayload_sel_4]);
    s1_outputPayload_selValid[5] = ((|{_zz_s1_outputPayload_selValid_41,{_zz_s1_outputPayload_selValid_40,{_zz_s1_outputPayload_selValid_39,{_zz_s1_outputPayload_selValid_38,{_zz_s1_outputPayload_selValid_37,{_zz_s1_outputPayload_selValid_36,{_zz_s1_outputPayload_selValid_35,(s1_input_payload_cmd_mask[0] && (s1_inputIndexes_0 == 3'b101))}}}}}}}) && s1_outputPayload_cmd_mask[s1_outputPayload_sel_5]);
    s1_outputPayload_selValid[6] = ((|{_zz_s1_outputPayload_selValid_48,{_zz_s1_outputPayload_selValid_47,{_zz_s1_outputPayload_selValid_46,{_zz_s1_outputPayload_selValid_45,{_zz_s1_outputPayload_selValid_44,{_zz_s1_outputPayload_selValid_43,{_zz_s1_outputPayload_selValid_42,(s1_input_payload_cmd_mask[0] && (s1_inputIndexes_0 == 3'b110))}}}}}}}) && s1_outputPayload_cmd_mask[s1_outputPayload_sel_6]);
    s1_outputPayload_selValid[7] = ((|{_zz_s1_outputPayload_selValid_55,{_zz_s1_outputPayload_selValid_54,{_zz_s1_outputPayload_selValid_53,{_zz_s1_outputPayload_selValid_52,{_zz_s1_outputPayload_selValid_51,{_zz_s1_outputPayload_selValid_50,{_zz_s1_outputPayload_selValid_49,(s1_input_payload_cmd_mask[0] && (s1_inputIndexes_0 == 3'b111))}}}}}}}) && s1_outputPayload_cmd_mask[s1_outputPayload_sel_7]);
  end

  assign _zz_s1_outputPayload_selValid_7 = (s1_input_payload_cmd_mask[1] && (s1_inputIndexes_1 == 3'b001));
  assign _zz_s1_outputPayload_selValid_8 = (s1_input_payload_cmd_mask[2] && (s1_inputIndexes_2 == 3'b001));
  assign _zz_s1_outputPayload_selValid_9 = (s1_input_payload_cmd_mask[3] && (s1_inputIndexes_3 == 3'b001));
  assign _zz_s1_outputPayload_selValid_10 = (s1_input_payload_cmd_mask[4] && (s1_inputIndexes_4 == 3'b001));
  assign _zz_s1_outputPayload_selValid_11 = (s1_input_payload_cmd_mask[5] && (s1_inputIndexes_5 == 3'b001));
  assign _zz_s1_outputPayload_selValid_12 = (s1_input_payload_cmd_mask[6] && (s1_inputIndexes_6 == 3'b001));
  assign _zz_s1_outputPayload_selValid_13 = (s1_input_payload_cmd_mask[7] && (s1_inputIndexes_7 == 3'b001));
  assign _zz_s1_outputPayload_sel_1 = (((_zz_s1_outputPayload_selValid_7 || _zz_s1_outputPayload_selValid_9) || _zz_s1_outputPayload_selValid_11) || _zz_s1_outputPayload_selValid_13);
  assign _zz_s1_outputPayload_sel_1_1 = (((_zz_s1_outputPayload_selValid_8 || _zz_s1_outputPayload_selValid_9) || _zz_s1_outputPayload_selValid_12) || _zz_s1_outputPayload_selValid_13);
  assign _zz_s1_outputPayload_sel_1_2 = (((_zz_s1_outputPayload_selValid_10 || _zz_s1_outputPayload_selValid_11) || _zz_s1_outputPayload_selValid_12) || _zz_s1_outputPayload_selValid_13);
  assign s1_outputPayload_sel_1 = {_zz_s1_outputPayload_sel_1_2,{_zz_s1_outputPayload_sel_1_1,_zz_s1_outputPayload_sel_1}};
  assign _zz_s1_outputPayload_selValid_14 = (s1_input_payload_cmd_mask[1] && (s1_inputIndexes_1 == 3'b010));
  assign _zz_s1_outputPayload_selValid_15 = (s1_input_payload_cmd_mask[2] && (s1_inputIndexes_2 == 3'b010));
  assign _zz_s1_outputPayload_selValid_16 = (s1_input_payload_cmd_mask[3] && (s1_inputIndexes_3 == 3'b010));
  assign _zz_s1_outputPayload_selValid_17 = (s1_input_payload_cmd_mask[4] && (s1_inputIndexes_4 == 3'b010));
  assign _zz_s1_outputPayload_selValid_18 = (s1_input_payload_cmd_mask[5] && (s1_inputIndexes_5 == 3'b010));
  assign _zz_s1_outputPayload_selValid_19 = (s1_input_payload_cmd_mask[6] && (s1_inputIndexes_6 == 3'b010));
  assign _zz_s1_outputPayload_selValid_20 = (s1_input_payload_cmd_mask[7] && (s1_inputIndexes_7 == 3'b010));
  assign _zz_s1_outputPayload_sel_2 = (((_zz_s1_outputPayload_selValid_14 || _zz_s1_outputPayload_selValid_16) || _zz_s1_outputPayload_selValid_18) || _zz_s1_outputPayload_selValid_20);
  assign _zz_s1_outputPayload_sel_2_1 = (((_zz_s1_outputPayload_selValid_15 || _zz_s1_outputPayload_selValid_16) || _zz_s1_outputPayload_selValid_19) || _zz_s1_outputPayload_selValid_20);
  assign _zz_s1_outputPayload_sel_2_2 = (((_zz_s1_outputPayload_selValid_17 || _zz_s1_outputPayload_selValid_18) || _zz_s1_outputPayload_selValid_19) || _zz_s1_outputPayload_selValid_20);
  assign s1_outputPayload_sel_2 = {_zz_s1_outputPayload_sel_2_2,{_zz_s1_outputPayload_sel_2_1,_zz_s1_outputPayload_sel_2}};
  assign _zz_s1_outputPayload_selValid_21 = (s1_input_payload_cmd_mask[1] && (s1_inputIndexes_1 == 3'b011));
  assign _zz_s1_outputPayload_selValid_22 = (s1_input_payload_cmd_mask[2] && (s1_inputIndexes_2 == 3'b011));
  assign _zz_s1_outputPayload_selValid_23 = (s1_input_payload_cmd_mask[3] && (s1_inputIndexes_3 == 3'b011));
  assign _zz_s1_outputPayload_selValid_24 = (s1_input_payload_cmd_mask[4] && (s1_inputIndexes_4 == 3'b011));
  assign _zz_s1_outputPayload_selValid_25 = (s1_input_payload_cmd_mask[5] && (s1_inputIndexes_5 == 3'b011));
  assign _zz_s1_outputPayload_selValid_26 = (s1_input_payload_cmd_mask[6] && (s1_inputIndexes_6 == 3'b011));
  assign _zz_s1_outputPayload_selValid_27 = (s1_input_payload_cmd_mask[7] && (s1_inputIndexes_7 == 3'b011));
  assign _zz_s1_outputPayload_sel_3 = (((_zz_s1_outputPayload_selValid_21 || _zz_s1_outputPayload_selValid_23) || _zz_s1_outputPayload_selValid_25) || _zz_s1_outputPayload_selValid_27);
  assign _zz_s1_outputPayload_sel_3_1 = (((_zz_s1_outputPayload_selValid_22 || _zz_s1_outputPayload_selValid_23) || _zz_s1_outputPayload_selValid_26) || _zz_s1_outputPayload_selValid_27);
  assign _zz_s1_outputPayload_sel_3_2 = (((_zz_s1_outputPayload_selValid_24 || _zz_s1_outputPayload_selValid_25) || _zz_s1_outputPayload_selValid_26) || _zz_s1_outputPayload_selValid_27);
  assign s1_outputPayload_sel_3 = {_zz_s1_outputPayload_sel_3_2,{_zz_s1_outputPayload_sel_3_1,_zz_s1_outputPayload_sel_3}};
  assign _zz_s1_outputPayload_selValid_28 = (s1_input_payload_cmd_mask[1] && (s1_inputIndexes_1 == 3'b100));
  assign _zz_s1_outputPayload_selValid_29 = (s1_input_payload_cmd_mask[2] && (s1_inputIndexes_2 == 3'b100));
  assign _zz_s1_outputPayload_selValid_30 = (s1_input_payload_cmd_mask[3] && (s1_inputIndexes_3 == 3'b100));
  assign _zz_s1_outputPayload_selValid_31 = (s1_input_payload_cmd_mask[4] && (s1_inputIndexes_4 == 3'b100));
  assign _zz_s1_outputPayload_selValid_32 = (s1_input_payload_cmd_mask[5] && (s1_inputIndexes_5 == 3'b100));
  assign _zz_s1_outputPayload_selValid_33 = (s1_input_payload_cmd_mask[6] && (s1_inputIndexes_6 == 3'b100));
  assign _zz_s1_outputPayload_selValid_34 = (s1_input_payload_cmd_mask[7] && (s1_inputIndexes_7 == 3'b100));
  assign _zz_s1_outputPayload_sel_4 = (((_zz_s1_outputPayload_selValid_28 || _zz_s1_outputPayload_selValid_30) || _zz_s1_outputPayload_selValid_32) || _zz_s1_outputPayload_selValid_34);
  assign _zz_s1_outputPayload_sel_4_1 = (((_zz_s1_outputPayload_selValid_29 || _zz_s1_outputPayload_selValid_30) || _zz_s1_outputPayload_selValid_33) || _zz_s1_outputPayload_selValid_34);
  assign _zz_s1_outputPayload_sel_4_2 = (((_zz_s1_outputPayload_selValid_31 || _zz_s1_outputPayload_selValid_32) || _zz_s1_outputPayload_selValid_33) || _zz_s1_outputPayload_selValid_34);
  assign s1_outputPayload_sel_4 = {_zz_s1_outputPayload_sel_4_2,{_zz_s1_outputPayload_sel_4_1,_zz_s1_outputPayload_sel_4}};
  assign _zz_s1_outputPayload_selValid_35 = (s1_input_payload_cmd_mask[1] && (s1_inputIndexes_1 == 3'b101));
  assign _zz_s1_outputPayload_selValid_36 = (s1_input_payload_cmd_mask[2] && (s1_inputIndexes_2 == 3'b101));
  assign _zz_s1_outputPayload_selValid_37 = (s1_input_payload_cmd_mask[3] && (s1_inputIndexes_3 == 3'b101));
  assign _zz_s1_outputPayload_selValid_38 = (s1_input_payload_cmd_mask[4] && (s1_inputIndexes_4 == 3'b101));
  assign _zz_s1_outputPayload_selValid_39 = (s1_input_payload_cmd_mask[5] && (s1_inputIndexes_5 == 3'b101));
  assign _zz_s1_outputPayload_selValid_40 = (s1_input_payload_cmd_mask[6] && (s1_inputIndexes_6 == 3'b101));
  assign _zz_s1_outputPayload_selValid_41 = (s1_input_payload_cmd_mask[7] && (s1_inputIndexes_7 == 3'b101));
  assign _zz_s1_outputPayload_sel_5 = (((_zz_s1_outputPayload_selValid_35 || _zz_s1_outputPayload_selValid_37) || _zz_s1_outputPayload_selValid_39) || _zz_s1_outputPayload_selValid_41);
  assign _zz_s1_outputPayload_sel_5_1 = (((_zz_s1_outputPayload_selValid_36 || _zz_s1_outputPayload_selValid_37) || _zz_s1_outputPayload_selValid_40) || _zz_s1_outputPayload_selValid_41);
  assign _zz_s1_outputPayload_sel_5_2 = (((_zz_s1_outputPayload_selValid_38 || _zz_s1_outputPayload_selValid_39) || _zz_s1_outputPayload_selValid_40) || _zz_s1_outputPayload_selValid_41);
  assign s1_outputPayload_sel_5 = {_zz_s1_outputPayload_sel_5_2,{_zz_s1_outputPayload_sel_5_1,_zz_s1_outputPayload_sel_5}};
  assign _zz_s1_outputPayload_selValid_42 = (s1_input_payload_cmd_mask[1] && (s1_inputIndexes_1 == 3'b110));
  assign _zz_s1_outputPayload_selValid_43 = (s1_input_payload_cmd_mask[2] && (s1_inputIndexes_2 == 3'b110));
  assign _zz_s1_outputPayload_selValid_44 = (s1_input_payload_cmd_mask[3] && (s1_inputIndexes_3 == 3'b110));
  assign _zz_s1_outputPayload_selValid_45 = (s1_input_payload_cmd_mask[4] && (s1_inputIndexes_4 == 3'b110));
  assign _zz_s1_outputPayload_selValid_46 = (s1_input_payload_cmd_mask[5] && (s1_inputIndexes_5 == 3'b110));
  assign _zz_s1_outputPayload_selValid_47 = (s1_input_payload_cmd_mask[6] && (s1_inputIndexes_6 == 3'b110));
  assign _zz_s1_outputPayload_selValid_48 = (s1_input_payload_cmd_mask[7] && (s1_inputIndexes_7 == 3'b110));
  assign _zz_s1_outputPayload_sel_6 = (((_zz_s1_outputPayload_selValid_42 || _zz_s1_outputPayload_selValid_44) || _zz_s1_outputPayload_selValid_46) || _zz_s1_outputPayload_selValid_48);
  assign _zz_s1_outputPayload_sel_6_1 = (((_zz_s1_outputPayload_selValid_43 || _zz_s1_outputPayload_selValid_44) || _zz_s1_outputPayload_selValid_47) || _zz_s1_outputPayload_selValid_48);
  assign _zz_s1_outputPayload_sel_6_2 = (((_zz_s1_outputPayload_selValid_45 || _zz_s1_outputPayload_selValid_46) || _zz_s1_outputPayload_selValid_47) || _zz_s1_outputPayload_selValid_48);
  assign s1_outputPayload_sel_6 = {_zz_s1_outputPayload_sel_6_2,{_zz_s1_outputPayload_sel_6_1,_zz_s1_outputPayload_sel_6}};
  assign _zz_s1_outputPayload_selValid_49 = (s1_input_payload_cmd_mask[1] && (s1_inputIndexes_1 == 3'b111));
  assign _zz_s1_outputPayload_selValid_50 = (s1_input_payload_cmd_mask[2] && (s1_inputIndexes_2 == 3'b111));
  assign _zz_s1_outputPayload_selValid_51 = (s1_input_payload_cmd_mask[3] && (s1_inputIndexes_3 == 3'b111));
  assign _zz_s1_outputPayload_selValid_52 = (s1_input_payload_cmd_mask[4] && (s1_inputIndexes_4 == 3'b111));
  assign _zz_s1_outputPayload_selValid_53 = (s1_input_payload_cmd_mask[5] && (s1_inputIndexes_5 == 3'b111));
  assign _zz_s1_outputPayload_selValid_54 = (s1_input_payload_cmd_mask[6] && (s1_inputIndexes_6 == 3'b111));
  assign _zz_s1_outputPayload_selValid_55 = (s1_input_payload_cmd_mask[7] && (s1_inputIndexes_7 == 3'b111));
  assign _zz_s1_outputPayload_sel_7 = (((_zz_s1_outputPayload_selValid_49 || _zz_s1_outputPayload_selValid_51) || _zz_s1_outputPayload_selValid_53) || _zz_s1_outputPayload_selValid_55);
  assign _zz_s1_outputPayload_sel_7_1 = (((_zz_s1_outputPayload_selValid_50 || _zz_s1_outputPayload_selValid_51) || _zz_s1_outputPayload_selValid_54) || _zz_s1_outputPayload_selValid_55);
  assign _zz_s1_outputPayload_sel_7_2 = (((_zz_s1_outputPayload_selValid_52 || _zz_s1_outputPayload_selValid_53) || _zz_s1_outputPayload_selValid_54) || _zz_s1_outputPayload_selValid_55);
  assign s1_outputPayload_sel_7 = {_zz_s1_outputPayload_sel_7_2,{_zz_s1_outputPayload_sel_7_1,_zz_s1_outputPayload_sel_7}};
  assign s1_output_valid = s1_input_valid;
  assign s1_input_ready = s1_output_ready;
  assign s1_output_payload_cmd_data = s1_outputPayload_cmd_data;
  assign s1_output_payload_cmd_mask = s1_outputPayload_cmd_mask;
  assign s1_output_payload_index_0 = s1_outputPayload_index_0;
  assign s1_output_payload_index_1 = s1_outputPayload_index_1;
  assign s1_output_payload_index_2 = s1_outputPayload_index_2;
  assign s1_output_payload_index_3 = s1_outputPayload_index_3;
  assign s1_output_payload_index_4 = s1_outputPayload_index_4;
  assign s1_output_payload_index_5 = s1_outputPayload_index_5;
  assign s1_output_payload_index_6 = s1_outputPayload_index_6;
  assign s1_output_payload_index_7 = s1_outputPayload_index_7;
  assign s1_output_payload_last = s1_outputPayload_last;
  assign s1_output_payload_sel_0 = s1_outputPayload_sel_0;
  assign s1_output_payload_sel_1 = s1_outputPayload_sel_1;
  assign s1_output_payload_sel_2 = s1_outputPayload_sel_2;
  assign s1_output_payload_sel_3 = s1_outputPayload_sel_3;
  assign s1_output_payload_sel_4 = s1_outputPayload_sel_4;
  assign s1_output_payload_sel_5 = s1_outputPayload_sel_5;
  assign s1_output_payload_sel_6 = s1_outputPayload_sel_6;
  assign s1_output_payload_sel_7 = s1_outputPayload_sel_7;
  assign s1_output_payload_selValid = s1_outputPayload_selValid;
  always @(*) begin
    s1_output_ready = s2_input_ready;
    if(when_Stream_l375_2) begin
      s1_output_ready = 1'b1;
    end
  end

  assign when_Stream_l375_2 = (! s2_input_valid);
  assign s2_input_valid = s1_output_rValid;
  assign s2_input_payload_cmd_data = s1_output_rData_cmd_data;
  assign s2_input_payload_cmd_mask = s1_output_rData_cmd_mask;
  assign s2_input_payload_index_0 = s1_output_rData_index_0;
  assign s2_input_payload_index_1 = s1_output_rData_index_1;
  assign s2_input_payload_index_2 = s1_output_rData_index_2;
  assign s2_input_payload_index_3 = s1_output_rData_index_3;
  assign s2_input_payload_index_4 = s1_output_rData_index_4;
  assign s2_input_payload_index_5 = s1_output_rData_index_5;
  assign s2_input_payload_index_6 = s1_output_rData_index_6;
  assign s2_input_payload_index_7 = s1_output_rData_index_7;
  assign s2_input_payload_last = s1_output_rData_last;
  assign s2_input_payload_sel_0 = s1_output_rData_sel_0;
  assign s2_input_payload_sel_1 = s1_output_rData_sel_1;
  assign s2_input_payload_sel_2 = s1_output_rData_sel_2;
  assign s2_input_payload_sel_3 = s1_output_rData_sel_3;
  assign s2_input_payload_sel_4 = s1_output_rData_sel_4;
  assign s2_input_payload_sel_5 = s1_output_rData_sel_5;
  assign s2_input_payload_sel_6 = s1_output_rData_sel_6;
  assign s2_input_payload_sel_7 = s1_output_rData_sel_7;
  assign s2_input_payload_selValid = s1_output_rData_selValid;
  always @(*) begin
    s2_input_ready = ((! io_output_enough) || io_output_consume);
    if(when_DmaSg_l1464) begin
      s2_input_ready = 1'b0;
    end
  end

  assign when_DmaSg_l1464 = (_zz_when_DmaSg_l1464 < s1_byteCounter);
  assign s2_input_fire = (s2_input_valid && s2_input_ready);
  assign io_output_consumed = s2_input_fire;
  assign s2_inputDataBytes_0 = s2_input_payload_cmd_data[7 : 0];
  assign s2_inputDataBytes_1 = s2_input_payload_cmd_data[15 : 8];
  assign s2_inputDataBytes_2 = s2_input_payload_cmd_data[23 : 16];
  assign s2_inputDataBytes_3 = s2_input_payload_cmd_data[31 : 24];
  assign s2_inputDataBytes_4 = s2_input_payload_cmd_data[39 : 32];
  assign s2_inputDataBytes_5 = s2_input_payload_cmd_data[47 : 40];
  assign s2_inputDataBytes_6 = s2_input_payload_cmd_data[55 : 48];
  assign s2_inputDataBytes_7 = s2_input_payload_cmd_data[63 : 56];
  assign s2_byteLogic_0_lastUsed = (3'b000 == io_output_lastByteUsed);
  assign s2_byteLogic_0_inputMask = s2_input_payload_selValid[0];
  assign s2_byteLogic_0_inputData = _zz_s2_byteLogic_0_inputData;
  assign s2_byteLogic_0_outputMask = (s2_byteLogic_0_buffer_valid || (s2_input_valid && s2_byteLogic_0_inputMask));
  assign s2_byteLogic_0_outputData = (s2_byteLogic_0_buffer_valid ? s2_byteLogic_0_buffer_data : s2_byteLogic_0_inputData);
  always @(*) begin
    io_output_mask[0] = s2_byteLogic_0_outputMask;
    io_output_mask[1] = s2_byteLogic_1_outputMask;
    io_output_mask[2] = s2_byteLogic_2_outputMask;
    io_output_mask[3] = s2_byteLogic_3_outputMask;
    io_output_mask[4] = s2_byteLogic_4_outputMask;
    io_output_mask[5] = s2_byteLogic_5_outputMask;
    io_output_mask[6] = s2_byteLogic_6_outputMask;
    io_output_mask[7] = s2_byteLogic_7_outputMask;
  end

  always @(*) begin
    io_output_data[7 : 0] = s2_byteLogic_0_outputData;
    io_output_data[15 : 8] = s2_byteLogic_1_outputData;
    io_output_data[23 : 16] = s2_byteLogic_2_outputData;
    io_output_data[31 : 24] = s2_byteLogic_3_outputData;
    io_output_data[39 : 32] = s2_byteLogic_4_outputData;
    io_output_data[47 : 40] = s2_byteLogic_5_outputData;
    io_output_data[55 : 48] = s2_byteLogic_6_outputData;
    io_output_data[63 : 56] = s2_byteLogic_7_outputData;
  end

  assign when_DmaSg_l1493 = (s2_byteLogic_0_inputMask && ((! io_output_consume) || s2_byteLogic_0_buffer_valid));
  assign s2_byteLogic_1_lastUsed = (3'b001 == io_output_lastByteUsed);
  assign s2_byteLogic_1_inputMask = s2_input_payload_selValid[1];
  assign s2_byteLogic_1_inputData = _zz_s2_byteLogic_1_inputData;
  assign s2_byteLogic_1_outputMask = (s2_byteLogic_1_buffer_valid || (s2_input_valid && s2_byteLogic_1_inputMask));
  assign s2_byteLogic_1_outputData = (s2_byteLogic_1_buffer_valid ? s2_byteLogic_1_buffer_data : s2_byteLogic_1_inputData);
  assign when_DmaSg_l1493_1 = (s2_byteLogic_1_inputMask && ((! io_output_consume) || s2_byteLogic_1_buffer_valid));
  assign s2_byteLogic_2_lastUsed = (3'b010 == io_output_lastByteUsed);
  assign s2_byteLogic_2_inputMask = s2_input_payload_selValid[2];
  assign s2_byteLogic_2_inputData = _zz_s2_byteLogic_2_inputData;
  assign s2_byteLogic_2_outputMask = (s2_byteLogic_2_buffer_valid || (s2_input_valid && s2_byteLogic_2_inputMask));
  assign s2_byteLogic_2_outputData = (s2_byteLogic_2_buffer_valid ? s2_byteLogic_2_buffer_data : s2_byteLogic_2_inputData);
  assign when_DmaSg_l1493_2 = (s2_byteLogic_2_inputMask && ((! io_output_consume) || s2_byteLogic_2_buffer_valid));
  assign s2_byteLogic_3_lastUsed = (3'b011 == io_output_lastByteUsed);
  assign s2_byteLogic_3_inputMask = s2_input_payload_selValid[3];
  assign s2_byteLogic_3_inputData = _zz_s2_byteLogic_3_inputData;
  assign s2_byteLogic_3_outputMask = (s2_byteLogic_3_buffer_valid || (s2_input_valid && s2_byteLogic_3_inputMask));
  assign s2_byteLogic_3_outputData = (s2_byteLogic_3_buffer_valid ? s2_byteLogic_3_buffer_data : s2_byteLogic_3_inputData);
  assign when_DmaSg_l1493_3 = (s2_byteLogic_3_inputMask && ((! io_output_consume) || s2_byteLogic_3_buffer_valid));
  assign s2_byteLogic_4_lastUsed = (3'b100 == io_output_lastByteUsed);
  assign s2_byteLogic_4_inputMask = s2_input_payload_selValid[4];
  assign s2_byteLogic_4_inputData = _zz_s2_byteLogic_4_inputData;
  assign s2_byteLogic_4_outputMask = (s2_byteLogic_4_buffer_valid || (s2_input_valid && s2_byteLogic_4_inputMask));
  assign s2_byteLogic_4_outputData = (s2_byteLogic_4_buffer_valid ? s2_byteLogic_4_buffer_data : s2_byteLogic_4_inputData);
  assign when_DmaSg_l1493_4 = (s2_byteLogic_4_inputMask && ((! io_output_consume) || s2_byteLogic_4_buffer_valid));
  assign s2_byteLogic_5_lastUsed = (3'b101 == io_output_lastByteUsed);
  assign s2_byteLogic_5_inputMask = s2_input_payload_selValid[5];
  assign s2_byteLogic_5_inputData = _zz_s2_byteLogic_5_inputData;
  assign s2_byteLogic_5_outputMask = (s2_byteLogic_5_buffer_valid || (s2_input_valid && s2_byteLogic_5_inputMask));
  assign s2_byteLogic_5_outputData = (s2_byteLogic_5_buffer_valid ? s2_byteLogic_5_buffer_data : s2_byteLogic_5_inputData);
  assign when_DmaSg_l1493_5 = (s2_byteLogic_5_inputMask && ((! io_output_consume) || s2_byteLogic_5_buffer_valid));
  assign s2_byteLogic_6_lastUsed = (3'b110 == io_output_lastByteUsed);
  assign s2_byteLogic_6_inputMask = s2_input_payload_selValid[6];
  assign s2_byteLogic_6_inputData = _zz_s2_byteLogic_6_inputData;
  assign s2_byteLogic_6_outputMask = (s2_byteLogic_6_buffer_valid || (s2_input_valid && s2_byteLogic_6_inputMask));
  assign s2_byteLogic_6_outputData = (s2_byteLogic_6_buffer_valid ? s2_byteLogic_6_buffer_data : s2_byteLogic_6_inputData);
  assign when_DmaSg_l1493_6 = (s2_byteLogic_6_inputMask && ((! io_output_consume) || s2_byteLogic_6_buffer_valid));
  assign s2_byteLogic_7_lastUsed = (3'b111 == io_output_lastByteUsed);
  assign s2_byteLogic_7_inputMask = s2_input_payload_selValid[7];
  assign s2_byteLogic_7_inputData = _zz_s2_byteLogic_7_inputData;
  assign s2_byteLogic_7_outputMask = (s2_byteLogic_7_buffer_valid || (s2_input_valid && s2_byteLogic_7_inputMask));
  assign s2_byteLogic_7_outputData = (s2_byteLogic_7_buffer_valid ? s2_byteLogic_7_buffer_data : s2_byteLogic_7_inputData);
  assign when_DmaSg_l1493_7 = (s2_byteLogic_7_inputMask && ((! io_output_consume) || s2_byteLogic_7_buffer_valid));
  assign _zz_io_output_usedUntil = (((s2_byteLogic_1_lastUsed || s2_byteLogic_3_lastUsed) || s2_byteLogic_5_lastUsed) || s2_byteLogic_7_lastUsed);
  assign _zz_io_output_usedUntil_1 = (((s2_byteLogic_2_lastUsed || s2_byteLogic_3_lastUsed) || s2_byteLogic_6_lastUsed) || s2_byteLogic_7_lastUsed);
  assign _zz_io_output_usedUntil_2 = (((s2_byteLogic_4_lastUsed || s2_byteLogic_5_lastUsed) || s2_byteLogic_6_lastUsed) || s2_byteLogic_7_lastUsed);
  assign io_output_usedUntil = _zz_io_output_usedUntil_3;
  always @(posedge clk) begin
    if(reset) begin
      io_input_rValid <= 1'b0;
      s0_output_rValid <= 1'b0;
      s1_output_rValid <= 1'b0;
    end else begin
      if(io_input_ready) begin
        io_input_rValid <= io_input_valid;
      end
      if(io_flush) begin
        io_input_rValid <= 1'b0;
      end
      if(s0_output_ready) begin
        s0_output_rValid <= s0_output_valid;
      end
      if(io_flush) begin
        s0_output_rValid <= 1'b0;
      end
      if(s1_output_ready) begin
        s1_output_rValid <= s1_output_valid;
      end
      if(io_flush) begin
        s1_output_rValid <= 1'b0;
      end
    end
  end

  always @(posedge clk) begin
    if(io_input_ready) begin
      io_input_rData_data <= io_input_payload_data;
      io_input_rData_mask <= io_input_payload_mask;
    end
    if(s0_output_ready) begin
      s0_output_rData_cmd_data <= s0_output_payload_cmd_data;
      s0_output_rData_cmd_mask <= s0_output_payload_cmd_mask;
      s0_output_rData_countOnes_0 <= s0_output_payload_countOnes_0;
      s0_output_rData_countOnes_1 <= s0_output_payload_countOnes_1;
      s0_output_rData_countOnes_2 <= s0_output_payload_countOnes_2;
      s0_output_rData_countOnes_3 <= s0_output_payload_countOnes_3;
      s0_output_rData_countOnes_4 <= s0_output_payload_countOnes_4;
      s0_output_rData_countOnes_5 <= s0_output_payload_countOnes_5;
      s0_output_rData_countOnes_6 <= s0_output_payload_countOnes_6;
      s0_output_rData_countOnes_7 <= s0_output_payload_countOnes_7;
    end
    if(s1_input_fire) begin
      s1_offset <= s1_offsetNext[2:0];
    end
    if(io_flush) begin
      s1_offset <= io_offset;
    end
    if(s1_input_fire) begin
      s1_byteCounter <= (s1_byteCounter + _zz_s1_byteCounter);
    end
    if(io_flush) begin
      s1_byteCounter <= 12'h0;
    end
    if(s1_output_ready) begin
      s1_output_rData_cmd_data <= s1_output_payload_cmd_data;
      s1_output_rData_cmd_mask <= s1_output_payload_cmd_mask;
      s1_output_rData_index_0 <= s1_output_payload_index_0;
      s1_output_rData_index_1 <= s1_output_payload_index_1;
      s1_output_rData_index_2 <= s1_output_payload_index_2;
      s1_output_rData_index_3 <= s1_output_payload_index_3;
      s1_output_rData_index_4 <= s1_output_payload_index_4;
      s1_output_rData_index_5 <= s1_output_payload_index_5;
      s1_output_rData_index_6 <= s1_output_payload_index_6;
      s1_output_rData_index_7 <= s1_output_payload_index_7;
      s1_output_rData_last <= s1_output_payload_last;
      s1_output_rData_sel_0 <= s1_output_payload_sel_0;
      s1_output_rData_sel_1 <= s1_output_payload_sel_1;
      s1_output_rData_sel_2 <= s1_output_payload_sel_2;
      s1_output_rData_sel_3 <= s1_output_payload_sel_3;
      s1_output_rData_sel_4 <= s1_output_payload_sel_4;
      s1_output_rData_sel_5 <= s1_output_payload_sel_5;
      s1_output_rData_sel_6 <= s1_output_payload_sel_6;
      s1_output_rData_sel_7 <= s1_output_payload_sel_7;
      s1_output_rData_selValid <= s1_output_payload_selValid;
    end
    if(io_output_consume) begin
      s2_byteLogic_0_buffer_valid <= 1'b0;
    end
    if(s2_input_fire) begin
      if(s2_input_payload_last) begin
        s2_byteLogic_0_buffer_valid <= 1'b0;
      end
      if(when_DmaSg_l1493) begin
        s2_byteLogic_0_buffer_valid <= 1'b1;
        s2_byteLogic_0_buffer_data <= s2_byteLogic_0_inputData;
      end
    end
    if(io_flush) begin
      s2_byteLogic_0_buffer_valid <= (3'b000 < io_offset);
    end
    if(io_output_consume) begin
      s2_byteLogic_1_buffer_valid <= 1'b0;
    end
    if(s2_input_fire) begin
      if(s2_input_payload_last) begin
        s2_byteLogic_1_buffer_valid <= 1'b0;
      end
      if(when_DmaSg_l1493_1) begin
        s2_byteLogic_1_buffer_valid <= 1'b1;
        s2_byteLogic_1_buffer_data <= s2_byteLogic_1_inputData;
      end
    end
    if(io_flush) begin
      s2_byteLogic_1_buffer_valid <= (3'b001 < io_offset);
    end
    if(io_output_consume) begin
      s2_byteLogic_2_buffer_valid <= 1'b0;
    end
    if(s2_input_fire) begin
      if(s2_input_payload_last) begin
        s2_byteLogic_2_buffer_valid <= 1'b0;
      end
      if(when_DmaSg_l1493_2) begin
        s2_byteLogic_2_buffer_valid <= 1'b1;
        s2_byteLogic_2_buffer_data <= s2_byteLogic_2_inputData;
      end
    end
    if(io_flush) begin
      s2_byteLogic_2_buffer_valid <= (3'b010 < io_offset);
    end
    if(io_output_consume) begin
      s2_byteLogic_3_buffer_valid <= 1'b0;
    end
    if(s2_input_fire) begin
      if(s2_input_payload_last) begin
        s2_byteLogic_3_buffer_valid <= 1'b0;
      end
      if(when_DmaSg_l1493_3) begin
        s2_byteLogic_3_buffer_valid <= 1'b1;
        s2_byteLogic_3_buffer_data <= s2_byteLogic_3_inputData;
      end
    end
    if(io_flush) begin
      s2_byteLogic_3_buffer_valid <= (3'b011 < io_offset);
    end
    if(io_output_consume) begin
      s2_byteLogic_4_buffer_valid <= 1'b0;
    end
    if(s2_input_fire) begin
      if(s2_input_payload_last) begin
        s2_byteLogic_4_buffer_valid <= 1'b0;
      end
      if(when_DmaSg_l1493_4) begin
        s2_byteLogic_4_buffer_valid <= 1'b1;
        s2_byteLogic_4_buffer_data <= s2_byteLogic_4_inputData;
      end
    end
    if(io_flush) begin
      s2_byteLogic_4_buffer_valid <= (3'b100 < io_offset);
    end
    if(io_output_consume) begin
      s2_byteLogic_5_buffer_valid <= 1'b0;
    end
    if(s2_input_fire) begin
      if(s2_input_payload_last) begin
        s2_byteLogic_5_buffer_valid <= 1'b0;
      end
      if(when_DmaSg_l1493_5) begin
        s2_byteLogic_5_buffer_valid <= 1'b1;
        s2_byteLogic_5_buffer_data <= s2_byteLogic_5_inputData;
      end
    end
    if(io_flush) begin
      s2_byteLogic_5_buffer_valid <= (3'b101 < io_offset);
    end
    if(io_output_consume) begin
      s2_byteLogic_6_buffer_valid <= 1'b0;
    end
    if(s2_input_fire) begin
      if(s2_input_payload_last) begin
        s2_byteLogic_6_buffer_valid <= 1'b0;
      end
      if(when_DmaSg_l1493_6) begin
        s2_byteLogic_6_buffer_valid <= 1'b1;
        s2_byteLogic_6_buffer_data <= s2_byteLogic_6_inputData;
      end
    end
    if(io_flush) begin
      s2_byteLogic_6_buffer_valid <= (3'b110 < io_offset);
    end
    if(io_output_consume) begin
      s2_byteLogic_7_buffer_valid <= 1'b0;
    end
    if(s2_input_fire) begin
      if(s2_input_payload_last) begin
        s2_byteLogic_7_buffer_valid <= 1'b0;
      end
      if(when_DmaSg_l1493_7) begin
        s2_byteLogic_7_buffer_valid <= 1'b1;
        s2_byteLogic_7_buffer_data <= s2_byteLogic_7_inputData;
      end
    end
    if(io_flush) begin
      s2_byteLogic_7_buffer_valid <= (3'b111 < io_offset);
    end
  end


endmodule

module EfxDMA_DmaMemoryCore (
  input  wire          io_writes_0_cmd_valid,
  output wire          io_writes_0_cmd_ready,
  input  wire [12:0]   io_writes_0_cmd_payload_address,
  input  wire [31:0]   io_writes_0_cmd_payload_data,
  input  wire [3:0]    io_writes_0_cmd_payload_mask,
  input  wire [1:0]    io_writes_0_cmd_payload_priority,
  input  wire [5:0]    io_writes_0_cmd_payload_context,
  output wire          io_writes_0_rsp_valid,
  output wire [5:0]    io_writes_0_rsp_payload_context,
  input  wire          io_writes_1_cmd_valid,
  output wire          io_writes_1_cmd_ready,
  input  wire [12:0]   io_writes_1_cmd_payload_address,
  input  wire [63:0]   io_writes_1_cmd_payload_data,
  input  wire [7:0]    io_writes_1_cmd_payload_mask,
  input  wire [5:0]    io_writes_1_cmd_payload_context,
  output wire          io_writes_1_rsp_valid,
  output wire [5:0]    io_writes_1_rsp_payload_context,
  input  wire          io_reads_0_cmd_valid,
  output wire          io_reads_0_cmd_ready,
  input  wire [12:0]   io_reads_0_cmd_payload_address,
  input  wire [1:0]    io_reads_0_cmd_payload_priority,
  input  wire [2:0]    io_reads_0_cmd_payload_context,
  output wire          io_reads_0_rsp_valid,
  input  wire          io_reads_0_rsp_ready,
  output wire [31:0]   io_reads_0_rsp_payload_data,
  output wire [3:0]    io_reads_0_rsp_payload_mask,
  output wire [2:0]    io_reads_0_rsp_payload_context,
  input  wire          io_reads_1_cmd_valid,
  output wire          io_reads_1_cmd_ready,
  input  wire [12:0]   io_reads_1_cmd_payload_address,
  input  wire [14:0]   io_reads_1_cmd_payload_context,
  output wire          io_reads_1_rsp_valid,
  input  wire          io_reads_1_rsp_ready,
  output wire [63:0]   io_reads_1_rsp_payload_data,
  output wire [7:0]    io_reads_1_rsp_payload_mask,
  output wire [14:0]   io_reads_1_rsp_payload_context,
  input  wire          clk,
  input  wire          reset
);

  reg        [35:0]   banks_0_ram_spinal_port1;
  reg        [35:0]   banks_1_ram_spinal_port1;
  wire       [35:0]   _zz_banks_0_ram_port;
  wire       [35:0]   _zz_banks_1_ram_port;
  wire       [3:0]    _zz_write_ports_0_priority_value;
  wire       [12:0]   _zz_when_MemoryCore_l136;
  wire       [12:0]   _zz_when_MemoryCore_l136_1;
  reg        [31:0]   _zz_read_ports_0_buffer_bufferIn_payload_data;
  reg        [3:0]    _zz_read_ports_0_buffer_bufferIn_payload_mask;
  wire       [3:0]    _zz_read_ports_0_priority_value;
  wire       [12:0]   _zz_when_MemoryCore_l221;
  wire       [12:0]   _zz_when_MemoryCore_l221_1;
  reg                 _zz_1;
  reg                 _zz_2;
  reg                 banks_0_write_valid;
  reg        [11:0]   banks_0_write_payload_address;
  reg        [31:0]   banks_0_write_payload_data_data;
  reg        [3:0]    banks_0_write_payload_data_mask;
  wire                banks_0_read_cmd_valid;
  wire       [11:0]   banks_0_read_cmd_payload;
  wire       [31:0]   banks_0_read_rsp_data;
  wire       [3:0]    banks_0_read_rsp_mask;
  wire       [35:0]   _zz_banks_0_read_rsp_data;
  wire                banks_0_writeOr_value_valid;
  wire       [11:0]   banks_0_writeOr_value_payload_address;
  wire       [31:0]   banks_0_writeOr_value_payload_data_data;
  wire       [3:0]    banks_0_writeOr_value_payload_data_mask;
  wire                banks_0_readOr_value_valid;
  wire       [11:0]   banks_0_readOr_value_payload;
  reg                 banks_1_write_valid;
  reg        [11:0]   banks_1_write_payload_address;
  reg        [31:0]   banks_1_write_payload_data_data;
  reg        [3:0]    banks_1_write_payload_data_mask;
  wire                banks_1_read_cmd_valid;
  wire       [11:0]   banks_1_read_cmd_payload;
  wire       [31:0]   banks_1_read_rsp_data;
  wire       [3:0]    banks_1_read_rsp_mask;
  wire       [35:0]   _zz_banks_1_read_rsp_data;
  wire                banks_1_writeOr_value_valid;
  wire       [11:0]   banks_1_writeOr_value_payload_address;
  wire       [31:0]   banks_1_writeOr_value_payload_data_data;
  wire       [3:0]    banks_1_writeOr_value_payload_data_mask;
  wire                banks_1_readOr_value_valid;
  wire       [11:0]   banks_1_readOr_value_payload;
  reg        [3:0]    write_ports_0_priority_value;
  wire                write_nodes_0_0_priority;
  wire                write_nodes_0_0_conflict;
  wire                write_nodes_0_1_priority;
  wire                write_nodes_0_1_conflict;
  wire                write_nodes_1_0_priority;
  wire                write_nodes_1_0_conflict;
  wire                write_nodes_1_1_priority;
  wire                write_nodes_1_1_conflict;
  wire       [0:0]    write_arbiter_0_losedAgainst;
  reg                 write_arbiter_0_doIt;
  reg                 _zz_banks_0_writeOr_value_valid;
  reg        [11:0]   _zz_banks_0_writeOr_value_valid_1;
  reg        [31:0]   _zz_banks_0_writeOr_value_valid_2;
  reg        [3:0]    _zz_banks_0_writeOr_value_valid_3;
  wire                when_MemoryCore_l136;
  reg                 _zz_banks_1_writeOr_value_valid;
  reg        [11:0]   _zz_banks_1_writeOr_value_valid_1;
  reg        [31:0]   _zz_banks_1_writeOr_value_valid_2;
  reg        [3:0]    _zz_banks_1_writeOr_value_valid_3;
  wire                when_MemoryCore_l136_1;
  reg                 write_arbiter_0_doIt_regNext;
  reg        [5:0]    io_writes_0_cmd_payload_context_regNext;
  wire       [0:0]    write_arbiter_1_losedAgainst;
  reg                 write_arbiter_1_doIt;
  reg                 _zz_banks_0_writeOr_value_valid_4;
  reg        [11:0]   _zz_banks_0_writeOr_value_valid_5;
  reg        [31:0]   _zz_banks_0_writeOr_value_valid_6;
  reg        [3:0]    _zz_banks_0_writeOr_value_valid_7;
  wire                when_MemoryCore_l136_2;
  reg                 _zz_banks_1_writeOr_value_valid_4;
  reg        [11:0]   _zz_banks_1_writeOr_value_valid_5;
  reg        [31:0]   _zz_banks_1_writeOr_value_valid_6;
  reg        [3:0]    _zz_banks_1_writeOr_value_valid_7;
  wire                when_MemoryCore_l136_3;
  reg                 write_arbiter_1_doIt_regNext;
  reg        [5:0]    io_writes_1_cmd_payload_context_regNext;
  wire                read_ports_0_buffer_s0_valid;
  wire       [2:0]    read_ports_0_buffer_s0_payload_context;
  wire       [12:0]   read_ports_0_buffer_s0_payload_address;
  reg                 read_ports_0_buffer_s1_valid;
  reg        [2:0]    read_ports_0_buffer_s1_payload_context;
  reg        [12:0]   read_ports_0_buffer_s1_payload_address;
  wire       [0:0]    read_ports_0_buffer_groupSel;
  wire                read_ports_0_buffer_bufferIn_valid;
  wire                read_ports_0_buffer_bufferIn_ready;
  wire       [31:0]   read_ports_0_buffer_bufferIn_payload_data;
  wire       [3:0]    read_ports_0_buffer_bufferIn_payload_mask;
  wire       [2:0]    read_ports_0_buffer_bufferIn_payload_context;
  wire                read_ports_0_buffer_bufferOut_valid;
  wire                read_ports_0_buffer_bufferOut_ready;
  wire       [31:0]   read_ports_0_buffer_bufferOut_payload_data;
  wire       [3:0]    read_ports_0_buffer_bufferOut_payload_mask;
  wire       [2:0]    read_ports_0_buffer_bufferOut_payload_context;
  reg                 read_ports_0_buffer_bufferIn_rValidN;
  reg        [31:0]   read_ports_0_buffer_bufferIn_rData_data;
  reg        [3:0]    read_ports_0_buffer_bufferIn_rData_mask;
  reg        [2:0]    read_ports_0_buffer_bufferIn_rData_context;
  wire                read_ports_0_buffer_full;
  wire                _zz_io_reads_0_cmd_ready;
  wire                read_ports_0_cmd_valid;
  wire                read_ports_0_cmd_ready;
  wire       [12:0]   read_ports_0_cmd_payload_address;
  wire       [1:0]    read_ports_0_cmd_payload_priority;
  wire       [2:0]    read_ports_0_cmd_payload_context;
  reg        [3:0]    read_ports_0_priority_value;
  wire                read_ports_1_buffer_s0_valid;
  wire       [14:0]   read_ports_1_buffer_s0_payload_context;
  wire       [12:0]   read_ports_1_buffer_s0_payload_address;
  reg                 read_ports_1_buffer_s1_valid;
  reg        [14:0]   read_ports_1_buffer_s1_payload_context;
  reg        [12:0]   read_ports_1_buffer_s1_payload_address;
  wire                read_ports_1_buffer_bufferIn_valid;
  wire                read_ports_1_buffer_bufferIn_ready;
  wire       [63:0]   read_ports_1_buffer_bufferIn_payload_data;
  wire       [7:0]    read_ports_1_buffer_bufferIn_payload_mask;
  wire       [14:0]   read_ports_1_buffer_bufferIn_payload_context;
  wire                read_ports_1_buffer_bufferOut_valid;
  wire                read_ports_1_buffer_bufferOut_ready;
  wire       [63:0]   read_ports_1_buffer_bufferOut_payload_data;
  wire       [7:0]    read_ports_1_buffer_bufferOut_payload_mask;
  wire       [14:0]   read_ports_1_buffer_bufferOut_payload_context;
  reg                 read_ports_1_buffer_bufferIn_rValidN;
  reg        [63:0]   read_ports_1_buffer_bufferIn_rData_data;
  reg        [7:0]    read_ports_1_buffer_bufferIn_rData_mask;
  reg        [14:0]   read_ports_1_buffer_bufferIn_rData_context;
  wire                read_ports_1_buffer_full;
  wire                _zz_io_reads_1_cmd_ready;
  wire                read_ports_1_cmd_valid;
  wire                read_ports_1_cmd_ready;
  wire       [12:0]   read_ports_1_cmd_payload_address;
  wire       [14:0]   read_ports_1_cmd_payload_context;
  wire                read_nodes_0_0_priority;
  wire                read_nodes_0_0_conflict;
  wire                read_nodes_0_1_priority;
  wire                read_nodes_0_1_conflict;
  wire                read_nodes_1_0_priority;
  wire                read_nodes_1_0_conflict;
  wire                read_nodes_1_1_priority;
  wire                read_nodes_1_1_conflict;
  wire       [0:0]    read_arbiter_0_losedAgainst;
  wire                read_arbiter_0_doIt;
  reg                 _zz_banks_0_readOr_value_valid;
  reg        [11:0]   _zz_banks_0_readOr_value_valid_1;
  wire                when_MemoryCore_l221;
  reg                 _zz_banks_1_readOr_value_valid;
  reg        [11:0]   _zz_banks_1_readOr_value_valid_1;
  wire                when_MemoryCore_l221_1;
  wire       [0:0]    read_arbiter_1_losedAgainst;
  wire                read_arbiter_1_doIt;
  reg                 _zz_banks_0_readOr_value_valid_2;
  reg        [11:0]   _zz_banks_0_readOr_value_valid_3;
  wire                when_MemoryCore_l221_2;
  reg                 _zz_banks_1_readOr_value_valid_2;
  reg        [11:0]   _zz_banks_1_readOr_value_valid_3;
  wire                when_MemoryCore_l221_3;
  reg        [12:0]   initialiser_counter;
  wire                initialiser_done;
  wire                when_MemoryCore_l239;
  wire       [35:0]   _zz_banks_0_write_payload_data_data;
  wire       [35:0]   _zz_banks_1_write_payload_data_data;
  wire       [48:0]   _zz_banks_0_writeOr_value_valid_8;
  wire       [47:0]   _zz_banks_0_writeOr_value_payload_address;
  wire       [35:0]   _zz_banks_0_writeOr_value_payload_data_data;
  wire       [12:0]   _zz_banks_0_readOr_value_valid_4;
  wire       [48:0]   _zz_banks_1_writeOr_value_valid_8;
  wire       [47:0]   _zz_banks_1_writeOr_value_payload_address;
  wire       [35:0]   _zz_banks_1_writeOr_value_payload_data_data;
  wire       [12:0]   _zz_banks_1_readOr_value_valid_4;
  (* ram_style = "block" *) reg [35:0] banks_0_ram [0:4095];
  (* ram_style = "block" *) reg [35:0] banks_1_ram [0:4095];

  assign _zz_write_ports_0_priority_value = {2'd0, io_writes_0_cmd_payload_priority};
  assign _zz_when_MemoryCore_l136 = (io_writes_0_cmd_payload_address ^ 13'h0);
  assign _zz_when_MemoryCore_l136_1 = (io_writes_0_cmd_payload_address ^ 13'h0001);
  assign _zz_read_ports_0_priority_value = {2'd0, read_ports_0_cmd_payload_priority};
  assign _zz_when_MemoryCore_l221 = (read_ports_0_cmd_payload_address ^ 13'h0);
  assign _zz_when_MemoryCore_l221_1 = (read_ports_0_cmd_payload_address ^ 13'h0001);
  assign _zz_banks_0_ram_port = {banks_0_write_payload_data_mask,banks_0_write_payload_data_data};
  assign _zz_banks_1_ram_port = {banks_1_write_payload_data_mask,banks_1_write_payload_data_data};
  always @(posedge clk) begin
    if(_zz_2) begin
      banks_0_ram[banks_0_write_payload_address] <= _zz_banks_0_ram_port;
    end
  end

  always @(posedge clk) begin
    if(banks_0_read_cmd_valid) begin
      banks_0_ram_spinal_port1 <= banks_0_ram[banks_0_read_cmd_payload];
    end
  end

  always @(posedge clk) begin
    if(_zz_1) begin
      banks_1_ram[banks_1_write_payload_address] <= _zz_banks_1_ram_port;
    end
  end

  always @(posedge clk) begin
    if(banks_1_read_cmd_valid) begin
      banks_1_ram_spinal_port1 <= banks_1_ram[banks_1_read_cmd_payload];
    end
  end

  initial begin
  `ifndef SYNTHESIS
    write_ports_0_priority_value = {$urandom};
    read_ports_0_priority_value = {$urandom};
  `endif
  end

  always @(*) begin
    case(read_ports_0_buffer_groupSel)
      1'b0 : begin
        _zz_read_ports_0_buffer_bufferIn_payload_data = banks_0_read_rsp_data;
        _zz_read_ports_0_buffer_bufferIn_payload_mask = banks_0_read_rsp_mask;
      end
      default : begin
        _zz_read_ports_0_buffer_bufferIn_payload_data = banks_1_read_rsp_data;
        _zz_read_ports_0_buffer_bufferIn_payload_mask = banks_1_read_rsp_mask;
      end
    endcase
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(banks_1_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    _zz_2 = 1'b0;
    if(banks_0_write_valid) begin
      _zz_2 = 1'b1;
    end
  end

  assign _zz_banks_0_read_rsp_data = banks_0_ram_spinal_port1;
  assign banks_0_read_rsp_data = _zz_banks_0_read_rsp_data[31 : 0];
  assign banks_0_read_rsp_mask = _zz_banks_0_read_rsp_data[35 : 32];
  always @(*) begin
    banks_0_write_valid = banks_0_writeOr_value_valid;
    if(when_MemoryCore_l239) begin
      banks_0_write_valid = 1'b1;
    end
  end

  always @(*) begin
    banks_0_write_payload_address = banks_0_writeOr_value_payload_address;
    if(when_MemoryCore_l239) begin
      banks_0_write_payload_address = initialiser_counter[11:0];
    end
  end

  always @(*) begin
    banks_0_write_payload_data_data = banks_0_writeOr_value_payload_data_data;
    if(when_MemoryCore_l239) begin
      banks_0_write_payload_data_data = _zz_banks_0_write_payload_data_data[31 : 0];
    end
  end

  always @(*) begin
    banks_0_write_payload_data_mask = banks_0_writeOr_value_payload_data_mask;
    if(when_MemoryCore_l239) begin
      banks_0_write_payload_data_mask = _zz_banks_0_write_payload_data_data[35 : 32];
    end
  end

  assign banks_0_read_cmd_valid = banks_0_readOr_value_valid;
  assign banks_0_read_cmd_payload = banks_0_readOr_value_payload;
  assign _zz_banks_1_read_rsp_data = banks_1_ram_spinal_port1;
  assign banks_1_read_rsp_data = _zz_banks_1_read_rsp_data[31 : 0];
  assign banks_1_read_rsp_mask = _zz_banks_1_read_rsp_data[35 : 32];
  always @(*) begin
    banks_1_write_valid = banks_1_writeOr_value_valid;
    if(when_MemoryCore_l239) begin
      banks_1_write_valid = 1'b1;
    end
  end

  always @(*) begin
    banks_1_write_payload_address = banks_1_writeOr_value_payload_address;
    if(when_MemoryCore_l239) begin
      banks_1_write_payload_address = initialiser_counter[11:0];
    end
  end

  always @(*) begin
    banks_1_write_payload_data_data = banks_1_writeOr_value_payload_data_data;
    if(when_MemoryCore_l239) begin
      banks_1_write_payload_data_data = _zz_banks_1_write_payload_data_data[31 : 0];
    end
  end

  always @(*) begin
    banks_1_write_payload_data_mask = banks_1_writeOr_value_payload_data_mask;
    if(when_MemoryCore_l239) begin
      banks_1_write_payload_data_mask = _zz_banks_1_write_payload_data_data[35 : 32];
    end
  end

  assign banks_1_read_cmd_valid = banks_1_readOr_value_valid;
  assign banks_1_read_cmd_payload = banks_1_readOr_value_payload;
  assign write_nodes_0_1_priority = 1'b0;
  assign write_nodes_1_0_priority = 1'b1;
  assign write_nodes_0_1_conflict = ((io_writes_0_cmd_valid && io_writes_1_cmd_valid) && (((io_writes_0_cmd_payload_address ^ io_writes_1_cmd_payload_address) & 13'h0) == 13'h0));
  assign write_nodes_1_0_conflict = write_nodes_0_1_conflict;
  assign write_arbiter_0_losedAgainst = (write_nodes_0_1_conflict && (! write_nodes_0_1_priority));
  always @(*) begin
    write_arbiter_0_doIt = (io_writes_0_cmd_valid && (write_arbiter_0_losedAgainst == 1'b0));
    if(when_MemoryCore_l239) begin
      write_arbiter_0_doIt = 1'b0;
    end
  end

  assign when_MemoryCore_l136 = (write_arbiter_0_doIt && (_zz_when_MemoryCore_l136[0 : 0] == 1'b0));
  always @(*) begin
    if(when_MemoryCore_l136) begin
      _zz_banks_0_writeOr_value_valid = 1'b1;
    end else begin
      _zz_banks_0_writeOr_value_valid = 1'b0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136) begin
      _zz_banks_0_writeOr_value_valid_1 = (io_writes_0_cmd_payload_address >>> 1'd1);
    end else begin
      _zz_banks_0_writeOr_value_valid_1 = 12'h0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136) begin
      _zz_banks_0_writeOr_value_valid_2 = io_writes_0_cmd_payload_data[31 : 0];
    end else begin
      _zz_banks_0_writeOr_value_valid_2 = 32'h0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136) begin
      _zz_banks_0_writeOr_value_valid_3 = io_writes_0_cmd_payload_mask[3 : 0];
    end else begin
      _zz_banks_0_writeOr_value_valid_3 = 4'b0000;
    end
  end

  assign when_MemoryCore_l136_1 = (write_arbiter_0_doIt && (_zz_when_MemoryCore_l136_1[0 : 0] == 1'b0));
  always @(*) begin
    if(when_MemoryCore_l136_1) begin
      _zz_banks_1_writeOr_value_valid = 1'b1;
    end else begin
      _zz_banks_1_writeOr_value_valid = 1'b0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136_1) begin
      _zz_banks_1_writeOr_value_valid_1 = (io_writes_0_cmd_payload_address >>> 1'd1);
    end else begin
      _zz_banks_1_writeOr_value_valid_1 = 12'h0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136_1) begin
      _zz_banks_1_writeOr_value_valid_2 = io_writes_0_cmd_payload_data[31 : 0];
    end else begin
      _zz_banks_1_writeOr_value_valid_2 = 32'h0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136_1) begin
      _zz_banks_1_writeOr_value_valid_3 = io_writes_0_cmd_payload_mask[3 : 0];
    end else begin
      _zz_banks_1_writeOr_value_valid_3 = 4'b0000;
    end
  end

  assign io_writes_0_cmd_ready = write_arbiter_0_doIt;
  assign io_writes_0_rsp_valid = write_arbiter_0_doIt_regNext;
  assign io_writes_0_rsp_payload_context = io_writes_0_cmd_payload_context_regNext;
  assign write_arbiter_1_losedAgainst = (write_nodes_1_0_conflict && (! write_nodes_1_0_priority));
  always @(*) begin
    write_arbiter_1_doIt = (io_writes_1_cmd_valid && (write_arbiter_1_losedAgainst == 1'b0));
    if(when_MemoryCore_l239) begin
      write_arbiter_1_doIt = 1'b0;
    end
  end

  assign when_MemoryCore_l136_2 = (write_arbiter_1_doIt && 1'b1);
  always @(*) begin
    if(when_MemoryCore_l136_2) begin
      _zz_banks_0_writeOr_value_valid_4 = 1'b1;
    end else begin
      _zz_banks_0_writeOr_value_valid_4 = 1'b0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136_2) begin
      _zz_banks_0_writeOr_value_valid_5 = (io_writes_1_cmd_payload_address >>> 1'd1);
    end else begin
      _zz_banks_0_writeOr_value_valid_5 = 12'h0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136_2) begin
      _zz_banks_0_writeOr_value_valid_6 = io_writes_1_cmd_payload_data[31 : 0];
    end else begin
      _zz_banks_0_writeOr_value_valid_6 = 32'h0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136_2) begin
      _zz_banks_0_writeOr_value_valid_7 = io_writes_1_cmd_payload_mask[3 : 0];
    end else begin
      _zz_banks_0_writeOr_value_valid_7 = 4'b0000;
    end
  end

  assign when_MemoryCore_l136_3 = (write_arbiter_1_doIt && 1'b1);
  always @(*) begin
    if(when_MemoryCore_l136_3) begin
      _zz_banks_1_writeOr_value_valid_4 = 1'b1;
    end else begin
      _zz_banks_1_writeOr_value_valid_4 = 1'b0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136_3) begin
      _zz_banks_1_writeOr_value_valid_5 = (io_writes_1_cmd_payload_address >>> 1'd1);
    end else begin
      _zz_banks_1_writeOr_value_valid_5 = 12'h0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136_3) begin
      _zz_banks_1_writeOr_value_valid_6 = io_writes_1_cmd_payload_data[63 : 32];
    end else begin
      _zz_banks_1_writeOr_value_valid_6 = 32'h0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l136_3) begin
      _zz_banks_1_writeOr_value_valid_7 = io_writes_1_cmd_payload_mask[7 : 4];
    end else begin
      _zz_banks_1_writeOr_value_valid_7 = 4'b0000;
    end
  end

  assign io_writes_1_cmd_ready = write_arbiter_1_doIt;
  assign io_writes_1_rsp_valid = write_arbiter_1_doIt_regNext;
  assign io_writes_1_rsp_payload_context = io_writes_1_cmd_payload_context_regNext;
  assign read_ports_0_buffer_groupSel = read_ports_0_buffer_s1_payload_address[0 : 0];
  assign read_ports_0_buffer_bufferIn_valid = read_ports_0_buffer_s1_valid;
  assign read_ports_0_buffer_bufferIn_payload_context = read_ports_0_buffer_s1_payload_context;
  assign read_ports_0_buffer_bufferIn_payload_data = _zz_read_ports_0_buffer_bufferIn_payload_data;
  assign read_ports_0_buffer_bufferIn_payload_mask = _zz_read_ports_0_buffer_bufferIn_payload_mask;
  assign read_ports_0_buffer_bufferIn_ready = read_ports_0_buffer_bufferIn_rValidN;
  assign read_ports_0_buffer_bufferOut_valid = (read_ports_0_buffer_bufferIn_valid || (! read_ports_0_buffer_bufferIn_rValidN));
  assign read_ports_0_buffer_bufferOut_payload_data = (read_ports_0_buffer_bufferIn_rValidN ? read_ports_0_buffer_bufferIn_payload_data : read_ports_0_buffer_bufferIn_rData_data);
  assign read_ports_0_buffer_bufferOut_payload_mask = (read_ports_0_buffer_bufferIn_rValidN ? read_ports_0_buffer_bufferIn_payload_mask : read_ports_0_buffer_bufferIn_rData_mask);
  assign read_ports_0_buffer_bufferOut_payload_context = (read_ports_0_buffer_bufferIn_rValidN ? read_ports_0_buffer_bufferIn_payload_context : read_ports_0_buffer_bufferIn_rData_context);
  assign io_reads_0_rsp_valid = read_ports_0_buffer_bufferOut_valid;
  assign read_ports_0_buffer_bufferOut_ready = io_reads_0_rsp_ready;
  assign io_reads_0_rsp_payload_data = read_ports_0_buffer_bufferOut_payload_data;
  assign io_reads_0_rsp_payload_mask = read_ports_0_buffer_bufferOut_payload_mask;
  assign io_reads_0_rsp_payload_context = read_ports_0_buffer_bufferOut_payload_context;
  assign read_ports_0_buffer_full = (read_ports_0_buffer_bufferOut_valid && (! read_ports_0_buffer_bufferOut_ready));
  assign _zz_io_reads_0_cmd_ready = (! read_ports_0_buffer_full);
  assign read_ports_0_cmd_valid = (io_reads_0_cmd_valid && _zz_io_reads_0_cmd_ready);
  assign io_reads_0_cmd_ready = (read_ports_0_cmd_ready && _zz_io_reads_0_cmd_ready);
  assign read_ports_0_cmd_payload_address = io_reads_0_cmd_payload_address;
  assign read_ports_0_cmd_payload_priority = io_reads_0_cmd_payload_priority;
  assign read_ports_0_cmd_payload_context = io_reads_0_cmd_payload_context;
  assign read_ports_1_buffer_bufferIn_valid = read_ports_1_buffer_s1_valid;
  assign read_ports_1_buffer_bufferIn_payload_context = read_ports_1_buffer_s1_payload_context;
  assign read_ports_1_buffer_bufferIn_payload_data = {banks_1_read_rsp_data,banks_0_read_rsp_data};
  assign read_ports_1_buffer_bufferIn_payload_mask = {banks_1_read_rsp_mask,banks_0_read_rsp_mask};
  assign read_ports_1_buffer_bufferIn_ready = read_ports_1_buffer_bufferIn_rValidN;
  assign read_ports_1_buffer_bufferOut_valid = (read_ports_1_buffer_bufferIn_valid || (! read_ports_1_buffer_bufferIn_rValidN));
  assign read_ports_1_buffer_bufferOut_payload_data = (read_ports_1_buffer_bufferIn_rValidN ? read_ports_1_buffer_bufferIn_payload_data : read_ports_1_buffer_bufferIn_rData_data);
  assign read_ports_1_buffer_bufferOut_payload_mask = (read_ports_1_buffer_bufferIn_rValidN ? read_ports_1_buffer_bufferIn_payload_mask : read_ports_1_buffer_bufferIn_rData_mask);
  assign read_ports_1_buffer_bufferOut_payload_context = (read_ports_1_buffer_bufferIn_rValidN ? read_ports_1_buffer_bufferIn_payload_context : read_ports_1_buffer_bufferIn_rData_context);
  assign io_reads_1_rsp_valid = read_ports_1_buffer_bufferOut_valid;
  assign read_ports_1_buffer_bufferOut_ready = io_reads_1_rsp_ready;
  assign io_reads_1_rsp_payload_data = read_ports_1_buffer_bufferOut_payload_data;
  assign io_reads_1_rsp_payload_mask = read_ports_1_buffer_bufferOut_payload_mask;
  assign io_reads_1_rsp_payload_context = read_ports_1_buffer_bufferOut_payload_context;
  assign read_ports_1_buffer_full = (read_ports_1_buffer_bufferOut_valid && (! read_ports_1_buffer_bufferOut_ready));
  assign _zz_io_reads_1_cmd_ready = (! read_ports_1_buffer_full);
  assign read_ports_1_cmd_valid = (io_reads_1_cmd_valid && _zz_io_reads_1_cmd_ready);
  assign io_reads_1_cmd_ready = (read_ports_1_cmd_ready && _zz_io_reads_1_cmd_ready);
  assign read_ports_1_cmd_payload_address = io_reads_1_cmd_payload_address;
  assign read_ports_1_cmd_payload_context = io_reads_1_cmd_payload_context;
  assign read_nodes_0_1_priority = 1'b0;
  assign read_nodes_1_0_priority = 1'b1;
  assign read_nodes_0_1_conflict = ((read_ports_0_cmd_valid && read_ports_1_cmd_valid) && (((read_ports_0_cmd_payload_address ^ io_reads_1_cmd_payload_address) & 13'h0) == 13'h0));
  assign read_nodes_1_0_conflict = read_nodes_0_1_conflict;
  assign read_arbiter_0_losedAgainst = (read_nodes_0_1_conflict && (! read_nodes_0_1_priority));
  assign read_arbiter_0_doIt = (read_ports_0_cmd_valid && (read_arbiter_0_losedAgainst == 1'b0));
  assign when_MemoryCore_l221 = (read_arbiter_0_doIt && (_zz_when_MemoryCore_l221[0 : 0] == 1'b0));
  always @(*) begin
    if(when_MemoryCore_l221) begin
      _zz_banks_0_readOr_value_valid = 1'b1;
    end else begin
      _zz_banks_0_readOr_value_valid = 1'b0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l221) begin
      _zz_banks_0_readOr_value_valid_1 = (read_ports_0_cmd_payload_address >>> 1'd1);
    end else begin
      _zz_banks_0_readOr_value_valid_1 = 12'h0;
    end
  end

  assign when_MemoryCore_l221_1 = (read_arbiter_0_doIt && (_zz_when_MemoryCore_l221_1[0 : 0] == 1'b0));
  always @(*) begin
    if(when_MemoryCore_l221_1) begin
      _zz_banks_1_readOr_value_valid = 1'b1;
    end else begin
      _zz_banks_1_readOr_value_valid = 1'b0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l221_1) begin
      _zz_banks_1_readOr_value_valid_1 = (read_ports_0_cmd_payload_address >>> 1'd1);
    end else begin
      _zz_banks_1_readOr_value_valid_1 = 12'h0;
    end
  end

  assign read_ports_0_cmd_ready = read_arbiter_0_doIt;
  assign read_ports_0_buffer_s0_valid = read_arbiter_0_doIt;
  assign read_ports_0_buffer_s0_payload_context = read_ports_0_cmd_payload_context;
  assign read_ports_0_buffer_s0_payload_address = read_ports_0_cmd_payload_address;
  assign read_arbiter_1_losedAgainst = (read_nodes_1_0_conflict && (! read_nodes_1_0_priority));
  assign read_arbiter_1_doIt = (read_ports_1_cmd_valid && (read_arbiter_1_losedAgainst == 1'b0));
  assign when_MemoryCore_l221_2 = (read_arbiter_1_doIt && 1'b1);
  always @(*) begin
    if(when_MemoryCore_l221_2) begin
      _zz_banks_0_readOr_value_valid_2 = 1'b1;
    end else begin
      _zz_banks_0_readOr_value_valid_2 = 1'b0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l221_2) begin
      _zz_banks_0_readOr_value_valid_3 = (read_ports_1_cmd_payload_address >>> 1'd1);
    end else begin
      _zz_banks_0_readOr_value_valid_3 = 12'h0;
    end
  end

  assign when_MemoryCore_l221_3 = (read_arbiter_1_doIt && 1'b1);
  always @(*) begin
    if(when_MemoryCore_l221_3) begin
      _zz_banks_1_readOr_value_valid_2 = 1'b1;
    end else begin
      _zz_banks_1_readOr_value_valid_2 = 1'b0;
    end
  end

  always @(*) begin
    if(when_MemoryCore_l221_3) begin
      _zz_banks_1_readOr_value_valid_3 = (read_ports_1_cmd_payload_address >>> 1'd1);
    end else begin
      _zz_banks_1_readOr_value_valid_3 = 12'h0;
    end
  end

  assign read_ports_1_cmd_ready = read_arbiter_1_doIt;
  assign read_ports_1_buffer_s0_valid = read_arbiter_1_doIt;
  assign read_ports_1_buffer_s0_payload_context = read_ports_1_cmd_payload_context;
  assign read_ports_1_buffer_s0_payload_address = read_ports_1_cmd_payload_address;
  assign initialiser_done = initialiser_counter[12];
  assign when_MemoryCore_l239 = (! initialiser_done);
  assign _zz_banks_0_write_payload_data_data = 36'h0;
  assign _zz_banks_1_write_payload_data_data = 36'h0;
  assign _zz_banks_0_writeOr_value_valid_8 = ({{{_zz_banks_0_writeOr_value_valid_3,_zz_banks_0_writeOr_value_valid_2},_zz_banks_0_writeOr_value_valid_1},_zz_banks_0_writeOr_value_valid} | {{{_zz_banks_0_writeOr_value_valid_7,_zz_banks_0_writeOr_value_valid_6},_zz_banks_0_writeOr_value_valid_5},_zz_banks_0_writeOr_value_valid_4});
  assign banks_0_writeOr_value_valid = _zz_banks_0_writeOr_value_valid_8[0];
  assign _zz_banks_0_writeOr_value_payload_address = _zz_banks_0_writeOr_value_valid_8[48 : 1];
  assign banks_0_writeOr_value_payload_address = _zz_banks_0_writeOr_value_payload_address[11 : 0];
  assign _zz_banks_0_writeOr_value_payload_data_data = _zz_banks_0_writeOr_value_payload_address[47 : 12];
  assign banks_0_writeOr_value_payload_data_data = _zz_banks_0_writeOr_value_payload_data_data[31 : 0];
  assign banks_0_writeOr_value_payload_data_mask = _zz_banks_0_writeOr_value_payload_data_data[35 : 32];
  assign _zz_banks_0_readOr_value_valid_4 = ({_zz_banks_0_readOr_value_valid_1,_zz_banks_0_readOr_value_valid} | {_zz_banks_0_readOr_value_valid_3,_zz_banks_0_readOr_value_valid_2});
  assign banks_0_readOr_value_valid = _zz_banks_0_readOr_value_valid_4[0];
  assign banks_0_readOr_value_payload = _zz_banks_0_readOr_value_valid_4[12 : 1];
  assign _zz_banks_1_writeOr_value_valid_8 = ({{{_zz_banks_1_writeOr_value_valid_3,_zz_banks_1_writeOr_value_valid_2},_zz_banks_1_writeOr_value_valid_1},_zz_banks_1_writeOr_value_valid} | {{{_zz_banks_1_writeOr_value_valid_7,_zz_banks_1_writeOr_value_valid_6},_zz_banks_1_writeOr_value_valid_5},_zz_banks_1_writeOr_value_valid_4});
  assign banks_1_writeOr_value_valid = _zz_banks_1_writeOr_value_valid_8[0];
  assign _zz_banks_1_writeOr_value_payload_address = _zz_banks_1_writeOr_value_valid_8[48 : 1];
  assign banks_1_writeOr_value_payload_address = _zz_banks_1_writeOr_value_payload_address[11 : 0];
  assign _zz_banks_1_writeOr_value_payload_data_data = _zz_banks_1_writeOr_value_payload_address[47 : 12];
  assign banks_1_writeOr_value_payload_data_data = _zz_banks_1_writeOr_value_payload_data_data[31 : 0];
  assign banks_1_writeOr_value_payload_data_mask = _zz_banks_1_writeOr_value_payload_data_data[35 : 32];
  assign _zz_banks_1_readOr_value_valid_4 = ({_zz_banks_1_readOr_value_valid_1,_zz_banks_1_readOr_value_valid} | {_zz_banks_1_readOr_value_valid_3,_zz_banks_1_readOr_value_valid_2});
  assign banks_1_readOr_value_valid = _zz_banks_1_readOr_value_valid_4[0];
  assign banks_1_readOr_value_payload = _zz_banks_1_readOr_value_valid_4[12 : 1];
  always @(posedge clk) begin
    if(io_writes_0_cmd_valid) begin
      write_ports_0_priority_value <= (write_ports_0_priority_value + _zz_write_ports_0_priority_value);
      if(io_writes_0_cmd_ready) begin
        write_ports_0_priority_value <= 4'b0000;
      end
    end
    io_writes_0_cmd_payload_context_regNext <= io_writes_0_cmd_payload_context;
    io_writes_1_cmd_payload_context_regNext <= io_writes_1_cmd_payload_context;
    read_ports_0_buffer_s1_payload_context <= read_ports_0_buffer_s0_payload_context;
    read_ports_0_buffer_s1_payload_address <= read_ports_0_buffer_s0_payload_address;
    if(read_ports_0_buffer_bufferIn_ready) begin
      read_ports_0_buffer_bufferIn_rData_data <= read_ports_0_buffer_bufferIn_payload_data;
      read_ports_0_buffer_bufferIn_rData_mask <= read_ports_0_buffer_bufferIn_payload_mask;
      read_ports_0_buffer_bufferIn_rData_context <= read_ports_0_buffer_bufferIn_payload_context;
    end
    if(read_ports_0_cmd_valid) begin
      read_ports_0_priority_value <= (read_ports_0_priority_value + _zz_read_ports_0_priority_value);
      if(read_ports_0_cmd_ready) begin
        read_ports_0_priority_value <= 4'b0000;
      end
    end
    read_ports_1_buffer_s1_payload_context <= read_ports_1_buffer_s0_payload_context;
    read_ports_1_buffer_s1_payload_address <= read_ports_1_buffer_s0_payload_address;
    if(read_ports_1_buffer_bufferIn_ready) begin
      read_ports_1_buffer_bufferIn_rData_data <= read_ports_1_buffer_bufferIn_payload_data;
      read_ports_1_buffer_bufferIn_rData_mask <= read_ports_1_buffer_bufferIn_payload_mask;
      read_ports_1_buffer_bufferIn_rData_context <= read_ports_1_buffer_bufferIn_payload_context;
    end
  end

  always @(posedge clk) begin
    if(reset) begin
      write_arbiter_0_doIt_regNext <= 1'b0;
      write_arbiter_1_doIt_regNext <= 1'b0;
      read_ports_0_buffer_s1_valid <= 1'b0;
      read_ports_0_buffer_bufferIn_rValidN <= 1'b1;
      read_ports_1_buffer_s1_valid <= 1'b0;
      read_ports_1_buffer_bufferIn_rValidN <= 1'b1;
      initialiser_counter <= 13'h0;
    end else begin
      write_arbiter_0_doIt_regNext <= write_arbiter_0_doIt;
      write_arbiter_1_doIt_regNext <= write_arbiter_1_doIt;
      read_ports_0_buffer_s1_valid <= read_ports_0_buffer_s0_valid;
      if(read_ports_0_buffer_bufferIn_valid) begin
        read_ports_0_buffer_bufferIn_rValidN <= 1'b0;
      end
      if(read_ports_0_buffer_bufferOut_ready) begin
        read_ports_0_buffer_bufferIn_rValidN <= 1'b1;
      end
      read_ports_1_buffer_s1_valid <= read_ports_1_buffer_s0_valid;
      if(read_ports_1_buffer_bufferIn_valid) begin
        read_ports_1_buffer_bufferIn_rValidN <= 1'b0;
      end
      if(read_ports_1_buffer_bufferOut_ready) begin
        read_ports_1_buffer_bufferIn_rValidN <= 1'b1;
      end
      if(when_MemoryCore_l239) begin
        initialiser_counter <= (initialiser_counter + 13'h0001);
      end
    end
  end


endmodule

module EfxDMA_StreamFifo_1 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [12:0]   io_push_payload_context,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [12:0]   io_pop_payload_context,
  input  wire          io_flush,
  output wire [2:0]    io_occupancy,
  output wire [2:0]    io_availability,
  input  wire          clk,
  input  wire          reset
);

  reg        [12:0]   logic_ram_spinal_port1;
  wire       [2:0]    _zz_logic_ptr_notPow2_counter;
  wire       [2:0]    _zz_logic_ptr_notPow2_counter_1;
  wire       [0:0]    _zz_logic_ptr_notPow2_counter_2;
  wire       [2:0]    _zz_logic_ptr_notPow2_counter_3;
  wire       [0:0]    _zz_logic_ptr_notPow2_counter_4;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [2:0]    logic_ptr_push;
  reg        [2:0]    logic_ptr_pop;
  wire       [2:0]    logic_ptr_occupancy;
  wire       [2:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1248;
  reg                 logic_ptr_wentUp;
  wire                when_Stream_l1283;
  wire                when_Stream_l1287;
  reg        [2:0]    logic_ptr_notPow2_counter;
  wire                io_push_fire;
  wire                io_pop_fire;
  wire                logic_push_onRam_write_valid;
  wire       [2:0]    logic_push_onRam_write_payload_address;
  wire       [12:0]   logic_push_onRam_write_payload_data_context;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [2:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [2:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [2:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l375;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [2:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [12:0]   logic_pop_sync_readPort_rsp_context;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [12:0]   logic_pop_sync_readArbitation_translated_payload_context;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [2:0]    logic_pop_sync_popReg;
  reg [12:0] logic_ram [0:6];

  assign _zz_logic_ptr_notPow2_counter = (logic_ptr_notPow2_counter + _zz_logic_ptr_notPow2_counter_1);
  assign _zz_logic_ptr_notPow2_counter_2 = io_push_fire;
  assign _zz_logic_ptr_notPow2_counter_1 = {2'd0, _zz_logic_ptr_notPow2_counter_2};
  assign _zz_logic_ptr_notPow2_counter_4 = io_pop_fire;
  assign _zz_logic_ptr_notPow2_counter_3 = {2'd0, _zz_logic_ptr_notPow2_counter_4};
  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_push_onRam_write_payload_address] <= logic_push_onRam_write_payload_data_context;
    end
  end

  always @(posedge clk) begin
    if(logic_pop_sync_readPort_cmd_valid) begin
      logic_ram_spinal_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_push_onRam_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign when_Stream_l1248 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = ((logic_ptr_push == logic_ptr_popOnIo) && logic_ptr_wentUp);
  assign logic_ptr_empty = ((logic_ptr_push == logic_ptr_pop) && (! logic_ptr_wentUp));
  assign when_Stream_l1283 = (logic_ptr_push == 3'b110);
  assign when_Stream_l1287 = (logic_ptr_pop == 3'b110);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign io_pop_fire = (io_pop_valid && io_pop_ready);
  assign logic_ptr_occupancy = logic_ptr_notPow2_counter;
  assign io_push_ready = (! logic_ptr_full);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push;
  assign logic_push_onRam_write_payload_data_context = io_push_payload_context;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop;
  assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
  assign logic_ptr_doPop = logic_pop_addressGen_fire;
  always @(*) begin
    logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
    if(when_Stream_l375) begin
      logic_pop_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l375 = (! logic_pop_sync_readArbitation_valid);
  assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
  assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
  assign logic_pop_sync_readPort_rsp_context = logic_ram_spinal_port1[12 : 0];
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_fire;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload_context = logic_pop_sync_readPort_rsp_context;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_context = logic_pop_sync_readArbitation_translated_payload_context;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (3'b111 - logic_ptr_occupancy);
  always @(posedge clk) begin
    if(reset) begin
      logic_ptr_push <= 3'b000;
      logic_ptr_pop <= 3'b000;
      logic_ptr_wentUp <= 1'b0;
      logic_ptr_notPow2_counter <= 3'b000;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 3'b000;
    end else begin
      if(when_Stream_l1248) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 3'b001);
        if(when_Stream_l1283) begin
          logic_ptr_push <= 3'b000;
        end
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 3'b001);
        if(when_Stream_l1287) begin
          logic_ptr_pop <= 3'b000;
        end
      end
      if(io_flush) begin
        logic_ptr_push <= 3'b000;
        logic_ptr_pop <= 3'b000;
      end
      logic_ptr_notPow2_counter <= (_zz_logic_ptr_notPow2_counter - _zz_logic_ptr_notPow2_counter_3);
      if(io_flush) begin
        logic_ptr_notPow2_counter <= 3'b000;
      end
      if(logic_pop_addressGen_ready) begin
        logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
      end
      if(io_flush) begin
        logic_pop_addressGen_rValid <= 1'b0;
      end
      if(logic_pop_sync_readArbitation_fire) begin
        logic_pop_sync_popReg <= logic_ptr_pop;
      end
      if(io_flush) begin
        logic_pop_sync_popReg <= 3'b000;
      end
    end
  end

  always @(posedge clk) begin
    if(logic_pop_addressGen_ready) begin
      logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
    end
  end


endmodule

module EfxDMA_StreamFifo (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [20:0]   io_push_payload_context,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [20:0]   io_pop_payload_context,
  input  wire          io_flush,
  output wire [2:0]    io_occupancy,
  output wire [2:0]    io_availability,
  input  wire          clk,
  input  wire          reset
);

  reg        [20:0]   logic_ram_spinal_port1;
  wire       [2:0]    _zz_logic_ptr_notPow2_counter;
  wire       [2:0]    _zz_logic_ptr_notPow2_counter_1;
  wire       [0:0]    _zz_logic_ptr_notPow2_counter_2;
  wire       [2:0]    _zz_logic_ptr_notPow2_counter_3;
  wire       [0:0]    _zz_logic_ptr_notPow2_counter_4;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [2:0]    logic_ptr_push;
  reg        [2:0]    logic_ptr_pop;
  wire       [2:0]    logic_ptr_occupancy;
  wire       [2:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1248;
  reg                 logic_ptr_wentUp;
  wire                when_Stream_l1283;
  wire                when_Stream_l1287;
  reg        [2:0]    logic_ptr_notPow2_counter;
  wire                io_push_fire;
  wire                io_pop_fire;
  wire                logic_push_onRam_write_valid;
  wire       [2:0]    logic_push_onRam_write_payload_address;
  wire       [20:0]   logic_push_onRam_write_payload_data_context;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [2:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [2:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [2:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l375;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [2:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [20:0]   logic_pop_sync_readPort_rsp_context;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [20:0]   logic_pop_sync_readArbitation_translated_payload_context;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [2:0]    logic_pop_sync_popReg;
  reg [20:0] logic_ram [0:6];

  assign _zz_logic_ptr_notPow2_counter = (logic_ptr_notPow2_counter + _zz_logic_ptr_notPow2_counter_1);
  assign _zz_logic_ptr_notPow2_counter_2 = io_push_fire;
  assign _zz_logic_ptr_notPow2_counter_1 = {2'd0, _zz_logic_ptr_notPow2_counter_2};
  assign _zz_logic_ptr_notPow2_counter_4 = io_pop_fire;
  assign _zz_logic_ptr_notPow2_counter_3 = {2'd0, _zz_logic_ptr_notPow2_counter_4};
  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_push_onRam_write_payload_address] <= logic_push_onRam_write_payload_data_context;
    end
  end

  always @(posedge clk) begin
    if(logic_pop_sync_readPort_cmd_valid) begin
      logic_ram_spinal_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_push_onRam_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign when_Stream_l1248 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = ((logic_ptr_push == logic_ptr_popOnIo) && logic_ptr_wentUp);
  assign logic_ptr_empty = ((logic_ptr_push == logic_ptr_pop) && (! logic_ptr_wentUp));
  assign when_Stream_l1283 = (logic_ptr_push == 3'b110);
  assign when_Stream_l1287 = (logic_ptr_pop == 3'b110);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign io_pop_fire = (io_pop_valid && io_pop_ready);
  assign logic_ptr_occupancy = logic_ptr_notPow2_counter;
  assign io_push_ready = (! logic_ptr_full);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push;
  assign logic_push_onRam_write_payload_data_context = io_push_payload_context;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop;
  assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
  assign logic_ptr_doPop = logic_pop_addressGen_fire;
  always @(*) begin
    logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
    if(when_Stream_l375) begin
      logic_pop_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l375 = (! logic_pop_sync_readArbitation_valid);
  assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
  assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
  assign logic_pop_sync_readPort_rsp_context = logic_ram_spinal_port1[20 : 0];
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_fire;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload_context = logic_pop_sync_readPort_rsp_context;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_context = logic_pop_sync_readArbitation_translated_payload_context;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (3'b111 - logic_ptr_occupancy);
  always @(posedge clk) begin
    if(reset) begin
      logic_ptr_push <= 3'b000;
      logic_ptr_pop <= 3'b000;
      logic_ptr_wentUp <= 1'b0;
      logic_ptr_notPow2_counter <= 3'b000;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 3'b000;
    end else begin
      if(when_Stream_l1248) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 3'b001);
        if(when_Stream_l1283) begin
          logic_ptr_push <= 3'b000;
        end
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 3'b001);
        if(when_Stream_l1287) begin
          logic_ptr_pop <= 3'b000;
        end
      end
      if(io_flush) begin
        logic_ptr_push <= 3'b000;
        logic_ptr_pop <= 3'b000;
      end
      logic_ptr_notPow2_counter <= (_zz_logic_ptr_notPow2_counter - _zz_logic_ptr_notPow2_counter_3);
      if(io_flush) begin
        logic_ptr_notPow2_counter <= 3'b000;
      end
      if(logic_pop_addressGen_ready) begin
        logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
      end
      if(io_flush) begin
        logic_pop_addressGen_rValid <= 1'b0;
      end
      if(logic_pop_sync_readArbitation_fire) begin
        logic_pop_sync_popReg <= logic_ptr_pop;
      end
      if(io_flush) begin
        logic_pop_sync_popReg <= 3'b000;
      end
    end
  end

  always @(posedge clk) begin
    if(logic_pop_addressGen_ready) begin
      logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
    end
  end


endmodule

module EfxDMA_BufferCC_1 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk) begin
    if(ctrl_reset) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module EfxDMA_BufferCC (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          clk,
  input  wire          reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge clk) begin
    if(reset) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule
