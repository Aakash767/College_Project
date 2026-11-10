
from flask import Flask, request, jsonify, session, render_template, redirect
import os
import mysql.connector
from mysql.connector import Error, IntegrityError
from werkzeug.security import generate_password_hash, check_password_hash
import os
from dotenv import load_dotenv
import uuid
load_dotenv()
app = Flask(__name__)

# ----------------------------------
# FLASK SECRET KEY
# ----------------------------------

app.secret_key = os.environ.get(
    "FLASK_SECRET_KEY",
    "local-development-secret-change-before-deployment"
)
@app.route('/')
def home():
    return render_template('index.html')


@app.route('/login')
def login_page():
    return render_template('login.html')


@app.route('/signup')
def signup_page():
    return render_template('signup.html')

@app.route('/super-admin/dashboard')
def super_admin_dashboard():

    if not is_super_admin_authenticated():
        return redirect('/super-admin/login-page')

    return render_template('super_admin_dashboard.html')


@app.route('/college-admin/dashboard')
def college_admin_dashboard():

    # Check whether College Admin is logged in
    if (
        'college_user_id' not in session
        or 'college_id' not in session
        or session.get('role_id') != 2
    ):
        return redirect('/login')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                u.full_name,
                c.college_id,
                c.college_name
            FROM user_details u
            INNER JOIN college_details c
                ON c.college_id = %s
            INNER JOIN user_college_access_details a
                ON a.user_id = u.user_id
                AND a.college_id = c.college_id
            INNER JOIN user_role_assignment_details r
                ON r.user_id = u.user_id
                AND r.college_id = c.college_id
            WHERE u.user_id = %s
              AND u.account_status = 'Active'
              AND a.access_status = 'Active'
              AND r.role_id = 2
              AND r.assignment_status = 'Active'
              AND c.registration_status = 'Approved'
              AND c.college_status = 'Active'
        """, (
            session['college_id'],
            session['college_user_id']
        ))

        admin = cursor.fetchone()

        if not admin:
            session.clear()
            return redirect('/login')

        return render_template(
            'college_admin_dashboard.html',
            full_name=admin['full_name'],
            college_name=admin['college_name'],
            college_id=admin['college_id']
        )

    except Error as e:
        return f"Database error: {str(e)}", 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


@app.route('/college-admin/logout', methods=['POST'])
def college_admin_logout():

    session.clear()

    return jsonify({
        "message": "College Admin logged out successfully."
    }), 200


@app.route('/college-admin/departments', methods=['GET'])
def get_college_departments():

    # Check College Admin login
    if (
        'college_user_id' not in session
        or 'college_id' not in session
        or session.get('role_id') != 2
    ):
        return jsonify({
            "message": "Please login as College Admin."
        }), 401

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                dept_id,
                dept_name,
                dept_status
            FROM department_details
            WHERE college_id = %s
            ORDER BY dept_name
        """, (session['college_id'],))

        departments = cursor.fetchall()

        return jsonify({
            "departments": departments
        }), 200

    except Error as e:

        return jsonify({
            "message": "Database error.",
            "error": str(e)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


@app.route('/college-admin/departments/add', methods=['POST'])
def add_college_department():

    if (
        'college_user_id' not in session
        or 'college_id' not in session
        or session.get('role_id') != 2
    ):
        return jsonify({
            "message": "Please login as College Admin."
        }), 401

    data = request.get_json()

    if not data:
        return jsonify({
            "message": "Please provide department details."
        }), 400

    dept_id = (data.get('dept_id') or '').strip()
    dept_name = (data.get('dept_name') or '').strip()

    if not dept_id or not dept_name:
        return jsonify({
            "message": "Department ID and Department Name are required."
        }), 400

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO department_details
                (college_id, dept_id, dept_name, dept_status)
            VALUES (%s, %s, %s, 'Active')
        """, (
            session['college_id'],
            dept_id,
            dept_name
        ))

        conn.commit()

        return jsonify({
            "message": "Department added successfully."
        }), 201

    except Error as e:

        if conn:
            conn.rollback()

        return jsonify({
            "message": "Unable to add department. Check whether the Department ID or Name already exists.",
            "error": str(e)
        }), 400

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


@app.route('/college-admin/departments/<dept_id>/status', methods=['POST'])
def update_department_status(dept_id):

    if (
        'college_user_id' not in session
        or 'college_id' not in session
        or session.get('role_id') != 2
    ):
        return jsonify({
            "message": "Please login as College Admin."
        }), 401

    data = request.get_json()

    if not data:
        return jsonify({
            "message": "Please provide department status."
        }), 400

    new_status = data.get('dept_status')

    if new_status not in ['Active', 'Inactive']:
        return jsonify({
            "message": "Invalid department status."
        }), 400

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            UPDATE department_details
            SET dept_status = %s
            WHERE college_id = %s
              AND dept_id = %s
        """, (
            new_status,
            session['college_id'],
            dept_id
        ))

        if cursor.rowcount == 0:
            return jsonify({
                "message": "Department not found or its status is already unchanged."
            }), 404

        conn.commit()

        return jsonify({
            "message": "Department status updated successfully."
        }), 200

    except Error as e:

        if conn:
            conn.rollback()

        return jsonify({
            "message": "Database error.",
            "error": str(e)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()

# ----------------------------------
# DATABASE CONNECTION
# ----------------------------------
def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )

# ----------------------------------
# CHECK SUPER ADMIN AUTHENTICATION
# ----------------------------------

def is_super_admin_authenticated():

    user_id = session.get('super_admin_id')

    if not user_id:
        return False

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT u.user_id
            FROM user_details u
            INNER JOIN platform_admin_details p
                ON u.user_id = p.user_id
            WHERE u.user_id = %s
              AND u.account_status = 'Active'
              AND p.admin_status = 'Active'
        """, (user_id,))

        return cursor.fetchone() is not None

    except Error:
        return False

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# CHECK COLLEGE ADMIN AUTHENTICATION
# ----------------------------------

def is_college_admin_authenticated():

    user_id = session.get('college_user_id')
    college_id = session.get('college_id')

    if not user_id or not college_id:
        return False

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT u.user_id
            FROM user_details u

            INNER JOIN user_college_access_details a
                ON u.user_id = a.user_id

            INNER JOIN user_role_assignment_details r
                ON u.user_id = r.user_id
                AND a.college_id = r.college_id

            INNER JOIN college_details c
                ON a.college_id = c.college_id

            WHERE u.user_id = %s
              AND a.college_id = %s
              AND u.account_status = 'Active'
              AND a.access_status = 'Active'
              AND r.role_id = 2
              AND r.assignment_status = 'Active'
              AND c.registration_status = 'Approved'
              AND c.college_status = 'Active'
        """, (user_id, college_id))

        return cursor.fetchone() is not None

    except Error:
        return False

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# COLLEGE SIGN UP
# ----------------------------------

@app.route('/college/signup', methods=['POST'])
def college_signup():

    data = request.get_json()

    if not data:
        return jsonify({
            "message": "Registration details are required"
        }), 400

    college_name = data.get('college_name')
    college_code = data.get('college_code')
    college_aishe_code = data.get('college_aishe_code')
    college_address = data.get('college_address')
    college_city = data.get('college_city')
    college_district = data.get('college_district')
    college_state = data.get('college_state')
    college_pincode = data.get('college_pincode')
    college_email = data.get('college_email')
    college_phone = data.get('college_phone')

    username = data.get('username')
    admin_email = data.get('admin_email')
    password = data.get('password')
    full_name = data.get('full_name')
    mobile_number = data.get('mobile_number')

    required_fields = {
        'college_name': college_name,
        'username': username,
        'admin_email': admin_email,
        'password': password,
        'full_name': full_name
    }

    for field, value in required_fields.items():

        if not isinstance(value, str) or not value.strip():
            return jsonify({
                "message": field + " is required"
            }), 400

    college_id = "COL" + uuid.uuid4().hex[:16]

    password_hash = generate_password_hash(password)

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        # 1. Insert college details

        cursor.execute("""
            INSERT INTO college_details (
                college_id,
                college_name,
                college_code,
                college_aishe_code,
                college_address,
                college_city,
                college_district,
                college_state,
                college_pincode,
                college_email,
                college_phone,
                registration_status,
                college_status
            )
            VALUES (
                %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s,
                'Pending', 'Inactive'
            )
        """, (
            college_id,
            college_name.strip(),
            college_code,
            college_aishe_code,
            college_address,
            college_city,
            college_district,
            college_state,
            college_pincode,
            college_email,
            college_phone
        ))

        # 2. Create College Admin account

        cursor.execute("""
            INSERT INTO user_details (
                username,
                email,
                password_hash,
                full_name,
                mobile_number,
                account_status
            )
            VALUES (%s, %s, %s, %s, %s, 'Inactive')
        """, (
            username.strip(),
            admin_email.strip(),
            password_hash,
            full_name.strip(),
            mobile_number
        ))

        user_id = cursor.lastrowid

        # 3. Link admin account with college

        cursor.execute("""
            INSERT INTO user_college_access_details (
                user_id,
                college_id,
                access_status
            )
            VALUES (%s, %s, 'Inactive')
        """, (user_id, college_id))

        # 4. Assign College Admin role

        cursor.execute("""
            INSERT INTO user_role_assignment_details (
                user_id,
                college_id,
                role_id,
                assigned_date,
                assignment_status
            )
            VALUES (%s, %s, 2, CURDATE(), 'Inactive')
        """, (user_id, college_id))

        conn.commit()

        return jsonify({
            "message": "College registration submitted successfully. Awaiting Super Admin approval.",
            "college_id": college_id,
            "college_name": college_name,
            "username": username,
            "registration_status": "Pending",
            "college_status": "Inactive"
        }), 201

    except IntegrityError as e:

        if conn:
            conn.rollback()

        return jsonify({
            "message": "Username, email or college code may already exist.",
            "error": str(e)
        }), 409

    except Error as e:

        if conn:
            conn.rollback()

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# CREATE SUPER ADMIN ACCOUNT
# ----------------------------------

@app.route('/setup-super-admin', methods=['POST'])
def setup_super_admin():

    data = request.get_json()

    if not data:
        return jsonify({
            "message": "Please provide account details"
        }), 400

    username = 'Super_Admin'
    password = data.get('password')
    full_name = data.get('full_name')
    email = data.get('email')

    if not password or not full_name or not email:
        return jsonify({
            "message": "Password, full name and email are required"
        }), 400

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT user_id
            FROM user_details
            WHERE username = %s
        """, (username,))

        if cursor.fetchone():
            return jsonify({
                "message": "Super Admin account already exists"
            }), 409

        password_hash = generate_password_hash(password)

        cursor.execute("""
            INSERT INTO user_details
            (username, email, password_hash, full_name)
            VALUES (%s, %s, %s, %s)
        """, (username, email, password_hash, full_name))

        user_id = cursor.lastrowid

        cursor.execute("""
            INSERT INTO platform_admin_details
            (user_id, role_id)
            VALUES (%s, %s)
        """, (user_id, 1))

        conn.commit()

        return jsonify({
            "message": "Super Admin account created successfully",
            "username": username,
            "user_id": user_id
        }), 201

    except Error as e:

        if conn:
            conn.rollback()

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# SUPER ADMIN LOGIN
# ----------------------------------
@app.route('/super-admin/login-page')
def super_admin_login_page():
    return render_template('super_admin_login.html')

@app.route('/super-admin/login', methods=['POST'])
def super_admin_login():

    data = request.get_json()

    if not data:
        return jsonify({
            "message": "Please provide login details"
        }), 400

    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({
            "message": "Username and password are required"
        }), 400

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                u.user_id,
                u.username,
                u.password_hash,
                u.full_name,
                u.account_status,
                p.admin_status
            FROM user_details u
            INNER JOIN platform_admin_details p
                ON u.user_id = p.user_id
            WHERE u.username = %s
        """, (username,))

        admin = cursor.fetchone()

        if not admin:
            return jsonify({
                "message": "Invalid username or password"
            }), 401

        if (
            admin['account_status'] != 'Active'
            or admin['admin_status'] != 'Active'
        ):
            return jsonify({
                "message": "Super Admin account is inactive"
            }), 403

        if not check_password_hash(
            admin['password_hash'], password
        ):
            return jsonify({
                "message": "Invalid username or password"
            }), 401

        cursor.execute("""
            UPDATE user_details
            SET last_login = NOW()
            WHERE user_id = %s
        """, (admin['user_id'],))

        conn.commit()

        session.clear()
        session['super_admin_id'] = admin['user_id']

        return jsonify({
            "message": "Super Admin login successful",
            "user_id": admin['user_id'],
            "username": admin['username'],
            "full_name": admin['full_name']
        }), 200

    except Error as e:

        if conn:
            conn.rollback()

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# SUPER ADMIN LOGOUT
# ----------------------------------

