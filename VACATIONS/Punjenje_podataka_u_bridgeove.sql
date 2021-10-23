CREATE SCHEMA work	--nova schema u kojoj se drze razne radne, tj privremene tablice

GO
SET XACT_ABORT ON	--ako se desi neka greska stani u svakom slucaju, nemoj nastavljati dalje

SET NOCOUNT ON 

-- u tablici datumi "od" moraju biti prije datuma "do"
ALTER TABLE dbo.employments					ADD CONSTRAINT CHK_Employments_date_correct_order				CHECK (employe_hire_date	<= COALESCE(employe_termination_date, '22220101'))
ALTER TABLE dbo.employees_leaves_requests	ADD CONSTRAINT CHK_EmployeesLeavesRequests_date_correct_order	CHECK (start_date			<= COALESCE(end_date				, '22220101'))
ALTER TABLE dbo.employees_leaves			ADD CONSTRAINT CHK_EmployeesLeaves_date_correct_order			CHECK (employe_leave_begin	<= COALESCE(employe_leave_end		, '22220101'))
ALTER TABLE dbo.leaves_termins				ADD CONSTRAINT CHK_LeavesTermins_date_correct_order				CHECK (leave_start_date		<= COALESCE(leave_end_date			, '22220101'))


--svaki zaposlenik smije biti samo jednom spomenut (samim time dodan samo u jednu grupi)
ALTER TABLE dbo.picking_groups_members	ADD CONSTRAINT UQ_PickingGroupsMembers_unique_membership UNIQUE (employe_id) --R

--u svakoj grupi svaka pozicija mora biti dodijeljena samo jednom
ALTER TABLE dbo.picking_groups_members	ADD CONSTRAINT UQ_PickingGroupsMembers_unique_order_position_per_group UNIQUE (picking_group_id, selection_order) --R


/*****************************************************************************************************************************************************************/
/*****************************************************************************************************************************************************************/
/*****************************************************************************************************************************************************************/


DECLARE @BrojRedova int

/*****************************************************************************************************************************************************************/
PRINT 'Svakom drugom zaposleniku koji je do sad imao samo jedno radno mjesto dodaj jos jedno dodatno radno mjesto prije trenutnog tako da mu se da neki drugi random odjel i da je u njemu radio godinu dana prije trenutnog mjesta...'

SELECT * FROM employments

INSERT INTO employments 
		( employee_id
		, department_id
		, employee_hire_date
		, employee_termination_date
		)
	
	SELECT TOP 50 PERCENT
			  e.employee_id
			, (SELECT TOP(1) d.id FROM departments AS d WHERE d.ID <> e.department_id ORDER BY d.department_name, d.id) AS proslo_radno_mjesto_department_id
			, DATEADD(YEAR, -1, e.employee_hire_date) AS proslo_radno_mjesto_employee_hire_date
			, DATEADD(DAY , -1, e.employee_hire_date) AS proslo_radno_mjesto_employee_termination_date
		FROM employments e
		WHERE e.employee_id IN (SELECT subq.employee_id 
								FROM employments AS subq 
								GROUP BY subq.employee_id 
								HAVING COUNT(1) = 1
								) --samo one koji se samo jednom spominju u zaposlenjima

PRINT CONCAT('Izmjenjeno ili dodano redova: ', COALESCE(@@ROWCOUNT, 0)) --  u @@ROWCOUNT sistemskoj varijabli uvijek mozemo naci broj redova koji su se izmjenili ili insertali u prethodnoj naredbi)

/*****************************************************************************************************************************************************************/
PRINT 'Provjeri imaju li svi ispravan redoslijed datuma...'
IF EXISTS(SELECT *
			FROM employments
			WHERE employee_hire_date > COALESCE(employee_termination_date, CAST('22220101' as date)) 
		)
	BEGIN
		;THROW 50000, 'U podacima o zaposlenjima postoje zapisi s neispravnim redoslijedom datuma!', 1
	END


/*****************************************************************************************************************************************************************/
PRINT 'Provjeri da li se nekome preklapaju zaposlenja...'
IF EXISTS(SELECT *
			FROM employments e1
				INNER JOIN employments e2 
								ON	e1.employee_id=e2.employee_id --da je isti zaposlenik
									AND (
										e1.employee_hire_date <= COALESCE(e2.employee_termination_date, CAST('21000101' as date)) 
										AND 
										COALESCE(e1.employee_termination_date, CAST('21000101' as date)) >= e2.employee_hire_date
										) --da se periodi preklapaju
									AND e1.id <> e2.id --da ne nalazi matcheve izmedju dva ista reda (sam sa sobom)
		)
	BEGIN
		;THROW 50000, 'U podacima o zaposlenjima postoje zapisi s neispravnim redoslijedom datuma!', 1
	END

