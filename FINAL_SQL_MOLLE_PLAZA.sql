CREATE DATABASE MollePlazaDB COLLATE Modern_Spanish_CI_AS;
GO

ALTER DATABASE MollePlazaDB SET RECOVERY FULL;
GO

USE MollePlazaDB;
GO

--Tabla 1: TiposDocumento
CREATE TABLE TiposDocumento (
    TipoDocID   INT IDENTITY(1,1) PRIMARY KEY,
    Codigo      NVARCHAR(10) NOT NULL,
    Descripcion NVARCHAR(80) NOT NULL,
    Longitud    INT,
    CONSTRAINT UQ_TDoc_Cod UNIQUE (Codigo)
);
GO
--Tabla 2: TiposComprobante
CREATE TABLE TiposComprobante (
    TipoComprobanteID INT  IDENTITY(1,1) PRIMARY KEY,
    Codigo            NVARCHAR(10)NOT NULL,
    Descripcion       NVARCHAR(80) NOT NULL,
    SeriePrefijo      NVARCHAR(5),
    AplicaIGV         BIT   NOT NULL DEFAULT 1,
    CONSTRAINT UQ_TComp_Cod UNIQUE (Codigo)
);
GO
--Tabla 3: FormasPago
CREATE TABLE FormasPago (
    FormaPagoID INT  IDENTITY(1,1) PRIMARY KEY,
    Codigo      NVARCHAR(20) NOT NULL,
    Descripcion NVARCHAR(80) NOT NULL,
    Activo      BIT  NOT NULL DEFAULT 1,
    CONSTRAINT UQ_FPago_Cod UNIQUE (Codigo)
);
GO
--Tabla 4: UnidadesMedida
CREATE TABLE UnidadesMedida (
    UnidadID    INT  IDENTITY(1,1) PRIMARY KEY,
    Codigo      NVARCHAR(10) NOT NULL,
    Descripcion NVARCHAR(60) NOT NULL,
    CONSTRAINT UQ_Unid_Cod UNIQUE (Codigo)
);
GO
--Tabla 5: Marcas
CREATE TABLE Marcas (
    MarcaID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre  NVARCHAR(100) NOT NULL,
    Activo  BIT  NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Marca_Nombre UNIQUE (Nombre)
);
GO
--Tabla 6: Categorias con autorrelación para subcategorías y restricción de unicidad por nivel
CREATE TABLE Categorias (
    CategoriaID      INT IDENTITY(1,1) PRIMARY KEY,
    CategoriaPadreID INT NULL,
    Nombre           NVARCHAR(100) NOT NULL,
    Nivel            TINYINT  NOT NULL DEFAULT 1,
    Activo           BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Cat_Padre   FOREIGN KEY (CategoriaPadreID) REFERENCES Categorias(CategoriaID),
    CONSTRAINT UQ_Cat_NomPadre UNIQUE (CategoriaPadreID, Nombre)
);
GO
--Tabla 7: Proveedores con validación de descuento habitual y relación con tipos de documento
CREATE TABLE Proveedores (
    ProveedorID       INT IDENTITY(1,1) PRIMARY KEY,
    TipoDocID         INT NOT NULL,
    NumDocumento      NVARCHAR(20) NOT NULL,
    RazonSocial       NVARCHAR(200)NOT NULL,
    NombreComercial   NVARCHAR(200),
    Direccion         NVARCHAR(300),
    Ciudad            NVARCHAR(80)  NOT NULL DEFAULT 'Cajamarca',
    Telefono          NVARCHAR(30),
    Email             NVARCHAR(120),
    ContactoNombre    NVARCHAR(150),
    ContactoTelefono  NVARCHAR(30),
    ContactoEmail     NVARCHAR(120),
    DiasCredito       INT NOT NULL DEFAULT 0,
    DescuentoHabitual DECIMAL(5,2)  NOT NULL DEFAULT 0,
    MontoMinimoPedido DECIMAL(10,2) NOT NULL DEFAULT 0,
    Activo            BIT  NOT NULL DEFAULT 1,
    FechaCreacion     DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Prov_Doc  UNIQUE (TipoDocID, NumDocumento),
    CONSTRAINT FK_Prov_TDoc FOREIGN KEY (TipoDocID) REFERENCES TiposDocumento(TipoDocID),
    CONSTRAINT CK_Prov_Desc CHECK (DescuentoHabitual BETWEEN 0 AND 100)
);
GO

--Tabla 8: Productos con validaciones de precios, stock y relación con categorías, marcas y unidades de medida
CREATE TABLE Productos (
    ProductoID      INT IDENTITY(1,1) PRIMARY KEY,
    CategoriaID     INT  NOT NULL,
    MarcaID         INT,
    UnidadID        INT NOT NULL,
    CodigoBarras    NVARCHAR(60),
    CodigoInterno   NVARCHAR(30)NOT NULL,
    Nombre          NVARCHAR(250)NOT NULL,
    Descripcion     NVARCHAR(500),
    PrecioCompra    DECIMAL(10,3) NOT NULL DEFAULT 0,
    PrecioVentaBase DECIMAL(10,3) NOT NULL DEFAULT 0,
    IGVAplica       BIT   NOT NULL DEFAULT 1,
    StockActual     DECIMAL(12,3) NOT NULL DEFAULT 0,
    StockMinimo     DECIMAL(12,3) NOT NULL DEFAULT 5,
    EsGranel        BIT   NOT NULL DEFAULT 0,
    PrecioOferta    DECIMAL(10,3),
    FechaFinOferta  DATE,
    Activo          BIT  NOT NULL DEFAULT 1,
    FechaCreacion   DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Prod_CodInt UNIQUE (CodigoInterno),
    CONSTRAINT FK_Prod_Cat    FOREIGN KEY (CategoriaID) REFERENCES Categorias(CategoriaID),
    CONSTRAINT FK_Prod_Marca  FOREIGN KEY (MarcaID)     REFERENCES Marcas(MarcaID),
    CONSTRAINT FK_Prod_Unid   FOREIGN KEY (UnidadID)    REFERENCES UnidadesMedida(UnidadID),
    CONSTRAINT CK_Prod_PC     CHECK (PrecioCompra    >= 0),
    CONSTRAINT CK_Prod_PV     CHECK (PrecioVentaBase >= 0)
);
GO

--Tabla 9: Clientes con validación de documento único por tipo y relación con tipos de documento
CREATE TABLE Clientes (
    ClienteID     INT IDENTITY(1,1) PRIMARY KEY,
    TipoDocID     INT  NOT NULL,
    NumDocumento  NVARCHAR(20)NOT NULL,
    Nombres       NVARCHAR(150)NOT NULL,
    Apellidos     NVARCHAR(150),
    Telefono      NVARCHAR(30),
    Email         NVARCHAR(120),
    Direccion     NVARCHAR(300),
    Ciudad        NVARCHAR(80)NOT NULL DEFAULT 'Cajamarca',
    FechaNac      DATE,
    Activo        BIT  NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2   NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Cli_Doc  UNIQUE (TipoDocID, NumDocumento),
    CONSTRAINT FK_Cli_TDoc FOREIGN KEY (TipoDocID) REFERENCES TiposDocumento(TipoDocID)
);
GO

--Tabla 10: Empleados
CREATE TABLE Empleados (
    EmpleadoID   INT IDENTITY(1,1) PRIMARY KEY,
    TipoDocID    INT NOT NULL,
    NumDocumento NVARCHAR(20) NOT NULL,
    Nombres      NVARCHAR(150)NOT NULL,
    Apellidos    NVARCHAR(150)NOT NULL,
    Cargo        NVARCHAR(50) NOT NULL DEFAULT 'Cajero',
    Telefono     NVARCHAR(30),
    Email        NVARCHAR(120),
    FechaIngreso DATE  NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Activo       BIT NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Emp_Doc   UNIQUE (TipoDocID, NumDocumento),
    CONSTRAINT FK_Emp_TDoc  FOREIGN KEY (TipoDocID) REFERENCES TiposDocumento(TipoDocID),
    CONSTRAINT CK_Emp_Cargo CHECK (Cargo IN ('Administrador','Cajero'))
);
GO

--Tabla 11: Usuarios con relación a empleados
CREATE TABLE Usuarios (
    UsuarioID    INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID   INT  NOT NULL,
    Login        NVARCHAR(50)NOT NULL,
    PasswordHash NVARCHAR(256)NOT NULL,
    Rol          NVARCHAR(30)NOT NULL DEFAULT 'Cajero',
    Activo       BIT NOT NULL DEFAULT 1,
    UltimoAcceso DATETIME2,
    CONSTRAINT UQ_Usr_Login    UNIQUE (Login),
    CONSTRAINT UQ_Usr_Empleado UNIQUE (EmpleadoID),
    CONSTRAINT FK_Usr_Emp      FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    CONSTRAINT CK_Usr_Rol      CHECK (Rol IN ('Admin','Cajero'))
);
GO
--Tabla 12: Ventas

CREATE TABLE Ventas (
    VentaID           INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID         INT,
    UsuarioID         INT  NOT NULL,
    TipoComprobanteID INT NOT NULL,
    FormaPagoID       INT NOT NULL,
    NumeroSerie       NVARCHAR(5),
    NumeroCorrelativo NVARCHAR(10),
    FechaVenta        DATETIME2     NOT NULL DEFAULT GETDATE(),
    SubTotal          DECIMAL(12,2) NOT NULL DEFAULT 0,
    DescuentoTotal    DECIMAL(12,2) NOT NULL DEFAULT 0,
    IGV               DECIMAL(12,2) NOT NULL DEFAULT 0,
    Total             DECIMAL(12,2) NOT NULL DEFAULT 0,
    MontoRecibido     DECIMAL(12,2),
    Vuelto            DECIMAL(12,2),
    Estado            NVARCHAR(12)  NOT NULL DEFAULT 'COMPLETADA',
    Observaciones     NVARCHAR(300),
    CONSTRAINT FK_Vta_Cli    FOREIGN KEY (ClienteID)         REFERENCES Clientes(ClienteID),
    CONSTRAINT FK_Vta_Usr    FOREIGN KEY (UsuarioID)         REFERENCES Usuarios(UsuarioID),
    CONSTRAINT FK_Vta_TComp  FOREIGN KEY (TipoComprobanteID) REFERENCES TiposComprobante(TipoComprobanteID),
    CONSTRAINT FK_Vta_FPago  FOREIGN KEY (FormaPagoID)       REFERENCES FormasPago(FormaPagoID),
    CONSTRAINT CK_Vta_Est    CHECK (Estado IN ('COMPLETADA','ANULADA','PENDIENTE'))
);
GO

--Tabla 13: DetalleVentas con relación a productos y ventas, y validaciones de cantidad y precio
CREATE TABLE DetalleVentas (
    DetalleVentaID INT  IDENTITY(1,1) PRIMARY KEY,
    VentaID        INT NOT NULL,
    ProductoID     INT  NOT NULL,
    Cantidad       DECIMAL(12,3) NOT NULL,
    PrecioUnitario DECIMAL(10,3) NOT NULL,
    Descuento      DECIMAL(10,3) NOT NULL DEFAULT 0,
    Subtotal       DECIMAL(12,3) NOT NULL,
    CONSTRAINT FK_DV_Vta  FOREIGN KEY (VentaID)    REFERENCES Ventas(VentaID),
    CONSTRAINT FK_DV_Prod FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID),
    CONSTRAINT CK_DV_Cant CHECK (Cantidad > 0),
    CONSTRAINT CK_DV_PU   CHECK (PrecioUnitario >= 0)
);
GO

