CREATE DATABASE [SistemasPlanetarios];
GO

USE [SistemasPlanetarios];
GO

-- =====================
-- Tablas base
-- =====================

CREATE TABLE [dbo].[Constelaciones](
	[sy_constellation_id] INT PRIMARY KEY NOT NULL,
	[sy_constellation] NVARCHAR(255) NOT NULL,
	[meaning] NVARCHAR(255) NOT NULL,
	[Origin] NVARCHAR(255) NOT NULL,
	[Brighteststar] NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE [dbo].[ClasificacionTemperatura](
	[pl_classification_temp_id] INT PRIMARY KEY NOT NULL,
	[pl_classification_temp] NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE [dbo].[TipoPlanetas](
	[pl_type_id] INT PRIMARY KEY NOT NULL,
	[pl_type] NVARCHAR(255) NOT NULL,
	[pl_type_description] NVARCHAR(MAX) NOT NULL
);
GO

CREATE TABLE [dbo].[CategoriaPlanetas](
	[pl_category_id] INT PRIMARY KEY NOT NULL,
	[pl_category] NVARCHAR(255) NOT NULL,
	[pl_category_description] NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE [dbo].[EstatusPlanetas](
	[pl_list_id] INT PRIMARY KEY NOT NULL,
	[pl_list] NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE [dbo].[LocacionesDescubrimiento](
	[locale_id] INT PRIMARY KEY NOT NULL,
	[disc_locale] NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE [dbo].[FacilidadDescubrimiento](
	[facility_id] INT PRIMARY KEY NOT NULL,
	[disc_facility] NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE [dbo].[Telescopios](
	[telescope_id] INT PRIMARY KEY NOT NULL,
	[disc_telescope] NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE [dbo].[MetodosDescubrimiento](
	[method_id] INT PRIMARY KEY NOT NULL,
	[discoverymethod] NVARCHAR(255) NULL,
	[discoverydescription] NVARCHAR(255) NULL
);
GO

-- =====================
-- Tablas dependientes
-- =====================

CREATE TABLE [dbo].[SistemasPlanetarios](
	[sy_id] INT PRIMARY KEY NOT NULL,
	[sy_name] NVARCHAR(255) NOT NULL,
	[sy_stars_num] INT NOT NULL,
	[sy_planets_num] INT NOT NULL,
	[sy_galatic_latitude] FLOAT NOT NULL,
	[sy_galatic_longitude] FLOAT NOT NULL,
	[sy_distance] FLOAT NOT NULL,
	[sy_constellation_id] INT NOT NULL,
	FOREIGN KEY (sy_constellation_id) REFERENCES Constelaciones (sy_constellation_id)
);
GO

CREATE TABLE [dbo].[Estrellas](
	[st_id] INT PRIMARY KEY NOT NULL,
	[st_hostname] NVARCHAR(255) NOT NULL,
	[st_temperature] INT NOT NULL,
	[st_radius] FLOAT NOT NULL,
	[st_mass] FLOAT NOT NULL,
	[st_luminosity] FLOAT NOT NULL,
	[st_gravity] FLOAT NOT NULL,
	[st_age] FLOAT NOT NULL,
	[st_density] FLOAT NOT NULL,
	[sy_id] INT NOT NULL,
	FOREIGN KEY (sy_id) REFERENCES SistemasPlanetarios (sy_id)
);
GO

CREATE TABLE [dbo].[Exoplanetas](
	[pl_id] INT PRIMARY KEY NOT NULL,
	[pl_name] NVARCHAR(255) NOT NULL,
	[pl_letter] CHAR(1) NOT NULL,
	[pl_orbital_period] FLOAT NOT NULL,
	[pl_radius_earth] FLOAT NOT NULL,
	[pl_radius_jupiter] FLOAT NOT NULL,
	[pl_mass_earth] FLOAT NOT NULL,
	[pl_mass_jupiter] FLOAT NOT NULL,
	[pl_density] FLOAT NOT NULL,
	[pl_eccentricity] FLOAT NOT NULL,
	[pl_insolation_flux] FLOAT NOT NULL,
	[pl_temperature] INT NOT NULL,
	[pl_impact_parameter] FLOAT NOT NULL,
	[pl_esi] FLOAT NOT NULL,
	[pl_light_years_from_earth] INT NOT NULL,
	[discovery_year] INT NOT NULL,
	[discovery_pubdate] NVARCHAR(255) NOT NULL,
	[pl_classification_temp_id] INT NOT NULL,
	[pl_type_id] INT NOT NULL,
	[pl_category_id] INT NOT NULL,
	[pl_list_id] INT NOT NULL,
	[locale_id] INT NOT NULL,
	[facility_id] INT NOT NULL,
	[telescope_id] INT NOT NULL,
	[method_id] INT NOT NULL,
	[st_id] INT NOT NULL,
	FOREIGN KEY (pl_classification_temp_id) REFERENCES ClasificacionTemperatura (pl_classification_temp_id),
	FOREIGN KEY (pl_type_id) REFERENCES TipoPlanetas (pl_type_id),
	FOREIGN KEY (pl_category_id) REFERENCES CategoriaPlanetas (pl_category_id),
	FOREIGN KEY (pl_list_id) REFERENCES EstatusPlanetas (pl_list_id),
	FOREIGN KEY (locale_id) REFERENCES LocacionesDescubrimiento (locale_id),
	FOREIGN KEY (facility_id) REFERENCES FacilidadDescubrimiento (facility_id),
	FOREIGN KEY (telescope_id) REFERENCES Telescopios (telescope_id),
	FOREIGN KEY (method_id) REFERENCES MetodosDescubrimiento (method_id),
	FOREIGN KEY (st_id) REFERENCES Estrellas (st_id)
);
GO

-- =====================
-- Consultas de verificación
-- =====================
SELECT * FROM Constelaciones;
SELECT * FROM ClasificacionTemperatura;
SELECT * FROM TipoPlanetas;
SELECT * FROM CategoriaPlanetas;
SELECT * FROM EstatusPlanetas;
SELECT * FROM LocacionesDescubrimiento;
SELECT * FROM FacilidadDescubrimiento;
SELECT * FROM Telescopios;
SELECT * FROM MetodosDescubrimiento;
SELECT * FROM SistemasPlanetarios;
SELECT * FROM Estrellas;
SELECT * FROM Exoplanetas;
GO

-- =====================
-- Borrado de Datos
-- =====================
DELETE FROM Constelaciones;
DELETE FROM ClasificacionTemperatura;
DELETE FROM TipoPlanetas;
DELETE FROM CategoriaPlanetas;
DELETE FROM EstatusPlanetas;
DELETE FROM LocacionesDescubrimiento;
DELETE FROM FacilidadDescubrimiento;
DELETE FROM Telescopios;
DELETE FROM MetodosDescubrimiento;