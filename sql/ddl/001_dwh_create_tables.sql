CREATE DATABASE ODS;
GO

USE ODS;
GO

/* ===========================================================
   DIMENSIONES
   =========================================================== */

-- Dimensión Estudiantes
CREATE TABLE dbo.dim_estudiantes (
    estudiante_id     INT IDENTITY(1,1) PRIMARY KEY,
    codigo_estudiante   VARCHAR(20)  NOT NULL,
    nombre            VARCHAR(100) NOT NULL,
    apellidos         VARCHAR(150) NOT NULL,
    carrera           VARCHAR(150) NULL,
    ciclo             INT NULL,
    periodo           VARCHAR(20) NULL,
    universidad       VARCHAR(200) NULL
);
GO

-- Dimensión Cursos
CREATE TABLE dbo.dim_cursos (
    curso_id        INT IDENTITY(1,1) PRIMARY KEY,
    codigo_curso    VARCHAR(20)  NOT NULL,
    nombre_curso    VARCHAR(200) NOT NULL,
    descripcion     VARCHAR(200) NULL,
    creditos        INT NOT NULL
);
GO

-- Dimensión Profesores
CREATE TABLE dbo.dim_profesores (
    profesor_id       INT IDENTITY(1,1) PRIMARY KEY,
    codigo_docente    VARCHAR(20)  NOT NULL,
    nombre_profesor   VARCHAR(100) NOT NULL,
    apellidos         VARCHAR(150) NOT NULL,
    especialidad      VARCHAR(150) NULL
);
GO

-- Dimensión Secciones
CREATE TABLE dbo.dim_secciones (
    seccion_id    INT IDENTITY(1,1) PRIMARY KEY,
    curso_id      INT NOT NULL,
    periodo       VARCHAR(100) NOT NULL,
    universidad   VARCHAR(200) NOT NULL,
    profesor_id   INT NOT NULL,
    FOREIGN KEY (curso_id) REFERENCES dbo.dim_cursos(curso_id),
    FOREIGN KEY (profesor_id) REFERENCES dbo.dim_profesores(profesor_id)
);
GO

-- Dimensión Preguntas de Encuestas
CREATE TABLE dbo.dim_pregunta_encuesta (
    pregunta_id        INT IDENTITY(1,1) PRIMARY KEY,
    codigo_pregunta    VARCHAR(20) NOT NULL,
    pregunta_texto     VARCHAR(500) NOT NULL,
    dimension          VARCHAR(100) NULL,
    escala             VARCHAR(50) NULL,
    vigente_flag       BIT NOT NULL DEFAULT 1,
    fecha_creacion     DATETIME NULL,
    fecha_actualizacion DATETIME NULL
);
GO

-- Dimensión Tipo de Encuestas
CREATE TABLE dbo.dim_tipo_encuesta (
    tipo_encuesta_id    INT IDENTITY(1,1) PRIMARY KEY,
    codigo_tipo         VARCHAR(20) NOT NULL,
    nombre_tipo         VARCHAR(200) NOT NULL,
    descripcion         VARCHAR(200) NULL,
    escala              VARCHAR(50) NULL,
    vigente_flag        BIT NOT NULL DEFAULT 1,
    fecha_creacion      DATETIME NULL,
    fecha_actualizacion DATETIME NULL
);
GO

-- ===========================================================
-- DIM_DATE (versión con date_id = yyyymmdd)
-- ===========================================================

CREATE TABLE dbo.dim_date (
    date_id          INT NOT NULL PRIMARY KEY,  -- formato YYYYMMDD (ej: 20251011)
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

-- Hechos de Matrículas
CREATE TABLE dbo.fact_matriculas (
    matricula_id    INT IDENTITY(1,1) PRIMARY KEY,
    estudiante_id   INT NOT NULL,
    seccion_id      INT NOT NULL,
    periodo         VARCHAR(100) NULL,
    estado_matricula VARCHAR(50) NULL,
    fecha_matricula  DATE NULL,
    fecha_carga      DATETIME NOT NULL DEFAULT GETDATE(),
    origen_fuente   VARCHAR(255) NULL, -- agregado según tu indicación
    FOREIGN KEY (estudiante_id) REFERENCES dbo.dim_estudiantes(estudiante_id),
    FOREIGN KEY (seccion_id) REFERENCES dbo.dim_secciones(seccion_id)
);
GO

-- Hechos de Notas
CREATE TABLE dbo.fact_notas (
    nota_id          INT IDENTITY(1,1) PRIMARY KEY,
    estudiante_id    INT NOT NULL,
    seccion_id       INT NOT NULL,
    date_id          INT NOT NULL,
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

-- ===========================================================
-- FACT_ENCUESTAS (versión corregida)
-- ===========================================================

CREATE TABLE dbo.fact_encuestas (
    encuesta_id   INT IDENTITY(1,1) PRIMARY KEY,
    seccion_id         INT NOT NULL,
    pregunta_id        INT NOT NULL,
    tipo_encuesta_id   INT NOT NULL,
    date_id            INT NOT NULL,   -- FK a dim_date.date_id
    score_avg          DECIMAL(5,2) NULL,
    n_respuestas       INT NULL,
    score_min          DECIMAL(5,2) NULL,
    score_max          DECIMAL(5,2) NULL,
    std_dev            DECIMAL(6,3) NULL,
    fecha_carga        DATETIME NOT NULL DEFAULT GETDATE(),
    origen_fuente      VARCHAR(50) NULL, 
    CONSTRAINT FK_fact_encuestas_dim_secciones
        FOREIGN KEY (seccion_id) REFERENCES dbo.dim_secciones(seccion_id),

    CONSTRAINT FK_fact_encuestas_dim_pregunta_encuesta
        FOREIGN KEY (pregunta_id) REFERENCES dbo.dim_pregunta_encuesta(pregunta_id),

    CONSTRAINT FK_fact_encuestas_dim_tipo_encuesta
        FOREIGN KEY (tipo_encuesta_id) REFERENCES dbo.dim_tipo_encuesta(tipo_encuesta_id),

    CONSTRAINT FK_fact_encuestas_dim_date
        FOREIGN KEY (date_id) REFERENCES dbo.dim_date(date_id)
);
GO
 