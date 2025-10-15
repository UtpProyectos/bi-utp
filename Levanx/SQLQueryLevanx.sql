USE STAGING

-- Profesores
CREATE TABLE temp.profesor (
  profesor_id       BIGINT PRIMARY KEY,
  codigo_profesor   NVARCHAR(20)  NOT NULL UNIQUE,--ESTE ES SU ID
  nombres           NVARCHAR(120) NOT NULL,
  apellidos         NVARCHAR(150) NOT NULL,
  email             NVARCHAR(150) NULL,
  telefono          NVARCHAR(30)  NULL,
  categoria         NVARCHAR(40)  NULL,   -- Asistente/Asociado/Principal
  estado            NVARCHAR(20)  NOT NULL DEFAULT 'ACTIVO'
);

-- Datos opcionales del profesor
CREATE TABLE temp.profesor_detalle (
  profesor_id        BIGINT PRIMARY KEY REFERENCES temp.profesor(profesor_id),
  especialidad       NVARCHAR(120) NULL,
  grados_academicos  NVARCHAR(200) NULL,
  experiencia_anios  TINYINT      NULL,
  observaciones      NVARCHAR(300) NULL
);


/*-----------------------------------------------------------*/

-- Profesores
CREATE TABLE dbo.profesor (
  profesor_id       BIGINT PRIMARY KEY,
  codigo_profesor   NVARCHAR(20)  NOT NULL UNIQUE,--ESTE ES SU ID
  nombres           NVARCHAR(120) NOT NULL,
  apellidos         NVARCHAR(150) NOT NULL
);

-- Datos opcionales del profesor
CREATE TABLE dbo.profesor_detalle (
  profesor_id        BIGINT PRIMARY KEY REFERENCES dbo.profesor(profesor_id),
  especialidad       NVARCHAR(120) NULL
);