--Tabla 14: Devoluciones con relación a ventas, productos y usuarios, y validaciones de motivo, cantidad y tipo de reposición
CREATE TABLE Devoluciones (
    DevolucionID    INT IDENTITY(1,1) PRIMARY KEY,
    VentaID         INT NOT NULL,
    ProductoID      INT  NOT NULL,
    UsuarioID       INT  NOT NULL,
    Motivo          NVARCHAR(40)  NOT NULL DEFAULT 'PRODUCTO_DEFECTUOSO',
    Cantidad        DECIMAL(12,3) NOT NULL,
    PrecioUnitario  DECIMAL(10,3) NOT NULL,
    MontoDevuelto   DECIMAL(12,2) NOT NULL DEFAULT 0,
    TipoReposicion  NVARCHAR(20)  NOT NULL DEFAULT 'CAMBIO_PRODUCTO',
    FechaDevolucion DATETIME2     NOT NULL DEFAULT GETDATE(),
    Observaciones   NVARCHAR(300),
    CONSTRAINT FK_Dev_Vta  FOREIGN KEY (VentaID)    REFERENCES Ventas(VentaID),
    CONSTRAINT FK_Dev_Prod FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID),
    CONSTRAINT FK_Dev_Usr  FOREIGN KEY (UsuarioID)  REFERENCES Usuarios(UsuarioID),
    CONSTRAINT CK_Dev_Cant CHECK (Cantidad > 0),
    CONSTRAINT CK_Dev_Mot  CHECK (Motivo IN
        ('PRODUCTO_DEFECTUOSO','PRODUCTO_VENCIDO','ERROR_COBRO','CAMBIO_MENTE','OTRO')),
    CONSTRAINT CK_Dev_Repo CHECK (TipoReposicion IN
        ('CAMBIO_PRODUCTO','REEMBOLSO','NOTA_CREDITO'))
);
GO

--Tabla 15: Compras con relación a proveedores, usuarios y formas de pago, y validaciones de estado de pago y cálculo de monto pendiente
CREATE TABLE Compras (
    CompraID        INT IDENTITY(1,1) PRIMARY KEY,
    ProveedorID     INT NOT NULL,
    UsuarioID       INT  NOT NULL,
    FormaPagoID     INT    NOT NULL,
    NumeroDocumento NVARCHAR(50),
    FechaCompra     DATETIME2     NOT NULL DEFAULT GETDATE(),
    SubTotal        DECIMAL(12,2) NOT NULL DEFAULT 0,
    IGV             DECIMAL(12,2) NOT NULL DEFAULT 0,
    Total           DECIMAL(12,2) NOT NULL DEFAULT 0,
    MontoPagado     DECIMAL(12,2) NOT NULL DEFAULT 0,
    MontoPendiente  AS (Total - MontoPagado),
    FechaVencPago   DATE,
    EstadoPago      NVARCHAR(10)  NOT NULL DEFAULT 'PENDIENTE',
    Observaciones   NVARCHAR(300),
    CONSTRAINT FK_Comp_Prov  FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID),
    CONSTRAINT FK_Comp_Usr   FOREIGN KEY (UsuarioID)   REFERENCES Usuarios(UsuarioID),
    CONSTRAINT FK_Comp_FPago FOREIGN KEY (FormaPagoID) REFERENCES FormasPago(FormaPagoID),
    CONSTRAINT CK_Comp_Est   CHECK (EstadoPago IN ('PENDIENTE','PARCIAL','PAGADA','VENCIDA'))
);
GO

--Tabla 16: DetalleCompras con relación a compras y productos, y validaciones de cantidad, precio y fecha de vencimiento de lote
CREATE TABLE DetalleCompras (
    DetalleCompraID INT  IDENTITY(1,1) PRIMARY KEY,
    CompraID        INT  NOT NULL,
    ProductoID      INT  NOT NULL,
    NumeroLote      NVARCHAR(60),
    FechaVencLote   DATE,
    Cantidad        DECIMAL(12,3) NOT NULL,
    PrecioUnitario  DECIMAL(10,3) NOT NULL,
    Subtotal        DECIMAL(12,3) NOT NULL,
    CONSTRAINT FK_DC_Comp FOREIGN KEY (CompraID)   REFERENCES Compras(CompraID),
    CONSTRAINT FK_DC_Prod FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID),
    CONSTRAINT CK_DC_Cant CHECK (Cantidad > 0),
    CONSTRAINT CK_DC_PU   CHECK (PrecioUnitario >= 0)
);
GO


-- Índices para optimizar consultas frecuentes en productos, ventas, compras y clientes
CREATE UNIQUE INDEX IX_Prod_Barras   ON Productos(CodigoBarras) WHERE CodigoBarras IS NOT NULL;
CREATE INDEX IX_Prod_Nombre          ON Productos(Nombre) INCLUDE (PrecioVentaBase, StockActual, Activo);
CREATE INDEX IX_Prod_Stock           ON Productos(StockActual, StockMinimo) WHERE Activo = 1;
CREATE INDEX IX_Prod_Oferta          ON Productos(PrecioOferta) WHERE PrecioOferta IS NOT NULL;
CREATE INDEX IX_Ventas_Fecha         ON Ventas(FechaVenta) INCLUDE (Total, Estado, UsuarioID);
CREATE INDEX IX_Ventas_Cliente       ON Ventas(ClienteID, FechaVenta);
CREATE INDEX IX_DetVta_Prod          ON DetalleVentas(ProductoID) INCLUDE (Cantidad, Subtotal);
CREATE INDEX IX_Compras_Prov         ON Compras(ProveedorID, FechaCompra);
CREATE INDEX IX_Cli_Doc              ON Clientes(TipoDocID, NumDocumento);
CREATE INDEX IX_Lotes_Venc           ON DetalleCompras(FechaVencLote) WHERE FechaVencLote IS NOT NULL;
CREATE INDEX IX_Ventas_Usuario       ON Ventas(UsuarioID, FechaVenta);
GO




-- FUNCIÓN 1: Margen de ganancia (%) de un producto

CREATE FUNCTION dbo.fn_MargenGanancia(@ProductoID INT)
RETURNS DECIMAL(6,2)
AS
BEGIN
    DECLARE @Margen DECIMAL(6,2);
    SELECT @Margen = CASE WHEN PrecioVentaBase > 0
        THEN ((PrecioVentaBase - PrecioCompra) / PrecioVentaBase) * 100.0
        ELSE 0 END
    FROM Productos WHERE ProductoID = @ProductoID;
    RETURN ISNULL(@Margen, 0);
END;
GO


-- FUNCIÓN 2: Días de stock restante según rotación últimos 30 días

CREATE FUNCTION dbo.fn_DiasStockRestante(@ProductoID INT)
RETURNS INT
AS
BEGIN
    DECLARE @PromedioVentaDiaria DECIMAL(12,3), @Stock DECIMAL(12,3);
    SELECT @PromedioVentaDiaria = ISNULL(
        SUM(dv.Cantidad) / NULLIF(DATEDIFF(DAY, MIN(v.FechaVenta), GETDATE()), 0), 0)
    FROM DetalleVentas dv
    JOIN Ventas v ON dv.VentaID = v.VentaID
    WHERE dv.ProductoID = @ProductoID
      AND v.Estado = 'COMPLETADA'
      AND v.FechaVenta >= DATEADD(DAY, -30, GETDATE());
    SELECT @Stock = StockActual FROM Productos WHERE ProductoID = @ProductoID;
    RETURN CASE WHEN @PromedioVentaDiaria > 0
                THEN CAST(@Stock / @PromedioVentaDiaria AS INT)
                ELSE 9999 END;
END;
GO


-- FUNCIÓN 3: Descuento de oferta vigente

CREATE FUNCTION dbo.fn_DescuentoOfertaVigente(@ProductoID INT)
RETURNS DECIMAL(10,3)
AS
BEGIN
    DECLARE @Descuento DECIMAL(10,3) = 0;
    DECLARE @Base DECIMAL(10,3), @Oferta DECIMAL(10,3), @FinOferta DATE;
    SELECT @Base = PrecioVentaBase, @Oferta = PrecioOferta, @FinOferta = FechaFinOferta
    FROM Productos WHERE ProductoID = @ProductoID;
    IF @Oferta IS NOT NULL AND (@FinOferta IS NULL OR @FinOferta >= CAST(GETDATE() AS DATE))
        SET @Descuento = @Base - @Oferta;
    RETURN CASE WHEN @Descuento > 0 THEN @Descuento ELSE 0 END;
END;
GO


-- FUNCIÓN 4: Precio con IGV incluido (18%)

CREATE FUNCTION dbo.fn_PrecioConIGV(@Precio DECIMAL(10,3))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN ROUND(@Precio * 1.18, 2);
END;
GO



-- VISTA 1: Stock crítico con días restantes y proveedor principal

CREATE VIEW vw_StockCritico AS
SELECT
    p.ProductoID,
    p.CodigoInterno,
    p.CodigoBarras,
    p.Nombre AS Producto,
    c.Nombre AS Categoria,
    ISNULL(m.Nombre, 'Sin marca') AS Marca,
    u.Codigo AS Unidad,
    p.StockActual,
    p.StockMinimo,
    (p.StockMinimo - p.StockActual) AS FaltanUnidades,
    dbo.fn_DiasStockRestante(p.ProductoID) AS DiasRestantes,
    (SELECT TOP 1 pr.RazonSocial
     FROM Compras co
     JOIN DetalleCompras dc ON co.CompraID = dc.CompraID
     JOIN Proveedores pr ON co.ProveedorID = pr.ProveedorID
     WHERE dc.ProductoID = p.ProductoID
     ORDER BY co.FechaCompra DESC) AS ProveedorPrincipal
FROM Productos p
JOIN Categorias c ON p.CategoriaID = c.CategoriaID
LEFT JOIN Marcas m ON p.MarcaID = m.MarcaID
JOIN UnidadesMedida u ON p.UnidadID = u.UnidadID
WHERE p.StockActual <= p.StockMinimo AND p.Activo = 1;
GO


-- VISTA 2: Resumen diario de ventas con desglose por forma de pago

CREATE VIEW vw_VentasDiarias AS
SELECT
    CAST(v.FechaVenta AS DATE) AS Fecha,
    COUNT(v.VentaID)           AS NumVentas,
    COUNT(DISTINCT v.ClienteID) AS ClientesAtendidos,
    SUM(v.SubTotal)            AS SubTotal,
    SUM(v.IGV)                 AS IGV,
    SUM(v.Total)               AS TotalVentas,
    AVG(v.Total)               AS TicketPromedio,
    SUM(CASE WHEN fp.Codigo = 'EFECTIVO'      THEN v.Total ELSE 0 END) AS Efectivo,
    SUM(CASE WHEN fp.Codigo = 'YAPE'          THEN v.Total ELSE 0 END) AS Yape,
    SUM(CASE WHEN fp.Codigo = 'PLIN'          THEN v.Total ELSE 0 END) AS Plin,
    SUM(CASE WHEN fp.Codigo = 'TARJETA'       THEN v.Total ELSE 0 END) AS Tarjeta,
    SUM(CASE WHEN fp.Codigo = 'TRANSFERENCIA' THEN v.Total ELSE 0 END) AS Transferencia
