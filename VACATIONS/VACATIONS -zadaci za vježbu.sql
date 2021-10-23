--TESTIRANJA
--Podatke iz tablica uvijek brišemo uz dodavanje uvjeta, kako nebi sve obrisali...
DELETE FROM dbo.PickingGroupsMemebers WHERE 1=1


--CONCAT
--naredba za spajanje CONCAT('neki tekst' , 'neki drugi test') U zagrade unosimo paramtere
SELECT CONCAT('neki tekst' , 'neki drugi test')
SELECT CONCAT('neki tekst' ,' ' , 'neki drugi test')
SELECT CONCAT(EmployeLastName, ', ' ,EmployeFirstName,' je zaposlenik') FROM dbo.Employees 


--IMEFUNKCIJE(PARAM1,PARAM2,...)
--UPPER I LOWER za velika ili mala slova
--LEFT I RIGHT koristimo za rezanje slova (prvi parametar je rijec a drugi koliko slova uzimamo)
SELECT UPPER (RIGHT(EmployeLastName,2))

--Upiti>>> SELECT
SELECT pgm.*,emp.EmployeFirstName,emp.EmployeLastName
	FROM dbo.PickingGroupsMemebers AS pgm
		LEFT JOIN dbo.Employees AS emp ON emp.EmployeId = pgm.EmployeId
	WHERE PickingGroupId IS NULL or pgm.EmployeId IS NULL



--######################################################################################################################

--Zadatak 1.
--IMENA LJUDI U KOJU GRUPU PRIPADAJU (IME)
--SORT PO NAZIVU GRUPE A UNUTAR GRUPE PA PO REDOSLJEDU BIRANJA
--prvi stupac ime grupe drugi ime i prezime zaposlenika (prezime , ime) treci stupac redosljed biranja
--četvrti stupac inicijal moga imena i prezimena 
--peti stupac inicijali d.e 

SELECT pick.PickingGroupName AS prvi_stupac, CONCAT(emp.EmployeLastName,', ',emp.EmployeFirstName)AS ime_i_prezime_zaposlenika,
	pgm.SelectionOrder AS Redosljed_Biranja, CONCAT(LEFT(emp.EmployeFirstName,1),'. ',emp.EmployeLastName) AS četvrti_stupac, 
	CONCAT(LEFT(EmployeFirstName,1),'. ',LEFT(emp.EmployeLastName,1),'.')AS peti_stupac
	FROM dbo.PickingGroups AS pick
		LEFT JOIN dbo.PickingGroupsMemebers AS pgm ON pgm.PickingGroupId=pick.PickingGroupId
		LEFT JOIN dbo.Employees AS emp ON emp.EmployeId=pgm.EmployeId
	ORDER BY  pick.PickingGroupName, pgm.SelectionOrder

--########################################################################################################	

--Zadatak 2.
--ISPISI SVE USERE U APLIKACIJI I KOJOJ GRUPI PRIPADAJU
--user name (logi in) kao jedan stupac
--naziv grupe:opis grupe kao drugi stupac
--naredba za spajanje concat('neki tekst' , 'neki drugi test')




--#######################################################################################################
--Onaj select koji prikazuje popis ljudi u kojim su grupama i na kojem mjestu napravi u par dodatnih varijanti:

--A) da prikazuje samo one koji su prvi u svojoj grupi
--B) da prikazuje samo one koji su prvi ili drugi u svojoj grupi
--C) da prikazuje samo one koji su od drugog do cetvrtog mjesta
--D) da prikazuje samo one kojima ime pocinje sa slovom D
--E) da prikazuje samo one kojima ime pocinje istim slovom kao prezime
--F) da prikazuje one kojima ime pocinje slovom koje ce biti prije samog selecta odredjeno varijablom:
--DECLARE @Slovo nvarchar(max) = ‘D’
--G) prikazuje samo one kojima je u nazivu picking grupe negdje (bilo gdje) slovo D
--H) isto kao G) ali slovo nije fixno nego se koristi ona varijabla iz F)
--I) samo one kojima negdje u nazivu njihove grupe postoji prvo slovo njihovog imena
DECLARE @Slovo nvarchar(max) = 'D'
SELECT pick.PickingGroupName AS prvi_stupac, CONCAT(emp.EmployeLastName,', ',emp.EmployeFirstName)AS ime_i_prezime_zaposlenika,
	pgm.SelectionOrder AS Redosljed_Biranja, CONCAT(LEFT(emp.EmployeFirstName,1),'. ',emp.EmployeLastName) AS četvrti_stupac, 
	CONCAT(LEFT(EmployeFirstName,1),'. ',LEFT(emp.EmployeLastName,1),'.')AS peti_stupac
	FROM dbo.PickingGroups AS pick
		LEFT JOIN dbo.PickingGroupsMemebers AS pgm ON pgm.PickingGroupId=pick.PickingGroupId
		LEFT JOIN dbo.Employees AS emp ON emp.EmployeId=pgm.EmployeId
	WHERE
		--A) da prikazuje samo one koji su prvi u svojoj grupi
		--pgm.SelectionOrder=1
		--.SelectionOrder IN (1)

		--B) da prikazuje samo one koji su prvi ili drugi u svojoj grupi
		--pgm.SelectionOrder=1 OR pgm.SelectionOrder=2
		--pgm.SelectionOrder IN (1,2)

		--C) da prikazuje samo one koji su od drugog do cetvrtog mjesta
		--pgm.SelectionOrder>=2 AND pgm.SelectionOrder<=4
		--pgm.SelectionOrder BETWEEN 2 AND 4
		
		--da prikazuje samo one kojima ime pocinje sa slovom D
		--EmployeFirstName LIKE 'D%'

		--F) da prikazuje one kojima ime pocinje slovom koje ce biti prije samog selecta odredjeno varijablom: DECLARE @Slovo nvarchar(max) = ‘D’
		--EmployeFirstName  LIKE CONCAT( @Slovo, '%')

		--G) prikazuje samo one kojima je u nazivu picking grupe negdje (bilo gdje) slovo D
		--EmployeFirstName LIKE '%D%'

		--H)isto kao G) ali slovo nije fixno nego se koristi ona varijabla iz F)
		--EmployeFirstName  LIKE CONCAT( '%', @Slovo, '%')

		--I) samo one kojima negdje u nazivu njihove grupe postoji prvo slovo njihovog imena
		--(EmployeFirstName LIKE CONCAT((LEFT(EmployeFirstName,1)), '%')) = (PickingGroups LIKE CONCAT('%', (LEFT(PickinhGroupName,1)), '%'))
		--PickingGroupName LIKE CONCAT('%', (LEFT(EmployeFirstName,1)), '%')
	ORDER BY  pick.PickingGroupName, pgm.SelectionOrder

