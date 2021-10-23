Procedure
--Zathjev za godisnji (employeeid, terminid, datumod, datumdo)



GO
--+ Rotiranje picking grupe(pickinggroupid)
CREATE OR ALTER PROCEDURE dbo.sp_Rotate_Picking_Group ( @picking_group_id bigint)
AS
/*
	Procedura za rotiranje redoslijeda izbora u grupi za biranje termina godisnjeg
	Sve clanove grupe ce unaprijediti za jedno mjesto a onoga koji je bio prvi ce baciti na zadnje mjesto
*/
BEGIN

	PRINT CONCAT('Obrada grupe ID = ', @picking_group_id)

	PRINT 'Smanjivanje rednog broja za biranje svim članovima grupe...'

	UPDATE dbo.picking_groups_members
		SET 
			  selection_order = selection_order - 1
		WHERE 
			picking_group_id = @picking_group_id



	PRINT 'Prebacivanje prvoga u grupi na kraj reda...'

	UPDATE dbo.picking_groups_members
		SET 
			selection_order = 1 + (SELECT MAX(selection_order) 
									FROM dbo.picking_groups_members 
									WHERE picking_group_id = @picking_group_id) --nadji koji je broj trenutno zadnjega i dodaj jedan
		WHERE 
			picking_group_id = @picking_group_id	--samo u toj grupi
			AND selection_order = 0					--onaj koji je prije bio prvi nakon smanjivanja je nulti


END
/*
TESTIRANJE

-- prekopiraj trenutno stanje grupe u privremenu tablicu
DROP TABLE IF EXISTS #backup_grupe_16

SELECT *
	INTO #backup_grupe_16
	FROM dbo.picking_groups_members
	WHERE picking_group_id = 16
	ORDER BY selection_order

-- zarotiraj tu grupu
EXEC  dbo.sp_Rotate_Picking_Group 16

-- pokazi kako je bilo stanje prije rotiranja (iz privremene tablice)
SELECT *
	FROM #backup_grupe_16
	ORDER BY selection_order

--pokazi kakvo je trenutno stanje u pravoj tablici nakon rotiranja
SELECT *
	FROM dbo.picking_groups_members
	WHERE picking_group_id = 16
	ORDER BY selection_order
*/

-----------------------
-- + Broj radnih dana izmedju dva datuma (datum1, datum2)
ALTER FUNCTION [dbo].[Fn_DatesBetween] (@DateFrom date, @DateTo date)
RETURNS @ListOfDates TABLE
	(
		 [date]			DATE
		,day_name		NVARCHAR(MAX)
		,day_in_week	INT
		,weekend		INT
		,holiday		INT
		,work_day		INT
	)
AS
/*
	Ova funkcija vrace datume u zadanom rasponu i neke informacije o njima

	SET LANGUAGE CROATIAN
	SET DATEFIRST 1
	SELECT * FROM dbo.Fn_DatesBetween('20210315', '20210328')

*/
BEGIN

	DECLARE @Err int
	--SET DATEFIRST 1 -- postavlja brojanje dana u tjednu po hr standardu (tjedan pocinje u ponedjaljak)
	IF @@DATEFIRST <> 1
		BEGIN
			SET @Err = CAST('Prvi dan u tjednu nije postavljen na ponedjeljak! Izvrsite: SET DATEFIRST 1' as int)
		END

	--u funkciji jos od deklaracije funkcije postoji virtualna tablica @ListOfDates koja je na pocetku prazna

	--napuni u tu tablicu samo prvi stupac (datume)  a svi ostali stupci ce imati u sebi NULLove
	INSERT INTO @ListOfDates ([date])
		SELECT
				 DATEADD( DD, RedniBrojevi.RBR-1, @DateFrom ) AS [date]
			FROM
				(SELECT TOP(100000)
					ROW_NUMBER() OVER (ORDER BY t1.object_id) AS RBR
					FROM sys.all_objects AS t1
						CROSS JOIN sys.all_objects AS t2
				) AS RedniBrojevi 
			WHERE DATEADD( DD, RedniBrojevi.RBR-1, @DateFrom )<=@DateTo

	--Ispuni u svim redovima ime dana prema datumu
	UPDATE @ListOfDates
		SET day_name = DATENAME(WEEKDAY, [date])

	--ispuni u svim redovima vrijednost za dan u tjednu prema datumu (koji je vec u tablici)
	UPDATE @ListOfDates
		SET day_in_week = DATEPART(WEEKDAY, [date])

	--postavi i oznake koji je vikend a koji nije
	UPDATE @ListOfDates
		SET weekend = CASE 
						WHEN day_in_week in (6,7) THEN 1 
						ELSE 0 
						END

	--postavi na 1 da je praznik za one datume koji se nalaze u popisu datuma u drugoj tablci
	UPDATE @ListOfDates
		SET holiday = CASE 
						WHEN [date] IN (SELECT holiday_date from dbo.National_holidays) THEN 1
						ELSE 0
						END


	
	UPDATE @ListOfDates
		SET work_day = CASE 
							WHEN holiday=0 AND weekend=0 THEN 1 -- DAA NIJE PRAZNIK I DA NIJE VIKEND
							ELSE 0
							END
		
	
	RETURN 
