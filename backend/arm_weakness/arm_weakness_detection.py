from flask import Flask, request, jsonify
import cv2
import mediapipe as mp
import numpy as np
import tempfile
import os

app = Flask(__name__)
# Initialize MediaPipe Pose.
mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=False)  # Use for video processing.
mp_drawing = mp.solutions.drawing_utils

ANGLE_THRESHOLD = 75  # Threshold angle for determining weakness.

def calculate_angle(a, b, c):
    """Calculate the angle (in degrees) between three landmarks."""
    a = np.array([a.x, a.y])
    b = np.array([b.x, b.y])
    c = np.array([c.x, c.y])
    radians = np.arctan2(c[1]-b[1], c[0]-b[0]) - np.arctan2(a[1]-b[1], a[0]-b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    if angle > 180:
        angle = 360 - angle
    return angle

@app.route('/detect', methods=['POST'])
def detect():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    file = request.files['file']

    # Save the video to a temporary file.
    temp_video = tempfile.NamedTemporaryFile(delete=False, suffix='.mp4')
    file.save(temp_video.name)
    temp_video.close()

    cap = cv2.VideoCapture(temp_video.name)
    left_angles = []
    right_angles = []

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Rotate frame 90 degrees clockwise.
        frame = cv2.rotate(frame, cv2.ROTATE_90_CLOCKWISE)

        # Process the frame using MediaPipe Pose.
        img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(img_rgb)

        if results.pose_landmarks:
            try:
                left_shoulder = results.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_SHOULDER]
                left_elbow = results.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_ELBOW]
                left_wrist = results.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_WRIST]
                right_shoulder = results.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_SHOULDER]
                right_elbow = results.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_ELBOW]
                right_wrist = results.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_WRIST]

                left_angle = calculate_angle(left_shoulder, left_elbow, left_wrist)
                right_angle = calculate_angle(right_shoulder, right_elbow, right_wrist)

                left_angles.append(left_angle)
                right_angles.append(right_angle)
            except Exception as e:
                print("Error processing landmarks:", e)

    cap.release()
    os.unlink(temp_video.name)

    if left_angles and right_angles:
        avg_left_angle = float(np.mean(left_angles))
        avg_right_angle = float(np.mean(right_angles))
        left_weak = bool(avg_left_angle < ANGLE_THRESHOLD)
        right_weak = bool(avg_right_angle < ANGLE_THRESHOLD)
        status = "Arm movement detected"
    else:
        avg_left_angle = None
        avg_right_angle = None
        left_weak = False
        right_weak = False
        status = "No arm movement detected"

    analysis = {
        "status": status,
        "avg_left_angle": avg_left_angle,
        "avg_right_angle": avg_right_angle,
        "left_weakness": left_weak,
        "right_weakness": right_weak
    }

    return jsonify(analysis)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=False)






# from flask import Flask, request, jsonify
# import cv2
# import mediapipe as mp
# import numpy as np
# import tempfile
# import os

# app = Flask(__name__)

# # Initialize MediaPipe Pose.
# mp_pose = mp.solutions.pose
# pose = mp_pose.Pose(static_image_mode=False)
# mp_drawing = mp.solutions.drawing_utils

# ANGLE_THRESHOLD = 50  # Threshold for weakness detection.
# SPEED_THRESHOLD = 3.0  # Minimum angle change per frame (lower means weakness).
# SMOOTHNESS_THRESHOLD = 5.0  # High deviation in movement = weakness.

# def calculate_angle(a, b, c):
#     """Calculate the angle (in degrees) between three landmarks."""
#     a, b, c = np.array([a.x, a.y]), np.array([b.x, b.y]), np.array([c.x, c.y])
#     radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
#     angle = np.abs(radians * 180.0 / np.pi)
#     return 360 - angle if angle > 180 else angle

# @app.route('/detect', methods=['POST'])
# def detect():
#     if 'file' not in request.files:
#         return jsonify({'error': 'No file provided'}), 400
    
#     file = request.files['file']

#     # Save the video to a temporary file.
#     temp_video = tempfile.NamedTemporaryFile(delete=False, suffix='.mp4')
#     file.save(temp_video.name)
#     temp_video.close()

#     cap = cv2.VideoCapture(temp_video.name)

#     left_angles, right_angles = [], []
#     left_speeds, right_speeds = [], []

#     prev_left_angle, prev_right_angle = None, None

#     while True:
#         ret, frame = cap.read()
#         if not ret:
#             break

#         # Rotate frame 90 degrees clockwise.
#         frame = cv2.rotate(frame, cv2.ROTATE_90_CLOCKWISE)

#         # Process the frame using MediaPipe Pose.
#         img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
#         results = pose.process(img_rgb)

#         if results.pose_landmarks:
#             try:
#                 # Extract landmarks
#                 left_shoulder = results.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_SHOULDER]
#                 left_elbow = results.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_ELBOW]
#                 left_wrist = results.pose_landmarks.landmark[mp_pose.PoseLandmark.LEFT_WRIST]

#                 right_shoulder = results.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_SHOULDER]
#                 right_elbow = results.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_ELBOW]
#                 right_wrist = results.pose_landmarks.landmark[mp_pose.PoseLandmark.RIGHT_WRIST]

#                 # Calculate elbow angles
#                 left_angle = calculate_angle(left_shoulder, left_elbow, left_wrist)
#                 right_angle = calculate_angle(right_shoulder, right_elbow, right_wrist)

#                 left_angles.append(left_angle)
#                 right_angles.append(right_angle)

#                 # Calculate movement speed (angle change per frame)
#                 if prev_left_angle is not None:
#                     left_speed = abs(left_angle - prev_left_angle)
#                     right_speed = abs(right_angle - prev_right_angle)
#                     left_speeds.append(left_speed)
#                     right_speeds.append(right_speed)

#                 prev_left_angle, prev_right_angle = left_angle, right_angle

#             except Exception as e:
#                 print("Error processing landmarks:", e)

#     cap.release()
#     os.unlink(temp_video.name)

#     if left_angles and right_angles:
#         avg_left_angle = float(np.mean(left_angles))
#         avg_right_angle = float(np.mean(right_angles))
#         avg_left_speed = float(np.mean(left_speeds)) if left_speeds else 0
#         avg_right_speed = float(np.mean(right_speeds)) if right_speeds else 0
#         left_smoothness = float(np.std(left_angles))  # Smoothness: deviation of angles
#         right_smoothness = float(np.std(right_angles))

#         # Weakness conditions
#         left_weak = avg_left_angle < ANGLE_THRESHOLD or avg_left_speed < SPEED_THRESHOLD or left_smoothness > SMOOTHNESS_THRESHOLD
#         right_weak = avg_right_angle < ANGLE_THRESHOLD or avg_right_speed < SPEED_THRESHOLD or right_smoothness > SMOOTHNESS_THRESHOLD
#         status = "Arm movement detected"
#     else:
#         avg_left_angle = avg_right_angle = None
#         avg_left_speed = avg_right_speed = None
#         left_smoothness = right_smoothness = None
#         left_weak = right_weak = False
#         status = "No arm movement detected"

#     analysis = {
#         "status": status,
#         "avg_left_angle": avg_left_angle,
#         "avg_right_angle": avg_right_angle,
#         "avg_left_speed": avg_left_speed,
#         "avg_right_speed": avg_right_speed,
#         "left_smoothness": left_smoothness,
#         "right_smoothness": right_smoothness,
#         "left_weakness": left_weak,
#         "right_weakness": right_weak
#     }

#     return jsonify(analysis)

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=5001, debug=False)
