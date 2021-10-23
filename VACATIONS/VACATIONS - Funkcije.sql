ALTER FUNCTION dbo.Fn_DatesBetween (@DateFrom date, @DateTo date)
RETURNS @ListOfDates TABLE
	(
		 date_1			DATE
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
	INSERT INTO @ListOfDates (Date_1)
		SELECT
				 DATEADD( DD, RedniBrojevi.RBR-1, @DateFrom ) AS Date_1
			FROM
				(SELECT TOP(100000)
					ROW_NUMBER() OVER (ORDER BY t1.object_id) AS RBR
					FROM sys.all_objects AS t1
						CROSS JOIN sys.all_objects AS t2
				) AS RedniBrojevi 
			WHERE DATEADD( DD, RedniBrojevi.RBR-1, @DateFrom )<=@DateTo

	--Ispuni u svim redovima ime dana prema datumu
	UPDATE @ListOfDates
		SET day_name = DATENAME(WEEKDAY,date_1)

	--ispuni u svim redovima vrijednost za dan u tjednu prema datumu (koji je vec u tablici)
	UPDATE @ListOfDates
		SET day_in_week = DATEPART(WEEKDAY, Date_1)

	--postavi i onake koji je vikend a koji nije
	UPDATE @ListOfDates
		SET weekend = case 
						when day_in_week in (6,7) then 1 
						ELSE 0 
						END
/*
	--postavi na 1 da je praznik za one datume koji se nalaze u popisu datuma u drugoj tablci
	UPDATE @ListOfDates
		SET holiday = 1 
		WHERE Date_1 IN (SELECT holiday_date from dbo.National_holidays)

	UPDATE @ListOfDates
		SET holiday = 0
		WHERE holiday IS NULL
*/
	UPDATE @ListOfDates
		SET holiday = CASE 
						WHEN Date_1 IN (SELECT holiday_date from dbo.National_holidays) THEN 1
						ELSE 0
						END


	/*
	UPDATE dat
		SET holiday = CASE 
						WHEN nh.ID IS NOT NULL THEN 1 --ovaj resd se pojoineao, znaci postoji u natioanl holiday taj datum
						ELSE 0 END --za ostale redove koji se nisu pojoineali
		FROM @ListOfDates AS dat
			LEFT JOIN dbo.National_holidays  AS nh ON dat.Date_1=nh.holiday_date
	*/
		
	UPDATE @ListOfDates
		SET work_day = CASE 
							WHEN holiday=0 AND weekend=0 THEN 1
							ELSE 0
							END
		
		
		
		---WHERE holiday = 0 AND weekend = 0 -- DAA NIJE PRAZNIK I DA NIJE VIKEND
		
	RETURN
END