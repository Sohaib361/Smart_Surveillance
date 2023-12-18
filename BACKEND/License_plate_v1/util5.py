import re
import easyocr

# Initialize the OCR reader
reader = easyocr.Reader(['en'], gpu=False)# Working good

def is_valid_license_plate(license_plate_text):
    # Check if the license plate contains only alphanumeric characters
    return bool(re.match("^[a-zA-Z0-9]+$", license_plate_text))

def write_csv(results, output_path):
    with open(output_path, 'w') as f:
        f.write('frame_nmr,car_id,car_bbox,license_plate_bbox,license_plate_bbox_score,license_text\n')

        for frame_nmr, frame_54data in results.items():
            for car_id, car_data in frame_data.items():
                car_bbox = '[{} {} {} {}]'.format(*car_data['car']['bbox'])
                license_data = car_data['license_plate']
                license_bbox = '[{} {} {} {}]'.format(*license_data['bbox'])
                bbox_score = license_data['bbox_score']
                license_text = license_data['text']

                if is_valid_license_plate(license_text) and 6 <= len(license_text) <= 8:
                    f.write(f'{frame_nmr},{car_id},{car_bbox},{license_bbox},{bbox_score},{license_text}\n')

def read_license_plate(license_plate_crop):
    detections = reader.readtext(license_plate_crop, detail=1)

    # Concatenate text from multiple lines excluding the digits at the top right corner
    filtered_text = ''
    for d in detections:
        _, text, _ = d
        # Exclude digits at the top right corner
        if not (text.isdigit() and int(text) > 0 and len(text) == 2):
            filtered_text += text

    # Limit the length of the license plate
    filtered_text = ''.join(char.upper() for char in filtered_text if char.isalnum())[:7]

    return filtered_text, None

def get_car(license_plate, vehicle_track_ids):
    x1, y1, x2, y2, _, _ = license_plate
    for xcar1, ycar1, xcar2, ycar2, car_id in vehicle_track_ids:
        if x1 > xcar1 and y1 > ycar1 and x2 < xcar2 and y2 < ycar2:
            return xcar1, ycar1, xcar2, ycar2, car_id
    return -1, -1, -1, -1, -1
















































































































