-------------------------------------------------------------------------------------------------------------
--15.02.2020

Update dbo.employees
Set createdat = dateadd(day, employeid, '20210201')

SELECT * 
FROM Employees

SELECT EOMONTH('20210101') 

--KAKO DOBITI DATUM KOJI JE PRVI VELJACE U ZADANOJ GODINI

@2048-02-01

20<10

---------------------------------------------------------------------------------------------------------------
--                                       date test
-------------------------------------------------------------------------------------------------------------


--u varijabli "DECLARE @ZadaniDatum date" je upisan neki datum. napisi
--select koji ima slijedece stupce:
DECLARE @ZadaniDatum date
SET @ZadaniDatum = '20110819'
SELECT
     --taj datum
	 @ZadaniDatum AS TAJ_Datum,
     
	 --koja je to godina
	YEAR(@ZadaniDatum) AS godina,
    
	-- koji je to mjesec
	MONTH(@ZadaniDatum) AS Mjesec,
    
	--koji je to dan u mjesecu
	DAY(@ZadaniDatum) AS DAN,
    
	--prvi dan u toj godini
	DATEFROMPARTS ( year(@ZadaniDatum), 1, 1 ) AS PRVI_DAN,

    --prvi dan u tom mjesecu
	DATEFROMPARTS ( YEAR(@ZadaniDatum), MONTH(@ZadaniDatum), 1 ) AS PRVI_DAN_MJESEC,
    
	--zadnji dan u toj godini
	EOMONTH(DATEFROMPARTS(YEAR(@ZadaniDatum), 12, 1 ))AS zadnjiDanUTojGodini,
   --ili 
   DATEFROMPARTS(YEAR(@ZadaniDatum), 12, 31 ) AS zadnjiDanUTojGodini

 

--u varijabli "DECLARE @DatumRodjenja date" je upisan neki datum necijeg rodjenja. napisi select koji ima slijedece stupce:

DECLARE @DatumRodjenja date
SET @DatumRodjenja = '19900519'
SELECT
    --taj datum rodjenja
	 @DatumRodjenja AS datum_rodjenja,
    
	--danasnji datum (dat ce ti i vrijeme, nema veze)
	GETDATE() AS DANASNJI_DATUM,
    
	--koja je sad godina
	YEAR(GETDATE()) AS SGodina,
    
	--koji je sad mjesec
	MONTH(GETDATE()) AS SMjesec,

    --koji je danas dan u mjesecu
	DAY(GETDATE()) AS SDan,

    --koliko je sad ta osoba stara u danima
	DATEDIFF(DAY,@DatumRodjenja,GETDATE()) AS osoba_stara_u_danima,

    --koliko je sad ta osoba stara u mjesecima
	DATEDIFF(MONTH,@DatumRodjenja,GETDATE()) AS osoba_stara_u_Mjesecima,
     
	--koliko je sad ta osoba stara u godinama
	DATEDIFF(YEAR,@DatumRodjenja,GETDATE()) AS osoba_stara_u_Godinama,

    --koliko je sad ta osoba stara u satima
	DATEDIFF(HOUR,@DatumRodjenja,GETDATE()) AS osoba_stara_u_Satima,
     
	--kojeg datuma je imala tri mjeseca
	DATEADD(MONTH, 3, @DatumRodjenja)AS imala_tri_mjeseca,
    
	--kojeg datuma je zivjela tocno 1000 dana
	DATEADD(DAY, 1000, @DatumRodjenja) AS Zivjela_1000_dana,

    --kojeg datuma je zivjela tocno pedeset tisuća sati
	DATEADD(HOUR, 50000, @DatumRodjenja) AS pedeset_tisuća_sati
     
	--kojeg datuma je napunila 18 godina
	DATEADD(YEAR, 18, @DatumRodjenja) AS Pgodina,
    
	--kojeg datuma ce napuniti 50 godina
	DATEADD(YEAR, 50, @DatumRodjenja) AS PEDESETgodina,

    --kojeg datuma ce napuniti 100 godina
	DATEADD(YEAR, 100, @DatumRodjenja) AS Stogodina,

	--ako je do sad prezivjela tocno pola zivota, kojeg datuma ce umrijeti
	DATEADD(YEAR, (DATEDIFF(YEAR,@DatumRodjenja, GETDATE() )), GETDATE()) 	AS SMRT,
	--ili
	DATEADD(DAY, (DATEDIFF(DAY,@DatumRodjenja, GETDATE() )), GETDATE()) AS SMRT


