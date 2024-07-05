import random
import time
from flask import Flask
from flask import render_template
import os
from flask import request
from flask import redirect
from flask import url_for
from flask import session

import re
from flask import flash
from datetime import datetime, timedelta
from flask_hashing import Hashing
import mysql.connector
from mysql.connector import FieldType
import connect
from manager import manager_page
from therapist import therapist_page
from member import member_page

app = Flask(__name__)
hashing = Hashing(app)
app.secret_key = 'gemini'

app.register_blueprint(manager_page, url_prefix="/manager")
app.register_blueprint(therapist_page, url_prefix="/therapist")
app.register_blueprint(member_page, url_prefix="/member")

dbconn = None
connection = None


def getCursor():
    global dbconn
    global connection
    connection = mysql.connector.connect(user=connect.dbuser, \
                                         password=connect.dbpass, host=connect.dbhost, \
                                         database=connect.dbname, autocommit=True)
    dbconn = connection.cursor()
    return dbconn


@app.route('/')
def home():
    return render_template('index.html')


def is_underage(dob_str):
    dob_date = ''
    try:
        dob_date = datetime.strptime(dob_str, '%Y-%m-%d')
    except ValueError:
        dob_date = datetime.strptime(dob_str, '%d-%m-%Y')
    today = datetime.today()
    age = today.year - dob_date.year - ((today.month, today.day) < (dob_date.month, dob_date.day))
    return age < 18


def is_expired(card_expire_date):
    current_date = datetime.now()
    expire_month, expire_year = map(int, card_expire_date.split('/'))
    expire_date = datetime(expire_year + 2000, expire_month, 1)
    if expire_date < current_date:
        return True
    else:
        return False


def get_sub_end_date(sub_start_date, flag):
    return_date = ''
    next_month_date = ''
    formatted_sub_start_date = datetime.strptime(sub_start_date, '%Y-%m-%d')
    if flag == 'monthly':
        next_month_date = formatted_sub_start_date + timedelta(days=30)
    if flag == 'annually':
        next_month_date = formatted_sub_start_date + timedelta(days=365)
    return_date = next_month_date.strftime('%Y-%m-%d')
    return return_date


