onerror {quit -f}
vlib work
vlog +define+SIM+SIM_MODE+EFX_SIM -sv -f ./prj.f
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./sim_modules.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./tb_soc.v
vsim -voptargs="+acc" -t ns work.tb_soc
run -all