FROM Ventas v
JOIN FormasPago fp ON v.FormaPagoID = fp.FormaPagoID
WHERE v.Estado = 'COMPLETADA'
GROUP BY CAST(v.FechaVenta AS DATE);
GO




-- VISTA 3: Lotes próximos a vencer (≤ 30 días)
CREATE VIEW vw_LotesProximosVencer AS
SELECT
    dc.NumeroLote,
    p.CodigoInterno,
    p.Nombre                                         AS Producto,
    c.Nombre                                         AS Categoria,
    dc.Cantidad                                      AS CantidadComprada,
    u.Codigo                                         AS Unidad,
    dc.FechaVencLote                                 AS FechaVencimiento,
    DATEDIFF(DAY, GETDATE(), dc.FechaVencLote)       AS DiasParaVencer,
    pr.RazonSocial                                   AS Proveedor,
    co.FechaCompra
FROM DetalleCompras dc
JOIN Compras co     ON dc.CompraID    = co.CompraID
JOIN Productos p    ON dc.ProductoID  = p.ProductoID
JOIN Categorias c   ON p.CategoriaID  = c.CategoriaID
JOIN UnidadesMedida u ON p.UnidadID   = u.UnidadID
JOIN Proveedores pr ON co.ProveedorID = pr.ProveedorID
WHERE dc.FechaVencLote IS NOT NULL
  AND dc.FechaVencLote >= GETDATE()
  AND DATEDIFF(DAY, GETDATE(), dc.FechaVencLote) <= 30;
GO


-- TRIGGER 1: Descontar stock al insertar línea de venta

CREATE TRIGGER trg_VentaDescontaStock
ON DetalleVentas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.StockActual = p.StockActual - i.Cantidad
    FROM Productos p
    JOIN inserted i ON p.ProductoID = i.ProductoID;
END;
GO


-- TRIGGER 2: Aumentar stock al recibir compra

CREATE TRIGGER trg_CompraAumentaStock
ON DetalleCompras
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.StockActual = p.StockActual + i.Cantidad
    FROM Productos p
    JOIN inserted i ON p.ProductoID = i.ProductoID;
END;
GO


--Trigger 3: Recalcular totales de venta al modificar detalle

CREATE TRIGGER trg_TotalesVenta
ON DetalleVentas
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VentasAfectadas TABLE (VentaID INT);
    INSERT INTO @VentasAfectadas (VentaID)
    SELECT DISTINCT VentaID FROM inserted
    UNION
    SELECT DISTINCT VentaID FROM deleted;

    UPDATE v SET
        v.SubTotal = ISNULL(sub.Base, 0),
        v.IGV      = CASE WHEN tc.AplicaIGV = 1
                         THEN ROUND(ISNULL(sub.Base, 0) * 0.18, 2) ELSE 0 END,
        v.Total    = ISNULL(sub.Base, 0) +
                     CASE WHEN tc.AplicaIGV = 1
                         THEN ROUND(ISNULL(sub.Base, 0) * 0.18, 2) ELSE 0 END
    FROM Ventas v
    JOIN TiposComprobante tc ON v.TipoComprobanteID = tc.TipoComprobanteID
    JOIN @VentasAfectadas va ON v.VentaID = va.VentaID
    LEFT JOIN (
        SELECT VentaID, SUM(Subtotal) AS Base
        FROM DetalleVentas
        WHERE VentaID IN (SELECT VentaID FROM @VentasAfectadas)
        GROUP BY VentaID
    ) sub ON v.VentaID = sub.VentaID;
END;
GO


-- TRIGGER 4: Reponer stock al procesar devolución

CREATE TRIGGER trg_DevolucionReponerStock
ON Devoluciones
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.StockActual = p.StockActual + i.Cantidad
    FROM Productos p
    JOIN inserted i ON p.ProductoID = i.ProductoID;
END;
GO



-- SP 1: Crear cabecera de venta

CREATE PROCEDURE sp_IniciarVenta
    @ClienteID         INT = NULL,
    @UsuarioID         INT,
    @TipoComprobanteID INT,
    @FormaPagoID       INT,
    @MontoRecibido     DECIMAL(12,2) = NULL,
    @Observaciones     NVARCHAR(300) = NULL,
    @VentaID           INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM Usuarios WHERE UsuarioID = @UsuarioID AND Activo = 1)
        THROW 50001, 'Usuario inactivo o inexistente.', 1;
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Ventas (
            ClienteID, UsuarioID, TipoComprobanteID, FormaPagoID,
            MontoRecibido, Observaciones
        ) VALUES (
            @ClienteID, @UsuarioID, @TipoComprobanteID, @FormaPagoID,
            @MontoRecibido, @Observaciones
        );
        SET @VentaID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


-- SP 2: Agregar línea de venta con descuento automático de oferta

CREATE PROCEDURE sp_AgregarDetalleVenta
    @VentaID    INT,
    @ProductoID INT,
    @Cantidad   DECIMAL(12,3),
    @PrecioUnit DECIMAL(10,3) = NULL,
    @Descuento  DECIMAL(10,3) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @PrecioUnit IS NULL
        SELECT @PrecioUnit = PrecioVentaBase FROM Productos WHERE ProductoID = @ProductoID;
    IF @Descuento IS NULL
        SET @Descuento = dbo.fn_DescuentoOfertaVigente(@ProductoID);
    IF EXISTS(SELECT 1 FROM Productos WHERE ProductoID = @ProductoID AND StockActual < @Cantidad)
        THROW 50002, 'Stock insuficiente para el producto solicitado.', 1;
    INSERT INTO DetalleVentas (VentaID, ProductoID, Cantidad, PrecioUnitario, Descuento, Subtotal)
    VALUES (@VentaID, @ProductoID, @Cantidad, @PrecioUnit, @Descuento,
            (@Cantidad * @PrecioUnit) - @Descuento);
END;
GO


CREATE ROLE rol_Admin;
CREATE ROLE rol_Cajero;


-- rol_Admin: control total
--   Dueño / administrador — gestiona productos, compras,
--   proveedores, usuarios y accede a todos los reportes.

EXEC sp_addrolemember 'db_owner', 'rol_Admin';


-- rol_Cajero: operaciones de punto de venta
--   Solo puede registrar ventas, devoluciones y consultar
--   productos y clientes. No accede a compras ni configuración.

GRANT SELECT, INSERT         ON dbo.Ventas           TO rol_Cajero;
GRANT SELECT, INSERT         ON dbo.DetalleVentas    TO rol_Cajero;
GRANT SELECT, INSERT         ON dbo.Devoluciones     TO rol_Cajero;
GRANT SELECT                 ON dbo.Productos        TO rol_Cajero;
GRANT SELECT                 ON dbo.Clientes         TO rol_Cajero;
GRANT SELECT                 ON dbo.FormasPago       TO rol_Cajero;
GRANT SELECT                 ON dbo.TiposComprobante TO rol_Cajero;
GRANT EXECUTE ON dbo.sp_IniciarVenta        TO rol_Cajero;
GRANT EXECUTE ON dbo.sp_AgregarDetalleVenta TO rol_Cajero;
GO


-- TIPOS DE DOCUMENTO 
INSERT INTO TiposDocumento (Codigo, Descripcion, Longitud) VALUES
    ('DNI', 'Documento Nacional de Identidad',  8),
    ('RUC', 'Registro Único de Contribuyentes', 11),
    ('CE',  'Carnet de Extranjería',             12),
    ('PAS', 'Pasaporte',                          12);

-- TIPOS DE COMPROBANTE
INSERT INTO TiposComprobante (Codigo, Descripcion, SeriePrefijo, AplicaIGV) VALUES
    ('BV', 'Boleta de Venta', 'B', 0),
    ('FA', 'Factura',         'F', 1),
    ('NV', 'Nota de Venta',   'N', 0);

-- FORMAS DE PAGO
INSERT INTO FormasPago (Codigo, Descripcion) VALUES
    ('EFECTIVO',      'Efectivo'),
    ('YAPE',          'Yape'),
    ('PLIN',          'Plin'),
    ('TARJETA',       'Tarjeta débito/crédito'),
    ('TRANSFERENCIA', 'Transferencia bancaria'),
    ('CREDITO',       'Crédito al cliente');

-- UNIDADES DE MEDIDA 
INSERT INTO UnidadesMedida (Codigo, Descripcion) VALUES
    ('UND',  'Unidad'),('KG',   'Kilogramo'),
    ('LT',   'Litro'),('CAJA', 'Caja'),
    ('DOC',  'Docena'),('ML',   'Mililitro'),
    ('PQT',  'Paquete'),('GR',   'Gramo');

-- MARCAS
INSERT INTO Marcas (Nombre) VALUES
    ('Gloria'),('Laive'),('Nestlé'),            
    ('Alicorp'),('Backus'),('Molitalia'),         
    ('Donofrio'),('San Fernando'),('Genérico'),          
    ('Otras'),('Incasur'),('Ángel'),             
    ('Procter & Gamble'),('Unilever'),('Colgate-Palmolive'); 

-- CATEGORÍAS
-- Nivel 1
INSERT INTO Categorias (CategoriaPadreID, Nombre, Nivel) VALUES
    (NULL, 'Lácteos',1), 
    (NULL, 'Abarrotes',1), 
    (NULL, 'Bebidas',1), 
    (NULL, 'Limpieza',1),  
    (NULL, 'Higiene Personal',1),  
    (NULL, 'Embutidos y Carnes',1), 
    (NULL, 'Snacks y Golosinas',1);  

-- Nivel 2
INSERT INTO Categorias (CategoriaPadreID, Nombre, Nivel) VALUES
    (1, 'Leche UHT',2),(1, 'Leche Evaporada',2),(1, 'Yogurt',2),
    (1, 'Queso',2), (1, 'Mantequilla',2),(2, 'Arroz',2), 
    (2, 'Azúcar',2),(2, 'Aceite', 2),(2, 'Fideos',2),
    (2, 'Menestras',2),(2, 'Sal y Condimentos',2),(2, 'Conservas', 2),
    (3, 'Gaseosas', 2),(3, 'Jugos y Néctares',2),(3, 'Agua',2),
    (3, 'Bebidas Calientes',2),(4, 'Detergentes', 2),(4, 'Lavavajilla',2), 
    (4, 'Lejía y Desinfect.',2),(5, 'Jabón de Tocador',2),(5, 'Shampoo',  2),
    (5, 'Pasta Dental',2),(6, 'Embutidos',  2), (7, 'Galletas', 2),
    (7, 'Chocolates',2);
GO

