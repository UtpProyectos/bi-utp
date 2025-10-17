select * from [temp].[pregunta_encuesta]


-- 1. Tablas que dependen de otras (nivel más bajo)
DROP TABLE temp.nota_evaluacion;
DROP TABLE temp.seccion_evaluacion;
DROP TABLE temp.seccion_profesor_hist;
DROP TABLE temp.matricula_seccion;

-- 2. Tablas intermedias
DROP TABLE temp.matricula;
DROP TABLE temp.seccion;
DROP TABLE temp.estudiante;
DROP TABLE temp.curso;

-- 3. Tablas base con dependencias entre sí
DROP TABLE temp.plan_estudios;
DROP TABLE temp.carrera;
DROP TABLE temp.facultad;
DROP TABLE temp.campus;
DROP TABLE temp.periodo;

-- 4. Tablas raíz (sin dependencias)
DROP TABLE temp.universidad;
DROP TABLE temp.profesor;

use STAGING
/*se crearan las siguientes tablas nota_evaluacion, matricula_seccion, matricula, campus,
seccion_evaluacion, seccion_profesor_hist, seccion, universidad, periodo, curso, estudiante, carrera,
facultad, plan_estudios*/
USE STAGING;
GO

-- 1?? Tablas raíz (no dependen de otras)
CREATE TABLE temp.universidad (
  codigo_universidad  NVARCHAR(20) NOT NULL PRIMARY KEY,
  nombre              NVARCHAR(200) NOT NULL,
  sigla               NVARCHAR(20)  NULL,
  CONSTRAINT UQ_universidad_nombre UNIQUE (nombre)
);

CREATE TABLE temp.profesor (
  codigo_profesor NVARCHAR(20) PRIMARY KEY,
  nombres NVARCHAR(100),
  apellidos NVARCHAR(100),
  email NVARCHAR(100)
);

-- 2?? Tablas que dependen directamente de universidad
CREATE TABLE temp.facultad (
  facultad_id        NVARCHAR(20) PRIMARY KEY,
  codigo_universidad NVARCHAR(20) NOT NULL,
  nombre_facultad    NVARCHAR(150) NOT NULL,
  CONSTRAINT FK_facultad_univ FOREIGN KEY (codigo_universidad)
    REFERENCES temp.universidad(codigo_universidad),
  CONSTRAINT UQ_facultad UNIQUE (codigo_universidad, nombre_facultad)
);

CREATE TABLE temp.campus (
  campus_id           NVARCHAR(20) PRIMARY KEY,
  codigo_universidad  NVARCHAR(20) NOT NULL,
  nombre_campus       NVARCHAR(120) NOT NULL,
  CONSTRAINT FK_campus_univ FOREIGN KEY (codigo_universidad)
    REFERENCES temp.universidad(codigo_universidad),
  CONSTRAINT UQ_campus UNIQUE (codigo_universidad, nombre_campus)
);

-- 3?? Carrera y plan de estudios (dependen de facultad)
CREATE TABLE temp.carrera (
  carrera_id      NVARCHAR(20) PRIMARY KEY,
  facultad_id     NVARCHAR(20) NOT NULL,
  nombre_carrera  NVARCHAR(150) NOT NULL,
  CONSTRAINT FK_carrera_facultad FOREIGN KEY (facultad_id)
    REFERENCES temp.facultad(facultad_id),
  CONSTRAINT UQ_carrera UNIQUE (facultad_id, nombre_carrera)
);

CREATE TABLE temp.plan_estudios (
  plan_id         NVARCHAR(20) PRIMARY KEY,
  carrera_id      NVARCHAR(20) NOT NULL,
  version         NVARCHAR(20) NOT NULL,
  vigente_desde   NVARCHAR(20) NOT NULL,
  vigente_hasta   NVARCHAR(20) NULL,
  CONSTRAINT FK_plan_carrera FOREIGN KEY (carrera_id)
    REFERENCES temp.carrera(carrera_id),
  CONSTRAINT UQ_plan_estudios UNIQUE (carrera_id, version)
);

