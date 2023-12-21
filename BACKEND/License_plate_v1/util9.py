from ultralytics import YOLO#updated code with flask
import cv2
import numpy as np
from sort.sort import Sort
from util6 import get_car, read_license_plate, write_csv, is_valid_license_plate
from collections import Counter
import psycopg2
import csv

results = {}
mot_tracker = Sort()

# load models
coco_model = YOLO('yolov8n.pt')
license_plate_detector = YOLO('license_plate_detector.pt')

# open camera
cap = cv2.VideoCapture(1)  # Use Camera 1


def get_owner_info(license_plate_number):
    conn = None
    try:
        conn = psycopg2.connect(
            host='192.168.181.218',
            database='postgres',
            user='postgres',
            password='postgres'
        )
        cur = conn.cursor()
        cur.execute("""
            SELECT u.full_name, u.CNIC, u.phone_number
            FROM user_info u
            JOIN vehicle_info v ON u.license_plate = v.owner_license_plate
            WHERE u.license_plate = %s;
        """, (license_plate_number,))
        owner_info = cur.fetchone()
        return owner_info
    except psycopg2.Error as e:
        print("Database error:", e)
    finally:
        if conn:
            conn.close()


def write_registered_owner(owner_info, license_plate_text):
    with open('registered_owner.csv', 'a', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([license_plate_text] + list(owner_info))


# set camera resolution
cap.set(3, 1280)
cap.set(4, 720)

frame_nmr = -1

# Initialize variables to keep track of the most repeated license plate
current_car_id = None
license_plate_counter = Counter()

confidence_threshold = 0.5  # Set your desired confidence threshold

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

            if (
                license_plate_text is not None
                and is_valid_license_plate(license_plate_text)
                and confidence_threshold <= score
                and 5 <= len(license_plate_text) <= 7
            ):
                license_plate_text_upper = license_plate_text.upper()

                # Convert to uppercase
                if frame_nmr not in results:
                    results[frame_nmr] = {}
                results[frame_nmr][car_id] = {
                    'car': {'bbox': [xcar1, ycar1, xcar2, ycar2]},
                    'license_plate': {
                        'bbox': [x1, y1, x2, y2],
                        'text': license_plate_text_upper,
                        'bbox_score': score,
                        'text_score': license_plate_text_score,
                    },
                }

                # Draw bounding box for the license plate
                cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), (0, 255, 0), 2)
                cv2.putText(
                    frame,
                    f"License Plate: {license_plate_text_upper}",
                    (int(x1), int(y1) - 10),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.5,
                    (0, 255, 0),
                    2,
                )

                # Update the CSV file immediately
                write_csv(results, './test2.csv')
                print("Writing to CSV file...")

                # Update most repeated license plate for each car_id
                if car_id != current_car_id:
                    if current_car_id is not None:
                        most_common_license_plate, count = license_plate_counter.most_common(1)[0]
                        # Store the most repeated license plate in a new CSV file
                        with open('most_repeated_license_plates.csv', 'a') as f:
                            f.write(f'{current_car_id},{most_common_license_plate},{count}\n')
                        owner_info = get_owner_info(license_plate_text_upper)
                        if owner_info:
                            print(f"Owner Info: {owner_info}")
                            # Write owner info and license plate to registered_owner.csv
                            write_registered_owner(owner_info, license_plate_text_upper)
                    current_car_id = car_id
                    license_plate_counter.clear()
                license_plate_counter[license_plate_text_upper] += 1

    # Draw bounding boxes for vehicles
    for car_id, car_data in results.get(frame_nmr, {}).items():
        xcar1, ycar1, xcar2, ycar2 = map(int, car_data['car']['bbox'])
        cv2.rectangle(frame, (xcar1, ycar1), (xcar2, ycar2), (255, 0, 0), 2)

    cv2.imshow('Camera Feed', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Write the last most repeated license plate to the new CSV file
if current_car_id is not None:
    most_common_license_plate, count = license_plate_counter.most_common(1)[0]
    with open('most_repeated_license_plates.csv', 'a') as f:
        f.write(f'{current_car_id},{most_common_license_plate},{count}\n')

cap.release()
cv2.destroyAllWindows()

print("CSV file updated.")
print("Most repeated license plates stored in most_repeated_license_plates.csv.")