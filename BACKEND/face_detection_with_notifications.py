import cv2
import dlib
from flask import Flask, request, jsonify
from flask_restful import Resource, Api
import base64
import numpy as np
import time

# Initialize the dlib face detector
detector = dlib.get_frontal_face_detector()

app = Flask(__name__)
api = Api(app)

# Initialize the camera
camera = cv2.VideoCapture(0)  # 0 represents the default camera (usually the built-in webcam)

# Create a resource for handling face detection notifications
class FaceDetection(Resource):
    def post(self):
        # Handle the notification when a face is detected
        try:
            time.sleep(1)  # Add a delay of 1 second between frame captures

            _, frame = camera.read()  # Read a frame from the camera

            # Convert the frame to grayscale for face detection
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

            # Adjust the face detection threshold
            faces = detector(gray, 1)  # Increase the threshold (1) for stricter detection

            if len(faces) > 0:
                # Handle the notification when a face is detected
                print(f"Detected {len(faces)} faces.")
                for i, face in enumerate(faces):
                    print(f"Face {i}: Confidence {face.confidence}")

                # Encode the frame as base64 to send back to the app
                _, buffer = cv2.imencode('.jpg', frame)
                frame_base64 = base64.b64encode(buffer).decode('utf-8')
                return jsonify({"message": "Face Detected", "image": frame_base64})

            return jsonify({"message": "No Face Detected"})

        except Exception as e:
            return jsonify({"error": str(e)})


# Add the FaceDetection resource to the API with the '/notification' endpoint
api.add_resource(FaceDetection, '/notification')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
