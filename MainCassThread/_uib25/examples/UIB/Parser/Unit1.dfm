object Form1: TForm1
  Left = 199
  Top = 113
  Width = 624
  Height = 632
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 576
    Width = 75
    Height = 25
    Caption = 'Parse'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 320
    Width = 577
    Height = 249
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object Memo2: TMemo
    Left = 8
    Top = 32
    Width = 577
    Height = 281
    Lines.Strings = (
      
        '/***************************************************************' +
        '***************/'
      
        '/****         Generated by IBExpert 2004.12.14 03/01/2005 20:59:' +
        '59         ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      'SET SQL DIALECT 3;'
      ''
      'SET NAMES NONE;'
      ''
      
        'CREATE DATABASE '#39'C:\Program Files\Firebird\Firebird_1_5\examples' +
        '\EMPLOYEE.FDB'#39
      'USER '#39'SYSDBA'#39' PASSWORD '#39'masterkey'#39
      'PAGE_SIZE 4096'
      'DEFAULT CHARACTER SET NONE;'
      ''
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                               Domains                     ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      'CREATE DOMAIN ADDRESSLINE AS'
      'VARCHAR(30);'
      ''
      'CREATE DOMAIN BUDGET AS'
      'DECIMAL(12,2)'
      'DEFAULT 50000'
      'CHECK (VALUE > 10000 AND VALUE <= 2000000);'
      ''
      'CREATE DOMAIN COUNTRYNAME AS'
      'VARCHAR(15);'
      ''
      'CREATE DOMAIN CUSTNO AS'
      'INTEGER'
      'CHECK (VALUE > 1000);'
      ''
      'CREATE DOMAIN DEPTNO AS'
      'CHAR(3)'
      
        'CHECK (VALUE = '#39'000'#39' OR (VALUE > '#39'0'#39' AND VALUE <= '#39'999'#39') OR VALU' +
        'E IS NULL);'
      ''
      'CREATE DOMAIN EMPNO AS'
      'SMALLINT;'
      ''
      'CREATE DOMAIN FIRSTNAME AS'
      'VARCHAR(15);'
      ''
      'CREATE DOMAIN JOBCODE AS'
      'VARCHAR(5)'
      'CHECK (VALUE > '#39'99999'#39');'
      ''
      'CREATE DOMAIN JOBGRADE AS'
      'SMALLINT'
      'CHECK (VALUE BETWEEN 0 AND 6);'
      ''
      'CREATE DOMAIN LASTNAME AS'
      'VARCHAR(20);'
      ''
      'CREATE DOMAIN PHONENUMBER AS'
      'VARCHAR(20);'
      ''
      'CREATE DOMAIN PONUMBER AS'
      'CHAR(8)'
      'CHECK (VALUE STARTING WITH '#39'V'#39');'
      ''
      'CREATE DOMAIN PRODTYPE AS'
      'VARCHAR(12)'
      'DEFAULT '#39'software'#39
      'NOT NULL'
      'CHECK (VALUE IN ('#39'software'#39', '#39'hardware'#39', '#39'other'#39', '#39'N/A'#39'));'
      ''
      'CREATE DOMAIN PROJNO AS'
      'CHAR(5)'
      'CHECK (VALUE = UPPER (VALUE));'
      ''
      'CREATE DOMAIN SALARY AS'
      'NUMERIC(10,2)'
      'DEFAULT 0'
      'CHECK (VALUE > 0);'
      ''
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                              Generators                   ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      'CREATE GENERATOR CUST_NO_GEN;'
      'SET GENERATOR CUST_NO_GEN TO 1015;'
      ''
      'CREATE GENERATOR EMP_NO_GEN;'
      'SET GENERATOR EMP_NO_GEN TO 145;'
      ''
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                              Exceptions                   ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      
        'CREATE EXCEPTION CUSTOMER_CHECK '#39'Overdue balance -- can not ship' +
        '.'#39';'
      ''
      'CREATE EXCEPTION CUSTOMER_ON_HOLD '#39'This customer is on hold.'#39';'
      ''
      
        'CREATE EXCEPTION ORDER_ALREADY_SHIPPED '#39'Order status is "shipped' +
        '."'#39';'
      ''
      
        'CREATE EXCEPTION REASSIGN_SALES '#39'Reassign the sales records befo' +
        're deleting this employee.'#39';'
      ''
      
        'CREATE EXCEPTION UNKNOWN_EMP_ID '#39'Invalid employee number or proj' +
        'ect id.'#39';'
      ''
      ''
      ''
      ''
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                          Stored Procedures                ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      'CREATE PROCEDURE ADD_EMP_PROJ ('
      '    EMP_NO SMALLINT,'
      '    PROJ_ID CHAR(5))'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      'CREATE PROCEDURE ALL_LANGS'
      'RETURNS ('
      '    CODE VARCHAR(5),'
      '    GRADE VARCHAR(5),'
      '    COUNTRY VARCHAR(15),'
      '    LANG VARCHAR(15))'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      'CREATE PROCEDURE DELETE_EMPLOYEE ('
      '    EMP_NUM INTEGER)'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      'CREATE PROCEDURE DEPT_BUDGET ('
      '    DNO CHAR(3))'
      'RETURNS ('
      '    TOT DECIMAL(12,2))'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      'CREATE PROCEDURE GET_EMP_PROJ ('
      '    EMP_NO SMALLINT)'
      'RETURNS ('
      '    PROJ_ID CHAR(5))'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      'CREATE PROCEDURE MAIL_LABEL ('
      '    CUST_NO INTEGER)'
      'RETURNS ('
      '    LINE1 CHAR(40),'
      '    LINE2 CHAR(40),'
      '    LINE3 CHAR(40),'
      '    LINE4 CHAR(40),'
      '    LINE5 CHAR(40),'
      '    LINE6 CHAR(40))'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      'CREATE PROCEDURE ORG_CHART'
      'RETURNS ('
      '    HEAD_DEPT CHAR(25),'
      '    DEPARTMENT CHAR(25),'
      '    MNGR_NAME CHAR(20),'
      '    TITLE CHAR(5),'
      '    EMP_CNT INTEGER)'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      'CREATE PROCEDURE SHIP_ORDER ('
      '    PO_NUM CHAR(8))'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      'CREATE PROCEDURE SHOW_LANGS ('
      '    CODE VARCHAR(5),'
      '    GRADE SMALLINT,'
      '    CTY VARCHAR(15))'
      'RETURNS ('
      '    LANGUAGES VARCHAR(15))'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      'CREATE PROCEDURE SUB_TOT_BUDGET ('
      '    HEAD_DEPT CHAR(3))'
      'RETURNS ('
      '    TOT_BUDGET DECIMAL(12,2),'
      '    AVG_BUDGET DECIMAL(12,2),'
      '    MIN_BUDGET DECIMAL(12,2),'
      '    MAX_BUDGET DECIMAL(12,2))'
      'AS'
      'BEGIN'
      '  EXIT;'
      'END;'
      ''
      ''
      ''
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                                Tables                     ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      ''
      ''
      'CREATE TABLE COUNTRY ('
      '    COUNTRY   COUNTRYNAME NOT NULL,'
      '    CURRENCY  VARCHAR(10) NOT NULL'
      ');'
      ''
      ''
      'CREATE TABLE CUSTOMER ('
      '    CUST_NO         CUSTNO NOT NULL,'
      '    CUSTOMER        VARCHAR(25) NOT NULL,'
      '    CONTACT_FIRST   FIRSTNAME,'
      '    CONTACT_LAST    LASTNAME,'
      '    PHONE_NO        PHONENUMBER,'
      '    ADDRESS_LINE1   ADDRESSLINE,'
      '    ADDRESS_LINE2   ADDRESSLINE,'
      '    CITY            VARCHAR(25),'
      '    STATE_PROVINCE  VARCHAR(15),'
      '    COUNTRY         COUNTRYNAME,'
      '    POSTAL_CODE     VARCHAR(12),'
      '    ON_HOLD         CHAR(1) DEFAULT NULL'
      ');'
      ''
      ''
      'CREATE TABLE DEPARTMENT ('
      '    DEPT_NO     DEPTNO NOT NULL,'
      '    DEPARTMENT  VARCHAR(25) NOT NULL,'
      '    HEAD_DEPT   DEPTNO,'
      '    MNGR_NO     EMPNO,'
      '    BUDGET      BUDGET,'
      '    LOCATION    VARCHAR(15),'
      '    PHONE_NO    PHONENUMBER DEFAULT '#39'555-1234'#39
      ');'
      ''
      ''
      'CREATE TABLE EMPLOYEE ('
      '    EMP_NO       EMPNO NOT NULL,'
      '    FIRST_NAME   FIRSTNAME NOT NULL,'
      '    LAST_NAME    LASTNAME NOT NULL,'
      '    PHONE_EXT    VARCHAR(4),'
      '    HIRE_DATE    TIMESTAMP DEFAULT '#39'NOW'#39' NOT NULL,'
      '    DEPT_NO      DEPTNO NOT NULL,'
      '    JOB_CODE     JOBCODE NOT NULL,'
      '    JOB_GRADE    JOBGRADE NOT NULL,'
      '    JOB_COUNTRY  COUNTRYNAME NOT NULL,'
      '    SALARY       SALARY NOT NULL,'
      '    FULL_NAME    COMPUTED BY (last_name || '#39', '#39' || first_name)'
      ');'
      ''
      ''
      'CREATE TABLE EMPLOYEE_PROJECT ('
      '    EMP_NO   EMPNO NOT NULL,'
      '    PROJ_ID  PROJNO NOT NULL'
      ');'
      ''
      ''
      'CREATE TABLE JOB ('
      '    JOB_CODE         JOBCODE NOT NULL,'
      '    JOB_GRADE        JOBGRADE NOT NULL,'
      '    JOB_COUNTRY      COUNTRYNAME NOT NULL,'
      '    JOB_TITLE        VARCHAR(25) NOT NULL,'
      '    MIN_SALARY       SALARY NOT NULL,'
      '    MAX_SALARY       SALARY NOT NULL,'
      '    JOB_REQUIREMENT  BLOB SUB_TYPE 1 SEGMENT SIZE 400,'
      '    LANGUAGE_REQ     VARCHAR(15) [1:5]'
      ');'
      ''
      ''
      'CREATE TABLE PROJ_DEPT_BUDGET ('
      '    FISCAL_YEAR       INTEGER NOT NULL,'
      '    PROJ_ID           PROJNO NOT NULL,'
      '    DEPT_NO           DEPTNO NOT NULL,'
      '    QUART_HEAD_CNT    INTEGER [1:4],'
      '    PROJECTED_BUDGET  BUDGET'
      ');'
      ''
      ''
      'CREATE TABLE PROJECT ('
      '    PROJ_ID      PROJNO NOT NULL,'
      '    PROJ_NAME    VARCHAR(20) NOT NULL,'
      '    PROJ_DESC    BLOB SUB_TYPE 1 SEGMENT SIZE 800,'
      '    TEAM_LEADER  EMPNO,'
      '    PRODUCT      PRODTYPE'
      ');'
      ''
      ''
      'CREATE TABLE SALARY_HISTORY ('
      '    EMP_NO          EMPNO NOT NULL,'
      '    CHANGE_DATE     TIMESTAMP DEFAULT '#39'NOW'#39' NOT NULL,'
      '    UPDATER_ID      VARCHAR(20) NOT NULL,'
      '    OLD_SALARY      SALARY NOT NULL,'
      '    PERCENT_CHANGE  DOUBLE PRECISION DEFAULT 0 NOT NULL,'
      
        '    NEW_SALARY      COMPUTED BY (old_salary + old_salary * perce' +
        'nt_change / 100)'
      ');'
      ''
      ''
      'CREATE TABLE SALES ('
      '    PO_NUMBER     PONUMBER NOT NULL,'
      '    CUST_NO       CUSTNO NOT NULL,'
      '    SALES_REP     EMPNO,'
      '    ORDER_STATUS  VARCHAR(7) DEFAULT '#39'new'#39' NOT NULL,'
      '    ORDER_DATE    TIMESTAMP DEFAULT '#39'NOW'#39' NOT NULL,'
      '    SHIP_DATE     TIMESTAMP,'
      '    DATE_NEEDED   TIMESTAMP,'
      '    PAID          CHAR(1) DEFAULT '#39'n'#39','
      '    QTY_ORDERED   INTEGER DEFAULT 1 NOT NULL,'
      '    TOTAL_VALUE   DECIMAL(9,2) NOT NULL,'
      '    DISCOUNT      FLOAT DEFAULT 0 NOT NULL,'
      '    ITEM_TYPE     PRODTYPE,'
      '    AGED          COMPUTED BY (ship_date - order_date)'
      ');'
      ''
      ''
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                                Views                      ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      ''
      '/* View: PHONE_LIST */'
      'CREATE VIEW PHONE_LIST('
      '    EMP_NO,'
      '    FIRST_NAME,'
      '    LAST_NAME,'
      '    PHONE_EXT,'
      '    LOCATION,'
      '    PHONE_NO)'
      'AS'
      'SELECT'
      '    emp_no, first_name, last_name, phone_ext, location, phone_no'
      '    FROM employee, department'
      '    WHERE employee.dept_no = department.dept_no'
      ';'
      ''
      ''
      ''
      ''
      '/* Check constraints definition */'
      ''
      'ALTER TABLE JOB ADD CHECK (min_salary < max_salary);'
      
        'ALTER TABLE EMPLOYEE ADD CHECK ( salary >= (SELECT min_salary FR' +
        'OM job WHERE'
      '                        job.job_code = employee.job_code AND'
      '                        job.job_grade = employee.job_grade AND'
      
        '                        job.job_country = employee.job_country) ' +
        'AND'
      '            salary <= (SELECT max_salary FROM job WHERE'
      '                        job.job_code = employee.job_code AND'
      '                        job.job_grade = employee.job_grade AND'
      
        '                        job.job_country = employee.job_country))' +
        ';'
      'ALTER TABLE PROJ_DEPT_BUDGET ADD CHECK (FISCAL_YEAR >= 1993);'
      
        'ALTER TABLE SALARY_HISTORY ADD CHECK (percent_change between -50' +
        ' and 50);'
      
        'ALTER TABLE CUSTOMER ADD CHECK (on_hold IS NULL OR on_hold = '#39'*'#39 +
        ');'
      'ALTER TABLE SALES ADD CHECK (order_status in'
      
        '                            ('#39'new'#39', '#39'open'#39', '#39'shipped'#39', '#39'waiting'#39 +
        '));'
      
        'ALTER TABLE SALES ADD CHECK (ship_date >= order_date OR ship_dat' +
        'e IS NULL);'
      
        'ALTER TABLE SALES ADD CHECK (date_needed > order_date OR date_ne' +
        'eded IS NULL);'
      'ALTER TABLE SALES ADD CHECK (paid in ('#39'y'#39', '#39'n'#39'));'
      'ALTER TABLE SALES ADD CHECK (qty_ordered >= 1);'
      'ALTER TABLE SALES ADD CHECK (total_value >= 0);'
      'ALTER TABLE SALES ADD CHECK (discount >= 0 AND discount <= 1);'
      
        'ALTER TABLE SALES ADD CHECK (NOT (order_status = '#39'shipped'#39' AND s' +
        'hip_date IS NULL));'
      'ALTER TABLE SALES ADD CHECK (NOT (order_status = '#39'shipped'#39' AND'
      '            EXISTS (SELECT on_hold FROM customer'
      '                    WHERE customer.cust_no = sales.cust_no'
      '                    AND customer.on_hold = '#39'*'#39')));'
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                          Unique Constraints               ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      'ALTER TABLE DEPARTMENT ADD UNIQUE (DEPARTMENT);'
      'ALTER TABLE PROJECT ADD UNIQUE (PROJ_NAME);'
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                             Primary Keys                  ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      'ALTER TABLE COUNTRY ADD PRIMARY KEY (COUNTRY);'
      'ALTER TABLE CUSTOMER ADD PRIMARY KEY (CUST_NO);'
      'ALTER TABLE DEPARTMENT ADD PRIMARY KEY (DEPT_NO);'
      'ALTER TABLE EMPLOYEE ADD PRIMARY KEY (EMP_NO);'
      'ALTER TABLE EMPLOYEE_PROJECT ADD PRIMARY KEY (EMP_NO, PROJ_ID);'
      
        'ALTER TABLE JOB ADD PRIMARY KEY (JOB_CODE, JOB_GRADE, JOB_COUNTR' +
        'Y);'
      'ALTER TABLE PROJECT ADD PRIMARY KEY (PROJ_ID);'
      
        'ALTER TABLE PROJ_DEPT_BUDGET ADD PRIMARY KEY (FISCAL_YEAR, PROJ_' +
        'ID, DEPT_NO);'
      
        'ALTER TABLE SALARY_HISTORY ADD PRIMARY KEY (EMP_NO, CHANGE_DATE,' +
        ' UPDATER_ID);'
      'ALTER TABLE SALES ADD PRIMARY KEY (PO_NUMBER);'
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                             Foreign Keys                  ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      
        'ALTER TABLE CUSTOMER ADD FOREIGN KEY (COUNTRY) REFERENCES COUNTR' +
        'Y (COUNTRY);'
      
        'ALTER TABLE DEPARTMENT ADD FOREIGN KEY (HEAD_DEPT) REFERENCES DE' +
        'PARTMENT (DEPT_NO);'
      
        'ALTER TABLE DEPARTMENT ADD FOREIGN KEY (MNGR_NO) REFERENCES EMPL' +
        'OYEE (EMP_NO);'
      
        'ALTER TABLE EMPLOYEE ADD FOREIGN KEY (DEPT_NO) REFERENCES DEPART' +
        'MENT (DEPT_NO);'
      
        'ALTER TABLE EMPLOYEE ADD FOREIGN KEY (JOB_CODE, JOB_GRADE, JOB_C' +
        'OUNTRY) REFERENCES JOB (JOB_CODE, JOB_GRADE, JOB_COUNTRY);'
      
        'ALTER TABLE EMPLOYEE_PROJECT ADD FOREIGN KEY (EMP_NO) REFERENCES' +
        ' EMPLOYEE (EMP_NO);'
      
        'ALTER TABLE EMPLOYEE_PROJECT ADD FOREIGN KEY (PROJ_ID) REFERENCE' +
        'S PROJECT (PROJ_ID);'
      
        'ALTER TABLE JOB ADD FOREIGN KEY (JOB_COUNTRY) REFERENCES COUNTRY' +
        ' (COUNTRY);'
      
        'ALTER TABLE PROJECT ADD FOREIGN KEY (TEAM_LEADER) REFERENCES EMP' +
        'LOYEE (EMP_NO);'
      
        'ALTER TABLE PROJ_DEPT_BUDGET ADD FOREIGN KEY (DEPT_NO) REFERENCE' +
        'S DEPARTMENT (DEPT_NO);'
      
        'ALTER TABLE PROJ_DEPT_BUDGET ADD FOREIGN KEY (PROJ_ID) REFERENCE' +
        'S PROJECT (PROJ_ID);'
      
        'ALTER TABLE SALARY_HISTORY ADD FOREIGN KEY (EMP_NO) REFERENCES E' +
        'MPLOYEE (EMP_NO);'
      
        'ALTER TABLE SALES ADD FOREIGN KEY (CUST_NO) REFERENCES CUSTOMER ' +
        '(CUST_NO);'
      
        'ALTER TABLE SALES ADD FOREIGN KEY (SALES_REP) REFERENCES EMPLOYE' +
        'E (EMP_NO);'
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                               Indices                     ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      'CREATE INDEX CUSTNAMEX ON CUSTOMER (CUSTOMER);'
      'CREATE INDEX CUSTREGION ON CUSTOMER (COUNTRY, CITY);'
      'CREATE DESCENDING INDEX BUDGETX ON DEPARTMENT (BUDGET);'
      'CREATE INDEX NAMEX ON EMPLOYEE (LAST_NAME, FIRST_NAME);'
      
        'CREATE DESCENDING INDEX MAXSALX ON JOB (JOB_COUNTRY, MAX_SALARY)' +
        ';'
      'CREATE INDEX MINSALX ON JOB (JOB_COUNTRY, MIN_SALARY);'
      'CREATE UNIQUE INDEX PRODTYPEX ON PROJECT (PRODUCT, PROJ_NAME);'
      'CREATE DESCENDING INDEX CHANGEX ON SALARY_HISTORY (CHANGE_DATE);'
      'CREATE INDEX UPDATERX ON SALARY_HISTORY (UPDATER_ID);'
      'CREATE INDEX NEEDX ON SALES (DATE_NEEDED);'
      'CREATE DESCENDING INDEX QTYX ON SALES (ITEM_TYPE, QTY_ORDERED);'
      'CREATE INDEX SALESTATX ON SALES (ORDER_STATUS, PAID);'
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                               Triggers                    ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      ''
      ''
      ''
      ''
      ''
      '/* Trigger: POST_NEW_ORDER */'
      'CREATE TRIGGER POST_NEW_ORDER FOR SALES'
      'ACTIVE AFTER INSERT POSITION 0'
      'AS'
      'BEGIN'
      '    POST_EVENT '#39'new_order'#39';'
      'END;'
      ''
      '/* Trigger: SAVE_SALARY_CHANGE */'
      'CREATE TRIGGER SAVE_SALARY_CHANGE FOR EMPLOYEE'
      'ACTIVE AFTER UPDATE POSITION 0'
      'AS'
      'BEGIN'
      '    IF (old.salary <> new.salary) THEN'
      '        INSERT INTO salary_history'
      
        '            (emp_no, change_date, updater_id, old_salary, percen' +
        't_change)'
      '        VALUES ('
      '            old.emp_no,'
      '            '#39'NOW'#39','
      '            user,'
      '            old.salary,'
      '            (new.salary - old.salary) * 100 / old.salary);'
      'END;'
      ''
      '/* Trigger: SET_CUST_NO */'
      'CREATE TRIGGER SET_CUST_NO FOR CUSTOMER'
      'ACTIVE BEFORE INSERT POSITION 0'
      'AS'
      'BEGIN'
      '    /* FIXED by helebor 19.01.2004 */'
      '    if (new.cust_no is null) then'
      '    new.cust_no = gen_id(cust_no_gen, 1);'
      'END;'
      ''
      '/* Trigger: SET_EMP_NO */'
      'CREATE TRIGGER SET_EMP_NO FOR EMPLOYEE'
      'ACTIVE BEFORE INSERT POSITION 0'
      'AS'
      'BEGIN'
      '    /* FIXED by helebor 19.01.2004 */'
      '    if (new.emp_no is null) then'
      '    new.emp_no = gen_id(emp_no_gen, 1);'
      'END;'
      ''
      ''
      ''
      ''
      ''
      
        '/***************************************************************' +
        '***************/'
      
        '/****                          Stored Procedures                ' +
        '           ****/'
      
        '/***************************************************************' +
        '***************/'
      ''
      ''
      ''
      'ALTER PROCEDURE ADD_EMP_PROJ ('
      '    EMP_NO SMALLINT,'
      '    PROJ_ID CHAR(5))'
      'AS'
      'BEGIN'
      '  BEGIN'
      
        '  INSERT INTO employee_project (emp_no, proj_id) VALUES (:emp_no' +
        ', :proj_id);'
      '  WHEN SQLCODE -530 DO'
      '    EXCEPTION unknown_emp_id;'
      '  END'
      '  SUSPEND;'
      'END;'
      ''
      'ALTER PROCEDURE ALL_LANGS'
      'RETURNS ('
      '    CODE VARCHAR(5),'
      '    GRADE VARCHAR(5),'
      '    COUNTRY VARCHAR(15),'
      '    LANG VARCHAR(15))'
      'AS'
      '    BEGIN'
      '  FOR SELECT job_code, job_grade, job_country FROM job '
      '    INTO :code, :grade, :country'
      ''
      '  DO'
      '  BEGIN'
      '      FOR SELECT languages FROM show_langs'
      '         (:code, :grade, :country) INTO :lang DO'
      '          SUSPEND;'
      '      /* Put nice separators between rows */'
      '      code = '#39'====='#39';'
      '      grade = '#39'====='#39';'
      '      country = '#39'==============='#39';'
      '      lang = '#39'=============='#39';'
      '      SUSPEND;'
      '  END'
      '    END;'
      ''
      'ALTER PROCEDURE DELETE_EMPLOYEE ('
      '    EMP_NUM INTEGER)'
      'AS'
      '  DECLARE VARIABLE any_sales INTEGER;'
      'BEGIN'
      '  any_sales = 0;'
      ''
      '  /*'
      '   *  If there are any sales records referencing this employee,'
      '   *  can'#39't delete the employee until the sales are re-assigned'
      '   *  to another employee or changed to NULL.'
      '   */'
      '  SELECT count(po_number)'
      '  FROM sales'
      '  WHERE sales_rep = :emp_num'
      '  INTO :any_sales;'
      ''
      '  IF (any_sales > 0) THEN'
      '  BEGIN'
      '    EXCEPTION reassign_sales;'
      '    SUSPEND;'
      '  END'
      ''
      '  /*'
      '   *  If the employee is a manager, update the department.'
      '   */'
      '  UPDATE department'
      '  SET mngr_no = NULL'
      '  WHERE mngr_no = :emp_num;'
      ''
      '  /*'
      '   *  If the employee is a project leader, update project.'
      '   */'
      '  UPDATE project'
      '  SET team_leader = NULL'
      '  WHERE team_leader = :emp_num;'
      ''
      '  /*'
      '   *  Delete the employee from any projects.'
      '   */'
      '  DELETE FROM employee_project'
      '  WHERE emp_no = :emp_num;'
      ''
      '  /*'
      '   *  Delete old salary records.'
      '   */'
      '  DELETE FROM salary_history'
      '  WHERE emp_no = :emp_num;'
      ''
      '  /*'
      '   *  Delete the employee.'
      '   */'
      '  DELETE FROM employee'
      '  WHERE emp_no = :emp_num;'
      ''
      '  SUSPEND;'
      'END;'
      ''
      'ALTER PROCEDURE DEPT_BUDGET ('
      '    DNO CHAR(3))'
      'RETURNS ('
      '    TOT DECIMAL(12,2))'
      'AS'
      '  DECLARE VARIABLE sumb DECIMAL(12, 2);'
      '  DECLARE VARIABLE rdno CHAR(3);'
      '  DECLARE VARIABLE cnt INTEGER;'
      'BEGIN'
      '  tot = 0;'
      ''
      '  SELECT budget FROM department WHERE dept_no = :dno INTO :tot;'
      ''
      
        '  SELECT count(budget) FROM department WHERE head_dept = :dno IN' +
        'TO :cnt;'
      ''
      '  IF (cnt = 0) THEN'
      '    SUSPEND;'
      ''
      '  FOR SELECT dept_no'
      '    FROM department'
      '    WHERE head_dept = :dno'
      '    INTO :rdno'
      '  DO'
      '    BEGIN'
      
        '      EXECUTE PROCEDURE dept_budget :rdno RETURNING_VALUES :sumb' +
        ';'
      '      tot = tot + sumb;'
      '    END'
      ''
      '  SUSPEND;'
      'END;'
      ''
      'ALTER PROCEDURE GET_EMP_PROJ ('
      '    EMP_NO SMALLINT)'
      'RETURNS ('
      '    PROJ_ID CHAR(5))'
      'AS'
      'BEGIN'
      '  FOR SELECT proj_id'
      '    FROM employee_project'
      '    WHERE emp_no = :emp_no'
      '    INTO :proj_id'
      '  DO'
      '    SUSPEND;'
      'END;'
      ''
      'ALTER PROCEDURE MAIL_LABEL ('
      '    CUST_NO INTEGER)'
      'RETURNS ('
      '    LINE1 CHAR(40),'
      '    LINE2 CHAR(40),'
      '    LINE3 CHAR(40),'
      '    LINE4 CHAR(40),'
      '    LINE5 CHAR(40),'
      '    LINE6 CHAR(40))'
      'AS'
      '  DECLARE VARIABLE customer  VARCHAR(25);'
      '  DECLARE VARIABLE first_name    VARCHAR(15);'
      '  DECLARE VARIABLE last_name    VARCHAR(20);'
      '  DECLARE VARIABLE addr1    VARCHAR(30);'
      '  DECLARE VARIABLE addr2    VARCHAR(30);'
      '  DECLARE VARIABLE city    VARCHAR(25);'
      '  DECLARE VARIABLE state    VARCHAR(15);'
      '  DECLARE VARIABLE country  VARCHAR(15);'
      '  DECLARE VARIABLE postcode  VARCHAR(12);'
      '  DECLARE VARIABLE cnt    INTEGER;'
      'BEGIN'
      '  line1 = '#39#39';'
      '  line2 = '#39#39';'
      '  line3 = '#39#39';'
      '  line4 = '#39#39';'
      '  line5 = '#39#39';'
      '  line6 = '#39#39';'
      ''
      '  SELECT customer, contact_first, contact_last, address_line1,'
      '    address_line2, city, state_province, country, postal_code'
      '  FROM CUSTOMER'
      '  WHERE cust_no = :cust_no'
      '  INTO :customer, :first_name, :last_name, :addr1, :addr2,'
      '    :city, :state, :country, :postcode;'
      ''
      '  IF (customer IS NOT NULL) THEN'
      '    line1 = customer;'
      '  IF (first_name IS NOT NULL) THEN'
      '    line2 = first_name || '#39' '#39' || last_name;'
      '  ELSE'
      '    line2 = last_name;'
      '  IF (addr1 IS NOT NULL) THEN'
      '    line3 = addr1;'
      '  IF (addr2 IS NOT NULL) THEN'
      '    line4 = addr2;'
      ''
      '  IF (country = '#39'USA'#39') THEN'
      '  BEGIN'
      '    IF (city IS NOT NULL) THEN'
      '      line5 = city || '#39', '#39' || state || '#39'  '#39' || postcode;'
      '    ELSE'
      '      line5 = state || '#39'  '#39' || postcode;'
      '  END'
      '  ELSE'
      '  BEGIN'
      '    IF (city IS NOT NULL) THEN'
      '      line5 = city || '#39', '#39' || state;'
      '    ELSE'
      '      line5 = state;'
      '    line6 = country || '#39'    '#39' || postcode;'
      '  END'
      ''
      '  SUSPEND;'
      'END;'
      ''
      'ALTER PROCEDURE ORG_CHART'
      'RETURNS ('
      '    HEAD_DEPT CHAR(25),'
      '    DEPARTMENT CHAR(25),'
      '    MNGR_NAME CHAR(20),'
      '    TITLE CHAR(5),'
      '    EMP_CNT INTEGER)'
      'AS'
      '  DECLARE VARIABLE mngr_no INTEGER;'
      '  DECLARE VARIABLE dno CHAR(3);'
      'BEGIN'
      '  FOR SELECT h.department, d.department, d.mngr_no, d.dept_no'
      '    FROM department d'
      '    LEFT OUTER JOIN department h ON d.head_dept = h.dept_no'
      '    ORDER BY d.dept_no'
      '    INTO :head_dept, :department, :mngr_no, :dno'
      '  DO'
      '  BEGIN'
      '    IF (:mngr_no IS NULL) THEN'
      '    BEGIN'
      '      mngr_name = '#39'--TBH--'#39';'
      '      title = '#39#39';'
      '    END'
      ''
      '    ELSE'
      '      SELECT full_name, job_code'
      '      FROM employee'
      '      WHERE emp_no = :mngr_no'
      '      INTO :mngr_name, :title;'
      ''
      '    SELECT COUNT(emp_no)'
      '    FROM employee'
      '    WHERE dept_no = :dno'
      '    INTO :emp_cnt;'
      ''
      '    SUSPEND;'
      '  END'
      'END;'
      ''
      'ALTER PROCEDURE SHIP_ORDER ('
      '    PO_NUM CHAR(8))'
      'AS'
      '  DECLARE VARIABLE ord_stat CHAR(7);'
      '  DECLARE VARIABLE hold_stat CHAR(1);'
      '  DECLARE VARIABLE cust_no INTEGER;'
      '  DECLARE VARIABLE any_po CHAR(8);'
      'BEGIN'
      '  SELECT s.order_status, c.on_hold, c.cust_no'
      '  FROM sales s, customer c'
      '  WHERE po_number = :po_num'
      '  AND s.cust_no = c.cust_no'
      '  INTO :ord_stat, :hold_stat, :cust_no;'
      ''
      '  /* This purchase order has been already shipped. */'
      '  IF (ord_stat = '#39'shipped'#39') THEN'
      '  BEGIN'
      '    EXCEPTION order_already_shipped;'
      '    SUSPEND;'
      '  END'
      ''
      '  /*  Customer is on hold. */'
      '  ELSE IF (hold_stat = '#39'*'#39') THEN'
      '  BEGIN'
      '    EXCEPTION customer_on_hold;'
      '    SUSPEND;'
      '  END'
      ''
      '  /*'
      
        '   *  If there is an unpaid balance on orders shipped over 2 mon' +
        'ths ago,'
      '   *  put the customer on hold.'
      '   */'
      '  FOR SELECT po_number'
      '    FROM sales'
      '    WHERE cust_no = :cust_no'
      '    AND order_status = '#39'shipped'#39
      '    AND paid = '#39'n'#39
      '    AND ship_date < CAST('#39'NOW'#39' AS TIMESTAMP) - 60'
      '    INTO :any_po'
      '  DO'
      '  BEGIN'
      '    EXCEPTION customer_check;'
      ''
      '    UPDATE customer'
      '    SET on_hold = '#39'*'#39
      '    WHERE cust_no = :cust_no;'
      ''
      '    SUSPEND;'
      '  END'
      ''
      '  /*'
      '   *  Ship the order.'
      '   */'
      '  UPDATE sales'
      '  SET order_status = '#39'shipped'#39', ship_date = '#39'NOW'#39
      '  WHERE po_number = :po_num;'
      ''
      '  SUSPEND;'
      'END;'
      ''
      'ALTER PROCEDURE SHOW_LANGS ('
      '    CODE VARCHAR(5),'
      '    GRADE SMALLINT,'
      '    CTY VARCHAR(15))'
      'RETURNS ('
      '    LANGUAGES VARCHAR(15))'
      'AS'
      'DECLARE VARIABLE i INTEGER;'
      'BEGIN'
      '  i = 1;'
      '  WHILE (i <= 5) DO'
      '  BEGIN'
      '    SELECT language_req[:i] FROM joB'
      
        '    WHERE ((job_code = :code) AND (job_grade = :grade) AND (job_' +
        'country = :cty)'
      '           AND (language_req IS NOT NULL))'
      '    INTO :languages;'
      
        '    IF (languages = '#39' '#39') THEN  /* Prints '#39'NULL'#39' instead of blank' +
        's */'
      '       languages = '#39'NULL'#39';'
      '    i = i +1;'
      '    SUSPEND;'
      '  END'
      'END;'
      ''
      'ALTER PROCEDURE SUB_TOT_BUDGET ('
      '    HEAD_DEPT CHAR(3))'
      'RETURNS ('
      '    TOT_BUDGET DECIMAL(12,2),'
      '    AVG_BUDGET DECIMAL(12,2),'
      '    MIN_BUDGET DECIMAL(12,2),'
      '    MAX_BUDGET DECIMAL(12,2))'
      'AS'
      'BEGIN'
      '  SELECT SUM(budget), AVG(budget), MIN(budget), MAX(budget)'
      '    FROM department'
      '    WHERE head_dept = :head_dept'
      '    INTO :tot_budget, :avg_budget, :min_budget, :max_budget;'
      '  SUSPEND;'
      'END;')
    ScrollBars = ssBoth
    TabOrder = 2
  end
end