-- PROVEEDORES
INSERT INTO Proveedores
    (TipoDocID, NumDocumento, RazonSocial, NombreComercial, Direccion, Ciudad,
     Telefono, Email, ContactoNombre, ContactoTelefono, DiasCredito,
     DescuentoHabitual, MontoMinimoPedido)
VALUES
    (2,'20100100610','Gloria S.A.','Gloria',
     'Av. República de Panamá 2461, Lima','Lima',
     '(01)2095500','proveedores@gloria.com.pe','Carlos Mendoza','987654321',30,5.00,500.00),

    (2,'20100196910','Nestlé Perú S.A.','Nestlé',
     'Av. Industrial 100, Lima','Lima',
     '(01)5133000','ventas@nestle.com.pe','Ana Quispe','976543210',30,3.00,800.00),

    (2,'20100059255','Alicorp S.A.A.','Alicorp',
     'Jr. Bartolomé Herrera 182, Lima','Lima',
     '(01)3150800','pedidos@alicorp.com.pe','Roberto Silva','965432109',45,4.00,1000.00),

    (2,'20331066703','Backus y Johnston S.A.A.','Backus',
     'Av. La Molina 1550, Lima','Lima',
     '(01)6263000','ventas@backus.pe','Luis Torres','954321098',30,2.00,600.00),

    (2,'20503503639','Distribuidora Cajamarca S.A.C.','DistCaja',
     'Jr. Del Comercio 345, Cajamarca','Cajamarca',
     '076-361234','ventas@distcajamarca.pe','María Huamán','943210987',15,2.00,200.00),

    (2,'20480516805','Inversiones Cajamarca E.I.R.L.','InvCajamarca',
     'Av. Hoyos Rubio 890, Cajamarca','Cajamarca',
     '076-365500','pedidos@invcajamarca.pe','Jorge Chávarry','976112200',15,1.50,150.00),

    (2,'20601122334','Molinos del Norte S.A.C.','MoliNorte',
     'Carretera a Bambamarca Km 3, Cajamarca','Cajamarca',
     '076-368800','ventas@molinorte.pe','Patricia Aliaga','965011223',30,3.00,300.00),

    (2,'20131369954','San Fernando S.A.','San Fernando',
     'Av. Argentina 1495, Lima','Lima',
     '(01)3620000','clientes@sanfernando.com.pe','Eduardo Paredes','953001122',30,3.50,500.00);
GO

-- ─── EMPLEADOS 
INSERT INTO Empleados (TipoDocID, NumDocumento, Nombres, Apellidos, Cargo, Telefono, Email, FechaIngreso) VALUES
    (1,'42356789','Juan Carlos','Ramirez Llanos', 'Administrador','976112233','jramirez@molleplaza.pe','2020-01-15'),
    (1,'48901234','Rosa Elena', 'Vasquez Cerna',  'Cajero', '965223344','rvasquez@molleplaza.pe','2021-03-01');

INSERT INTO Usuarios (EmpleadoID, Login, PasswordHash, Rol, Activo) VALUES
    (1,'jramirez','8C6976E5B5410415BDE908BD4DEE15DFB167A9C873FC4BB8A81F6F2AB448A918','Admin', 1),
    (2,'rvasquez','E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855','Cajero',1);
GO

-- ─── PRODUCTOS  
INSERT INTO Productos
    (CategoriaID, MarcaID, UnidadID, CodigoBarras, CodigoInterno,
     Nombre, PrecioCompra, PrecioVentaBase, IGVAplica,
     StockActual, StockMinimo, EsGranel, PrecioOferta, FechaFinOferta)
VALUES
-- ── LECHE UHT (Cat=8) 
    ( 8, 1,1,'7750332100013','LAC-001','Leche Gloria Entera 1L',            2.80, 3.50,0,120,20,0,NULL,NULL),   -- 1
    ( 8, 1,1,'7750332100020','LAC-002','Leche Gloria Semidescremada 1L',    2.80, 3.50,0, 80,15,0,NULL,NULL),   -- 2
    ( 8, 2,1,'7751140001012','LAC-003','Leche Laive Entera 1L',             2.75, 3.40,0, 60,15,0,NULL,NULL),   -- 3
    ( 8, 1,4,'7750332100037','LAC-004','Leche Gloria Caja x6 und 1L',      16.00,19.50,0, 20, 5,0,NULL,NULL),   -- 4
-- ── LECHE EVAPORADA (Cat=9) 
    ( 9, 1,1,'7750332150010','LAC-005','Leche Evaporada Gloria 400g',       2.10, 2.80,0,100,24,0,NULL,NULL),   -- 5
    ( 9,12,1,'7750098010011','LAC-006','Leche Evaporada Ángel 400g',        2.00, 2.70,0, 80,24,0,NULL,NULL),   -- 6
-- ── YOGURT (Cat=10) 
    (10, 1,1,'7750332200015','LAC-007','Yogurt Gloria Fresa 1kg',           4.20, 5.50,0, 50,10,0, 5.00,'2025-06-30'), -- 7
    (10, 2,1,'7751140002011','LAC-008','Yogurt Laive Vainilla 1kg',         4.10, 5.30,0, 40,10,0,NULL,NULL),   -- 8
    (10, 1,6,'7750332200022','LAC-009','Yogurt Gloria Natural 200ml',       1.10, 1.50,0, 60,20,0,NULL,NULL),   -- 9
    (10, 2,6,'7751140002028','LAC-010','Yogurt Laive Durazno 200ml',        1.05, 1.45,0, 50,20,0,NULL,NULL),   -- 10
-- ── QUESO (Cat=11) 
    (11, 2,2,'7751140003018','LAC-011','Queso Fresco Laive x kg',           9.50,13.00,0, 30, 5,1,NULL,NULL),   -- 11
    (11, 9,2,'0000000000001','LAC-012','Queso Fresco Local x kg',           7.00,10.00,0, 20, 5,1,NULL,NULL),   -- 12
-- ── MANTEQUILLA (Cat=12)
    (12, 1,1,'7750332300011','LAC-013','Mantequilla Gloria con Sal 200g',   5.50, 7.20,0, 25, 8,0,NULL,NULL),   -- 13
    (12, 2,1,'7751140004015','LAC-014','Mantequilla Laive sin Sal 200g',    5.30, 7.00,0, 20, 8,0,NULL,NULL),   -- 14
-- ── ARROZ (Cat=13)
    (13,11,2,'7752045000015','ABA-001','Arroz Incasur Añejo x kg',          2.60, 3.20,0,200,50,1,NULL,NULL),   -- 15
    (13, 9,2,'0000000000002','ABA-002','Arroz Corriente x kg',              2.20, 2.80,0,150,30,1,NULL,NULL),   -- 16
    (13, 4,7,'7752045000039','ABA-003','Arroz Costeño Bolsa 1kg',           2.70, 3.30,0, 80,20,0,NULL,NULL),   -- 17
    (13, 4,4,'7752045000022','ABA-004','Arroz Costeño Caja 50kg',         125.00,145.00,0, 10, 2,0,NULL,NULL),  -- 18
-- ── AZÚCAR (Cat=14)
    (14, 9,2,'7754321000011','ABA-005','Azúcar Rubia x kg',                 2.20, 2.80,0,150,30,1,NULL,NULL),   -- 19
    (14, 9,7,'7754321000028','ABA-006','Azúcar Rubia Bolsa 2kg',            4.20, 5.20,0, 60,15,0,NULL,NULL),   -- 20
    (14, 9,7,'7754321000035','ABA-007','Azúcar Blanca Bolsa 1kg',           2.30, 2.90,0, 80,20,0,NULL,NULL),   -- 21
-- ── ACEITE (Cat=15) 
    (15, 4,3,'7752046000013','ABA-008','Aceite Primor 1L',                  6.80, 8.50,0, 80,20,0, 8.00,'2025-05-31'), -- 22
    (15, 4,3,'7752046000020','ABA-009','Aceite Cocinero 1L',                6.20, 7.80,0, 60,15,0,NULL,NULL),   -- 23
    (15, 4,3,'7752046000037','ABA-010','Aceite Crisol 1L',                  6.50, 8.20,0, 40,12,0,NULL,NULL),   -- 24
-- ── FIDEOS (Cat=16) 
    (16, 6,7,'7750023000018','ABA-011','Fideo Molitalia Spaghetti 500g',    1.80, 2.50,0, 90,20,0,NULL,NULL),   -- 25
    (16, 6,7,'7750023000025','ABA-012','Fideo Molitalia Corbata 250g',      1.00, 1.50,0, 70,15,0,NULL,NULL),   -- 26
    (16, 4,7,'7752046010011','ABA-013','Fideo Anita Spaghetti 500g',        1.60, 2.30,0, 80,20,0,NULL,NULL),   -- 27
    (16, 4,7,'7752046010028','ABA-014','Fideo Anita Cabello Ángel 250g',    0.90, 1.40,0, 60,15,0,NULL,NULL),   -- 28
-- ── MENESTRAS (Cat=17) 
    (17, 9,2,'0000000000003','ABA-015','Lenteja Corriente x kg',            3.50, 4.50,0, 50,10,1,NULL,NULL),   -- 29
    (17, 9,2,'0000000000004','ABA-016','Frijol Canario x kg',               4.20, 5.50,0, 40, 8,1,NULL,NULL),   -- 30
    (17, 9,2,'0000000000005','ABA-017','Arveja Seca x kg',                  3.80, 5.00,0, 35, 8,1,NULL,NULL),   -- 31
-- ── SAL Y CONDIMENTOS (Cat=18) 
    (18, 9,7,'7754000100011','ABA-018','Sal de Mesa Emsal 1kg',             0.90, 1.30,0, 80,20,0,NULL,NULL),   -- 32
    (18, 4,7,'7752046020010','ABA-019','Ajinomoto 100g',                    1.20, 1.80,0, 50,15,0,NULL,NULL),   -- 33
    (18, 4,7,'7752046020027','ABA-020','Sibarita Sazón 100g',               1.50, 2.20,0, 40,12,0,NULL,NULL),   -- 34
-- ── CONSERVAS (Cat=19)
    (19, 1,1,'7750332400010','ABA-021','Atún Florida Grated 170g',          3.20, 4.20,0, 60,15,0,NULL,NULL),   -- 35
    (19, 9,1,'7754000200011','ABA-022','Sardina A-1 al Tomate 425g',        3.50, 4.80,0, 40,10,0,NULL,NULL),   -- 36
-- ── GASEOSAS (Cat=20) 
    (20, 5,1,'7751382000011','BEB-001','Inca Kola 500ml',                   1.20, 2.00,0,120,24,0,NULL,NULL),   -- 37
    (20, 5,1,'7751382000028','BEB-002','Coca Cola 1.5L',                    2.50, 3.50,0, 80,12,0,NULL,NULL),   -- 38
    (20, 5,1,'7751382000035','BEB-003','Inca Kola 1.5L',                    2.50, 3.50,0, 80,12,0,NULL,NULL),   -- 39
    (20, 5,1,'7751382000042','BEB-004','Pepsi 500ml',                       1.10, 1.80,0, 60,12,0,NULL,NULL),   -- 40
    (20, 5,1,'7751382000059','BEB-005','Sprite 1.5L',                       2.40, 3.30,0, 50,12,0,NULL,NULL),   -- 41
