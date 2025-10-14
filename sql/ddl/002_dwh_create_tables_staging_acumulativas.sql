
CREATE TABLE [dbo].[tipo_encuesta](
	[codigo_tipo] Nvarchar(255) NOT NULL,
	[vigente_flag] FLOAT NOT NULL,
	[fecha_creacion] Nvarchar(255) NOT NULL,
	[nombre_tipo] NVARCHAR(255) NULL,
	[descripcion] NVARCHAR(255) NULL,
	[escala_default] NVARCHAR(255) NOT NULL, 
) 
GO
 
CREATE TABLE [dbo].[pregunta_encuesta](
	[codigo_pregunta] [nvarchar](255) NULL,
	[codigo_tipo] [nvarchar](255) NULL,
	[pregunta_texto] [nvarchar](255) NULL,
	[dimension] [nvarchar](255) NULL,
	[escala] [nvarchar](255) NULL,
	[vigente_flag] [nvarchar](255) NULL,
	[fecha_creacion] [nvarchar](255) NULL
) 

GO

CREATE TABLE [encuesta_resultado](
	[codigo_tipo] VARCHAR (25) NOT NULL,
	[codigo_seccion] [nvarchar](255) NULL,
	[codigo_pregunta] [nvarchar](255) NULL,
	[n_respuestas] [nvarchar](255) NULL,
	[score_avg] [nvarchar](255) NULL,
	[score_min] [nvarchar](255) NULL,
	[score_max] [nvarchar](255) NULL,
	[std_dev] [nvarchar](255) NULL,
	[fecha_aplicacion] [nvarchar](255) NULL,
	[fecha_carga] [nvarchar](255) NULL,
	[origen_fuente] [nvarchar](255) NULL
) 
GO