@app.route('/super-admin/logout', methods=['POST'])
def super_admin_logout():

    session.clear()

    return jsonify({
        "message": "Super Admin logged out successfully"
    }), 200


# ----------------------------------
# COLLEGE ADMIN LOGIN
# ----------------------------------

@app.route('/college-admin/login', methods=['POST'])
def college_admin_login():

    data = request.get_json()

    if not data:
        return jsonify({
            "message": "Please provide login details."
        }), 400

    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({
            "message": "Username and password are required."
        }), 400

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                u.user_id,
                u.username,
                u.password_hash,
                u.full_name,
                u.account_status,
                a.college_id,
                a.access_status,
                r.role_id,
                r.assignment_status,
                c.college_name,
                c.registration_status,
                c.college_status

            FROM user_details u

            INNER JOIN user_college_access_details a
                ON u.user_id = a.user_id

            INNER JOIN user_role_assignment_details r
                ON u.user_id = r.user_id
                AND a.college_id = r.college_id

            INNER JOIN college_details c
                ON a.college_id = c.college_id

            WHERE u.username = %s
              AND r.role_id = 2

        """, (username,))

        admin = cursor.fetchone()

        if not admin:
            return jsonify({
                "message": "Invalid username or password."
            }), 401

        if not check_password_hash(
            admin['password_hash'], password
        ):
            return jsonify({
                "message": "Invalid username or password."
            }), 401

        if admin['account_status'] != 'Active':
            return jsonify({
                "message": "College Admin account is inactive."
            }), 403

        if admin['access_status'] != 'Active':
            return jsonify({
                "message": "College access is inactive."
            }), 403

        if admin['assignment_status'] != 'Active':
            return jsonify({
                "message": "College Admin role is inactive."
            }), 403

        if admin['registration_status'] != 'Approved':
            return jsonify({
                "message": "College registration is not approved."
            }), 403

        if admin['college_status'] != 'Active':
            return jsonify({
                "message": "College is currently inactive."
            }), 403

        cursor.execute("""
            UPDATE user_details
            SET last_login = NOW()
            WHERE user_id = %s
        """, (admin['user_id'],))

        conn.commit()

        # Clear any previous login session
        session.clear()

        # Store College Admin session details
        session['college_user_id'] = admin['user_id']
        session['college_id'] = admin['college_id']
        session['role_id'] = admin['role_id']

        return jsonify({
            "message": "College Admin login successful.",
            "user_id": admin['user_id'],
            "username": admin['username'],
            "full_name": admin['full_name'],
            "college_id": admin['college_id'],
            "college_name": admin['college_name']
        }), 200

    except Error as e:

        if conn:
            conn.rollback()

        return jsonify({
            "message": "Database error.",
            "error": str(e)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()

# ----------------------------------
# COLLEGE ADMIN LOGOUT
# ----------------------------------

@app.route('/college/logout', methods=['POST'])
def college_logout():

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "No active College Admin session."
        }), 401

    session.clear()

    return jsonify({
        "message": "College Admin logged out successfully"
    }), 200


# ----------------------------------
# DEPARTMENT MANAGEMENT
# ----------------------------------

# 1. ADD DEPARTMENT


@app.route("/departments", methods=["POST"])
def add_department():

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "College Admin login required."
        }), 401

    data = request.get_json()

    dept_name = data.get("dept_name", "").strip()

    if not dept_name:
        return jsonify({
            "message": "Department name is required."
        }), 400

    college_id = session.get("college_id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Check whether this department already exists
        cursor.execute("""
            SELECT dept_id
            FROM department_details
            WHERE college_id = %s
            AND LOWER(TRIM(dept_name)) = LOWER(TRIM(%s))
        """, (college_id, dept_name))

        existing_department = cursor.fetchone()

        if existing_department:
            return jsonify({
                "message": "This department already exists in your college.",
                "dept_id": existing_department["dept_id"]
            }), 409

        # Generate department ID
        dept_id = "DEP" + uuid.uuid4().hex[:12].upper()

        # Insert department
        cursor.execute("""
            INSERT INTO department_details
            (college_id, dept_id, dept_name, dept_status)
            VALUES (%s, %s, %s, 'Active')
        """, (college_id, dept_id, dept_name))

        conn.commit()

        return jsonify({
            "message": "Department added successfully.",
            "dept_id": dept_id,
            "dept_name": dept_name,
            "dept_status": "Active"
        }), 201

    except IntegrityError:
        conn.rollback()

        return jsonify({
            "message": "This department already exists in your college."
        }), 409

    except Error as e:
        conn.rollback()

        return jsonify({
            "message": "Database error.",
            "error": str(e)
        }), 500

    finally:
        cursor.close()
        conn.close()

# 2. VIEW ALL DEPARTMENTS

@app.route('/departments', methods=['GET'])
def get_departments():

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "Unauthorized or college is inactive."
        }), 401

    college_id = session.get('college_id')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                college_id,
                dept_id,
                dept_name,
                dept_status
            FROM department_details
            WHERE college_id = %s
            ORDER BY dept_name
        """, (college_id,))

        departments = cursor.fetchall()

        return jsonify({
            "total_departments": len(departments),
            "departments": departments
        }), 200

    except Error as e:

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# 3. VIEW ONE DEPARTMENT

