# Sensors

This guide show on how to run the sensors application on baremetal. 

## sensor_DS3231_rtc
This example design utilize I2C peripheral to communicate with DS3231 RTC sensor and run it on baremetal.

### Supported Feature		
* Time Keeping
* 12/24hr Time System
* Temperature Sensor
* Alarms 1 and 2	
* Power Failure Check and Clear

* Note: Please set ENABLE_SEMIHOSTING_PRINT to 0 in bsp.h

###  Usage
1. In Efinity RISC-V IDE, open the main.c from sensor_DS3231_rtc.
2. Run the project by right click sensor_DS3231_rtc.launch where xxx can be as trion or titanium run as sensor_DS3231_rtc.

There are two ways of using RTC in the example design:
* At default setting, main menu is enabled to allow user to configure time, alarm, etc in terminal. This required the user to enabled UART at first place.

    ![RTC](../images/RTC.png)

* User can also disable mainu menu to allow the time shown in terminal every few seconds depending on the configuration. 

    ![RTC-demo](../images/RTC-Demo.png)
    