/*****************************************************************************************************************************************************************/
SELECT * FROM employments

PRINT 'Otvori grupe godisnjeg za sve godine koje se spominju u zaposlenjima a jos nisu upisane u bazu'

DECLARE @Najstarija_godina int, @Najnovija_godina int, @Ukupno_godina int
-- napuni vrijednosti u te dvije varijable
SELECT	 @Najstarija_godina = MIN(godine.godina) - 1 --za svaki slucaj da pokrijem i jednu prije
		,@Najnovija_godina	= MAX(godine.godina) + 1 --za svaki slucaj da pokrijem i jednu nakon
	FROM (
			SELECT YEAR(employee_hire_date)			AS godina FROM employments
			UNION ALL
			SELECT YEAR(employee_termination_date)	AS godina FROM employments
			UNION ALL 
			SELECT YEAR(GETDATE())+10					AS godina -- ako su slucajno svi podaci iz proslosti dodaj i slijedecih 10 godina od danas u igru
		) AS godine

--tablica s popisom svih godina imedju najstarije i najnovije

DROP TABLE IF EXISTS work.tmp_popis_godina
CREATE TABLE work.tmp_popis_godina (godina int)

INSERT INTO work.tmp_popis_godina ( godina )
	SELECT lista_brojeva.redni_broj AS godina_za_ubaciti
				FROM	(SELECT ROW_NUMBER() OVER (ORDER BY sao1.object_id) AS redni_broj
							FROM sys.all_objects AS sao1 
								CROSS JOIN sys.all_objects AS sao2 --sumanuti join bez uvjeta po sistemu kombinacije svakog sa svakim da dobijemo milione redova kombinacija
						) AS lista_brojeva
				WHERE 
					lista_brojeva.redni_broj BETWEEN @Najstarija_godina AND @Najnovija_godina --one godine koje nam trebaju	

------------------------------------------------------------------------------------------------------------------------------
--Provjera
--SELECT * FROM work.tmp_popis_godina
--SELECT * FROM leave_groups

INSERT INTO leave_groups 
		( leave_group_name
		, leave_group_year
		, leave_group_description
		) 
	SELECT DISTINCT 
			  CONCAT('go', godine_za_ubaciti.godina)										AS leave_group_name
			, godine_za_ubaciti.godina													AS leave_group_year
			, CONCAT(' Godišnji za ', godine_za_ubaciti.godina, ' (automatski dodano)')	AS leave_group_description
		FROM
			( SELECT godina 
				FROM work.tmp_popis_godina
					WHERE godina NOT IN (SELECT subq.leave_group_year FROM leave_groups AS subq) --nemoj one za koje vec imamo otvorene grupe godisnjih
			) AS godine_za_ubaciti

PRINT CONCAT('Izmjenjeno ili dodano redova: ', COALESCE(@@ROWCOUNT, 0)) --  u @@ROWCOUNT sistemskoj varijabli uvijek mozemo naci broj redova koji su se izmjenili ili insertali u prethodnoj naredbi)


/*****************************************************************************************************************************************************************/
PRINT 'Dodaj neka prava za godisnji u svim tim godinama'
--SELECT * FROM employees_leave_rights

DECLARE @MAX_ground_id int = (SELECT MAX(ID) FROM leave_grounds)
INSERT INTO dbo.employees_leave_rights
		(   employee_id
		  , created_by_user_id
		  , ground_id
		  , leave_group_id
		  , number_of_days
		  , info_description
		  , created_at 
		  , effective_from
		) 
	SELECT    e.id													AS employee_id
			, d.manager_user_id										AS createdby_user_id
			, grounds.ground_id										AS ground_id
			, (SELECT TOP(1) 
					subq.id 
				FROM leave_groups AS subq 
				WHERE leave_group_year = godine_rada.godina
				)													AS leave_group_id
			, grounds.no_of_days									AS number_of_days
			, 'Automatski dodano'									AS info_description
			, zaposlenja.employee_hire_date							AS created_at
			, DATEFROMPARTS(YEAR(godine_rada.godina),1,1)
		FROM employees AS e
			INNER JOIN employments				AS zaposlenja	ON e.id=zaposlenja.employee_id
			INNER JOIN work.tmp_popis_godina	AS godine_rada	ON godine_rada.godina BETWEEN YEAR(zaposlenja.employee_hire_date) AND COALESCE( YEAR(zaposlenja.employee_termination_date),YEAR(GETDATE()) )
			INNER JOIN departments				AS d			ON d.id = zaposlenja.department_id
			CROSS JOIN (SELECT TOP(1) subq.id AS ground_id, 20 AS no_of_days FROM leave_grounds AS subq WHERE subq.ground_right_name LIKE '20 radnih dana'
						UNION ALL
						SELECT subq.id AS ground_id, 3 AS no_of_days FROM leave_grounds AS subq ORDER BY subq.id OFFSET CAST( FLOOR(RAND()*(@MAX_ground_id-3)) as int) ROWS FETCH NEXT 3 ROWS ONLY
						) AS grounds --daj svima osnovnih 20 i jos po 3 dana na osnovi neke 3 random osnove
		ORDER BY e.id, godine_rada.godina, grounds.ground_id

