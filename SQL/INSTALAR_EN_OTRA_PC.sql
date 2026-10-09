-- GESTIÓN CINE V2.3 - instalación en una instancia nueva de SQL Server.
-- Ejecutar el archivo COMPLETO en SSMS sobre la instancia que usará la aplicación.
-- Este archivo conserva una base ya existente y sus registros; no crea usuarios SQL.
-- El primer administrador se crea desde la pantalla de ingreso de C# (admin, clave nueva de 8+).

-- Nueva instalación o reapertura segura. No borra la base ni sus registros.
USE master;
GO

IF DB_ID('GestionCineDB') IS NULL
    EXEC(N'CREATE DATABASE GestionCineDB');
GO

USE GestionCineDB;
GO

/* =========================================================
   1. TABLA GENERO
   ========================================================= */
IF OBJECT_ID('dbo.Genero','U') IS NULL
CREATE TABLE Genero (
    GeneroId INT IDENTITY (1, 1) PRIMARY KEY,
    Nombre VARCHAR (50) NOT NULL UNIQUE,
    Descripcion VARCHAR (150)
);


GO
/* =========================================================
   2. TABLA PELICULA
   ========================================================= */
IF OBJECT_ID('dbo.Pelicula','U') IS NULL
CREATE TABLE Pelicula (
    PeliculaId INT IDENTITY (1, 1) PRIMARY KEY,
    Titulo VARCHAR (100) NOT NULL,
    DuracionMinutos INT NOT NULL,
    Clasificacion VARCHAR (10) NOT NULL,
    FechaEstreno DATE,
    Director VARCHAR (100),
    GeneroId INT NOT NULL,
    Estado VARCHAR (20) DEFAULT 'ACTIVA' NOT NULL,
    CONSTRAINT FK_Pelicula_Genero FOREIGN KEY (GeneroId) REFERENCES Genero (GeneroId)
);


GO
/* =========================================================
   3. TABLA SALA
   ========================================================= */
IF OBJECT_ID('dbo.Sala','U') IS NULL
CREATE TABLE Sala (
    SalaId INT IDENTITY (1, 1) PRIMARY KEY,
    NumeroSala INT NOT NULL UNIQUE,
    Nombre VARCHAR (50) NOT NULL,
    TipoSala VARCHAR (20) NOT NULL,
    CapacidadTotal INT NOT NULL,
    Activo BIT DEFAULT 1 NOT NULL,
    CONSTRAINT CK_Sala_Tipo CHECK (TipoSala IN ('ESTANDAR', 'VIP', 'IMAX', '3D', '4DX'))
);


GO
/* =========================================================
   4. TABLA BUTACA
   ========================================================= */
IF OBJECT_ID('dbo.Butaca','U') IS NULL
CREATE TABLE Butaca (
    ButacaId INT IDENTITY (1, 1) PRIMARY KEY,
    SalaId INT NOT NULL,
    Fila VARCHAR (5) NOT NULL,
    Numero INT NOT NULL,
    TipoButaca VARCHAR (20) DEFAULT 'NORMAL' NOT NULL,
    PrecioExtra DECIMAL (10, 2) DEFAULT 0 NOT NULL,
    Activo BIT DEFAULT 1 NOT NULL,
    CONSTRAINT FK_Butaca_Sala FOREIGN KEY (SalaId) REFERENCES Sala (SalaId),
    CONSTRAINT CK_Butaca_Tipo CHECK (TipoButaca IN ('NORMAL', 'VIP', 'DISCAPACIDAD', 'PAREJA')),
    CONSTRAINT UQ_Butaca UNIQUE (SalaId, Fila, Numero)
);


GO
/* =========================================================
   5. TABLA FUNCION
   ========================================================= */
IF OBJECT_ID('dbo.Funcion','U') IS NULL
CREATE TABLE Funcion (
    FuncionId INT IDENTITY (1, 1) PRIMARY KEY,
    PeliculaId INT NOT NULL,
    SalaId INT NOT NULL,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Formato VARCHAR (10) DEFAULT '2D' NOT NULL,
    PrecioBase DECIMAL (10, 2) NOT NULL,
    Activo BIT DEFAULT 1 NOT NULL,
    CONSTRAINT FK_Funcion_Pelicula FOREIGN KEY (PeliculaId) REFERENCES Pelicula (PeliculaId),
    CONSTRAINT FK_Funcion_Sala FOREIGN KEY (SalaId) REFERENCES Sala (SalaId),
    CONSTRAINT CK_Funcion_Formato CHECK (Formato IN ('2D', '3D', 'IMAX', '4DX'))
);