--kad spominjem "datum zaposlenika" uvijek misllim na onaj dbo.employees.CreatedAt
--napisi selectove koji vracaju one zaposlenike koji
GO
DECLARE @Eri  DATE
SET @Eri = ( SELECT CreatedAt  FROM Employees where EmployeLastName='Eri')
SELECT *
	FROM dbo.employees
	WHERE
		--imaju datum u proslosti ili danasnji
		--CreatedAt<=GETDATE()

		--imaju datum strogo u buducnosti (ne smije biti danasnji)
		--CreatedAt>GETDATE()

		--imaju datum strogo u proslosti (ne smije biti danasnji)
		--CreatedAt<DATEADD(DAY, -1, GETDATE())

		--imaju datum prije Božića
		--CreatedAt<DATEFROMPARTS ( year(CreatedAt),12, 25) 
		
		--imaju datum na sam Božić
		--CreatedAt = DATEFROMPARTS( year(CreatedAt),12, 25 ) 

		--imaju datum u kojem je dan u mjesecu jednak kao sto je tom zaposleniku redni broj za biranje godisnjeg u grupi
		--CreatedAt = DATEFROMPARTS ( year(CreatedAt),MONTH(CreatedAt), DAY())


		--imaju datum u mjesecu koji je manji nego zaposlenikov redni broj za biranje godisnjeg
		--DAY(CreatedAt)<(SELECT SelectionOrder FROM PickingGroupsMemebers)

		--imaju datum kojemu je dan u mjesecu isti broj kao i mjesec
		--DAY(CreatedAt) = MONTH(CreatedAt)

		--imaju datum kojemu je mjesec veci nego dan u mjesecu
		--MONTH(CreatedAt)>DAY(CreatedAt)


		--imaju datum kojemu je umnozak dana u mjesecu i mjeseca veci ili jednak 50
		--(MONTH(CreatedAt)*DAY(CreatedAt))>=50


		--imaju datum koji je zadnji dan u mjesecu
		--Employees.CreatedAt = DATEFROMPARTS(YEAR(CreatedAt),MONTH(CreatedAt),DAY(EOMONTH(CreatedAt)))
		--CreatedAt = EOMONTH(CreatedAt)


		--imaju datum koji je prvi dan u mjesecu
		--Employees.CreatedAt=DateADD(DAY,1,(DATEFROMPARTS(YEAR(CreatedAt),MONTH(CreatedAt), DAY(EOMONTH(CreatedAt)))))
		--CreatedAt = DATEFROMPARTS(YEAR(CreatedAt), MONTH(CreatedAt),1)


		--imaju datum koji nije u prijestupnoj godini
			--GO
			--UPDATE dbo.Employees 
			--SET createdAt= '20240229'
			--WHERE employeid= 1
			--GO
			--SELECT *
			--	FROM dbo.employees
			--	WHERE NOT DAY(EOMONTH(CreatedAt))=29 
			--GO



		--imaju datum koji je prije datuma kojeg u tablici ima Cico
		--DECLARE @Eri  DATE
		--SET @Eri = ( SELECT CreatedAt  FROM Employees where EmployeLastName='Eri')
		--CreatedAt < @Eri

		--imaju datum koji je nakon datuma kojeg u tablici ima Cico
		--CreatedAt > @Eri

		--imaju datum koji je istog datuma kao i onaj kojeg u tablici ima Cico
		--CreatedAt = @Eri

		--imaju datum koji ima isti mjesec kado datum kod Cice
		--MONTH(CreatedAt) = MONTH(@Eri)
		
		--imaju datum koji imaju isti dan u mjesecu kao datum kod Cice
		--DAY(CreatedAt) = DAY(@Eri)

		--koji su 40 ili vise dana nakon datuma od cice
		--DATEADD(DAY,40,@Eri)<CreatedAt


		--one zaposlenike kod kojih je mjesec jednak broju dana u mjesecu kod cice, 
		--MONTH(CreatedAt)=DAY(@Eri)  
		--a dan u mjesecu kod tih zaposlenika je jednak mjesecu kod cice
		--DAY(CreatedAt)=MONTH(@Eri)
		--CreatedAt=DATEFROMPARTS(YEAR(CreatedAt),MONTH(DAY(@Eri)),DAY(MONTH(@Eri)))


--####################################################################################################################################
--#####################################				JOIN-Vježba						##################################################
--####################################################################################################################################	

--adm schema

--1 popis usera i u koje grupe pripadaju
SELECT	 u.User_Name
		,g.Group_Name
	FROM adm.users AS u
		INNER JOIN adm.Groups_Members	AS gm	ON u.User_Id	=	gm.User_Id
		INNER JOIN adm.Groups			AS g	ON gm.Group_Id	=	g.Group_Id


--3 popis usera i opis dodijeljenih prava (za svakog usera moze biti vise
--redova), hocu vidjeti sve usere cak i ako nemaju dodijeljenih prava	
SELECT 
	 u.User_Name AS username
	,g.Group_Description 
	,[Can_Approve_Request], [Can_Enter_Request], [Can_Add_Free_Days], [Can_Add_New_User], [Can_Change_Group_Rights]
	FROM adm.Users AS u
		LEFT JOIN adm.Groups_Members	AS gm	 ON u.User_Id	=	gm.User_Id
		LEFT JOIN adm.Groups			AS g	 ON gm.Group_Id	=	g.Group_Id
	order by username



--1 popis grupa i njima dodijeljenih prava (moze se grupa vise puta spominjati).
SELECT 
		g.Group_Name, 
		gr.Group_Right_Description
	FROM adm.Groups AS g
		RIGHT JOIN adm.Group_Rights AS gr ON g.Group_Id	=	gr.Group_id


--1 popis mogucih prava i u kojim grupama su dodijeljena (hocu vidjeti sva
--prava a ne samo ona koja se koriste)											
SELECT 
	group_Right_Id, 
	group_Right_Description, 
	COALESCE(g.Group_Name,  'Nije dodijeljen')
	FROM adm.Group_Rights AS gr	
		LEFT JOIN adm.Groups AS g	ON gr.Group_id	=	g.Group_Id


--$$$$$$$$$$$$$$$$$
----ako je prvi null ispisat ce prvi sljedeci parametar koji nije null! 
-- paziti jer mora biti isti tip podataka
--COALESCE(g.Group_Name,  'Nije dodijeljen')
--$$$$$$$$$$$$$$$$$

--dbo schema

--rezultati joineova smiju neke podatke prikazati vise puta ako tako ispadne join...

--2 najdi one zaposlenike kojima su dodijeljeni slobodni dani bazirano na
--pravu za "vadjenje krvi" u 2020 godini. Konkretnu godinu i pravni razlog
--filtriraj u whereu, ne odmahu joineu, ali napisi i join i where
SELECT 
	 e.Employe_First_Name
	,e.Employe_Last_Name
	,elr.Number_Of_Days
	,Ground_Right_Name

	FROM dbo.Employees AS e
		INNER JOIN Employees_Leave_Rights AS elr	ON e.Employe_Id			=	elr.Employe_Id 
		LEFT JOIN Leave_Grounds						ON elr.Ground_Id		=	dbo.Leave_Grounds.Ground_Id
		INNER JOIN Leave_Groups						ON elr.Leave_Group_Id	=	dbo.Leave_Groups.Leave_Group_Id
			WHERE 1=1
			 AND	Ground_Right_Name	=	'vadjenje krvi' 
			 AND	Leave_Group_Year	=	2020 


