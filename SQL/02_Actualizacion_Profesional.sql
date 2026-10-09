USE GestionCineDB;
GO
-- Ejecutar después del script 01 en una PC nueva.
-- En una base GestionCineDB existente ejecutar SOLO este script.
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
