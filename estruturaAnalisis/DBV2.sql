CREATE DATABASE SistemaEducativoCompleto;
GO

USE SistemaEducativoCompleto;
GO

-- 1. TABLAS CATÁLOGO (Para normalizar estados y tipos)
CREATE TABLE TiposAsistencia (
    TipoAsistenciaId INT PRIMARY KEY IDENTITY,
    Nombre VARCHAR(50) NOT NULL UNIQUE, -- 'Presente', 'Ausente', 'Tarde', 'Justificada'
    ValorPonderacion DECIMAL(3,2) DEFAULT 1.0 -- Por si la asistencia cuenta para la nota
);

CREATE TABLE RolesSistema (
    RolId INT PRIMARY KEY IDENTITY,
    NombreRol VARCHAR(50) NOT NULL UNIQUE, -- 'Admin', 'Docente', 'Estudiante'
    Descripcion VARCHAR(200)
);

-- 2. ENTIDADES PRINCIPALES
CREATE TABLE Estudiantes (
    EstudianteId INT PRIMARY KEY IDENTITY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Correo VARCHAR(254) UNIQUE, -- 254 es el estándar máximo para emails
    Telefono VARCHAR(20),
    FechaNacimiento DATE, -- Dato útil
    Estado BIT DEFAULT 1,
    FechaRegistro DATETIME DEFAULT GETDATE()
);

CREATE TABLE Docentes (
    DocenteId INT PRIMARY KEY IDENTITY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Correo VARCHAR(254) UNIQUE,
    Telefono VARCHAR(20),
    Especialidad VARCHAR(100),
    Estado BIT DEFAULT 1
);

CREATE TABLE Grupos (
    GrupoId INT PRIMARY KEY IDENTITY,
    NombreGrupo VARCHAR(100) NOT NULL,
    NivelAcademico VARCHAR(50), -- 'Primaria', 'Secundaria', 'Universidad'
    AnoLectivo INT NOT NULL, -- Importante para separar cursos de diferentes años
    Descripcion VARCHAR(300)
);

CREATE TABLE Asignaturas (
    AsignaturaId INT PRIMARY KEY IDENTITY,
    NombreAsignatura VARCHAR(150) NOT NULL,
    CodigoAsignatura VARCHAR(20) UNIQUE, -- Ej: MAT-101
    Descripcion VARCHAR(300)
);

-- 3. RELACIONES ACADÉMICAS
CREATE TABLE GrupoAsignatura (
    GrupoAsignaturaId INT PRIMARY KEY IDENTITY,
    GrupoId INT NOT NULL,
    AsignaturaId INT NOT NULL,
    DocenteId INT NOT NULL,
    AnoLectivo INT NOT NULL, -- Para saber a qué año corresponde esta asignación
    CONSTRAINT UQ_GrupoAsignatura UNIQUE (GrupoId, AsignaturaId, AnoLectivo), -- Evita duplicados en el mismo año
    FOREIGN KEY (GrupoId) REFERENCES Grupos(GrupoId),
    FOREIGN KEY (AsignaturaId) REFERENCES Asignaturas(AsignaturaId),
    FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId)
);

CREATE TABLE EstudianteGrupo (
    EstudianteGrupoId INT PRIMARY KEY IDENTITY,
    EstudianteId INT NOT NULL,
    GrupoId INT NOT NULL,
    FechaRegistro DATE DEFAULT GETDATE(),
    FechaRetiro DATE NULL, -- NULL significa que aún está activo
    Estado BIT DEFAULT 1,
    FOREIGN KEY (EstudianteId) REFERENCES Estudiantes(EstudianteId),
    FOREIGN KEY (GrupoId) REFERENCES Grupos(GrupoId)
);

-- 4. SESIONES Y ASISTENCIA
CREATE TABLE Sesiones (
    SesionId INT PRIMARY KEY IDENTITY,
    GrupoAsignaturaId INT NOT NULL,
    Fecha DATE NOT NULL,
    HoraInicio TIME NOT NULL,
    HoraFin TIME NOT NULL,
    Tema VARCHAR(200),
    LinkVideollamada VARCHAR(500),
    FOREIGN KEY (GrupoAsignaturaId) REFERENCES GrupoAsignatura(GrupoAsignaturaId)
);

CREATE TABLE Asistencia (
    AsistenciaId INT PRIMARY KEY IDENTITY,
    EstudianteId INT NOT NULL,
    SesionId INT NOT NULL,
    TipoAsistenciaId INT NOT NULL, -- FK a tabla catálogo
    Observacion VARCHAR(300),
    FechaRegistro DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_Asistencia UNIQUE (EstudianteId, SesionId), -- Un alumno solo 1 registro por sesión
    FOREIGN KEY (EstudianteId) REFERENCES Estudiantes(EstudianteId),
    FOREIGN KEY (SesionId) REFERENCES Sesiones(SesionId),
    FOREIGN KEY (TipoAsistenciaId) REFERENCES TiposAsistencia(TipoAsistenciaId)
);

