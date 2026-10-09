USE master;
GO

IF DB_ID('GestionCineDB') IS NOT NULL
BEGIN
    ALTER DATABASE GestionCineDB
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE GestionCineDB;
END
GO

CREATE DATABASE GestionCineDB;
GO

USE GestionCineDB;
GO

/* =========================================================
   1. TABLA GENERO
   ========================================================= */
CREATE TABLE Genero (
    GeneroId INT IDENTITY (1, 1) PRIMARY KEY,
    Nombre VARCHAR (50) NOT NULL UNIQUE,
    Descripcion VARCHAR (150)
);


GO
/* =========================================================
   2. TABLA PELICULA
   ========================================================= */
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
CREATE PROCEDURE sp_ObtenerPeliculas
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

CREATE PROCEDURE sp_InsertarPelicula
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
CREATE PROCEDURE sp_ObtenerClientes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ClienteId, Nombre, Apellido, Correo, Telefono, FechaNacimiento, Activo
    FROM Cliente
    WHERE Activo = 1
    ORDER BY ClienteId DESC;
END;
GO

CREATE PROCEDURE sp_InsertarCliente
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

CREATE PROCEDURE sp_EliminarClienteLogic
    @ClienteId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Cliente SET Activo = 0 WHERE ClienteId = @ClienteId;
END;
GO

-- 3. PRODUCTO: Obtener e Insertar
CREATE PROCEDURE sp_ObtenerProductos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductoId, Nombre, Categoria, Precio, Stock, Descripcion, Activo
    FROM Producto
    WHERE Activo = 1
    ORDER BY ProductoId;
END;
GO

CREATE PROCEDURE sp_InsertarProducto
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
CREATE PROCEDURE sp_RegistrarVenta
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