/* ===========================================================
   RESET LIMPIO (SIN DATA): codigo_seccion como ID/PK
   =========================================================== */
SET XACT_ABORT ON;
BEGIN TRAN;

--------------------------------------------------------------
-- 1) DROPS en orden correcto (evita errores de FK)
--------------------------------------------------------------
IF OBJECT_ID('sis.nota_alumno_seccion','U') IS NOT NULL
  DROP TABLE sis.nota_alumno_seccion;

IF OBJECT_ID('sis.matricula_seccion','U') IS NOT NULL
  DROP TABLE sis.matricula_seccion;

IF OBJECT_ID('sis.seccion_profesor_hist','U') IS NOT NULL
  DROP TABLE sis.seccion_profesor_hist;

-- (Opcional) No es necesario botar matricula si no cambias su estructura
-- IF OBJECT_ID('sis.matricula','U') IS NOT NULL
--   DROP TABLE sis.matricula;

IF OBJECT_ID('sis.seccion','U') IS NOT NULL
  DROP TABLE sis.seccion;

--------------------------------------------------------------
-- 2) CREATES con codigo_seccion como PK
--------------------------------------------------------------

/* =======================
   Oferta académica (secciones)
   ======================= */
CREATE TABLE sis.seccion (
  codigo_seccion   VARCHAR(20) PRIMARY KEY,        -- ahora es el ID
  codigo_curso     VARCHAR(20) NOT NULL,           -- FK a curso
  periodo_id       INT NOT NULL,
  campus_id        INT NULL,
  modalidad        VARCHAR(20) NULL,               -- Presencial/Virtual/Mixta
  capacidad        INT NULL,
  CONSTRAINT FK_seccion_curso   FOREIGN KEY (codigo_curso) REFERENCES sis.curso(codigo_curso),
  CONSTRAINT FK_seccion_periodo FOREIGN KEY (periodo_id)   REFERENCES sis.periodo(periodo_id),
  CONSTRAINT FK_seccion_campus  FOREIGN KEY (campus_id)    REFERENCES sis.campus(campus_id),
  CONSTRAINT UQ_seccion UNIQUE (codigo_curso, periodo_id, codigo_seccion)
);
-- Índice de apoyo por periodo/curso
CREATE INDEX IX_seccion_periodo_curso ON sis.seccion(periodo_id, codigo_curso);


/* =======================
   Historial de profesor por sección
   ======================= */
CREATE TABLE sis.seccion_profesor_hist (
  seccion_prof_id  BIGINT IDENTITY(1,1) PRIMARY KEY,
  codigo_seccion   VARCHAR(20) NOT NULL,           -- FK directo
  codigo_profesor  VARCHAR(20) NOT NULL,
  rol              VARCHAR(20) NOT NULL DEFAULT 'TITULAR', -- TITULAR/AUXILIAR
  vigente_desde    DATETIME2 NOT NULL,
  vigente_hasta    DATETIME2 NULL,
  CONSTRAINT FK_sph_seccion  FOREIGN KEY (codigo_seccion)  REFERENCES sis.seccion(codigo_seccion),
  CONSTRAINT FK_sph_profesor FOREIGN KEY (codigo_profesor) REFERENCES sis.profesor(codigo_profesor)
);
CREATE INDEX IX_sph_activo ON sis.seccion_profesor_hist(codigo_seccion, vigente_hasta) INCLUDE (codigo_profesor);


/* =======================
   Matrícula (cabecera)  -- (solo crear si no existe)
   ======================= */
IF OBJECT_ID('sis.matricula','U') IS NULL
BEGIN
  CREATE TABLE sis.matricula (
    matricula_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_estudiante  VARCHAR(20) NOT NULL,
    periodo_id         INT NOT NULL,
    fecha_matricula    DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    estado             VARCHAR(20) NOT NULL DEFAULT 'VIGENTE', -- VIGENTE/ANULADA
    CONSTRAINT FK_mat_est FOREIGN KEY (codigo_estudiante) REFERENCES sis.estudiante(codigo_estudiante),
    CONSTRAINT FK_mat_per FOREIGN KEY (periodo_id)        REFERENCES sis.periodo(periodo_id),
    CONSTRAINT UQ_matricula UNIQUE (codigo_estudiante, periodo_id)
  );
END


/* =======================
   Matrícula - detalle de secciones
   ======================= */
CREATE TABLE sis.matricula_seccion (
  mat_seccion_id    BIGINT IDENTITY(1,1) PRIMARY KEY,
  matricula_id      BIGINT NOT NULL,
  codigo_seccion    VARCHAR(20) NOT NULL,          -- FK directo a seccion
  estado            VARCHAR(20) NOT NULL DEFAULT 'INSCRITO',
  fecha_inscripcion DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  fecha_baja        DATETIME2 NULL,
  intento_nro       TINYINT NULL,                  -- 1er/2do/3er intento
  CONSTRAINT FK_matsec_mat     FOREIGN KEY (matricula_id)   REFERENCES sis.matricula(matricula_id),
  CONSTRAINT FK_matsec_seccion FOREIGN KEY (codigo_seccion) REFERENCES sis.seccion(codigo_seccion),
  CONSTRAINT UQ_matsec UNIQUE (matricula_id, codigo_seccion)
);
CREATE INDEX IX_matsec_seccion ON sis.matricula_seccion(codigo_seccion);


/* =======================
   Notas por alumno-sección
   ======================= */

   /* Componentes de evaluación por sección (pesos) */
IF OBJECT_ID('sis.seccion_evaluacion','U') IS NULL
BEGIN
  CREATE TABLE sis.seccion_evaluacion (
    evaluacion_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_seccion    VARCHAR(20) NOT NULL,
    evaluacion_code   VARCHAR(30) NOT NULL,  -- 'PARCIAL','PRACT','FINAL'
    nombre            VARCHAR(100) NULL,
    ponderacion_pct   DECIMAL(5,2) NOT NULL CHECK (ponderacion_pct BETWEEN 0 AND 100),
    fecha_programada  DATE NULL,
    CONSTRAINT FK_eval_seccion FOREIGN KEY (codigo_seccion)
      REFERENCES sis.seccion(codigo_seccion),
    CONSTRAINT UQ_eval_seccion UNIQUE (codigo_seccion, evaluacion_code)
  );
END
GO

/* Nota por alumno-sección y evaluación (grano fino) */
IF OBJECT_ID('sis.nota_evaluacion','U') IS NULL
BEGIN
  CREATE TABLE sis.nota_evaluacion (
    nota_eval_id      BIGINT IDENTITY(1,1) PRIMARY KEY,
    mat_seccion_id    BIGINT NOT NULL,
    evaluacion_id     BIGINT NOT NULL,
    nota_obtenida     DECIMAL(5,2) NULL CHECK (nota_obtenida BETWEEN 0 AND 20),
    fecha_registro    DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    origen_fuente     VARCHAR(30) NULL,
    CONSTRAINT FK_ne_matsec FOREIGN KEY (mat_seccion_id)
      REFERENCES sis.matricula_seccion(mat_seccion_id),
    CONSTRAINT FK_ne_eval FOREIGN KEY (evaluacion_id)
      REFERENCES sis.seccion_evaluacion(evaluacion_id),
    CONSTRAINT UQ_ne UNIQUE (mat_seccion_id, evaluacion_id)
  );
  CREATE INDEX IX_ne_matsec ON sis.nota_evaluacion(mat_seccion_id);
END
GO

 
 