--2 ispisi one grupe u kojima je na prvom mjestu zaposlenik kojemu su u
--godisnjem za 2020-tu uracunati i slobodni dani od vadjena krvi
SELECT pgr.Picking_Group_Name
	FROM dbo.Picking_Groups AS pgr
	LEFT JOIN dbo.Picking_Groups_Memebers	AS pgm	ON pgr.Picking_Group_Id= pgm.Picking_Group_Id
	LEFT JOIN dbo.Employees					AS e	ON pgm.Employe_Id=e.Employe_Id
	LEFT JOIN dbo.Employees_Leave_Rights	AS elr	ON elr.Employe_Id		=	e.Employe_Id
	LEFT JOIN dbo.Leave_Grounds				AS lg	ON elr.Ground_Id=lg.Ground_Id
	LEFT JOIN dbo.Leave_Groups				AS lgr	ON elr.Leave_Group_Id=lgr.Leave_Group_Id
	WHERE lg.Ground_Right_Name='vadnjen krvi'
		AND lgr.Leave_Group_Year=2020


--3 ispisi one odjele u kojima je radio zaposlenik koji je dok je radio
--u tom odjelu predao zahtjev za godisnji u terminu koji ima ID=1
SELECT 
	d.Department_Name
	FROM dbo.Departments AS d
	LEFT JOIN dbo.Employments				AS emp	ON d.Department_Id		=	emp.Department_Id
	LEFT JOIN dbo.Employees					AS e	ON emp.Employe_Id		=	e.Employe_Id
	LEFT JOIN dbo.Employees_Leaves_Requests AS elr	ON e.Employe_Id			=	elr.Employe_Id
	LEFT JOIN dbo.Leaves_Termins			AS lt	ON elr.Leave_Termin_Id	=	lt.Leave_Termin_Id
		WHERE 
			lt.Leave_Termin_Id = 1 
			AND elr.Created_At BETWEEN emp.Employe_Hire_Date AND emp.Employe_Termination_Date

	


--3 ispisi one zahtjeve za godisnji koje je odobrio adm.user koji NIJE zaduzen za taj odjel
SELECT null 
	 ,elr.Employe_Leave_Request_Id
	 --e.Employe_First_Name 
	,u.User_Name AS odobrio
	 --,d.Department_Name AS Odjel_zaposlenika
	 --,d.Manager_User_ID AS zaduzeni_user_za_zaposlenikov_odjel
	 ,elr.Approval_User_Id as User_koji_je_odobrio_zahtjev	 
	--,CONCAT(elr.Start_Datee,'-',elr.End_Date) AS OD_kada_DO_kada
	--,elr.Request_Description
	,EMP.Employe_Id	,	elr.Employe_Id 
	,elr.Created_At , emp.Employe_Hire_Date , emp.Employe_Termination_Date


	FROM dbo.Employees_Leaves_Requests AS elr 

	INNER JOIN adm.Users			AS u ON elr.Approval_User_Id	=	u.User_Id 
	--LEFT JOIN dbo.Employees AS e ON e.Employe_Id	=	elr.Employe_Id

	LEFT join dbo.Employments AS emp ON EMP.Employe_Id	=	elr.Employe_Id 
										AND 
										elr.Created_At between emp.Employe_Hire_Date and emp.Employe_Termination_Date --ZAPOSLENJE RELEVANTNO ZA TAJ ZAHTJEV ZA GODISNJIE
	
	INNER JOIN Departments AS d ON emp.Department_Id	=	d.Department_Id--
		WHERE elr.Approval_User_Id <> d.Manager_User_ID
		--koje je odobrio adm.user koji NIJE zaduzen za taj odjel
	


	UPDATE dbo.Employments SET Employe_Termination_Date ='20011231'
		

select * from dbo.Departments
select * from adm.users
select * from dbo.Employees_Leaves_Requests


SELECT * 
	FROM dbo.Employees_Leaves AS godisnji_iskoristeni

	JOIN dbo.Employees AS zaposlenik ON godisnji_iskoristeni.Employe_Id=zaposlenik.Employe_Id

	JOIN dbo.Leave_Groups AS goGODINA ON godisnji_iskoristeni.Leave_Group_Id=goGODINA.Leave_Group_Id

	JOIN dbo.Employees_Leave_Rights AS zaradjeni_dani ON goGODINA.Leave_Group_Id= zaradjeni_dani.Leave_Group_Id



														AND  godisnji_iskoristeni.Employe_Id=zaradjeni_dani.Employe_Id

godisnji el

grupa godisnje 

prava elr

--3 ispisi one odradjene godisnje u kojima su se iskoristili dani dobiveni zbog vadjenja krvi		
SELECT el.Employe_Leave_Name
	FROM dbo.Employees_Leaves AS el
	--LEFT JOIN dbo.Employees					AS e	ON el.Employe_Id	=	e.Employe_Id

	LEFT JOIN dbo.Employees_Leave_Rights	AS elr	ON e.Employe_Id		=	elr.Employe_Id
	INNER JOIN dbo.Leave_Grounds			AS lg	ON elr.Ground_Id	=	lg.Ground_Id
		WHERE lg.Ground_Right_Name	=	'vadjenje krvi'


--1 ispisi one termine za koje nema zahtjeva
SELECT 
	lt.Leave_Termin_Name
	FROM dbo.Leaves_Termins AS lt
			LEFT JOIN dbo.Employees_Leaves_Requests AS elr	ON lt.Leave_Termin_Id	=	elr.leave_termin_id
			WHERE elr.Employe_Leave_Request_Id IS NULL


