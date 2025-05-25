#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from rclpy.qos import QoSProfile, ReliabilityPolicy, HistoryPolicy
import csv
import os
import importlib
import datetime # 시간 형식 변환을 위해 필요

class TopicHzToCsv(Node):
    def __init__(self):
        super().__init__('topic_hz_to_csv')
        self.declare_parameter('topic_name', '/your/topic')
        self.declare_parameter('message_type', 'std_msgs/msg/String')
        self.declare_parameter('csv_filename', 'topic_hz_data.csv')
        self.declare_parameter('window_size', 10)

        self.topic_name = self.get_parameter('topic_name').get_parameter_value().string_value
        self.message_type_str = self.get_parameter('message_type').get_parameter_value().string_value
        self.csv_filename = self.get_parameter('csv_filename').get_parameter_value().string_value
        self.window_size = self.get_parameter('window_size').get_parameter_value().integer_value

        self.message_times_ns = []
        self.hz = 0.0 # hz는 내부적으로 float으로 계산

        # 메시지 타입 동적 임포트
        try:
            module_parts = self.message_type_str.split('/')
            if len(module_parts) == 3:
                package_name, module_name, type_name = module_parts
                msg_module = importlib.import_module(f"{package_name}.{module_name}")
                self.msg_type = getattr(msg_module, type_name)
                self.get_logger().info(f"Successfully imported message type: {self.msg_type.__name__} from {package_name}.{module_name}")
            else:
                self.get_logger().error(f"Invalid message type format: {self.message_type_str}. Expected 'pkg/module/Type'.")
                raise ImportError("Invalid message type format")
        except (ImportError, AttributeError, IndexError) as e:
            self.get_logger().error(f"Could not import message type '{self.message_type_str}': {e}")
            self.msg_type = None

        # CSV 파일 초기화
        file_exists = os.path.exists(self.csv_filename)
        is_empty = file_exists and os.path.getsize(self.csv_filename) == 0

        if not file_exists or is_empty:
            with open(self.csv_filename, mode='w', newline='') as csv_file:
                csv_writer = csv.writer(csv_file)
                csv_file.write(f"# Topic: {self.topic_name}\n")
                csv_file.write(f"# Message Type: {self.message_type_str}\n")
                csv_writer.writerow(['timestamp', 'hz']) # 헤더 이름 변경 고려 (선택 사항)
            self.get_logger().info(f"Created new CSV file: {self.csv_filename} with header.")
        else:
            self.get_logger().info(f"Appending to existing CSV file: {self.csv_filename}")

        if self.msg_type:
            qos_profile = QoSProfile(
                reliability=ReliabilityPolicy.BEST_EFFORT,
                history=HistoryPolicy.KEEP_LAST,
                depth=1
            )
            self.subscription = self.create_subscription(
                self.msg_type,
                self.topic_name,
                self.listener_callback,
                qos_profile
            )
            self.get_logger().info(f"Subscribing to topic: {self.topic_name} with type {self.message_type_str}")
            self.get_logger().info(f"Saving data to: {self.csv_filename}")
            self.get_logger().info(f"Frequency calculation window size: {self.window_size} messages")

            # CSV 저장을 위한 타이머 (1초마다 save_data_callback 호출)
            self.save_timer = self.create_timer(1.0, self.save_data_callback)
        else:
            self.get_logger().error("Subscription not created due to message type import failure.")

    def listener_callback(self, msg):
        current_time_ns = self.get_clock().now().nanoseconds
        self.message_times_ns.append(current_time_ns)
        if len(self.message_times_ns) > self.window_size:
            self.message_times_ns.pop(0)

        if len(self.message_times_ns) >= 2:
            time_diff_ns = self.message_times_ns[-1] - self.message_times_ns[0]
            if time_diff_ns > 0:
                time_diff_s = time_diff_ns / 1e9
                self.hz = (len(self.message_times_ns) - 1) / time_diff_s
            else:
                self.hz = 0.0
        else:
            self.hz = 0.0

    def save_data_callback(self):
        if not self.msg_type:
            return

        ros_time_now = self.get_clock().now()
        seconds, _ = ros_time_now.seconds_nanoseconds()

        # POSIX 타임스탬프(초)를 시스템의 로컬 시간대 기준의 datetime 객체로 변환
        dt_object_local = datetime.datetime.fromtimestamp(seconds)
        
        # 로컬 datetime 객체를 'YYYY-MM-DD HH:MM:SS' 형식의 문자열로 포맷
        formatted_ros_timestamp = dt_object_local.strftime('%Y-%m-%d %H:%M:%S')

        hz_rounded_int = round(self.hz)

        with open(self.csv_filename, mode='a', newline='') as csv_file:
            csv_writer = csv.writer(csv_file)
            # 헤더를 'timestamp'로 변경했다면 여기서도 일관성 유지 가능
            csv_writer.writerow([formatted_ros_timestamp, hz_rounded_int]) 
        # 로그 메시지에도 로컬 시간으로 표시됨
        self.get_logger().info(f"Timestamp (Local): {formatted_ros_timestamp}, Hz: {hz_rounded_int}", throttle_duration_sec=5.0)


def main(args=None):
    rclpy.init(args=args)
    topic_hz_to_csv_node = TopicHzToCsv()
    if topic_hz_to_csv_node.msg_type is None:
        topic_hz_to_csv_node.get_logger().fatal("Failed to initialize node due to message type error. Shutting down.")
    else:
        try:
            rclpy.spin(topic_hz_to_csv_node)
        except KeyboardInterrupt:
            topic_hz_to_csv_node.get_logger().info('Keyboard interrupt, shutting down.')
        except Exception as e:
            topic_hz_to_csv_node.get_logger().error(f"An error occurred during spin: {e}")
    
    if rclpy.ok():
        if hasattr(topic_hz_to_csv_node, 'msg_type'): 
             if topic_hz_to_csv_node.msg_type is not None :
                topic_hz_to_csv_node.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()