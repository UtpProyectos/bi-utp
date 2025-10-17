;WITH STG_SECC AS (
    SELECT DISTINCT
        s.codigo_curso,
        s.periodo_id,
        s.campus_id
    FROM [STAGING].temp.seccion s
),
LLAVES_DW AS (
    SELECT
        c.curso_id,
        s.periodo_id,
        s.campus_id
    FROM STG_SECC s
    JOIN [ODS].dbo.dim_cursos c
      ON c.curso_id = s.codigo_curso  
)

DELETE DS
FROM [ODS].dbo.dim_secciones AS DS
JOIN LLAVES_DW K
  ON DS.curso_id  = K.curso_id
 AND DS.periodo   = K.periodo_id
 AND DS.campus_id = K.campus_id;

;WITH K AS (
    SELECT
        c.curso_id,
        s.periodo_id,
        s.campus_id
    FROM [STAGING].temp.seccion s
    JOIN [ODS].dbo.dim_cursos c
      ON c.curso_id = s.codigo_curso
),
MAP_SECC AS (
    SELECT d.seccion_id, d.curso_id, d.periodo, d.campus_id
    FROM [ODS].dbo.dim_secciones d
    JOIN K
      ON d.curso_id  = K.curso_id
     AND d.periodo   = K.periodo_id
     AND d.campus_id = K.campus_id
)
DELETE F
FROM [ODS].dbo.fact_matriculas F
JOIN MAP_SECC M
  ON F.seccion_id = M.seccion_id
 AND F.periodo    = M.periodo
 AND F.campus_id  = M.campus_id;



 delete dwh from ods.dbo.dim_secciones dwh
 join STAGING.dbo.seccion acum
 on dwh.seccion_id = acum.codigo_seccion AND
    dwh.curso_id = acum.codigo_curso


select * from dbo.universidad