import socket
import numpy as np
import cv2
import time

WIDTH, HEIGHT = 640,640
FRAME_SIZE = WIDTH * HEIGHT * 3
PACKET_SIZE = 1400
MAX_PACKETS = (FRAME_SIZE + PACKET_SIZE - 1) // PACKET_SIZE

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 10*1024*1024)  # larger buffer
sock.bind(("0.0.0.0", 5005))
import time

frame_count = 0
fps = 0
last_time = time.time()
current_frame = None
current_frame_id = None
packet_received = 0

last_frame_time = time.time()
fps = 0

print("Listening for video UDP packets...")

while True:
    data, addr = sock.recvfrom(2048)
    if len(data) < 4: 
        continue

    frame_id = data[0] | (data[1] << 8)
    pkt_id = data[2] | (data[3] << 8)
    payload = data[4:]

    if frame_id != current_frame_id:
        current_frame = bytearray(FRAME_SIZE)
        current_frame_id = frame_id
        packet_received = 0

    offset = pkt_id * PACKET_SIZE
    current_frame[offset : offset + len(payload)] = payload
    packet_received += 1

    if packet_received == MAX_PACKETS:
        img = np.frombuffer(current_frame, dtype=np.uint8).reshape((HEIGHT, WIDTH, 3))
        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
        cv2.imshow("Video Stream", img)
        cv2.waitKey(1)
        
        # --- FPS calculation ---
        frame_count += 1
        now = time.time()
        if now - last_time >= 1.0:
            fps = frame_count / (now - last_time)
            print(f"FPS: {fps:.2f}")
            frame_count = 0
            last_time = now

        packet_received = 0
