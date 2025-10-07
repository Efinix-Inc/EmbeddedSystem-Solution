////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   
//       / / .'     /    
//    __/ /.'      /     
//   __   \       /      
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***********************************************************************
// Generator : SpinalHDL dev    git head : 9cdee03b276638ef8e7a948b606bb7acc6e4c8d0
// Component : Asic32To128UpsizerAxi4Upsizer
// Git hash  : cd16421fb7a4d44431a2445f9a92b82070ab9b8a

`timescale 1ns/1ps

module Asic32To128UpsizerAxi4Upsizer (
  input               io_input_aw_valid,
  output              io_input_aw_ready,
  input      [31:0]   io_input_aw_payload_addr,
  input      [7:0]    io_input_aw_payload_id,
  input      [3:0]    io_input_aw_payload_region,
  input      [7:0]    io_input_aw_payload_len,
  input      [2:0]    io_input_aw_payload_size,
  input      [1:0]    io_input_aw_payload_burst,
  input      [0:0]    io_input_aw_payload_lock,
  input      [3:0]    io_input_aw_payload_cache,
  input      [3:0]    io_input_aw_payload_qos,
  input      [2:0]    io_input_aw_payload_prot,
  input               io_input_w_valid,
  output              io_input_w_ready,
  input      [31:0]   io_input_w_payload_data,
  input      [3:0]    io_input_w_payload_strb,
  input               io_input_w_payload_last,
  output              io_input_b_valid,
  input               io_input_b_ready,
  output     [7:0]    io_input_b_payload_id,
  output     [1:0]    io_input_b_payload_resp,
  input               io_input_ar_valid,
  output              io_input_ar_ready,
  input      [31:0]   io_input_ar_payload_addr,
  input      [7:0]    io_input_ar_payload_id,
  input      [3:0]    io_input_ar_payload_region,
  input      [7:0]    io_input_ar_payload_len,
  input      [2:0]    io_input_ar_payload_size,
  input      [1:0]    io_input_ar_payload_burst,
  input      [0:0]    io_input_ar_payload_lock,
  input      [3:0]    io_input_ar_payload_cache,
  input      [3:0]    io_input_ar_payload_qos,
  input      [2:0]    io_input_ar_payload_prot,
  output              io_input_r_valid,
  input               io_input_r_ready,
  output     [31:0]   io_input_r_payload_data,
  output     [7:0]    io_input_r_payload_id,
  output     [1:0]    io_input_r_payload_resp,
  output              io_input_r_payload_last,
  output              io_output_aw_valid,
  input               io_output_aw_ready,
  output     [31:0]   io_output_aw_payload_addr,
  output     [7:0]    io_output_aw_payload_id,
  output     [3:0]    io_output_aw_payload_region,
  output     [7:0]    io_output_aw_payload_len,
  output     [2:0]    io_output_aw_payload_size,
  output     [1:0]    io_output_aw_payload_burst,
  output     [0:0]    io_output_aw_payload_lock,
  output     [3:0]    io_output_aw_payload_cache,
  output     [3:0]    io_output_aw_payload_qos,
  output     [2:0]    io_output_aw_payload_prot,
  output              io_output_w_valid,
  input               io_output_w_ready,
  output     [127:0]  io_output_w_payload_data,
  output     [15:0]   io_output_w_payload_strb,
  output              io_output_w_payload_last,
  input               io_output_b_valid,
  output              io_output_b_ready,
  input      [7:0]    io_output_b_payload_id,
  input      [1:0]    io_output_b_payload_resp,
  output              io_output_ar_valid,
  input               io_output_ar_ready,
  output     [31:0]   io_output_ar_payload_addr,
  output     [7:0]    io_output_ar_payload_id,
  output     [3:0]    io_output_ar_payload_region,
  output     [7:0]    io_output_ar_payload_len,
  output     [2:0]    io_output_ar_payload_size,
  output     [1:0]    io_output_ar_payload_burst,
  output     [0:0]    io_output_ar_payload_lock,
  output     [3:0]    io_output_ar_payload_cache,
  output     [3:0]    io_output_ar_payload_qos,
  output     [2:0]    io_output_ar_payload_prot,
  input               io_output_r_valid,
  output              io_output_r_ready,
  input      [127:0]  io_output_r_payload_data,
  input      [7:0]    io_output_r_payload_id,
  input      [1:0]    io_output_r_payload_resp,
  input               io_output_r_payload_last,
  input               clk,
  input               reset
);

  wire                readOnly_io_input_ar_ready;
  wire                readOnly_io_input_r_valid;
  wire       [31:0]   readOnly_io_input_r_payload_data;
  wire       [7:0]    readOnly_io_input_r_payload_id;
  wire       [1:0]    readOnly_io_input_r_payload_resp;
  wire                readOnly_io_input_r_payload_last;
  wire                readOnly_io_output_ar_valid;
  wire       [31:0]   readOnly_io_output_ar_payload_addr;
  wire       [7:0]    readOnly_io_output_ar_payload_id;
  wire       [3:0]    readOnly_io_output_ar_payload_region;
  wire       [7:0]    readOnly_io_output_ar_payload_len;
  wire       [2:0]    readOnly_io_output_ar_payload_size;
  wire       [1:0]    readOnly_io_output_ar_payload_burst;
  wire       [0:0]    readOnly_io_output_ar_payload_lock;
  wire       [3:0]    readOnly_io_output_ar_payload_cache;
  wire       [3:0]    readOnly_io_output_ar_payload_qos;
  wire       [2:0]    readOnly_io_output_ar_payload_prot;
  wire                readOnly_io_output_r_ready;
  wire                writeOnly_io_input_aw_ready;
  wire                writeOnly_io_input_w_ready;
  wire                writeOnly_io_input_b_valid;
  wire       [7:0]    writeOnly_io_input_b_payload_id;
  wire       [1:0]    writeOnly_io_input_b_payload_resp;
  wire                writeOnly_io_output_aw_valid;
  wire       [31:0]   writeOnly_io_output_aw_payload_addr;
  wire       [7:0]    writeOnly_io_output_aw_payload_id;
  wire       [3:0]    writeOnly_io_output_aw_payload_region;
  wire       [7:0]    writeOnly_io_output_aw_payload_len;
  wire       [2:0]    writeOnly_io_output_aw_payload_size;
  wire       [1:0]    writeOnly_io_output_aw_payload_burst;
  wire       [0:0]    writeOnly_io_output_aw_payload_lock;
  wire       [3:0]    writeOnly_io_output_aw_payload_cache;
  wire       [3:0]    writeOnly_io_output_aw_payload_qos;
  wire       [2:0]    writeOnly_io_output_aw_payload_prot;
  wire                writeOnly_io_output_w_valid;
  wire       [127:0]  writeOnly_io_output_w_payload_data;
  wire       [15:0]   writeOnly_io_output_w_payload_strb;
  wire                writeOnly_io_output_w_payload_last;
  wire                writeOnly_io_output_b_ready;

//Encryption begin
  Asic32To128UpsizerAxi4ReadOnlyUpsizer readOnly (
    .io_input_ar_valid           (io_input_ar_valid                        ), //i
    .io_input_ar_ready           (readOnly_io_input_ar_ready               ), //o
    .io_input_ar_payload_addr    (io_input_ar_payload_addr[31:0]           ), //i
    .io_input_ar_payload_id      (io_input_ar_payload_id[7:0]              ), //i
    .io_input_ar_payload_region  (io_input_ar_payload_region[3:0]          ), //i
    .io_input_ar_payload_len     (io_input_ar_payload_len[7:0]             ), //i
    .io_input_ar_payload_size    (io_input_ar_payload_size[2:0]            ), //i
    .io_input_ar_payload_burst   (io_input_ar_payload_burst[1:0]           ), //i
    .io_input_ar_payload_lock    (io_input_ar_payload_lock                 ), //i
    .io_input_ar_payload_cache   (io_input_ar_payload_cache[3:0]           ), //i
    .io_input_ar_payload_qos     (io_input_ar_payload_qos[3:0]             ), //i
    .io_input_ar_payload_prot    (io_input_ar_payload_prot[2:0]            ), //i
    .io_input_r_valid            (readOnly_io_input_r_valid                ), //o
    .io_input_r_ready            (io_input_r_ready                         ), //i
    .io_input_r_payload_data     (readOnly_io_input_r_payload_data[31:0]   ), //o
    .io_input_r_payload_id       (readOnly_io_input_r_payload_id[7:0]      ), //o
    .io_input_r_payload_resp     (readOnly_io_input_r_payload_resp[1:0]    ), //o
    .io_input_r_payload_last     (readOnly_io_input_r_payload_last         ), //o
    .io_output_ar_valid          (readOnly_io_output_ar_valid              ), //o
    .io_output_ar_ready          (io_output_ar_ready                       ), //i
    .io_output_ar_payload_addr   (readOnly_io_output_ar_payload_addr[31:0] ), //o
    .io_output_ar_payload_id     (readOnly_io_output_ar_payload_id[7:0]    ), //o
    .io_output_ar_payload_region (readOnly_io_output_ar_payload_region[3:0]), //o
    .io_output_ar_payload_len    (readOnly_io_output_ar_payload_len[7:0]   ), //o
    .io_output_ar_payload_size   (readOnly_io_output_ar_payload_size[2:0]  ), //o
    .io_output_ar_payload_burst  (readOnly_io_output_ar_payload_burst[1:0] ), //o
    .io_output_ar_payload_lock   (readOnly_io_output_ar_payload_lock       ), //o
    .io_output_ar_payload_cache  (readOnly_io_output_ar_payload_cache[3:0] ), //o
    .io_output_ar_payload_qos    (readOnly_io_output_ar_payload_qos[3:0]   ), //o
    .io_output_ar_payload_prot   (readOnly_io_output_ar_payload_prot[2:0]  ), //o
    .io_output_r_valid           (io_output_r_valid                        ), //i
    .io_output_r_ready           (readOnly_io_output_r_ready               ), //o
    .io_output_r_payload_data    (io_output_r_payload_data[127:0]          ), //i
    .io_output_r_payload_id      (io_output_r_payload_id[7:0]              ), //i
    .io_output_r_payload_resp    (io_output_r_payload_resp[1:0]            ), //i
    .io_output_r_payload_last    (io_output_r_payload_last                 ), //i
    .clk                         (clk                                      ), //i
    .reset                       (reset                                    )  //i
  );
  Asic32To128UpsizerAxi4WriteOnlyUpsizer writeOnly (
    .io_input_aw_valid           (io_input_aw_valid                         ), //i
    .io_input_aw_ready           (writeOnly_io_input_aw_ready               ), //o
    .io_input_aw_payload_addr    (io_input_aw_payload_addr[31:0]            ), //i
    .io_input_aw_payload_id      (io_input_aw_payload_id[7:0]               ), //i
    .io_input_aw_payload_region  (io_input_aw_payload_region[3:0]           ), //i
    .io_input_aw_payload_len     (io_input_aw_payload_len[7:0]              ), //i
    .io_input_aw_payload_size    (io_input_aw_payload_size[2:0]             ), //i
    .io_input_aw_payload_burst   (io_input_aw_payload_burst[1:0]            ), //i
    .io_input_aw_payload_lock    (io_input_aw_payload_lock                  ), //i
    .io_input_aw_payload_cache   (io_input_aw_payload_cache[3:0]            ), //i
    .io_input_aw_payload_qos     (io_input_aw_payload_qos[3:0]              ), //i
    .io_input_aw_payload_prot    (io_input_aw_payload_prot[2:0]             ), //i
    .io_input_w_valid            (io_input_w_valid                          ), //i
    .io_input_w_ready            (writeOnly_io_input_w_ready                ), //o
    .io_input_w_payload_data     (io_input_w_payload_data[31:0]             ), //i
    .io_input_w_payload_strb     (io_input_w_payload_strb[3:0]              ), //i
    .io_input_w_payload_last     (io_input_w_payload_last                   ), //i
    .io_input_b_valid            (writeOnly_io_input_b_valid                ), //o
    .io_input_b_ready            (io_input_b_ready                          ), //i
    .io_input_b_payload_id       (writeOnly_io_input_b_payload_id[7:0]      ), //o
    .io_input_b_payload_resp     (writeOnly_io_input_b_payload_resp[1:0]    ), //o
    .io_output_aw_valid          (writeOnly_io_output_aw_valid              ), //o
    .io_output_aw_ready          (io_output_aw_ready                        ), //i
    .io_output_aw_payload_addr   (writeOnly_io_output_aw_payload_addr[31:0] ), //o
    .io_output_aw_payload_id     (writeOnly_io_output_aw_payload_id[7:0]    ), //o
    .io_output_aw_payload_region (writeOnly_io_output_aw_payload_region[3:0]), //o
    .io_output_aw_payload_len    (writeOnly_io_output_aw_payload_len[7:0]   ), //o
    .io_output_aw_payload_size   (writeOnly_io_output_aw_payload_size[2:0]  ), //o
    .io_output_aw_payload_burst  (writeOnly_io_output_aw_payload_burst[1:0] ), //o
    .io_output_aw_payload_lock   (writeOnly_io_output_aw_payload_lock       ), //o
    .io_output_aw_payload_cache  (writeOnly_io_output_aw_payload_cache[3:0] ), //o
    .io_output_aw_payload_qos    (writeOnly_io_output_aw_payload_qos[3:0]   ), //o
    .io_output_aw_payload_prot   (writeOnly_io_output_aw_payload_prot[2:0]  ), //o
    .io_output_w_valid           (writeOnly_io_output_w_valid               ), //o
    .io_output_w_ready           (io_output_w_ready                         ), //i
    .io_output_w_payload_data    (writeOnly_io_output_w_payload_data[127:0] ), //o
    .io_output_w_payload_strb    (writeOnly_io_output_w_payload_strb[15:0]  ), //o
    .io_output_w_payload_last    (writeOnly_io_output_w_payload_last        ), //o
    .io_output_b_valid           (io_output_b_valid                         ), //i
    .io_output_b_ready           (writeOnly_io_output_b_ready               ), //o
    .io_output_b_payload_id      (io_output_b_payload_id[7:0]               ), //i
    .io_output_b_payload_resp    (io_output_b_payload_resp[1:0]             ), //i
    .clk                         (clk                                       ), //i
    .reset                       (reset                                     )  //i
  );
  assign io_input_ar_ready = readOnly_io_input_ar_ready;
  assign io_input_r_valid = readOnly_io_input_r_valid;
  assign io_input_r_payload_data = readOnly_io_input_r_payload_data;
  assign io_input_r_payload_id = readOnly_io_input_r_payload_id;
  assign io_input_r_payload_resp = readOnly_io_input_r_payload_resp;
  assign io_input_r_payload_last = readOnly_io_input_r_payload_last;
  assign io_input_aw_ready = writeOnly_io_input_aw_ready;
  assign io_input_w_ready = writeOnly_io_input_w_ready;
  assign io_input_b_valid = writeOnly_io_input_b_valid;
  assign io_input_b_payload_id = writeOnly_io_input_b_payload_id;
  assign io_input_b_payload_resp = writeOnly_io_input_b_payload_resp;
  assign io_output_ar_valid = readOnly_io_output_ar_valid;
  assign io_output_ar_payload_addr = readOnly_io_output_ar_payload_addr;
  assign io_output_ar_payload_id = readOnly_io_output_ar_payload_id;
  assign io_output_ar_payload_region = readOnly_io_output_ar_payload_region;
  assign io_output_ar_payload_len = readOnly_io_output_ar_payload_len;
  assign io_output_ar_payload_size = readOnly_io_output_ar_payload_size;
  assign io_output_ar_payload_burst = readOnly_io_output_ar_payload_burst;
  assign io_output_ar_payload_lock = readOnly_io_output_ar_payload_lock;
  assign io_output_ar_payload_cache = readOnly_io_output_ar_payload_cache;
  assign io_output_ar_payload_qos = readOnly_io_output_ar_payload_qos;
  assign io_output_ar_payload_prot = readOnly_io_output_ar_payload_prot;
  assign io_output_r_ready = readOnly_io_output_r_ready;
  assign io_output_aw_valid = writeOnly_io_output_aw_valid;
  assign io_output_aw_payload_addr = writeOnly_io_output_aw_payload_addr;
  assign io_output_aw_payload_id = writeOnly_io_output_aw_payload_id;
  assign io_output_aw_payload_region = writeOnly_io_output_aw_payload_region;
  assign io_output_aw_payload_len = writeOnly_io_output_aw_payload_len;
  assign io_output_aw_payload_size = writeOnly_io_output_aw_payload_size;
  assign io_output_aw_payload_burst = writeOnly_io_output_aw_payload_burst;
  assign io_output_aw_payload_lock = writeOnly_io_output_aw_payload_lock;
  assign io_output_aw_payload_cache = writeOnly_io_output_aw_payload_cache;
  assign io_output_aw_payload_qos = writeOnly_io_output_aw_payload_qos;
  assign io_output_aw_payload_prot = writeOnly_io_output_aw_payload_prot;
  assign io_output_w_valid = writeOnly_io_output_w_valid;
  assign io_output_w_payload_data = writeOnly_io_output_w_payload_data;
  assign io_output_w_payload_strb = writeOnly_io_output_w_payload_strb;
  assign io_output_w_payload_last = writeOnly_io_output_w_payload_last;
  assign io_output_b_ready = writeOnly_io_output_b_ready;

endmodule

module Asic32To128UpsizerAxi4WriteOnlyUpsizer (
  input               io_input_aw_valid,
  output reg          io_input_aw_ready,
  input      [31:0]   io_input_aw_payload_addr,
  input      [7:0]    io_input_aw_payload_id,
  input      [3:0]    io_input_aw_payload_region,
  input      [7:0]    io_input_aw_payload_len,
  input      [2:0]    io_input_aw_payload_size,
  input      [1:0]    io_input_aw_payload_burst,
  input      [0:0]    io_input_aw_payload_lock,
  input      [3:0]    io_input_aw_payload_cache,
  input      [3:0]    io_input_aw_payload_qos,
  input      [2:0]    io_input_aw_payload_prot,
  input               io_input_w_valid,
  output              io_input_w_ready,
  input      [31:0]   io_input_w_payload_data,
  input      [3:0]    io_input_w_payload_strb,
  input               io_input_w_payload_last,
  output              io_input_b_valid,
  input               io_input_b_ready,
  output     [7:0]    io_input_b_payload_id,
  output     [1:0]    io_input_b_payload_resp,
  output              io_output_aw_valid,
  input               io_output_aw_ready,
  output     [31:0]   io_output_aw_payload_addr,
  output     [7:0]    io_output_aw_payload_id,
  output     [3:0]    io_output_aw_payload_region,
  output reg [7:0]    io_output_aw_payload_len,
  output reg [2:0]    io_output_aw_payload_size,
  output     [1:0]    io_output_aw_payload_burst,
  output     [0:0]    io_output_aw_payload_lock,
  output     [3:0]    io_output_aw_payload_cache,
  output     [3:0]    io_output_aw_payload_qos,
  output     [2:0]    io_output_aw_payload_prot,
  output              io_output_w_valid,
  input               io_output_w_ready,
  output     [127:0]  io_output_w_payload_data,
  output     [15:0]   io_output_w_payload_strb,
  output              io_output_w_payload_last,
  input               io_output_b_valid,
  output              io_output_b_ready,
  input      [7:0]    io_output_b_payload_id,
  input      [1:0]    io_output_b_payload_resp,
  input               clk,
  input               reset
);

  wire       [14:0]   _zz_cmdLogic_byteCount;
  wire       [10:0]   _zz_cmdLogic_incrLen;
  wire       [10:0]   _zz_cmdLogic_incrLen_1;
  wire       [3:0]    _zz_cmdLogic_incrLen_2;
  wire       [4:0]    _zz_dataLogic_byteCounterNext;
  wire       [7:0]    _zz_dataLogic_byteCounterNext_1;
  reg        [15:0]   _zz_dataLogic_byteActivity;
  wire       [1:0]    _zz_dataLogic_byteActivity_1;
  wire                cmdLogic_outputFork_valid;
  wire                cmdLogic_outputFork_ready;
  wire       [31:0]   cmdLogic_outputFork_payload_addr;
  wire       [7:0]    cmdLogic_outputFork_payload_id;
  wire       [3:0]    cmdLogic_outputFork_payload_region;
  wire       [7:0]    cmdLogic_outputFork_payload_len;
  wire       [2:0]    cmdLogic_outputFork_payload_size;
  wire       [1:0]    cmdLogic_outputFork_payload_burst;
  wire       [0:0]    cmdLogic_outputFork_payload_lock;
  wire       [3:0]    cmdLogic_outputFork_payload_cache;
  wire       [3:0]    cmdLogic_outputFork_payload_qos;
  wire       [2:0]    cmdLogic_outputFork_payload_prot;
  wire                cmdLogic_dataFork_valid;
  wire                cmdLogic_dataFork_ready;
  wire       [31:0]   cmdLogic_dataFork_payload_addr;
  wire       [7:0]    cmdLogic_dataFork_payload_id;
  wire       [3:0]    cmdLogic_dataFork_payload_region;
  wire       [7:0]    cmdLogic_dataFork_payload_len;
  wire       [2:0]    cmdLogic_dataFork_payload_size;
  wire       [1:0]    cmdLogic_dataFork_payload_burst;
  wire       [0:0]    cmdLogic_dataFork_payload_lock;
  wire       [3:0]    cmdLogic_dataFork_payload_cache;
  wire       [3:0]    cmdLogic_dataFork_payload_qos;
  wire       [2:0]    cmdLogic_dataFork_payload_prot;
  reg                 io_input_aw_fork2_logic_linkEnable_0;
  reg                 io_input_aw_fork2_logic_linkEnable_1;
  wire                when_Stream_l993;
  wire                when_Stream_l993_1;
  wire                cmdLogic_outputFork_fire;
  wire                cmdLogic_dataFork_fire;
  wire       [9:0]    cmdLogic_byteCount;
  wire       [6:0]    cmdLogic_incrLen;
  wire                when_Axi4Upsizer_l21;
  wire                when_Axi4Upsizer_l24;
  reg        [3:0]    dataLogic_byteCounter;
  reg        [2:0]    dataLogic_size;
  reg                 dataLogic_outputValid;
  reg                 dataLogic_outputLast;
  reg                 dataLogic_busy;
  reg                 dataLogic_incrementByteCounter;
  reg                 dataLogic_alwaysFire;
  wire       [4:0]    dataLogic_byteCounterNext;
  reg        [127:0]  dataLogic_dataBuffer;
  reg        [15:0]   dataLogic_maskBuffer;
  wire       [15:0]   dataLogic_byteActivity;
  wire                io_output_w_fire;
  wire                io_output_w_isStall;
  wire                io_input_w_fire;
  wire                when_Axi4Upsizer_l59;
  wire                when_Axi4Upsizer_l59_1;
  wire                when_Axi4Upsizer_l59_2;
  wire                when_Axi4Upsizer_l59_3;
  wire                when_Axi4Upsizer_l59_4;
  wire                when_Axi4Upsizer_l59_5;
  wire                when_Axi4Upsizer_l59_6;
  wire                when_Axi4Upsizer_l59_7;
  wire                when_Axi4Upsizer_l59_8;
  wire                when_Axi4Upsizer_l59_9;
  wire                when_Axi4Upsizer_l59_10;
  wire                when_Axi4Upsizer_l59_11;
  wire                when_Axi4Upsizer_l59_12;
  wire                when_Axi4Upsizer_l59_13;
  wire                when_Axi4Upsizer_l59_14;
  wire                when_Axi4Upsizer_l59_15;
  wire                cmdLogic_dataFork_fire_1;
  wire                when_Axi4Upsizer_l68;
  wire                when_Axi4Upsizer_l68_1;
  wire                when_Axi4Upsizer_l68_2;
  wire                when_Axi4Upsizer_l68_3;

  assign _zz_cmdLogic_byteCount = ({7'd0,io_input_aw_payload_len} <<< io_input_aw_payload_size);
  assign _zz_cmdLogic_incrLen = ({1'b0,cmdLogic_byteCount} + _zz_cmdLogic_incrLen_1);
  assign _zz_cmdLogic_incrLen_2 = io_input_aw_payload_addr[3 : 0];
  assign _zz_cmdLogic_incrLen_1 = {7'd0, _zz_cmdLogic_incrLen_2};
  assign _zz_dataLogic_byteCounterNext_1 = ({7'd0,1'b1} <<< dataLogic_size);
  assign _zz_dataLogic_byteCounterNext = _zz_dataLogic_byteCounterNext_1[4:0];
  assign _zz_dataLogic_byteActivity_1 = dataLogic_size[1:0];
  always @(*) begin
    case(_zz_dataLogic_byteActivity_1)
      2'b00 : _zz_dataLogic_byteActivity = 16'h0001;
      2'b01 : _zz_dataLogic_byteActivity = 16'h0003;
      2'b10 : _zz_dataLogic_byteActivity = 16'h000f;
      default : _zz_dataLogic_byteActivity = 16'h00ff;
    endcase
  end

  always @(*) begin
    io_input_aw_ready = 1'b1;
    if(when_Stream_l993) begin
      io_input_aw_ready = 1'b0;
    end
    if(when_Stream_l993_1) begin
      io_input_aw_ready = 1'b0;
    end
  end

  assign when_Stream_l993 = ((! cmdLogic_outputFork_ready) && io_input_aw_fork2_logic_linkEnable_0);
  assign when_Stream_l993_1 = ((! cmdLogic_dataFork_ready) && io_input_aw_fork2_logic_linkEnable_1);
  assign cmdLogic_outputFork_valid = (io_input_aw_valid && io_input_aw_fork2_logic_linkEnable_0);
  assign cmdLogic_outputFork_payload_addr = io_input_aw_payload_addr;
  assign cmdLogic_outputFork_payload_id = io_input_aw_payload_id;
  assign cmdLogic_outputFork_payload_region = io_input_aw_payload_region;
  assign cmdLogic_outputFork_payload_len = io_input_aw_payload_len;
  assign cmdLogic_outputFork_payload_size = io_input_aw_payload_size;
  assign cmdLogic_outputFork_payload_burst = io_input_aw_payload_burst;
  assign cmdLogic_outputFork_payload_lock = io_input_aw_payload_lock;
  assign cmdLogic_outputFork_payload_cache = io_input_aw_payload_cache;
  assign cmdLogic_outputFork_payload_qos = io_input_aw_payload_qos;
  assign cmdLogic_outputFork_payload_prot = io_input_aw_payload_prot;
  assign cmdLogic_outputFork_fire = (cmdLogic_outputFork_valid && cmdLogic_outputFork_ready);
  assign cmdLogic_dataFork_valid = (io_input_aw_valid && io_input_aw_fork2_logic_linkEnable_1);
  assign cmdLogic_dataFork_payload_addr = io_input_aw_payload_addr;
  assign cmdLogic_dataFork_payload_id = io_input_aw_payload_id;
  assign cmdLogic_dataFork_payload_region = io_input_aw_payload_region;
  assign cmdLogic_dataFork_payload_len = io_input_aw_payload_len;
  assign cmdLogic_dataFork_payload_size = io_input_aw_payload_size;
  assign cmdLogic_dataFork_payload_burst = io_input_aw_payload_burst;
  assign cmdLogic_dataFork_payload_lock = io_input_aw_payload_lock;
  assign cmdLogic_dataFork_payload_cache = io_input_aw_payload_cache;
  assign cmdLogic_dataFork_payload_qos = io_input_aw_payload_qos;
  assign cmdLogic_dataFork_payload_prot = io_input_aw_payload_prot;
  assign cmdLogic_dataFork_fire = (cmdLogic_dataFork_valid && cmdLogic_dataFork_ready);
  assign io_output_aw_valid = cmdLogic_outputFork_valid;
  assign cmdLogic_outputFork_ready = io_output_aw_ready;
  assign io_output_aw_payload_addr = cmdLogic_outputFork_payload_addr;
  assign io_output_aw_payload_id = cmdLogic_outputFork_payload_id;
  assign io_output_aw_payload_region = cmdLogic_outputFork_payload_region;
  always @(*) begin
    io_output_aw_payload_len = cmdLogic_outputFork_payload_len;
    if(when_Axi4Upsizer_l21) begin
      io_output_aw_payload_len = {1'd0, cmdLogic_incrLen};
    end
  end

  always @(*) begin
    io_output_aw_payload_size = cmdLogic_outputFork_payload_size;
    if(when_Axi4Upsizer_l21) begin
      io_output_aw_payload_size = 3'b100;
      if(when_Axi4Upsizer_l24) begin
        io_output_aw_payload_size = io_input_aw_payload_size;
      end
    end
  end

  assign io_output_aw_payload_burst = cmdLogic_outputFork_payload_burst;
  assign io_output_aw_payload_lock = cmdLogic_outputFork_payload_lock;
  assign io_output_aw_payload_cache = cmdLogic_outputFork_payload_cache;
  assign io_output_aw_payload_qos = cmdLogic_outputFork_payload_qos;
  assign io_output_aw_payload_prot = cmdLogic_outputFork_payload_prot;
  assign cmdLogic_byteCount = _zz_cmdLogic_byteCount[9:0];
  assign cmdLogic_incrLen = _zz_cmdLogic_incrLen[10 : 4];
  assign when_Axi4Upsizer_l21 = (io_output_aw_payload_burst == 2'b01);
  assign when_Axi4Upsizer_l24 = (io_input_aw_payload_len == 8'h00);
  assign dataLogic_byteCounterNext = ({1'b0,dataLogic_byteCounter} + _zz_dataLogic_byteCounterNext);
  assign dataLogic_byteActivity = (_zz_dataLogic_byteActivity <<< dataLogic_byteCounter);
  assign io_output_w_fire = (io_output_w_valid && io_output_w_ready);
  assign io_output_w_valid = dataLogic_outputValid;
  assign io_output_w_isStall = (io_output_w_valid && (! io_output_w_ready));
  assign io_input_w_ready = (dataLogic_busy && (! io_output_w_isStall));
  assign io_output_w_payload_data = dataLogic_dataBuffer;
  assign io_output_w_payload_strb = dataLogic_maskBuffer;
  assign io_output_w_payload_last = dataLogic_outputLast;
  assign io_input_w_fire = (io_input_w_valid && io_input_w_ready);
  assign when_Axi4Upsizer_l59 = dataLogic_byteActivity[0];
  assign when_Axi4Upsizer_l59_1 = dataLogic_byteActivity[1];
  assign when_Axi4Upsizer_l59_2 = dataLogic_byteActivity[2];
  assign when_Axi4Upsizer_l59_3 = dataLogic_byteActivity[3];
  assign when_Axi4Upsizer_l59_4 = dataLogic_byteActivity[4];
  assign when_Axi4Upsizer_l59_5 = dataLogic_byteActivity[5];
  assign when_Axi4Upsizer_l59_6 = dataLogic_byteActivity[6];
  assign when_Axi4Upsizer_l59_7 = dataLogic_byteActivity[7];
  assign when_Axi4Upsizer_l59_8 = dataLogic_byteActivity[8];
  assign when_Axi4Upsizer_l59_9 = dataLogic_byteActivity[9];
  assign when_Axi4Upsizer_l59_10 = dataLogic_byteActivity[10];
  assign when_Axi4Upsizer_l59_11 = dataLogic_byteActivity[11];
  assign when_Axi4Upsizer_l59_12 = dataLogic_byteActivity[12];
  assign when_Axi4Upsizer_l59_13 = dataLogic_byteActivity[13];
  assign when_Axi4Upsizer_l59_14 = dataLogic_byteActivity[14];
  assign when_Axi4Upsizer_l59_15 = dataLogic_byteActivity[15];
  assign cmdLogic_dataFork_fire_1 = (cmdLogic_dataFork_valid && cmdLogic_dataFork_ready);
  assign when_Axi4Upsizer_l68 = (3'b000 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_1 = (3'b001 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_2 = (3'b010 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_3 = (3'b011 < cmdLogic_dataFork_payload_size);
  assign cmdLogic_dataFork_ready = (! dataLogic_busy);
  assign io_input_b_valid = io_output_b_valid;
  assign io_output_b_ready = io_input_b_ready;
  assign io_input_b_payload_id = io_output_b_payload_id;
  assign io_input_b_payload_resp = io_output_b_payload_resp;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_input_aw_fork2_logic_linkEnable_0 <= 1'b1;
      io_input_aw_fork2_logic_linkEnable_1 <= 1'b1;
      dataLogic_outputValid <= 1'b0;
      dataLogic_busy <= 1'b0;
      dataLogic_maskBuffer <= 16'h0000;
    end else begin
      if(cmdLogic_outputFork_fire) begin
        io_input_aw_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdLogic_dataFork_fire) begin
        io_input_aw_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_input_aw_ready) begin
        io_input_aw_fork2_logic_linkEnable_0 <= 1'b1;
        io_input_aw_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(io_output_w_ready) begin
        dataLogic_outputValid <= 1'b0;
      end
      if(io_output_w_fire) begin
        dataLogic_maskBuffer <= 16'h0000;
      end
      if(io_input_w_fire) begin
        dataLogic_outputValid <= ((dataLogic_byteCounterNext[4] || io_input_w_payload_last) || dataLogic_alwaysFire);
        if(io_input_w_payload_last) begin
          dataLogic_busy <= 1'b0;
        end
        if(when_Axi4Upsizer_l59) begin
          dataLogic_maskBuffer[0] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_1) begin
          dataLogic_maskBuffer[1] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_2) begin
          dataLogic_maskBuffer[2] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_3) begin
          dataLogic_maskBuffer[3] <= io_input_w_payload_strb[3];
        end
        if(when_Axi4Upsizer_l59_4) begin
          dataLogic_maskBuffer[4] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_5) begin
          dataLogic_maskBuffer[5] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_6) begin
          dataLogic_maskBuffer[6] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_7) begin
          dataLogic_maskBuffer[7] <= io_input_w_payload_strb[3];
        end
        if(when_Axi4Upsizer_l59_8) begin
          dataLogic_maskBuffer[8] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_9) begin
          dataLogic_maskBuffer[9] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_10) begin
          dataLogic_maskBuffer[10] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_11) begin
          dataLogic_maskBuffer[11] <= io_input_w_payload_strb[3];
        end
        if(when_Axi4Upsizer_l59_12) begin
          dataLogic_maskBuffer[12] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_13) begin
          dataLogic_maskBuffer[13] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_14) begin
          dataLogic_maskBuffer[14] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_15) begin
          dataLogic_maskBuffer[15] <= io_input_w_payload_strb[3];
        end
      end
      if(cmdLogic_dataFork_fire_1) begin
        dataLogic_busy <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if(io_input_w_fire) begin
      if(dataLogic_incrementByteCounter) begin
        dataLogic_byteCounter <= dataLogic_byteCounterNext[3:0];
      end
      dataLogic_outputLast <= io_input_w_payload_last;
      if(when_Axi4Upsizer_l59) begin
        dataLogic_dataBuffer[7 : 0] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_1) begin
        dataLogic_dataBuffer[15 : 8] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_2) begin
        dataLogic_dataBuffer[23 : 16] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_3) begin
        dataLogic_dataBuffer[31 : 24] <= io_input_w_payload_data[31 : 24];
      end
      if(when_Axi4Upsizer_l59_4) begin
        dataLogic_dataBuffer[39 : 32] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_5) begin
        dataLogic_dataBuffer[47 : 40] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_6) begin
        dataLogic_dataBuffer[55 : 48] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_7) begin
        dataLogic_dataBuffer[63 : 56] <= io_input_w_payload_data[31 : 24];
      end
      if(when_Axi4Upsizer_l59_8) begin
        dataLogic_dataBuffer[71 : 64] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_9) begin
        dataLogic_dataBuffer[79 : 72] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_10) begin
        dataLogic_dataBuffer[87 : 80] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_11) begin
        dataLogic_dataBuffer[95 : 88] <= io_input_w_payload_data[31 : 24];
      end
      if(when_Axi4Upsizer_l59_12) begin
        dataLogic_dataBuffer[103 : 96] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_13) begin
        dataLogic_dataBuffer[111 : 104] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_14) begin
        dataLogic_dataBuffer[119 : 112] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_15) begin
        dataLogic_dataBuffer[127 : 120] <= io_input_w_payload_data[31 : 24];
      end
    end
    if(cmdLogic_dataFork_fire_1) begin
      dataLogic_byteCounter <= cmdLogic_dataFork_payload_addr[3:0];
      if(when_Axi4Upsizer_l68) begin
        dataLogic_byteCounter[0] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_1) begin
        dataLogic_byteCounter[1] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_2) begin
        dataLogic_byteCounter[2] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_3) begin
        dataLogic_byteCounter[3] <= 1'b0;
      end
      dataLogic_size <= cmdLogic_dataFork_payload_size;
      dataLogic_alwaysFire <= (! (cmdLogic_dataFork_payload_burst == 2'b01));
      dataLogic_incrementByteCounter <= (! (cmdLogic_dataFork_payload_burst == 2'b00));
    end
  end


endmodule

module Asic32To128UpsizerAxi4ReadOnlyUpsizer (
  input               io_input_ar_valid,
  output reg          io_input_ar_ready,
  input      [31:0]   io_input_ar_payload_addr,
  input      [7:0]    io_input_ar_payload_id,
  input      [3:0]    io_input_ar_payload_region,
  input      [7:0]    io_input_ar_payload_len,
  input      [2:0]    io_input_ar_payload_size,
  input      [1:0]    io_input_ar_payload_burst,
  input      [0:0]    io_input_ar_payload_lock,
  input      [3:0]    io_input_ar_payload_cache,
  input      [3:0]    io_input_ar_payload_qos,
  input      [2:0]    io_input_ar_payload_prot,
  output              io_input_r_valid,
  input               io_input_r_ready,
  output     [31:0]   io_input_r_payload_data,
  output     [7:0]    io_input_r_payload_id,
  output     [1:0]    io_input_r_payload_resp,
  output              io_input_r_payload_last,
  output              io_output_ar_valid,
  input               io_output_ar_ready,
  output     [31:0]   io_output_ar_payload_addr,
  output     [7:0]    io_output_ar_payload_id,
  output     [3:0]    io_output_ar_payload_region,
  output     [7:0]    io_output_ar_payload_len,
  output reg [2:0]    io_output_ar_payload_size,
  output     [1:0]    io_output_ar_payload_burst,
  output     [0:0]    io_output_ar_payload_lock,
  output     [3:0]    io_output_ar_payload_cache,
  output     [3:0]    io_output_ar_payload_qos,
  output     [2:0]    io_output_ar_payload_prot,
  input               io_output_r_valid,
  output              io_output_r_ready,
  input      [127:0]  io_output_r_payload_data,
  input      [7:0]    io_output_r_payload_id,
  input      [1:0]    io_output_r_payload_resp,
  input               io_output_r_payload_last,
  input               clk,
  input               reset
);

  wire                dataLogic_cmdPush_fifo_io_pop_ready;
  wire                dataLogic_cmdPush_fifo_io_push_ready;
  wire                dataLogic_cmdPush_fifo_io_pop_valid;
  wire       [3:0]    dataLogic_cmdPush_fifo_io_pop_payload_startAt;
  wire       [3:0]    dataLogic_cmdPush_fifo_io_pop_payload_endAt;
  wire       [2:0]    dataLogic_cmdPush_fifo_io_pop_payload_size;
  wire       [7:0]    dataLogic_cmdPush_fifo_io_pop_payload_id;
  wire       [4:0]    dataLogic_cmdPush_fifo_io_occupancy;
  wire       [4:0]    dataLogic_cmdPush_fifo_io_availability;
  wire       [14:0]   _zz_cmdLogic_byteCount;
  wire       [10:0]   _zz_cmdLogic_incrLen;
  wire       [10:0]   _zz_cmdLogic_incrLen_1;
  wire       [3:0]    _zz_cmdLogic_incrLen_2;
  wire       [31:0]   _zz_dataLogic_cmdPush_payload_endAt;
  wire       [31:0]   _zz_dataLogic_cmdPush_payload_endAt_1;
  wire       [14:0]   _zz_dataLogic_cmdPush_payload_endAt_2;
  wire       [4:0]    _zz_dataLogic_byteCounterNext;
  wire       [7:0]    _zz_dataLogic_byteCounterNext_1;
  reg        [31:0]   _zz_io_input_r_payload_data;
  wire       [1:0]    _zz_io_input_r_payload_data_1;
  wire                cmdLogic_outputFork_valid;
  wire                cmdLogic_outputFork_ready;
  wire       [31:0]   cmdLogic_outputFork_payload_addr;
  wire       [7:0]    cmdLogic_outputFork_payload_id;
  wire       [3:0]    cmdLogic_outputFork_payload_region;
  wire       [7:0]    cmdLogic_outputFork_payload_len;
  wire       [2:0]    cmdLogic_outputFork_payload_size;
  wire       [1:0]    cmdLogic_outputFork_payload_burst;
  wire       [0:0]    cmdLogic_outputFork_payload_lock;
  wire       [3:0]    cmdLogic_outputFork_payload_cache;
  wire       [3:0]    cmdLogic_outputFork_payload_qos;
  wire       [2:0]    cmdLogic_outputFork_payload_prot;
  wire                cmdLogic_dataFork_valid;
  wire                cmdLogic_dataFork_ready;
  wire       [31:0]   cmdLogic_dataFork_payload_addr;
  wire       [7:0]    cmdLogic_dataFork_payload_id;
  wire       [3:0]    cmdLogic_dataFork_payload_region;
  wire       [7:0]    cmdLogic_dataFork_payload_len;
  wire       [2:0]    cmdLogic_dataFork_payload_size;
  wire       [1:0]    cmdLogic_dataFork_payload_burst;
  wire       [0:0]    cmdLogic_dataFork_payload_lock;
  wire       [3:0]    cmdLogic_dataFork_payload_cache;
  wire       [3:0]    cmdLogic_dataFork_payload_qos;
  wire       [2:0]    cmdLogic_dataFork_payload_prot;
  reg                 io_input_ar_fork2_logic_linkEnable_0;
  reg                 io_input_ar_fork2_logic_linkEnable_1;
  wire                when_Stream_l993;
  wire                when_Stream_l993_1;
  wire                cmdLogic_outputFork_fire;
  wire                cmdLogic_dataFork_fire;
  wire       [9:0]    cmdLogic_byteCount;
  wire       [6:0]    cmdLogic_incrLen;
  wire                when_Axi4Upsizer_l108;
  wire                dataLogic_cmdPush_valid;
  wire                dataLogic_cmdPush_ready;
  wire       [3:0]    dataLogic_cmdPush_payload_startAt;
  wire       [3:0]    dataLogic_cmdPush_payload_endAt;
  wire       [2:0]    dataLogic_cmdPush_payload_size;
  wire       [7:0]    dataLogic_cmdPush_payload_id;
  reg        [2:0]    dataLogic_size;
  reg                 dataLogic_busy;
  reg        [7:0]    dataLogic_id;
  reg        [3:0]    dataLogic_byteCounter;
  reg        [3:0]    dataLogic_byteCounterLast;
  wire       [4:0]    dataLogic_byteCounterNext;
  wire                readOnly_dataLogic_cmdPush_fifo_io_pop_fire;
  wire                io_input_r_fire;

  assign _zz_cmdLogic_byteCount = ({7'd0,io_input_ar_payload_len} <<< io_input_ar_payload_size);
  assign _zz_cmdLogic_incrLen = ({1'b0,cmdLogic_byteCount} + _zz_cmdLogic_incrLen_1);
  assign _zz_cmdLogic_incrLen_2 = io_input_ar_payload_addr[3 : 0];
  assign _zz_cmdLogic_incrLen_1 = {7'd0, _zz_cmdLogic_incrLen_2};
  assign _zz_dataLogic_cmdPush_payload_endAt = (cmdLogic_dataFork_payload_addr + _zz_dataLogic_cmdPush_payload_endAt_1);
  assign _zz_dataLogic_cmdPush_payload_endAt_2 = ({7'd0,cmdLogic_dataFork_payload_len} <<< cmdLogic_dataFork_payload_size);
  assign _zz_dataLogic_cmdPush_payload_endAt_1 = {17'd0, _zz_dataLogic_cmdPush_payload_endAt_2};
  assign _zz_dataLogic_byteCounterNext_1 = ({7'd0,1'b1} <<< dataLogic_size);
  assign _zz_dataLogic_byteCounterNext = _zz_dataLogic_byteCounterNext_1[4:0];
  assign _zz_io_input_r_payload_data_1 = (dataLogic_byteCounter >>> 2'd2);
  Asic32To128UpsizerStreamFifo dataLogic_cmdPush_fifo (
    .io_push_valid           (dataLogic_cmdPush_valid                           ), //i
    .io_push_ready           (dataLogic_cmdPush_fifo_io_push_ready              ), //o
    .io_push_payload_startAt (dataLogic_cmdPush_payload_startAt[3:0]            ), //i
    .io_push_payload_endAt   (dataLogic_cmdPush_payload_endAt[3:0]              ), //i
    .io_push_payload_size    (dataLogic_cmdPush_payload_size[2:0]               ), //i
    .io_push_payload_id      (dataLogic_cmdPush_payload_id[7:0]                 ), //i
    .io_pop_valid            (dataLogic_cmdPush_fifo_io_pop_valid               ), //o
    .io_pop_ready            (dataLogic_cmdPush_fifo_io_pop_ready               ), //i
    .io_pop_payload_startAt  (dataLogic_cmdPush_fifo_io_pop_payload_startAt[3:0]), //o
    .io_pop_payload_endAt    (dataLogic_cmdPush_fifo_io_pop_payload_endAt[3:0]  ), //o
    .io_pop_payload_size     (dataLogic_cmdPush_fifo_io_pop_payload_size[2:0]   ), //o
    .io_pop_payload_id       (dataLogic_cmdPush_fifo_io_pop_payload_id[7:0]     ), //o
    .io_flush                (1'b0                                              ), //i
    .io_occupancy            (dataLogic_cmdPush_fifo_io_occupancy[4:0]          ), //o
    .io_availability         (dataLogic_cmdPush_fifo_io_availability[4:0]       ), //o
    .clk                     (clk                                               ), //i
    .reset                   (reset                                             )  //i
  );
  always @(*) begin
    case(_zz_io_input_r_payload_data_1)
      2'b00 : _zz_io_input_r_payload_data = io_output_r_payload_data[31 : 0];
      2'b01 : _zz_io_input_r_payload_data = io_output_r_payload_data[63 : 32];
      2'b10 : _zz_io_input_r_payload_data = io_output_r_payload_data[95 : 64];
      default : _zz_io_input_r_payload_data = io_output_r_payload_data[127 : 96];
    endcase
  end

  always @(*) begin
    io_input_ar_ready = 1'b1;
    if(when_Stream_l993) begin
      io_input_ar_ready = 1'b0;
    end
    if(when_Stream_l993_1) begin
      io_input_ar_ready = 1'b0;
    end
  end

  assign when_Stream_l993 = ((! cmdLogic_outputFork_ready) && io_input_ar_fork2_logic_linkEnable_0);
  assign when_Stream_l993_1 = ((! cmdLogic_dataFork_ready) && io_input_ar_fork2_logic_linkEnable_1);
  assign cmdLogic_outputFork_valid = (io_input_ar_valid && io_input_ar_fork2_logic_linkEnable_0);
  assign cmdLogic_outputFork_payload_addr = io_input_ar_payload_addr;
  assign cmdLogic_outputFork_payload_id = io_input_ar_payload_id;
  assign cmdLogic_outputFork_payload_region = io_input_ar_payload_region;
  assign cmdLogic_outputFork_payload_len = io_input_ar_payload_len;
  assign cmdLogic_outputFork_payload_size = io_input_ar_payload_size;
  assign cmdLogic_outputFork_payload_burst = io_input_ar_payload_burst;
  assign cmdLogic_outputFork_payload_lock = io_input_ar_payload_lock;
  assign cmdLogic_outputFork_payload_cache = io_input_ar_payload_cache;
  assign cmdLogic_outputFork_payload_qos = io_input_ar_payload_qos;
  assign cmdLogic_outputFork_payload_prot = io_input_ar_payload_prot;
  assign cmdLogic_outputFork_fire = (cmdLogic_outputFork_valid && cmdLogic_outputFork_ready);
  assign cmdLogic_dataFork_valid = (io_input_ar_valid && io_input_ar_fork2_logic_linkEnable_1);
  assign cmdLogic_dataFork_payload_addr = io_input_ar_payload_addr;
  assign cmdLogic_dataFork_payload_id = io_input_ar_payload_id;
  assign cmdLogic_dataFork_payload_region = io_input_ar_payload_region;
  assign cmdLogic_dataFork_payload_len = io_input_ar_payload_len;
  assign cmdLogic_dataFork_payload_size = io_input_ar_payload_size;
  assign cmdLogic_dataFork_payload_burst = io_input_ar_payload_burst;
  assign cmdLogic_dataFork_payload_lock = io_input_ar_payload_lock;
  assign cmdLogic_dataFork_payload_cache = io_input_ar_payload_cache;
  assign cmdLogic_dataFork_payload_qos = io_input_ar_payload_qos;
  assign cmdLogic_dataFork_payload_prot = io_input_ar_payload_prot;
  assign cmdLogic_dataFork_fire = (cmdLogic_dataFork_valid && cmdLogic_dataFork_ready);
  assign io_output_ar_valid = cmdLogic_outputFork_valid;
  assign cmdLogic_outputFork_ready = io_output_ar_ready;
  assign io_output_ar_payload_addr = cmdLogic_outputFork_payload_addr;
  assign io_output_ar_payload_region = cmdLogic_outputFork_payload_region;
  assign io_output_ar_payload_burst = cmdLogic_outputFork_payload_burst;
  assign io_output_ar_payload_lock = cmdLogic_outputFork_payload_lock;
  assign io_output_ar_payload_cache = cmdLogic_outputFork_payload_cache;
  assign io_output_ar_payload_qos = cmdLogic_outputFork_payload_qos;
  assign io_output_ar_payload_prot = cmdLogic_outputFork_payload_prot;
  assign cmdLogic_byteCount = _zz_cmdLogic_byteCount[9:0];
  assign cmdLogic_incrLen = _zz_cmdLogic_incrLen[10 : 4];
  always @(*) begin
    io_output_ar_payload_size = 3'b100;
    if(when_Axi4Upsizer_l108) begin
      io_output_ar_payload_size = io_input_ar_payload_size;
    end
  end

  assign io_output_ar_payload_len = {1'd0, cmdLogic_incrLen};
  assign io_output_ar_payload_id = 8'h00;
  assign when_Axi4Upsizer_l108 = (io_input_ar_payload_len == 8'h00);
  assign dataLogic_cmdPush_valid = cmdLogic_dataFork_valid;
  assign cmdLogic_dataFork_ready = dataLogic_cmdPush_ready;
  assign dataLogic_cmdPush_payload_startAt = cmdLogic_dataFork_payload_addr[3:0];
  assign dataLogic_cmdPush_payload_endAt = _zz_dataLogic_cmdPush_payload_endAt[3:0];
  assign dataLogic_cmdPush_payload_size = cmdLogic_dataFork_payload_size;
  assign dataLogic_cmdPush_payload_id = cmdLogic_dataFork_payload_id;
  assign dataLogic_cmdPush_ready = dataLogic_cmdPush_fifo_io_push_ready;
  assign dataLogic_byteCounterNext = ({1'b0,dataLogic_byteCounter} + _zz_dataLogic_byteCounterNext);
  assign readOnly_dataLogic_cmdPush_fifo_io_pop_fire = (dataLogic_cmdPush_fifo_io_pop_valid && dataLogic_cmdPush_fifo_io_pop_ready);
  assign dataLogic_cmdPush_fifo_io_pop_ready = (! dataLogic_busy);
  assign io_input_r_fire = (io_input_r_valid && io_input_r_ready);
  assign io_input_r_valid = (io_output_r_valid && dataLogic_busy);
  assign io_input_r_payload_last = (io_output_r_payload_last && (dataLogic_byteCounter == dataLogic_byteCounterLast));
  assign io_input_r_payload_resp = io_output_r_payload_resp;
  assign io_input_r_payload_data = _zz_io_input_r_payload_data;
  assign io_input_r_payload_id = dataLogic_id;
  assign io_output_r_ready = ((dataLogic_busy && io_input_r_ready) && (io_input_r_payload_last || dataLogic_byteCounterNext[4]));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_input_ar_fork2_logic_linkEnable_0 <= 1'b1;
      io_input_ar_fork2_logic_linkEnable_1 <= 1'b1;
      dataLogic_busy <= 1'b0;
    end else begin
      if(cmdLogic_outputFork_fire) begin
        io_input_ar_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdLogic_dataFork_fire) begin
        io_input_ar_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_input_ar_ready) begin
        io_input_ar_fork2_logic_linkEnable_0 <= 1'b1;
        io_input_ar_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(readOnly_dataLogic_cmdPush_fifo_io_pop_fire) begin
        dataLogic_busy <= 1'b1;
      end
      if(io_input_r_fire) begin
        if(io_input_r_payload_last) begin
          dataLogic_busy <= 1'b0;
        end
      end
    end
  end

  always @(posedge clk) begin
    if(readOnly_dataLogic_cmdPush_fifo_io_pop_fire) begin
      dataLogic_byteCounter <= dataLogic_cmdPush_fifo_io_pop_payload_startAt;
      dataLogic_byteCounterLast <= dataLogic_cmdPush_fifo_io_pop_payload_endAt;
      dataLogic_size <= dataLogic_cmdPush_fifo_io_pop_payload_size;
      dataLogic_id <= dataLogic_cmdPush_fifo_io_pop_payload_id;
    end
    if(io_input_r_fire) begin
      dataLogic_byteCounter <= dataLogic_byteCounterNext[3:0];
    end
  end


endmodule

module Asic32To128UpsizerStreamFifo (
  input               io_push_valid,
  output              io_push_ready,
  input      [3:0]    io_push_payload_startAt,
  input      [3:0]    io_push_payload_endAt,
  input      [2:0]    io_push_payload_size,
  input      [7:0]    io_push_payload_id,
  output              io_pop_valid,
  input               io_pop_ready,
  output     [3:0]    io_pop_payload_startAt,
  output     [3:0]    io_pop_payload_endAt,
  output     [2:0]    io_pop_payload_size,
  output     [7:0]    io_pop_payload_id,
  input               io_flush,
  output     [4:0]    io_occupancy,
  output     [4:0]    io_availability,
  input               clk,
  input               reset
);

  reg        [18:0]   _zz_logic_ram_port0;
  wire       [3:0]    _zz_logic_pushPtr_valueNext;
  wire       [0:0]    _zz_logic_pushPtr_valueNext_1;
  wire       [3:0]    _zz_logic_popPtr_valueNext;
  wire       [0:0]    _zz_logic_popPtr_valueNext_1;
  wire                _zz__zz_logic_ram_port0;
  wire                _zz__zz_io_pop_payload_startAt;
  wire       [18:0]   _zz__zz_logic_ram_port1;
  wire       [3:0]    _zz_io_availability;
  reg                 _zz_1;
  reg                 logic_pushPtr_willIncrement;
  reg                 logic_pushPtr_willClear;
  reg        [3:0]    logic_pushPtr_valueNext;
  reg        [3:0]    logic_pushPtr_value;
  wire                logic_pushPtr_willOverflowIfInc;
  wire                logic_pushPtr_willOverflow;
  reg                 logic_popPtr_willIncrement;
  reg                 logic_popPtr_willClear;
  reg        [3:0]    logic_popPtr_valueNext;
  reg        [3:0]    logic_popPtr_value;
  wire                logic_popPtr_willOverflowIfInc;
  wire                logic_popPtr_willOverflow;
  wire                logic_ptrMatch;
  reg                 logic_risingOccupancy;
  wire                logic_pushing;
  wire                logic_popping;
  wire                logic_empty;
  wire                logic_full;
  reg                 _zz_io_pop_valid;
  wire       [18:0]   _zz_io_pop_payload_startAt;
  wire                when_Stream_l1123;
  wire       [3:0]    logic_ptrDif;
  reg [18:0] logic_ram [0:15];

  assign _zz_logic_pushPtr_valueNext_1 = logic_pushPtr_willIncrement;
  assign _zz_logic_pushPtr_valueNext = {3'd0, _zz_logic_pushPtr_valueNext_1};
  assign _zz_logic_popPtr_valueNext_1 = logic_popPtr_willIncrement;
  assign _zz_logic_popPtr_valueNext = {3'd0, _zz_logic_popPtr_valueNext_1};
  assign _zz_io_availability = (logic_popPtr_value - logic_pushPtr_value);
  assign _zz__zz_io_pop_payload_startAt = 1'b1;
  assign _zz__zz_logic_ram_port1 = {io_push_payload_id,{io_push_payload_size,{io_push_payload_endAt,io_push_payload_startAt}}};
  always @(posedge clk) begin
    if(_zz__zz_io_pop_payload_startAt) begin
      _zz_logic_ram_port0 <= logic_ram[logic_popPtr_valueNext];
    end
  end

  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_pushPtr_value] <= _zz__zz_logic_ram_port1;
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_pushing) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willIncrement = 1'b0;
    if(logic_pushing) begin
      logic_pushPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_pushPtr_willClear = 1'b1;
    end
  end

  assign logic_pushPtr_willOverflowIfInc = (logic_pushPtr_value == 4'b1111);
  assign logic_pushPtr_willOverflow = (logic_pushPtr_willOverflowIfInc && logic_pushPtr_willIncrement);
  always @(*) begin
    logic_pushPtr_valueNext = (logic_pushPtr_value + _zz_logic_pushPtr_valueNext);
    if(logic_pushPtr_willClear) begin
      logic_pushPtr_valueNext = 4'b0000;
    end
  end

  always @(*) begin
    logic_popPtr_willIncrement = 1'b0;
    if(logic_popping) begin
      logic_popPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_popPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_popPtr_willClear = 1'b1;
    end
  end

  assign logic_popPtr_willOverflowIfInc = (logic_popPtr_value == 4'b1111);
  assign logic_popPtr_willOverflow = (logic_popPtr_willOverflowIfInc && logic_popPtr_willIncrement);
  always @(*) begin
    logic_popPtr_valueNext = (logic_popPtr_value + _zz_logic_popPtr_valueNext);
    if(logic_popPtr_willClear) begin
      logic_popPtr_valueNext = 4'b0000;
    end
  end

  assign logic_ptrMatch = (logic_pushPtr_value == logic_popPtr_value);
  assign logic_pushing = (io_push_valid && io_push_ready);
  assign logic_popping = (io_pop_valid && io_pop_ready);
  assign logic_empty = (logic_ptrMatch && (! logic_risingOccupancy));
  assign logic_full = (logic_ptrMatch && logic_risingOccupancy);
  assign io_push_ready = (! logic_full);
  assign io_pop_valid = ((! logic_empty) && (! (_zz_io_pop_valid && (! logic_full))));
  assign _zz_io_pop_payload_startAt = _zz_logic_ram_port0;
  assign io_pop_payload_startAt = _zz_io_pop_payload_startAt[3 : 0];
  assign io_pop_payload_endAt = _zz_io_pop_payload_startAt[7 : 4];
  assign io_pop_payload_size = _zz_io_pop_payload_startAt[10 : 8];
  assign io_pop_payload_id = _zz_io_pop_payload_startAt[18 : 11];
  assign when_Stream_l1123 = (logic_pushing != logic_popping);
  assign logic_ptrDif = (logic_pushPtr_value - logic_popPtr_value);
  assign io_occupancy = {(logic_risingOccupancy && logic_ptrMatch),logic_ptrDif};
  assign io_availability = {((! logic_risingOccupancy) && logic_ptrMatch),_zz_io_availability};
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      logic_pushPtr_value <= 4'b0000;
      logic_popPtr_value <= 4'b0000;
      logic_risingOccupancy <= 1'b0;
      _zz_io_pop_valid <= 1'b0;
    end else begin
      logic_pushPtr_value <= logic_pushPtr_valueNext;
      logic_popPtr_value <= logic_popPtr_valueNext;
      _zz_io_pop_valid <= (logic_popPtr_valueNext == logic_pushPtr_value);
      if(when_Stream_l1123) begin
        logic_risingOccupancy <= logic_pushing;
      end
      if(io_flush) begin
        logic_risingOccupancy <= 1'b0;
      end
    end
  end

//Encryption end
endmodule