@app.route('/departments/<dept_id>', methods=['GET'])
def get_department(dept_id):

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "Unauthorized or college is inactive."
        }), 401

    college_id = session.get('college_id')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                college_id,
                dept_id,
                dept_name,
                dept_status
            FROM department_details
            WHERE college_id = %s
              AND dept_id = %s
        """, (college_id, dept_id))

        department = cursor.fetchone()

        if not department:
            return jsonify({
                "message": "Department not found."
            }), 404

        return jsonify(department), 200

    except Error as e:

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# 4. UPDATE DEPARTMENT NAME

@app.route('/departments/<dept_id>', methods=['PUT'])
def update_department(dept_id):

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "Unauthorized or college is inactive."
        }), 401

    data = request.get_json()

    if not data:
        return jsonify({
            "message": "Department details are required."
        }), 400

    dept_name = data.get('dept_name')

    if not isinstance(dept_name, str) or not dept_name.strip():
        return jsonify({
            "message": "Department name is required."
        }), 400

    college_id = session.get('college_id')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            UPDATE department_details
            SET dept_name = %s
            WHERE college_id = %s
              AND dept_id = %s
        """, (
            dept_name.strip(),
            college_id,
            dept_id
        ))

        if cursor.rowcount == 0:

            cursor.execute("""
                SELECT dept_id
                FROM department_details
                WHERE college_id = %s
                  AND dept_id = %s
            """, (college_id, dept_id))

            if not cursor.fetchone():
                return jsonify({
                    "message": "Department not found."
                }), 404

        conn.commit()

        return jsonify({
            "message": "Department updated successfully.",
            "dept_id": dept_id,
            "dept_name": dept_name.strip()
        }), 200

    except Error as e:

        if conn:
            conn.rollback()

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# COURSE MANAGEMENT
# ----------------------------------

