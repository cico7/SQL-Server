--Glavna Skripta za Izradu tablica u bazi godišni odmori ( vacations)
--CREATE SCHEMA adm
--CREATE SCHEMA work
--SET XACT_ABORT ON	--ako se desi neka greska stani u svakom slucaju, nemoj nastavljati dalje

ALTER TABLE dbo.departments DROP CONSTRAINT FK_departments_users

DROP TABLE IF EXISTS dbo.picking_groups_members
DROP TABLE IF EXISTS dbo.picking_groups
DROP TABLE IF EXISTS dbo.employees_leaves
drop table if exists dbo.employees_leaves_requests
DROP TABLE IF EXISTS dbo.leaves_termins
DROP TABLE IF EXISTS adm.groups_members
DROP TABLE IF EXISTS dbo.employees_leave_rights
DROP TABLE IF EXISTS dbo.leave_grounds
DROP TABLE IF EXISTS dbo.employments
DROP TABLE IF EXISTS dbo.leave_groups
DROP TABLE IF EXISTS dbo.employees
DROP TABLE IF EXISTS adm.groups
DROP TABLE IF EXISTS dbo.departments
DROP TABLE IF EXISTS adm.users
DROP TABLE IF EXISTS dbo.National_holidays


PRINT '1. users table is created'
CREATE TABLE adm.users(
	 id						INT IDENTITY (1,1) PRIMARY KEY
	,user_log_in					NVARCHAR (MAX) NOT NULL
	,user_name					NVARCHAR (MAX) NOT NULL
	,created_at					DATETIME DEFAULT GETDATE()
	)


--Ubačena prava za grupu ( koja grupa ima koja prava)
--Na način da imamo fiksna prava s vraćanjem 1 ili 0 ima ili nema to pravo
PRINT '2. groups table is created'
CREATE TABLE adm.groups(
		 id					INT IDENTITY (1,1) PRIMARY KEY
		,group_name				NVARCHAR (MAX) NOT NULL
		,can_approve_request			BIT	NOT NULL
		,can_enter_request			BIT	NOT NULL
		,can_add_free_days			BIT	NOT NULL
		,can_add_new_user			BIT	NOT NULL
		,can_change_group_rights		BIT	NOT NULL
		,group_description			NVARCHAR (MAX) NULL
		,created_at				DATETIME DEFAULT GETDATE()
	
	)
	

PRINT '3. groups_members table is created'
CREATE TABLE adm.groups_members(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,user_id					INT 	NOT NULL	CONSTRAINT FK_groupMembers_users		FOREIGN KEY REFERENCES adm.users(id)
	  ,group_id					INT	NOT NULL	CONSTRAINT FK_group_members_groups		FOREIGN KEY REFERENCES adm.groups(id)
	  ,created_at					DATETIME DEFAULT getdate()
	)


PRINT '4. employees table is created'
CREATE TABLE dbo.employees(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,employee_first_name				NVARCHAR	(MAX) NOT NULL
	  ,employee_last_name				NVARCHAR	(MAX) NOT NULL
	  ,oib						NVARCHAR(11) CONSTRAINT OIB_neispravne_duzine CHECK (LEN(Oib)=11)
	  ,licence_id					NVARCHAR(7)
	  ,job_name					NVARCHAR	(MAX)
	  ,employee_address				NVARCHAR	(MAX) 
	  ,employee_email				NVARCHAR	(MAX)
	  ,phone_number					NVARCHAR	(MAX) 
	  ,created_at					DATETIME DEFAULT GETDATE()
	)


PRINT '5. departments table is created'
CREATE TABLE dbo.departments(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,manager_user_id				INT	NOT NULL		CONSTRAINT FK_departments_users FOREIGN KEY REFERENCES adm.users(id)
	  ,department_name				NVARCHAR (MAX) NOT NULL
	  ,department_description			NVARCHAR (MAX)
	  ,created_at					DATETIME DEFAULT GETDATE()
	)
--ALTER TABLE dbo.departments DROP CONSTRAINT FK_departments_users


PRINT '6. employments table is created'
CREATE TABLE dbo.employments(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,employee_id					INT	NOT NULL	CONSTRAINT FK_employments_employees		FOREIGN KEY REFERENCES dbo.employees(id)
	  ,department_id				INT	NOT NULL	CONSTRAINT FK_employments_departments		FOREIGN KEY REFERENCES dbo.departments(id)
	  ,employee_hire_date				DATE	NOT NULL
	  ,employee_termination_date			DATE		
	  ,created_at					DATETIME DEFAULT GETDATE()
	)
ALTER TABLE dbo.employments				ADD CONSTRAINT CHK_Employments_date_correct_order	CHECK (employee_hire_date <= COALESCE(employee_termination_date,'22220101'))


PRINT '7. leave_grounds table is created'
CREATE TABLE dbo.leave_grounds(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,ground_right_name				NVARCHAR (MAX)	NOT NULL
	  ,ground_right_description			NVARCHAR (MAX)	NULL
	  ,created_at					DATETIME DEFAULT GETDATE()
	)


PRINT '8. leave_groups table is created'
CREATE TABLE dbo.leave_groups(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,leave_group_name				NVARCHAR (MAX)	NOT NULL
	  ,leave_group_year				INT		NOT NULL
	  ,leave_group_description			NVARCHAR (MAX)	NULL
	  ,created_at					DATETIME DEFAULT GETDATE()
	)


