# Gestión Cine Profesional V2.3

Esta versión conserva la lógica de V2.2 y modifica los archivos `*.Designer.cs` para
mostrar controles editables en Visual Studio y mejorar la paleta, botones y tablas.
El tamaño de las ventanas se mantiene.

## Instalar en otra computadora

1. Instalar SQL Server y SQL Server Management Studio; confirmar el nombre de instancia.
2. En SSMS, conectarse a esa instancia con autenticación de Windows, abrir
   `SQL/INSTALAR_EN_OTRA_PC.sql` y ejecutarlo completo. Debe finalizar mostrando
   las tablas de `GestionCineDB`. No ejecutar el archivo de referencia original.
3. Abrir `GestionCine_WindowsForms.sln` en Visual Studio 2022 con .NET 8 y la carga
   de trabajo Desarrollo de escritorio con .NET; restaurar NuGet y compilar.
4. Ejecutar el programa. En el inicio de sesión elegir `Configurar SQL Server` y
   escribir exactamente la instancia usada en SSMS, por ejemplo `.\SQLEXPRESS`
   o `NOMBRE-PC\SQLEXPRESS`. Usar autenticación de Windows con acceso a la base.
5. En una base nueva, ingresar con `admin` y una contraseña nueva de al menos 8
   caracteres. La aplicación crea esa cuenta segura en `UsuariosCine`.

`INSTALAR_EN_OTRA_PC.sql` crea esquema y datos de ejemplo, no copia los registros
que hayas guardado en tu PC. Para mover los registros reales se requiere respaldo
y restauración de la base (`.bak`), o exportación de datos aparte.

## Verificación

En Visual Studio: Compilar > Recompilar solución. Abrir los diseñadores `FrmLogin`
y `MainForm` y comprobar que se ven todos sus controles. Iniciar sesión, crear un
género y consultar `SELECT * FROM GestionCineDB.dbo.Genero` en SSMS.