-- 5. EVALUACIONES UNIFICADAS (Normalización 3NF)
-- Fusiona Examenes y Actividades Complementarias
CREATE TABLE TiposEvaluacion (
    TipoEvaluacionId INT PRIMARY KEY IDENTITY,
    Nombre VARCHAR(50) NOT NULL -- 'Examen Parcial', 'Tarea', 'Proyecto', 'Quiz'
);

CREATE TABLE Evaluaciones (
    EvaluacionId INT PRIMARY KEY IDENTITY,
    GrupoAsignaturaId INT NOT NULL,
    TipoEvaluacionId INT NOT NULL,
    Titulo VARCHAR(150) NOT NULL,
    Descripcion VARCHAR(500),
    FechaEntrega DATETIME NOT NULL, -- Unifica FechaExamen y FechaEntrega
    PuntajeMaximo DECIMAL(5,2) NOT NULL,
    PesoPorcentual DECIMAL(5,2) DEFAULT 0, -- Cuánto vale esto en la nota final
    FOREIGN KEY (GrupoAsignaturaId) REFERENCES GrupoAsignatura(GrupoAsignaturaId),
    FOREIGN KEY (TipoEvaluacionId) REFERENCES TiposEvaluacion(TipoEvaluacionId)
);

CREATE TABLE Notas (
    NotaId INT PRIMARY KEY IDENTITY,
    EvaluacionId INT NOT NULL,
    EstudianteId INT NOT NULL,
    PuntajeObtenido DECIMAL(5,2) NOT NULL,
    FechaRegistro DATETIME DEFAULT GETDATE(),
    ComentarioDocente VARCHAR(300),
    CONSTRAINT UQ_Nota UNIQUE (EvaluacionId, EstudianteId), -- Un alumno solo 1 nota por evaluación
    FOREIGN KEY (EvaluacionId) REFERENCES Evaluaciones(EvaluacionId),
    FOREIGN KEY (EstudianteId) REFERENCES Estudiantes(EstudianteId)
);

-- 6. SISTEMA Y COMUNICACIÓN
CREATE TABLE UsuariosSistema (
    UsuarioId INT PRIMARY KEY IDENTITY,
    NombreUsuario VARCHAR(50) UNIQUE NOT NULL,
    ContrasenaHash VARCHAR(500) NOT NULL,
    EstudianteId INT NULL,
    DocenteId INT NULL,
    RolId INT NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    UltimaConexion DATETIME NULL,
    -- Restricción para asegurar coherencia (simplificada)
    CONSTRAINT CHK_Usuario_Rol CHECK (
        (RolId = 1 AND EstudianteId IS NULL AND DocenteId IS NULL) OR -- Admin
        (RolId = 2 AND DocenteId IS NOT NULL AND EstudianteId IS NULL) OR -- Docente
        (RolId = 3 AND EstudianteId IS NOT NULL AND DocenteId IS NULL) -- Estudiante
    ),
    FOREIGN KEY (EstudianteId) REFERENCES Estudiantes(EstudianteId),
    FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId),
    FOREIGN KEY (RolId) REFERENCES RolesSistema(RolId)
);

CREATE TABLE Mensajes (
    MensajeId INT PRIMARY KEY IDENTITY,
    EmisorId INT NOT NULL, -- Apunta al UsuarioSistema
    ReceptorId INT NOT NULL, -- Apunta al UsuarioSistema
    Contenido VARCHAR(MAX) NOT NULL,
    FechaEnvio DATETIME DEFAULT GETDATE(),
    Leido BIT DEFAULT 0,
    FOREIGN KEY (EmisorId) REFERENCES UsuariosSistema(UsuarioId),
    FOREIGN KEY (ReceptorId) REFERENCES UsuariosSistema(UsuarioId)
);

CREATE TABLE MaterialesCurso (
    MaterialId INT PRIMARY KEY IDENTITY,
    GrupoAsignaturaId INT NOT NULL,
    Titulo VARCHAR(150),
    LinkRecurso VARCHAR(500),
    TipoRecurso VARCHAR(50),
    FechaSubida DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (GrupoAsignaturaId) REFERENCES GrupoAsignatura(GrupoAsignaturaId)
);

CREATE TABLE Logs (
    LogId INT PRIMARY KEY IDENTITY,
    UsuarioId INT NOT NULL,
    Actividad VARCHAR(300),
    IpOrigen VARCHAR(45), -- Útil para seguridad
    FechaHora DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UsuarioId) REFERENCES UsuariosSistema(UsuarioId)
);

-- 7. ÍNDICES DE RENDIMIENTO (Muy importante en SQL Server)
-- SQL Server no indexa automáticamente las FKs
CREATE INDEX IX_EstudianteGrupo_Estudiante ON EstudianteGrupo(EstudianteId);
CREATE INDEX IX_EstudianteGrupo_Grupo ON EstudianteGrupo(GrupoId);
CREATE INDEX IX_Sesiones_GrupoAsignatura ON Sesiones(GrupoAsignaturaId);
CREATE INDEX IX_Asistencia_Sesion ON Asistencia(SesionId);
CREATE INDEX IX_Notas_Evaluacion ON Notas(EvaluacionId);
CREATE INDEX IX_Usuarios_Rol ON UsuariosSistema(RolId);
GO