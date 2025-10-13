/* =========================================================
   SISTEMA UTP - OLTP SIMPLE (SQL Server) — versión con códigos como PK
   ========================================================= */
IF DB_ID('DB_SIS_UTP') IS NULL
  CREATE DATABASE DB_SIS_UTP;
GO
USE DB_SIS_UTP;
GO

/* =======================
   Esquema
   ======================= */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='sis')
  EXEC('CREATE SCHEMA sis');
GO

/* =======================
   Institucional
   ======================= */
-- Universidades (PK por código)
IF OBJECT_ID('sis.universidad','U') IS NOT NULL DROP TABLE sis.universidad;
GO
CREATE TABLE sis.universidad (
  codigo_universidad  VARCHAR(20)  NOT NULL PRIMARY KEY,  -- e.g. 'UTP'
  nombre              VARCHAR(200) NOT NULL,
  sigla               VARCHAR(20)  NULL,
  CONSTRAINT UQ_universidad_nombre UNIQUE (nombre)
);

-- Campus por universidad (FK por código_universidad)
IF OBJECT_ID('sis.campus','U') IS NOT NULL DROP TABLE sis.campus;
GO
CREATE TABLE sis.campus (
  campus_id           INT IDENTITY(1,1) PRIMARY KEY,
  codigo_universidad  VARCHAR(20) NOT NULL,
  nombre_campus       VARCHAR(120) NOT NULL,
  CONSTRAINT FK_campus_univ FOREIGN KEY (codigo_universidad)
    REFERENCES sis.universidad(codigo_universidad),
  CONSTRAINT UQ_campus UNIQUE (codigo_universidad, nombre_campus)
);

-- Facultades por universidad (mantiene ID numérico)
IF OBJECT_ID('sis.facultad','U') IS NOT NULL DROP TABLE sis.facultad;
GO
CREATE TABLE sis.facultad (
  facultad_id      INT IDENTITY(1,1) PRIMARY KEY,
  codigo_universidad VARCHAR(20) NOT NULL,
  nombre_facultad  VARCHAR(150) NOT NULL,
  CONSTRAINT FK_facultad_univ FOREIGN KEY (codigo_universidad)
    REFERENCES sis.universidad(codigo_universidad),
  CONSTRAINT UQ_facultad UNIQUE (codigo_universidad, nombre_facultad)
);

-- Carreras por facultad
IF OBJECT_ID('sis.carrera','U') IS NOT NULL DROP TABLE sis.carrera;
GO
CREATE TABLE sis.carrera (
  carrera_id      INT IDENTITY(1,1) PRIMARY KEY,
  facultad_id     INT NOT NULL,
  nombre_carrera  VARCHAR(150) NOT NULL,
  CONSTRAINT FK_carrera_facultad FOREIGN KEY (facultad_id)
    REFERENCES sis.facultad(facultad_id),
  CONSTRAINT UQ_carrera UNIQUE (facultad_id, nombre_carrera)
);

/* =======================
   Periodos académicos
   ======================= */
IF OBJECT_ID('sis.periodo','U') IS NOT NULL DROP TABLE sis.periodo;
GO
CREATE TABLE sis.periodo (
  periodo_id      INT IDENTITY(1,1) PRIMARY KEY,
  anio            INT NOT NULL,
  termino         VARCHAR(20) NOT NULL,   -- 'CICLO01','CICLO02', etc.
  fecha_inicio    DATE NOT NULL,
  fecha_fin       DATE NOT NULL,
  CONSTRAINT UQ_periodo UNIQUE (anio, termino)
);

/* =======================
   Cursos y Plan de estudios
   ======================= */