# 1. ADD COURSE

@app.route('/courses', methods=['POST'])
def add_course():

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "College Admin login required or college is inactive."
        }), 401

    data = request.get_json()

    if not data:
        return jsonify({"message": "Course details are required."}), 400

    dept_id = data.get('dept_id')
    course_name = data.get('course_name')
    course_code = data.get('course_code')
    duration_years = data.get('duration_years')
    semesters_per_year = data.get('semesters_per_year', 2)

    if not dept_id:
        return jsonify({"message": "Please select a department."}), 400

    if not isinstance(course_name, str) or not course_name.strip():
        return jsonify({"message": "Course name is required."}), 400

    if not isinstance(course_code, str) or not course_code.strip():
        return jsonify({"message": "Course code is required."}), 400

    try:
        duration_years = int(duration_years)
        semesters_per_year = int(semesters_per_year)

        if duration_years <= 0 or semesters_per_year <= 0:
            raise ValueError

    except (TypeError, ValueError):
        return jsonify({
            "message": "Duration and semesters per year must be positive numbers."
        }), 400

    college_id = session.get('college_id')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # Verify that the selected department belongs to this college
        # and is Active.

        cursor.execute("""
            SELECT dept_id, dept_status
            FROM department_details
            WHERE college_id = %s
              AND dept_id = %s
        """, (college_id, dept_id))

        department = cursor.fetchone()

        if not department:
            return jsonify({
                "message": "Department not found in your college."
            }), 404

        if department['dept_status'] != 'Active':
            return jsonify({
                "message": "This department is inactive. You cannot add courses."
            }), 403

        course_id = "CRS" + uuid.uuid4().hex[:12].upper()

        cursor.execute("""
            INSERT INTO course_details (
                college_id,
                dept_id,
                course_id,
                course_name,
                course_code,
                duration_years,
                semesters_per_year,
                course_status,
                course_level,
                course_type,
                course_mode,
                course_description,
                course_start_year
            )
            VALUES (
                %s, %s, %s, %s, %s, %s, %s, 'Active',
                %s, %s, %s, %s, %s
            )
        """, (
            college_id,
            dept_id,
            course_id,
            course_name.strip(),
            course_code.strip(),
            duration_years,
            semesters_per_year,
            data.get('course_level'),
            data.get('course_type'),
            data.get('course_mode'),
            data.get('course_description'),
            data.get('course_start_year')
        ))

        conn.commit()

        return jsonify({
            "message": "Course added successfully.",
            "college_id": college_id,
            "dept_id": dept_id,
            "course_id": course_id,
            "course_name": course_name.strip(),
            "course_code": course_code.strip(),
            "course_status": "Active"
        }), 201

    except IntegrityError as e:
        if conn:
            conn.rollback()

        return jsonify({
            "message": "Course could not be added because of a duplicate or database constraint.",
            "error": str(e)
        }), 409

    except Error as e:
        if conn:
            conn.rollback()

        return jsonify({
            "message": "Database error.",
            "error": str(e)
        }), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# 2. VIEW ALL COURSES