GO
/* =========================================================
   6. TABLA CLIENTE
   ========================================================= */
IF OBJECT_ID('dbo.Cliente','U') IS NULL
CREATE TABLE Cliente (
    ClienteId INT IDENTITY (1, 1) PRIMARY KEY,
    Nombre VARCHAR (50) NOT NULL,
    Apellido VARCHAR (50) NOT NULL,
    Correo VARCHAR (100) NOT NULL UNIQUE,
    Telefono VARCHAR (20),
    FechaNacimiento DATE,
    Activo BIT DEFAULT 1 NOT NULL
);


GO
/* =========================================================
   7. TABLA EMPLEADO
   ========================================================= */
IF OBJECT_ID('dbo.Empleado','U') IS NULL
CREATE TABLE Empleado (
    EmpleadoId INT IDENTITY (1, 1) PRIMARY KEY,
    Nombre VARCHAR (50) NOT NULL,
    Apellido VARCHAR (50) NOT NULL,
    Cargo VARCHAR (50) NOT NULL,
    Area VARCHAR (50) NOT NULL,
    Correo VARCHAR (100) NOT NULL UNIQUE,
    Telefono VARCHAR (20),
    FechaContratacion DATE NOT NULL,
    Activo BIT DEFAULT 1 NOT NULL
);


GO
/* =========================================================
   8. TABLA PRODUCTO
   ========================================================= */
IF OBJECT_ID('dbo.Producto','U') IS NULL
CREATE TABLE Producto (
    ProductoId INT IDENTITY (1, 1) PRIMARY KEY,
    Nombre VARCHAR (100) NOT NULL,
    Categoria VARCHAR (30) NOT NULL,
    Precio DECIMAL (10, 2) NOT NULL,
    Stock INT DEFAULT 0 NOT NULL,
    Descripcion VARCHAR (200),
    Activo BIT DEFAULT 1 NOT NULL,
    CONSTRAINT CK_Producto_Categoria CHECK (Categoria IN ('PALOMITAS', 'BEBIDA', 'COMIDA', 'DULCE', 'COMBO'))
);


GO
/* =========================================================
   9. TABLA VENTA
   ========================================================= */
IF OBJECT_ID('dbo.Venta','U') IS NULL
CREATE TABLE Venta (
    VentaId INT IDENTITY (1, 1) PRIMARY KEY,
    ClienteId INT NOT NULL,
    EmpleadoId INT NOT NULL,
    FuncionId INT NULL,
    ButacaId INT NULL,
    ProductoId INT NULL,
    CantidadBoletos INT DEFAULT 0 NOT NULL,
    CantidadProducto INT DEFAULT 0 NOT NULL,
    Subtotal DECIMAL (10, 2) NOT NULL,
    Impuesto DECIMAL (10, 2) NOT NULL,
    Total DECIMAL (10, 2) NOT NULL,
    FormaPago VARCHAR (30) NOT NULL,
    ReferenciaPago VARCHAR (100),
    FechaVenta DATETIME DEFAULT GETDATE() NOT NULL,
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (ClienteId) REFERENCES Cliente (ClienteId),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (EmpleadoId) REFERENCES Empleado (EmpleadoId),
    CONSTRAINT FK_Venta_Funcion FOREIGN KEY (FuncionId) REFERENCES Funcion (FuncionId),
    CONSTRAINT FK_Venta_Butaca FOREIGN KEY (ButacaId) REFERENCES Butaca (ButacaId),
    CONSTRAINT FK_Venta_Producto FOREIGN KEY (ProductoId) REFERENCES Producto (ProductoId),
    CONSTRAINT CK_Venta_FormaPago CHECK (FormaPago IN ('EFECTIVO', 'TARJETA_CREDITO', 'TARJETA_DEBITO', 'TRANSFERENCIA', 'PAGO_QR', 'GIFT_CARD'))
);