-- Catálogo de cursos (PK por código_curso)
IF OBJECT_ID('sis.curso','U') IS NOT NULL DROP TABLE sis.curso;
GO
CREATE TABLE sis.curso (
  codigo_curso    VARCHAR(20)  NOT NULL PRIMARY KEY, -- PK por código
  nombre_curso    VARCHAR(200) NOT NULL,
  descripcion     VARCHAR(400) NULL,
  creditos        DECIMAL(5,2) NOT NULL,             -- soporta 3.78 etc.
  carrera_id      INT          NULL,
  CONSTRAINT FK_curso_carrera FOREIGN KEY (carrera_id)
    REFERENCES sis.carrera(carrera_id),
  CONSTRAINT UQ_curso_nombre UNIQUE (nombre_curso)
);

-- Planes por carrera (ID numérico)
IF OBJECT_ID('sis.plan_estudios','U') IS NOT NULL DROP TABLE sis.plan_estudios;
GO
CREATE TABLE sis.plan_estudios (
  plan_id         INT IDENTITY(1,1) PRIMARY KEY,
  carrera_id      INT NOT NULL,
  version         VARCHAR(20) NOT NULL,     -- ej. '2025'
  vigente_desde   DATE NOT NULL,
  vigente_hasta   DATE NULL,
  CONSTRAINT FK_plan_carrera FOREIGN KEY (carrera_id)
    REFERENCES sis.carrera(carrera_id),
  CONSTRAINT UQ_plan_estudios UNIQUE (carrera_id, version)
);

-- Ubicación del curso dentro del plan (FK a codigo_curso)
IF OBJECT_ID('sis.plan_curso','U') IS NOT NULL DROP TABLE sis.plan_curso;
GO
CREATE TABLE sis.plan_curso (
  plan_curso_id   INT IDENTITY(1,1) PRIMARY KEY,
  plan_id         INT NOT NULL,
  codigo_curso    VARCHAR(20) NOT NULL,  -- FK a sis.curso(codigo_curso)
  ciclo           TINYINT NOT NULL CHECK (ciclo BETWEEN 1 AND 10),
  tipo            VARCHAR(20) NULL,      -- OBLIGATORIO/ELECTIVO
  CONSTRAINT FK_plan_curso_plan FOREIGN KEY (plan_id)
    REFERENCES sis.plan_estudios(plan_id),
  CONSTRAINT FK_plan_curso_curso FOREIGN KEY (codigo_curso)
    REFERENCES sis.curso(codigo_curso),
  CONSTRAINT UQ_plan_curso UNIQUE (plan_id, codigo_curso)
);
CREATE INDEX IX_plan_curso_curso ON sis.plan_curso(codigo_curso);

/* =======================
   Personas (simplificadas, PK por código)
   ======================= */
-- Estudiantes (PK por codigo_estudiante)
IF OBJECT_ID('sis.estudiante','U') IS NOT NULL DROP TABLE sis.estudiante;
GO
CREATE TABLE sis.estudiante (
  codigo_estudiante  VARCHAR(20)  NOT NULL PRIMARY KEY, -- PK por código
  nombres            VARCHAR(120) NOT NULL,
  apellidos          VARCHAR(150) NOT NULL,
  email              VARCHAR(150) NULL,
  telefono           VARCHAR(30)  NULL,
  carrera_id         INT          NULL,
  plan_id            INT          NULL, -- plan que sigue
  ciclo_actual       TINYINT      NULL,
  fecha_ingreso      DATE         NULL,
  estado             VARCHAR(20)  NOT NULL DEFAULT 'ACTIVO',  -- ACTIVO/INACTIVO/EGRESADO
  CONSTRAINT FK_est_carrera FOREIGN KEY (carrera_id)
    REFERENCES sis.carrera(carrera_id),
  CONSTRAINT FK_est_plan FOREIGN KEY (plan_id)
    REFERENCES sis.plan_estudios(plan_id)
);

