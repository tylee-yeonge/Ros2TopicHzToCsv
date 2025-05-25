# Ros2TopicHzToCsv

### 개요
이 도구는 ROS2 토픽의 발행 주파수(Hz)를 모니터링하고 CSV 파일로 저장합니다.

### 필수 요구사항
- ROS2 설치
- Python 3

### 설치 방법
1. 이 저장소를 클론합니다:
   ```bash
   git clone https://github.com/your-username/Ros2TopicHzToCsv.git
   cd Ros2TopicHzToCsv
   ```

### 실행 방법

#### 쉘 스크립트 사용 (권장)
```bash
./topic_logger.sh <토픽이름> <메시지타입>
```

예시:
```bash
./topic_logger.sh sensor_msgs/msg/Imu /imu
```

#### 직접 Python 스크립트 실행
```bash
python3 TopicHzToCsv.py --ros-args -p topic_name:=/<토픽이름> -p message_type:=<메시지타입> -p csv_filename:="<파일명>.csv" -p window_size:=<윈도우크기>
```

예시:
```bash
python3 TopicHzToCsv.py --ros-args -p topic_name:=/imu -p message_type:=sensor_msgs/msg/Imu -p csv_filename:="imu_hz_data.csv" -p window_size:=20
```

### 매개변수 설명
- `topic_name`: 모니터링할 ROS2 토픽 이름
- `message_type`: 토픽의 메시지 타입 (예: std_msgs/msg/String)
- `csv_filename`: 결과를 저장할 CSV 파일 이름 (기본값: topic_hz_data.csv)
- `window_size`: 주파수 계산에 사용할 메시지 윈도우 크기 (기본값: 10)

### 출력 CSV 포맷
생성된 CSV 파일은 다음 형식으로 저장됩니다:
- 첫 두 줄: 토픽 이름과 메시지 타입 정보
- 데이터 열: timestamp (YYYY-MM-DD HH:MM:SS 형식), hz (정수로 반올림된 주파수)

