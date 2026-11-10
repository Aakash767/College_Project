
import requests

BASE_URL = "http://127.0.0.1:5000"

api_session = requests.Session()


# ==================================
# DISPLAY API RESPONSE
# ==================================

def show_response(response):

    print("\nStatus Code:", response.status_code)

    try:
        print("Response:", response.json())
    except ValueError:
        print("Response:", response.text)


# ==================================
# SUPER ADMIN MANAGEMENT
# ==================================

def create_super_admin():

    print("\n--- CREATE SUPER ADMIN ACCOUNT ---")

    password = input("Enter Super Admin password: ")
    full_name = input("Enter full name: ")
    email = input("Enter email: ")

    data = {
        "password": password,
        "full_name": full_name,
        "email": email
    }

    try:
        response = api_session.post(
            BASE_URL + "/setup-super-admin",
            json=data,
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


def super_admin_login():

    print("\n--- SUPER ADMIN LOGIN ---")

    username = input("Enter Super Admin Username: ")
    password = input("Enter Password: ")

    try:
        response = api_session.post(
            BASE_URL + "/super-admin/login",
            json={
                "username": username,
                "password": password
            },
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


def super_admin_logout():

    try:
        response = api_session.post(
            BASE_URL + "/super-admin/logout",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# ==================================
# COLLEGE MANAGEMENT
# ==================================

def college_signup():

    print("\n--- COLLEGE SIGN UP ---")
    print("\nCOLLEGE DETAILS")

    data = {
        "college_name": input("Enter College Name: "),
        "college_code": input("Enter College Code: "),
        "college_aishe_code": input("Enter AISHE Code: "),
        "college_address": input("Enter College Address: "),
        "college_city": input("Enter City: "),
        "college_district": input("Enter District: "),
        "college_state": input("Enter State: "),
        "college_pincode": input("Enter PIN Code: "),
        "college_email": input("Enter College Email: "),
        "college_phone": input("Enter College Phone: ")
    }

    print("\nCOLLEGE ADMIN DETAILS")

    data["full_name"] = input("Enter Admin Full Name: ")
    data["username"] = input("Create Username: ")
    data["admin_email"] = input("Enter Admin Email: ")
    data["mobile_number"] = input("Enter Admin Mobile Number: ")
    data["password"] = input("Create Password: ")

    try:
        response = api_session.post(
            BASE_URL + "/college/signup",
            json=data,
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


def view_pending_colleges():

    try:
        response = api_session.get(
            BASE_URL + "/super-admin/colleges/pending",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


def approve_college():

    college_id = input("Enter College ID to approve: ").strip()

    if not college_id:
        print("College ID is required.")
        return

    try:
        response = api_session.put(
            BASE_URL + "/super-admin/colleges/" +
            college_id + "/approve",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


def reject_college():

    college_id = input("Enter College ID to reject: ").strip()

    if not college_id:
        print("College ID is required.")
        return

    try:
        response = api_session.put(
            BASE_URL + "/super-admin/colleges/" +
            college_id + "/reject",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


def college_login():

    print("\n--- COLLEGE ADMIN LOGIN ---")

    username = input("Enter College Admin Username: ")
    password = input("Enter College Admin Password: ")

    try:
        response = api_session.post(
            BASE_URL + "/college/login",
            json={
                "username": username,
                "password": password
            },
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


def college_logout():

    try:
        response = api_session.post(
            BASE_URL + "/college/logout",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# ==================================
# DEPARTMENT MANAGEMENT
# ==================================

# 10. ADD DEPARTMENT

def add_department():

    dept_name = input("Enter Department Name: ").strip()

    if not dept_name:
        print("Department name cannot be empty.")
        return

    try:
        response = api_session.post(
            BASE_URL + "/departments",
            json={"dept_name": dept_name},
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# 11. VIEW ALL DEPARTMENTS

def view_departments():

    try:
        response = api_session.get(
            BASE_URL + "/departments",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# 12. VIEW ONE DEPARTMENT

def view_one_department():

    dept_id = input("Enter Department ID: ").strip()

    if not dept_id:
        print("Department ID is required.")
        return

    try:
        response = api_session.get(
            f"{BASE_URL}/departments/{dept_id}",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# 13. UPDATE DEPARTMENT

def update_department():

    dept_id = input("Enter Department ID: ").strip()
    dept_name = input("Enter New Department Name: ").strip()

    if not dept_id or not dept_name:
        print("Department ID and name are required.")
        return

    try:
        response = api_session.put(
            f"{BASE_URL}/departments/{dept_id}",
            json={"dept_name": dept_name},
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# 14. ACTIVATE / DEACTIVATE DEPARTMENT

def update_department_status():

    dept_id = input("Enter Department ID: ").strip()

    if not dept_id:
        print("Department ID is required.")
        return

    print("\n1. Activate Department")
    print("2. Deactivate Department")

    choice = input("Enter your choice: ").strip()

    if choice == "1":
        dept_status = "Active"

    elif choice == "2":
        dept_status = "Inactive"

    else:
        print("Invalid choice.")
        return

    try:
        response = api_session.put(
            f"{BASE_URL}/departments/{dept_id}/status",
            json={"dept_status": dept_status},
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# ==================================
# COMMON DEPARTMENT SELECTION
# ==================================

def select_department():

    try:
        response = api_session.get(
            BASE_URL + "/departments",
            timeout=15
        )

        if response.status_code != 200:
            show_response(response)
            return None, None

        departments = response.json().get("departments", [])

        if not departments:
            print("\nNo departments found.")
            return None, None

        print("\n========== SELECT DEPARTMENT ==========")

        for index, dept in enumerate(departments, start=1):

            print(
                f"{index}. {dept['dept_name']} "
                f"({dept['dept_status']})"
            )

        try:
            choice = int(input("\nSelect Department Number: "))

            if choice < 1 or choice > len(departments):
                print("Invalid department selection.")
                return None, None

            selected_department = departments[choice - 1]

            if selected_department["dept_status"] != "Active":
                print("This department is Inactive. You cannot proceed.")
                return None, None

            dept_id = selected_department["dept_id"]
            dept_name = selected_department["dept_name"]

            print("\nSelected Department:", dept_name)

            return dept_id, dept_name

        except ValueError:
            print("Please enter a valid number.")
            return None, None

    except requests.exceptions.RequestException as e:
        print("Error:", e)
        return None, None


# ==================================
# COURSE MANAGEMENT
# ==================================

# COMMON COURSE SELECTION

def select_course(dept_id, department_name):

    try:
        response = api_session.get(
            f"{BASE_URL}/departments/{dept_id}/courses",
            timeout=15
        )

        if response.status_code != 200:
            show_response(response)
            return None

        courses = response.json().get("courses", [])

        if not courses:
            print("\nNo courses found in this department.")
            return None

        print("\n========== SELECT COURSE ==========")
        print("Department:", department_name)

        for index, course in enumerate(courses, start=1):

            print(
                f"{index}. {course['course_name']} "
                f"({course['course_id']}) "
                f"[{course['course_status']}]"
            )

        try:
            choice = int(input("\nSelect Course Number: "))

            if choice < 1 or choice > len(courses):
                print("Invalid course selection.")
                return None

            selected_course = courses[choice - 1]

            print("\nSelected Department:", department_name)
            print("Selected Course:", selected_course["course_name"])
            print("Course ID:", selected_course["course_id"])

            return selected_course["course_id"]

        except ValueError:
            print("Please enter a valid number.")
            return None

    except requests.exceptions.RequestException as e:
        print("Error:", e)
        return None


# 15. ADD COURSE

def add_course():

    print("\n--- ADD COURSE ---")

    dept_id, department_name = select_department()

    if not dept_id:
        return

    print("\nAdding Course Under:", department_name)

    course_name = input("Enter Course Name: ").strip()
    course_code = input("Enter Course Code: ").strip()

    if not course_name or not course_code:
        print("Course Name and Course Code are required.")
        return

    try:
        duration_years = int(input("Enter Duration in Years: "))

        semesters_per_year = input(
            "Enter Semesters per Year (default 2): "
        ).strip()

        if not semesters_per_year:
            semesters_per_year = 2
        else:
            semesters_per_year = int(semesters_per_year)

        if duration_years <= 0 or semesters_per_year <= 0:
            print("Duration and semesters must be greater than zero.")
            return

    except ValueError:
        print("Please enter valid numeric values.")
        return

    course_level = input("Enter Course Level (optional): ").strip()
    course_type = input("Enter Course Type (optional): ").strip()
    course_mode = input("Enter Course Mode (optional): ").strip()

    course_description = input(
        "Enter Course Description (optional): "
    ).strip()

    course_start_year = input(
        "Enter Course Start Year (optional): "
    ).strip()

    try:
        start_year = int(course_start_year) if course_start_year else None
    except ValueError:
        print("Invalid start year.")
        return

    data = {
        "dept_id": dept_id,
        "course_name": course_name,
        "course_code": course_code,
        "duration_years": duration_years,
        "semesters_per_year": semesters_per_year,
        "course_level": course_level or None,
        "course_type": course_type or None,
        "course_mode": course_mode or None,
        "course_description": course_description or None,
        "course_start_year": start_year
    }

    try:
        response = api_session.post(
            BASE_URL + "/courses",
            json=data,
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# 16. VIEW ALL COURSES

def view_courses():

    print("\n--- VIEW ALL COURSES ---")

    try:
        response = api_session.get(
            BASE_URL + "/courses",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# 17. VIEW COURSES UNDER A DEPARTMENT

def view_department_courses():

    print("\n--- VIEW DEPARTMENT COURSES ---")

    dept_id, department_name = select_department()

    if not dept_id:
        return

    print("\nCourses Under:", department_name)

    try:
        response = api_session.get(
            f"{BASE_URL}/departments/{dept_id}/courses",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# 18. VIEW ONE COURSE

def view_one_course():

    print("\n--- VIEW ONE COURSE ---")

    dept_id, department_name = select_department()

    if not dept_id:
        return

    course_id = select_course(dept_id, department_name)

    if not course_id:
        return

    try:
        response = api_session.get(
            f"{BASE_URL}/departments/{dept_id}/courses/{course_id}",
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# 19. UPDATE COURSE

def update_course():

    print("\n--- UPDATE COURSE ---")

    dept_id, department_name = select_department()

    if not dept_id:
        return

    course_id = select_course(dept_id, department_name)

    if not course_id:
        return

    print("\nUpdating Course Under:", department_name)

    print("\nEnter the updated course details.")

    course_name = input("Enter Course Name: ").strip()
    course_code = input("Enter Course Code: ").strip()

    if not course_name or not course_code:
        print("Course Name and Course Code are required.")
        return

    try:
        duration_years = int(input("Enter Duration in Years: "))

        semesters_per_year = int(
            input("Enter Semesters per Year: ")
        )

        if duration_years <= 0 or semesters_per_year <= 0:
            print("Duration and semesters must be greater than zero.")
            return

    except ValueError:
        print("Please enter valid numeric values.")
        return

    course_level = input("Enter Course Level (optional): ").strip()
    course_type = input("Enter Course Type (optional): ").strip()
    course_mode = input("Enter Course Mode (optional): ").strip()

    course_description = input(
        "Enter Course Description (optional): "
    ).strip()

    course_start_year = input(
        "Enter Course Start Year (optional): "
    ).strip()

    try:
        start_year = int(course_start_year) if course_start_year else None
    except ValueError:
        print("Invalid start year.")
        return

    data = {
        "course_name": course_name,
        "course_code": course_code,
        "duration_years": duration_years,
        "semesters_per_year": semesters_per_year,
        "course_level": course_level or None,
        "course_type": course_type or None,
        "course_mode": course_mode or None,
        "course_description": course_description or None,
        "course_start_year": start_year
    }

    try:
        response = api_session.put(
            f"{BASE_URL}/departments/{dept_id}/courses/{course_id}",
            json=data,
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# 20. ACTIVATE / DEACTIVATE COURSE

def update_course_status():

    print("\n--- ACTIVATE / DEACTIVATE COURSE ---")

    dept_id, department_name = select_department()

    if not dept_id:
        return

    course_id = select_course(dept_id, department_name)

    if not course_id:
        return

    print("\n1. Activate Course")
    print("2. Deactivate Course")

    choice = input("Enter your choice: ").strip()

    if choice == "1":
        course_status = "Active"

    elif choice == "2":
        course_status = "Inactive"

    else:
        print("Invalid choice.")
        return

    try:
        response = api_session.put(
            f"{BASE_URL}/departments/{dept_id}/courses/{course_id}/status",
            json={"course_status": course_status},
            timeout=15
        )

        show_response(response)

    except requests.exceptions.RequestException as e:
        print("Error:", e)


# ==================================
# MAIN MENU
# ==================================

while True:

    print("\n================================")
    print("       COLLEGE MANAGEMENT")
    print("          API TESTING")
    print("================================")

    print("\n--- SUPER ADMIN / COLLEGE LOGIN ---")

    print("1. Create Super Admin Account")
    print("2. Super Admin Login")
    print("3. College Sign Up")
    print("4. View Pending Colleges")
    print("5. Approve College")
    print("6. Reject College")
    print("7. Super Admin Logout")
    print("8. College Admin Login")
    print("9. College Admin Logout")

    print("\n--- DEPARTMENT MANAGEMENT ---")

    print("10. Add Department")
    print("11. View All Departments")
    print("12. View One Department")
    print("13. Update Department")
    print("14. Activate / Deactivate Department")

    print("\n--- COURSE MANAGEMENT ---")

    print("15. Add Course")
    print("16. View All Courses")
    print("17. View Courses Under a Department")
    print("18. View One Course")
    print("19. Update Course")
    print("20. Activate / Deactivate Course")

    print("\n0. Exit")

    choice = input("\nEnter your choice: ").strip()

    if choice == "1":
        create_super_admin()

    elif choice == "2":
        super_admin_login()

    elif choice == "3":
        college_signup()

    elif choice == "4":
        view_pending_colleges()

    elif choice == "5":
        approve_college()

    elif choice == "6":
        reject_college()

    elif choice == "7":
        super_admin_logout()

    elif choice == "8":
        college_login()

    elif choice == "9":
        college_logout()

    elif choice == "10":
        add_department()

    elif choice == "11":
        view_departments()

    elif choice == "12":
        view_one_department()

    elif choice == "13":
        update_department()

    elif choice == "14":
        update_department_status()

    elif choice == "15":
        add_course()

    elif choice == "16":
        view_courses()

    elif choice == "17":
        view_department_courses()

    elif choice == "18":
        view_one_course()

    elif choice == "19":
        update_course()

    elif choice == "20":
        update_course_status()

    elif choice == "0":
        print("\nExiting API Testing.")
        break

    else:
        print("\nInvalid choice. Please try again.")
