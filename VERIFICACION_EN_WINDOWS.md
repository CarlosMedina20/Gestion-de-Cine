# Verificación final en la computadora de entrega

Este entorno no puede abrir Windows Forms ni conectarse a tu instancia local de SQL Server. En Visual Studio 2022:

1. Compilar solución con Ctrl + Mayús + B y confirmar cero errores.
2. Ejecutar los scripts SQL en el orden indicado en LEEME_PRIMERO.md.
3. Probar la instancia SQL desde el login, crear admin inicial, salir y volver a entrar.
4. Registrar un cliente y una película; cerrar la aplicación y confirmar que permanecen.
5. Editar cliente, filtrar por nombre, inactivarlo y mostrar inactivos.
6. Abrir cada formulario con «Ver diseñador», mover un control de prueba y deshacer el movimiento.
7. Crear una venta de un boleto con butaca libre y otra de producto: revisar el total, la ocupación y el stock en SSMS.
8. Intentar repetir una butaca o vender más unidades que el stock: debe rechazarse sin crear venta parcial.
9. Crear usuarios Registro y Consulta; comprobar que Consulta no pueda modificar registros.
