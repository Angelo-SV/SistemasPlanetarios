CREATE DATABASE [SistemasPlanetariosDW]
GO

USE [SistemasPlanetariosDW]
GO

-- =======================
-- DIMENSIONES
-- =======================

CREATE TABLE DIM_SistemasPlanetarios (
    sy_sk INT IDENTITY(1,1) PRIMARY KEY,          -- surrogate key
    sy_id INT NOT NULL,                           -- business key (del OLTP)
    sy_nombre NVARCHAR(255) NOT NULL,
    sy_constelacion NVARCHAR(255) NOT NULL,
    sy_estrellamasbrillante NVARCHAR(255) NOT NULL,
    sy_numero_estrellas INT NOT NULL,
    sy_numero_planetas INT NOT NULL,
    sy_distancia FLOAT NOT NULL
);

CREATE TABLE DIM_Estrellas (
    st_sk INT IDENTITY(1,1) PRIMARY KEY,
    st_id INT NOT NULL,
    st_nombre NVARCHAR(255) NOT NULL,
    st_temperatura_K INT NOT NULL,
    st_radio_sol FLOAT NOT NULL,
    st_masa_sol FLOAT NOT NULL,
    st_luminosidad FLOAT NOT NULL,
    st_edad FLOAT NOT NULL,
    st_densidad FLOAT NOT NULL
);

CREATE TABLE DIM_DescubrimientoPlanetas (
    desc_sk INT IDENTITY(1,1) PRIMARY KEY,
    descubrimiento_id INT NOT NULL,
    disc_centro_instalacion NVARCHAR(255) NOT NULL,
    disc_telescopio NVARCHAR(255) NOT NULL,
    disc_metodo NVARCHAR(255) NULL,
    disc_locacion NVARCHAR(255) NOT NULL
);

CREATE TABLE DIM_ClasificacionPlanetas (
    clasif_sk INT IDENTITY(1,1) PRIMARY KEY,
    pl_clasificacion_id INT NOT NULL,
    pl_tipo NVARCHAR(255) NOT NULL,
    pl_categoria NVARCHAR(255) NOT NULL,
    pl_clasificacion_temperatura NVARCHAR(255) NOT NULL,
    pl_status NVARCHAR(255) NOT NULL
);

CREATE TABLE DIM_Tiempo (
    tiempo_sk INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL,
    mes INT NOT NULL,
    año INT NOT NULL,
    trimestre INT NOT NULL
);

-- =======================
-- TABLA DE HECHOS
-- =======================

CREATE TABLE FACT_Exoplanetas (
    fact_id INT IDENTITY(1,1) PRIMARY KEY,

    -- Foreign Keys hacia dimensiones
    sy_sk INT NOT NULL,
    st_sk INT NOT NULL,
    desc_sk INT NULL,
    clasif_sk INT NULL,
    tiempo_sk INT NULL,

    -- Medidas
    pl_nombre NVARCHAR(255) NOT NULL,
    pl_periodo_orbital_dias FLOAT NOT NULL,
    pl_radio_tierra FLOAT NOT NULL,
    pl_mass_tierra FLOAT NOT NULL,
    pl_densidad FLOAT NOT NULL,
    pl_temperatura INT NOT NULL,
    pl_esi FLOAT NOT NULL,
    pl_años_luz_tierra INT NOT NULL,

    -- Relaciones
    FOREIGN KEY (sy_sk) REFERENCES DIM_SistemasPlanetarios(sy_sk),
    FOREIGN KEY (st_sk) REFERENCES DIM_Estrellas(st_sk),
    FOREIGN KEY (desc_sk) REFERENCES DIM_DescubrimientoPlanetas(desc_sk),
    FOREIGN KEY (clasif_sk) REFERENCES DIM_ClasificacionPlanetas(clasif_sk),
    FOREIGN KEY (tiempo_sk) REFERENCES DIM_Tiempo(tiempo_sk)
);

SELECT * FROM DIM_SistemasPlanetarios;
SELECT * FROM DIM_Estrellas;
SELECT * FROM DIM_ClasificacionPlanetas;
SELECT * FROM DIM_DescubrimientoPlanetas;
SELECT * FROM DIM_Tiempo;
SELECT * FROM FACT_Exoplanetas;

/* =======================================
   CARGA DE DIMENSIONES A TRAVÉS DE CONSULTAS SELECT
   ======================================= */

-- DIM_SistemasPlanetarios
INSERT INTO DIM_SistemasPlanetarios
(sy_id, sy_nombre, sy_constelacion, sy_estrellamasbrillante, sy_numero_estrellas, sy_numero_planetas, sy_distancia)
SELECT 
    S.sy_id,
    S.sy_name,
    C.sy_constellation,
    C.Brighteststar,
    S.sy_stars_num,
    S.sy_planets_num,
    S.sy_distance
FROM SistemasPlanetarios.dbo.SistemasPlanetarios S
INNER JOIN SistemasPlanetarios.dbo.Constelaciones C 
    ON S.sy_constellation_id = C.sy_constellation_id;