--4 ispisi one termine u kojima ima godisnjih (OPREZ: na godisnji se moze
--ici i bez zahtjeva ili godisnji moze biti u datumima drugacijim nego sto
--je bilo u inicijalnom zahtjevu, dakle ne spajam preko zahtjeva nego
--direktno termin sa odradjenim godisnjima)
SELECT 
	el.Employe_Leave_Name
	FROM dbo.Employees_Leaves AS el
	LEFT JOIN dbo.Employees_Leaves_Requests AS elr ON el.Employe_Leave_Request_Id = elr.Employe_Leave_Request_Id
	WHERE elr.End_Date = Employe_Leave_End


--4 ispisi one parove zaposlenika koji imaju isti CreatedAt datum.
SELECT 
	 CONCAT(e.Employe_First_Name,  ' ' , e.Employe_Last_Name) AS Zaposlenik
	,CONCAT(e2.Employe_First_Name, ' ' , e2.Employe_Last_Name) AS Njegov_par
	FROM dbo.Employees AS e
	INNER JOIN dbo.Employees AS e2 ON e.Created_At	=	e2.Created_At
	WHERE e.Employe_First_Name <> e2.Employe_First_Name AND e.Employe_Last_Name <> e2.Employe_Last_Name


--3 ispisi zaposlenike i uz njih termin koji ukljucuje CreatedAt datum tog
--zaposlenika
		
SELECT +
	 CONCAT(e.Employe_First_Name,' ' , e.Employe_Last_Name) AS zaposlenik
	,lt.Leave_Termin_Name +' '+ e.Created_At AS termin_i_datum
	FROM dbo.Employees AS e
	LEFT JOIN dbo.Employees_Leaves_Requests AS elr ON e.Employe_Id	=	elr.Employe_Id
	LEFT JOIN dbo.Leaves_Termins AS lt ON elr.Leave_Termin_Id = lt.Leave_Termin_Id


--3 Ispisi one zaposlenike koji su dali zahtjev za godisnji u vrijeme njihovog createdat datuma
SELECT 
	CONCAT(e.Employe_Last_Name, ', ', e.Employe_First_Name) AS Zaposlenici
	FROM dbo.Employees AS e
	LEFT JOIN dbo.Employees_Leaves_Requests AS emr ON e.Employe_Id	=	emr.Employe_Id
		WHERE emr.Created_At	=	e.Created_At


--4 ispisi one zaposlenike kojima je red biranja u grupi veci nego id
--termina za koji su dali zahtjev
SELECT 
	CONCAT(e.Employe_First_Name,' ',e.Employe_Last_Name) AS Zaposlenici
	FROM dbo.Employees AS e
	LEFT JOIN dbo.Picking_Groups_Memebers	AS pgm	ON e.Employe_Id			=	pgm.Employe_Id
	LEFT JOIN dbo.Employees_Leaves_Requests AS elr	ON e.Employe_Id			=	elr.Employe_Id
	LEFT JOIN dbo.Leaves_Termins			AS lt	ON elr.Leave_Termin_Id	=	lt.Leave_Termin_Id
		--WHERE pgm.Selection_Order > elr.Employe_Leave_Request_Id
	--  ako zelimo ponuđeni termin onda bi uvjet bio 
	 WHERE pgm.Selection_Order > lt.Leave_Termin_Id


--3 ispisi svakog zaposlenika i uz njega u drugom stupcu sve one druge
--zaposlenike koji imaju manji CreatedAt datum od njega
SELECT
	 CONCAT(e.Employe_First_Name, ' ', e.Employe_Last_Name) AS Z1
	,CONCAT(e2.Employe_First_Name , ' ' ,e2.Employe_Last_Name ) AS Z2
	FROM dbo.Employees AS e
	LEFT JOIN Employees AS e2		ON		e.Employe_Id	=	e2.Employe_Id
		WHERE e2.Created_At < e.Created_At
	

--3 ispisi one zaposlenike kojima je njihov red na biranje u grupi jednak
--mjesecu njihovog createdat datuma	
SELECT 
	e.Employe_First_Name, 
	e.Employe_Last_Name
	FROM dbo.Employees AS e
		LEFT JOIN dbo.Picking_Groups_Memebers AS pgm ON e.Employe_Id	=	pgm.Employe_Id
			WHERE pgm.Selection_Order = MONTH(e.Created_At)


--2 ispisi one zaposlenike kojima je godisnji odobrio isti adm.user koji
--je ispunio i zahtjev za taj godisnji
--i napisi usera koji je unio i onog koji je odobrio
SELECT 
	 emp.Employe_First_Name
	,emp.Employe_Last_Name 
	,u_req.User_Name
	,u_apr.User_Name
	FROM dbo.Employees AS emp
		INNER JOIN dbo.Employees_Leaves_Requests	AS elr				ON emp.Employe_Id			=	elr.Employe_Id
		INNER JOIN adm.Users						AS u_req			ON elr.Requester_User_Id	=	u_req.User_Id
		INNER JOIN adm.Users						AS u_apr			ON elr.Approval_User_Id		=	u_apr.User_Id
			WHERE elr.Approval_User_Id = elr.Requester_User_Id


--5 postoji bojazan da je ekipa iz financija u dogovoru sa zaposlenicima:
--unose im slobodne dane na racun izmisljenih uvjeta i onda im odobravaju
--godisnje. izlistaj sumnjive:
--ispisi one zaposlenike koji su nekad ispunili zahtjev koji je rezultirao
--pravim godisnjim ali da se tad poklopilo da je isti adm.user im
--dodijelio slobodne dane koji su (mozda) koristeni u tom godisnjem, a
--istovremeno im je taj adm.user i odobrio godisnji.
SELECT 
	CONCAT(e.Employe_First_Name, ' ', e.Employe_Last_Name) AS Zaposlenik
	FROM dbo.Employees AS e
	INNER JOIN dbo.Employees_Leaves_Requests	AS elr		ON e.Employe_Id					= elr.Employe_Id
	INNER JOIN dbo.Employees_Leaves				AS el		ON elr.Employe_Leave_Request_Id	= el.Employe_Leave_Request_Id
	LEFT JOIN adm.Users							AS u		ON elr.Approval_User_Id			= u.User_Id
	LEFT JOIN dbo.Employees_Leave_Rights		AS elrig	ON u.User_Id					= elrig.User_Id
		WHERE elrig.User_Id = elr.Approval_User_Id