# Courses under inactive departments are not displayed.

@app.route('/courses', methods=['GET'])
def get_courses():

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "College Admin login required or college is inactive."
        }), 401

    college_id = session.get('college_id')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                c.college_id,
                c.dept_id,
                d.dept_name,
                c.course_id,
                c.course_name,
                c.course_code,
                c.duration_years,
                c.semesters_per_year,
                c.course_status,
                c.course_level,
                c.course_type,
                c.course_mode,
                c.course_description,
                c.course_start_year
            FROM course_details c
            INNER JOIN department_details d
                ON c.college_id = d.college_id
                AND c.dept_id = d.dept_id
            WHERE c.college_id = %s
              AND d.dept_status = 'Active'
            ORDER BY d.dept_name, c.course_name
        """, (college_id,))

        courses = cursor.fetchall()

        return jsonify({
            "total_courses": len(courses),
            "courses": courses
        }), 200

    except Error as e:
        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# 3. VIEW COURSES UNDER ONE DEPARTMENT

@app.route('/departments/<dept_id>/courses', methods=['GET'])
def get_department_courses(dept_id):

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "College Admin login required or college is inactive."
        }), 401

    college_id = session.get('college_id')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT dept_name, dept_status
            FROM department_details
            WHERE college_id = %s
              AND dept_id = %s
        """, (college_id, dept_id))

        department = cursor.fetchone()

        if not department:
            return jsonify({
                "message": "Department not found."
            }), 404

        if department['dept_status'] != 'Active':
            return jsonify({
                "message": "This department is inactive. Its course facilities are blocked."
            }), 403

        cursor.execute("""
            SELECT
                college_id,
                dept_id,
                course_id,
                course_name,
                course_code,
                duration_years,
                semesters_per_year,
                course_status,
                course_level,
                course_type,
                course_mode,
                course_description,
                course_start_year
            FROM course_details
            WHERE college_id = %s
              AND dept_id = %s
            ORDER BY course_name
        """, (college_id, dept_id))

        courses = cursor.fetchall()

        return jsonify({
            "department_name": department['dept_name'],
            "total_courses": len(courses),
            "courses": courses
        }), 200

    except Error as e:
        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# 4. VIEW ONE COURSE