-- 4?? Estudiante (depende de carrera y plan_estudios)
CREATE TABLE temp.estudiante (
  codigo_estudiante  NVARCHAR(20) PRIMARY KEY,
  nombres            NVARCHAR(120) NOT NULL,
  apellidos          NVARCHAR(150) NOT NULL,
  email              NVARCHAR(150) NULL,
  telefono           NVARCHAR(30)  NULL,
  carrera_id         NVARCHAR(20) NULL,
  plan_id            NVARCHAR(20) NULL,
  ciclo_actual       TINYINT NULL,
  fecha_ingreso      NVARCHAR(20) NULL,
  estado             NVARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
  CONSTRAINT FK_est_carrera FOREIGN KEY (carrera_id)
    REFERENCES temp.carrera(carrera_id),
  CONSTRAINT FK_est_plan FOREIGN KEY (plan_id)
    REFERENCES temp.plan_estudios(plan_id)
);

-- 5?? Periodo
CREATE TABLE temp.periodo (
  periodo_id      NVARCHAR(20) PRIMARY KEY,
  anio            NVARCHAR(20) NOT NULL,
  termino         NVARCHAR(20) NOT NULL,
  fecha_inicio    NVARCHAR(20) NOT NULL,
  fecha_fin       NVARCHAR(20) NOT NULL,
  CONSTRAINT UQ_periodo UNIQUE (anio, termino)
);

-- 6?? Curso
CREATE TABLE temp.curso (
  codigo_curso    NVARCHAR(20) PRIMARY KEY,
  nombre_curso    NVARCHAR(200) NOT NULL,
  descripcion     NVARCHAR(400) NULL,
  creditos        NVARCHAR(120) NOT NULL,
  carrera_id      NVARCHAR(20) NULL,
  CONSTRAINT FK_curso_carrera FOREIGN KEY (carrera_id)
    REFERENCES temp.carrera(carrera_id),
  CONSTRAINT UQ_curso_nombre UNIQUE (nombre_curso)
);

-- 7?? Sección (depende de curso, periodo y campus)
CREATE TABLE temp.seccion (
  codigo_seccion   NVARCHAR(20) PRIMARY KEY,
  codigo_curso     NVARCHAR(20) NOT NULL,
  periodo_id       NVARCHAR(20) NOT NULL,
  campus_id        NVARCHAR(20) NULL,
  modalidad        NVARCHAR(20) NULL,
  capacidad        NVARCHAR(20) NULL,
  CONSTRAINT FK_seccion_curso   FOREIGN KEY (codigo_curso) REFERENCES temp.curso(codigo_curso),
  CONSTRAINT FK_seccion_periodo FOREIGN KEY (periodo_id)   REFERENCES temp.periodo(periodo_id),
  CONSTRAINT FK_seccion_campus  FOREIGN KEY (campus_id)    REFERENCES temp.campus(campus_id),
  CONSTRAINT UQ_seccion UNIQUE (codigo_curso, periodo_id, codigo_seccion)
);
CREATE INDEX IX_seccion_periodo_curso ON temp.seccion(periodo_id, codigo_curso);

-- 8?? Sección Evaluación
CREATE TABLE temp.seccion_evaluacion (
  evaluacion_id     BIGINT PRIMARY KEY,
  codigo_seccion    NVARCHAR(20) NOT NULL,
  evaluacion_code   NVARCHAR(30) NOT NULL,
  nombre            NVARCHAR(100) NULL,
  ponderacion_pct   NVARCHAR(20) NOT NULL CHECK (ponderacion_pct BETWEEN 0 AND 100),
  fecha_programada  NVARCHAR(20) NULL,
  CONSTRAINT FK_eval_seccion FOREIGN KEY (codigo_seccion)
    REFERENCES temp.seccion(codigo_seccion),
  CONSTRAINT UQ_eval_seccion UNIQUE (codigo_seccion, evaluacion_code)
);

-- 9?? Matrícula
CREATE TABLE temp.matricula (
  matricula_id       BIGINT PRIMARY KEY,
  codigo_estudiante  NVARCHAR(20) NOT NULL,
  periodo_id         NVARCHAR(20) NOT NULL,
  fecha_matricula    NVARCHAR(20) NOT NULL DEFAULT SYSUTCDATETIME(),
  estado             NVARCHAR(20) NOT NULL DEFAULT 'VIGENTE',
  CONSTRAINT FK_mat_est FOREIGN KEY (codigo_estudiante) REFERENCES temp.estudiante(codigo_estudiante),
  CONSTRAINT FK_mat_per FOREIGN KEY (periodo_id)        REFERENCES temp.periodo(periodo_id),
  CONSTRAINT UQ_matricula UNIQUE (codigo_estudiante, periodo_id)
);

