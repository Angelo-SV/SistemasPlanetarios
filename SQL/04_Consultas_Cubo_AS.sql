/* ========================================================
   CONSULTAS MDX PARA EL CUBO ANALYSIS SERVICES (SSAS)
   ======================================================== */

--Top 10 planetas por ESI
SELECT 
    TOPCOUNT(
        [DIM Exoplanetas].[Pl Nombre].[Pl Nombre].MEMBERS,
        10,
        [Measures].[Pl Esi]
    ) ON ROWS,
    [Measures].[Pl Esi] ON COLUMNS
FROM [Sistemas Planetarios DW]

--Top 5 planetas más cercanos a la Tierra
SELECT 
    TOPCOUNT(
        [DIM Exoplanetas].[Pl Nombre].[Pl Nombre].MEMBERS,
        5,
        [Measures].[Pl Años Luz Tierra]
    ) ON ROWS,
    [Measures].[Pl Años Luz Tierra] ON COLUMNS
FROM [Sistemas Planetarios DW]

--Promedio de temperatura por clasificación de planeta
SELECT 
    [DIM Clasificacion Planetas].[Pl Clasificacion Temperatura].[Pl Clasificacion Temperatura].MEMBERS ON ROWS,
    [Measures].[Pl Temperatura] ON COLUMNS
FROM [Sistemas Planetarios DW]

--Planetas más habitables (ESI > 0.8) por método de descubrimiento
SELECT 
    NONEMPTY(
        FILTER(
            [DIM Exoplanetas].[Pl Nombre].[Pl Nombre].MEMBERS,
            [Measures].[Pl Esi] > 0.8
        )
    ) ON ROWS,
    [Measures].[Pl Esi] ON COLUMNS
FROM [Sistemas Planetarios DW];

--Comparar radios promedios por tipo de planeta
WITH 
    MEMBER [Measures].[Avg Pl Radio Tierra] AS
        AVG(
            [DIM Exoplanetas].[Pl Nombre].[Pl Nombre].MEMBERS,
            [Measures].[Pl Radio Tierra]
        )
SELECT 
    [DIM Clasificacion Planetas].[Pl Tipo].[Pl Tipo].MEMBERS ON ROWS,
    [Measures].[Avg Pl Radio Tierra] ON COLUMNS
FROM [Sistemas Planetarios DW];