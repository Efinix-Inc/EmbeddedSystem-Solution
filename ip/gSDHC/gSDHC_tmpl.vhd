--------------------------------------------------------------------------------
-- Copyright (C) 2013-2024 Efinix Inc. All rights reserved.              
--
-- This   document  contains  proprietary information  which   is        
-- protected by  copyright. All rights  are reserved.  This notice       
-- refers to original work by Efinix, Inc. which may be derivitive       
-- of other work distributed under license of the authors.  In the       
-- case of derivative work, nothing in this notice overrides the         
-- original author's license agreement.  Where applicable, the           
-- original license agreement is included in it's original               
-- unmodified form immediately below this header.                        
--                                                                       
-- WARRANTY DISCLAIMER.                                                  
--     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND        
--     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH               
--     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,  
--     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF          
--     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR    
--     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED       
--     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.           
--                                                                       
-- LIMITATION OF LIABILITY.                                              
--     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY       
--     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT    
--     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY   
--     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,      
--     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY    
--     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF      
--     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR   
--     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN    
--     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER    
--     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
--     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
--     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR            
--     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT   
--     APPLY TO LICENSEE.                                                
--
--------------------------------------------------------------------------------
------------- Begin Cut here for COMPONENT Declaration ------
component gSDHC is
port (
    sd_rst : in std_logic;
    sd_base_clk : in std_logic;
    sd_int : out std_logic;
    sd_cd_n : in std_logic;
    sd_wp : in std_logic;
    s_axi_awaddr : in std_logic_vector(9 downto 0);
    s_axi_aclk : in std_logic;
    s_axi_awready : out std_logic;
    s_axi_awvalid : in std_logic;
    s_axi_wdata : in std_logic_vector(31 downto 0);
    s_axi_wready : out std_logic;
    s_axi_wvalid : in std_logic;
    s_axi_bresp : out std_logic_vector(1 downto 0);
    s_axi_bvalid : out std_logic;
    s_axi_araddr : in std_logic_vector(9 downto 0);
    s_axi_bready : in std_logic;
    s_axi_arready : out std_logic;
    s_axi_arvalid : in std_logic;
    s_axi_rresp : out std_logic_vector(1 downto 0);
    s_axi_rdata : out std_logic_vector(31 downto 0);
    s_axi_rvalid : out std_logic;
    s_axi_rready : in std_logic;
    m_axi_awaddr : out std_logic_vector(31 downto 0);
    m_axi_awvalid : out std_logic;
    m_axi_clk : in std_logic;
    m_axi_awlen : out std_logic_vector(7 downto 0);
    m_axi_awready : in std_logic;
    m_axi_awsize : out std_logic_vector(2 downto 0);
    m_axi_awcache : out std_logic_vector(3 downto 0);
    m_axi_awlock : out std_logic_vector(1 downto 0);
    m_axi_awprot : out std_logic_vector(2 downto 0);
    m_axi_wlast : out std_logic;
    m_axi_wvalid : out std_logic;
    m_axi_wready : in std_logic;
    m_axi_bresp : in std_logic_vector(1 downto 0);
    m_axi_bvalid : in std_logic;
    m_axi_bready : out std_logic;
    m_axi_arvalid : out std_logic;
    m_axi_araddr : out std_logic_vector(31 downto 0);
    m_axi_arlen : out std_logic_vector(7 downto 0);
    m_axi_arsize : out std_logic_vector(2 downto 0);
    m_axi_arburst : out std_logic_vector(1 downto 0);
    m_axi_arprot : out std_logic_vector(2 downto 0);
    m_axi_arlock : out std_logic_vector(1 downto 0);
    m_axi_arcache : out std_logic_vector(3 downto 0);
    m_axi_arready : in std_logic;
    m_axi_rvalid : in std_logic;
    m_axi_rlast : in std_logic;
    m_axi_rresp : in std_logic_vector(1 downto 0);
    m_axi_rready : out std_logic;
    sd_clk_hi : out std_logic;
    sd_clk_lo : out std_logic;
    sd_cmd_i : in std_logic;
    sd_cmd_o : out std_logic;
    sd_cmd_oe : out std_logic;
    sd_dat_i : in std_logic_vector(3 downto 0);
    sd_dat_o : out std_logic_vector(3 downto 0);
    sd_dat_oe : out std_logic;
    m_axi_awburst : out std_logic_vector(1 downto 0);
    m_axi_wdata : out std_logic_vector(127 downto 0);
    m_axi_wstrb : out std_logic_vector(15 downto 0);
    m_axi_rdata : in std_logic_vector(127 downto 0);
    s_axi_wstrb : in std_logic_vector(3 downto 0)
);
end component gSDHC;