@app.route('/departments/<dept_id>/courses/<course_id>', methods=['GET'])
def get_one_course(dept_id, course_id):

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "College Admin login required or college is inactive."
        }), 401

    college_id = session.get('college_id')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT dept_status
            FROM department_details
            WHERE college_id = %s
              AND dept_id = %s
        """, (college_id, dept_id))

        department = cursor.fetchone()

        if not department:
            return jsonify({"message": "Department not found."}), 404

        if department['dept_status'] != 'Active':
            return jsonify({
                "message": "This department is inactive. Course facilities are blocked."
            }), 403

        cursor.execute("""
            SELECT *
            FROM course_details
            WHERE college_id = %s
              AND dept_id = %s
              AND course_id = %s
        """, (college_id, dept_id, course_id))

        course = cursor.fetchone()

        if not course:
            return jsonify({"message": "Course not found."}), 404

        return jsonify(course), 200

    except Error as e:
        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# 5. UPDATE COURSE DETAILS

@app.route(
    '/departments/<dept_id>/courses/<course_id>',
    methods=['PUT']
)
def update_course(dept_id, course_id):

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "College Admin login required or college is inactive."
        }), 401

    data = request.get_json()

    if not data:
        return jsonify({"message": "Course details are required."}), 400

    course_name = data.get('course_name')
    course_code = data.get('course_code')
    duration_years = data.get('duration_years')
    semesters_per_year = data.get('semesters_per_year')

    if not isinstance(course_name, str) or not course_name.strip():
        return jsonify({"message": "Course name is required."}), 400

    if not isinstance(course_code, str) or not course_code.strip():
        return jsonify({"message": "Course code is required."}), 400

    try:
        duration_years = int(duration_years)
        semesters_per_year = int(semesters_per_year)

        if duration_years <= 0 or semesters_per_year <= 0:
            raise ValueError

    except (TypeError, ValueError):
        return jsonify({
            "message": "Duration and semesters per year must be positive numbers."
        }), 400

    college_id = session.get('college_id')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT dept_status
            FROM department_details
            WHERE college_id = %s
              AND dept_id = %s
        """, (college_id, dept_id))

        department = cursor.fetchone()

        if not department:
            return jsonify({"message": "Department not found."}), 404

        if department['dept_status'] != 'Active':
            return jsonify({
                "message": "This department is inactive. Course updates are blocked."
            }), 403

        cursor.execute("""
            SELECT course_id
            FROM course_details
            WHERE college_id = %s
              AND dept_id = %s
              AND course_id = %s
        """, (college_id, dept_id, course_id))

        if not cursor.fetchone():
            return jsonify({"message": "Course not found."}), 404

        cursor.execute("""
            UPDATE course_details
            SET
                course_name = %s,
                course_code = %s,
                duration_years = %s,
                semesters_per_year = %s,
                course_level = %s,
                course_type = %s,
                course_mode = %s,
                course_description = %s,
                course_start_year = %s
            WHERE college_id = %s
              AND dept_id = %s
              AND course_id = %s
        """, (
            course_name.strip(),
            course_code.strip(),
            duration_years,
            semesters_per_year,
            data.get('course_level'),
            data.get('course_type'),
            data.get('course_mode'),
            data.get('course_description'),
            data.get('course_start_year'),
            college_id,
            dept_id,
            course_id
        ))

        conn.commit()

        return jsonify({
            "message": "Course updated successfully.",
            "course_id": course_id,
            "course_name": course_name.strip()
        }), 200

    except Error as e:
        if conn:
            conn.rollback()

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# 6. ACTIVATE OR DEACTIVATE COURSE