@app.route('/register', methods=['GET', 'POST'])
def register():
    profile = {
        'username': '',
        'password': '',
        'confirmpassword': '',
        'firstname': '',
        'lastname': '',
        'email': '',
        'phone': '',
        'title': '',
        'dob': '',
        'health_info': '',
        'profile_img': '',
        'user_position': '',
        'subscription_type': '',
        'card_number': '',
        'card_holder': '',
        'card_expire_date': '',
        'card_cvv': '',
    }
    msg_obj = {
        'msg_field': '',
        'msg': '',
        'msg_type': 'danger',
    }

    if request.method == 'POST' and 'username' in request.form and 'user_password' in request.form and 'firstname' in request.form and 'lastname' in request.form and 'email' in request.form and 'phone_number' in request.form and 'dob' in request.form and 'card_number' in request.form and 'card_holder' in request.form and 'card_expire_date' in request.form and 'card_cvv' in request.form:

        profile['username'] = request.form['username']
        profile['user_password'] = request.form['user_password']
        profile['firstname'] = request.form['firstname']
        profile['lastname'] = request.form['lastname']
        profile['email'] = request.form['email']
        profile['phone_number'] = request.form['phone_number']
        profile['title'] = request.form['title']
        profile['dob'] = request.form['dob']
        profile['health_info'] = request.form['health_info']
        profile['user_position'] = request.form['user_position']
        if request.form.get('subscription_type') == 'on':
            profile['subscription_type'] = 'monthly'
        else:
            profile['subscription_type'] = 'annually'
        profile['card_number'] = request.form['card_number']
        profile['card_holder'] = request.form['card_holder']
        profile['card_expire_date'] = request.form['card_expire_date']
        profile['card_cvv'] = request.form['card_cvv']

        cursor = getCursor()
        cursor.execute('SELECT username FROM members WHERE username=%s', (profile['username'],))
        account = cursor.fetchone()

        if account:
            msg_obj['msg_field'] = 'username'
            msg_obj['msg'] = 'Account already exists!'
        elif not re.match(r'[^@]+@[^@]+\.[^@]+', profile['email']):
            msg_obj['msg_field'] = 'email'
            msg_obj['msg'] = 'Invalid email address!'
        elif not re.match(r'[A-Za-z0-9]{5,}', profile['username']):
            msg_obj['msg_field'] = 'username'
            msg_obj['msg'] = 'Username must be at least 5 characters long and contain only characters and numbers!'
        elif not re.match(r'^(?=.*[a-zA-Z])(?=.*\d).{8,}$', profile['user_password']):
            msg_obj['msg_field'] = 'user_password'
            msg_obj[
                'msg'] = 'Password must be at least 8 characters long and contain at least 1 character and 1 number!'
        elif not re.match(r'^(\+\d{1,2}\s*)?(\d{3,4}-?)?\d{7,8}$', profile['phone_number']):
            msg_obj['msg_field'] = 'phone_number'
            msg_obj['msg'] = 'Please enter a correct phone number!'
        elif is_underage(profile['dob']):
            msg_obj['msg_field'] = 'dob'
            msg_obj['msg'] = 'You are not allowed to regiser if you are underage!'
        elif not profile['card_number'] or not profile['card_holder'] or not profile['card_expire_date'] or not profile[
            'card_cvv']:
            msg_obj['msg'] = 'Please fill out the payment form!'
        elif len(profile['card_number']) < 16:
            msg_obj['msg_field'] = 'card_number'
            msg_obj['msg'] = 'Please enter the complete bank card number!'
        elif not profile['card_holder']:
            msg_obj['msg_field'] = 'card_holder'
            msg_obj['msg'] = 'Please enter the card holder name!'
        elif is_expired(profile['card_expire_date']):
            msg_obj['msg_field'] = 'card_expire_date'
            msg_obj['msg'] = 'Your bank card is expired!'
        elif len(profile['card_cvv']) < 3:
            msg_obj['msg_field'] = 'card_cvv'
            msg_obj['msg'] = 'Please enter the complete CVV number!'
        elif not profile['username'] or not profile['user_password'] or not profile['firstname'] or not profile[
            'lastname'] or not profile['phone_number'] or not profile['email'] or not profile['dob']:
            msg_obj['msg_field'] = 'global'
            msg_obj['msg'] = 'Please fill out the form!'
        else:
            
            hashed_password = hashing.hash_value(profile['user_password'], salt='orion')
            
            cursor.execute(
                'INSERT INTO members (username, user_password, title, firstname, lastname, phone_number, email, dob, health_info, profile_image, user_position) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)',
                (profile['username'], hashed_password, profile['title'], profile['firstname'], profile['lastname'],
                 profile['phone_number'], profile['email'], profile['dob'], profile['health_info'], '',
                 profile['user_position'],))

            new_member_id = cursor.lastrowid
            paid_date = datetime.now().date().strftime("%Y-%m-%d")
            payment_amount = 167.00
            if profile['subscription_type'] == 'annually':
                payment_amount = 2000.00
            cursor.execute('INSERT INTO sub_payment (paid, paid_date, member_id,payment_amount) VALUES (%s, %s, %s, %s)', (True, paid_date, new_member_id, payment_amount))

            new_payment_id = cursor.lastrowid
            sub_end_date = get_sub_end_date(paid_date, profile['subscription_type'])
            annual_sub = False
            monthly_sub = True
            if profile['subscription_type'] == 'annually':
                annual_sub = True
                monthly_sub = False

            cursor.execute(
                'INSERT INTO subscription (annual_sub, monthly_sub, sub_start_date, sub_end_date, member_id, payment_id) VALUES (%s, %s, %s, %s, %s ,%s)',
                (annual_sub, monthly_sub, paid_date, sub_end_date, new_member_id, new_payment_id))

            connection.commit()

            msg_obj['msg_field'] = 'global'
            msg_obj['msg_type'] = 'success'
            msg_obj['msg'] = 'You have successfully registered!'

            profile = {
                'username': '',
                'password': '',
                'confirmpassword': '',
                'firstname': '',
                'lastname': '',
                'email': '',
                'phone': '',
                'title': '',
                'dob': '',
                'health_info': '',
                'profile_img': '',
                'user_position': '',
                'subscription_type': '',
                'card_number': '',
                'card_holder': '',
                'card_expire_date': '',
                'card_cvv': '',
            }
    elif request.method == 'POST':
        msg_obj['msg_field'] = 'global'
        msg_obj['msg'] = 'Please fill out the form!'
    return render_template('register.html', msg_obj=msg_obj, profile=profile)