PRINT '9. employees_leave_rights table is created'	
CREATE TABLE dbo.employees_leave_rights(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,employee_id					INT NOT NULL	CONSTRAINT	FK_employees_leave_rights_employees		FOREIGN KEY REFERENCES dbo.employees(id)
	  ,created_by_user_id				INT NOT NULL	CONSTRAINT	FK_employees_leave_rights_users			FOREIGN KEY REFERENCES adm.users(id)
	  ,ground_id					INT NOT NULL	CONSTRAINT	FK_employees_leave_rights_leave_grounds		FOREIGN KEY REFERENCES dbo.leave_grounds(id)
	  ,leave_group_id				INT NOT NULL	CONSTRAINT	FK_employees_leave_rights_leave_groups		FOREIGN KEY REFERENCES dbo.leave_groups(id)
	  ,number_of_days				INT NOT NULL
	  ,info_description				NVARCHAR	(MAX)	NULL
	  ,effective_from				DATE NOT NULL
	  ,created_at					DATETIME DEFAULT GETDATE()
	)


PRINT '10. leaves_termins table is created'
CREATE TABLE dbo.leaves_termins(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,leave_termin_name				NVARCHAR (MAX)	NOT NULL
	  ,leave_termin_start_date			DATE		NOT NULL
	  ,leave_termin_end_date			DATE		NOT NULL
	  ,leave_termin_description			NVARCHAR(MAX)	NULL
	  ,created_at					DATETIME DEFAULT GETDATE()
	)
ALTER TABLE dbo.leaves_termins				ADD CONSTRAINT CHK_LeavesTermins_date_correct_order	CHECK (leave_termin_start_date <= COALESCE(leave_termin_end_date,'22220101'))


PRINT '11. dbo.employees_leaves_requests table is created'
CREATE TABLE dbo.employees_leaves_requests(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,request_date					DATE	NOT NULL
	  ,employee_id					INT	NOT NULL	CONSTRAINT	employees_leaves_requests_employees			FOREIGN KEY REFERENCES dbo.employees(id)
	  ,requester_user_id				INT	NOT NULL	CONSTRAINT	employees_leaves_requests_users1			FOREIGN KEY REFERENCES adm.users(id)
	  ,approval_user_id				INT					CONSTRAINT	employees_leaves_requests_users2	FOREIGN KEY REFERENCES adm.users(id)
	  ,leave_termin_id				INT	NOT NULL	CONSTRAINT	employees_leaves_requests_leaves_termins		FOREIGN KEY REFERENCES dbo.leaves_termins(id)
	  ,approved_request				BIT	NOT NULL
	  ,employee_leave_request_start_date		DATE	NOT NULL
	  ,employee_leave_request_end_date		DATE	NOT NULL
	  ,request_description				NVARCHAR	(MAX)
	  ,created_at					DATETIME DEFAULT GETDATE()
	)
ALTER TABLE dbo.employees_leaves_requests	ADD CONSTRAINT CHK_EmployeesLeavesRequests_date_correct_order	CHECK (employee_leave_request_start_date <= COALESCE(employee_leave_request_end_date,'22220101'))


PRINT '12. employees_leaves table is created'
CREATE TABLE dbo.employees_leaves(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,employee_id					INT	NOT NULL	CONSTRAINT	employees_leaves_employees				FOREIGN KEY REFERENCES dbo.employees(id)
	  ,leave_group_id				INT	NOT NULL	CONSTRAINT	employees_leaves_leave_groups				FOREIGN KEY REFERENCES dbo.leave_groups(id)
	  ,employee_leave_request_id			INT			CONSTRAINT	employees_leaves_employees_leaves_requests		FOREIGN KEY REFERENCES dbo.employees_leaves_requests(id)
	  ,employee_leave_start_date			DATE	NOT NULL
	  ,employee_leave_end_date			DATE
	  ,created_at					DATETIME DEFAULT GETDATE()
	)
ALTER TABLE dbo.employees_leaves		ADD CONSTRAINT CHK_EmployeesLeaves_date_correct_order	CHECK (employee_leave_start_date <= COALESCE(employee_leave_end_date,'22220101'))


PRINT '13.  picking_groups table is created'
CREATE TABLE dbo. picking_groups(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,picking_group_name				NVARCHAR (MAX)		NOT NULL
	  ,created_at					DATETIME DEFAULT GETDATE()
	)


PRINT '14.  picking_groups_members table is created'
CREATE TABLE dbo.picking_groups_members(
	   id						INT IDENTITY (1,1) PRIMARY KEY
	  ,employee_id					INT	NOT NULL CONSTRAINT picking_groups_members_employees		FOREIGN KEY REFERENCES dbo.employees(id)	
	  ,picking_group_id				INT	NOT NULL CONSTRAINT picking_groups_members_picking_groups	FOREIGN KEY REFERENCES dbo.picking_groups(id)
	  ,selection_order				INT 	NOT NULL
	  ,created_at					DATETIME DEFAULT GETDATE()
	)
ALTER TABLE dbo.picking_groups_members		ADD CONSTRAINT UQ_PickingGroupsMembers_unique_membership		UNIQUE (employee_id)
ALTER TABLE dbo.picking_groups_members		ADD CONSTRAINT UQ_PickingGroupsMembers_unique_order_position_per_group	UNIQUE (picking_group_id, selection_order)


PRINT '15.  National_holidays table is created' 
CREATE TABLE dbo.National_holidays(
		 id 					INT IDENTITY(1,1)
		,holiday_date 				DATE CONSTRAINT CU_use_Date_Only_Once UNIQUE (holiday_date)
		,holiday_name 				NVARCHAR(MAX)
		,holiday_description 			NVARCHAR(MAX)
)

 PRINT'_________________'
PRINT'15. Tables is created'