@app.route(
    '/departments/<dept_id>/courses/<course_id>/status',
    methods=['PUT']
)
def update_course_status(dept_id, course_id):

    if not is_college_admin_authenticated():
        return jsonify({
            "message": "College Admin login required or college is inactive."
        }), 401

    data = request.get_json()

    if not data:
        return jsonify({"message": "Course status is required."}), 400

    course_status = data.get('course_status')

    if course_status not in ['Active', 'Inactive']:
        return jsonify({
            "message": "Status must be Active or Inactive."
        }), 400

    college_id = session.get('college_id')

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT dept_status
            FROM department_details
            WHERE college_id = %s
              AND dept_id = %s
        """, (college_id, dept_id))

        department = cursor.fetchone()

        if not department:
            return jsonify({"message": "Department not found."}), 404

        if department['dept_status'] != 'Active':
            return jsonify({
                "message": "This department is inactive. Course status cannot be changed."
            }), 403

        cursor.execute("""
            UPDATE course_details
            SET course_status = %s
            WHERE college_id = %s
              AND dept_id = %s
              AND course_id = %s
        """, (course_status, college_id, dept_id, course_id))

        if cursor.rowcount == 0:

            cursor.execute("""
                SELECT course_id
                FROM course_details
                WHERE college_id = %s
                  AND dept_id = %s
                  AND course_id = %s
            """, (college_id, dept_id, course_id))

            if not cursor.fetchone():
                return jsonify({"message": "Course not found."}), 404

        conn.commit()

        return jsonify({
            "message": "Course status updated successfully.",
            "course_id": course_id,
            "course_status": course_status
        }), 200

    except Error as e:
        if conn:
            conn.rollback()

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# PART 1: VIEW PENDING COLLEGES
# ----------------------------------

@app.route('/super-admin/colleges/pending', methods=['GET'])
def get_pending_colleges():

    if not is_super_admin_authenticated():
        return jsonify({
            "message": "Unauthorized. Super Admin login required."
        }), 401

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                college_id,
                college_name,
                college_code,
                college_aishe_code,
                college_email,
                college_phone,
                college_city,
                college_district,
                college_state,
                created_at,
                registration_status,
                college_status
            FROM college_details
            WHERE registration_status = 'Pending'
            ORDER BY created_at DESC
        """)

        colleges = cursor.fetchall()

        return jsonify({
            "total_pending_colleges": len(colleges),
            "colleges": colleges
        }), 200

    except Error as e:

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# PART 2: APPROVE COLLEGE
# ----------------------------------