@app.route("/login", methods=['GET', 'POST'])
def login():
    if session.get("loggined") == True:
        return "You have loginned"
    msg = ''
    if request.method == 'POST':
        username = request.form.get('username')
        input_password = request.form.get('password')
        loginAs = request.form.get('loginAs')
        cursor = getCursor()
        queryStr = ""
        if loginAs == "member":
            queryStr = 'SELECT member_id, username,user_password, title, firstname, lastname FROM members where members.username = %s'
        if loginAs == "manager":
            queryStr = 'SELECT manager_id, username, user_password FROM manager where username = %s'
        if loginAs == "therapists":
            queryStr = 'SELECT therapists_id, username, user_password FROM therapists where username = %s'
        cursor.execute(queryStr, (username,))
        account = cursor.fetchone()
        if account is not None:
            password = account[2]
            if hashing.check_value(password, input_password, salt = "orion"):
                session["user_id"] = account[0]
                session["loggined"] = True
                session["user_name"] = account[1]
                session["user_role"] = loginAs
                if loginAs == "member":
                    return redirect(url_for('member_dashboard'))
                if loginAs == "manager":
                    return redirect(url_for('manager_dashboard'))
                if loginAs == "therapists":
                    return redirect(url_for('therapist.therapist_dashboard'))
            else:
                msg = 'Incorrect password!'
        else:
            msg = "Account Not Exist"
    user_role = session.get("user_role")
    logined = session.get("loggined")
    return render_template("login.html", msg=msg, user_role=user_role, logined=logined, active_item=None)


@app.route('/logout')
def logout():
    session.pop('loggined', None)
    session.pop('user_role', None)
    return redirect(url_for('home'))


