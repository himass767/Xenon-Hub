import pyautogui
import time
import random

# Cài đặt phím bấm (F là mặc định trong Blade Ball)
KEY_TO_PRESS = 'f' 

print("Mở cửa sổ Game lên! Script sẽ bắt đầu sau 5 giây...")
time.sleep(5)

try:
    print("Đang chạy Auto Parry... Nhấn Ctrl+C để dừng.")
    while True:
        # Nhấn phím F
        pyautogui.press(KEY_TO_PRESS)
        
        # Tạo độ trễ ngẫu nhiên từ 0.05 đến 0.1 giây 
        # Việc ngẫu nhiên hóa giúp bạn khó bị hệ thống phát hiện hơn
        delay = random.uniform(0.05, 0.1)
        time.sleep(delay)
        
except KeyboardInterrupt:
    print("\nĐã dừng Script.")