-- Datos opcionales del estudiante
IF OBJECT_ID('sis.estudiante_detalle','U') IS NOT NULL DROP TABLE sis.estudiante_detalle;
GO
CREATE TABLE sis.estudiante_detalle (
  codigo_estudiante  VARCHAR(20)  NOT NULL PRIMARY KEY,
  direccion          VARCHAR(250) NULL,
  distrito           VARCHAR(120) NULL,
  ciudad             VARCHAR(120) NULL,
  fecha_nacimiento   DATE         NULL,
  observaciones      VARCHAR(300) NULL,
  CONSTRAINT FK_est_det FOREIGN KEY (codigo_estudiante)
    REFERENCES sis.estudiante(codigo_estudiante)
);

-- Profesores (PK por codigo_profesor)
IF OBJECT_ID('sis.profesor','U') IS NOT NULL DROP TABLE sis.profesor;
GO
CREATE TABLE sis.profesor (
  codigo_profesor   VARCHAR(20)  NOT NULL PRIMARY KEY, -- PK por código
  nombres           VARCHAR(120) NOT NULL,
  apellidos         VARCHAR(150) NOT NULL,
  email             VARCHAR(150) NULL,
  telefono          VARCHAR(30)  NULL,
  categoria         VARCHAR(40)  NULL,   -- Asistente/Asociado/Principal
  estado            VARCHAR(20)  NOT NULL DEFAULT 'ACTIVO'
);

-- Datos opcionales del profesor
IF OBJECT_ID('sis.profesor_detalle','U') IS NOT NULL DROP TABLE sis.profesor_detalle;
GO
CREATE TABLE sis.profesor_detalle (
  codigo_profesor     VARCHAR(20)  NOT NULL PRIMARY KEY,
  especialidad        VARCHAR(120) NULL,
  grados_academicos   VARCHAR(200) NULL,
  experiencia_anios   TINYINT      NULL,
  observaciones       VARCHAR(300) NULL,
  CONSTRAINT FK_prof_det FOREIGN KEY (codigo_profesor)
    REFERENCES sis.profesor(codigo_profesor)
);

/* =======================
   Oferta académica (secciones)
   ======================= */
-- Sección única por (codigo_curso, periodo, codigo_seccion)
IF OBJECT_ID('sis.seccion','U') IS NOT NULL DROP TABLE sis.seccion;
GO
CREATE TABLE sis.seccion (
  seccion_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
  codigo_curso     VARCHAR(20) NOT NULL,     -- FK a curso por código
  periodo_id       INT NOT NULL,
  codigo_seccion   VARCHAR(20) NOT NULL,     -- p.ej. 'A', 'B1' o '42460'
  campus_id        INT NULL,
  modalidad        VARCHAR(20)  NULL,        -- Presencial/Virtual/Mixta
  capacidad        INT          NULL,
  CONSTRAINT FK_seccion_curso FOREIGN KEY (codigo_curso)
    REFERENCES sis.curso(codigo_curso),
  CONSTRAINT FK_seccion_periodo FOREIGN KEY (periodo_id)
    REFERENCES sis.periodo(periodo_id),
  CONSTRAINT FK_seccion_campus FOREIGN KEY (campus_id)
    REFERENCES sis.campus(campus_id),
  CONSTRAINT UQ_seccion UNIQUE (codigo_curso, periodo_id, codigo_seccion)
);

-- Historial de profesor por sección (profesor por código)
IF OBJECT_ID('sis.seccion_profesor_hist','U') IS NOT NULL DROP TABLE sis.seccion_profesor_hist;
GO
CREATE TABLE sis.seccion_profesor_hist (
  seccion_prof_id  BIGINT IDENTITY(1,1) PRIMARY KEY,
  seccion_id       BIGINT NOT NULL,
  codigo_profesor  VARCHAR(20) NOT NULL,
  rol              VARCHAR(20) NOT NULL DEFAULT 'TITULAR', -- TITULAR/AUXILIAR
  vigente_desde    DATETIME2 NOT NULL,
  vigente_hasta    DATETIME2 NULL,
  CONSTRAINT FK_secc_prof_seccion FOREIGN KEY (seccion_id)
    REFERENCES sis.seccion(seccion_id),
  CONSTRAINT FK_secc_prof_profesor FOREIGN KEY (codigo_profesor)
    REFERENCES sis.profesor(codigo_profesor)
);
CREATE INDEX IX_secc_prof_activo ON sis.seccion_profesor_hist(seccion_id, vigente_hasta) INCLUDE (codigo_profesor);

