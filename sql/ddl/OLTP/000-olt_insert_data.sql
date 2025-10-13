-- ===== Universidad =====
-- ============================================
-- Carga inicial UTP (institucional + plan 2025)
-- Requiere que ya exista la BD y el esquema 'sis'
-- ============================================
--delete  from sis.universidad
--DBCC CHECKIDENT ('sis.universidad', RESEED, 0);

USE DB_SIS_UTP;
GO
USE DB_SIS_UTP;
GO

/* ===== Universidad (PK: codigo_universidad) ===== */
INSERT INTO sis.universidad (codigo_universidad, nombre, sigla)
VALUES ('UTP', 'Universidad Tecnol�gica del Per�', 'UTP');


/* ===== Campus (FK a codigo_universidad) ===== */
DECLARE @campus_centro_id INT, @campus_lnorte_id INT;

INSERT INTO sis.campus (codigo_universidad, nombre_campus)
VALUES ('UTP', 'Centro Lima');
SET @campus_centro_id = SCOPE_IDENTITY();

INSERT INTO sis.campus (codigo_universidad, nombre_campus)
VALUES ('UTP', 'Lima Norte');
SET @campus_lnorte_id = SCOPE_IDENTITY();


/* ===== Facultades (FK a codigo_universidad) ===== */
DECLARE @fac_ing_id INT, @fac_neg_id INT, @fac_salud_id INT;

INSERT INTO sis.facultad (codigo_universidad, nombre_facultad)
VALUES ('UTP', 'Ingenier�a');
SET @fac_ing_id = SCOPE_IDENTITY();

INSERT INTO sis.facultad (codigo_universidad, nombre_facultad)
VALUES ('UTP', 'Negocios');
SET @fac_neg_id = SCOPE_IDENTITY();

INSERT INTO sis.facultad (codigo_universidad, nombre_facultad)
VALUES ('UTP', 'Salud');
SET @fac_salud_id = SCOPE_IDENTITY();

/* ===== Carreras (FK a facultad_id) ===== */
DECLARE @carrera_sistemas_id INT, @carrera_software_id INT, @carrera_civil_id INT, @carrera_admin_id INT;

INSERT INTO sis.carrera (facultad_id, nombre_carrera)
VALUES (@fac_ing_id, 'Ingenier�a de Sistemas');
SET @carrera_sistemas_id = SCOPE_IDENTITY();

INSERT INTO sis.carrera (facultad_id, nombre_carrera)
VALUES (@fac_ing_id, 'Ingenier�a de Software');
SET @carrera_software_id = SCOPE_IDENTITY();

INSERT INTO sis.carrera (facultad_id, nombre_carrera)
VALUES (@fac_ing_id, 'Ingenier�a Civil');
SET @carrera_civil_id = SCOPE_IDENTITY();

INSERT INTO sis.carrera (facultad_id, nombre_carrera)
VALUES (@fac_neg_id, 'Administraci�n');
SET @carrera_admin_id = SCOPE_IDENTITY();

/* ===== Plan de estudios (principal: Sistemas - versi�n 2025) ===== */
DECLARE @plan_sistemas_2025_id INT;

INSERT INTO sis.plan_estudios (carrera_id, version, vigente_desde, vigente_hasta)
VALUES (@carrera_sistemas_id, '2025', '2025-01-01', NULL);

SET @plan_sistemas_2025_id = SCOPE_IDENTITY();

/* ===== Periodos (varios; foco en 2025-CICLO01) ===== */
INSERT INTO sis.periodo (anio, termino, fecha_inicio, fecha_fin)
VALUES (2024, 'CICLO01', '2024-03-01', '2024-07-31');

INSERT INTO sis.periodo (anio, termino, fecha_inicio, fecha_fin)
VALUES (2024, 'CICLO02', '2024-08-01', '2024-12-31');

INSERT INTO sis.periodo (anio, termino, fecha_inicio, fecha_fin)
VALUES (2025, 'CICLO01', '2025-03-01', '2025-07-31');

INSERT INTO sis.periodo (anio, termino, fecha_inicio, fecha_fin)
VALUES (2025, 'CICLO02', '2025-08-01', '2025-12-31');





