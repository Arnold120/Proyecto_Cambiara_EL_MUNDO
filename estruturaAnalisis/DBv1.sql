USE SistemaEducativoCompleto;
GO

-- ============================================================
-- 1. TABLAS DE CATÁLOGO (NORMALIZACIÓN DE VALORES VARCHAR)
-- ============================================================

-- Catálogo de Estados de Asistencia
CREATE TABLE CatalogoEstadoAsistencia (
    EstadoAsistenciaId INT PRIMARY KEY IDENTITY,
    Codigo VARCHAR(20) UNIQUE NOT NULL,        -- 'PRESENTE', 'AUSENTE', 'TARDANZA', 'JUSTIFICADO'
    Nombre VARCHAR(50) NOT NULL,               -- 'Presente', 'Ausente', 'Tardanza', 'Justificado'
    Descripcion VARCHAR(200),
    Color VARCHAR(7),                          -- Para UI: '#10B981', '#EF4444', '#F59E0B'
    Activo BIT DEFAULT 1
);

INSERT INTO CatalogoEstadoAsistencia (Codigo, Nombre, Descripcion, Color) VALUES
('PRESENTE', 'Presente', 'El estudiante asistió puntualmente', '#10B981'),
('AUSENTE', 'Ausente', 'El estudiante no asistió', '#EF4444'),
('TARDANZA', 'Tardanza', 'El estudiante llegó tarde', '#F59E0B'),
('JUSTIFICADO', 'Justificado', 'Ausencia con justificación válida', '#3B82F6');
GO

-- Catálogo de Tipos de Examen
CREATE TABLE CatalogoTipoExamen (
    TipoExamenId INT PRIMARY KEY IDENTITY,
    Codigo VARCHAR(20) UNIQUE NOT NULL,        -- 'PRACTICO', 'TEORICO', 'MIXTO'
    Nombre VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(200),
    PesoPorcentaje DECIMAL(5,2),               -- Peso en la calificación final
    Activo BIT DEFAULT 1
);

INSERT INTO CatalogoTipoExamen (Codigo, Nombre, Descripcion, PesoPorcentaje) VALUES
('PRACTICO', 'Práctico', 'Evaluación de habilidades prácticas', 30.00),
('TEORICO', 'Teórico', 'Evaluación de conocimientos teóricos', 40.00),
('MIXTO', 'Mixto', 'Combinación de teoría y práctica', 50.00),
('PARCIAL', 'Parcial', 'Evaluación parcial del curso', 25.00),
('FINAL', 'Final', 'Evaluación final del curso', 35.00);
GO

-- Catálogo de Tipos de Alerta
CREATE TABLE CatalogoTipoAlerta (
    TipoAlertaId INT PRIMARY KEY IDENTITY,
    Codigo VARCHAR(30) UNIQUE NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(200),
    NivelSeveridad INT,                        -- 1: Bajo, 2: Medio, 3: Alto, 4: Crítico
    Color VARCHAR(7),
    PlantillaMensaje VARCHAR(500),             -- Plantilla para generar alertas automáticas
    Activo BIT DEFAULT 1
);

INSERT INTO CatalogoTipoAlerta (Codigo, Nombre, Descripcion, NivelSeveridad, Color, PlantillaMensaje) VALUES
('INASISTENCIA_REITERADA', 'Inasistencia Reiterada', 'Estudiante con múltiples ausencias', 3, '#F97316', 
 'El estudiante {estudiante} tiene {cantidad} inasistencias en {asignatura}'),
('BAJO_RENDIMIENTO', 'Bajo Rendimiento', 'Promedio de notas bajo el umbral', 2, '#EAB308',
 'El estudiante {estudiante} tiene un promedio de {promedio} en {asignatura}'),
('RIESGO_DESERCION', 'Riesgo de Deserción', 'Estudiante en riesgo de abandonar', 4, '#EF4444',
 'ALERTA: El estudiante {estudiante} está en riesgo de deserción académica'),
('FECHA_ENTREGA', 'Próxima Entrega', 'Actividad próxima a vencer', 1, '#3B82F6',
 'La actividad {actividad} vence el {fecha}'),