/* =========================================================
   DATOS DE GENERO
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Genero)
INSERT INTO Genero
(Nombre, Descripcion)
VALUES
('Romance', 'Peliculas de romance'),
('Comedia', 'Peliculas de comedia'),
('Animacion', 'Peliculas animadas'),
('Accion', 'Peliculas de accion'),
('Drama', 'Peliculas dramaticas'),
('Musical', 'Peliculas musicales');
GO


/* =========================================================
   DATOS DE PELICULAS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Pelicula)
INSERT INTO Pelicula
(Titulo, DuracionMinutos, Clasificacion,
 FechaEstreno, Director, GeneroId)
VALUES
('Mujer Bonita', 119, 'T12',
 '1990-03-23', 'Garry Marshall', 1),

('CJ7', 88, 'ATP',
 '2008-01-31', 'Stephen Chow', 2),

('El Principito', 108, 'ATP',
 '2015-10-29', 'Mark Osborne', 3),

('Spiderman', 121, 'T12',
 '2002-05-03', 'Sam Raimi', 4),

('El Diablo Viste a la Moda', 109, 'T12',
 '2006-06-30', 'David Frankel', 5),

('Michael Jackson', 120, 'ATP',
 '2009-10-28', 'Michael Jackson', 6);
GO


/* =========================================================
   DATOS DE SALAS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Sala)
INSERT INTO Sala
(NumeroSala, Nombre, TipoSala, CapacidadTotal)
VALUES
(1, 'Sala 1', 'ESTANDAR', 40),
(2, 'Sala 2', 'ESTANDAR', 40),
(3, 'Sala 3', 'VIP', 30),
(4, 'Sala 4', 'IMAX', 50),
(5, 'Sala 5', '3D', 40);
GO


/* =========================================================
   DATOS DE BUTACAS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Butaca)
INSERT INTO Butaca
(SalaId, Fila, Numero, TipoButaca, PrecioExtra)
VALUES
(1, 'A', 1, 'NORMAL', 0),
(1, 'A', 2, 'NORMAL', 0),
(1, 'A', 3, 'NORMAL', 0),
(1, 'A', 4, 'NORMAL', 0),
(1, 'A', 5, 'NORMAL', 0),

(2, 'A', 1, 'NORMAL', 0),
(2, 'A', 2, 'NORMAL', 0),
(2, 'A', 3, 'NORMAL', 0),
(2, 'A', 4, 'NORMAL', 0),
(2, 'A', 5, 'NORMAL', 0),

(3, 'A', 1, 'VIP', 2.00),
(3, 'A', 2, 'VIP', 2.00),
(3, 'A', 3, 'VIP', 2.00),
(3, 'A', 4, 'VIP', 2.00),
(3, 'A', 5, 'VIP', 2.00);
GO


/* =========================================================
   DATOS DE FUNCIONES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Funcion)
INSERT INTO Funcion
(PeliculaId, SalaId, Fecha, Hora, Formato, PrecioBase)
VALUES

(1, 1, '2026-09-08', '14:00', '2D', 5.00),
(1, 1, '2026-09-08', '17:00', '2D', 5.00),
(1, 1, '2026-09-08', '20:00', '2D', 5.00),

(2, 2, '2026-09-08', '13:00', '2D', 5.00),
(2, 2, '2026-09-08', '16:00', '2D', 5.00),
(2, 2, '2026-09-08', '19:00', '2D', 5.00),

(3, 3, '2026-09-08', '12:00', '2D', 7.00),
(3, 3, '2026-09-08', '15:00', '2D', 7.00),
(3, 3, '2026-09-08', '18:00', '2D', 7.00),

(4, 4, '2026-09-08', '14:30', 'IMAX', 8.00),
(4, 4, '2026-09-08', '17:30', 'IMAX', 8.00),
(4, 4, '2026-09-08', '20:30', 'IMAX', 8.00),

(5, 1, '2026-09-08', '15:00', '2D', 5.00),
(5, 1, '2026-09-08', '18:00', '2D', 5.00),
(5, 1, '2026-09-08', '21:00', '2D', 5.00),

(6, 2, '2026-09-08', '13:30', '2D', 5.00),
(6, 2, '2026-09-08', '16:30', '2D', 5.00),
(6, 2, '2026-09-08', '19:30', '2D', 5.00);
GO


/* =========================================================
   DATOS DE CLIENTES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Cliente)
INSERT INTO Cliente
(Nombre, Apellido, Correo, Telefono, FechaNacimiento)
VALUES
('Lesther', 'Martinez',
 'lesthermartinez@gmail.com', '8888-1001', '2000-05-10'),

('Mauricio', 'Putoy',
 'mauricioputoy@gmail.com', '8888-1002', '1999-08-15'),

('Kevin', 'Useda',
 'kevinuseda@gmail.com', '8888-1003', '2001-02-20'),

('Solange', 'Putoy',
 'solangeputoy@gmail.com', '8888-1004', '2000-11-12'),

('Francheska', 'Molina',
 'francheskamolina@gmail.com', '8888-1005', '2002-04-18'),

('Arlen', 'Martinez',
 'arlenmartinez@gmail.com', '8888-1006', '1998-09-25');
GO


/* =========================================================
   DATOS DE EMPLEADOS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Empleado)
INSERT INTO Empleado
(Nombre, Apellido, Cargo, Area, Correo,
 Telefono, FechaContratacion)
VALUES
('Karen', 'Gomez',
 'Limpieza', 'Salas y baños',
 'karengomez@gmail.com', '8888-2001', '2025-01-10'),

('Dilan', 'Lopez',
 'Limpieza', 'Salas y baños',
 'dilanlopez@gmail.com', '8888-2002', '2025-02-15'),

('Fernanda', 'Soto',
 'Cajera', 'Taquilla y confiteria',
 'fernandasoto@gmail.com', '8888-2003', '2025-03-20'),

('Tonny', 'Medina',
 'Cajero', 'Taquilla y confiteria',
 'tonnymedina@gmail.com', '8888-2004', '2025-04-05');
GO


/* =========================================================
   DATOS DE PRODUCTOS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Producto)
INSERT INTO Producto
(Nombre, Categoria, Precio, Stock, Descripcion)
VALUES
('Palomitas Pequeñas', 'PALOMITAS',
 2.50, 50, 'Palomitas tamaño pequeño'),

('Palomitas Medianas', 'PALOMITAS',
 3.50, 50, 'Palomitas tamaño mediano'),

('Palomitas Grandes', 'PALOMITAS',
 5.00, 40, 'Palomitas tamaño grande'),

('Gaseosa Pequeña', 'BEBIDA',
 1.50, 80, 'Gaseosa tamaño pequeño'),

('Gaseosa Mediana', 'BEBIDA',
 2.00, 70, 'Gaseosa tamaño mediano'),

('Gaseosa Grande', 'BEBIDA',
 2.50, 60, 'Gaseosa tamaño grande'),

('Agua', 'BEBIDA',
 1.00, 100, 'Botella de agua'),

('Nachos', 'COMIDA',
 3.50, 40, 'Nachos con queso'),

('Hot Dog', 'COMIDA',
 4.00, 30, 'Hot dog preparado'),

('Chocolate', 'DULCE',
 2.00, 40, 'Chocolate'),

('Dulces', 'DULCE',
 1.50, 50, 'Dulces variados'),

('Combo Cine 1', 'COMBO',
 7.00, 30, 'Palomitas medianas y gaseosa mediana');
GO


/* =========================================================
   DATOS DE VENTAS
   IMPUESTO DEL 15%
   ========================================================= */

