////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#pragma once

#include "bsp.h"
#include "device_config.h"
#include "io.h"

#define EXAMPLE_APB3_SLV_REG0_OFFSET 	0
#define EXAMPLE_APB3_SLV_REG1_OFFSET 	4
#define EXAMPLE_APB3_SLV_REG2_OFFSET 	8
#define EXAMPLE_APB3_SLV_REG3_OFFSET 	12
#define EXAMPLE_APB3_SLV_REG4_OFFSET 	16
#define EXAMPLE_APB3_SLV_REG5_OFFSET 	20


    struct ctrl_reg {
    	unsigned int lfsr_stop	        :1;
    	unsigned int reserved			:31;
    
    }apb3_ctrl_reg;
    
    struct ctrl_reg2 {
		unsigned int mem_start	        :1;
		unsigned int rsv0               :7;
		unsigned int ilen               :8;
		unsigned int rsv1   			:16;

	}owrite_crtl;


    u32 apb3_read(u32 slave)
    {
    	return read_u32(slave+EXAMPLE_APB3_SLV_REG0_OFFSET);
    	
    }
    
    void apb3_ctrl_write(u32 slave, struct ctrl_reg *cfg)
    {
        write_u32(*(int *)cfg, slave+EXAMPLE_APB3_SLV_REG1_OFFSET);
    }
    
    void cfg_write(u32 slave, struct ctrl_reg2 *cfg)
	{
		write_u32(*(int *)cfg, slave+EXAMPLE_APB3_SLV_REG3_OFFSET);
	}

	void cfg_data(u32 slave, u32 data)
	{
		write_u32(data, slave+EXAMPLE_APB3_SLV_REG4_OFFSET);
	}

	void cfg_addr(u32 slave, u32  addr)
	{
		write_u32(addr, slave+EXAMPLE_APB3_SLV_REG5_OFFSET);
	}
    
    void apb3_ctrl_write(u32 slave, struct ctrl_reg *cfg);
    void cfg_write(u32 slave, struct ctrl_reg2 *cfg);
	void cfg_data(u32 slave, u32 data);
	void cfg_addr(u32 slave, u32 addr);
    u32 apb3_read(u32 slave);