PRINT CONCAT('Izmjenjeno ili dodano redova: ', COALESCE(@@ROWCOUNT, 0)) --  u @@ROWCOUNT sistemskoj varijabli uvijek mozemo naci broj redova koji su se izmjenili ili insertali u prethodnoj naredbi)

--SELECT * FROM employees_leave_rights
--DELETE FROM [dbo].[employees_leave_rights]
      --WHERE 1=1

/*****************************************************************************************************************************************************************/
PRINT 'Dodaj termine za biranje za sve godine'

UPDATE dbo.leaves_termins
	SET leave_termin_end_date = DATEADD(DAY, 15, leave_termin_start_date)
	WHERE leave_termin_end_date IS NULL

-- SELECT * FROM dbo.leaves_termins

INSERT INTO dbo.leaves_termins
	(
		  leave_termin_name
		, leave_termin_start_date
		, leave_termin_end_date
		, leave_termin_description
	) 
SELECT 
		  CONCAT(godisnji_termini.[Termin pocetak opisa bez godine], godine_za_ubaciti.godina)							AS leave_termin_name
		, DATEFROMPARTS(godine_za_ubaciti.godina, godisnji_termini.leave_start_month, godisnji_termini.leave_start_day)	AS leave_start_date
		, DATEFROMPARTS(godine_za_ubaciti.godina, godisnji_termini.leave_end_month, godisnji_termini.leave_end_day)		AS leave_end_date
		, 'Automatski dodano'																							AS leave_termin_description
	FROM 
		(SELECT godine.godina
			FROM work.tmp_popis_godina AS godine
			WHERE godine.godina NOT IN (SELECT CAST(RIGHT(leave_termin_name,4) as int) AS godina FROM dbo.leaves_termins) --za godine gdje vec postoje termini nemoj dodavati automatske
		) AS godine_za_ubaciti
		CROSS JOIN 
			(
			SELECT DISTINCT 
					  LEFT(lt.leave_termin_name,5)	 AS [Termin pocetak opisa bez godine]
					, MONTH(lt.leave_termin_start_date)	AS leave_start_month
					, DAY(  lt.leave_termin_start_date)	AS leave_start_day
					, MONTH(lt.leave_termin_end_date)		AS leave_end_month
					, DAY(  lt.leave_termin_end_date)		AS leave_end_day
				FROM dbo.leaves_termins AS lt
			) AS godisnji_termini


PRINT CONCAT('Izmjenjeno ili dodano redova: ', COALESCE(@@ROWCOUNT, 0)) --  u @@ROWCOUNT sistemskoj varijabli uvijek mozemo naci broj redova koji su se izmjenili ili insertali u prethodnoj naredbi)

/*****************************************************************************************************************************************************************/
PRINT 'Dodaj neke zahtjeve za godisnji'

SELECT * FROM employees_leaves_requests

INSERT INTO dbo.employees_leaves_requests
	( [request_date]
	, [employee_id]
	, [requester_user_id]
	, [approval_user_id]
	, [leave_termin_id]
	, [approved_request]
	, [employee_leave_request_start_date]
	, [employee_leave_request_end_date]
	, [request_description]
	, [created_at] 
	)
SELECT
	  DATEADD(DAY, 1, zaposlenja.employee_hire_date)	AS [request_date]
	, zaposlenja.employee_id							AS [employee_id]
	, d.manager_user_id									AS [requester_user_id]
	, NULL												AS [approval_user_id]
	, lt.id												AS [leave_termin_id]
	, 0													AS [approved_request]
	, lt.leave_termin_start_date						AS [leave_termin_start_date]
	, lt.leave_termin_end_date							AS [leave_termin_end_date]
	, 'Automatski kreirano'								AS [request_description]
	,  DATEADD(DAY, 2, zaposlenja.employee_hire_date)	AS [created_at] 
	FROM 
		dbo.employments							AS zaposlenja
		INNER JOIN work.tmp_popis_godina		AS godine	ON godine.godina BETWEEN YEAR(zaposlenja.employee_hire_date) AND YEAR( COALESCE(zaposlenja.employee_termination_date, GETDATE()) )
		INNER JOIN dbo.employees				AS e	ON e.id = zaposlenja.employee_id
		LEFT JOIN dbo.departments				AS d	ON d.id = zaposlenja.department_id
		LEFT JOIN dbo.picking_groups_members	AS pgm	ON pgm.employee_id = e.id
		LEFT JOIN dbo.leaves_termins			AS lt	ON CAST(SUBSTRING(lt.leave_termin_name, 2,2) as int) = pgm.selection_order --da svatko izabere onaj termin koji je po redu u grupi
															AND CAST(RIGHT(lt.leave_termin_name, 4) as int) = godine.godina