('RETRASO_CONTINUO', 'Retraso Continuo', 'Llegadas tarde frecuentes', 2, '#F59E0B',
 'El estudiante {estudiante} tiene {cantidad} retrasos en el mes');
GO

-- Catálogo de Tipos de Recurso
CREATE TABLE CatalogoTipoRecurso (
    TipoRecursoId INT PRIMARY KEY IDENTITY,
    Codigo VARCHAR(20) UNIQUE NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Icono VARCHAR(50),                         -- Nombre del icono para UI
    ExtensionesPermitidas VARCHAR(200),        -- '.pdf,.doc,.docx'
    Activo BIT DEFAULT 1
);

INSERT INTO CatalogoTipoRecurso (Codigo, Nombre, Icono, ExtensionesPermitidas) VALUES
('VIDEO', 'Video', 'VideoIcon', '.mp4,.avi,.mov'),
('PDF', 'PDF', 'FileTextIcon', '.pdf'),
('DOCUMENTO', 'Documento', 'FileIcon', '.doc,.docx,.txt'),
('PRESENTACION', 'Presentación', 'PresentationIcon', '.ppt,.pptx'),
('ENLACE', 'Enlace Externo', 'LinkIcon', ''),
('IMAGEN', 'Imagen', 'ImageIcon', '.jpg,.jpeg,.png,.gif');
GO

-- Catálogo de Estados Generales
CREATE TABLE CatalogoEstado (
    EstadoId INT PRIMARY KEY IDENTITY,
    Codigo VARCHAR(30) UNIQUE NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(200),
    Color VARCHAR(7),
    Activo BIT DEFAULT 1
);

INSERT INTO CatalogoEstado (Codigo, Nombre, Descripcion, Color) VALUES
('ACTIVO', 'Activo', 'Registro activo en el sistema', '#10B981'),
('INACTIVO', 'Inactivo', 'Registro desactivado temporalmente', '#6B7280'),
('SUSPENDIDO', 'Suspendido', 'Registro suspendido por medida disciplinaria', '#EF4444'),
('GRADUADO', 'Graduado', 'Estudiante que completó el programa', '#3B82F6'),
('BAJA_TEMPORAL', 'Baja Temporal', 'Baja temporal por motivos varios', '#F59E0B'),
('BAJA_DEFINITIVA', 'Baja Definitiva', 'Baja permanente del sistema', '#7C3AED');
GO

-- Catálogo de Estados de Alerta
CREATE TABLE CatalogoEstadoAlerta (
    EstadoAlertaId INT PRIMARY KEY IDENTITY,
    Codigo VARCHAR(20) UNIQUE NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(200),
    Color VARCHAR(7)
);

INSERT INTO CatalogoEstadoAlerta (Codigo, Nombre, Descripcion, Color) VALUES
('PENDIENTE', 'Pendiente', 'Alerta sin atender', '#F59E0B'),
('EN_PROCESO', 'En Proceso', 'Alerta en proceso de atención', '#3B82F6'),
('RESUELTA', 'Resuelta', 'Alerta atendida y resuelta', '#10B981'),
('DESCARTADA', 'Descartada', 'Alerta descartada por error o falsa alarma', '#6B7280');
GO

-- ============================================================
-- 2. TABLA PARA ROLES DE USUARIO EN MENSAJES
-- ============================================================

-- Catálogo de Tipos de Actor (para identificar emisor/receptor)
CREATE TABLE CatalogoTipoActor (
    TipoActorId INT PRIMARY KEY IDENTITY,
    Codigo VARCHAR(20) UNIQUE NOT NULL,
    Nombre VARCHAR(50) NOT NULL
);

INSERT INTO CatalogoTipoActor (Codigo, Nombre) VALUES
('ESTUDIANTE', 'Estudiante'),
('DOCENTE', 'Docente'),
('ADMINISTRADOR', 'Administrador'),
('COORDINADOR', 'Coordinador');
GO

-- ============================================================
-- 3. MODIFICACIÓN DE TABLAS EXISTENTES
-- ============================================================

-- Modificar tabla Asistencia para usar catálogo
ALTER TABLE Asistencia
ADD EstadoAsistenciaId INT NULL;