-- ── JUGOS Y NÉCTARES (Cat=21)
    (21, 3,6,'7751384010011','BEB-006','Néctar Tampico 300ml',              1.00, 1.50,0, 80,24,0,NULL,NULL),   -- 42
    (21, 4,6,'7752046030010','BEB-007','Néctar Pulp Durazno 250ml',         1.10, 1.60,0, 60,20,0,NULL,NULL),   -- 43
-- ── AGUA (Cat=22) 
    (22, 9,1,'7754892000012','BEB-008','Agua San Luis 620ml',               0.80, 1.20,0, 80,24,0,NULL,NULL),   -- 44
    (22, 9,1,'7754892000029','BEB-009','Agua Cielo 1L',                     0.90, 1.40,0, 60,20,0,NULL,NULL),   -- 45
    (22, 9,1,'7754892000036','BEB-010','Agua San Luis 1.5L',                1.20, 1.80,0, 50,20,0,NULL,NULL),   -- 46
-- ── BEBIDAS CALIENTES (Cat=23) 
    (23, 3,7,'7751384020011','BEB-011','Café Nescafé Clásico 50g',          4.50, 6.00,0, 40,10,0,NULL,NULL),   -- 47
    (23, 9,7,'7754000300011','BEB-012','Té Herbi Manzanilla x25 bolsas',    2.00, 2.80,0, 30,10,0,NULL,NULL),   -- 48
-- ── DETERGENTES (Cat=24) 
    (24, 4,7,'7752046001010','LIM-001','Detergente Ariel 500g',             4.50, 6.00,1, 40,10,0,NULL,NULL),   -- 49
    (24, 4,7,'7752046001027','LIM-002','Detergente Bolivar 1kg',            6.20, 8.00,1, 30, 8,0,NULL,NULL),   -- 50
-- ── LAVAVAJILLA (Cat=25) 
    (25, 4,1,'7752046002017','LIM-003','Lavavajilla Ayudín Limón 150g',     1.80, 2.50,1, 50,15,0,NULL,NULL),   -- 51
    (25, 4,1,'7752046002024','LIM-004','Lavavajilla Ayudín Naranja 500g',   4.20, 5.80,1, 30,10,0,NULL,NULL),   -- 52
-- ── LEJÍA Y DESINFECTANTE (Cat=26) 
    (26, 4,3,'7752046003014','LIM-005','Lejía Clorox 1L',                   3.50, 5.00,1, 40,10,0,NULL,NULL),   -- 53
    (26, 9,3,'7754000400011','LIM-006','Desinfectante Sapolio 900ml',       4.80, 6.50,1, 25, 8,0,NULL,NULL),   -- 54
-- ── JABÓN DE TOCADOR (Cat=27) 
    (27,14,1,'7751384000014','HIG-001','Jabón Dove Original 90g',           2.20, 3.00,1, 60,15,0,NULL,NULL),   -- 55
    (27, 9,1,'7754567000011','HIG-002','Jabón Heno de Pravia 100g',         1.50, 2.20,1, 45,12,0,NULL,NULL),   -- 56
    (27,15,1,'7750100000011','HIG-003','Jabón Palmolive 90g',               1.80, 2.50,1, 50,15,0,NULL,NULL),   -- 57
-- ── SHAMPOO (Cat=28) 
    (28,14,6,'7751384001011','HIG-004','Shampoo Dove Hidratación 200ml',    5.50, 7.50,1, 35,10,0,NULL,NULL),   -- 58
    (28,13,6,'7750024002011','HIG-005','Shampoo Pantene Pro-V 200ml',       6.00, 8.00,1, 30,10,0,NULL,NULL),   -- 59
-- ── PASTA DENTAL (Cat=29)
    (29,15,1,'7750100002011','HIG-006','Pasta Colgate Triple Acción 75ml',  2.80, 3.80,1, 50,15,0,NULL,NULL),   -- 60
    (29,15,1,'7750100002028','HIG-007','Pasta Colgate Herbal 75ml',         2.80, 3.80,1, 40,12,0,NULL,NULL),   -- 61
-- ── EMBUTIDOS (Cat=30) 
    (30, 8,2,'7751560000011','EMB-001','Jamonada San Fernando x kg',        9.00,12.50,0, 15, 3,1,NULL,NULL),   -- 62
    (30, 8,1,'7751560000028','EMB-002','Hot Dog San Fernando x8 und',       5.50, 7.50,0, 20, 5,0,NULL,NULL),   -- 63
-- ── GALLETAS (Cat=31) 
    (31, 9,1,'7754001000011','SNA-001','Galleta Oreo 36g',                  1.00, 1.50,0, 80,20,0,NULL,NULL),   -- 64
    (31, 4,1,'7752046040011','SNA-002','Galleta Casino Vainilla 39g',       1.00, 1.50,0, 70,20,0,NULL,NULL),   -- 65
-- ── CHOCOLATES (Cat=32) 
    (32, 7,1,'7754002000011','SNA-003','Sublime 32g',                       0.80, 1.20,0,100,30,0,NULL,NULL),   -- 66
    (32, 3,1,'7751384030011','SNA-004','Milo Barra 30g',                    1.00, 1.50,0, 60,20,0,NULL,NULL);   -- 67
GO

-- ─── CLIENTES (40)
INSERT INTO Clientes (TipoDocID, NumDocumento, Nombres, Apellidos, Telefono, Email, Direccion, FechaNac) VALUES
    (1,'43256789','María Elena',    'Quispe Chavez',       '976543210','mquispe@gmail.com',     'Jr. Dos de Mayo 123, Cajamarca',            '1985-04-12'),
    (1,'52341890','Pedro Antonio',  'Huamán Torres',       '965432109','phuaman@hotmail.com',   'Av. Hoyos Rubio 456, Cajamarca',            '1990-07-22'),
    (1,'38901234','Carmen Rosa',    'Llanos Rojas',        '954321098',NULL,                    'Jr. El Batán 789, Cajamarca',               '1978-11-05'),
    (1,'67123456','José Manuel',    'Vargas Mendoza',      '943210987','jvargas@yahoo.com',     'Psj. Revilla 32, Cajamarca',                '2000-02-18'),
    (1,'45678901','Ana Lucía',      'Díaz Saldaña',        '932109876','adiaz@gmail.com',       'Av. Los Fresnos 221, Cajamarca',            '1995-09-30'),
    (2,'20601234567','Ferretería Cajamarca E.I.R.L.',NULL, '076-362233',NULL,                   'Jr. Lima 500, Cajamarca',                   NULL),
    (1,'71234567','Luis Alberto',   'Cotrina Peralta',     '921098765',NULL,                    'Barrio Magna Vallejo 45, Cajamarca',        '2003-06-14'),
    (1,'59012345','Sofía Beatriz',  'Becerra Alcántara',   '910987654','sbecerra@gmail.com',    'Jr. Cruz de Piedra 12, Cajamarca',          '1988-12-01'),
    (1,'46789012','Roberto Carlos', 'Arce Chávez',         '999888777',NULL,                    'Av. Túpac Amaru 303, Cajamarca',            '1982-03-25'),
    (1,'80123456','Diana Carolina', 'Tafur Gutiérrez',     '988777666','dtafur@gmail.com',      'Jr. Santa Apolonia 67, Cajamarca',          '1997-08-10'),
    (1,'44567890','Wilmer',         'Chávarry Bustamante', '977665544',NULL,                    'Av. Independencia 234, Cajamarca',          '1980-05-20'),
    (1,'55432109','Nilda Marisol',  'Aliaga Campos',       '966554433','naliaga@gmail.com',     'Jr. Amazonas 890, Cajamarca',               '1993-03-15'),
    (1,'63219087','Segundo Isidoro','Rojas Cerna',         '955443322',NULL,                    'Jr. José Gálvez 345, Cajamarca',           '1975-12-08'),
    (1,'72108976','Liliana del Pilar','Sánchez Vásquez',   '944332211','lsanchez@gmail.com',   'Av. San Martín 678, Cajamarca',             '2001-07-25'),
    (1,'48297654','Edgardo Rubén',  'Gallardo Infante',    '933221100',NULL,                    'Jr. Apurímac 123, Cajamarca',              '1987-10-02'),
    (2,'20601345678','Restaurante El Zarco S.R.L.',NULL,   '076-363344','elzarco@gmail.com',   'Jr. Del Comercio 200, Cajamarca',           NULL),
    (2,'20601456789','Pensión Universitaria Cajamarca E.I.R.L.',NULL,'076-364455',NULL,         'Jr. Silva Santisteban 456, Cajamarca',      NULL),
    (1,'85012347','Katia Miluska',  'Pérez Infantes',      '922110099','kperez@gmail.com',     'Barrio San Sebastián 78, Cajamarca',        '1999-01-30'),
    (1,'39876543','Napoleón',       'Mestanza Ortiz',      '911009988',NULL,                    'Jr. Kunturkanki 56, Cajamarca',             '1973-06-17'),
    (1,'76543219','Yessica Paola',  'Culqui Angulo',       '900998877','yculqui@gmail.com',    'Av. Hoyos Rubio 123, Cajamarca',           '2005-04-11'),
    (1,'61234780','Francisco',      'Muñoz Cabanillas',    '989887766',NULL,                    'Jr. Puno 890, Cajamarca',                   '1984-08-28'),
    (1,'49012367','Esperanza',      'Cabellos Tirado',     '978776655','ecabellos@gmail.com',  'Jr. Cajabamba 234, Cajamarca',              '1992-11-14'),
    (1,'57890124','Cristian Iván',  'Díaz Guevara',        '967665544',NULL,                    'Av. Los Eucaliptos 567, Los Baños del Inca','1996-02-23'),
    (1,'42109876','Rosario Luz',    'Terán Marín',         '956554433','rteran@gmail.com',     'Jr. Bolívar 321, Cajamarca',                '1981-09-07'),
    (1,'70987654','Jhonatan',       'Chilón Herrera',      '945443322',NULL,                    'Barrio Pueblo Libre 89, Cajamarca',         '2002-12-19'),
    (1,'53678901','Verónica Luz',   'Briones Sandoval',    '934332211','vbriones@gmail.com',   'Jr. Santa Teresa 45, Cajamarca',            '1994-07-03'),
    (1,'61890234','Marco Antonio',  'Cabanillas Díaz',     '923221100',NULL,                    'Av. Atahualpa 670, Cajamarca',             '1983-01-22'),
    (1,'47012345','Gladys Marleni', 'Idrogo Vásquez',      '912110099','gladysi@gmail.com',    'Jr. Revilla Pérez 234, Cajamarca',         '1989-05-16'),
    (1,'83456789','Humberto',       'Ríos Castope',        '901009988',NULL,                    'Barrio Chontapaccha 12, Cajamarca',         '1977-10-30'),
    (1,'60123478','Silvia del Rosario','Mendo Campos',     '990998877','silviamendo@gmail.com','Jr. Dos de Mayo 890, Cajamarca',            '1991-03-08'),
    (2,'20601567890','Bodega La Esperanza E.I.R.L.',NULL,  '076-365566',NULL,                   'Av. San Martín 123, Cajamarca',             NULL),
    (1,'74321098','Yolanda',        'Cerna Peralta',       '979887766',NULL,                    'Jr. Amazonas 456, Cajamarca',              '1986-12-25'),
    (1,'51234089','Darwin',         'Linares Julón',       '968776655','dlinares@gmail.com',   'Av. Los Fresnos 789, Cajamarca',            '1998-08-14'),
    (1,'44890123','Milagros',       'Vásquez Tocas',       '957665544',NULL,                    'Jr. Junín 123, Cajamarca',                 '1976-04-05'),
    (1,'68012347','Rubén Elías',    'Cruzado Malca',       '946554433','rcruzado@gmail.com',   'Psj. La Merced 56, Cajamarca',             '2001-11-18'),
    (1,'55678902','Patricia',       'Quiroz Espinoza',     '935443322',NULL,                    'Jr. Cruz de Piedra 890, Cajamarca',        '1988-06-27'),
    (1,'42890165','Edgar Augusto',  'Bazán Díaz',          '924332211','ebazan@gmail.com',     'Av. Independencia 567, Cajamarca',         '1979-02-11'),
    (2,'20601678901','Minimarket Don Pepe S.R.L.',NULL,    '076-366677',NULL,                   'Jr. Lima 345, Cajamarca',                   NULL),
    (1,'79012356','Roxana del Pilar','Chiclote Guevara',   '913221100',NULL,                    'Barrio La Tulpuna 34, Cajamarca',           '1995-09-02'),
    (1,'65432109','Teodoro',        'Huaccha Ramírez',     '902110099','thuaccha@gmail.com',   'Jr. José Gálvez 678, Cajamarca',           '1971-07-20');
