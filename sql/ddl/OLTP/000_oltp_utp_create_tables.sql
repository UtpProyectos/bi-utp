/* =========================================================
   SISTEMA UTP - OLTP SIMPLE (SQL Server)
   ========================================================= */
CREATE DATABASE DB_UTP;
GO
USE DB_UTP;
GO

/* =======================
   Esquema
   ======================= */
CREATE SCHEMA sis;
GO

/* =======================
   Institucional
   ======================= */
-- Universidades (UTP, etc.)
CREATE TABLE sis.universidad (
  universidad_id  INT IDENTITY(1,1) PRIMARY KEY,
  nombre          VARCHAR(200) NOT NULL,
  sigla           VARCHAR(20)  NULL,
  CONSTRAINT UQ_universidad UNIQUE (nombre)
);

-- Campus por universidad
CREATE TABLE sis.campus (
  campus_id       INT IDENTITY(1,1) PRIMARY KEY,
  universidad_id  INT NOT NULL REFERENCES sis.universidad(universidad_id),
  nombre_campus   VARCHAR(120) NOT NULL,
  CONSTRAINT UQ_campus UNIQUE (universidad_id, nombre_campus)
);

-- Facultades por universidad
CREATE TABLE sis.facultad (
  facultad_id     INT IDENTITY(1,1) PRIMARY KEY,
  universidad_id  INT NOT NULL REFERENCES sis.universidad(universidad_id),
  nombre_facultad VARCHAR(150) NOT NULL,
  CONSTRAINT UQ_facultad UNIQUE (universidad_id, nombre_facultad)
);

-- Carreras por facultad
CREATE TABLE sis.carrera (
  carrera_id      INT IDENTITY(1,1) PRIMARY KEY,
  facultad_id     INT NOT NULL REFERENCES sis.facultad(facultad_id),
  nombre_carrera  VARCHAR(150) NOT NULL,
  CONSTRAINT UQ_carrera UNIQUE (facultad_id, nombre_carrera)
);

/* =======================
   Periodos académicos
   ======================= */
CREATE TABLE sis.periodo (
  periodo_id      INT IDENTITY(1,1) PRIMARY KEY,
  anio            INT NOT NULL,
  termino         VARCHAR(20) NOT NULL,   -- 'I','II','Marzo I', etc.
  fecha_inicio    DATE NOT NULL,
  fecha_fin       DATE NOT NULL,
  CONSTRAINT UQ_periodo UNIQUE (anio, termino)
);

/* =======================
   Cursos y Plan de estudios
   ======================= */
-- Catálogo de cursos
CREATE TABLE sis.curso (
  curso_id        INT IDENTITY(1,1) PRIMARY KEY,
  codigo_curso    VARCHAR(20)  NOT NULL,--ESTE DEBE SER SU PRIMARY KEY , 
  nombre_curso    VARCHAR(200) NOT NULL,
  descripcion     VARCHAR(400) NULL,
  creditos        TINYINT      NOT NULL,
  carrera_id      INT          NULL REFERENCES sis.carrera(carrera_id), -- opcional
  CONSTRAINT UQ_curso_codigo UNIQUE (codigo_curso)
);

-- Planes por carrera (la "versión" del plan)
CREATE TABLE sis.plan_estudios (
  plan_id         INT IDENTITY(1,1) PRIMARY KEY,
  carrera_id      INT NOT NULL REFERENCES sis.carrera(carrera_id),
  version         VARCHAR(20) NOT NULL,     -- ej. '2023'
  vigente_desde   DATE NOT NULL,
  vigente_hasta   DATE NULL,
  CONSTRAINT UQ_plan_estudios UNIQUE (carrera_id, version)
);

-- Ubicación del curso dentro del plan (aquí está el CICLO)
CREATE TABLE sis.plan_curso (
  plan_curso_id   INT IDENTITY(1,1) PRIMARY KEY,
  plan_id         INT NOT NULL REFERENCES sis.plan_estudios(plan_id),
  curso_id        INT NOT NULL REFERENCES sis.curso(curso_id),
  ciclo           TINYINT NOT NULL CHECK (ciclo BETWEEN 1 AND 10),  -- ← ciclo del curso
  tipo            VARCHAR(20) NULL,  -- OBLIGATORIO/ELECTIVO
  CONSTRAINT UQ_plan_curso UNIQUE (plan_id, curso_id)
);
CREATE INDEX IX_plan_curso_curso ON sis.plan_curso(curso_id);

/* =======================
   Personas (simplificadas)
   ======================= */
-- Estudiantes
CREATE TABLE sis.estudiante (
  estudiante_id      BIGINT IDENTITY(1,1) PRIMARY KEY,
  codigo_estudiante  VARCHAR(20)  NOT NULL UNIQUE, --ESTE ES SU ID
  nombres            VARCHAR(120) NOT NULL,
  apellidos          VARCHAR(150) NOT NULL,
  email              VARCHAR(150) NULL,
  telefono           VARCHAR(30)  NULL,
  carrera_id         INT          NULL REFERENCES sis.carrera(carrera_id),
  plan_id            INT          NULL REFERENCES sis.plan_estudios(plan_id), -- plan que sigue
  ciclo_actual       TINYINT      NULL,
  fecha_ingreso      DATE         NULL,
  estado             VARCHAR(20)  NOT NULL DEFAULT 'ACTIVO'  -- ACTIVO/INACTIVO/EGRESADO
);