ALTER TABLE Asistencia
ADD CONSTRAINT FK_Asistencia_EstadoAsistencia 
FOREIGN KEY (EstadoAsistenciaId) REFERENCES CatalogoEstadoAsistencia(EstadoAsistenciaId);

-- Migra datos existentes
UPDATE Asistencia
SET EstadoAsistenciaId = CASE 
    WHEN UPPER(EstadoAsistencia) LIKE '%PRESENT%' THEN 1
    WHEN UPPER(EstadoAsistencia) LIKE '%AUSENT%' THEN 2
    WHEN UPPER(EstadoAsistencia) LIKE '%TARD%' THEN 3
    WHEN UPPER(EstadoAsistencia) LIKE '%JUSTIF%' THEN 4
    ELSE 1
END;

-- Modificar tabla Examenes para usar catálogo
ALTER TABLE Examenes
ADD TipoExamenId INT NULL;

ALTER TABLE Examenes
ADD CONSTRAINT FK_Examenes_TipoExamen 
FOREIGN KEY (TipoExamenId) REFERENCES CatalogoTipoExamen(TipoExamenId);

-- Migra datos de tipo examen
UPDATE Examenes
SET TipoExamenId = CASE 
    WHEN UPPER(TipoExamen) LIKE '%PRACTIC%' THEN 1
    WHEN UPPER(TipoExamen) LIKE '%TEORIC%' THEN 2
    WHEN UPPER(TipoExamen) LIKE '%MIXTO%' THEN 3
    ELSE 2
END;

-- Modificar tabla Alertas para usar catálogos
ALTER TABLE Alertas
ADD TipoAlertaId INT NULL,
    EstadoAlertaId INT NULL;

ALTER TABLE Alertas
ADD CONSTRAINT FK_Alertas_TipoAlerta 
FOREIGN KEY (TipoAlertaId) REFERENCES CatalogoTipoAlerta(TipoAlertaId);

ALTER TABLE Alertas
ADD CONSTRAINT FK_Alertas_EstadoAlerta 
FOREIGN KEY (EstadoAlertaId) REFERENCES CatalogoEstadoAlerta(EstadoAlertaId);

-- Actualizar estados de alertas existentes
UPDATE Alertas
SET EstadoAlertaId = CASE 
    WHEN Estado = 0 THEN 1  -- Pendiente
    WHEN Estado = 1 THEN 3  -- Resuelta
    ELSE 1
END;

-- Modificar tabla MaterialesCurso
ALTER TABLE MaterialesCurso
ADD TipoRecursoId INT NULL;

ALTER TABLE MaterialesCurso
ADD CONSTRAINT FK_Materiales_TipoRecurso 
FOREIGN KEY (TipoRecursoId) REFERENCES CatalogoTipoRecurso(TipoRecursoId);

-- Migra datos de tipo recurso
UPDATE MaterialesCurso
SET TipoRecursoId = CASE 
    WHEN UPPER(TipoRecurso) LIKE '%VIDEO%' THEN 1
    WHEN UPPER(TipoRecurso) LIKE '%PDF%' THEN 2
    WHEN UPPER(TipoRecurso) LIKE '%DOC%' THEN 3
    WHEN UPPER(TipoRecurso) LIKE '%PPT%' OR UPPER(TipoRecurso) LIKE '%PRESENT%' THEN 4
    WHEN UPPER(TipoRecurso) LIKE '%LINK%' OR UPPER(TipoRecurso) LIKE '%ENLACE%' THEN 5
    WHEN UPPER(TipoRecurso) LIKE '%IMAGE%' OR UPPER(TipoRecurso) LIKE '%IMAGEN%' THEN 6
    ELSE 2
END;

-- Modificar tablas Estudiantes y Docentes para usar catálogo de estados
ALTER TABLE Estudiantes
ADD EstadoId INT NULL;

ALTER TABLE Estudiantes
ADD CONSTRAINT FK_Estudiantes_Estado 
FOREIGN KEY (EstadoId) REFERENCES CatalogoEstado(EstadoId);

UPDATE Estudiantes SET EstadoId = CASE WHEN Estado = 1 THEN 1 ELSE 2 END;

ALTER TABLE Docentes
ADD EstadoId INT NULL;