Select e.Created_At 
FROM dbo.Employees AS e
INNER JOIN dbo.Leaves_Termins AS lt ON e.Created_At Between lt.Leave_Start_Date AND lt.Leave_End_Date

--###################################################################################################################################-----------------------------
--###################################################################################################################################
--###################################################################################################################################u nekoj godini mogu biti otvorene npr tri leave_grupe, npr:
/*
go2020									2020
covid_izolacije_2020					2020
slobodni_dani_za_skolovanje				2020
To su tri razlicite grupe ali sve je u istoj godini!
*/

--lista zaposlenika (ime, prezime) i koliko godisnjeg imaju DODIJELJENO u kojoj LEAVE_GROUP (ime grupe napisi) ?
GO

primjer grupiranja s navodjenjem dodatnih polja iz iste tablice koja ne utjecu na grupe
SELECT 
	 CONCAT(e.employee_first_name,', ',e.employee_last_name)		AS ime_i_prezime
	,SUM(elr.number_of_days)										AS godisnjeg_dodjeljeno
	,MIN(lg.leave_group_name)										AS ime_grupe	
FROM dbo.employees AS e
LEFT JOIN dbo.employees_leave_rights	AS elr	ON e.id=elr.employee_id
LEFT JOIN dbo.leave_groups				AS lg	ON elr.leave_group_id=lg.id
--WHERE lg.leave_group_name IS NOT NULL AND elr.number_of_days IS NOT NULL AND employee_last_name='Eri'
GROUP BY e.id, e.employee_first_name, e.employee_last_name, lg.leave_group_name

primjer koristenja podupita: join na rezulutat selecta kao da je tablica

SELECT e.employee_last_name, e.employee_first_name
	,podupit.godisnjeg_dodjeljeno
	,podupit.ime_grupe
	FROM dbo.employees e
		LEFT JOIN (SELECT 
						-- CONCAT(e.employee_first_name,', ',e.employee_last_name)		AS ime_i_prezime
						elr.employee_id
						,SUM(elr.number_of_days)										AS godisnjeg_dodjeljeno
						,MIN(lg.leave_group_name)										AS ime_grupe	
					FROM 
						dbo.employees_leave_rights			AS elr	
						LEFT JOIN dbo.leave_groups			AS lg	ON elr.leave_group_id=lg.id
					--WHERE lg.leave_group_name IS NOT NULL AND elr.number_of_days IS NOT NULL AND employee_last_name='Eri'
					GROUP BY elr.employee_id, lg.leave_group_name) AS podupit ON e.id = podupit.employee_id

GO


--lista zaposlenika (ime, prezime) i koliko godisnjeg imaju DODIJELJENO u
--kojoj GODINI (napisi godinu)?

SELECT 
	 MIN(CONCAT(employee_first_name,', ',employee_last_name))	AS ime_i_prezime
	,SUM(number_of_days)										AS godisnjeg_dodjeljeno
	,leave_group_year											AS godine_dodjeljeno
FROM dbo.employees AS e
LEFT JOIN dbo.employees_leave_rights	AS elr	ON e.id=elr.employee_id
LEFT JOIN dbo.leave_groups				AS lg	ON elr.leave_group_id=lg.id
GROUP BY e.id, lg.leave_group_year



--ako gledamo prema godini zahtjeva (uzmi ju iz datuma zahtjeva) prikazati
--po zaposleniku i po godini zahtjeva:
--koliko su ukupno dana godisnjeg REQUESTALI
GO
SELECT 
		 CONCAT(employee_last_name,', ',employee_first_name)												AS prezime_i_ime
		,YEAR(request_date)																						AS godina_zahtjeva
		,SUM(DATEDIFF(DAY,elr.employee_leave_request_start_date , elr .employee_leave_request_end_date))		AS dana_u_zahtjevu
FROM dbo.employees_leaves_requests AS elr
LEFT JOIN dbo.employees AS e ON elr.employee_id=e.id
GROUP BY e.ID, CONCAT(employee_last_name,', ',employee_first_name), YEAR(elr.request_date)


GO
     
--koliko su ukupno zahtjeva podnesli
GO
SELECT  
		 CONCAT(e.employee_last_name, ', ' , e.employee_first_name)	AS Prezime_i_ime_zaposlenika
		,YEAR(elr.request_date)											AS u_kojoj_godini
		,COUNT(elr.id)														AS Zahtjeva_podnesli
FROM dbo.employees_leaves_requests AS elr
LEFT JOIN dbo.employees AS e ON elr.employee_id=e.id
GROUP BY e.id, CONCAT(e.employee_last_name, ', ' , e.employee_first_name), YEAR(elr.request_date)

GO

--koliko im je zahtjeva odobreno
GO
SELECT  
		 CONCAT(e.employee_last_name, ', ' , e.employee_first_name)		AS Prezime_i_ime_zaposlenika
		,YEAR(elr.request_date)											AS u_kojoj_godini
		,sum( case  
					WHEN elr.approved_request=0 then 0
					ELSE 1 
				end )										AS Zahtjeva_odobreno
FROM dbo.employees_leaves_requests AS elr
LEFT JOIN dbo.employees AS e ON elr.employee_id=e.id
--WHERE elr.approved_request=1
GROUP BY 
	e.id, CONCAT(e.employee_last_name, ', ' , e.employee_first_name) --ZAPOSLENIKE
	, YEAR(elr.request_date)

GO

--ORIG
SELECT 
	 e.id																								AS	employee_id
	,lg.leave_group_year																							AS	leave_group_id
	,elr.ground_id
	,elr.number_of_days																				AS	allocated_days
	,el.id AS LEAVE_id
	,DATEDIFF(DAY,el.employee_leave_start_date,el.employee_leave_end_date)							AS	spent_days    
	,elr.number_of_days - (DATEDIFF(DAY,el.employee_leave_start_date,el.employee_leave_end_date))	AS	remaining_days
