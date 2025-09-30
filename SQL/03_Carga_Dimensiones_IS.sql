
/* ========================================================
   CONSULTAS PARA INTEGRATION SERVICES (SSIS)
   Modelo: DW con FACT_Exoplanetas
   ======================================================== */

/* ======================
   DIMENSIONES
   ====================== */

/* DIM_SistemasPlanetarios */
SELECT 
    S.sy_id,
    S.sy_name AS sy_nombre,
    C.sy_constellation,
    C.Brighteststar AS sy_estrellamasbrillante,
    S.sy_stars_num AS sy_numero_estrellas,
    S.sy_planets_num AS sy_numero_planetas,
    S.sy_distance AS sy_distancia
FROM SistemasPlanetarios.dbo.SistemasPlanetarios S
INNER JOIN SistemasPlanetarios.dbo.Constelaciones C 
    ON S.sy_constellation_id = C.sy_constellation_id;

/* DIM_Estrellas */
SELECT 
    st_id,
    st_hostname AS st_nombre,
    st_temperature AS st_temperatura_K,
    st_radius AS st_radio_sol,
    st_mass AS st_masa_sol,
    st_luminosity AS st_luminosidad,
    st_age AS st_edad,
    st_density AS st_densidad
FROM SistemasPlanetarios.dbo.Estrellas;

/* DIM_DescubrimientoPlanetas */
SELECT 
    E.pl_id AS descubrimiento_id,
    F.disc_facility AS disc_centro_instalacion,
    T.disc_telescope AS disc_telescopio,
    M.discoverymethod AS disc_metodo,
    L.disc_locale AS disc_locacion
FROM SistemasPlanetarios.dbo.Exoplanetas E
INNER JOIN SistemasPlanetarios.dbo.FacilidadDescubrimiento F ON E.facility_id = F.facility_id
INNER JOIN SistemasPlanetarios.dbo.LocacionesDescubrimiento L ON E.locale_id = L.locale_id
INNER JOIN SistemasPlanetarios.dbo.MetodosDescubrimiento M ON E.method_id = M.method_id
INNER JOIN SistemasPlanetarios.dbo.Telescopios T ON E.telescope_id = T.telescope_id;

/* DIM_ClasificacionPlanetas */
SELECT 
    E.pl_id AS pl_clasificacion_id,
    TP.pl_type AS pl_tipo,
    C.pl_category AS pl_categoria,
    CT.pl_classification_temp AS pl_clasificacion_temperatura,
    EP.pl_list AS pl_status
FROM SistemasPlanetarios.dbo.Exoplanetas E
INNER JOIN SistemasPlanetarios.dbo.TipoPlanetas TP ON E.pl_type_id = TP.pl_type_id
INNER JOIN SistemasPlanetarios.dbo.CategoriaPlanetas C ON E.pl_category_id = C.pl_category_id
INNER JOIN SistemasPlanetarios.dbo.ClasificacionTemperatura CT ON E.pl_classification_temp_id = CT.pl_classification_temp_id
INNER JOIN SistemasPlanetarios.dbo.EstatusPlanetas EP ON E.pl_list_id = EP.pl_list_id;

/* DIM_Tiempo */
SELECT 
    TRY_CONVERT(DATE, E.discovery_pubdate) AS fecha,
    MONTH(TRY_CONVERT(DATE, E.discovery_pubdate)) AS mes,
    YEAR(TRY_CONVERT(DATE, E.discovery_pubdate)) AS año,
    DATEPART(QUARTER, TRY_CONVERT(DATE, E.discovery_pubdate)) AS trimestre
FROM SistemasPlanetarios.dbo.Exoplanetas E
WHERE TRY_CONVERT(DATE, E.discovery_pubdate) IS NOT NULL;

/* ======================
   TABLA DE HECHOS
   ====================== */
SELECT
    dsp.sy_sk,
    de.st_sk,
    dd.desc_sk,
    dc.clasif_sk,
    dt.tiempo_sk,
    Ex.pl_name AS pl_nombre,
    Ex.pl_orbital_period AS pl_periodo_orbital_dias,
    Ex.pl_radius_earth AS pl_radio_tierra,
    Ex.pl_mass_earth AS pl_mass_tierra,
    Ex.pl_density AS pl_densidad,
    Ex.pl_temperature AS pl_temperatura,
    Ex.pl_esi,
    Ex.pl_light_years_from_earth AS pl_años_luz_tierra
FROM SistemasPlanetarios.dbo.Exoplanetas Ex
INNER JOIN SistemasPlanetarios.dbo.Estrellas E ON Ex.st_id = E.st_id
INNER JOIN SistemasPlanetarios.dbo.SistemasPlanetarios SP ON E.sy_id = SP.sy_id
INNER JOIN SistemasPlanetariosDW.dbo.DIM_SistemasPlanetarios dsp ON SP.sy_id = dsp.sy_id
INNER JOIN SistemasPlanetariosDW.dbo.DIM_Estrellas de ON E.st_id = de.st_id
LEFT JOIN SistemasPlanetariosDW.dbo.DIM_DescubrimientoPlanetas dd ON Ex.pl_id = dd.descubrimiento_id
LEFT JOIN SistemasPlanetariosDW.dbo.DIM_ClasificacionPlanetas dc ON Ex.pl_id = dc.pl_clasificacion_id
LEFT JOIN SistemasPlanetariosDW.dbo.DIM_Tiempo dt ON dt.fecha = TRY_CONVERT(DATE, Ex.discovery_pubdate);