GO

-- CORRECCIÓN ERROR 1: Deshabilitar triggers ANTES de insertar compras

DISABLE TRIGGER trg_CompraAumentaStock ON DetalleCompras;
DISABLE TRIGGER trg_VentaDescontaStock ON DetalleVentas;
GO

-- COMPRAS (12 compras)

-- COMPRA 1: Gloria — Efectivo
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (1,1,1,'F001-00123','2025-01-05',1320.00,0.00,1320.00,1320.00,NULL,'PAGADA');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (1, 1,'GL-2501','2026-01-31',120,2.80, 336.00),
    (1, 2,'GL-2502','2026-01-31', 80,2.80, 224.00),
    (1, 5,'GL-2503','2026-06-30',100,2.10, 210.00),
    (1, 6,'GL-2504','2026-06-30', 80,2.00, 160.00),
    (1, 7,'GL-2505','2025-08-15', 50,4.20, 210.00),
    (1,13,'GL-2506','2026-03-31', 25,5.50, 137.50),
    (1,14,'GL-2507','2026-03-31', 20,5.30, 106.00);
UPDATE Productos SET StockActual=StockActual+120 WHERE ProductoID= 1;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID= 2;
UPDATE Productos SET StockActual=StockActual+100 WHERE ProductoID= 5;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID= 6;
UPDATE Productos SET StockActual=StockActual+ 50 WHERE ProductoID= 7;
UPDATE Productos SET StockActual=StockActual+ 25 WHERE ProductoID=13;
UPDATE Productos SET StockActual=StockActual+ 20 WHERE ProductoID=14;

-- COMPRA 2: Alicorp — Crédito
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (3,1,6,'F003-00456','2025-01-08',2050.00,369.00,2419.00,0.00,'2025-02-22','PENDIENTE');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (2,22,'AC-2501','2026-06-30', 80,6.80, 544.00),
    (2,23,'AC-2502','2026-06-30', 60,6.20, 372.00),
    (2,25,'FD-2501','2026-09-30', 90,1.80, 162.00),
    (2,26,'FD-2502','2026-09-30', 70,1.00,  70.00),
    (2,27,'FD-2503','2026-09-30', 80,1.60, 128.00),
    (2,49,'DT-2501','2027-03-31', 40,4.50, 180.00),
    (2,50,'DT-2502','2027-03-31', 30,6.20, 186.00),
    (2,51,'LV-2501','2027-06-30', 50,1.80,  90.00),
    (2,33,'AJ-2501','2026-12-31', 50,1.20,  60.00),
    (2,34,'SZ-2501','2026-12-31', 40,1.50,  60.00);
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=22;
UPDATE Productos SET StockActual=StockActual+ 60 WHERE ProductoID=23;
UPDATE Productos SET StockActual=StockActual+ 90 WHERE ProductoID=25;
UPDATE Productos SET StockActual=StockActual+ 70 WHERE ProductoID=26;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=27;
UPDATE Productos SET StockActual=StockActual+ 40 WHERE ProductoID=49;
UPDATE Productos SET StockActual=StockActual+ 30 WHERE ProductoID=50;
UPDATE Productos SET StockActual=StockActual+ 50 WHERE ProductoID=51;
UPDATE Productos SET StockActual=StockActual+ 50 WHERE ProductoID=33;
UPDATE Productos SET StockActual=StockActual+ 40 WHERE ProductoID=34;

-- COMPRA 3: Distribuidora Cajamarca — Efectivo
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (5,1,1,'B005-00789','2025-01-10',1080.00,0.00,1080.00,1080.00,NULL,'PAGADA');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (3,15, NULL,NULL,              200,2.60, 520.00),
    (3,16, NULL,NULL,              150,2.20, 330.00),
    (3,32,'SAL-2501','2028-12-31',  80,0.90,  72.00),
    (3,29,'ME-2501', '2026-09-30',  50,3.50, 175.00);
UPDATE Productos SET StockActual=StockActual+200 WHERE ProductoID=15;
UPDATE Productos SET StockActual=StockActual+150 WHERE ProductoID=16;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=32;
UPDATE Productos SET StockActual=StockActual+ 50 WHERE ProductoID=29;

-- COMPRA 4: Nestlé — Transferencia
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (2,1,5,'F002-00321','2025-01-12',1180.00,212.40,1392.40,1392.40,NULL,'PAGADA');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (4,58,'SH-2501','2026-08-31', 35,5.50, 192.50),
    (4,59,'SH-2502','2026-08-31', 30,6.00, 180.00),
    (4,47,'CA-2501','2026-09-30', 40,4.50, 180.00),
    (4,42,'NE-2501','2026-12-31', 80,1.00,  80.00),
    (4,55,'JB-2501','2027-01-31', 60,2.20, 132.00),
    (4,56,'JB-2502','2027-01-31', 45,1.50,  67.50),
    (4,60,'PD-2501','2027-01-31', 40,2.80, 112.00),
    (4,66,'MI-2501','2026-06-30', 60,1.00,  60.00),
    (4,48,'TE-2501','2026-06-30', 30,2.00,  60.00);
UPDATE Productos SET StockActual=StockActual+ 35 WHERE ProductoID=58;
UPDATE Productos SET StockActual=StockActual+ 30 WHERE ProductoID=59;
UPDATE Productos SET StockActual=StockActual+ 40 WHERE ProductoID=47;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=42;
UPDATE Productos SET StockActual=StockActual+ 60 WHERE ProductoID=55;
UPDATE Productos SET StockActual=StockActual+ 45 WHERE ProductoID=56;
UPDATE Productos SET StockActual=StockActual+ 40 WHERE ProductoID=60;
UPDATE Productos SET StockActual=StockActual+ 60 WHERE ProductoID=66;
UPDATE Productos SET StockActual=StockActual+ 30 WHERE ProductoID=48;

-- COMPRA 5: San Fernando — Efectivo
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (8,1,1,'F008-00101','2025-01-15',450.00,0.00,450.00,450.00,NULL,'PAGADA');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (5,62,'SF-2501','2025-04-30', 20, 9.00, 180.00),
    (5,63,'SF-2502','2025-04-30', 40, 5.50, 220.00),
    (5,26,'SF-2503','2026-09-30', 50, 1.00,  50.00);
UPDATE Productos SET StockActual=StockActual+20 WHERE ProductoID=62;
UPDATE Productos SET StockActual=StockActual+40 WHERE ProductoID=63;
UPDATE Productos SET StockActual=StockActual+50 WHERE ProductoID=26;

-- COMPRA 6: Backus — Transferencia
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (4,1,5,'F004-00210','2025-01-18',750.00,0.00,750.00,750.00,NULL,'PAGADA');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (6,37,'BK-2501','2025-12-31',120,1.20, 144.00),
    (6,38,'BK-2502','2025-12-31', 80,2.50, 200.00),
    (6,39,'BK-2503','2025-12-31', 80,2.50, 200.00),
    (6,40,'BK-2504','2025-12-31', 80,1.10,  88.00),
    (6,44,'BK-2505','2025-12-31', 80,0.80,  64.00),
    (6,45,'BK-2506','2025-12-31', 60,0.90,  54.00);
UPDATE Productos SET StockActual=StockActual+120 WHERE ProductoID=37;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=38;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=39;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=40;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=44;
UPDATE Productos SET StockActual=StockActual+ 60 WHERE ProductoID=45;

-- COMPRA 7: Inversiones Cajamarca — Crédito
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (6,1,6,'B006-00050','2025-01-22',620.00,0.00,620.00,0.00,'2025-02-06','PENDIENTE');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (7,16, NULL,NULL,              100,2.20, 220.00),
    (7,15, NULL,NULL,              100,2.60, 260.00),
    (7,19,'AZ-2502','2026-12-31',  50,2.20, 110.00),
    (7,32,'SAL-2502','2028-12-31', 50,0.90,  45.00);
UPDATE Productos SET StockActual=StockActual+100 WHERE ProductoID=16;
UPDATE Productos SET StockActual=StockActual+100 WHERE ProductoID=15;
UPDATE Productos SET StockActual=StockActual+ 50 WHERE ProductoID=19;
UPDATE Productos SET StockActual=StockActual+ 50 WHERE ProductoID=32;

-- COMPRA 8: Gloria — Yape
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (1,1,2,'F001-00150','2025-01-28',860.00,0.00,860.00,860.00,NULL,'PAGADA');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (8, 1,'GL-2510','2026-03-31',100,2.80, 280.00),
    (8, 3,'GL-2511','2026-03-31', 60,2.75, 165.00),
    (8, 4,'GL-2512','2026-03-31', 20,16.00,320.00),
    (8, 9,'GL-2513','2025-09-30', 60, 1.10,  66.00),
    (8,10,'GL-2514','2025-09-30', 50, 1.05,  52.50);
UPDATE Productos SET StockActual=StockActual+100 WHERE ProductoID= 1;
UPDATE Productos SET StockActual=StockActual+ 60 WHERE ProductoID= 3;
UPDATE Productos SET StockActual=StockActual+ 20 WHERE ProductoID= 4;
UPDATE Productos SET StockActual=StockActual+ 60 WHERE ProductoID= 9;
UPDATE Productos SET StockActual=StockActual+ 50 WHERE ProductoID=10;