INSERT INTO sis.curso (codigo_curso, nombre_curso, creditos, carrera_id)
VALUES
('100000I27N','ADMINISTRACI�N Y ORGANIZACI�N DE EMPRESAS',3,1),
('100000SI42','ALGORITMOS Y ESTRUCTURAS DE DATOS',3,1),
('100000SI36','AN�LISIS Y DISE�O DE ALGORITMOS',3,1),
('100000I60N','AN�LISIS Y DISE�O DE SISTEMAS DE INFORMACI�N',4,1),
('100000I52N','BASE DE DATOS',3,1),
('100000SI48','BASE DE DATOS II',4,1),
('1000000IN6','C�LCULO I',4,1),
('100000S2I5','C�LCULO II',2,1),
('100000I80S','CALIDAD DE SOFTWARE',3,1),
('100000N07C','CIUDADAN�A Y REFLEXI�N �TICA',3,1),
('100000AL01','COMPRENSI�N Y REDACCI�N DE TEXTOS I',4,1),
('100000A16E','COMPRENSI�N Y REDACCI�N DE TEXTOS II',4,1),
('100000IN42','CONTABILIDAD GENERAL',3,1),
('100000I58N','CURSO INTEGRADOR I: SISTEMAS - SOFTWARE',3,1),
('100000S09I','CURSO INTEGRADOR II: SISTEMAS',3,1),
('100000ST61','DESARROLLO WEB INTEGRADO',2,1),
('100000SI49','DISE�O DE PATRONES',2,1),
('100000S64V','DISE�O DE PRODUCTOS Y SERVICIOS',3,1),
('100000SI71','DISE�O E IMPLEMENTACI�N DE ARQUITECTURA EMPRESARIAL',3,1),
('10000028ZZ','ELEMENTARY BUSINESS ENGLISH',4,1),
('100000S21V','ESTAD�STICA DESCRIPTIVA Y PROBABILIDADES',3,1),
('100000SI31','ESTAD�STICA INFERENCIAL',4,1),
('100000N12I','�TICA PROFESIONAL',2,1),
('100000N11I','FORMACI�N PARA LA EMPLEABILIDAD',3,1),
('100000SI82','FORMACI�N PARA LA INVESTIGACI�N - SISTEMAS',4,1),
('100000F2I1','FUNDAMENTOS DE ELECTROMAGNETISMO',3.78,1),
('100000I33N','GESTI�N DE PROYECTOS',3,1),
('100000SI51','GESTI�N DEL CONOCIMIENTO',2,1),
('100000S74T','GESTI�N DEL SERVICIO TI',3,1),
('100000S66T','HERRAMIENTAS DE DESARROLLO',3,1),
('10000092ST','HERRAMIENTAS DE DESARROLLO PROFESIONAL - TIC',2,1),
('100000S75T','HERRAMIENTAS DE PROTOTIPADO',3,1),
('100000I04N','HERRAMIENTAS INFORM�TICAS PARA LA TOMA DE DECISIONES',2,1),
('100000S72V','HERRAMIENTAS PARA LA COMUNICACI�N EFECTIVA',3,1),
('100000S53T','HOJAS DE ESTILO EN CASCADA AVANZADO',2,1),
('100000N09I','INDIVIDUO Y MEDIO AMBIENTE',2,1),
('100000IN64','INGENIER�A ECON�MICA',3,1),
('100000N03I','INGL�S I',3,1),
('100000N05I','INGL�S II',3,1),
('100000N08I','INGL�S III',3,1),
('100000N10I','INGL�S IV',3,1),
('100000SI63','INNOVACI�N Y TRANSFORMACI�N DIGITAL',3,1),
('100000I62N','INTELIGENCIA DE NEGOCIOS',4,1),
('100000S82T','INTERACCI�N HOMBRE MAQUINA',3,1),
('100000VU02','INTRODUCCI�N A LA VIDA UNIVERSITARIA',2,1),
('100000TI60','INTRODUCCI�N A LAS TIC',2,1),
('100000N02C','INVESTIGACI�N ACAD�MICA',4,1),
('100000S51T','JAVA SCRIPT AVANZADO',3,1),
('100000F2I2','LABORATORIO DE FUNDAMENTOS DE ELECTROMAGNETISMO',0.22,1),
('100000F1I2','LABORATORIO DE MEC�NICA CL�SICA',0.22,1),
('100000L02Q','LABORATORIO DE QU�MICA GENERAL',0.28,1),
('100000SI68','LENGUAJES DE PROGRAMACI�N',2,1),
('100000S63V','LIDERAZGO Y GESTI�N DE EQUIPOS',3,1),
('100000S52T','MARCOS DE DESARROLLO WEB',3,1),
('100000SI18','MATEM�TICA DISCRETA',2,1),
('100000I0N2','MATEM�TICA I',3,1),
('100000I0N3','MATEM�TICA II',4,1),
('100000F1I1','MEC�NICA CL�SICA',3.78,1),
('100000S76T','NEGOCIACI�N Y NARRATIVA',2,1),
('100000SI73','PLANEAMIENTO ESTRAT�GICO DE LAS TICs',4,1),
('100000SI12','PRINCIPIOS DE ALGORITMOS',2,1),
('100000A17E','PROBLEMAS Y DESAF�OS EN EL PER� ACTUAL',3,1),
('100000SI34','PROGRAMACI�N ORIENTADA A OBJETOS',3,1),
('100000I41N','REDES Y COMUNICACI�N DE DATOS I',4,1),
('100000I45N','SEGURIDAD INFORM�TICA',3,1),
('100000S91T','SERVICIOS CLOUD',3,1),
('100000S84T','SISTEMAS DE INFORMACI�N EMPRESARIAL',3,1),
('100000TV74','SISTEMAS OPERATIVOS',3,1),
('100000S11I','TALLER DE INVESTIGACI�N - SISTEMAS',4,1),
('100000SI23','TALLER DE PROGRAMACI�N',3,1),
('100000SI45','TALLER DE PROGRAMACI�N WEB',2,1),
('100000S62T','TEOR�A DE SISTEMAS',3,1);