ALTER TABLE Docentes
ADD CONSTRAINT FK_Docentes_Estado 
FOREIGN KEY (EstadoId) REFERENCES CatalogoEstado(EstadoId);

UPDATE Docentes SET EstadoId = CASE WHEN Estado = 1 THEN 1 ELSE 2 END;

-- ============================================================
-- 4. CORRECCIÓN DE TABLA MENSAJES (NORMALIZACIÓN BCNF)
-- ============================================================

-- Eliminar tabla Mensajes anterior y crear estructura correcta
DROP TABLE IF EXISTS Mensajes;

CREATE TABLE Mensajes (
    MensajeId INT PRIMARY KEY IDENTITY,
    EmisorUsuarioId INT NOT NULL,              -- Usuario que envía
    ReceptorUsuarioId INT NOT NULL,            -- Usuario que recibe
    Asunto VARCHAR(200),
    Contenido NVARCHAR(MAX),                   -- NVARCHAR para caracteres especiales
    FechaEnvio DATETIME DEFAULT GETDATE(),
    FechaLectura DATETIME NULL,                -- NULL hasta que se lea
    EliminadoEmisor BIT DEFAULT 0,
    EliminadoReceptor BIT DEFAULT 0,
    CONSTRAINT FK_Mensajes_Emisor FOREIGN KEY (EmisorUsuarioId) REFERENCES UsuariosSistema(UsuarioId),
    CONSTRAINT FK_Mensajes_Receptor FOREIGN KEY (ReceptorUsuarioId) REFERENCES UsuariosSistema(UsuarioId)
);

-- Tabla para hilos de conversación (opcional, para mensajes encadenados)
CREATE TABLE Conversaciones (
    ConversacionId INT PRIMARY KEY IDENTITY,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    UltimoMensaje DATETIME,
    Activa BIT DEFAULT 1
);

CREATE TABLE ParticipantesConversacion (
    ParticipanteId INT PRIMARY KEY IDENTITY,
    ConversacionId INT NOT NULL,
    UsuarioId INT NOT NULL,
    FechaUnion DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ConversacionId) REFERENCES Conversaciones(ConversacionId),
    FOREIGN KEY (UsuarioId) REFERENCES UsuariosSistema(UsuarioId)
);

-- ============================================================
-- 5. ÍNDICES PARA OPTIMIZACIÓN
-- ============================================================

-- Índices para consultas frecuentes
CREATE INDEX IX_Asistencia_Estudiante ON Asistencia(EstudianteId);
CREATE INDEX IX_Asistencia_Sesion ON Asistencia(SesionId);
CREATE INDEX IX_Sesiones_Fecha ON Sesiones(Fecha);
CREATE INDEX IX_Alertas_Estudiante ON Alertas(EstudianteId);
CREATE INDEX IX_Alertas_Tipo ON Alertas(TipoAlertaId);
CREATE INDEX IX_Alertas_Estado ON Alertas(EstadoAlertaId);
CREATE INDEX IX_Notas_Estudiante ON Notas(EstudianteId);
CREATE INDEX IX_Notas_Examen ON Notas(ExamenId);
CREATE INDEX IX_Mensajes_Emisor ON Mensajes(EmisorUsuarioId);
CREATE INDEX IX_Mensajes_Receptor ON Mensajes(ReceptorUsuarioId);
CREATE INDEX IX_Logs_Usuario ON Logs(UsuarioId);
CREATE INDEX IX_Logs_Fecha ON Logs(FechaHora);

-- ============================================================
-- 6. LIMPIEZA DE COLUMNAS OBSOLETAS (OPCIONAL)
-- ============================================================

-- Después de verificar que la migración fue exitosa, puedes eliminar las columnas antiguas:
/*
ALTER TABLE Asistencia DROP COLUMN EstadoAsistencia;
ALTER TABLE Examenes DROP COLUMN TipoExamen;
ALTER TABLE Alertas DROP COLUMN TipoAlerta;
ALTER TABLE Alertas DROP COLUMN Estado;
ALTER TABLE MaterialesCurso DROP COLUMN TipoRecurso;
ALTER TABLE Estudiantes DROP COLUMN Estado;
ALTER TABLE Docentes DROP COLUMN Estado;
*/