/* =======================
   Matrícula
   ======================= */
-- Cabecera de matrícula por alumno (por código) y periodo
IF OBJECT_ID('sis.matricula','U') IS NOT NULL DROP TABLE sis.matricula;
GO
CREATE TABLE sis.matricula (
  matricula_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  codigo_estudiante VARCHAR(20) NOT NULL,  -- FK por código
  periodo_id       INT    NOT NULL,
  fecha_matricula  DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  estado           VARCHAR(20) NOT NULL DEFAULT 'VIGENTE', -- VIGENTE/ANULADA
  CONSTRAINT FK_matricula_est FOREIGN KEY (codigo_estudiante)
    REFERENCES sis.estudiante(codigo_estudiante),
  CONSTRAINT FK_matricula_periodo FOREIGN KEY (periodo_id)
    REFERENCES sis.periodo(periodo_id),
  CONSTRAINT UQ_matricula UNIQUE (codigo_estudiante, periodo_id)
);

-- Detalle de cursos inscritos (vínculo a sección)
IF OBJECT_ID('sis.matricula_seccion','U') IS NOT NULL DROP TABLE sis.matricula_seccion;
GO
CREATE TABLE sis.matricula_seccion (
  mat_seccion_id    BIGINT IDENTITY(1,1) PRIMARY KEY,
  matricula_id      BIGINT NOT NULL,
  seccion_id        BIGINT NOT NULL,
  estado            VARCHAR(20) NOT NULL DEFAULT 'INSCRITO', -- INSCRITO/RETIRADO
  fecha_inscripcion DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  fecha_baja        DATETIME2 NULL,
  intento_nro       TINYINT NULL,  -- 1er/2do/3er intento del curso
  CONSTRAINT FK_matsec_mat FOREIGN KEY (matricula_id)
    REFERENCES sis.matricula(matricula_id),
  CONSTRAINT FK_matsec_seccion FOREIGN KEY (seccion_id)
    REFERENCES sis.seccion(seccion_id),
  CONSTRAINT UQ_mat_seccion UNIQUE (matricula_id, seccion_id)
);
CREATE INDEX IX_matsec_seccion ON sis.matricula_seccion(seccion_id);

-- Notas por alumno-sección (simple)
IF OBJECT_ID('sis.nota_alumno_seccion','U') IS NOT NULL DROP TABLE sis.nota_alumno_seccion;
GO
CREATE TABLE sis.nota_alumno_seccion (
  nota_id          BIGINT IDENTITY(1,1) PRIMARY KEY,
  mat_seccion_id   BIGINT NOT NULL,
  nota_parcial     DECIMAL(5,2) NULL CHECK (nota_parcial BETWEEN 0 AND 20),
  nota_practicas   DECIMAL(5,2) NULL CHECK (nota_practicas BETWEEN 0 AND 20),
  nota_final       DECIMAL(5,2) NULL CHECK (nota_final BETWEEN 0 AND 20),
  nota_promedio    DECIMAL(5,2) NULL CHECK (nota_promedio BETWEEN 0 AND 20),
  aprobado_flag    AS (CASE WHEN nota_promedio >= 11 THEN 1 ELSE 0 END) PERSISTED,
  fecha_registro   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  origen_fuente    VARCHAR(30) NULL,
  CONSTRAINT FK_nota_matsec FOREIGN KEY (mat_seccion_id)
    REFERENCES sis.matricula_seccion(mat_seccion_id)
);
CREATE UNIQUE INDEX UQ_nota_por_inscripcion ON sis.nota_alumno_seccion(mat_seccion_id);
GO