-- DIM_Estrellas
INSERT INTO DIM_Estrellas
(st_id, st_nombre, st_temperatura_K, st_radio_sol, st_masa_sol, st_luminosidad, st_edad, st_densidad)
SELECT 
    st_id,
    st_hostname,
    st_temperature,
    st_radius,
    st_mass,
    st_luminosity,
    st_age,
    st_density
FROM SistemasPlanetarios.dbo.Estrellas;

-- DIM_DescubrimientoPlanetas
INSERT INTO DIM_DescubrimientoPlanetas
(descubrimiento_id, disc_centro_instalacion, disc_telescopio, disc_metodo, disc_locacion)
SELECT 
    E.pl_id,
    F.disc_facility,
    T.disc_telescope,
    M.discoverymethod,
    L.disc_locale
FROM SistemasPlanetarios.dbo.Exoplanetas E
INNER JOIN SistemasPlanetarios.dbo.FacilidadDescubrimiento F ON E.facility_id = F.facility_id
INNER JOIN SistemasPlanetarios.dbo.LocacionesDescubrimiento L ON E.locale_id = L.locale_id
INNER JOIN SistemasPlanetarios.dbo.MetodosDescubrimiento M ON E.method_id = M.method_id
INNER JOIN SistemasPlanetarios.dbo.Telescopios T ON E.telescope_id = T.telescope_id;

-- DIM_ClasificacionPlanetas
INSERT INTO DIM_ClasificacionPlanetas
(pl_clasificacion_id, pl_tipo, pl_categoria, pl_clasificacion_temperatura, pl_status)
SELECT 
    E.pl_id,
    TP.pl_type,
    C.pl_category,
    CT.pl_classification_temp,
    EP.pl_list
FROM SistemasPlanetarios.dbo.Exoplanetas E
INNER JOIN SistemasPlanetarios.dbo.TipoPlanetas TP ON E.pl_type_id = TP.pl_type_id
INNER JOIN SistemasPlanetarios.dbo.CategoriaPlanetas C ON E.pl_category_id = C.pl_category_id
INNER JOIN SistemasPlanetarios.dbo.ClasificacionTemperatura CT ON E.pl_classification_temp_id = CT.pl_classification_temp_id
INNER JOIN SistemasPlanetarios.dbo.EstatusPlanetas EP ON E.pl_list_id = EP.pl_list_id;

-- DIM_Tiempo
INSERT INTO DIM_Tiempo (fecha, mes, año, trimestre)
SELECT 
    TRY_CONVERT(DATE, E.discovery_pubdate) AS fecha,
    MONTH(TRY_CONVERT(DATE, E.discovery_pubdate)) AS mes,
    YEAR(TRY_CONVERT(DATE, E.discovery_pubdate)) AS año,
    DATEPART(QUARTER, TRY_CONVERT(DATE, E.discovery_pubdate)) AS trimestre
FROM SistemasPlanetarios.dbo.Exoplanetas E
WHERE TRY_CONVERT(DATE, E.discovery_pubdate) IS NOT NULL;

/* =======================================
   CARGA DE LA TABLA DE HECHOS
   ======================================= */

INSERT INTO FACT_Exoplanetas
(sy_sk, st_sk, desc_sk, clasif_sk, tiempo_sk,
 pl_nombre, pl_periodo_orbital_dias, pl_radio_tierra, pl_mass_tierra, 
 pl_densidad, pl_temperatura, pl_esi, pl_años_luz_tierra)
SELECT
    -- Mapear surrogate keys
    dsp.sy_sk,
    de.st_sk,
    dd.desc_sk,
    dc.clasif_sk,
    dt.tiempo_sk,

    -- Medidas
    Ex.pl_name,
    Ex.pl_orbital_period,
    Ex.pl_radius_earth,
    Ex.pl_mass_earth,
    Ex.pl_density,
    Ex.pl_temperature,
    Ex.pl_esi,
    Ex.pl_light_years_from_earth

FROM SistemasPlanetarios.dbo.Exoplanetas Ex
-- Join con DIM_SistemasPlanetarios (por sy_id)
INNER JOIN SistemasPlanetarios.dbo.Estrellas E ON Ex.st_id = E.st_id
INNER JOIN SistemasPlanetarios.dbo.SistemasPlanetarios SP ON E.sy_id = SP.sy_id
INNER JOIN DIM_SistemasPlanetarios dsp ON SP.sy_id = dsp.sy_id
-- Join con DIM_Estrellas (por st_id)
INNER JOIN DIM_Estrellas de ON E.st_id = de.st_id
-- Join con DIM_DescubrimientoPlanetas (por pl_id)
LEFT JOIN DIM_DescubrimientoPlanetas dd ON Ex.pl_id = dd.descubrimiento_id
-- Join con DIM_ClasificacionPlanetas (por pl_id)
LEFT JOIN DIM_ClasificacionPlanetas dc ON Ex.pl_id = dc.pl_clasificacion_id
-- Join con DIM_Tiempo (por fecha = discovery_pubdate)
LEFT JOIN DIM_Tiempo dt ON dt.fecha = TRY_CONVERT(DATE, Ex.discovery_pubdate);