-- ?? Matrícula Sección
CREATE TABLE temp.matricula_seccion (
  mat_seccion_id    BIGINT PRIMARY KEY,
  matricula_id      BIGINT NOT NULL,
  codigo_seccion    NVARCHAR(20) NOT NULL,
  estado            NVARCHAR(20) NOT NULL DEFAULT 'INSCRITO',
  fecha_inscripcion NVARCHAR(20) NOT NULL DEFAULT SYSUTCDATETIME(),
  fecha_baja        NVARCHAR(20) NULL,
  intento_nro       TINYINT NULL,
  CONSTRAINT FK_matsec_mat     FOREIGN KEY (matricula_id)   REFERENCES temp.matricula(matricula_id),
  CONSTRAINT FK_matsec_seccion FOREIGN KEY (codigo_seccion) REFERENCES temp.seccion(codigo_seccion),
  CONSTRAINT UQ_matsec UNIQUE (matricula_id, codigo_seccion)
);
CREATE INDEX IX_matsec_seccion ON temp.matricula_seccion(codigo_seccion);

-- 11?? Sección Profesor Historial
CREATE TABLE temp.seccion_profesor_hist (
  seccion_prof_id  BIGINT PRIMARY KEY,
  codigo_seccion   NVARCHAR(20) NOT NULL,
  codigo_profesor  NVARCHAR(20) NOT NULL,
  rol              NVARCHAR(20) NOT NULL DEFAULT 'TITULAR',
  vigente_desde    NVARCHAR(20) NOT NULL,
  vigente_hasta    NVARCHAR(20) NULL,
  CONSTRAINT FK_sph_seccion  FOREIGN KEY (codigo_seccion)  REFERENCES temp.seccion(codigo_seccion),
  CONSTRAINT FK_sph_profesor FOREIGN KEY (codigo_profesor) REFERENCES temp.profesor(codigo_profesor)
);
CREATE INDEX IX_sph_activo ON temp.seccion_profesor_hist(codigo_seccion, vigente_hasta) INCLUDE (codigo_profesor);

-- 12?? Nota Evaluación (última, depende de matrícula_seccion y seccion_evaluacion)
CREATE TABLE temp.nota_evaluacion (
  nota_eval_id      BIGINT PRIMARY KEY,
  mat_seccion_id    BIGINT NOT NULL,
  evaluacion_id     BIGINT NOT NULL,
  nota_obtenida     NVARCHAR(20) NULL CHECK (nota_obtenida BETWEEN 0 AND 20),
  fecha_registro    NVARCHAR(20) NOT NULL DEFAULT SYSUTCDATETIME(),
  origen_fuente     NVARCHAR(30) NULL,
  CONSTRAINT FK_ne_matsec FOREIGN KEY (mat_seccion_id)
    REFERENCES temp.matricula_seccion(mat_seccion_id),
  CONSTRAINT FK_ne_eval FOREIGN KEY (evaluacion_id)
    REFERENCES temp.seccion_evaluacion(evaluacion_id),
  CONSTRAINT UQ_ne UNIQUE (mat_seccion_id, evaluacion_id)
);
CREATE INDEX IX_ne_matsec ON temp.nota_evaluacion(mat_seccion_id);


-------------------------------------------------------
-- 1) UNIVERSIDAD (raíz)
-------------------------------------------------------
CREATE TABLE dbo.universidad (
    universidad_id      BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_universidad  NVARCHAR(20) NOT NULL UNIQUE,
    nombre              NVARCHAR(200) NOT NULL,
    sigla               NVARCHAR(20) NULL
);
CREATE UNIQUE INDEX UQ_universidad_nombre ON dbo.universidad(nombre);

-------------------------------------------------------
-- 2) PROFESOR (según tu ejemplo reducido)
-------------------------------------------------------
CREATE TABLE dbo.profesor (
    profesor_id      BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_profesor  NVARCHAR(20) NOT NULL UNIQUE,
    nombres          NVARCHAR(120) NOT NULL,
    apellidos        NVARCHAR(150) NOT NULL
);

-------------------------------------------------------
-- 3) FACULTAD (depende de universidad)
-------------------------------------------------------
CREATE TABLE dbo.facultad (
    facultad_id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    universidad_id      BIGINT NOT NULL,
    nombre_facultad     NVARCHAR(150) NOT NULL,
    CONSTRAINT FK_facultad_univ 
        FOREIGN KEY (universidad_id) REFERENCES dbo.universidad(universidad_id),
    CONSTRAINT UQ_facultad_nombre
        UNIQUE (universidad_id, nombre_facultad)
);