---------------------- End COMPONENT Declaration ------------
------------- Begin Cut here for INSTANTIATION Template -----
u_gSDHC : gSDHC
port map (
    sd_rst => sd_rst,
    sd_base_clk => sd_base_clk,
    sd_int => sd_int,
    sd_cd_n => sd_cd_n,
    sd_wp => sd_wp,
    s_axi_awaddr => s_axi_awaddr,
    s_axi_aclk => s_axi_aclk,
    s_axi_awready => s_axi_awready,
    s_axi_awvalid => s_axi_awvalid,
    s_axi_wdata => s_axi_wdata,
    s_axi_wready => s_axi_wready,
    s_axi_wvalid => s_axi_wvalid,
    s_axi_bresp => s_axi_bresp,
    s_axi_bvalid => s_axi_bvalid,
    s_axi_araddr => s_axi_araddr,
    s_axi_bready => s_axi_bready,
    s_axi_arready => s_axi_arready,
    s_axi_arvalid => s_axi_arvalid,
    s_axi_rresp => s_axi_rresp,
    s_axi_rdata => s_axi_rdata,
    s_axi_rvalid => s_axi_rvalid,
    s_axi_rready => s_axi_rready,
    m_axi_awaddr => m_axi_awaddr,
    m_axi_awvalid => m_axi_awvalid,
    m_axi_clk => m_axi_clk,
    m_axi_awlen => m_axi_awlen,
    m_axi_awready => m_axi_awready,
    m_axi_awsize => m_axi_awsize,
    m_axi_awcache => m_axi_awcache,
    m_axi_awlock => m_axi_awlock,
    m_axi_awprot => m_axi_awprot,
    m_axi_wlast => m_axi_wlast,
    m_axi_wvalid => m_axi_wvalid,
    m_axi_wready => m_axi_wready,
    m_axi_bresp => m_axi_bresp,
    m_axi_bvalid => m_axi_bvalid,
    m_axi_bready => m_axi_bready,
    m_axi_arvalid => m_axi_arvalid,
    m_axi_araddr => m_axi_araddr,
    m_axi_arlen => m_axi_arlen,
    m_axi_arsize => m_axi_arsize,
    m_axi_arburst => m_axi_arburst,
    m_axi_arprot => m_axi_arprot,
    m_axi_arlock => m_axi_arlock,
    m_axi_arcache => m_axi_arcache,
    m_axi_arready => m_axi_arready,
    m_axi_rvalid => m_axi_rvalid,
    m_axi_rlast => m_axi_rlast,
    m_axi_rresp => m_axi_rresp,
    m_axi_rready => m_axi_rready,
    sd_clk_hi => sd_clk_hi,
    sd_clk_lo => sd_clk_lo,
    sd_cmd_i => sd_cmd_i,
    sd_cmd_o => sd_cmd_o,
    sd_cmd_oe => sd_cmd_oe,
    sd_dat_i => sd_dat_i,
    sd_dat_o => sd_dat_o,
    sd_dat_oe => sd_dat_oe,
    m_axi_awburst => m_axi_awburst,
    m_axi_wdata => m_axi_wdata,
    m_axi_wstrb => m_axi_wstrb,
    m_axi_rdata => m_axi_rdata,
    s_axi_wstrb => s_axi_wstrb
);

------------------------ End INSTANTIATION Template ---------
