# Vision

This guide show on how to run the vision application on baremetal. 
Below are the vision-related application:
  - [cameraStreaming_HDMI](ug_vision.md#cameraStreaming_HDMI)
  
## cameraStreaming_HDMI
The cameraStreaming_HDMI example design demonstrates a use case of hardware/software co-design for video processing within a camera and display system. This design showcases how users can control the FPGA hardware via software, enabling different hardware acceleration functions by modifying the firmware on the RISC-V processor.

Though the example focuses on video filtering functions, users can replace these with their own hardware acceleration blocks. This design provides an effective framework for accelerating computationally intensive functions in hardware, while using RISC-V software to manage and control the acceleration.

List of implemented ISP algorithms (available for both SW functions and HW modules):
- RGB to grayscale conversion
- Sobel edge detection -> Performs edge detection.
- Binary dilation      -> Removes line detail by ANDing all windowed pixels.
- Binary erosion       -> Strengthens line detail by ORing all windowed pixels. 

![evsoc-demo-output.png](../images/evsoc-demo-output.png)