-- Venta 1: boleto
IF NOT EXISTS (SELECT 1 FROM dbo.Venta WHERE VentaId=1)
INSERT INTO Venta
(ClienteId, EmpleadoId, FuncionId, ButacaId,
 ProductoId, CantidadBoletos, CantidadProducto,
 Subtotal, Impuesto, Total, FormaPago, ReferenciaPago)
VALUES
(1, 3, 1, 1,
 NULL, 1, 0,
 5.00, 0.75, 5.75,
 'EFECTIVO', NULL);
GO


-- Venta 2: producto
IF NOT EXISTS (SELECT 1 FROM dbo.Venta WHERE VentaId=2)
INSERT INTO Venta
(ClienteId, EmpleadoId, FuncionId, ButacaId,
 ProductoId, CantidadBoletos, CantidadProducto,
 Subtotal, Impuesto, Total, FormaPago, ReferenciaPago)
VALUES
(2, 4, NULL, NULL,
 1, 0, 1,
 2.50, 0.38, 2.88,
 'EFECTIVO', NULL);
GO


-- Venta 3: boleto + producto
IF NOT EXISTS (SELECT 1 FROM dbo.Venta WHERE VentaId=3)
INSERT INTO Venta
(ClienteId, EmpleadoId, FuncionId, ButacaId,
 ProductoId, CantidadBoletos, CantidadProducto,
 Subtotal, Impuesto, Total, FormaPago, ReferenciaPago)
