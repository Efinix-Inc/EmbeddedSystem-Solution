// Generator : SpinalHDL dev    git head : 8110d461d26b1efcc14be97a24c461052245a1de
// Component : MacTxLso
// Git hash  : 56a3abea056878726b04a29f693fa9a2dd65be02

`timescale 1ns/1ps

module MacTxLso (
  input  wire          io_input_valid,
  output wire          io_input_ready,
  input  wire          io_input_payload_last,
  input  wire [7:0]    io_input_payload_fragment_data,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire          io_output_payload_last,
  output wire [7:0]    io_output_payload_fragment_data,
  input  wire          clk,
  input  wire          reset
);

  wire                lso_io_input_ready;
  wire                lso_io_output_valid;
  wire                lso_io_output_payload_last;
  wire       [7:0]    lso_io_output_payload_fragment_data;
  wire                io_input_s2mPipe_valid;
  reg                 io_input_s2mPipe_ready;
  wire                io_input_s2mPipe_payload_last;
  wire       [7:0]    io_input_s2mPipe_payload_fragment_data;
  reg                 io_input_rValidN;
  reg                 io_input_rData_last;
  reg        [7:0]    io_input_rData_fragment_data;
  wire                io_input_s2mPipe_m2sPipe_valid;
  wire                io_input_s2mPipe_m2sPipe_ready;
  wire                io_input_s2mPipe_m2sPipe_payload_last;
  wire       [7:0]    io_input_s2mPipe_m2sPipe_payload_fragment_data;
  reg                 io_input_s2mPipe_rValid;
  reg                 io_input_s2mPipe_rData_last;
  reg        [7:0]    io_input_s2mPipe_rData_fragment_data;
  wire                when_Stream_l477;
  wire                io_output_s2mPipe_valid;
  reg                 io_output_s2mPipe_ready;
  wire                io_output_s2mPipe_payload_last;
  wire       [7:0]    io_output_s2mPipe_payload_fragment_data;
  reg                 io_output_rValidN;
  reg                 io_output_rData_last;
  reg        [7:0]    io_output_rData_fragment_data;
  wire                io_output_s2mPipe_m2sPipe_valid;
  wire                io_output_s2mPipe_m2sPipe_ready;
  wire                io_output_s2mPipe_m2sPipe_payload_last;
  wire       [7:0]    io_output_s2mPipe_m2sPipe_payload_fragment_data;
  reg                 io_output_s2mPipe_rValid;
  reg                 io_output_s2mPipe_rData_last;
  reg        [7:0]    io_output_s2mPipe_rData_fragment_data;
  wire                when_Stream_l477_1;

  MacTxLso_MacTxLso lso (
    .io_input_valid                  (io_input_s2mPipe_m2sPipe_valid                     ), //i
    .io_input_ready                  (lso_io_input_ready                                 ), //o
    .io_input_payload_last           (io_input_s2mPipe_m2sPipe_payload_last              ), //i
    .io_input_payload_fragment_data  (io_input_s2mPipe_m2sPipe_payload_fragment_data[7:0]), //i
    .io_output_valid                 (lso_io_output_valid                                ), //o
    .io_output_ready                 (io_output_rValidN                                  ), //i
    .io_output_payload_last          (lso_io_output_payload_last                         ), //o
    .io_output_payload_fragment_data (lso_io_output_payload_fragment_data[7:0]           ), //o
    .clk                             (clk                                                ), //i
    .reset                           (reset                                              )  //i
  );
  assign io_input_ready = io_input_rValidN;
  assign io_input_s2mPipe_valid = (io_input_valid || (! io_input_rValidN));
  assign io_input_s2mPipe_payload_last = (io_input_rValidN ? io_input_payload_last : io_input_rData_last);
  assign io_input_s2mPipe_payload_fragment_data = (io_input_rValidN ? io_input_payload_fragment_data : io_input_rData_fragment_data);
  always @(*) begin
    io_input_s2mPipe_ready = io_input_s2mPipe_m2sPipe_ready;
    if(when_Stream_l477) begin
      io_input_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l477 = (! io_input_s2mPipe_m2sPipe_valid);
  assign io_input_s2mPipe_m2sPipe_valid = io_input_s2mPipe_rValid;
  assign io_input_s2mPipe_m2sPipe_payload_last = io_input_s2mPipe_rData_last;
  assign io_input_s2mPipe_m2sPipe_payload_fragment_data = io_input_s2mPipe_rData_fragment_data;
  assign io_input_s2mPipe_m2sPipe_ready = lso_io_input_ready;
  assign io_output_s2mPipe_valid = (lso_io_output_valid || (! io_output_rValidN));
  assign io_output_s2mPipe_payload_last = (io_output_rValidN ? lso_io_output_payload_last : io_output_rData_last);
  assign io_output_s2mPipe_payload_fragment_data = (io_output_rValidN ? lso_io_output_payload_fragment_data : io_output_rData_fragment_data);
  always @(*) begin
    io_output_s2mPipe_ready = io_output_s2mPipe_m2sPipe_ready;
    if(when_Stream_l477_1) begin
      io_output_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l477_1 = (! io_output_s2mPipe_m2sPipe_valid);
  assign io_output_s2mPipe_m2sPipe_valid = io_output_s2mPipe_rValid;
  assign io_output_s2mPipe_m2sPipe_payload_last = io_output_s2mPipe_rData_last;
  assign io_output_s2mPipe_m2sPipe_payload_fragment_data = io_output_s2mPipe_rData_fragment_data;
  assign io_output_valid = io_output_s2mPipe_m2sPipe_valid;
  assign io_output_s2mPipe_m2sPipe_ready = io_output_ready;
  assign io_output_payload_last = io_output_s2mPipe_m2sPipe_payload_last;
  assign io_output_payload_fragment_data = io_output_s2mPipe_m2sPipe_payload_fragment_data;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_input_rValidN <= 1'b1;
      io_input_s2mPipe_rValid <= 1'b0;
      io_output_rValidN <= 1'b1;
      io_output_s2mPipe_rValid <= 1'b0;
    end else begin
      if(io_input_valid) begin
        io_input_rValidN <= 1'b0;
      end
      if(io_input_s2mPipe_ready) begin
        io_input_rValidN <= 1'b1;
      end
      if(io_input_s2mPipe_ready) begin
        io_input_s2mPipe_rValid <= io_input_s2mPipe_valid;
      end
      if(lso_io_output_valid) begin
        io_output_rValidN <= 1'b0;
      end
      if(io_output_s2mPipe_ready) begin
        io_output_rValidN <= 1'b1;
      end
      if(io_output_s2mPipe_ready) begin
        io_output_s2mPipe_rValid <= io_output_s2mPipe_valid;
      end
    end
  end

  always @(posedge clk) begin
    if(io_input_ready) begin
      io_input_rData_last <= io_input_payload_last;
      io_input_rData_fragment_data <= io_input_payload_fragment_data;
    end
    if(io_input_s2mPipe_ready) begin
      io_input_s2mPipe_rData_last <= io_input_s2mPipe_payload_last;
      io_input_s2mPipe_rData_fragment_data <= io_input_s2mPipe_payload_fragment_data;
    end
    if(io_output_rValidN) begin
      io_output_rData_last <= lso_io_output_payload_last;
      io_output_rData_fragment_data <= lso_io_output_payload_fragment_data;
    end
    if(io_output_s2mPipe_ready) begin
      io_output_s2mPipe_rData_last <= io_output_s2mPipe_payload_last;
      io_output_s2mPipe_rData_fragment_data <= io_output_s2mPipe_payload_fragment_data;
    end
  end


endmodule

module MacTxLso_MacTxLso (
  input  wire          io_input_valid,
  output wire          io_input_ready,
  input  wire          io_input_payload_last,
  input  wire [7:0]    io_input_payload_fragment_data,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire          io_output_payload_last,
  output wire [7:0]    io_output_payload_fragment_data,
  input  wire          clk,
  input  wire          reset
);
  localparam frontend_BOOT = 29'd1;
  localparam frontend_INIT = 29'd2;
  localparam frontend_ETH = 29'd4;
  localparam frontend_DONE = 29'd8;
  localparam frontend_IPV4 = 29'd16;
  localparam frontend_IPV4_UNKNOWN = 29'd32;
  localparam frontend_TCP = 29'd64;
  localparam frontend_UDP = 29'd128;
  //localparam frontend_ICMP = 29'd256;
  localparam frontend_CS_WRITE_0 = 29'd512;
  localparam frontend_CS_WRITE_1 = 29'd1024;
  localparam frontend_IP4_LENGTH_0 = 29'd2048;
  localparam frontend_IP4_LENGTH_1 = 29'd4096;
  localparam frontend_IP4_CS_0 = 29'd8192;
  localparam frontend_IP4_CS_1 = 29'd16384;
  localparam frontend_TSO_DATA = 29'd32768;
  localparam frontend_TSO_IP4_LENGTH_0 = 29'd65536;
  localparam frontend_TSO_IP4_LENGTH_1 = 29'd131072;
  localparam frontend_TSO_IP4_CS_0 = 29'd262144;
  localparam frontend_TSO_IP4_CS_1 = 29'd524288;
  localparam frontend_TSO_SN_0 = 29'd1048576;
  localparam frontend_TSO_SN_1 = 29'd2097152;
  localparam frontend_TSO_SN_2 = 29'd4194304;
  localparam frontend_TSO_SN_3 = 29'd8388608;
  localparam frontend_TSO_FLAG = 29'd16777216;
  localparam frontend_TSO_CS_0 = 29'd33554432;
  localparam frontend_TSO_CS_1 = 29'd67108864;
  localparam frontend_TSO_SPLIT_END = 29'd134217728;
  localparam frontend_TSO_HEADER_CPY = 29'd268435456;
  localparam frontend_BOOT_OH_ID = 0;
  localparam frontend_INIT_OH_ID = 1;
  localparam frontend_ETH_OH_ID = 2;
  localparam frontend_DONE_OH_ID = 3;
  localparam frontend_IPV4_OH_ID = 4;
  localparam frontend_IPV4_UNKNOWN_OH_ID = 5;
  localparam frontend_TCP_OH_ID = 6;
  localparam frontend_UDP_OH_ID = 7;
  //localparam frontend_ICMP_OH_ID = 8;
  localparam frontend_CS_WRITE_0_OH_ID = 9;
  localparam frontend_CS_WRITE_1_OH_ID = 10;
  localparam frontend_IP4_LENGTH_0_OH_ID = 11;
  localparam frontend_IP4_LENGTH_1_OH_ID = 12;
  localparam frontend_IP4_CS_0_OH_ID = 13;
  localparam frontend_IP4_CS_1_OH_ID = 14;
  localparam frontend_TSO_DATA_OH_ID = 15;
  localparam frontend_TSO_IP4_LENGTH_0_OH_ID = 16;
  localparam frontend_TSO_IP4_LENGTH_1_OH_ID = 17;
  localparam frontend_TSO_IP4_CS_0_OH_ID = 18;
  localparam frontend_TSO_IP4_CS_1_OH_ID = 19;
  localparam frontend_TSO_SN_0_OH_ID = 20;
  localparam frontend_TSO_SN_1_OH_ID = 21;
  localparam frontend_TSO_SN_2_OH_ID = 22;
  localparam frontend_TSO_SN_3_OH_ID = 23;
  localparam frontend_TSO_FLAG_OH_ID = 24;
  localparam frontend_TSO_CS_0_OH_ID = 25;
  localparam frontend_TSO_CS_1_OH_ID = 26;
  localparam frontend_TSO_SPLIT_END_OH_ID = 27;
  localparam frontend_TSO_HEADER_CPY_OH_ID = 28;

  reg        [8:0]    buffer_ram_spinal_port1;
  reg        [7:0]    header_ram_spinal_port1;
  wire       [8:0]    _zz_buffer_ram_port;
  wire       [7:0]    _zz_buffer_readRsp_payload_fragment_data;
  wire       [11:0]   _zz_buffer_full;
  wire       [16:0]   _zz_frontend_checksum_sOverflow;
  wire       [16:0]   _zz_frontend_checksum_sMuxed;
  wire       [16:0]   _zz_frontend_checksumTso_sOverflow;
  wire       [16:0]   _zz_frontend_checksumTso_sMuxed;
  wire       [16:0]   _zz_frontend_checksumIp_sOverflow;
  wire       [16:0]   _zz_frontend_checksumIp_sMuxed;
  wire       [10:0]   _zz_frontend_tsoPacketLast;
  wire       [11:0]   _zz_frontend_tcpAt;
  wire       [11:0]   _zz_frontend_tcpAt_1;
  wire       [5:0]    _zz_frontend_tcpAt_2;
  wire       [7:0]    _zz_frontend_tsoHeaderLength;
  wire       [7:0]    _zz_frontend_tsoHeaderLength_1;
  wire       [5:0]    _zz_frontend_tsoHeaderLength_2;
  wire       [7:0]    _zz_frontend_tsoHeaderLength_3;
  wire       [5:0]    _zz_frontend_tsoHeaderLength_4;
  wire       [15:0]   _zz_frontend_checksum_input;
  wire       [5:0]    _zz_frontend_checksum_input_1;
  wire       [15:0]   _zz_when_MacTx_l590;
  wire       [5:0]    _zz_when_MacTx_l590_1;
  wire       [5:0]    _zz_when_MacTx_l590_2;
  wire       [15:0]   _zz_frontend_checksumTso_push;
  wire       [15:0]   _zz_frontend_checksumTso_push_1;
  wire       [15:0]   _zz_when_MacTx_l644;
  wire       [5:0]    _zz_when_MacTx_l644_1;
  wire       [5:0]    _zz_when_MacTx_l644_2;
  wire       [11:0]   _zz_buffer_write_payload_data_last;
  wire       [10:0]   _zz_buffer_write_payload_data_last_1;
  wire       [11:0]   _zz_buffer_write_payload_address;
  wire       [11:0]   _zz_buffer_write_payload_address_1;
  wire       [11:0]   _zz_buffer_write_payload_address_2;
  wire       [11:0]   _zz_buffer_write_payload_address_3;
  wire       [10:0]   _zz_frontend_checksumTso_input;
  wire       [10:0]   _zz_frontend_checksumTso_input_1;
  wire       [5:0]    _zz_frontend_checksumTso_input_2;
  wire       [11:0]   _zz_buffer_write_payload_address_4;
  wire       [11:0]   _zz_buffer_write_payload_address_5;
  wire       [11:0]   _zz_buffer_write_payload_address_6;
  wire       [11:0]   _zz_buffer_write_payload_address_7;
  wire       [11:0]   _zz_buffer_write_payload_address_8;
  wire       [11:0]   _zz_buffer_write_payload_address_9;
  wire       [11:0]   _zz_buffer_write_payload_address_10;
  wire       [11:0]   _zz_buffer_write_payload_address_11;
  wire       [11:0]   _zz_buffer_write_payload_address_12;
  wire       [31:0]   _zz_frontend_tcpCtx_sequenceNumber;
  wire       [10:0]   _zz_frontend_tcpCtx_sequenceNumber_1;
  wire       [10:0]   _zz_frontend_tcpCtx_sequenceNumber_2;
  reg                 _zz_1;
  reg                 _zz_2;
  reg        [11:0]   buffer_pushAt;
  reg        [11:0]   buffer_popAt;
  reg                 buffer_write_valid;
  reg        [10:0]   buffer_write_payload_address;
  reg                 buffer_write_payload_data_last;
  reg        [7:0]    buffer_write_payload_data_fragment_data;
  wire                buffer_readCmd_valid;
  wire                buffer_readCmd_ready;
  wire       [10:0]   buffer_readCmd_payload;
  wire                buffer_readRsp_valid;
  wire                buffer_readRsp_ready;
  wire                buffer_readRsp_payload_last;
  wire       [7:0]    buffer_readRsp_payload_fragment_data;
  reg                 _zz_buffer_readRsp_valid;
  wire                buffer_readCmd_fire;
  wire       [8:0]    _zz_buffer_readRsp_payload_last;
  wire                buffer_readRsp_isFree;
  reg                 buffer_packets_incrementIt;
  reg                 buffer_packets_decrementIt;
  wire       [3:0]    buffer_packets_valueNext;
  reg        [3:0]    buffer_packets_value;
  wire                buffer_packets_mayOverflow;
  wire                buffer_packets_mayUnderflow;
  wire                buffer_packets_willOverflowIfInc;
  wire                buffer_packets_willOverflow;
  wire                buffer_packets_willUnderflowIfDec;
  wire                buffer_packets_willUnderflow;
  reg        [3:0]    buffer_packets_finalIncrement;
  wire                when_Utils_l767;
  wire                when_Utils_l769;
  reg                 buffer_full;
  wire                buffer_empty;
  reg        [11:0]   buffer_packetAt;
  reg                 buffer_push;
  reg                 header_capture;
  reg                 header_write_valid;
  wire       [7:0]    header_write_payload_address;
  wire       [7:0]    header_write_payload_data;
  reg        [7:0]    header_writePtr;
  wire                io_input_fire;
  wire                when_MacTx_l418;
  reg                 header_readCmd_valid;
  wire                header_readCmd_ready;
  wire       [7:0]    header_readCmd_payload;
  wire                header_readRsp_valid;
  wire                header_readRsp_ready;
  wire       [7:0]    header_readRsp_payload;
  reg                 _zz_header_readRsp_valid;
  wire                header_readCmd_fire;
  wire                header_readRsp_isFree;
  reg                 header_readBusy;
  reg        [7:0]    header_readPtr;
  wire                header_readEnd;
  wire                when_MacTx_l430;
  reg                 header_clear;
  wire                buffer_readRsp_fire;
  wire                when_MacTx_l457;
  wire                _zz_buffer_readRsp_ready;
  wire                buffer_readRsp_haltWhen_valid;
  reg                 buffer_readRsp_haltWhen_ready;
  wire                buffer_readRsp_haltWhen_payload_last;
  wire       [7:0]    buffer_readRsp_haltWhen_payload_fragment_data;
  wire                buffer_readRsp_haltWhen_stage_valid;
  wire                buffer_readRsp_haltWhen_stage_ready;
  wire                buffer_readRsp_haltWhen_stage_payload_last;
  wire       [7:0]    buffer_readRsp_haltWhen_stage_payload_fragment_data;
  reg                 buffer_readRsp_haltWhen_rValid;
  reg                 buffer_readRsp_haltWhen_rData_last;
  reg        [7:0]    buffer_readRsp_haltWhen_rData_fragment_data;
  wire                when_Stream_l477;
  wire                frontend_wantExit;
  reg                 frontend_wantStart;
  wire                frontend_wantKill;
  reg                 frontend_firstSegment;
  reg                 frontend_lastFired;
  wire                when_MacTx_l471;
  reg                 frontend_halted;
  wire       [7:0]    frontend_history_0;
  wire       [7:0]    frontend_history_1;
  wire       [7:0]    _zz_frontend_history_0;
  reg        [7:0]    _zz_frontend_history_1;
  reg        [15:0]   frontend_counter;
  reg        [10:0]   frontend_packetBytes;
  reg                 frontend_checksum_clear;
  reg        [15:0]   frontend_checksum_accumulator;
  reg                 frontend_checksum_push;
  wire                frontend_checksum_inputLsb;
  wire       [7:0]    frontend_checksum_inputData;
  reg        [15:0]   frontend_checksum_input;
  (* keep , syn_keep *) wire       [16:0]   frontend_checksum_sNoOverflow /* synthesis syn_keep = 1 */ ;
  (* keep , syn_keep *) wire       [16:0]   frontend_checksum_sOverflow /* synthesis syn_keep = 1 */ ;
  wire       [15:0]   frontend_checksum_sMuxed;
  wire       [15:0]   frontend_checksum_result;
  reg                 frontend_checksumTso_clear;
  reg        [15:0]   frontend_checksumTso_accumulator;
  reg                 frontend_checksumTso_push;
  reg                 frontend_checksumTso_inputLsb;
  reg        [7:0]    frontend_checksumTso_inputData;
  reg        [15:0]   frontend_checksumTso_input;
  (* keep , syn_keep *) wire       [16:0]   frontend_checksumTso_sNoOverflow /* synthesis syn_keep = 1 */ ;
  (* keep , syn_keep *) wire       [16:0]   frontend_checksumTso_sOverflow /* synthesis syn_keep = 1 */ ;
  wire       [15:0]   frontend_checksumTso_sMuxed;
  wire       [15:0]   frontend_checksumTso_result;
  reg        [15:0]   frontend_checksumTso_checkpoint;
  reg                 frontend_checksumTso_save;
  reg                 frontend_checksumTso_restore;
  reg                 frontend_checksumIp_clear;
  reg        [15:0]   frontend_checksumIp_accumulator;
  reg                 frontend_checksumIp_push;
  reg                 frontend_checksumIp_inputLsb;
  reg        [7:0]    frontend_checksumIp_inputData;
  wire       [15:0]   frontend_checksumIp_input;
  (* keep , syn_keep *) wire       [16:0]   frontend_checksumIp_sNoOverflow /* synthesis syn_keep = 1 */ ;
  (* keep , syn_keep *) wire       [16:0]   frontend_checksumIp_sOverflow /* synthesis syn_keep = 1 */ ;
  wire       [15:0]   frontend_checksumIp_sMuxed;
  wire       [15:0]   frontend_checksumIp_result;
  reg        [15:0]   frontend_checksumIp_checkpoint;
  reg                 frontend_checksumIp_save;
  reg                 frontend_checksumIp_restore;
  reg        [3:0]    frontend_IHL;
  reg        [7:0]    frontend_protocol;
  reg        [10:0]   frontend_csAt;
  reg        [15:0]   frontend_ip4Length;
  reg                 frontend_tcpCtx_flags_FIN;
  reg                 frontend_tcpCtx_flags_SYN;
  reg                 frontend_tcpCtx_flags_RST;
  reg                 frontend_tcpCtx_flags_PSH;
  reg                 frontend_tcpCtx_flags_ACK;
  reg                 frontend_tcpCtx_flags_URG;
  reg                 frontend_tcpCtx_flags_ECE;
  reg                 frontend_tcpCtx_flags_CWR;
  reg        [3:0]    frontend_tcpCtx_dataOffset;
  reg        [31:0]   frontend_tcpCtx_sequenceNumber;
  reg        [15:0]   frontend_tcpCtx_urgentPointer;
  wire                frontend_tsoPacketLast;
  reg        [11:0]   frontend_tcpAt;
  wire       [10:0]   frontend_tsoIp4Length;
  wire       [7:0]    frontend_tsoHeaderLength;
  wire       [2:0]    _zz_buffer_write_payload_data_fragment_data;
  wire       [7:0]    _zz_buffer_write_payload_data_fragment_data_1;
  wire                frontend_lastSegment;
  wire                frontend_fp_FIN;
  wire                frontend_fp_SYN;
  wire                frontend_fp_RST;
  wire                frontend_fp_PSH;
  wire                frontend_fp_ACK;
  wire                frontend_fp_URG;
  wire                frontend_fp_ECE;
  wire                frontend_fp_CWR;
  wire       [7:0]    _zz_buffer_write_payload_data_fragment_data_2;
  wire       [7:0]    _zz_buffer_write_payload_data_fragment_data_3;
  wire       [7:0]    _zz_buffer_write_payload_data_fragment_data_4;
  wire       [7:0]    _zz_buffer_write_payload_data_fragment_data_5;
  wire       [7:0]    _zz_buffer_write_payload_data_fragment_data_6;
  reg        [28:0]   frontend_stateReg;
  reg        [28:0]   frontend_stateNext;
  wire                when_MacTx_l539;
  wire                when_MacTx_l541;
  wire                when_MacTx_l566;
  wire                when_MacTx_l573;
  wire                when_MacTx_l578;
  wire                when_MacTx_l585;
  wire                when_MacTx_l587;
  wire                when_MacTx_l594;
  wire                when_MacTx_l590;
  wire                when_MacTx_l796;
  wire                when_MacTx_l625;
  wire                when_MacTx_l625_1;
  wire                when_MacTx_l625_2;
  wire                when_MacTx_l625_3;
  wire                when_MacTx_l625_4;
  wire       [7:0]    _zz_frontend_tcpCtx_flags_FIN;
  wire                when_MacTx_l625_5;
  wire                when_MacTx_l625_6;
  wire                when_MacTx_l635;
  wire                when_MacTx_l636;
  wire                when_MacTx_l641;
  wire                when_MacTx_l644;
  wire                when_MacTx_l651;
  wire                when_MacTx_l768;
  wire                when_MacTx_l773;
  wire                when_MacTx_l783;
  wire                when_MacTx_l788;
  wire                when_MacTx_l682;
  wire                when_MacTx_l668;
  wire                frontend_onExit_BOOT;
  wire                frontend_onExit_INIT;
  wire                frontend_onExit_ETH;
  wire                frontend_onExit_DONE;
  wire                frontend_onExit_IPV4;
  wire                frontend_onExit_IPV4_UNKNOWN;
  wire                frontend_onExit_TCP;
  wire                frontend_onExit_UDP;
  wire                frontend_onExit_ICMP;
  wire                frontend_onExit_CS_WRITE_0;
  wire                frontend_onExit_CS_WRITE_1;
  wire                frontend_onExit_IP4_LENGTH_0;
  wire                frontend_onExit_IP4_LENGTH_1;
  wire                frontend_onExit_IP4_CS_0;
  wire                frontend_onExit_IP4_CS_1;
  wire                frontend_onExit_TSO_DATA;
  wire                frontend_onExit_TSO_IP4_LENGTH_0;
  wire                frontend_onExit_TSO_IP4_LENGTH_1;
  wire                frontend_onExit_TSO_IP4_CS_0;
  wire                frontend_onExit_TSO_IP4_CS_1;
  wire                frontend_onExit_TSO_SN_0;
  wire                frontend_onExit_TSO_SN_1;
  wire                frontend_onExit_TSO_SN_2;
  wire                frontend_onExit_TSO_SN_3;
  wire                frontend_onExit_TSO_FLAG;
  wire                frontend_onExit_TSO_CS_0;
  wire                frontend_onExit_TSO_CS_1;
  wire                frontend_onExit_TSO_SPLIT_END;
  wire                frontend_onExit_TSO_HEADER_CPY;
  wire                frontend_onEntry_BOOT;
  wire                frontend_onEntry_INIT;
  wire                frontend_onEntry_ETH;
  wire                frontend_onEntry_DONE;
  wire                frontend_onEntry_IPV4;
  wire                frontend_onEntry_IPV4_UNKNOWN;
  wire                frontend_onEntry_TCP;
  wire                frontend_onEntry_UDP;
  wire                frontend_onEntry_ICMP;
  wire                frontend_onEntry_CS_WRITE_0;
  wire                frontend_onEntry_CS_WRITE_1;
  wire                frontend_onEntry_IP4_LENGTH_0;
  wire                frontend_onEntry_IP4_LENGTH_1;
  wire                frontend_onEntry_IP4_CS_0;
  wire                frontend_onEntry_IP4_CS_1;
  wire                frontend_onEntry_TSO_DATA;
  wire                frontend_onEntry_TSO_IP4_LENGTH_0;
  wire                frontend_onEntry_TSO_IP4_LENGTH_1;
  wire                frontend_onEntry_TSO_IP4_CS_0;
  wire                frontend_onEntry_TSO_IP4_CS_1;
  wire                frontend_onEntry_TSO_SN_0;
  wire                frontend_onEntry_TSO_SN_1;
  wire                frontend_onEntry_TSO_SN_2;
  wire                frontend_onEntry_TSO_SN_3;
  wire                frontend_onEntry_TSO_FLAG;
  wire                frontend_onEntry_TSO_CS_0;
  wire                frontend_onEntry_TSO_CS_1;
  wire                frontend_onEntry_TSO_SPLIT_END;
  wire                frontend_onEntry_TSO_HEADER_CPY;
  `ifndef SYNTHESIS
  reg [127:0] frontend_stateReg_string;
  reg [127:0] frontend_stateNext_string;
  `endif

  reg [8:0] buffer_ram [0:2047];
  reg [7:0] header_ram [0:134];

  assign _zz_buffer_readRsp_payload_fragment_data = _zz_buffer_readRsp_payload_last[8 : 1];
  assign _zz_buffer_full = (buffer_pushAt - buffer_popAt);
  assign _zz_frontend_checksum_sOverflow = ({1'b0,frontend_checksum_accumulator} + {1'b0,frontend_checksum_input});
  assign _zz_frontend_checksum_sMuxed = (frontend_checksum_sNoOverflow[16] ? frontend_checksum_sOverflow : frontend_checksum_sNoOverflow);
  assign _zz_frontend_checksumTso_sOverflow = ({1'b0,frontend_checksumTso_accumulator} + {1'b0,frontend_checksumTso_input});
  assign _zz_frontend_checksumTso_sMuxed = (frontend_checksumTso_sNoOverflow[16] ? frontend_checksumTso_sOverflow : frontend_checksumTso_sNoOverflow);
  assign _zz_frontend_checksumIp_sOverflow = ({1'b0,frontend_checksumIp_accumulator} + {1'b0,frontend_checksumIp_input});
  assign _zz_frontend_checksumIp_sMuxed = (frontend_checksumIp_sNoOverflow[16] ? frontend_checksumIp_sOverflow : frontend_checksumIp_sNoOverflow);
  assign _zz_frontend_tsoPacketLast = (frontend_packetBytes + 11'h001);
  assign _zz_frontend_tcpAt = (buffer_packetAt + 12'h00e);
  assign _zz_frontend_tcpAt_2 = ({2'd0,frontend_IHL} <<< 2'd2);
  assign _zz_frontend_tcpAt_1 = {6'd0, _zz_frontend_tcpAt_2};
  assign _zz_frontend_tsoHeaderLength = (8'h0e + _zz_frontend_tsoHeaderLength_1);
  assign _zz_frontend_tsoHeaderLength_2 = ({2'd0,frontend_IHL} <<< 2'd2);
  assign _zz_frontend_tsoHeaderLength_1 = {2'd0, _zz_frontend_tsoHeaderLength_2};
  assign _zz_frontend_tsoHeaderLength_4 = ({2'd0,frontend_tcpCtx_dataOffset} <<< 2'd2);
  assign _zz_frontend_tsoHeaderLength_3 = {2'd0, _zz_frontend_tsoHeaderLength_4};
  assign _zz_frontend_checksum_input_1 = ({2'd0,frontend_IHL} <<< 2'd2);
  assign _zz_frontend_checksum_input = {10'd0, _zz_frontend_checksum_input_1};
  assign _zz_when_MacTx_l590_1 = (_zz_when_MacTx_l590_2 - 6'h01);
  assign _zz_when_MacTx_l590 = {10'd0, _zz_when_MacTx_l590_1};
  assign _zz_when_MacTx_l590_2 = ({2'd0,frontend_IHL} <<< 2'd2);
  assign _zz_when_MacTx_l644_1 = (_zz_when_MacTx_l644_2 - 6'h01);
  assign _zz_when_MacTx_l644 = {10'd0, _zz_when_MacTx_l644_1};
  assign _zz_when_MacTx_l644_2 = ({2'd0,frontend_tcpCtx_dataOffset} <<< 2'd2);
  assign _zz_buffer_write_payload_data_last_1 = (frontend_csAt + 11'h002);
  assign _zz_buffer_write_payload_data_last = {1'd0, _zz_buffer_write_payload_data_last_1};
  assign _zz_buffer_write_payload_address = (buffer_packetAt + 12'h018);
  assign _zz_buffer_write_payload_address_1 = (buffer_packetAt + 12'h019);
  assign _zz_buffer_write_payload_address_2 = (buffer_packetAt + 12'h010);
  assign _zz_buffer_write_payload_address_3 = (buffer_packetAt + 12'h011);
  assign _zz_frontend_checksumTso_input = (frontend_tsoIp4Length - _zz_frontend_checksumTso_input_1);
  assign _zz_frontend_checksumTso_input_2 = ({2'd0,frontend_IHL} <<< 2'd2);
  assign _zz_frontend_checksumTso_input_1 = {5'd0, _zz_frontend_checksumTso_input_2};
  assign _zz_buffer_write_payload_address_4 = (buffer_packetAt + 12'h018);
  assign _zz_buffer_write_payload_address_5 = (buffer_packetAt + 12'h019);
  assign _zz_buffer_write_payload_address_6 = (frontend_tcpAt + 12'h004);
  assign _zz_buffer_write_payload_address_7 = (frontend_tcpAt + 12'h005);
  assign _zz_buffer_write_payload_address_8 = (frontend_tcpAt + 12'h006);
  assign _zz_buffer_write_payload_address_9 = (frontend_tcpAt + 12'h007);
  assign _zz_buffer_write_payload_address_10 = (frontend_tcpAt + 12'h00d);
  assign _zz_buffer_write_payload_address_11 = (frontend_tcpAt + 12'h010);
  assign _zz_buffer_write_payload_address_12 = (frontend_tcpAt + 12'h011);
  assign _zz_frontend_tcpCtx_sequenceNumber_1 = (frontend_packetBytes - _zz_frontend_tcpCtx_sequenceNumber_2);
  assign _zz_frontend_tcpCtx_sequenceNumber = {21'd0, _zz_frontend_tcpCtx_sequenceNumber_1};
  assign _zz_frontend_tcpCtx_sequenceNumber_2 = {3'd0, frontend_tsoHeaderLength};
  assign _zz_buffer_ram_port = {buffer_write_payload_data_fragment_data,buffer_write_payload_data_last};
  assign _zz_frontend_checksumTso_push = 16'h0005;
  assign _zz_frontend_checksumTso_push_1 = 16'h0004;
  always @(posedge clk) begin
    if(_zz_2) begin
      buffer_ram[buffer_write_payload_address] <= _zz_buffer_ram_port;
    end
  end

  always @(posedge clk) begin
    if(buffer_readCmd_fire) begin
      buffer_ram_spinal_port1 <= buffer_ram[buffer_readCmd_payload];
    end
  end

  always @(posedge clk) begin
    if(_zz_1) begin
      header_ram[header_write_payload_address] <= header_write_payload_data;
    end
  end

  always @(posedge clk) begin
    if(header_readCmd_fire) begin
      header_ram_spinal_port1 <= header_ram[header_readCmd_payload];
    end
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(frontend_stateReg)
      frontend_BOOT : frontend_stateReg_string = "BOOT            ";
      frontend_INIT : frontend_stateReg_string = "INIT            ";
      frontend_ETH : frontend_stateReg_string = "ETH             ";
      frontend_DONE : frontend_stateReg_string = "DONE            ";
      frontend_IPV4 : frontend_stateReg_string = "IPV4            ";
      frontend_IPV4_UNKNOWN : frontend_stateReg_string = "IPV4_UNKNOWN    ";
      frontend_TCP : frontend_stateReg_string = "TCP             ";
      frontend_UDP : frontend_stateReg_string = "UDP             ";
      //frontend_ICMP : frontend_stateReg_string = "ICMP            ";
      frontend_CS_WRITE_0 : frontend_stateReg_string = "CS_WRITE_0      ";
      frontend_CS_WRITE_1 : frontend_stateReg_string = "CS_WRITE_1      ";
      frontend_IP4_LENGTH_0 : frontend_stateReg_string = "IP4_LENGTH_0    ";
      frontend_IP4_LENGTH_1 : frontend_stateReg_string = "IP4_LENGTH_1    ";
      frontend_IP4_CS_0 : frontend_stateReg_string = "IP4_CS_0        ";
      frontend_IP4_CS_1 : frontend_stateReg_string = "IP4_CS_1        ";
      frontend_TSO_DATA : frontend_stateReg_string = "TSO_DATA        ";
      frontend_TSO_IP4_LENGTH_0 : frontend_stateReg_string = "TSO_IP4_LENGTH_0";
      frontend_TSO_IP4_LENGTH_1 : frontend_stateReg_string = "TSO_IP4_LENGTH_1";
      frontend_TSO_IP4_CS_0 : frontend_stateReg_string = "TSO_IP4_CS_0    ";
      frontend_TSO_IP4_CS_1 : frontend_stateReg_string = "TSO_IP4_CS_1    ";
      frontend_TSO_SN_0 : frontend_stateReg_string = "TSO_SN_0        ";
      frontend_TSO_SN_1 : frontend_stateReg_string = "TSO_SN_1        ";
      frontend_TSO_SN_2 : frontend_stateReg_string = "TSO_SN_2        ";
      frontend_TSO_SN_3 : frontend_stateReg_string = "TSO_SN_3        ";
      frontend_TSO_FLAG : frontend_stateReg_string = "TSO_FLAG        ";
      frontend_TSO_CS_0 : frontend_stateReg_string = "TSO_CS_0        ";
      frontend_TSO_CS_1 : frontend_stateReg_string = "TSO_CS_1        ";
      frontend_TSO_SPLIT_END : frontend_stateReg_string = "TSO_SPLIT_END   ";
      frontend_TSO_HEADER_CPY : frontend_stateReg_string = "TSO_HEADER_CPY  ";
      default : frontend_stateReg_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(frontend_stateNext)
      frontend_BOOT : frontend_stateNext_string = "BOOT            ";
      frontend_INIT : frontend_stateNext_string = "INIT            ";
      frontend_ETH : frontend_stateNext_string = "ETH             ";
      frontend_DONE : frontend_stateNext_string = "DONE            ";
      frontend_IPV4 : frontend_stateNext_string = "IPV4            ";
      frontend_IPV4_UNKNOWN : frontend_stateNext_string = "IPV4_UNKNOWN    ";
      frontend_TCP : frontend_stateNext_string = "TCP             ";
      frontend_UDP : frontend_stateNext_string = "UDP             ";
      //frontend_ICMP : frontend_stateNext_string = "ICMP            ";
      frontend_CS_WRITE_0 : frontend_stateNext_string = "CS_WRITE_0      ";
      frontend_CS_WRITE_1 : frontend_stateNext_string = "CS_WRITE_1      ";
      frontend_IP4_LENGTH_0 : frontend_stateNext_string = "IP4_LENGTH_0    ";
      frontend_IP4_LENGTH_1 : frontend_stateNext_string = "IP4_LENGTH_1    ";
      frontend_IP4_CS_0 : frontend_stateNext_string = "IP4_CS_0        ";
      frontend_IP4_CS_1 : frontend_stateNext_string = "IP4_CS_1        ";
      frontend_TSO_DATA : frontend_stateNext_string = "TSO_DATA        ";
      frontend_TSO_IP4_LENGTH_0 : frontend_stateNext_string = "TSO_IP4_LENGTH_0";
      frontend_TSO_IP4_LENGTH_1 : frontend_stateNext_string = "TSO_IP4_LENGTH_1";
      frontend_TSO_IP4_CS_0 : frontend_stateNext_string = "TSO_IP4_CS_0    ";
      frontend_TSO_IP4_CS_1 : frontend_stateNext_string = "TSO_IP4_CS_1    ";
      frontend_TSO_SN_0 : frontend_stateNext_string = "TSO_SN_0        ";
      frontend_TSO_SN_1 : frontend_stateNext_string = "TSO_SN_1        ";
      frontend_TSO_SN_2 : frontend_stateNext_string = "TSO_SN_2        ";
      frontend_TSO_SN_3 : frontend_stateNext_string = "TSO_SN_3        ";
      frontend_TSO_FLAG : frontend_stateNext_string = "TSO_FLAG        ";
      frontend_TSO_CS_0 : frontend_stateNext_string = "TSO_CS_0        ";
      frontend_TSO_CS_1 : frontend_stateNext_string = "TSO_CS_1        ";
      frontend_TSO_SPLIT_END : frontend_stateNext_string = "TSO_SPLIT_END   ";
      frontend_TSO_HEADER_CPY : frontend_stateNext_string = "TSO_HEADER_CPY  ";
      default : frontend_stateNext_string = "????????????????";
    endcase
  end
  `endif

  always @(*) begin
    _zz_1 = 1'b0;
    if(header_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    _zz_2 = 1'b0;
    if(buffer_write_valid) begin
      _zz_2 = 1'b1;
    end
  end

  assign buffer_readCmd_fire = (buffer_readCmd_valid && buffer_readCmd_ready);
  assign _zz_buffer_readRsp_payload_last = buffer_ram_spinal_port1;
  assign buffer_readRsp_isFree = ((! buffer_readRsp_valid) || buffer_readRsp_ready);
  assign buffer_readCmd_ready = buffer_readRsp_isFree;
  assign buffer_readRsp_valid = _zz_buffer_readRsp_valid;
  assign buffer_readRsp_payload_last = _zz_buffer_readRsp_payload_last[0];
  assign buffer_readRsp_payload_fragment_data = _zz_buffer_readRsp_payload_fragment_data[7 : 0];
  always @(*) begin
    buffer_packets_incrementIt = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_DONE_OH_ID]) : begin
        if(frontend_lastFired) begin
          buffer_packets_incrementIt = 1'b1;
        end
      end
      (frontend_stateReg[frontend_TSO_SPLIT_END_OH_ID]) : begin
        buffer_packets_incrementIt = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    buffer_packets_decrementIt = 1'b0;
    if(when_MacTx_l457) begin
      buffer_packets_decrementIt = 1'b1;
    end
  end

  assign buffer_packets_mayOverflow = (buffer_packets_value == 4'b1111);
  assign buffer_packets_mayUnderflow = (buffer_packets_value == 4'b0000);
  assign buffer_packets_willOverflowIfInc = (buffer_packets_mayOverflow && (! buffer_packets_decrementIt));
  assign buffer_packets_willOverflow = (buffer_packets_willOverflowIfInc && buffer_packets_incrementIt);
  assign buffer_packets_willUnderflowIfDec = (buffer_packets_mayUnderflow && (! buffer_packets_incrementIt));
  assign buffer_packets_willUnderflow = (buffer_packets_willUnderflowIfDec && buffer_packets_decrementIt);
  assign when_Utils_l767 = (buffer_packets_incrementIt && (! buffer_packets_decrementIt));
  always @(*) begin
    if(when_Utils_l767) begin
      buffer_packets_finalIncrement = 4'b0001;
    end else begin
      if(when_Utils_l769) begin
        buffer_packets_finalIncrement = 4'b1111;
      end else begin
        buffer_packets_finalIncrement = 4'b0000;
      end
    end
  end

  assign when_Utils_l769 = ((! buffer_packets_incrementIt) && buffer_packets_decrementIt);
  assign buffer_packets_valueNext = (buffer_packets_value + buffer_packets_finalIncrement);
  assign buffer_empty = (buffer_pushAt == buffer_popAt);
  always @(*) begin
    buffer_push = 1'b0;
    if(io_input_fire) begin
      buffer_push = 1'b1;
    end
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
        if(header_readRsp_valid) begin
          buffer_push = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    header_write_valid = 1'b0;
    if(when_MacTx_l418) begin
      header_write_valid = 1'b1;
    end
  end

  assign header_write_payload_address = header_writePtr;
  assign header_write_payload_data = io_input_payload_fragment_data;
  assign io_input_fire = (io_input_valid && io_input_ready);
  assign when_MacTx_l418 = (header_capture && io_input_fire);
  assign header_readCmd_fire = (header_readCmd_valid && header_readCmd_ready);
  assign header_readRsp_isFree = ((! header_readRsp_valid) || header_readRsp_ready);
  assign header_readCmd_ready = header_readRsp_isFree;
  assign header_readRsp_valid = _zz_header_readRsp_valid;
  assign header_readRsp_payload = header_ram_spinal_port1;
  assign header_readEnd = (header_readPtr == header_writePtr);
  always @(*) begin
    header_readCmd_valid = 1'b0;
    if(!when_MacTx_l430) begin
      if(!header_readEnd) begin
        header_readCmd_valid = 1'b1;
      end
    end
  end

  assign header_readCmd_payload = header_readPtr;
  assign when_MacTx_l430 = (! header_readBusy);
  assign header_readRsp_ready = 1'b1;
  always @(*) begin
    header_clear = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_INIT_OH_ID]) : begin
        header_clear = 1'b1;
      end
      (frontend_stateReg[frontend_DONE_OH_ID]) : begin
        if(frontend_lastFired) begin
          header_clear = 1'b1;
        end
      end
      (frontend_stateReg[frontend_TSO_SPLIT_END_OH_ID]) : begin
        if(frontend_lastFired) begin
          header_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign buffer_readCmd_valid = (! buffer_empty);
  assign buffer_readCmd_payload = buffer_popAt[10:0];
  assign buffer_readRsp_fire = (buffer_readRsp_valid && buffer_readRsp_ready);
  assign when_MacTx_l457 = (buffer_readRsp_fire && buffer_readRsp_payload_last);
  assign _zz_buffer_readRsp_ready = (! (buffer_packets_value == 4'b0000));
  assign buffer_readRsp_haltWhen_valid = (buffer_readRsp_valid && _zz_buffer_readRsp_ready);
  assign buffer_readRsp_ready = (buffer_readRsp_haltWhen_ready && _zz_buffer_readRsp_ready);
  assign buffer_readRsp_haltWhen_payload_last = buffer_readRsp_payload_last;
  assign buffer_readRsp_haltWhen_payload_fragment_data = buffer_readRsp_payload_fragment_data;
  always @(*) begin
    buffer_readRsp_haltWhen_ready = buffer_readRsp_haltWhen_stage_ready;
    if(when_Stream_l477) begin
      buffer_readRsp_haltWhen_ready = 1'b1;
    end
  end

  assign when_Stream_l477 = (! buffer_readRsp_haltWhen_stage_valid);
  assign buffer_readRsp_haltWhen_stage_valid = buffer_readRsp_haltWhen_rValid;
  assign buffer_readRsp_haltWhen_stage_payload_last = buffer_readRsp_haltWhen_rData_last;
  assign buffer_readRsp_haltWhen_stage_payload_fragment_data = buffer_readRsp_haltWhen_rData_fragment_data;
  assign io_output_valid = buffer_readRsp_haltWhen_stage_valid;
  assign buffer_readRsp_haltWhen_stage_ready = io_output_ready;
  assign io_output_payload_last = buffer_readRsp_haltWhen_stage_payload_last;
  assign io_output_payload_fragment_data = buffer_readRsp_haltWhen_stage_payload_fragment_data;
  assign frontend_wantExit = 1'b0;
  always @(*) begin
    frontend_wantStart = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_BOOT_OH_ID]) : begin
        frontend_wantStart = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign frontend_wantKill = 1'b0;
  assign when_MacTx_l471 = (io_input_fire && io_input_payload_last);
  assign _zz_frontend_history_0 = io_input_payload_fragment_data;
  assign frontend_history_0 = _zz_frontend_history_0;
  assign frontend_history_1 = _zz_frontend_history_1;
  assign io_input_ready = (((! buffer_full) && (! frontend_lastFired)) && (! frontend_halted));
  always @(*) begin
    buffer_write_valid = io_input_fire;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_CS_WRITE_0_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_CS_WRITE_1_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_IP4_CS_0_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_IP4_CS_1_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_0_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_1_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_SN_0_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_SN_1_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_SN_2_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_SN_3_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_FLAG_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_CS_0_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_CS_1_OH_ID]) : begin
        buffer_write_valid = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
        if(header_readRsp_valid) begin
          buffer_write_valid = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    buffer_write_payload_address = buffer_pushAt[10:0];
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_CS_WRITE_0_OH_ID]) : begin
        buffer_write_payload_address = frontend_csAt;
      end
      (frontend_stateReg[frontend_CS_WRITE_1_OH_ID]) : begin
        buffer_write_payload_address = (frontend_csAt + 11'h001);
      end
      (frontend_stateReg[frontend_IP4_CS_0_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address[10:0];
      end
      (frontend_stateReg[frontend_IP4_CS_1_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_1[10:0];
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_2[10:0];
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_3[10:0];
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_0_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_4[10:0];
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_1_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_5[10:0];
      end
      (frontend_stateReg[frontend_TSO_SN_0_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_6[10:0];
      end
      (frontend_stateReg[frontend_TSO_SN_1_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_7[10:0];
      end
      (frontend_stateReg[frontend_TSO_SN_2_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_8[10:0];
      end
      (frontend_stateReg[frontend_TSO_SN_3_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_9[10:0];
      end
      (frontend_stateReg[frontend_TSO_FLAG_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_10[10:0];
      end
      (frontend_stateReg[frontend_TSO_CS_0_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_11[10:0];
      end
      (frontend_stateReg[frontend_TSO_CS_1_OH_ID]) : begin
        buffer_write_payload_address = _zz_buffer_write_payload_address_12[10:0];
      end
      (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
        if(header_readRsp_valid) begin
          buffer_write_payload_address = buffer_pushAt[10:0];
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    buffer_write_payload_data_last = io_input_payload_last;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_CS_WRITE_0_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_CS_WRITE_1_OH_ID]) : begin
        buffer_write_payload_data_last = (_zz_buffer_write_payload_data_last == buffer_pushAt);
      end
      (frontend_stateReg[frontend_IP4_CS_0_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_IP4_CS_1_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_DATA_OH_ID]) : begin
        if(frontend_tsoPacketLast) begin
          buffer_write_payload_data_last = 1'b1;
        end
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_0_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_1_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_SN_0_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_SN_1_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_SN_2_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_SN_3_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_FLAG_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_CS_0_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_CS_1_OH_ID]) : begin
        buffer_write_payload_data_last = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
        if(header_readRsp_valid) begin
          buffer_write_payload_data_last = 1'b0;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    buffer_write_payload_data_fragment_data = io_input_payload_fragment_data;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_CS_WRITE_0_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = frontend_checksum_result[15 : 8];
      end
      (frontend_stateReg[frontend_CS_WRITE_1_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = frontend_checksum_result[7 : 0];
      end
      (frontend_stateReg[frontend_IP4_CS_0_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = frontend_checksumIp_result[15 : 8];
      end
      (frontend_stateReg[frontend_IP4_CS_1_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = frontend_checksumIp_result[7 : 0];
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = {5'd0, _zz_buffer_write_payload_data_fragment_data};
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = _zz_buffer_write_payload_data_fragment_data_1;
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_0_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = frontend_checksumIp_result[15 : 8];
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_1_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = frontend_checksumIp_result[7 : 0];
      end
      (frontend_stateReg[frontend_TSO_SN_0_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = _zz_buffer_write_payload_data_fragment_data_2;
      end
      (frontend_stateReg[frontend_TSO_SN_1_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = _zz_buffer_write_payload_data_fragment_data_3;
      end
      (frontend_stateReg[frontend_TSO_SN_2_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = _zz_buffer_write_payload_data_fragment_data_4;
      end
      (frontend_stateReg[frontend_TSO_SN_3_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = _zz_buffer_write_payload_data_fragment_data_5;
      end
      (frontend_stateReg[frontend_TSO_FLAG_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = _zz_buffer_write_payload_data_fragment_data_6;
      end
      (frontend_stateReg[frontend_TSO_CS_0_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = frontend_checksumTso_result[15 : 8];
      end
      (frontend_stateReg[frontend_TSO_CS_1_OH_ID]) : begin
        buffer_write_payload_data_fragment_data = frontend_checksumTso_result[7 : 0];
      end
      (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
        if(header_readRsp_valid) begin
          buffer_write_payload_data_fragment_data = header_readRsp_payload;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksum_clear = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_ETH_OH_ID]) : begin
        frontend_checksum_clear = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksum_push = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_IPV4_OH_ID]) : begin
        if(io_input_fire) begin
          frontend_checksum_push = ((16'h000c <= frontend_counter) && (frontend_counter <= 16'h0013));
          if(when_MacTx_l573) begin
            frontend_checksum_push = 1'b1;
          end
          if(when_MacTx_l578) begin
            frontend_checksum_push = 1'b1;
          end
        end
      end
      (frontend_stateReg[frontend_TCP_OH_ID]) : begin
        if(io_input_fire) begin
          frontend_checksum_push = ((frontend_counter != 16'h0010) && (frontend_counter != 16'h0011));
        end
      end
      (frontend_stateReg[frontend_UDP_OH_ID]) : begin
        if(io_input_fire) begin
          frontend_checksum_push = ((frontend_counter != 16'h0006) && (frontend_counter != 16'h0007));
        end
      end
//      (frontend_stateReg[frontend_ICMP_OH_ID]) : begin
//        if(io_input_fire) begin
//          frontend_checksum_push = ((frontend_counter != 16'h0002) && (frontend_counter != 16'h0003));
//        end
//      end
      default : begin
      end
    endcase
  end

  assign frontend_checksum_inputLsb = frontend_counter[0];
  assign frontend_checksum_inputData = io_input_payload_fragment_data;
  always @(*) begin
    frontend_checksum_input = (frontend_checksum_inputLsb ? {8'h0,frontend_checksum_inputData} : {frontend_checksum_inputData,8'h0});
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_IPV4_OH_ID]) : begin
        if(when_MacTx_l566) begin
          frontend_checksum_input = ({frontend_history_1,frontend_history_0} - _zz_frontend_checksum_input);
        end
      end
      default : begin
      end
    endcase
  end

  assign frontend_checksum_sNoOverflow = ({1'b0,frontend_checksum_accumulator} + {1'b0,frontend_checksum_input});
  assign frontend_checksum_sOverflow = (_zz_frontend_checksum_sOverflow + 17'h00001);
  assign frontend_checksum_sMuxed = _zz_frontend_checksum_sMuxed[15 : 0];
  assign frontend_checksum_result = (~ frontend_checksum_accumulator);
  always @(*) begin
    frontend_checksumTso_clear = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_ETH_OH_ID]) : begin
        frontend_checksumTso_clear = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumTso_push = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_IPV4_OH_ID]) : begin
        if(io_input_fire) begin
          frontend_checksumTso_push = ((16'h000c <= frontend_counter) && (frontend_counter <= 16'h0013));
          if(when_MacTx_l573) begin
            frontend_checksumTso_push = 1'b1;
          end
        end
      end
      (frontend_stateReg[frontend_TCP_OH_ID]) : begin
        if(io_input_fire) begin
          frontend_checksumTso_push = (&{(16'h0011 != frontend_counter),{(16'h0010 != frontend_counter),{(16'h000d != frontend_counter),{(16'h0007 != frontend_counter),{(16'h0006 != frontend_counter),{(_zz_frontend_checksumTso_push != frontend_counter),(_zz_frontend_checksumTso_push_1 != frontend_counter)}}}}}});
        end
      end
      (frontend_stateReg[frontend_TSO_DATA_OH_ID]) : begin
        if(io_input_fire) begin
          frontend_checksumTso_push = 1'b1;
        end
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        frontend_checksumTso_push = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_SN_0_OH_ID]) : begin
        frontend_checksumTso_push = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_SN_1_OH_ID]) : begin
        frontend_checksumTso_push = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_SN_2_OH_ID]) : begin
        frontend_checksumTso_push = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_SN_3_OH_ID]) : begin
        frontend_checksumTso_push = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_FLAG_OH_ID]) : begin
        frontend_checksumTso_push = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumTso_inputLsb = frontend_counter[0];
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_TSO_SN_0_OH_ID]) : begin
        frontend_checksumTso_inputLsb = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_SN_1_OH_ID]) : begin
        frontend_checksumTso_inputLsb = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_SN_2_OH_ID]) : begin
        frontend_checksumTso_inputLsb = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_SN_3_OH_ID]) : begin
        frontend_checksumTso_inputLsb = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_FLAG_OH_ID]) : begin
        frontend_checksumTso_inputLsb = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumTso_inputData = io_input_payload_fragment_data;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_TSO_SN_0_OH_ID]) : begin
        frontend_checksumTso_inputData = _zz_buffer_write_payload_data_fragment_data_2;
      end
      (frontend_stateReg[frontend_TSO_SN_1_OH_ID]) : begin
        frontend_checksumTso_inputData = _zz_buffer_write_payload_data_fragment_data_3;
      end
      (frontend_stateReg[frontend_TSO_SN_2_OH_ID]) : begin
        frontend_checksumTso_inputData = _zz_buffer_write_payload_data_fragment_data_4;
      end
      (frontend_stateReg[frontend_TSO_SN_3_OH_ID]) : begin
        frontend_checksumTso_inputData = _zz_buffer_write_payload_data_fragment_data_5;
      end
      (frontend_stateReg[frontend_TSO_FLAG_OH_ID]) : begin
        frontend_checksumTso_inputData = _zz_buffer_write_payload_data_fragment_data_6;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumTso_input = (frontend_checksumTso_inputLsb ? {8'h0,frontend_checksumTso_inputData} : {frontend_checksumTso_inputData,8'h0});
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        frontend_checksumTso_input = {5'd0, _zz_frontend_checksumTso_input};
      end
      default : begin
      end
    endcase
  end

  assign frontend_checksumTso_sNoOverflow = ({1'b0,frontend_checksumTso_accumulator} + {1'b0,frontend_checksumTso_input});
  assign frontend_checksumTso_sOverflow = (_zz_frontend_checksumTso_sOverflow + 17'h00001);
  assign frontend_checksumTso_sMuxed = _zz_frontend_checksumTso_sMuxed[15 : 0];
  assign frontend_checksumTso_result = (~ frontend_checksumTso_accumulator);
  always @(*) begin
    frontend_checksumTso_save = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_TCP_OH_ID]) : begin
        if(io_input_fire) begin
          if(when_MacTx_l644) begin
            frontend_checksumTso_save = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumTso_restore = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
        if(when_MacTx_l668) begin
          frontend_checksumTso_restore = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumIp_clear = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_ETH_OH_ID]) : begin
        frontend_checksumIp_clear = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumIp_push = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_IPV4_OH_ID]) : begin
        if(io_input_fire) begin
          frontend_checksumIp_push = ((((frontend_counter != 16'h0002) && (frontend_counter != 16'h0003)) && (frontend_counter != 16'h000a)) && (frontend_counter != 16'h000b));
        end
      end
      (frontend_stateReg[frontend_IP4_LENGTH_0_OH_ID]) : begin
        frontend_checksumIp_push = 1'b1;
      end
      (frontend_stateReg[frontend_IP4_LENGTH_1_OH_ID]) : begin
        frontend_checksumIp_push = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]) : begin
        frontend_checksumIp_push = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        frontend_checksumIp_push = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumIp_inputLsb = frontend_counter[0];
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_IP4_LENGTH_0_OH_ID]) : begin
        frontend_checksumIp_inputLsb = 1'b0;
      end
      (frontend_stateReg[frontend_IP4_LENGTH_1_OH_ID]) : begin
        frontend_checksumIp_inputLsb = 1'b1;
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]) : begin
        frontend_checksumIp_inputLsb = 1'b0;
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        frontend_checksumIp_inputLsb = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumIp_inputData = io_input_payload_fragment_data;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_IP4_LENGTH_0_OH_ID]) : begin
        frontend_checksumIp_inputData = frontend_ip4Length[15 : 8];
      end
      (frontend_stateReg[frontend_IP4_LENGTH_1_OH_ID]) : begin
        frontend_checksumIp_inputData = frontend_ip4Length[7 : 0];
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]) : begin
        frontend_checksumIp_inputData = {5'd0, _zz_buffer_write_payload_data_fragment_data};
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        frontend_checksumIp_inputData = _zz_buffer_write_payload_data_fragment_data_1;
      end
      default : begin
      end
    endcase
  end

  assign frontend_checksumIp_input = (frontend_checksumIp_inputLsb ? {8'h0,frontend_checksumIp_inputData} : {frontend_checksumIp_inputData,8'h0});
  assign frontend_checksumIp_sNoOverflow = ({1'b0,frontend_checksumIp_accumulator} + {1'b0,frontend_checksumIp_input});
  assign frontend_checksumIp_sOverflow = (_zz_frontend_checksumIp_sOverflow + 17'h00001);
  assign frontend_checksumIp_sMuxed = _zz_frontend_checksumIp_sMuxed[15 : 0];
  assign frontend_checksumIp_result = (~ frontend_checksumIp_accumulator);
  always @(*) begin
    frontend_checksumIp_save = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_IPV4_OH_ID]) : begin
        if(io_input_fire) begin
          if(!when_MacTx_l585) begin
            if(when_MacTx_l590) begin
              frontend_checksumIp_save = 1'b1;
            end
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frontend_checksumIp_restore = 1'b0;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
        if(when_MacTx_l668) begin
          frontend_checksumIp_restore = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign frontend_tsoPacketLast = (_zz_frontend_tsoPacketLast == 11'h5ea);
  assign frontend_tsoIp4Length = (frontend_packetBytes - 11'h00e);
  assign frontend_tsoHeaderLength = (_zz_frontend_tsoHeaderLength + _zz_frontend_tsoHeaderLength_3);
  assign _zz_buffer_write_payload_data_fragment_data = (frontend_tsoIp4Length >>> 4'd8);
  assign _zz_buffer_write_payload_data_fragment_data_1 = frontend_tsoIp4Length[7 : 0];
  assign frontend_lastSegment = frontend_lastFired;
  assign frontend_fp_FIN = (frontend_tcpCtx_flags_FIN && frontend_lastSegment);
  assign frontend_fp_SYN = (frontend_tcpCtx_flags_SYN && frontend_firstSegment);
  assign frontend_fp_RST = (frontend_tcpCtx_flags_RST && frontend_firstSegment);
  assign frontend_fp_PSH = (frontend_tcpCtx_flags_PSH && frontend_lastSegment);
  assign frontend_fp_ACK = frontend_tcpCtx_flags_ACK;
  assign frontend_fp_URG = (frontend_tcpCtx_flags_URG && 1'b0);
  assign frontend_fp_ECE = (frontend_tcpCtx_flags_ECE && frontend_firstSegment);
  assign frontend_fp_CWR = (frontend_tcpCtx_flags_CWR && frontend_firstSegment);
  assign _zz_buffer_write_payload_data_fragment_data_2 = frontend_tcpCtx_sequenceNumber[31 : 24];
  assign _zz_buffer_write_payload_data_fragment_data_3 = frontend_tcpCtx_sequenceNumber[23 : 16];
  assign _zz_buffer_write_payload_data_fragment_data_4 = frontend_tcpCtx_sequenceNumber[15 : 8];
  assign _zz_buffer_write_payload_data_fragment_data_5 = frontend_tcpCtx_sequenceNumber[7 : 0];
  assign _zz_buffer_write_payload_data_fragment_data_6 = {frontend_fp_CWR,{frontend_fp_ECE,{frontend_fp_URG,{frontend_fp_ACK,{frontend_fp_PSH,{frontend_fp_RST,{frontend_fp_SYN,frontend_fp_FIN}}}}}}};
  always @(*) begin
    frontend_stateNext = frontend_stateReg;
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_INIT_OH_ID]) : begin
        frontend_stateNext = frontend_ETH;
      end
      (frontend_stateReg[frontend_ETH_OH_ID]) : begin
        if(io_input_fire) begin
          if(when_MacTx_l539) begin
            frontend_stateNext = frontend_DONE;
            if(when_MacTx_l541) begin
              frontend_stateNext = frontend_IPV4;
            end
          end
          if(io_input_payload_last) begin
            frontend_stateNext = frontend_DONE;
          end
        end
      end
      (frontend_stateReg[frontend_DONE_OH_ID]) : begin
        if(frontend_lastFired) begin
          frontend_stateNext = frontend_ETH;
        end
      end
      (frontend_stateReg[frontend_IPV4_OH_ID]) : begin
        if(io_input_fire) begin
          if(io_input_payload_last) begin
            frontend_stateNext = frontend_DONE;
          end
          if(when_MacTx_l585) begin
            if(when_MacTx_l587) begin
              frontend_stateNext = frontend_DONE;
            end
          end else begin
            if(when_MacTx_l590) begin
              frontend_stateNext = frontend_IPV4_UNKNOWN;
              if(when_MacTx_l594) begin
                case(frontend_protocol)
                  8'h06 : begin
                    frontend_stateNext = frontend_TCP;
                  end
                  8'h11 : begin
                    frontend_stateNext = frontend_UDP;
                  end
                  default : begin
                  end
                endcase
              end
            end
          end
        end
      end
      (frontend_stateReg[frontend_IPV4_UNKNOWN_OH_ID]) : begin
        if(when_MacTx_l796) begin
          frontend_stateNext = frontend_IP4_LENGTH_0;
        end
      end
      (frontend_stateReg[frontend_TCP_OH_ID]) : begin
        if(io_input_fire) begin
          if(when_MacTx_l644) begin
            frontend_stateNext = frontend_TSO_DATA;
          end
          if(io_input_payload_last) begin
            frontend_stateNext = frontend_CS_WRITE_0;
            if(when_MacTx_l651) begin
              frontend_stateNext = frontend_DONE;
            end
          end
        end
      end
      (frontend_stateReg[frontend_UDP_OH_ID]) : begin
        if(io_input_fire) begin
          if(io_input_payload_last) begin
            frontend_stateNext = frontend_IP4_LENGTH_0;
            if(when_MacTx_l773) begin
              frontend_stateNext = frontend_DONE;
            end
          end
        end
      end
//      (frontend_stateReg[frontend_ICMP_OH_ID]) : begin
//        if(io_input_fire) begin
//          if(io_input_payload_last) begin
//            frontend_stateNext = frontend_IP4_LENGTH_0;
//            if(when_MacTx_l788) begin
//              frontend_stateNext = frontend_DONE;
//            end
//          end
//        end
//      end
      (frontend_stateReg[frontend_CS_WRITE_0_OH_ID]) : begin
        frontend_stateNext = frontend_CS_WRITE_1;
      end
      (frontend_stateReg[frontend_CS_WRITE_1_OH_ID]) : begin
        frontend_stateNext = frontend_DONE;
      end
      (frontend_stateReg[frontend_IP4_LENGTH_0_OH_ID]) : begin
        frontend_stateNext = frontend_IP4_LENGTH_1;
      end
      (frontend_stateReg[frontend_IP4_LENGTH_1_OH_ID]) : begin
        frontend_stateNext = frontend_IP4_CS_0;
      end
      (frontend_stateReg[frontend_IP4_CS_0_OH_ID]) : begin
        frontend_stateNext = frontend_IP4_CS_1;
      end
      (frontend_stateReg[frontend_IP4_CS_1_OH_ID]) : begin
        frontend_stateNext = frontend_CS_WRITE_0;
        case(frontend_protocol)
          8'h06 : begin
          end
          8'h11 : begin
          end
          default : begin
            frontend_stateNext = frontend_DONE;
          end
        endcase
      end
      (frontend_stateReg[frontend_TSO_DATA_OH_ID]) : begin
        if(io_input_fire) begin
          if(when_MacTx_l682) begin
            frontend_stateNext = frontend_TSO_IP4_LENGTH_0;
          end
        end
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_IP4_LENGTH_1;
      end
      (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_IP4_CS_0;
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_0_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_IP4_CS_1;
      end
      (frontend_stateReg[frontend_TSO_IP4_CS_1_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_SN_0;
      end
      (frontend_stateReg[frontend_TSO_SN_0_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_SN_1;
      end
      (frontend_stateReg[frontend_TSO_SN_1_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_SN_2;
      end
      (frontend_stateReg[frontend_TSO_SN_2_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_SN_3;
      end
      (frontend_stateReg[frontend_TSO_SN_3_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_FLAG;
      end
      (frontend_stateReg[frontend_TSO_FLAG_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_CS_0;
      end
      (frontend_stateReg[frontend_TSO_CS_0_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_CS_1;
      end
      (frontend_stateReg[frontend_TSO_CS_1_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_SPLIT_END;
      end
      (frontend_stateReg[frontend_TSO_SPLIT_END_OH_ID]) : begin
        frontend_stateNext = frontend_TSO_HEADER_CPY;
        if(frontend_lastFired) begin
          frontend_stateNext = frontend_ETH;
        end
      end
      (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
        if(when_MacTx_l668) begin
          frontend_stateNext = frontend_TSO_DATA;
        end
      end
      default : begin
      end
    endcase
    if(frontend_wantStart) begin
      frontend_stateNext = frontend_INIT;
    end
    if(frontend_wantKill) begin
      frontend_stateNext = frontend_BOOT;
    end
  end

  assign when_MacTx_l539 = (frontend_counter == 16'h000d);
  assign when_MacTx_l541 = ((frontend_history_0 == 8'h0) && (frontend_history_1 == 8'h08));
  assign when_MacTx_l566 = (frontend_counter == 16'h0003);
  assign when_MacTx_l573 = (frontend_counter == 16'h0009);
  assign when_MacTx_l578 = (frontend_counter == 16'h0003);
  assign when_MacTx_l585 = (frontend_counter == 16'h0);
  assign when_MacTx_l587 = ((io_input_payload_fragment_data[7 : 4] != 4'b0100) || (io_input_payload_fragment_data[3 : 0] < 4'b0101));
  assign when_MacTx_l594 = (! io_input_payload_last);
  assign when_MacTx_l590 = (frontend_counter == _zz_when_MacTx_l590);
  assign when_MacTx_l796 = ((io_input_fire && io_input_payload_last) || frontend_lastFired);
  assign when_MacTx_l625 = (frontend_counter == 16'h0007);
  assign when_MacTx_l625_1 = (frontend_counter == 16'h0006);
  assign when_MacTx_l625_2 = (frontend_counter == 16'h0005);
  assign when_MacTx_l625_3 = (frontend_counter == 16'h0004);
  assign when_MacTx_l625_4 = (frontend_counter == 16'h000d);
  assign _zz_frontend_tcpCtx_flags_FIN = io_input_payload_fragment_data;
  assign when_MacTx_l625_5 = (frontend_counter == 16'h0013);
  assign when_MacTx_l625_6 = (frontend_counter == 16'h0012);
  assign when_MacTx_l635 = (frontend_counter == 16'h000c);
  assign when_MacTx_l636 = (frontend_counter == 16'h0004);
  assign when_MacTx_l641 = (frontend_counter == 16'h0010);
  assign when_MacTx_l644 = (frontend_counter == _zz_when_MacTx_l644);
  assign when_MacTx_l651 = (frontend_counter < 16'h0012);
  assign when_MacTx_l768 = (frontend_counter == 16'h0006);
  assign when_MacTx_l773 = (frontend_counter < 16'h0008);
  assign when_MacTx_l783 = (frontend_counter == 16'h0002);
  assign when_MacTx_l788 = (frontend_counter < 16'h0004);
  assign when_MacTx_l682 = (frontend_tsoPacketLast || io_input_payload_last);
  assign when_MacTx_l668 = (! header_readBusy);
  assign frontend_onExit_BOOT = ((! frontend_stateNext[frontend_BOOT_OH_ID]) && (frontend_stateReg[frontend_BOOT_OH_ID]));
  assign frontend_onExit_INIT = ((! frontend_stateNext[frontend_INIT_OH_ID]) && (frontend_stateReg[frontend_INIT_OH_ID]));
  assign frontend_onExit_ETH = ((! frontend_stateNext[frontend_ETH_OH_ID]) && (frontend_stateReg[frontend_ETH_OH_ID]));
  assign frontend_onExit_DONE = ((! frontend_stateNext[frontend_DONE_OH_ID]) && (frontend_stateReg[frontend_DONE_OH_ID]));
  assign frontend_onExit_IPV4 = ((! frontend_stateNext[frontend_IPV4_OH_ID]) && (frontend_stateReg[frontend_IPV4_OH_ID]));
  assign frontend_onExit_IPV4_UNKNOWN = ((! frontend_stateNext[frontend_IPV4_UNKNOWN_OH_ID]) && (frontend_stateReg[frontend_IPV4_UNKNOWN_OH_ID]));
  assign frontend_onExit_TCP = ((! frontend_stateNext[frontend_TCP_OH_ID]) && (frontend_stateReg[frontend_TCP_OH_ID]));
  assign frontend_onExit_UDP = ((! frontend_stateNext[frontend_UDP_OH_ID]) && (frontend_stateReg[frontend_UDP_OH_ID]));
  //assign frontend_onExit_ICMP = ((! frontend_stateNext[frontend_ICMP_OH_ID]) && (frontend_stateReg[frontend_ICMP_OH_ID]));
  assign frontend_onExit_CS_WRITE_0 = ((! frontend_stateNext[frontend_CS_WRITE_0_OH_ID]) && (frontend_stateReg[frontend_CS_WRITE_0_OH_ID]));
  assign frontend_onExit_CS_WRITE_1 = ((! frontend_stateNext[frontend_CS_WRITE_1_OH_ID]) && (frontend_stateReg[frontend_CS_WRITE_1_OH_ID]));
  assign frontend_onExit_IP4_LENGTH_0 = ((! frontend_stateNext[frontend_IP4_LENGTH_0_OH_ID]) && (frontend_stateReg[frontend_IP4_LENGTH_0_OH_ID]));
  assign frontend_onExit_IP4_LENGTH_1 = ((! frontend_stateNext[frontend_IP4_LENGTH_1_OH_ID]) && (frontend_stateReg[frontend_IP4_LENGTH_1_OH_ID]));
  assign frontend_onExit_IP4_CS_0 = ((! frontend_stateNext[frontend_IP4_CS_0_OH_ID]) && (frontend_stateReg[frontend_IP4_CS_0_OH_ID]));
  assign frontend_onExit_IP4_CS_1 = ((! frontend_stateNext[frontend_IP4_CS_1_OH_ID]) && (frontend_stateReg[frontend_IP4_CS_1_OH_ID]));
  assign frontend_onExit_TSO_DATA = ((! frontend_stateNext[frontend_TSO_DATA_OH_ID]) && (frontend_stateReg[frontend_TSO_DATA_OH_ID]));
  assign frontend_onExit_TSO_IP4_LENGTH_0 = ((! frontend_stateNext[frontend_TSO_IP4_LENGTH_0_OH_ID]) && (frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]));
  assign frontend_onExit_TSO_IP4_LENGTH_1 = ((! frontend_stateNext[frontend_TSO_IP4_LENGTH_1_OH_ID]) && (frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]));
  assign frontend_onExit_TSO_IP4_CS_0 = ((! frontend_stateNext[frontend_TSO_IP4_CS_0_OH_ID]) && (frontend_stateReg[frontend_TSO_IP4_CS_0_OH_ID]));
  assign frontend_onExit_TSO_IP4_CS_1 = ((! frontend_stateNext[frontend_TSO_IP4_CS_1_OH_ID]) && (frontend_stateReg[frontend_TSO_IP4_CS_1_OH_ID]));
  assign frontend_onExit_TSO_SN_0 = ((! frontend_stateNext[frontend_TSO_SN_0_OH_ID]) && (frontend_stateReg[frontend_TSO_SN_0_OH_ID]));
  assign frontend_onExit_TSO_SN_1 = ((! frontend_stateNext[frontend_TSO_SN_1_OH_ID]) && (frontend_stateReg[frontend_TSO_SN_1_OH_ID]));
  assign frontend_onExit_TSO_SN_2 = ((! frontend_stateNext[frontend_TSO_SN_2_OH_ID]) && (frontend_stateReg[frontend_TSO_SN_2_OH_ID]));
  assign frontend_onExit_TSO_SN_3 = ((! frontend_stateNext[frontend_TSO_SN_3_OH_ID]) && (frontend_stateReg[frontend_TSO_SN_3_OH_ID]));
  assign frontend_onExit_TSO_FLAG = ((! frontend_stateNext[frontend_TSO_FLAG_OH_ID]) && (frontend_stateReg[frontend_TSO_FLAG_OH_ID]));
  assign frontend_onExit_TSO_CS_0 = ((! frontend_stateNext[frontend_TSO_CS_0_OH_ID]) && (frontend_stateReg[frontend_TSO_CS_0_OH_ID]));
  assign frontend_onExit_TSO_CS_1 = ((! frontend_stateNext[frontend_TSO_CS_1_OH_ID]) && (frontend_stateReg[frontend_TSO_CS_1_OH_ID]));
  assign frontend_onExit_TSO_SPLIT_END = ((! frontend_stateNext[frontend_TSO_SPLIT_END_OH_ID]) && (frontend_stateReg[frontend_TSO_SPLIT_END_OH_ID]));
  assign frontend_onExit_TSO_HEADER_CPY = ((! frontend_stateNext[frontend_TSO_HEADER_CPY_OH_ID]) && (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]));
  assign frontend_onEntry_BOOT = ((frontend_stateNext[frontend_BOOT_OH_ID]) && (! frontend_stateReg[frontend_BOOT_OH_ID]));
  assign frontend_onEntry_INIT = ((frontend_stateNext[frontend_INIT_OH_ID]) && (! frontend_stateReg[frontend_INIT_OH_ID]));
  assign frontend_onEntry_ETH = ((frontend_stateNext[frontend_ETH_OH_ID]) && (! frontend_stateReg[frontend_ETH_OH_ID]));
  assign frontend_onEntry_DONE = ((frontend_stateNext[frontend_DONE_OH_ID]) && (! frontend_stateReg[frontend_DONE_OH_ID]));
  assign frontend_onEntry_IPV4 = ((frontend_stateNext[frontend_IPV4_OH_ID]) && (! frontend_stateReg[frontend_IPV4_OH_ID]));
  assign frontend_onEntry_IPV4_UNKNOWN = ((frontend_stateNext[frontend_IPV4_UNKNOWN_OH_ID]) && (! frontend_stateReg[frontend_IPV4_UNKNOWN_OH_ID]));
  assign frontend_onEntry_TCP = ((frontend_stateNext[frontend_TCP_OH_ID]) && (! frontend_stateReg[frontend_TCP_OH_ID]));
  assign frontend_onEntry_UDP = ((frontend_stateNext[frontend_UDP_OH_ID]) && (! frontend_stateReg[frontend_UDP_OH_ID]));
  //assign frontend_onEntry_ICMP = ((frontend_stateNext[frontend_ICMP_OH_ID]) && (! frontend_stateReg[frontend_ICMP_OH_ID]));
  assign frontend_onEntry_CS_WRITE_0 = ((frontend_stateNext[frontend_CS_WRITE_0_OH_ID]) && (! frontend_stateReg[frontend_CS_WRITE_0_OH_ID]));
  assign frontend_onEntry_CS_WRITE_1 = ((frontend_stateNext[frontend_CS_WRITE_1_OH_ID]) && (! frontend_stateReg[frontend_CS_WRITE_1_OH_ID]));
  assign frontend_onEntry_IP4_LENGTH_0 = ((frontend_stateNext[frontend_IP4_LENGTH_0_OH_ID]) && (! frontend_stateReg[frontend_IP4_LENGTH_0_OH_ID]));
  assign frontend_onEntry_IP4_LENGTH_1 = ((frontend_stateNext[frontend_IP4_LENGTH_1_OH_ID]) && (! frontend_stateReg[frontend_IP4_LENGTH_1_OH_ID]));
  assign frontend_onEntry_IP4_CS_0 = ((frontend_stateNext[frontend_IP4_CS_0_OH_ID]) && (! frontend_stateReg[frontend_IP4_CS_0_OH_ID]));
  assign frontend_onEntry_IP4_CS_1 = ((frontend_stateNext[frontend_IP4_CS_1_OH_ID]) && (! frontend_stateReg[frontend_IP4_CS_1_OH_ID]));
  assign frontend_onEntry_TSO_DATA = ((frontend_stateNext[frontend_TSO_DATA_OH_ID]) && (! frontend_stateReg[frontend_TSO_DATA_OH_ID]));
  assign frontend_onEntry_TSO_IP4_LENGTH_0 = ((frontend_stateNext[frontend_TSO_IP4_LENGTH_0_OH_ID]) && (! frontend_stateReg[frontend_TSO_IP4_LENGTH_0_OH_ID]));
  assign frontend_onEntry_TSO_IP4_LENGTH_1 = ((frontend_stateNext[frontend_TSO_IP4_LENGTH_1_OH_ID]) && (! frontend_stateReg[frontend_TSO_IP4_LENGTH_1_OH_ID]));
  assign frontend_onEntry_TSO_IP4_CS_0 = ((frontend_stateNext[frontend_TSO_IP4_CS_0_OH_ID]) && (! frontend_stateReg[frontend_TSO_IP4_CS_0_OH_ID]));
  assign frontend_onEntry_TSO_IP4_CS_1 = ((frontend_stateNext[frontend_TSO_IP4_CS_1_OH_ID]) && (! frontend_stateReg[frontend_TSO_IP4_CS_1_OH_ID]));
  assign frontend_onEntry_TSO_SN_0 = ((frontend_stateNext[frontend_TSO_SN_0_OH_ID]) && (! frontend_stateReg[frontend_TSO_SN_0_OH_ID]));
  assign frontend_onEntry_TSO_SN_1 = ((frontend_stateNext[frontend_TSO_SN_1_OH_ID]) && (! frontend_stateReg[frontend_TSO_SN_1_OH_ID]));
  assign frontend_onEntry_TSO_SN_2 = ((frontend_stateNext[frontend_TSO_SN_2_OH_ID]) && (! frontend_stateReg[frontend_TSO_SN_2_OH_ID]));
  assign frontend_onEntry_TSO_SN_3 = ((frontend_stateNext[frontend_TSO_SN_3_OH_ID]) && (! frontend_stateReg[frontend_TSO_SN_3_OH_ID]));
  assign frontend_onEntry_TSO_FLAG = ((frontend_stateNext[frontend_TSO_FLAG_OH_ID]) && (! frontend_stateReg[frontend_TSO_FLAG_OH_ID]));
  assign frontend_onEntry_TSO_CS_0 = ((frontend_stateNext[frontend_TSO_CS_0_OH_ID]) && (! frontend_stateReg[frontend_TSO_CS_0_OH_ID]));
  assign frontend_onEntry_TSO_CS_1 = ((frontend_stateNext[frontend_TSO_CS_1_OH_ID]) && (! frontend_stateReg[frontend_TSO_CS_1_OH_ID]));
  assign frontend_onEntry_TSO_SPLIT_END = ((frontend_stateNext[frontend_TSO_SPLIT_END_OH_ID]) && (! frontend_stateReg[frontend_TSO_SPLIT_END_OH_ID]));
  assign frontend_onEntry_TSO_HEADER_CPY = ((frontend_stateNext[frontend_TSO_HEADER_CPY_OH_ID]) && (! frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      buffer_pushAt <= 12'h0;
      buffer_popAt <= 12'h0;
      _zz_buffer_readRsp_valid <= 1'b0;
      buffer_packets_value <= 4'b0000;
      buffer_full <= 1'b0;
      _zz_header_readRsp_valid <= 1'b0;
      header_readBusy <= 1'b0;
      buffer_readRsp_haltWhen_rValid <= 1'b0;
      frontend_lastFired <= 1'b0;
      frontend_halted <= 1'b0;
      frontend_stateReg <= frontend_BOOT;
    end else begin
      if(buffer_readRsp_ready) begin
        _zz_buffer_readRsp_valid <= 1'b0;
      end
      if(buffer_readCmd_ready) begin
        _zz_buffer_readRsp_valid <= buffer_readCmd_valid;
      end
      buffer_packets_value <= buffer_packets_valueNext;
      buffer_full <= ((12'h7ff <= _zz_buffer_full) || (4'b1110 <= buffer_packets_value));
      if(buffer_push) begin
        buffer_pushAt <= (buffer_pushAt + 12'h001);
      end
      if(header_readRsp_ready) begin
        _zz_header_readRsp_valid <= 1'b0;
      end
      if(header_readCmd_ready) begin
        _zz_header_readRsp_valid <= header_readCmd_valid;
      end
      if(!when_MacTx_l430) begin
        if(header_readEnd) begin
          header_readBusy <= 1'b0;
        end
      end
      if(buffer_readCmd_fire) begin
        buffer_popAt <= (buffer_popAt + 12'h001);
      end
      if(buffer_readRsp_haltWhen_ready) begin
        buffer_readRsp_haltWhen_rValid <= buffer_readRsp_haltWhen_valid;
      end
      if(when_MacTx_l471) begin
        frontend_lastFired <= 1'b1;
      end
      frontend_stateReg <= frontend_stateNext;
      (* parallel_case *)
      case(1) // synthesis parallel_case
        (frontend_stateReg[frontend_INIT_OH_ID]) : begin
          frontend_lastFired <= 1'b0;
          frontend_halted <= 1'b0;
        end
        (frontend_stateReg[frontend_DONE_OH_ID]) : begin
          if(frontend_lastFired) begin
            frontend_lastFired <= 1'b0;
            frontend_halted <= 1'b0;
          end
        end
        (frontend_stateReg[frontend_TSO_DATA_OH_ID]) : begin
          if(io_input_fire) begin
            if(when_MacTx_l682) begin
              frontend_halted <= 1'b1;
            end
          end
        end
        (frontend_stateReg[frontend_TSO_SPLIT_END_OH_ID]) : begin
          header_readBusy <= 1'b1;
          if(frontend_lastFired) begin
            frontend_lastFired <= 1'b0;
            frontend_halted <= 1'b0;
          end
        end
        (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
          if(when_MacTx_l668) begin
            frontend_halted <= 1'b0;
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    if(when_MacTx_l418) begin
      header_writePtr <= (header_writePtr + 8'h01);
    end
    if(when_MacTx_l430) begin
      header_readPtr <= 8'h0;
    end else begin
      if(!header_readEnd) begin
        header_readPtr <= (header_readPtr + 8'h01);
      end
    end
    if(header_clear) begin
      header_capture <= 1'b1;
      header_writePtr <= 8'h0;
    end
    if(buffer_readRsp_haltWhen_ready) begin
      buffer_readRsp_haltWhen_rData_last <= buffer_readRsp_haltWhen_payload_last;
      buffer_readRsp_haltWhen_rData_fragment_data <= buffer_readRsp_haltWhen_payload_fragment_data;
    end
    if(io_input_fire) begin
      _zz_frontend_history_1 <= _zz_frontend_history_0;
    end
    if(io_input_fire) begin
      frontend_counter <= (frontend_counter + 16'h0001);
    end
    if(io_input_fire) begin
      frontend_packetBytes <= (frontend_packetBytes + 11'h001);
    end
    if(frontend_checksum_push) begin
      frontend_checksum_accumulator <= frontend_checksum_sMuxed;
    end
    if(frontend_checksum_clear) begin
      frontend_checksum_accumulator <= 16'h0;
    end
    if(frontend_checksumTso_push) begin
      frontend_checksumTso_accumulator <= frontend_checksumTso_sMuxed;
    end
    if(frontend_checksumTso_clear) begin
      frontend_checksumTso_accumulator <= 16'h0;
    end
    if(frontend_checksumTso_save) begin
      frontend_checksumTso_checkpoint <= frontend_checksumTso_sMuxed;
    end
    if(frontend_checksumTso_restore) begin
      frontend_checksumTso_accumulator <= frontend_checksumTso_checkpoint;
    end
    if(frontend_checksumIp_push) begin
      frontend_checksumIp_accumulator <= frontend_checksumIp_sMuxed;
    end
    if(frontend_checksumIp_clear) begin
      frontend_checksumIp_accumulator <= 16'h0;
    end
    if(frontend_checksumIp_save) begin
      frontend_checksumIp_checkpoint <= frontend_checksumIp_sMuxed;
    end
    if(frontend_checksumIp_restore) begin
      frontend_checksumIp_accumulator <= frontend_checksumIp_checkpoint;
    end
    frontend_tcpAt <= (_zz_frontend_tcpAt + _zz_frontend_tcpAt_1);
    (* parallel_case *)
    case(1) // synthesis parallel_case
      (frontend_stateReg[frontend_INIT_OH_ID]) : begin
        frontend_counter <= 16'h0;
        frontend_packetBytes <= 11'h0;
        buffer_packetAt <= buffer_pushAt;
        frontend_firstSegment <= 1'b1;
      end
      (frontend_stateReg[frontend_ETH_OH_ID]) : begin
        if(io_input_fire) begin
          if(when_MacTx_l539) begin
            if(when_MacTx_l541) begin
              frontend_counter <= 16'h0;
            end
          end
        end
      end
      (frontend_stateReg[frontend_DONE_OH_ID]) : begin
        if(frontend_lastFired) begin
          frontend_counter <= 16'h0;
          frontend_packetBytes <= 11'h0;
          buffer_packetAt <= buffer_pushAt;
          frontend_firstSegment <= 1'b1;
        end
      end
      (frontend_stateReg[frontend_IPV4_OH_ID]) : begin
        if(io_input_fire) begin
          if(when_MacTx_l573) begin
            frontend_protocol <= io_input_payload_fragment_data;
          end
          if(when_MacTx_l578) begin
            frontend_ip4Length <= {frontend_history_1,frontend_history_0};
          end
          if(when_MacTx_l585) begin
            frontend_IHL <= io_input_payload_fragment_data[3 : 0];
          end else begin
            if(when_MacTx_l590) begin
              frontend_counter <= 16'h0;
            end
          end
        end
      end
      (frontend_stateReg[frontend_TCP_OH_ID]) : begin
        if(io_input_fire) begin
          if(when_MacTx_l625) begin
            frontend_tcpCtx_sequenceNumber[7 : 0] <= io_input_payload_fragment_data;
          end
          if(when_MacTx_l625_1) begin
            frontend_tcpCtx_sequenceNumber[15 : 8] <= io_input_payload_fragment_data;
          end
          if(when_MacTx_l625_2) begin
            frontend_tcpCtx_sequenceNumber[23 : 16] <= io_input_payload_fragment_data;
          end
          if(when_MacTx_l625_3) begin
            frontend_tcpCtx_sequenceNumber[31 : 24] <= io_input_payload_fragment_data;
          end
          if(when_MacTx_l625_4) begin
            frontend_tcpCtx_flags_FIN <= _zz_frontend_tcpCtx_flags_FIN[0];
            frontend_tcpCtx_flags_SYN <= _zz_frontend_tcpCtx_flags_FIN[1];
            frontend_tcpCtx_flags_RST <= _zz_frontend_tcpCtx_flags_FIN[2];
            frontend_tcpCtx_flags_PSH <= _zz_frontend_tcpCtx_flags_FIN[3];
            frontend_tcpCtx_flags_ACK <= _zz_frontend_tcpCtx_flags_FIN[4];
            frontend_tcpCtx_flags_URG <= _zz_frontend_tcpCtx_flags_FIN[5];
            frontend_tcpCtx_flags_ECE <= _zz_frontend_tcpCtx_flags_FIN[6];
            frontend_tcpCtx_flags_CWR <= _zz_frontend_tcpCtx_flags_FIN[7];
          end
          if(when_MacTx_l625_5) begin
            frontend_tcpCtx_urgentPointer[7 : 0] <= io_input_payload_fragment_data;
          end
          if(when_MacTx_l625_6) begin
            frontend_tcpCtx_urgentPointer[15 : 8] <= io_input_payload_fragment_data;
          end
          if(when_MacTx_l635) begin
            frontend_tcpCtx_dataOffset <= io_input_payload_fragment_data[7 : 4];
          end
          if(when_MacTx_l636) begin
            frontend_csAt <= buffer_pushAt[10:0];
          end
          if(when_MacTx_l641) begin
            frontend_csAt <= buffer_pushAt[10:0];
          end
          if(when_MacTx_l644) begin
            header_capture <= 1'b0;
          end
        end
      end
      (frontend_stateReg[frontend_UDP_OH_ID]) : begin
        if(io_input_fire) begin
          if(when_MacTx_l768) begin
            frontend_csAt <= buffer_pushAt[10:0];
          end
        end
      end
//      (frontend_stateReg[frontend_ICMP_OH_ID]) : begin
//        if(io_input_fire) begin
//          if(when_MacTx_l783) begin
//            frontend_csAt <= buffer_pushAt[10:0];
//          end
//        end
//      end
      (frontend_stateReg[frontend_TSO_SPLIT_END_OH_ID]) : begin
        buffer_packetAt <= buffer_pushAt;
        frontend_packetBytes <= {3'd0, frontend_tsoHeaderLength};
        frontend_tcpCtx_sequenceNumber <= (frontend_tcpCtx_sequenceNumber + _zz_frontend_tcpCtx_sequenceNumber);
        if(frontend_lastFired) begin
          frontend_counter <= 16'h0;
          frontend_packetBytes <= 11'h0;
          buffer_packetAt <= buffer_pushAt;
          frontend_firstSegment <= 1'b1;
        end
      end
      (frontend_stateReg[frontend_TSO_HEADER_CPY_OH_ID]) : begin
        frontend_firstSegment <= 1'b0;
      end
      default : begin
      end
    endcase
  end


endmodule