PRINT CONCAT('Izmjenjeno ili dodano redova: ', COALESCE(@@ROWCOUNT, 0)) --  u @@ROWCOUNT sistemskoj varijabli uvijek mozemo naci broj redova koji su se izmjenili ili insertali u prethodnoj naredbi)

--****************************************************************************************************************************
--odobri sve osim svakog desetog requesta
select * from [dbo].[employees_leaves_requests]
UPDATE [dbo].[employees_leaves_requests]
	SET 
	
		  approved_request = 1						--postavi da je odobren
		, approval_user_id = dep.manager_user_id	--postavi tko je odobrio
		--, req.id
	FROM dbo.employees_leaves_requests AS req
		INNER JOIN employments AS zaposlenja ON req.employee_id=zaposlenja.employee_id --to je zaposlenje od onoga tko je dao zahtjev
												AND req.created_at BETWEEN zaposlenja.employee_hire_date AND COALESCE(zaposlenja.employee_termination_date, '22220101') --i to koje je bilo aktualno u vrijeme zahtjeva
		INNER JOIN departments AS dep		 ON dep.id=zaposlenja.department_id
	WHERE 
		req.id % 10 <> 0 -- znak % je modulo, tj ostatak nakon dijeljenja, tako da uzmem sve osim svakog desetog


PRINT CONCAT('Izmjenjeno ili dodano redova: ', COALESCE(@@ROWCOUNT, 0)) --  u @@ROWCOUNT sistemskoj varijabli uvijek mozemo naci broj redova koji su se izmjenili ili insertali u prethodnoj naredbi)


/*****************************************************************************************************************************************************************/


PRINT 'Dodaj neke odradjenje godisnje'


SELECT *
	FROM dbo.employees_leaves
	ORDER BY employee_id, employee_leave_request_id ,employee_leave_start_date

--sve odobrene godisnje pretvori u prave godisnje
INSERT INTO dbo.employees_leaves
	( [employee_id]
	, [leave_group_id]
	, [employee_leave_request_id]
	, [employee_leave_start_date]
	, [employee_leave_end_date]
	, [created_at]
	)

SELECT
	  req.employee_id		AS [employee_id]
	, (	SELECT TOP(1) 
			subq.id 
			FROM dbo.leave_groups AS subq 
			WHERE subq.leave_group_year = YEAR(req.employee_leave_request_start_date) + raspodjea_godisnjeg.godina_pomak
		)					AS [leave_group_id] 
	, req.id				AS [employee_leave_request_id]


	, CASE --svaki godisnji sam razbio na dvije polovice i stavio da u prvoj polovici koristi stari godisnji a u drugoj polovici novi godisnji
			WHEN raspodjea_godisnjeg.godisnji = 'stari'	THEN req.employee_leave_request_start_date 
			WHEN raspodjea_godisnjeg.godisnji = 'novi'	THEN DATEADD(DAY
																	, (DATEDIFF(DAY, req.employee_leave_request_start_date, req.employee_leave_request_end_date) / 2) --polovica dana godisnjeg
																	, req.employee_leave_request_start_date
																	)
		END					AS [employee_leave_request_start_date]

	, CASE 
			WHEN raspodjea_godisnjeg.godisnji = 'novi'	THEN req.employee_leave_request_end_date
			WHEN raspodjea_godisnjeg.godisnji = 'stari'	THEN DATEADD(DAY
																	, (DATEDIFF(DAY, req.employee_leave_request_start_date, req.employee_leave_request_end_date) / 2) - 1 --polovica dana godisnjeg
																	, req.employee_leave_request_start_date
																	)
		END					AS [employee_leave_request_end_date]

	, req.employee_leave_request_start_date	AS [created_at]
	FROM 
		dbo.employees_leaves_requests AS req
		--CROSS JOIN JE svaki sa svakim bez uvjeta ON
		CROSS JOIN (SELECT 'stari' as godisnji, -1 AS godina_pomak
					UNION ALL
					SELECT 'novi' as godisnji,   0 AS godina_pomak
					) as raspodjea_godisnjeg
	WHERE req.approved_request = 1
		
	ORDER BY [employee_leave_request_start_date]
PRINT CONCAT('Izmjenjeno ili dodano redova: ', COALESCE(@@ROWCOUNT, 0)) --  u @@ROWCOUNT sistemskoj varijabli uvijek mozemo naci broj redova koji su se izmjenili ili insertali u prethodnoj naredbi)