VALUES
(3, 3, 1, 2,
 2, 1, 1,
 8.50, 1.28, 9.78,
 'TARJETA_DEBITO', 'TXN-0003');
GO


/* =========================================================
   CONSULTAS DE COMPROBACION
   ========================================================= */

SELECT * FROM Genero;
GO

SELECT * FROM Pelicula;
GO

SELECT * FROM Sala;
GO

SELECT * FROM Butaca;
GO

SELECT * FROM Funcion;
GO

SELECT * FROM Cliente;
GO

SELECT * FROM Empleado;
GO

SELECT * FROM Producto;
GO

SELECT * FROM Venta;
GO


/* =========================================================
   CONSULTA GENERAL
   MUESTRA LAS TABLAS RELACIONADAS
   ========================================================= */

SELECT
    V.VentaId,
    C.Nombre + ' ' + C.Apellido AS Cliente,
    P.Titulo AS Pelicula,
    S.Nombre AS Sala,
    F.Hora,
    E.Nombre + ' ' + E.Apellido AS Empleado,
    PR.Nombre AS Producto,
    V.CantidadBoletos,
    V.CantidadProducto,
    V.Subtotal,
    V.Impuesto,
    V.Total,
    V.FormaPago,
    V.FechaVenta

FROM Venta V

INNER JOIN Cliente C
    ON V.ClienteId = C.ClienteId

LEFT JOIN Funcion F
    ON V.FuncionId = F.FuncionId

LEFT JOIN Pelicula P
    ON F.PeliculaId = P.PeliculaId

LEFT JOIN Sala S
    ON F.SalaId = S.SalaId

INNER JOIN Empleado E
    ON V.EmpleadoId = E.EmpleadoId

LEFT JOIN Producto PR
    ON V.ProductoId = PR.ProductoId;
GO

/* =========================================================
   PROCEDIMIENTOS ALMACENADOS (NUEVA SECCIÓN REQUERIDA)
   ========================================================= */

-- 1. PELICULA: Insertar y Obtener
GO
CREATE OR ALTER PROCEDURE sp_ObtenerPeliculas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.PeliculaId, p.Titulo, p.DuracionMinutos, p.Clasificacion, 
           p.FechaEstreno, p.Director, g.Nombre AS Genero, p.Estado
    FROM Pelicula p
    INNER JOIN Genero g ON p.GeneroId = g.GeneroId
    ORDER BY p.PeliculaId DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertarPelicula
    @Titulo VARCHAR(100),
    @DuracionMinutos INT,
    @Clasificacion VARCHAR(10),
    @FechaEstreno DATE,
    @Director VARCHAR(100),
    @GeneroId INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Pelicula (Titulo, DuracionMinutos, Clasificacion, FechaEstreno, Director, GeneroId)
    VALUES (@Titulo, @DuracionMinutos, @Clasificacion, @FechaEstreno, @Director, @GeneroId);
END;
GO

-- 2. CLIENTE: Insertar, Obtener y Eliminar (Lógico)
CREATE OR ALTER PROCEDURE sp_ObtenerClientes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ClienteId, Nombre, Apellido, Correo, Telefono, FechaNacimiento, Activo
    FROM Cliente
    WHERE Activo = 1
    ORDER BY ClienteId DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertarCliente
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @Correo VARCHAR(100),
    @Telefono VARCHAR(20),
    @FechaNacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Cliente (Nombre, Apellido, Correo, Telefono, FechaNacimiento)
    VALUES (@Nombre, @Apellido, @Correo, @Telefono, @FechaNacimiento);
END;
GO

CREATE OR ALTER PROCEDURE sp_EliminarClienteLogic
    @ClienteId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Cliente SET Activo = 0 WHERE ClienteId = @ClienteId;