@app.route(
    '/super-admin/colleges/<college_id>/approve',
    methods=['PUT']
)
def approve_college(college_id):

    if not is_super_admin_authenticated():
        return jsonify({
            "message": "Unauthorized. Super Admin login required."
        }), 401

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        conn.start_transaction()

        # Approve and activate college

        cursor.execute("""
            UPDATE college_details
            SET registration_status = 'Approved',
                college_status = 'Active'
            WHERE college_id = %s
              AND registration_status = 'Pending'
        """, (college_id,))

        if cursor.rowcount != 1:

            conn.rollback()

            return jsonify({
                "message": "College not found or already processed."
            }), 404

        # Activate College Admin account

        cursor.execute("""
            UPDATE user_details u
            INNER JOIN user_college_access_details a
                ON u.user_id = a.user_id
            SET u.account_status = 'Active'
            WHERE a.college_id = %s
        """, (college_id,))

        # Activate college access

        cursor.execute("""
            UPDATE user_college_access_details
            SET access_status = 'Active'
            WHERE college_id = %s
        """, (college_id,))

        # Activate College Admin role

        cursor.execute("""
            UPDATE user_role_assignment_details
            SET assignment_status = 'Active'
            WHERE college_id = %s
              AND role_id = 2
        """, (college_id,))

        conn.commit()

        return jsonify({
            "message": "College approved successfully.",
            "college_id": college_id,
            "registration_status": "Approved",
            "college_status": "Active",
            "admin_account_status": "Active",
            "college_access_status": "Active"
        }), 200

    except Error as e:

        if conn:
            conn.rollback()

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# PART 3: REJECT COLLEGE
# ----------------------------------

@app.route(
    '/super-admin/colleges/<college_id>/reject',
    methods=['PUT']
)
def reject_college(college_id):

    if not is_super_admin_authenticated():
        return jsonify({
            "message": "Unauthorized. Super Admin login required."
        }), 401

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        conn.start_transaction()

        # Reject and deactivate college

        cursor.execute("""
            UPDATE college_details
            SET registration_status = 'Rejected',
                college_status = 'Inactive'
            WHERE college_id = %s
              AND registration_status = 'Pending'
        """, (college_id,))

        if cursor.rowcount != 1:

            conn.rollback()

            return jsonify({
                "message": "College not found or already processed."
            }), 404

        # Keep admin account inactive

        cursor.execute("""
            UPDATE user_details u
            INNER JOIN user_college_access_details a
                ON u.user_id = a.user_id
            SET u.account_status = 'Inactive'
            WHERE a.college_id = %s
        """, (college_id,))

        # Keep college access inactive

        cursor.execute("""
            UPDATE user_college_access_details
            SET access_status = 'Inactive'
            WHERE college_id = %s
        """, (college_id,))

        # Keep College Admin role inactive

        cursor.execute("""
            UPDATE user_role_assignment_details
            SET assignment_status = 'Inactive'
            WHERE college_id = %s
              AND role_id = 2
        """, (college_id,))

        conn.commit()

        return jsonify({
            "message": "College registration rejected.",
            "college_id": college_id,
            "registration_status": "Rejected",
            "college_status": "Inactive",
            "admin_account_status": "Inactive",
            "college_access_status": "Inactive"
        }), 200

    except Error as e:

        if conn:
            conn.rollback()

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# PART 4: GET COLLEGES BY REGISTRATION STATUS
# ----------------------------------

@app.route(
    '/super-admin/colleges/by-status/<status>',
    methods=['GET']
)
def get_colleges_by_status(status):

    if not is_super_admin_authenticated():
        return jsonify({
            "message": "Unauthorized. Super Admin login required."
        }), 401

    allowed_statuses = ['Pending', 'Approved', 'Rejected']

    if status not in allowed_statuses:
        return jsonify({
            "message": "Invalid registration status."
        }), 400

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                college_id,
                college_name,
                college_code,
                college_aishe_code,
                college_email,
                college_phone,
                college_city,
                college_district,
                college_state,
                created_at,
                registration_status,
                college_status
            FROM college_details
            WHERE registration_status = %s
            ORDER BY created_at DESC
        """, (status,))

        colleges = cursor.fetchall()

        return jsonify({
            "total_colleges": len(colleges),
            "colleges": colleges
        }), 200

    except Error as e:

        return jsonify({"error": str(e)}), 500

    finally:
        if cursor:
            cursor.close()

        if conn and conn.is_connected():
            conn.close()


# ----------------------------------
# START FLASK SERVER
# ----------------------------------

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