END
/*
	SET DATEFIRST 1
	SELECT * FROM  [dbo].[Fn_DatesBetween] ('20201223', '20210103')
*/


--
GO
--

CREATE OR ALTER FUNCTION [dbo].[Fn_No_Of_WorkingDays_Between_Dates]( @DateFrom date, @DateTo date )
RETURNS int
AS
--funkcija vrace broj radnih dana izmedju dva datuma koristeci prebrojavanje radnih dana iz funcije DatesBetween
BEGIN
	DECLARE @NoOfDays int

	SET @NoOfDays = (SELECT COUNT(1) 
						FROM dbo.Fn_DatesBetween(@DateFrom, @DateTo)
						WHERE work_day = 1
					)

	RETURN @NoOfDays
END
---------------------------
--Preostalo dana godisnjeg na danasnji dan (employeeid)
CREATE OR ALTER   FUNCTION [dbo].[Fn_Remaining_Vacations] (@employee_id bigint)
RETURNS @Remaining_Vacations TABLE
	(
		  employee_id		bigint
		, leave_group_id	bigint
		, allocated_days	int		--dodijeljenih slobodnih dana
		, spent_days		int		--potrosenih slobodnih dana
		, reserved_days		int		--unaprijed zapisanih dana za godisnji (jos nisu potroseni)
		, remaining_days	int		--preostalo slobodnih dana

	)
BEGIN
	DECLARE @TodaysDate date = GETDATE()

	INSERT INTO @Remaining_Vacations
	SELECT 
		 vacations.employee_id						AS employee_id
		,vacations.leave_group_id					AS leave_group_id
		,COALESCE(SUM(vacations.allocated_days),0)	AS allocated_days
		,COALESCE(SUM(vacations.spent_days),0)		AS spent_days
		,COALESCE(SUM(vacations.reserved_days),0) 	AS reserved_days
		,COALESCE(SUM(vacations.allocated_days),0)-COALESCE(SUM(vacations.spent_days),0)-COALESCE(SUM(vacations.reserved_days),0)						AS remaining_days
		FROM	
			(SELECT --dohvat dodijeljenih slobodnih dana
					 e.id								AS employee_id
					,lg.id								AS leave_group_id
					,SUM(number_of_days)				AS allocated_days
					,NULL								AS spent_days
					,NULL								AS reserved_days
				FROM dbo.employees							AS e
					LEFT JOIN dbo.employees_leave_rights	AS elr	ON e.id					=	elr.employee_id
					LEFT JOIN dbo.leave_groups				AS lg	ON elr.leave_group_id	=	lg.id
				WHERE e.id = @employee_id
				GROUP BY e.id , lg.id
				----------
				UNION ALL
				----------
				SELECT --dohvat potrosenih dana na godisnji
					 e.id		AS employee_id
					,lg.id		AS leave_group_id
					,NULL		AS allocated_days
					,SUM(dbo.Fn_No_Of_WorkingDays_Between_Dates(el.employee_leave_start_date
																,el.employee_leave_end_date)
						)		AS spent_days
					,NULL		AS reserved_days
				FROM dbo.employees						AS e
					LEFT JOIN dbo.employees_leaves		AS el	ON e.id					=	el.employee_id
					LEFT JOIN dbo.leave_groups			AS lg	ON el.leave_group_id	=	lg.id
				WHERE e.id = @employee_id
				GROUP BY 
					e.id , lg.id
				----------
				UNION ALL
				----------
				SELECT --dohvat zahtjeva za godisnji
					 e.id		AS employee_id
					,lg.id		AS leave_group_id
					,NULL		AS allocated_days
					,NULL		AS spent_days
					,SUM( dbo.Fn_No_Of_WorkingDays_Between_Dates(elr.employee_leave_request_start_date
																,elr.employee_leave_request_end_date)
						)		AS reserved_days
				FROM dbo.employees							AS e
					LEFT JOIN dbo.employees_leaves_requests	AS elr	ON e.id					=	elr.employee_id
					LEFT JOIN dbo.leave_groups				AS lg	ON lg.leave_group_year	= YEAR(elr.employee_leave_request_start_date)	
				WHERE
					e.id = @employee_id
					AND elr.employee_leave_request_start_date > @TodaysDate --uzmi samo zahtjeve za buduce godisnje jer mu ne zelimo za prosle godisnje odbiti dane i za godisnji i za zahtjev za taj isti godisnji
				GROUP BY 
					e.id , lg.id

			) AS vacations
	GROUP BY vacations.employee_id , vacations.leave_group_id 

	RETURN