-------------------------------------------------------
-- 4) CAMPUS (depende de universidad)
-------------------------------------------------------
CREATE TABLE dbo.campus (
    campus_id        BIGINT IDENTITY(1,1) PRIMARY KEY,
    universidad_id   BIGINT NOT NULL,
    nombre_campus    NVARCHAR(120) NOT NULL,
    CONSTRAINT FK_campus_univ 
        FOREIGN KEY (universidad_id) REFERENCES dbo.universidad(universidad_id),
    CONSTRAINT UQ_campus_nombre
        UNIQUE (universidad_id, nombre_campus)
);

-------------------------------------------------------
-- 5) CARRERA (depende de facultad)
-------------------------------------------------------
CREATE TABLE dbo.carrera (
    carrera_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
    facultad_id      BIGINT NOT NULL,
    nombre_carrera   NVARCHAR(150) NOT NULL,
    CONSTRAINT FK_carrera_facultad 
        FOREIGN KEY (facultad_id) REFERENCES dbo.facultad(facultad_id),
    CONSTRAINT UQ_carrera_nombre
        UNIQUE (facultad_id, nombre_carrera)
);

-------------------------------------------------------
-- 6) PLAN DE ESTUDIOS (depende de carrera)  [reducido]
--    Solo guardamos la "version" como clave lógica.
-------------------------------------------------------
CREATE TABLE dbo.plan_estudios (
    plan_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    carrera_id  BIGINT NOT NULL,
    version     NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_plan_carrera 
        FOREIGN KEY (carrera_id) REFERENCES dbo.carrera(carrera_id),
    CONSTRAINT UQ_plan_estudios UNIQUE (carrera_id, version)
);

-------------------------------------------------------
-- 7) ESTUDIANTE (reducido: sin email/telefono/fechas/estado)
-------------------------------------------------------
CREATE TABLE dbo.estudiante (
    estudiante_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_estudiante NVARCHAR(20) NOT NULL UNIQUE,
    nombres           NVARCHAR(120) NOT NULL,
    apellidos         NVARCHAR(150) NOT NULL,
    carrera_id        BIGINT NULL,
    plan_id           BIGINT NULL,
    CONSTRAINT FK_est_carrera FOREIGN KEY (carrera_id) REFERENCES dbo.carrera(carrera_id),
    CONSTRAINT FK_est_plan    FOREIGN KEY (plan_id)    REFERENCES dbo.plan_estudios(plan_id)
);

-------------------------------------------------------
-- 8) PERIODO (reducido: solo año + término)
-------------------------------------------------------
CREATE TABLE dbo.periodo (
    periodo_id  BIGINT IDENTITY(1,1) PRIMARY KEY,
    anio        SMALLINT NOT NULL,
    termino     NVARCHAR(20) NOT NULL,
    CONSTRAINT UQ_periodo UNIQUE (anio, termino)
);

-------------------------------------------------------
-- 9) CURSO (reducido: sin descripción; creditos numérico)
-------------------------------------------------------
CREATE TABLE dbo.curso (
    curso_id      BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_curso  NVARCHAR(20) NOT NULL UNIQUE,
    nombre_curso  NVARCHAR(200) NOT NULL,
    creditos      SMALLINT NOT NULL,
    carrera_id    BIGINT NULL,
    CONSTRAINT FK_curso_carrera FOREIGN KEY (carrera_id) REFERENCES dbo.carrera(carrera_id)
);

-------------------------------------------------------
-- 10) SECCION (reducido: sin modalidad/capacidad)
-------------------------------------------------------
CREATE TABLE dbo.seccion (
    seccion_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_seccion NVARCHAR(20) NOT NULL UNIQUE,
    curso_id       BIGINT NOT NULL,
    periodo_id     BIGINT NOT NULL,
    campus_id      BIGINT NULL,
    CONSTRAINT FK_seccion_curso   FOREIGN KEY (curso_id)   REFERENCES dbo.curso(curso_id),
    CONSTRAINT FK_seccion_periodo FOREIGN KEY (periodo_id) REFERENCES dbo.periodo(periodo_id),
    CONSTRAINT FK_seccion_campus  FOREIGN KEY (campus_id)  REFERENCES dbo.campus(campus_id),
    CONSTRAINT UQ_seccion_tripleta UNIQUE (curso_id, periodo_id, codigo_seccion)
);
CREATE INDEX IX_seccion_periodo_curso ON dbo.seccion(periodo_id, curso_id);