INSERT INTO sis.plan_curso (plan_id,codigo_curso, ciclo, tipo)
VALUES(1,'100000I0N2',1,'O'),
(1,'100000SI12',1,'O'),
(1,'100000AL01',1,'O'),
(1,'100000VU02',1,'O'),
(1,'100000N03I',1,'O'),
(1,'100000N09I',1,'O'),
(1,'100000S21V',2,'O'),
(1,'100000A17E',2,'O'),
(1,'100000I0N3',2,'O'),
(1,'100000SI18',2,'O'),
(1,'100000A16E',2,'O'),
(1,'100000TI60',2,'O'),
(1,'100000N05I',2,'O'),
(1,'100000SI31',3,'O'),
(1,'1000000IN6',3,'O'),
(1,'100000F1I2',3,'O'),
(1,'100000F1I1',3,'O'),
(1,'100000SI23',3,'O'),
(1,'100000N08I',3,'O'),
(1,'100000N07C',3,'O'),
(1,'100000L02Q',3,'E'),
(1,'100000S2I5',4,'O'),
(1,'100000F2I2',4,'O'),
(1,'100000F2I1',4,'O'),
(1,'100000SI34',4,'O'),
(1,'100000N02C',4,'O'),
(1,'100000N10I',4,'O'),
(1,'100000I52N',4,'O'),
(1,'100000SI36',4,'O'),
(1,'100000I04N',5,'O'),
(1,'100000TV74',5,'O'),
(1,'100000SI45',5,'O'),
(1,'100000I41N',5,'O'),
(1,'100000SI49',5,'O'),
(1,'100000SI42',5,'O'),
(1,'100000SI48',5,'O'),
(1,'100000I33N',6,'O'),
(1,'100000S53T',6,'O'),
(1,'100000S52T',6,'O'),
(1,'100000S51T',6,'O'),
(1,'100000I58N',6,'O'),
(1,'100000I60N',6,'O'),
(1,'100000I27N',6,'O'),
(1,'100000S64V',7,'O'),
(1,'100000S63V',7,'O'),
(1,'100000S66T',7,'O'),
(1,'100000I45N',7,'O'),
(1,'100000ST61',7,'O'),
(1,'100000SI68',7,'O'),
(1,'100000S62T',7,'O'),
(1,'100000S72V',8,'O'),
(1,'100000S76T',8,'O'),
(1,'100000I62N',8,'O'),
(1,'100000SI71',8,'O'),
(1,'100000S75T',8,'O'),
(1,'100000SI63',8,'O'),
(1,'100000S74T',8,'O'),
(1,'100000S82T',9,'O'),
(1,'100000S84T',9,'O'),
(1,'100000SI82',9,'O'),
(1,'100000S09I',9,'O'),
(1,'100000SI73',9,'O'),
(1,'100000SI51',9,'O'),
(1,'10000092ST',10,'O'),
(1,'100000N12I',10,'O'),
(1,'100000S11I',10,'O'),
(1,'100000N11I',10,'O'),
(1,'100000S91T',10,'O'),
(1,'100000IN64',10,'O'),
(1,'10000028ZZ',10,'E'),
(1,'100000I80S',10,'E'),
(1,'100000IN42',10,'E');




SELECT * FROM SIS.facultad
SELECT * FROM SIS.campus
SELECT * FROM SIS.universidad
SELECT * FROM SIS.periodo
SELECT * FROM SIS.carrera
SELECT * FROM SIS.curso
SELECT * FROM SIS.plan_estudios
SELECT * FROM SIS.plan_curso
SELECT * FROM SIS.estudiante
SELECT * FROM SIS.estudiante_detalle
SELECT * FROM SIS.profesor
SELECT * FROM SIS.profesor_detalle
SELECT * FROM SIS.plan_curso
SELECT * FROM SIS.seccion  
SELECT * FROM SIS.seccion_profesor_hist
SELECT * FROM SIS.matricula
SELECT * FROM SIS.matricula_seccion
SELECT * FROM SIS.seccion_evaluacion
SELECT * FROM SIS.nota_evaluacion