@app.route('/profile_edit_member/', methods=['GET', 'POST'])
def profile_edit_member():
    # Handle the GET request: display the member's current information
    if request.method == "GET":
        member_id = request.args.get('member_id') or session.get("user_id")
        connection = getCursor()
        query = 'SELECT * FROM members WHERE member_id = %s'
        connection.execute(query, (member_id,))

        member = connection.fetchone()
        return render_template("profile_edit_member.html", member=member)
    # Handle the POST request: update the member's information based on the form input
    else:
        # Extract form data
        username = request.form.get("username")
        title = request.form.get("title")
        firstname = request.form.get("firstname")
        lastname = request.form.get("lastname")
        email = request.form.get("email")
        phone_number = request.form.get("phone_number")
        dob = request.form.get("dob")
        health_info = request.form.get("health_info")
        # Ensure all required fields are filled
        if username is None or firstname is None or lastname is None or email is None or phone_number is None or dob is None:
            msg = 'Please complete all required fields!'
            return render_template("profile_edit_member.html", msg=msg)
        # Validate email and phone number formats using regex
        email_regex = r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)"
        if not re.match(email_regex, email):
            msg = 'Invalid email format!'
            return render_template("profile_edit_member.html", msg=msg, member=request.form)

        phone_regex = r"^\+?1?\d{3,15}$"
        if not re.match(phone_regex, phone_number):
            msg = 'Invalid phone number format!'
            return render_template("profile_edit_member.html", msg=msg, member=request.form)
        # Handle profile image upload
        img_file_name = None
        if request.files.__len__() > 0:
            image_file = request.files['profile_img']
            if image_file is not None and image_file.filename != '':
                dot_idx = image_file.filename.find(".")
                filename = str(int(time.time())) + "_" + str(get_random_string()) + image_file.filename[dot_idx:]
                image_file.save(os.path.join('static/upload/', filename))
                img_file_name = filename
                print("file upload successfully ：" + str(filename))
        # Update the member's data in the database
        member_id = session.get("user_id")
        connection = getCursor()
        if img_file_name:
            query = 'UPDATE members SET username= %s, title = %s, firstname= %s, lastname= %s, phone_number=%s, email=%s, dob=%s, health_info= %s, profile_image = %s WHERE member_id= %s'
            connection.execute(query, (
                username, title, firstname, lastname, phone_number, email, dob, health_info, img_file_name, member_id))
        else:
            query = 'UPDATE members SET username= %s, title = %s, firstname= %s, lastname= %s, phone_number=%s, email=%s, dob=%s, health_info= %s WHERE member_id= %s'
            connection.execute(query,
                               (username, title, firstname, lastname, phone_number, email, dob, health_info, member_id))
    # Fetch the updated member data to confirm the changes
    query = 'SELECT * FROM members WHERE member_id = %s'
    connection.execute(query, (member_id,))
    member = connection.fetchone()
    # Notify the user of a successful update
    msg = "Update Success!"
    return render_template("/profile_edit_member.html", msg=msg, member=member)


def get_random_string():  # def for rename the images uploaded
    len = 6
    charset = 'abcdefghijklmnopqrstuvwxyz0123456789'
    random_string = ''.join(random.choices(charset, k=len))
    return random_string


@app.route('/member_dashboard')
def member_dashboard():
    if 'loggined' not in session or session.get('user_role') != 'member':
        return redirect(url_for('login'))
    return render_template('member_dashboard.html')


@app.route('/manager_dashboard')
def manager_dashboard():
    if 'loggined' not in session or session.get('user_role') != 'manager':
        return redirect(url_for('login'))
    return render_template('manager/manager_dashboard.html')


@app.route('/member_update_password', methods=['GET', 'POST'])
def member_update_password():
    if session.get("loggined") != True:
        flash('Please login to update your password.', 'info')
        return redirect(url_for('login'))

    profile = {
        'current_password': '',
        'new_password': '',
        'confirm_new_password': '',
    }
    msg_obj = {
        'msg_field': '',
        'msg': '',
        'msg_type': 'danger',
    }

    if request.method == 'POST':
        profile['current_password'] = request.form['current_password']
        profile['new_password'] = request.form['new_password']
        profile['confirm_new_password'] = request.form['confirm_new_password']
        username = session.get("user_name")

        cursor = connection.cursor(dictionary=True)
        cursor.execute('SELECT user_password FROM members WHERE username=%s', (username,))
        account = cursor.fetchone()

        if not account:
            msg_obj['msg_field'] = 'username'
            msg_obj['msg'] = 'Account does not exist!'
        elif account and account['user_password'] != profile['current_password']:
            msg_obj['msg_field'] = 'current_password'
            msg_obj['msg'] = 'Current password is incorrect!'
        elif profile['new_password'] != profile['confirm_new_password']:
            msg_obj['msg_field'] = 'confirm_new_password'
            msg_obj['msg'] = 'New password and confirm new password do not match!'
        elif not re.match(r'^(?=.*[a-zA-Z])(?=.*\d).{8,}$', profile['new_password']):
            msg_obj['msg_field'] = 'new_password'
            msg_obj['msg'] = 'Password must be at least 8 characters long and contain at least 1 letter and 1 number!'
        else:
            hashed_password = hashing.hash_value(profile['new_password'], salt='orion')
            cursor.execute('UPDATE members SET user_password=%s WHERE username=%s', (hashed_password, username,))
            connection.commit()

            msg_obj['msg_field'] = 'global'
            msg_obj['msg_type'] = 'success'
            msg_obj['msg'] = 'Your password has been successfully updated!'

            return redirect(url_for('member_dashboard'))

    return render_template('member_update_password.html', msg_obj=msg_obj, profile=profile)