-- Datos opcionales del estudiante
CREATE TABLE sis.estudiante_detalle (
  estudiante_id     BIGINT PRIMARY KEY REFERENCES sis.estudiante(estudiante_id),
  direccion         VARCHAR(250) NULL,
  distrito          VARCHAR(120) NULL,
  ciudad            VARCHAR(120) NULL,
  fecha_nacimiento  DATE         NULL,
  observaciones     VARCHAR(300) NULL
);

-- Profesores
CREATE TABLE sis.profesor (
  profesor_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
  codigo_profesor   VARCHAR(20)  NOT NULL UNIQUE,--ESTE ES SU ID
  nombres           VARCHAR(120) NOT NULL,
  apellidos         VARCHAR(150) NOT NULL,
  email             VARCHAR(150) NULL,
  telefono          VARCHAR(30)  NULL,
  categoria         VARCHAR(40)  NULL,   -- Asistente/Asociado/Principal
  estado            VARCHAR(20)  NOT NULL DEFAULT 'ACTIVO'
);

-- Datos opcionales del profesor
CREATE TABLE sis.profesor_detalle (
  profesor_id        BIGINT PRIMARY KEY REFERENCES sis.profesor(profesor_id),
  especialidad       VARCHAR(120) NULL,
  grados_academicos  VARCHAR(200) NULL,
  experiencia_anios  TINYINT      NULL,
  observaciones      VARCHAR(300) NULL
);

/* =======================
   Oferta académica (secciones)
   ======================= */
-- Sección única por (curso, periodo, código)
CREATE TABLE sis.seccion (
  seccion_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
  curso_id         INT NOT NULL REFERENCES sis.curso(curso_id),
  periodo_id       INT NOT NULL REFERENCES sis.periodo(periodo_id),
  codigo_seccion   VARCHAR(10) NOT NULL,    -- p.ej. A, B1 --ESTE ES SU ID EJEMPLO 42460 
  campus_id        INT NULL REFERENCES sis.campus(campus_id),
  modalidad        VARCHAR(20)  NULL,       -- Presencial/Virtual/Mixta
  capacidad        INT          NULL,
  CONSTRAINT UQ_seccion UNIQUE (curso_id, periodo_id, codigo_seccion)
);

-- Historial de profesor por sección (por si cambia el docente)
CREATE TABLE sis.seccion_profesor_hist (
  seccion_prof_id  BIGINT IDENTITY(1,1) PRIMARY KEY,
  seccion_id       BIGINT NOT NULL REFERENCES sis.seccion(seccion_id),
  profesor_id      BIGINT NOT NULL REFERENCES sis.profesor(profesor_id),
  rol              VARCHAR(20) NOT NULL DEFAULT 'TITULAR', -- TITULAR/AUXILIAR
  vigente_desde    DATETIME2 NOT NULL,
  vigente_hasta    DATETIME2 NULL
);
CREATE INDEX IX_secc_prof_activo ON sis.seccion_profesor_hist(seccion_id, vigente_hasta) INCLUDE (profesor_id);

/* =======================
   Matrícula
   ======================= */
-- Cabecera de matrícula por alumno y periodo
CREATE TABLE sis.matricula (
  matricula_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  estudiante_id    BIGINT NOT NULL REFERENCES sis.estudiante(estudiante_id),
  periodo_id       INT    NOT NULL REFERENCES sis.periodo(periodo_id),
  fecha_matricula  DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  estado           VARCHAR(20) NOT NULL DEFAULT 'VIGENTE', -- VIGENTE/ANULADA
  CONSTRAINT UQ_matricula UNIQUE (estudiante_id, periodo_id)
);

-- Detalle de cursos inscritos (vínculo a sección)
CREATE TABLE sis.matricula_seccion (
  mat_seccion_id    BIGINT IDENTITY(1,1) PRIMARY KEY,
  matricula_id      BIGINT NOT NULL REFERENCES sis.matricula(matricula_id),
  seccion_id        BIGINT NOT NULL REFERENCES sis.seccion(seccion_id),
  estado            VARCHAR(20) NOT NULL DEFAULT 'INSCRITO', -- INSCRITO/RETIRADO
  fecha_inscripcion DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  fecha_baja        DATETIME2 NULL,
  intento_nro       TINYINT NULL,  -- 1er/2do/3er intento del curso
  CONSTRAINT UQ_mat_seccion UNIQUE (matricula_id, seccion_id)
);
CREATE INDEX IX_matsec_seccion ON sis.matricula_seccion(seccion_id);

-- Notas por alumno-sección (simple)
CREATE TABLE sis.nota_alumno_seccion (
  nota_id          BIGINT IDENTITY(1,1) PRIMARY KEY,
  mat_seccion_id   BIGINT NOT NULL REFERENCES sis.matricula_seccion(mat_seccion_id),
  nota_parcial     DECIMAL(5,2) NULL CHECK (nota_parcial BETWEEN 0 AND 20),
  nota_practicas   DECIMAL(5,2) NULL CHECK (nota_practicas BETWEEN 0 AND 20),
  nota_final       DECIMAL(5,2) NULL CHECK (nota_final BETWEEN 0 AND 20),
  nota_promedio    DECIMAL(5,2) NULL CHECK (nota_promedio BETWEEN 0 AND 20),
  aprobado_flag    AS (CASE WHEN nota_promedio >= 11 THEN 1 ELSE 0 END) PERSISTED,
  fecha_registro   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  origen_fuente    VARCHAR(30) NULL
);
CREATE UNIQUE INDEX UQ_nota_por_inscripcion ON sis.nota_alumno_seccion(mat_seccion_id);
GO
