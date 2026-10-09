# Gestión Cine Profesional · versión 2.2

Aplicación de escritorio en C# Windows Forms, .NET 8 y SQL Server. Se entrega como una versión nueva; el archivo `RESPALDO_Proyecto_cine_original.zip` conserva el proyecto que enviaste sin modificaciones.

**Si ya ejecutaste los scripts SQL 01 y 02, no tenés que ejecutarlos otra vez ni recrear GestionCineDB.** Abrí esta nueva solución, compilá y configurá la conexión con tu instancia SQL Server.

Las ventanas se adaptan al espacio libre del escritorio; el panel de edición se puede desplazar cuando no entra completo.

## Instalación en otra computadora

1. Instalar SQL Server Express, SQL Server Management Studio y Visual Studio 2022 con «Desarrollo de escritorio con .NET» y SDK .NET 8.
2. Abrir SSMS con autenticación de Windows. **Si no existe** `GestionCineDB`, ejecutar **en este orden** `SQL/01_Instalar_GestionCineDB.sql` y `SQL/02_Actualizacion_Profesional.sql`.
3. **Si ya existe** la base `GestionCineDB` con las tablas originales, hacer una copia de seguridad y ejecutar **solo** `SQL/02_Actualizacion_Profesional.sql`. Esta mejora agrega usuarios y un procedimiento de venta segura sin borrar tus datos.
4. Abrir `GestionCine_WindowsForms.sln` en Visual Studio 2022. Restaurar NuGet y compilar. Ejecutar con F5.
5. En la ventana de inicio, pulsar **Configurar SQL Server**. Escribir el nombre de la instancia de esa computadora, por ejemplo `.\SQLEXPRESS` o `NOMBREPC\SQLEXPRESS`; pulsar **Guardar y probar**. Se guarda en `conexion.json` junto al ejecutable de la aplicación.
6. En una instalación nueva, escribir `admin` como usuario y elegir una contraseña de al menos 8 caracteres. El primer intento crea la cuenta y abre la sesión. El administrador puede abrir **Usuarios** y crear cuentas con rol Registro o Consulta.

La cuenta de Windows con la que se ejecute la aplicación debe tener acceso a `GestionCineDB`. Si se copia solo el proyecto fuente, `conexion.json` se configura de nuevo al ejecutarlo.

## Funciones

- **Películas, clientes, productos, funciones, salas, butacas, empleados y géneros:** listar, buscar, crear y editar desde formularios independientes.
- **Desactivar:** películas, clientes, productos, funciones, salas, butacas y empleados permanecen en SQL Server. Géneros no tienen columna de estado y se conservan sin botón de eliminación.
- **Ventas:** consultar historial y registrar una venta con cliente, empleado, función y butaca opcionales, o producto. La transacción valida actividad, evita repetir butaca, verifica existencias, descuenta inventario y calcula subtotal, 15 % de impuesto y total. Una venta admite **un boleto** porque la tabla `Venta` tiene una sola columna `ButacaId`; para más boletos se hacen ventas separadas.
- **Roles:** Administrador puede administrar usuarios; Administrador y Registro pueden crear y editar; Consulta solo visualiza.
- **Consultas SQL:** se usan parámetros para texto y valores ingresados por usuarios. Nombres de tablas y columnas en `CrudController` provienen exclusivamente de definiciones fijas del programa.
- **Versiones y persistencia:** los cambios se guardan en SQL Server; el ZIP de respaldo conserva el proyecto inicial.

## Formularios editables

Para abrir el diseñador sin cargar SQL, se usan constructores vacíos que solo crean controles. En Visual Studio, expandir `GestionCine_WindowsForms`, hacer clic derecho en `FrmClientes.cs`, `FrmPeliculas.cs`, `FrmVentas.cs`, `MainForm.cs` o el formulario deseado y elegir **Ver diseñador** (Mayús + F7). Los controles con nombre se declaran en su archivo `.Designer.cs`. Abrir el archivo `.cs` principal para editar eventos y lógica. No cambiar los nombres de controles sin actualizar las referencias en el código.

## Relación con la guía de Registro de Estudiantes, pasos 1–19

Se adaptaron al dominio de cine los objetivos de conexión ADO.NET, entidades, consultas parametrizadas, catálogos SQL, registro, búsqueda, edición, inactivación, procedimientos almacenados, transacciones y login con roles. En cine, las consultas finales se concretan en cartelera, funciones, butacas libres, ventas e inventario; **no se incorporan tablas de estudiantes o asignaturas**. La organización en proyectos separados es el paso 20 de la guía y no es requisito de esta entrega. Esta solución conserva una sola aplicación con clases de acceso a datos y formularios distintos.

## Notas de seguridad de datos

El SQL original del proyecto inicia borrando `GestionCineDB`. **No lo ejecutes sobre una base con datos**. Esta versión incluye un script inicial seguro y una mejora separada. El respaldo contiene el original para consulta histórica. El sistema no edita ventas cerradas para mantener coherencia de los importes y las existencias. El procedimiento anterior `sp_RegistrarVenta` puede seguir existiendo por compatibilidad, pero la aplicación nueva usa `sp_RegistrarVentaSegura`.
