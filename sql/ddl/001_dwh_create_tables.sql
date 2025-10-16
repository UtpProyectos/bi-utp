/* ===========================================================
   CREACIÓN COMPLETA DE BASE DE DATOS ODS (versión modificada)
   Autor: Pollito Crack 🐣
   Fecha: 2025-10-13
   =========================================================== */
USE STAGING
DROP DATABASE ODS
-- 1️⃣ CREAR BASE DE DATOS
IF DB_ID('ODS') IS NOT NULL
BEGIN
    ALTER DATABASE ODS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ODS;
END
GO

CREATE DATABASE ODS;
GO

USE ODS;
GO


/* ===========================================================
   DIMENSIONES
   =========================================================== */

-- ======================================
-- DIM_ESTUDIANTES
-- ======================================
CREATE TABLE dbo.dim_estudiantes (
    estudiante_id      VARCHAR(20) PRIMARY KEY, 
    nombre             VARCHAR(100) NOT NULL,
    apellidos          VARCHAR(150) NOT NULL,
    carrera            VARCHAR(150) NULL,
    ciclo              INT NULL,
    periodo            VARCHAR(20) NULL,
    universidad        VARCHAR(200) NULL
);
GO

-- ======================================
-- DIM_CURSOS
-- ======================================
CREATE TABLE dbo.dim_cursos (
    curso_id        VARCHAR(20)  PRIMARY KEY, 
    nombre_curso    VARCHAR(200) NOT NULL,
    descripcion     VARCHAR(200) NULL,
    creditos        INT NOT NULL
);
GO

-- ======================================
-- DIM_PROFESORES
-- ======================================
CREATE TABLE dbo.dim_profesores (
    profesor_id       VARCHAR(20)  PRIMARY KEY,
    nombre_profesor   VARCHAR(100) NOT NULL,
    apellidos         VARCHAR(150) NOT NULL,
    especialidad      VARCHAR(150) NULL
);
GO

-- ======================================
-- DIM_SECCIONES
-- ======================================
CREATE TABLE dbo.dim_secciones (
  seccion_id   INT NOT NULL PRIMARY KEY,   -- sin IDENTITY
  curso_id     VARCHAR(20)  NOT NULL,
  periodo      VARCHAR(100) NOT NULL,
  universidad  VARCHAR(200) NOT NULL,
  profesor_id  VARCHAR(20)  NOT NULL,
  campus VARCHAR(20) NOT NULL,
  CONSTRAINT FK_dim_secciones_dim_cursos
    FOREIGN KEY (curso_id)    REFERENCES dbo.dim_cursos(curso_id),
  CONSTRAINT FK_dim_secciones_dim_profesores
    FOREIGN KEY (profesor_id) REFERENCES dbo.dim_profesores(profesor_id),
  CONSTRAINT UQ_dim_secciones UNIQUE (curso_id, periodo, universidad, profesor_id),
  CONSTRAINT CK_dim_secciones_id_pos CHECK (seccion_id > 0)
);


-- ======================================
-- DIM_PREGUNTA_ENCUESTA (modificada)
-- ======================================
CREATE TABLE dbo.dim_pregunta_encuesta (
    pregunta_id         VARCHAR(20) PRIMARY KEY,      -- cambiado de INT a VARCHAR
    pregunta_texto      VARCHAR(500) NOT NULL,
    dimension           VARCHAR(100) NULL,
    escala              VARCHAR(50) NULL,
    vigente_flag        BIT NOT NULL DEFAULT 1,
    fecha_creacion      DATETIME NULL,
    fecha_actualizacion DATETIME NULL
);
GO


-- ======================================
-- DIM_DATE (versión YYYYMMDD)
-- ======================================
CREATE TABLE dbo.dim_date (
    date_id          INT NOT NULL PRIMARY KEY,  -- formato YYYYMMDD (ej: 20251013)
    fecha            DATE NOT NULL,
    año              INT NOT NULL,
    mes              INT NOT NULL,
    mes_nombre       VARCHAR(20) NOT NULL,
    trimestre        INT NOT NULL,
    semana_año       INT NOT NULL,
    dia_mes          INT NOT NULL,
    dia_semana       INT NOT NULL,
    nombre_dia       VARCHAR(20) NOT NULL,
    es_fin_semana    BIT NOT NULL,
    es_feriado       BIT NOT NULL DEFAULT 0,
    ciclo_academico  VARCHAR(20) NULL,
    año_academico    INT NULL
);
GO