-- ============================================================
-- 7. VISTAS ÚTILES PARA EL SISTEMA
-- ============================================================

-- Vista de asistencia detallada
CREATE VIEW vw_AsistenciaDetallada AS
SELECT 
    a.AsistenciaId,
    e.Nombre + ' ' + e.Apellido AS NombreEstudiante,
    e.Correo AS CorreoEstudiante,
    g.NombreGrupo,
    asig.NombreAsignatura,
    s.Fecha AS FechaSesion,
    s.HoraInicio,
    s.HoraFin,
    cea.Nombre AS EstadoAsistencia,
    cea.Color AS ColorEstado,
    a.Observacion
FROM Asistencia a
INNER JOIN Estudiantes e ON a.EstudianteId = e.EstudianteId
INNER JOIN Sesiones s ON a.SesionId = s.SesionId
INNER JOIN GrupoAsignatura ga ON s.GrupoAsignaturaId = ga.GrupoAsignaturaId
INNER JOIN Grupos g ON ga.GrupoId = g.GrupoId
INNER JOIN Asignaturas asig ON ga.AsignaturaId = asig.AsignaturaId
LEFT JOIN CatalogoEstadoAsistencia cea ON a.EstadoAsistenciaId = cea.EstadoAsistenciaId;

-- Vista de alertas activas
CREATE VIEW vw_AlertasActivas AS
SELECT 
    al.AlertaId,
    e.Nombre + ' ' + e.Apellido AS NombreEstudiante,
    g.NombreGrupo,
    cta.Nombre AS TipoAlerta,
    cta.NivelSeveridad,
    cta.Color AS ColorAlerta,
    cea.Nombre AS EstadoAlerta,
    al.Descripcion,
    al.FechaRegistro
FROM Alertas al
INNER JOIN Estudiantes e ON al.EstudianteId = e.EstudianteId
INNER JOIN CatalogoTipoAlerta cta ON al.TipoAlertaId = cta.TipoAlertaId
INNER JOIN CatalogoEstadoAlerta cea ON al.EstadoAlertaId = cea.EstadoAlertaId
LEFT JOIN EstudianteGrupo eg ON e.EstudianteId = eg.EstudianteId
LEFT JOIN Grupos g ON eg.GrupoId = g.GrupoId
WHERE al.EstadoAlertaId IN (1, 2); -- Pendiente o En Proceso

-- Vista de rendimiento académico
CREATE VIEW vw_RendimientoAcademico AS
SELECT 
    e.EstudianteId,
    e.Nombre + ' ' + e.Apellido AS NombreEstudiante,
    g.NombreGrupo,
    asig.NombreAsignatura,
    COUNT(DISTINCT n.NotaId) AS TotalExamenes,
    AVG(n.PuntosObtenidos) AS PromedioNotas,
    SUM(CASE WHEN cea.Codigo = 'AUSENTE' THEN 1 ELSE 0 END) AS TotalAusencias,
    SUM(CASE WHEN cea.Codigo = 'TARDANZA' THEN 1 ELSE 0 END) AS TotalTardanzas
FROM Estudiantes e
INNER JOIN EstudianteGrupo eg ON e.EstudianteId = eg.EstudianteId
INNER JOIN Grupos g ON eg.GrupoId = g.GrupoId
INNER JOIN GrupoAsignatura ga ON g.GrupoId = ga.GrupoId
INNER JOIN Asignaturas asig ON ga.AsignaturaId = asig.AsignaturaId
LEFT JOIN Notas n ON e.EstudianteId = n.EstudianteId
LEFT JOIN Asistencia a ON e.EstudianteId = a.EstudianteId
LEFT JOIN CatalogoEstadoAsistencia cea ON a.EstadoAsistenciaId = cea.EstadoAsistenciaId
GROUP BY e.EstudianteId, e.Nombre, e.Apellido, g.NombreGrupo, asig.NombreAsignatura;

GO

PRINT 'Normalización completada exitosamente';
PRINT 'Tablas de catálogo creadas: 6';
PRINT 'Índices creados: 9';
PRINT 'Vistas creadas: 3';