END;
GO

-- 3. PRODUCTO: Obtener e Insertar
CREATE OR ALTER PROCEDURE sp_ObtenerProductos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductoId, Nombre, Categoria, Precio, Stock, Descripcion, Activo
    FROM Producto
    WHERE Activo = 1
    ORDER BY ProductoId;
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertarProducto
    @Nombre VARCHAR(100),
    @Categoria VARCHAR(30),
    @Precio DECIMAL(10,2),
    @Stock INT,
    @Descripcion VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Producto (Nombre, Categoria, Precio, Stock, Descripcion)
    VALUES (@Nombre, @Categoria, @Precio, @Stock, @Descripcion);
END;
GO

-- 4. VENTA: Transacción Completa para Registrar Venta
CREATE OR ALTER PROCEDURE sp_RegistrarVenta
    @ClienteId INT,
    @EmpleadoId INT,
    @FuncionId INT = NULL,
    @ButacaId INT = NULL,
    @ProductoId INT = NULL,
    @CantidadBoletos INT = 0,
    @CantidadProducto INT = 0,
    @Subtotal DECIMAL(10,2),
    @Impuesto DECIMAL(10,2),
    @Total DECIMAL(10,2),
    @FormaPago VARCHAR(30),
    @ReferenciaPago VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insertar el registro de venta
        INSERT INTO Venta (ClienteId, EmpleadoId, FuncionId, ButacaId, ProductoId, 
                           CantidadBoletos, CantidadProducto, Subtotal, Impuesto, Total, FormaPago, ReferenciaPago)
        VALUES (@ClienteId, @EmpleadoId, @FuncionId, @ButacaId, @ProductoId, 
                @CantidadBoletos, @CantidadProducto, @Subtotal, @Impuesto, @Total, @FormaPago, @ReferenciaPago);

        -- Si se compró un producto con stock, descontar del inventario
        IF @ProductoId IS NOT NULL AND @CantidadProducto > 0
        BEGIN
            UPDATE Producto 
            SET Stock = Stock - @CantidadProducto 
            WHERE ProductoId = @ProductoId;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- MÓDULO PROFESIONAL, USUARIOS Y VENTA SEGURA
USE GestionCineDB;
GO
-- Ejecutar después del script 01 en una PC nueva.
-- También es seguro volver a ejecutarlo sobre GestionCineDB existente.
IF OBJECT_ID('dbo.UsuariosCine','U') IS NULL
BEGIN
    CREATE TABLE dbo.UsuariosCine (
        UsuarioId INT IDENTITY(1,1) PRIMARY KEY,
        Usuario NVARCHAR(60) NOT NULL UNIQUE,
        ClaveHash VARBINARY(64) NOT NULL,
        ClaveSalt VARBINARY(32) NOT NULL,
        Rol NVARCHAR(20) NOT NULL CONSTRAINT CK_UsuariosCine_Rol CHECK (Rol IN ('Administrador','Registro','Consulta')),
        Activo BIT NOT NULL CONSTRAINT DF_UsuariosCine_Activo DEFAULT 1,
        FechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_UsuariosCine_Fecha DEFAULT SYSDATETIME()
    );
END;
GO
-- Proteger ocupación de una butaca por función, incluidos los registros ya existentes.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Venta_Funcion_Butaca' AND object_id=OBJECT_ID('dbo.Venta'))
BEGIN
    IF EXISTS (SELECT FuncionId,ButacaId FROM dbo.Venta
               WHERE FuncionId IS NOT NULL AND ButacaId IS NOT NULL AND CantidadBoletos>0
               GROUP BY FuncionId,ButacaId HAVING COUNT(*)>1)
        PRINT 'Ya hay butacas duplicadas: revisalas antes de activar el índice.';
    ELSE
        CREATE UNIQUE INDEX UX_Venta_Funcion_Butaca ON dbo.Venta(FuncionId,ButacaId)
        WHERE FuncionId IS NOT NULL AND ButacaId IS NOT NULL AND CantidadBoletos>0;
