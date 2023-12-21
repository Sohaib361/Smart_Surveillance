import psycopg2
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
import hashlib
from sqlalchemy import ForeignKey

app = Flask(__name__)
CORS(app)


# Database connection setup
def get_db_connection():
    conn = psycopg2.connect(
        host='localhost',
        database='postgres',
        user='postgres',
        password='postgres'
    )
    return conn


@app.route('/')
def hello_world():
    return 'Welcome!'

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/postgres'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)


# UserCredentials model
class UserCredentials(db.Model):
    __tablename__ = 'user_credentials'
    CNIC = db.Column(db.String(13), primary_key=True)  # Set CNIC as the primary key
    username = db.Column(db.String(100), unique=True, nullable=False)
    password_hash = db.Column(db.String(64), nullable=False)

# UserInfo model
class UserInfo(db.Model):
    __tablename__ = 'user_info'

    CNIC = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(30), nullable=False)
    license_plate = db.Column(db.String(20), unique=True, nullable=False)
    gender = db.Column(db.String(10), nullable=False)
    age = db.Column(db.Integer, nullable=False)
    phone_number = db.Column(db.String(20), nullable=False)
    address = db.Column(db.Text, nullable=False)
    email = db.Column(db.String(30), unique=True, nullable=False)
    photo = db.Column(db.LargeBinary, nullable=False)

    # Define a one-to-many relationship with vehicle_info
    vehicles = db.relationship('VehicleInfo', backref='owner', lazy=True)


# VehicleInfo model
class VehicleInfo(db.Model):
    __tablename__ = 'vehicle_info'

    owner_license_plate = db.Column(db.String(20), ForeignKey('user_info.license_plate'), primary_key=True)
    vehicle_type = db.Column(db.String(10), nullable=False)
    vehicle_model = db.Column(db.String(20), nullable=False)
    vehicle_color = db.Column(db.String(10), nullable=False)
    registered_city = db.Column(db.String(30), nullable=False)


# Signup route
@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    cnic = data['cnic']
    username = data['username']
    password = data['password']

    # Password encryption
    hashed_password = hashlib.sha256(password.encode()).hexdigest()
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("INSERT INTO user_credentials (CNIC, username, password_hash) VALUES (%s, %s, %s)",
                    (cnic, username, hashed_password))
        conn.commit()
    except psycopg2.Error as e:
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close()
        conn.close()

    return jsonify({'message': 'Signup successful'}), 200


# Login route
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data['username']
    password = data['password']

    # Password encryption
    hashed_password = hashlib.sha256(password.encode()).hexdigest()
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("SELECT CNIC FROM user_credentials WHERE username = %s AND password_hash = %s",
                    (username, hashed_password))
        cnic = cur.fetchone()

        if cnic:
            # Retrieving user and corresponding vehicle info
            cur.execute("""
                SELECT u.CNIC, u.full_name, v.owner_license_plate, v.vehicle_type,
                       v.vehicle_model, v.vehicle_color, v.registered_city, u.license_plate
                FROM user_info u
                JOIN vehicle_info v ON u.license_plate = v.owner_license_plate
                WHERE u.CNIC = %s;
                """, (cnic[0],))
            user_info = cur.fetchone()

            if user_info:
                # Extracting the user and vehicle info
                user_info_dict = {
                    'cnic': user_info[0],
                    'username': username,
                    'password_hash': hashed_password,
                    'full_name': user_info[1],
                    'vehicle_type': user_info[3],
                    'vehicle_model': user_info[4],
                    'vehicle_color': user_info[5],
                    'registered_city': user_info[6],
                    'license_plate': user_info[7],
                }
                return jsonify(user_info_dict), 200
        return jsonify({'message': 'Invalid username or password'}), 401
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close()
        conn.close()


# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