END
/*
SET DATEFIRST 1
SELECT * FROM dbo.Fn_Remaining_Vacations (13)
*/
----------------

GO
--unos zahtjeva za godisnji
CREATE OR ALTER PROCEDURE dbo.sp_New_Leave_Request(@employee_id bigint, @request_date date, @leaves_termin_id bigint, @DateFrom date, @DateTo date, @description nvarchar(MAX), @Active_User_ID bigint)
AS
BEGIN

	--provjera da li postoji taj @user_id
	IF NOT EXISTS (SELECT * FROM adm.users WHERE id = @Active_User_ID)
		BEGIN
			;THROW 50000, 'Nepostojeći user_id!', 1
		END

	--provjera da li postoji taj @employee_id
	IF NOT EXISTS (SELECT * FROM dbo.employees WHERE id = @employee_id)
		BEGIN
			;THROW 50000, 'Nepostojeći employee_id!', 1
		END

	--provjera da li postoji taj @leaves_termin_id (samo ako je naveden)
	IF @leaves_termin_id IS NOT NULL AND NOT EXISTS (SELECT * FROM dbo.leaves_termins WHERE id = @leaves_termin_id)
		BEGIN
			;THROW 50000, 'Nepostojeći leaves_termin_id!', 1
		END

	--provjera da li su datumi ispravno ispunjeni
	IF @DateFrom IS NULL OR @DateTo IS NULL OR @DateFrom > @DateTo
		BEGIN
			;THROW 50000, 'Datumi nisu navedeni ili su u neispravnom redoslijedu!', 1
		END

	--provjera da li su datumi odgovaraju datumima termina (samo ako je naveden konkretni termin)
	IF @leaves_termin_id IS NOT NULL --ako je naveden konkretni termin
		BEGIN
			DECLARE   @TerminStart date
					, @TerminEnd date

			--nadji datume pocetka i kraja termina
			SELECT    @TerminStart	= leave_termin_start_date
					, @TerminEnd	= leave_termin_end_date
				FROM dbo.leaves_termins
				WHERE id = @leaves_termin_id

			--provjeri je li pocetak i kraj zatrazenog godisnjeg unutar datuma termina
			IF   @DateFrom NOT BETWEEN @TerminStart AND @TerminEnd
				OR @DateTo NOT BETWEEN @TerminStart AND @TerminEnd
				BEGIN
					;THROW 50000, 'Zatrazeni period godisnjeg izlazi izvan ponudjenog raspona za odabrani termin!', 1
				END
		END

	--provjera ima li taj zaposlenik dovoljno godisnjeg
	DECLARE @EmployeeRemainingLeaveDays int
	
	SET @EmployeeRemainingLeaveDays = (SELECT COALESCE(SUM(remaining_days),0) 
										FROM dbo.Fn_Remaining_Vacations(@employee_id)
										)

	IF dbo.Fn_No_Of_WorkingDays_Between_Dates(@DateFrom, @DateTo) > @EmployeeRemainingLeaveDays
		BEGIN
			;THROW 50000, 'Zatraženo je više godišnjeg nego što zaposlenik ima preostalo na raspolaganju!', 1
		END
	
	INSERT INTO dbo.employees_leaves_requests 
			(	
			  [request_date]
			, [employee_id]
			, [requester_user_id]
			, [approval_user_id]
			, [leave_termin_id]
			, [approved_request]
			, [employee_leave_request_start_date]
			, [employee_leave_request_end_date]
			, [request_description]
			)
		SELECT 
			  @request_date				AS [request_date]
			, @employee_id				AS [employee_id]
			, @Active_User_ID			AS [requester_user_id]
			, NULL						AS [approval_user_id]
			, @leaves_termin_id			AS [leave_termin_id]
			, 0							AS [approved_request]
			, @DateFrom					AS [employee_leave_request_start_date]
			, @DateTo					AS [employee_leave_request_end_date]
			, @description				AS [request_description]

END


--jos napraviti storu za Trosenje godisnjeg (employeeid, zahtjevid, datumod, datumdo)
/*
	stora mora po redu uzimati dane iz leavegroups (godisnjeg po godinama), prvo trositi najstariji godisnji
	i upisivati u tablic employees_leaves takve komadice
*/