END;
GO
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarVentaSegura
    @ClienteId INT, @EmpleadoId INT,
    @FuncionId INT=NULL, @ButacaId INT=NULL, @ProductoId INT=NULL,
    @CantidadBoletos INT=0, @CantidadProducto INT=0,
    @FormaPago VARCHAR(30), @ReferenciaPago VARCHAR(100)=NULL,
    @TotalCalculado DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    IF @CantidadBoletos NOT IN (0,1) OR @CantidadProducto<0 OR @CantidadBoletos+@CantidadProducto=0
        THROW 51000,'Debe vender al menos un artículo; cada boleto necesita su propia venta.',1;
    IF @CantidadBoletos=1 AND (@FuncionId IS NULL OR @ButacaId IS NULL)
        THROW 51001,'Seleccioná función y butaca.',1;
    IF @CantidadProducto>0 AND @ProductoId IS NULL
        THROW 51002,'Seleccioná un producto.',1;
    IF @FormaPago NOT IN ('EFECTIVO','TARJETA_CREDITO','TARJETA_DEBITO','TRANSFERENCIA','PAGO_QR','GIFT_CARD')
        THROW 51003,'Forma de pago no válida.',1;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS(SELECT 1 FROM dbo.Cliente WHERE ClienteId=@ClienteId AND Activo=1)
            THROW 51004,'El cliente no está activo.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.Empleado WHERE EmpleadoId=@EmpleadoId AND Activo=1)
            THROW 51005,'El empleado no está activo.',1;

        DECLARE @PrecioBoleto DECIMAL(10,2)=0,@PrecioProducto DECIMAL(10,2)=0;
        IF @CantidadBoletos=1
        BEGIN
            SELECT @PrecioBoleto=f.PrecioBase+b.PrecioExtra
            FROM dbo.Funcion f WITH (UPDLOCK,HOLDLOCK)
            JOIN dbo.Pelicula p ON p.PeliculaId=f.PeliculaId
            JOIN dbo.Butaca b WITH (UPDLOCK,HOLDLOCK) ON b.SalaId=f.SalaId AND b.ButacaId=@ButacaId
            WHERE f.FuncionId=@FuncionId AND f.Activo=1 AND b.Activo=1 AND p.Estado='ACTIVA';
            IF @PrecioBoleto=0 THROW 51006,'La función o butaca no está disponible.',1;
            IF EXISTS(SELECT 1 FROM dbo.Venta WITH (UPDLOCK,HOLDLOCK)
                      WHERE FuncionId=@FuncionId AND ButacaId=@ButacaId AND CantidadBoletos>0)
                THROW 51007,'Esta butaca ya fue vendida para la función.',1;
        END
        IF @CantidadProducto>0
        BEGIN
            SELECT @PrecioProducto=Precio FROM dbo.Producto WITH (UPDLOCK,HOLDLOCK)
            WHERE ProductoId=@ProductoId AND Activo=1 AND Stock>=@CantidadProducto;
            IF @PrecioProducto=0 THROW 51008,'Producto agotado o inactivo.',1;
            UPDATE dbo.Producto SET Stock=Stock-@CantidadProducto WHERE ProductoId=@ProductoId;
        END
        DECLARE @Subtotal DECIMAL(10,2)=@CantidadBoletos*@PrecioBoleto+@CantidadProducto*@PrecioProducto;
        DECLARE @Impuesto DECIMAL(10,2)=ROUND(@Subtotal*0.15,2);
        SET @TotalCalculado=@Subtotal+@Impuesto;
        INSERT INTO dbo.Venta
          (ClienteId,EmpleadoId,FuncionId,ButacaId,ProductoId,CantidadBoletos,CantidadProducto,
           Subtotal,Impuesto,Total,FormaPago,ReferenciaPago)
        VALUES(@ClienteId,@EmpleadoId,CASE WHEN @CantidadBoletos=1 THEN @FuncionId END,
               CASE WHEN @CantidadBoletos=1 THEN @ButacaId END,
               CASE WHEN @CantidadProducto>0 THEN @ProductoId END,@CantidadBoletos,@CantidadProducto,
               @Subtotal,@Impuesto,@TotalCalculado,@FormaPago,@ReferenciaPago);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Confirmar las tablas en la instancia usada por la aplicación.
SELECT @@SERVERNAME AS Servidor, DB_NAME() AS BaseDatos, name AS Tabla FROM sys.tables ORDER BY name;