/* ===========================================================
   TABLAS DE HECHOS
   =========================================================== */

-- ======================================
-- FACT_MATRICULAS
-- ======================================
CREATE TABLE dbo.fact_matriculas (
    matricula_id      INT IDENTITY(1,1) PRIMARY KEY,
    estudiante_id     VARCHAR(20) NOT NULL,
    seccion_id        INT NOT NULL,
    periodo           VARCHAR(100) NULL,
    estado_matricula  VARCHAR(50) NULL,
    fecha_matricula   DATE NULL,
    fecha_carga       DATETIME NOT NULL DEFAULT GETDATE(),
    origen_fuente     VARCHAR(255) NULL,
    FOREIGN KEY (estudiante_id) REFERENCES dbo.dim_estudiantes(estudiante_id),
    FOREIGN KEY (seccion_id) REFERENCES dbo.dim_secciones(seccion_id)
);
GO


-- ======================================
-- FACT_NOTAS
-- ======================================
CREATE TABLE dbo.fact_notas (
    nota_id           INT IDENTITY(1,1) PRIMARY KEY,
    estudiante_id     VARCHAR(20) NOT NULL,
    seccion_id        INT NOT NULL,
    date_id           INT NOT NULL,
    evaluacion_codigo VARCHAR(50) NULL,
    nota_obtenida     DECIMAL(5,2) NULL,
    nota_ponderada    DECIMAL(5,2) NULL,
    aprobado_flag     BIT NOT NULL DEFAULT 0,
    fecha_carga       DATETIME NOT NULL DEFAULT GETDATE(),
    origen_fuente     VARCHAR(255) NULL, 
    FOREIGN KEY (estudiante_id) REFERENCES dbo.dim_estudiantes(estudiante_id),
    FOREIGN KEY (seccion_id) REFERENCES dbo.dim_secciones(seccion_id),
    FOREIGN KEY (date_id) REFERENCES dbo.dim_date(date_id)
);
GO


-- ======================================
-- FACT_ENCUESTAS (modificada y unificada con tipo_encuesta)
-- ======================================
CREATE TABLE dbo.fact_encuestas (
    encuesta_id        INT IDENTITY(1,1) PRIMARY KEY,

    -- Relaciones
    seccion_id         INT NOT NULL,
    pregunta_id        VARCHAR(20) NOT NULL,     -- ahora VARCHAR (FK a dim_pregunta_encuesta)
    date_id            INT NOT NULL,             -- FK a dim_date

    -- Campos unificados desde dim_tipo_encuesta
    codigo_tipo        VARCHAR(20) NULL,
    nombre_tipo        VARCHAR(200) NULL,
    descripcion_tipo   VARCHAR(200) NULL,

    -- Métricas de resultados
    score_avg          DECIMAL(5,2) NULL,
    n_respuestas       INT NULL,
    score_min          DECIMAL(5,2) NULL,
    score_max          DECIMAL(5,2) NULL,
    std_dev            DECIMAL(6,3) NULL,

    -- Metadata
    fecha_carga        DATETIME NOT NULL DEFAULT GETDATE(),
    origen_fuente      VARCHAR(50) NULL,

    -- Claves externas
    CONSTRAINT FK_fact_encuestas_dim_secciones
        FOREIGN KEY (seccion_id) REFERENCES dbo.dim_secciones(seccion_id),

    CONSTRAINT FK_fact_encuestas_dim_pregunta_encuesta
        FOREIGN KEY (pregunta_id) REFERENCES dbo.dim_pregunta_encuesta(pregunta_id),

    CONSTRAINT FK_fact_encuestas_dim_date
        FOREIGN KEY (date_id) REFERENCES dbo.dim_date(date_id)
);
GO