-------------------------------------------------------
-- 11) SECCION_EVALUACION (reducido: sin fecha_programada)
-------------------------------------------------------
CREATE TABLE dbo.seccion_evaluacion (
    evaluacion_id    BIGINT IDENTITY(1,1) PRIMARY KEY,
    seccion_id       BIGINT NOT NULL,
    evaluacion_code  NVARCHAR(30) NOT NULL,
    nombre           NVARCHAR(100) NULL,
    ponderacion_pct  TINYINT NOT NULL CHECK (ponderacion_pct BETWEEN 0 AND 100),
    CONSTRAINT FK_eval_seccion FOREIGN KEY (seccion_id) REFERENCES dbo.seccion(seccion_id),
    CONSTRAINT UQ_eval_seccion UNIQUE (seccion_id, evaluacion_code)
);

-------------------------------------------------------
-- 12) MATRICULA (reducido: sin estado/fechas)
-------------------------------------------------------
CREATE TABLE dbo.matricula (
    matricula_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    estudiante_id    BIGINT NOT NULL,
    periodo_id       BIGINT NOT NULL,
    CONSTRAINT FK_mat_est FOREIGN KEY (estudiante_id) REFERENCES dbo.estudiante(estudiante_id),
    CONSTRAINT FK_mat_per FOREIGN KEY (periodo_id)    REFERENCES dbo.periodo(periodo_id),
    CONSTRAINT UQ_matricula UNIQUE (estudiante_id, periodo_id)
);

-------------------------------------------------------
-- 13) MATRICULA_SECCION (reducido)
-------------------------------------------------------
CREATE TABLE dbo.matricula_seccion (
    mat_seccion_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    matricula_id   BIGINT NOT NULL,
    seccion_id     BIGINT NOT NULL,
    CONSTRAINT FK_matsec_mat    FOREIGN KEY (matricula_id) REFERENCES dbo.matricula(matricula_id),
    CONSTRAINT FK_matsec_seccion FOREIGN KEY (seccion_id)  REFERENCES dbo.seccion(seccion_id),
    CONSTRAINT UQ_matsec UNIQUE (matricula_id, seccion_id)
);
CREATE INDEX IX_matsec_seccion ON dbo.matricula_seccion(seccion_id);

-------------------------------------------------------
-- 14) SECCION_PROFESOR_HIST (reducido: sin fechas; rol opcional)
-------------------------------------------------------
CREATE TABLE dbo.seccion_profesor_hist (
    seccion_prof_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    seccion_id      BIGINT NOT NULL,
    profesor_id     BIGINT NOT NULL,
    rol             NVARCHAR(20) NOT NULL DEFAULT 'TITULAR',
    CONSTRAINT FK_sph_seccion  FOREIGN KEY (seccion_id)  REFERENCES dbo.seccion(seccion_id),
    CONSTRAINT FK_sph_profesor FOREIGN KEY (profesor_id) REFERENCES dbo.profesor(profesor_id)
);
CREATE INDEX IX_sph ON dbo.seccion_profesor_hist(seccion_id, profesor_id);

-------------------------------------------------------
-- 15) NOTA_EVALUACION (reducido: sin fecha/origen)
-------------------------------------------------------
CREATE TABLE dbo.nota_evaluacion (
    nota_eval_id    BIGINT IDENTITY(1,1) PRIMARY KEY,
    mat_seccion_id  BIGINT NOT NULL,
    evaluacion_id   BIGINT NOT NULL,
    nota_obtenida   DECIMAL(5,2) NULL CHECK (nota_obtenida BETWEEN 0 AND 20),
    CONSTRAINT FK_ne_matsec FOREIGN KEY (mat_seccion_id) REFERENCES dbo.matricula_seccion(mat_seccion_id),
    CONSTRAINT FK_ne_eval   FOREIGN KEY (evaluacion_id)   REFERENCES dbo.seccion_evaluacion(evaluacion_id),
    CONSTRAINT UQ_ne UNIQUE (mat_seccion_id, evaluacion_id)
);
CREATE INDEX IX_ne_matsec ON dbo.nota_evaluacion(mat_seccion_id);
