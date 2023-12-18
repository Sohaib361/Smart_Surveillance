from ultralytics import YOLO
import cv2
import numpy as np
from sort.sort import Sort
from util5 import get_car, read_license_plate, write_csv, is_valid_license_plate

results = {}
mot_tracker = Sort()

# load models
coco_model = YOLO('yolov8n.pt')
license_plate_detector = YOLO('license_plate_detector.pt')

# open camera
cap = cv2.VideoCapture(0)

# set camera resolution
cap.set(3, 1280)
cap.set(4, 720)

frame_nmr = -1

while True:
    ret, frame = cap.read()
    if not ret:
        break

    frame_nmr += 1
    detections = coco_model(frame)[0]

    detections_ = []
    for detection in detections.boxes.data.tolist():
        x1, y1, x2, y2, score, class_id = detection
        if int(class_id) in [2, 3, 5, 7]:
            detections_.append([x1, y1, x2, y2, score])

    track_ids = mot_tracker.update(np.asarray(detections_)) if len(detections_) > 0 else []

    license_plates = license_plate_detector(frame)[0]
    for license_plate in license_plates.boxes.data.tolist():
        x1, y1, x2, y2, score, class_id = license_plate
        xcar1, ycar1, xcar2, ycar2, car_id = get_car(license_plate, track_ids)

        if car_id != -1:
            license_plate_crop = frame[int(y1):int(y2), int(x1): int(x2)]
            license_plate_text, license_plate_text_score = read_license_plate(license_plate_crop)

            if license_plate_text is not None and is_valid_license_plate(license_plate_text) and 6 <= len(license_plate_text) <= 8:
                license_plate_text_upper = license_plate_text.upper()  # Convert to uppercase
                if frame_nmr not in results:
                    results[frame_nmr] = {}
                results[frame_nmr][car_id] = {'car': {'bbox': [xcar1, ycar1, xcar2, ycar2]},
                                              'license_plate': {'bbox': [x1, y1, x2, y2],
                                                                'text': license_plate_text_upper,
                                                                'bbox_score': score,
                                                                'text_score': license_plate_text_score}}

                # Draw bounding box for the license plate
                cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), (0, 255, 0), 2)
                cv2.putText(frame, f"License Plate: {license_plate_text_upper}", (int(x1), int(y1) - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

                # Update the CSV file immediately
                write_csv(results, './test2.csv')
                print("writen in csv file")

    # Draw bounding boxes for vehicles
    for car_id, car_data in results.get(frame_nmr, {}).items():
        xcar1, ycar1, xcar2, ycar2 = map(int, car_data['car']['bbox'])
        cv2.rectangle(frame, (xcar1, ycar1), (xcar2, ycar2), (255, 0, 0), 2)

    cv2.imshow('Camera Feed', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()

print("CSV file updated.")