FROM dbo.employees AS e
LEFT JOIN dbo.employees_leave_rights		AS elr	ON e.id					=	elr.employee_id
LEFT JOIN dbo.leave_groups					AS lg	ON elr.leave_group_id	=	lg.id
--
LEFT JOIN dbo.employees_leaves				AS el	ON lg.id				=	el.leave_group_id
WHERE e.id=13 AND lg.leave_group_year=2020
ORDER BY e.id, LEAVE_ID
GROUP BY E.ID, lg.id

select * from employees where employee_last_name = 'Grbavac'
select * from employees_leave_rights where employee_id=22
CREATE VIEW PROBA AS
SELECT godisnji.employee_id, godisnji.leave_group_id, SUM(godisnji.allocated_days) AS Ukupno_dodijeljeno, SUM(godisnji.spent_days) as potroseno
		,COALESCE(SUM(godisnji.allocated_days),0) - COALESCE(SUM(godisnji.spent_days),0) AS preostalo
	FROM
		(
		SELECT 
			 e.id																								AS	employee_id
			,lg.id																								AS	leave_group_id
			,SUM(elr.number_of_days)																			AS	allocated_days
			, NULL AS	spent_days
		FROM dbo.employees AS e
		LEFT JOIN dbo.employees_leave_rights		AS elr	ON e.id					=	elr.employee_id
		LEFT JOIN dbo.leave_groups					AS lg	ON elr.leave_group_id	=	lg.id
		GROUP BY e.id, lg.id
		UNION ALL

		SELECT 
			 e.id																								AS	employee_id
			,lg.id																								AS	leave_group_id
			, NULL AS  allocated_days
			, SUM(DATEDIFF(DAY,el.employee_leave_start_date,el.employee_leave_end_date))						AS	spent_days    
		FROM dbo.employees AS e
		LEFT JOIN dbo.employees_leaves				AS el	ON e.id				=	el.employee_id
		LEFT JOIN dbo.leave_groups					AS lg	ON el.leave_group_id	=	lg.id
		GROUP BY e.id, lg.id
		)  AS godisnji
	GROUP BY godisnji.employee_id, godisnji.leave_group_id
	ORDER BY godisnji.employee_id, godisnji.leave_group_id

go

SELECT *

     FROM ( SELECT xxxxx FROM xxxxx --dohvat svih dodjeljivanja

                 UNION ALL

                 SELECT xxxxxx FROM yyyyyy --dohvat svih trosenja

                ) AS svi_dani

     GROUP BY nesto


--###################################################################################################################################
--##################################   PONOVO RIJEŠAVANJE ###########################################################################
--###################################################################################################################################
/*
u nekoj godini mogu biti otvorene npr tri leave_grupe, npr:
go2020										2020
covid_izolacije_2020						2020
slobodni_dani_za_skolovanje					2020
To su tri razlicite grupe ali sve je u istoj godini!
*/



--lista zaposlenika (ime, prezime) i koliko godisnjeg imaju DODIJELJENO u
--kojoj LEAVE_GROUP (ime grupe napisi) ?
GO
SELECT
	 e.id															AS id_zaposlenika
	,CONCAT(e.employee_first_name,', ',e.employee_last_name)		AS ime_i_prezime
	,SUM(elr.number_of_days)										AS godisnjeg_dodjeljeno
	,lg.leave_group_name											AS ime_grupe	
FROM dbo.employees													AS e
LEFT JOIN dbo.employees_leave_rights								AS elr				ON e.id					=	elr.employee_id
LEFT JOIN dbo.leave_groups											AS lg				ON elr.leave_group_id	=	lg.id
GROUP BY e.id, e.employee_first_name, e.employee_last_name, lg.leave_group_name
GO

--lista zaposlenika (ime, prezime) i koliko godisnjeg imaju DODIJELJENO u
--kojoj GODINI (napisi godinu)?
GO
SELECT 
	 e.id																AS id_zaposlenika
	,CONCAT(e.employee_first_name,', ',e.employee_last_name)			AS ime_i_prezime
	,SUM(elr.number_of_days)											AS godisnjeg_dodjeljeno
	,lg.leave_group_year												AS godine_dodjeljeno
FROM dbo.employees														AS e
LEFT JOIN dbo.employees_leave_rights									AS elr		ON e.id					=	elr.employee_id
LEFT JOIN dbo.leave_groups												AS lg		ON elr.leave_group_id	=	lg.id
GROUP BY e.id, e.employee_first_name, e.employee_last_name, lg.leave_group_year
GO


--ako gledamo prema godini zahtjeva (uzmi ju iz datuma zahtjeva) prikazati
--po zaposleniku i po godini zahtjeva:
--koliko su ukupno dana godisnjeg REQUESTALI	 
SELECT
	 e.id																									AS id_zaposlenika
	,CONCAT	(e.employee_last_name, ', ', e.employee_first_name)												AS prezime_i_ime
	,YEAR	(elr.request_date)																				AS godina_zahtjeva
	,SUM	(DATEDIFF(DAY, elr.employee_leave_request_start_date,elr.employee_leave_request_end_date))		AS ukupno_dana
FROM dbo.employees AS e
LEFT JOIN dbo.employees_leaves_requests AS elr ON e.id	=	elr.employee_id --543 rows( imamo vise jer nemaju svi zahtjeve!)
WHERE YEAR	(elr.employee_leave_request_start_date) IS NOT NULL -- Podnesli su 461 zahtjev
GROUP BY e.id, CONCAT (e.employee_last_name, ', ', e.employee_first_name),YEAR(elr.request_date)



--koliko su ukupno zahtjeva podnesli
SELECT 
	 e.id															AS id_zaposlenika
	,CONCAT	(e.employee_last_name, ', ', e.employee_first_name)		AS prezime_i_ime
	,YEAR	(elr.request_date)										AS godina_podnesenog_zahtjeva
	,COUNT	(elr.approved_request)									AS podneseno_zahtjeva
FROM dbo.employees AS e
LEFT JOIN dbo.employees_leaves_requests AS elr ON e.id	=	elr.employee_id --543 rows( imamo vise jer nemaju svi zahtjeve!)
WHERE YEAR	(elr.employee_leave_request_start_date) IS NOT NULL -- Podnesli su 461 zahtjev
GROUP BY e.id, CONCAT (e.employee_last_name, ', ', e.employee_first_name),YEAR(elr.request_date)
 