def getDictCursor():
    global connection
    if connection is None or not connection.is_connected():
        connection = mysql.connector.connect(
            user=connect.dbuser,
            password=connect.dbpass,
            host=connect.dbhost,
            database=connect.dbname,
            autocommit=True
        )
    return connection.cursor(dictionary=True)


@app.route('/view_therapeutic_sessions')
def view_therapeutic_sessions():
    if 'loggined' not in session or session.get('user_role') != 'member':
        flash("Please login as a member to view available therapeutic sessions.", "warning")
        return redirect(url_for('login'))

    cursor = getDictCursor()

    query = """
    SELECT 
        ts.session_id, 
        ts.start_time, 
        ts.end_time, 
        ts.session_length, 
        t.therapeutic_type, 
        t.therapeutic_description, 
        l.descriptions as location, 
        ts.booked,
        th.firstname as therapist_firstname, 
        th.lastname as therapist_lastname
    FROM therapeutic_session ts
    JOIN therapeutic t ON ts.therapeutic_id = t.therapeutic_id
    JOIN locations l ON ts.location_id = l.location_id
    JOIN therapists th ON ts.therapists_id = th.therapists_id
    WHERE ts.booked = false
    ORDER BY ts.start_time;
    """
    cursor.execute(query)
    sessions = cursor.fetchall()

    return render_template('view_therapeutic_sessions.html', sessions=sessions)


@app.route('/classes')
def classes():
    cursor = getCursor()
    cursor.execute(
        'SELECT class_id, class_name, class_description, firstname, lastname, image_name FROM wellness_class JOIN therapists on wellness_class.class_therapist_id=therapists_id;')
    classes = cursor.fetchall()
    return render_template('visitors/classes.html', classes=classes)


@app.route('/classes/book')
def class_book():
    today = datetime.today().strftime('%Y-%m-%d')
    member_id = session.get("user_id")
    cursor = getCursor()
    cursor.execute(
        'SELECT cs.session_id, DATE_FORMAT(cs.start_time, "%H:%i") as start_time, DATE_FORMAT(cs.end_time, "%H:%i") as end_time, cs.capacity, wc.class_name, l.descriptions FROM class_session cs JOIN wellness_class wc ON cs.class_id = wc.class_id JOIN locations l ON cs.location_id = l.location_id ORDER BY cs.start_time;')
    sessions = cursor.fetchall()
    return render_template('visitors/class_book.html', sessions=sessions, today=today, member_id=member_id)


@app.route('/save_booking', methods=['POST'])
def save_booking():
    if session.get("loggined") != True or session.get("user_role") != "member":
      return redirect(url_for("login"))
    member_id = request.form['member_id']
    session_id = request.form['session_id']
    selected_date = request.form['selected_date']

    date_object = datetime.strptime(selected_date, '%Y-%m-%d').date()

    sql = "INSERT INTO class_session_booking (member_id, session_id, session_date) VALUES (%s, %s, %s)"
    values = (member_id, session_id, date_object)
    cursor = getCursor()
    cursor.execute(sql, values)
    flash('The session has been booked successfully', 'info')
    return redirect(url_for('class_book'))



@app.route('/therapist_list')
def therapist_list():
    return render_template('therapist/therapist_list.html')