-- COMPRA 9: Alicorp — Efectivo
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (3,1,1,'F003-00500','2025-02-03',1350.00,243.00,1593.00,1593.00,NULL,'PAGADA');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (9,22,'AC-2510','2026-09-30', 80,6.80, 544.00),
    (9,24,'AC-2511','2026-09-30', 60,6.50, 390.00),
    (9,53,'LE-2501','2027-06-30', 40,3.50, 140.00),
    (9,54,'DS-2501','2027-06-30', 30,4.80, 144.00),
    (9,64,'GA-2501','2026-06-30', 80,1.00,  80.00),
    (9,65,'GA-2502','2026-06-30', 80,1.00,  80.00),
    (9,35,'AT-2501','2026-12-31', 60,3.20, 192.00);
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=22;
UPDATE Productos SET StockActual=StockActual+ 60 WHERE ProductoID=24;
UPDATE Productos SET StockActual=StockActual+ 40 WHERE ProductoID=53;
UPDATE Productos SET StockActual=StockActual+ 30 WHERE ProductoID=54;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=64;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=65;
UPDATE Productos SET StockActual=StockActual+ 60 WHERE ProductoID=35;

-- COMPRA 10: Molinos del Norte — Efectivo
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (7,1,1,'B007-00010','2025-02-06',780.00,0.00,780.00,780.00,NULL,'PAGADA');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (10,15, NULL,NULL, 200,2.60, 520.00),
    (10,17,'MN-2501','2027-01-31', 80,2.70, 216.00),
    (10,30,'MN-2502','2026-12-31', 50,4.20, 210.00);
UPDATE Productos SET StockActual=StockActual+200 WHERE ProductoID=15;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=17;
UPDATE Productos SET StockActual=StockActual+ 50 WHERE ProductoID=30;

-- COMPRA 11: Nestlé — Crédito
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (2,1,6,'F002-00400','2025-02-10',920.00,165.60,1085.60,0.00,'2025-03-12','PENDIENTE');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (11,58,'SH-2510','2026-10-31', 30,5.50, 165.00),
    (11,59,'SH-2511','2026-10-31', 25,6.00, 150.00),
    (11,61,'PD-2510','2027-03-31', 50,2.80, 140.00),
    (11,67,'MI-2510','2026-09-30', 80,1.00,  80.00),
    (11,47,'CA-2510','2026-12-31', 40,4.50, 180.00),
    (11,48,'TE-2510','2026-12-31', 30,2.00,  60.00),
    (11,42,'NE-2510','2026-12-31', 80,1.10,  88.00);
UPDATE Productos SET StockActual=StockActual+ 30 WHERE ProductoID=58;
UPDATE Productos SET StockActual=StockActual+ 25 WHERE ProductoID=59;
UPDATE Productos SET StockActual=StockActual+ 50 WHERE ProductoID=61;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=67;
UPDATE Productos SET StockActual=StockActual+ 40 WHERE ProductoID=47;
UPDATE Productos SET StockActual=StockActual+ 30 WHERE ProductoID=48;
UPDATE Productos SET StockActual=StockActual+ 80 WHERE ProductoID=42;

-- COMPRA 12: San Fernando + Distribuidora Cajamarca — Efectivo
INSERT INTO Compras (ProveedorID,UsuarioID,FormaPagoID,NumeroDocumento,
                     FechaCompra,SubTotal,IGV,Total,MontoPagado,FechaVencPago,EstadoPago)
VALUES (5,1,1,'B005-00820','2025-02-14',670.00,0.00,670.00,670.00,NULL,'PAGADA');
INSERT INTO DetalleCompras (CompraID,ProductoID,NumeroLote,FechaVencLote,Cantidad,PrecioUnitario,Subtotal) VALUES
    (12,62,'SF-2510','2025-05-31', 15, 9.00, 135.00),
    (12,63,'SF-2511','2025-05-31', 30, 5.50, 165.00),
    (12,11,'DC-2501','2026-01-31', 20, 9.50, 190.00),
    (12,12, NULL,NULL,             20, 7.00, 140.00),
    (12,36,'SA-2501','2026-12-31', 40, 3.50, 140.00);
UPDATE Productos SET StockActual=StockActual+15 WHERE ProductoID=62;
UPDATE Productos SET StockActual=StockActual+30 WHERE ProductoID=63;
UPDATE Productos SET StockActual=StockActual+20 WHERE ProductoID=11;
UPDATE Productos SET StockActual=StockActual+20 WHERE ProductoID=12;
UPDATE Productos SET StockActual=StockActual+40 WHERE ProductoID=36;
GO


-- VENTAS (40 ventas)