--koliko im je zahtjeva odobreno
GO
SELECT 
	 e.id															AS id_zaposlenika
	,CONCAT	(e.employee_last_name, ', ', e.employee_first_name)		AS prezime_i_ime
	,YEAR	(elr.request_date)										AS godina_podnesenog_zahtjeva
	,COUNT	(elr.approved_request)									AS odobreno_zahtjeva
FROM dbo.employees AS e
LEFT JOIN dbo.employees_leaves_requests AS elr ON e.id	=	elr.employee_id --543 rows( imamo vise jer nemaju svi zahtjeve!)
WHERE elr.approved_request = 1 -- 415 zahtjeva
GROUP BY e.id, CONCAT (e.employee_last_name, ', ', e.employee_first_name),YEAR(elr.request_date)
 
GO

--Provjera---> ukupno 461 zahtjev
SELECT * FROM dbo.employees_leaves_requests


--koliko im je zahtjeva odbijeno
GO
SELECT 
	 e.id															AS id_zaposlenika
	,CONCAT	(e.employee_last_name, ', ', e.employee_first_name)		AS prezime_i_ime
	,YEAR	(elr.request_date)										AS godina_podnesenog_zahtjeva
	,COUNT	(elr.approved_request)									AS odbijeno_zahtjeva
FROM dbo.employees AS e
LEFT JOIN dbo.employees_leaves_requests AS elr ON e.id	=	elr.employee_id --543 zahtjeva
WHERE elr.approved_request = 0 -- 46 zahtjeva
GROUP BY e.id, CONCAT (e.employee_last_name, ', ', e.employee_first_name),YEAR(elr.request_date)




GO
--kako bi u prethodnom zadatku prikazao samo one koji su requestali ukupno
--vise od 15 dana u godini?
GO
SELECT 
	 e.id																								AS id_zaposlenika
	,CONCAT	(e.employee_last_name, ', ', e.employee_first_name)											AS prezime_i_ime
	,YEAR	(elr.request_date)																			AS godina_podnesenog_zahtjeva
	,SUM	(DATEDIFF(DAY,elr.employee_leave_request_start_date,elr.employee_leave_request_end_date))	AS ZBROJ_dana
FROM dbo.employees AS e
LEFT JOIN dbo.employees_leaves_requests AS elr ON e.id	=	elr.employee_id --543 zahtjeva
WHERE (DATEDIFF(DAY,elr.employee_leave_request_start_date,elr.employee_leave_request_end_date))  > 15
GROUP BY e.id, CONCAT (e.employee_last_name, ', ', e.employee_first_name),YEAR(elr.request_date)


--lista zaposlenika, leave_groupa i koliko u svakoj leave_Group imaju
--potroseno dana (procitaj iz tablice odradjenih godisnjih)?

SELECT 
	 e.id																			AS	employee_id
	,CONCAT	(e.employee_last_name, ', ', e.employee_first_name)						AS	ime_i_prezime
	,lg.leave_group_name															AS leave_group_name --(mogao sam i lg.id)
	,SUM(DATEDIFF(DAY,el.employee_leave_start_date,el.employee_leave_end_date))		AS iskoristeno_god
FROM	employees			AS e 
LEFT JOIN employees_leaves	AS el	ON e.id					=	el.employee_id	--912 rows
LEFT JOIN dbo.leave_groups	AS lg	ON el.leave_group_id	=	lg.id			--912 rows
GROUP BY e.id, CONCAT	(e.employee_last_name, ', ', e.employee_first_name), lg.leave_group_name
ORDER BY lg.leave_group_name


--************************************************************************************************************************************
/*
 select koji ima stupce

     employee_id

     leave_group_id

     allocated_days    (ukupno dana dodijeljeno u toj leave_group)

     spent_days    (potroseno dana u toj leave_group prema tablici
odradjenih godisnjih)

     remaining_days (preostalo dana, razlika dva prethodna podatka)

napravi dva selecta, jedan za dohvat transakcija kad su dani
dodjeljivani, drugi za dohvat potrosenih.

ta dva selecta union all u jedan veliki dataset.

*/
GO
CREATE VIEW V_employees_leave_days AS
SELECT 
	 vacations.employee_id																					AS employee_id
	,vacations.leave_group_id																				AS leave_group_id
	,COALESCE(SUM(vacations.allocated_days),0)																AS allocated_days
	,COALESCE(SUM(vacations.spent_days),0)																	AS spent_days
	,COALESCE(SUM(vacations.allocated_days),0)-COALESCE(SUM(vacations.spent_days),0)						AS remaining_days
FROM		(SELECT 
				 e.id								AS employee_id
				,lg.id								AS leave_group_id
				,SUM(number_of_days)				AS allocated_days
				,NULL								AS spent_days
			FROM dbo.employees						AS e
			LEFT JOIN dbo.employees_leave_rights	AS elr	ON e.id					=	elr.employee_id
			LEFT JOIN dbo.leave_groups				AS lg	ON elr.leave_group_id	=	lg.id
			GROUP BY e.id , lg.id
			--HAVING e.id=13 --Provjera samo za jednog zaposlenika
			----------
			UNION ALL
			----------
			SELECT 
				 e.id																		AS employee_id
				,lg.id																		AS leave_group_id
				,NULL																		AS allocated_days
				,SUM(DATEDIFF(DAY,el.employee_leave_start_date,el.employee_leave_end_date))	AS spent_days
			FROM dbo.employees						AS e
			LEFT JOIN dbo.employees_leaves			AS el	ON e.id					=	el.employee_id
			LEFT JOIN dbo.leave_groups				AS lg	ON el.leave_group_id	=	lg.id
			GROUP BY e.id , lg.id)		AS vacations
GROUP BY vacations.employee_id , vacations.leave_group_id 
--HAVING vacations.employee_id=13 --Provjera samo za jednog zaposlenika
--ORDER BY vacations.employee_id, vacations.leave_group_id

GO
SELECT  remaining_days FROM[dbo].[V_employees_leave_days]

ovi ga V_employees_leave_days
*/
--*************************************************************************************************
