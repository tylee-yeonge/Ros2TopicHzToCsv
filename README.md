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

#### 다중 토픽 동시 모니터링 (고급 사용법)

**1. make_topics_logger.sh 사용**
여러 토픽을 동시에 모니터링하려면 `make_topics_logger.sh` 스크립트를 사용하세요:

```bash
chmod +x make_topics_logger.sh
./make_topics_logger.sh
```

이 스크립트는 `topic_list.txt` 파일에서 설정을 읽어 여러 토픽들을 백그라운드에서 동시에 모니터링합니다.

**2. 토픽 목록 설정 (topic_list.txt)**
모니터링할 토픽을 설정하려면 `topic_list.txt` 파일을 편집하세요:

```txt
# 주석은 #으로 시작합니다
# 형식: <토픽이름> <메시지타입>
front/scan sensor_msgs/msg/LaserScan
rear/scan sensor_msgs/msg/LaserScan
rs_camera_1/color/image_raw sensor_msgs/msg/Image
```

**3. 백그라운드 실행**
터미널을 닫아도 모니터링이 계속되도록 백그라운드에서 실행하려면:

```bash
nohup ./make_topics_logger.sh &
```

**백그라운드 프로세스 관리:**
- 실행 중인 프로세스 확인: `ps aux | grep topic_logger`
- 특정 PID 종료: `kill <PID번호>`
- 모든 topic_logger 프로세스 종료: `pkill -f topic_logger.sh`

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

### 파일 설명
- `topic_logger.sh`: 단일 토픽 모니터링 스크립트
- `make_topics_logger.sh`: 다중 토픽 동시 모니터링 스크립트
- `topic_list.txt`: 모니터링할 토픽 목록 설정 파일
- `background_execution.txt`: 백그라운드 실행 명령어 예시
- `TopicHzToCsv.py`: 실제 토픽 주파수 측정 및 CSV 저장 로직

### 출력 CSV 포맷
생성된 CSV 파일은 다음 형식으로 저장됩니다:
- 첫 두 줄: 토픽 이름과 메시지 타입 정보
- 데이터 열: timestamp (YYYY-MM-DD HH:MM:SS 형식), hz (정수로 반올림된 주파수)