-- VENTA 1: Boleta | Efectivo | Cliente 1
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(1,2,1,1,'B001','00000001','2025-01-20 09:15:00',30.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (1, 1,2,3.50,0.00, 7.00),(1,15,2,3.20,0.00, 6.40),(1, 3,1,3.40,0.00, 3.40),
    (1,32,1,1.30,0.00, 1.30),(1,42,2,1.50,0.00, 3.00),(1,64,2,1.50,0.00, 3.00);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=1;

-- VENTA 2: Boleta | Yape | Cliente 2
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(2,2,1,2,'B001','00000002','2025-01-20 10:30:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (2,22,1,8.50,0.50, 8.00),(2,25,2,2.50,0.00, 5.00),(2,44,1,1.20,0.00, 1.20),(2,19,2,2.80,0.00, 5.60);

-- VENTA 3: Factura | Transferencia | Cliente 6 (Ferretería)
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(6,2,2,5,'F001','00000001','2025-01-21 08:45:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (3, 1,5,3.50,0.00,17.50),(3,16,10,2.80,0.00,28.00),(3,22,3,8.50,0.00,25.50),(3,19,5,2.80,0.00,14.00);

-- VENTA 4: Boleta | Plin | Cliente 3
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(3,2,1,3,'B001','00000003','2025-01-21 11:20:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (4,44,2,1.20,0.00,2.40),(4,45,1,1.40,0.00,1.40),(4,55,1,3.00,0.00,3.00),
    (4,58,1,7.50,0.00,7.50),(4,60,1,3.80,0.00,3.80),(4,61,1,3.80,0.00,3.80);

-- VENTA 5: Boleta | Efectivo | Cliente 4 — volumen arroz
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(4,2,1,1,'B001','00000004','2025-01-22 07:30:00',60.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (5,15,10,3.20,0.00,32.00),(5,16, 5,2.80,0.00,14.00),(5,32, 2,1.30,0.00, 2.60);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=5;

-- VENTA 6: Boleta | Tarjeta | Cliente 5 — higiene
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(5,2,1,4,'B001','00000005','2025-01-22 14:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (6,55,2,3.00,0.00,6.00),(6,56,3,2.20,0.00,6.60),(6,58,1,7.50,0.00,7.50),(6,60,1,3.80,0.00,3.80);

-- VENTA 7: Nota de Venta | Efectivo | sin cliente
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(NULL,2,3,1,'N001','00000001','2025-01-23 09:10:00',15.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (7,37,2,2.00,0.00,4.00),(7,45,2,1.40,0.00,2.80),(7,64,2,1.50,0.00,3.00);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=7;

-- VENTA 8: Boleta ANULADA | Cliente 7
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado,Observaciones)
VALUES(7,2,1,1,'B001','00000006','2025-01-23 10:00:00','ANULADA','Error al cobrar, se anuló antes de entregar productos');

-- VENTA 9: Boleta | Yape | Cliente 8
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(8,2,1,2,'B001','00000007','2025-01-24 16:45:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (9,7,1,5.50,0.50,5.00),(9,38,2,3.50,0.00,7.00),(9,47,1,6.00,0.00,6.00),(9,42,2,1.50,0.00,3.00);

-- VENTA 10: Boleta | Efectivo | Cliente 9 — compra grande
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(9,2,1,1,'B001','00000008','2025-01-25 08:00:00',100.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (10, 1,4,3.50,0.00,14.00),(10,15,5,3.20,0.00,16.00),(10,16,3,2.80,0.00, 8.40),
    (10,22,2,8.50,0.00,17.00),(10,44,3,1.20,0.00, 3.60),(10,25,2,2.50,0.00, 5.00);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=10;

-- VENTA 11: Factura | Crédito | Cliente 16 (El Zarco)
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(16,2,2,6,'F001','00000002','2025-01-27 07:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (11, 5,10,2.80,0.00,28.00),(11, 6,10,2.70,0.00,27.00),(11, 1,12,3.50,0.00,42.00),
    (11,62, 5,12.50,0.00,62.50),(11,63,10,7.50,0.00,75.00);

-- VENTA 12: Boleta | Yape | Cliente 10
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(10,2,1,2,'B001','00000009','2025-01-28 12:30:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (12,64,3,1.50,0.00,4.50),(12,66,2,1.20,0.00,2.40),(12,60,1,3.80,0.00,3.80),
    (12,61,1,3.80,0.00,3.80),(12,32,2,1.30,0.00,2.60);

-- VENTA 13: Boleta | Tarjeta | Cliente 11
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(11,2,1,4,'B001','00000010','2025-01-29 15:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (13, 4,1,19.50,0.00,19.50),(13, 7,2,5.50,0.50,10.50),(13,42,3,1.60,0.00,4.80),(13,21,2,2.90,0.00,5.80);

-- VENTA 14: Nota de Venta | Efectivo | sin cliente
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(NULL,2,3,1,'N001','00000002','2025-01-30 09:00:00',20.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (14,25,1,2.50,0.00,2.50),(14,19,2,2.80,0.00,5.60),(14,32,2,1.30,0.00,2.60),(14,42,3,1.50,0.00,4.50);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=14;

-- VENTA 15: Boleta | Plin | Cliente 12
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(12,2,1,3,'B001','00000011','2025-02-01 10:15:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (15, 1,6,3.50,0.00,21.00),(15, 5,4,2.80,0.00,11.20),(15,13,1,7.20,0.00,7.20),
    (15,55,2,3.00,0.00,6.00),(15,60,1,3.80,0.00,3.80);

-- VENTA 16: Factura | Transferencia | Cliente 17 (Pensión Universitaria)
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(17,2,2,5,'F001','00000003','2025-02-03 08:30:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (16, 1,20,3.50,0.10,68.00),(16, 5,15,2.80,0.00,42.00),(16,16,10,2.80,0.00,28.00),
    (16,19,10,2.80,0.00,28.00),(16,15,10,3.20,0.00,32.00),(16,22, 5,8.50,0.00,42.50);

-- VENTA 17: Boleta | Efectivo | Cliente 13
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(13,2,1,1,'B001','00000012','2025-02-05 11:40:00',50.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (17,19,2,2.80,0.00,5.60),(17,22,1,8.50,0.00,8.50),(17,58,1,7.50,0.00,7.50),
    (17,59,1,8.00,0.00,8.00),(17,64,3,1.50,0.00,4.50),(17,66,2,1.20,0.00,2.40);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=17;

-- VENTA 18: Boleta | Yape | Cliente 14
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(14,2,1,2,'B001','00000013','2025-02-06 17:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (18,37,3,2.00,0.00,6.00),(18,38,2,3.50,0.00,7.00),(18,42,4,1.50,0.00,6.00),(18,43,2,1.60,0.00,3.20);

-- VENTA 19: Boleta | Efectivo | Cliente 18
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(18,2,1,1,'B001','00000014','2025-02-08 08:45:00',40.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (19,30,2,5.50,0.00,11.00),(19,29,2,4.50,0.00, 9.00),
    (19,32,3,1.30,0.00, 3.90),(19, 1,4,3.50,0.00,14.00);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=19;

-- VENTA 20: Boleta | Tarjeta | Cliente 20
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(20,2,1,4,'B001','00000015','2025-02-10 14:30:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (20, 8,2,5.30,0.00,10.60),(20, 7,1,5.50,0.00, 5.50),(20,20,2,5.20,0.00,10.40),
    (20,34,2,2.20,0.00, 4.40),(20,47,1,6.00,0.00, 6.00),(20,64,2,1.50,0.00, 3.00);

-- VENTA 21: Boleta | Efectivo | Cliente 21
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(21,2,1,1,'B001','00000016','2025-02-11 09:00:00',25.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (21,35,2,4.20,0.00,8.40),(21,36,1,4.80,0.00,4.80),(21,44,3,1.20,0.00,3.60),(21,32,2,1.30,0.00,2.60);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=21;

-- VENTA 22: Boleta | Yape | Cliente 22
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(22,2,1,2,'B001','00000017','2025-02-11 11:30:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (22, 5,4,2.80,0.00,11.20),(22, 6,3,2.70,0.00,8.10),(22,48,2,2.80,0.00,5.60),(22,33,2,1.80,0.00,3.60);

-- VENTA 23: Nota de Venta | Efectivo | sin cliente
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(NULL,2,3,1,'N001','00000003','2025-02-12 08:00:00',10.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (23,64,2,1.50,0.00,3.00),(23,66,2,1.20,0.00,2.40),(23,67,2,1.50,0.00,3.00);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=23;

-- VENTA 24: Boleta | Plin | Cliente 23
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(23,2,1,3,'B001','00000018','2025-02-12 13:15:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (24, 3,2,3.40,0.00,6.80),(24,10,2,1.45,0.00,2.90),(24,23,1,7.80,0.00,7.80),(24,32,1,1.30,0.00,1.30);

-- VENTA 25: Boleta | Efectivo | Cliente 24
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(24,2,1,1,'B001','00000019','2025-02-13 10:00:00',50.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (25,11,2,13.00,0.00,26.00),(25,12,1,10.00,0.00,10.00),(25, 1,2, 3.50,0.00, 7.00);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=25;

-- VENTA 26: Factura | Crédito | Cliente 31 (Bodega La Esperanza)
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(31,2,2,6,'F001','00000004','2025-02-14 08:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (26, 1,24,3.50,0.10,82.80),(26,15,20,3.20,0.00,64.00),(26,22,10,8.50,0.00,85.00),
    (26,37,24,2.00,0.00,48.00),(26,38,12,3.50,0.00,42.00);

-- VENTA 27: Boleta | Yape | Cliente 25
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(25,2,1,2,'B001','00000020','2025-02-15 16:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (27,55,1,3.00,0.00,3.00),(27,57,2,2.50,0.00,5.00),(27,60,1,3.80,0.00,3.80),(27,61,1,3.80,0.00,3.80);

-- VENTA 28: Boleta | Efectivo | Cliente 26
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(26,2,1,1,'B001','00000021','2025-02-17 07:30:00',30.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (28,15,5,3.20,0.00,16.00),(28,19,2,2.80,0.00,5.60),(28,32,1,1.30,0.00,1.30),(28,33,2,1.80,0.00,3.60);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=28;

-- VENTA 29: Boleta | Tarjeta | Cliente 27
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(27,2,1,4,'B001','00000022','2025-02-18 12:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (29,49,1,6.00,0.00,6.00),(29,51,2,2.50,0.00,5.00),(29,53,1,5.00,0.00,5.00),(29,57,2,2.50,0.00,5.00);

-- VENTA 30: Boleta | Yape | Cliente 28
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(28,2,1,2,'B001','00000023','2025-02-19 09:45:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (30, 9,4,1.50,0.00,6.00),(30,10,3,1.45,0.00,4.35),(30,43,2,1.60,0.00,3.20),(30,67,3,1.50,0.00,4.50);

-- VENTA 31: Nota de Venta | Efectivo | sin cliente
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(NULL,2,3,1,'N001','00000004','2025-02-20 08:30:00',20.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (31,37,3,2.00,0.00,6.00),(31,44,4,1.20,0.00,4.80),(31,26,2,1.50,0.00,3.00);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=31;

-- VENTA 32: Boleta | Plin | Cliente 29
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(29,2,1,3,'B001','00000024','2025-02-20 14:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (32,63,2,7.50,0.00,15.00),(32,62,1,12.50,0.00,12.50),(32,35,2,4.20,0.00,8.40);

-- VENTA 33: Boleta | Efectivo | Cliente 30
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(30,2,1,1,'B001','00000025','2025-02-21 09:00:00',20.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (33,25,2,2.50,0.00,5.00),(33,26,3,1.50,0.00,4.50),(33,33,2,1.80,0.00,3.60),(33,48,1,2.80,0.00,2.80);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=33;

-- VENTA 34: Factura | Transferencia | Cliente 38 (Minimarket Don Pepe)
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(38,2,2,5,'F001','00000005','2025-02-22 07:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (34, 1,30,3.50,0.10,103.50),(34, 5,20,2.80,0.00,56.00),(34,22,15,8.50,0.00,127.50),
    (34,37,30,2.00,0.00,60.00),(34,15,20,3.20,0.00,64.00);

-- VENTA 35: Boleta | Yape | Cliente 32
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(32,2,1,2,'B001','00000026','2025-02-23 11:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (35, 1,4,3.50,0.00,14.00),(35,13,1,7.20,0.00,7.20),(35,55,1,3.00,0.00,3.00),(35,60,2,3.80,0.00,7.60);

-- VENTA 36: Boleta | Efectivo | Cliente 33
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(33,2,1,1,'B001','00000027','2025-02-24 10:30:00',30.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (36,17,3,3.30,0.00,9.90),(36,21,2,2.90,0.00,5.80),(36,32,2,1.30,0.00,2.60),(36,47,1,6.00,0.00,6.00);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=36;

-- VENTA 37: Boleta | Tarjeta | Cliente 34
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(34,2,1,4,'B001','00000028','2025-02-24 14:00:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (37,29,2,4.50,0.00,9.00),(37,30,1,5.50,0.00,5.50),(37,19,3,2.80,0.00,8.40),(37,37,2,2.00,0.00,4.00);

-- VENTA 38: Boleta | Plin | Cliente 35
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(35,2,1,3,'B001','00000029','2025-02-25 09:15:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (38, 5,5,2.80,0.00,14.00),(38, 6,4,2.70,0.00,10.80),(38,48,1,2.80,0.00,2.80),(38,32,2,1.30,0.00,2.60);

-- VENTA 39: Boleta | Yape | Cliente 36
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,Estado)
VALUES(36,2,1,2,'B001','00000030','2025-02-26 16:30:00','COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (39,58,1,7.50,0.00,7.50),(39,59,1,8.00,0.00,8.00),(39,60,1,3.80,0.00,3.80),(39,67,2,1.50,0.00,3.00);

-- VENTA 40: Boleta | Efectivo | Cliente 40
INSERT INTO Ventas(ClienteID,UsuarioID,TipoComprobanteID,FormaPagoID,NumeroSerie,NumeroCorrelativo,FechaVenta,MontoRecibido,Estado)
VALUES(40,2,1,1,'B001','00000031','2025-02-27 08:00:00',50.00,'COMPLETADA');
INSERT INTO DetalleVentas(VentaID,ProductoID,Cantidad,PrecioUnitario,Descuento,Subtotal) VALUES
    (40, 1,4,3.50,0.00,14.00),(40,22,1,8.50,0.00,8.50),(40,15,4,3.20,0.00,12.80),
    (40,37,2,2.00,0.00, 4.00),(40,64,3,1.50,0.00, 4.50),(40,66,3,1.20,0.00, 3.60);
UPDATE Ventas SET Vuelto=MontoRecibido-Total WHERE VentaID=40;
GO

-- DEVOLUCIONES (6 devoluciones)
INSERT INTO Devoluciones
    (VentaID,ProductoID,UsuarioID,Motivo,Cantidad,PrecioUnitario,
     MontoDevuelto,TipoReposicion,FechaDevolucion,Observaciones)
VALUES
    (1, 1,2,'PRODUCTO_DEFECTUOSO',1,3.50,3.50,'CAMBIO_PRODUCTO',
     '2025-01-21 10:00:00','Leche venía golpeada, se hizo cambio en tienda'),

    (4,44,2,'PRODUCTO_VENCIDO',2,1.20,2.40,'REEMBOLSO',
     '2025-01-22 09:30:00','Cliente devolvió agua próxima a vencer'),

    (2,22,2,'ERROR_COBRO',1,8.50,8.50,'NOTA_CREDITO',
     '2025-01-20 11:00:00','Se cobró aceite de más, se emitió nota de crédito'),

    (9,38,2,'PRODUCTO_DEFECTUOSO',1,3.50,3.50,'CAMBIO_PRODUCTO',
     '2025-01-25 09:00:00','Gaseosa sin gas, cliente solicitó cambio de producto'),

   
    (12,66,2,'CAMBIO_MENTE',1,1.20,1.20,'REEMBOLSO',
     '2025-01-28 14:00:00','Cliente indicó que el sabor no era de su agrado'),

    (16, 5,2,'PRODUCTO_DEFECTUOSO',2,2.80,5.60,'CAMBIO_PRODUCTO',
     '2025-02-04 08:30:00','Leche evaporada abollada, se reemplazaron 2 unidades');
GO

-- RE-HABILITAR TRIGGERS
ENABLE TRIGGER trg_CompraAumentaStock ON DetalleCompras;
ENABLE TRIGGER trg_VentaDescontaStock ON DetalleVentas;
GO

-- VERIFICACIÓN FINAL
SELECT 'TiposDocumento'AS Tabla, COUNT(*) AS Registros FROM TiposDocumento UNION ALL
SELECT 'TiposComprobante',COUNT(*) FROM TiposComprobante UNION ALL
SELECT 'FormasPago', COUNT(*) FROM FormasPago UNION ALL
SELECT 'UnidadesMedida',COUNT(*) FROM UnidadesMedida UNION ALL
SELECT 'Marcas',COUNT(*) FROM Marcas UNION ALL
SELECT 'Categorias',COUNT(*) FROM Categorias UNION ALL
SELECT 'Proveedores',COUNT(*) FROM Proveedores UNION ALL
SELECT 'Empleados',COUNT(*) FROM Empleados UNION ALL
SELECT 'Usuarios',COUNT(*) FROM Usuarios UNION ALL
SELECT 'Productos',COUNT(*) FROM Productos UNION ALL
SELECT 'Clientes',COUNT(*) FROM Clientes UNION ALL
SELECT 'Compras',COUNT(*) FROM Compras UNION ALL
SELECT 'DetalleCompras',COUNT(*) FROM DetalleCompras UNION ALL
SELECT 'Ventas',COUNT(*) FROM Ventas UNION ALL
SELECT 'DetalleVentas',COUNT(*) FROM DetalleVentas  UNION ALL
SELECT 'Devoluciones',COUNT(*) FROM Devoluciones;
GO
