namespace GestionCine_WindowsForms;
public partial class FrmEmpleados : Form
{
    public FrmEmpleados() => InitializeComponent();
    public FrmEmpleados(Sesion sesion) : this()
    {
        VentanaAdaptable.Preparar(this);
        new CrudController(this,sesion,"Empleado","EmpleadoId","Nombre",
            dgvDatos,txtBuscar,chkTodos,lblEstado,btnNuevo,btnGuardar,btnDesactivar,
            new List<Campo>
            {
                new("Nombre","text",inputNombre,true,"Nombre"),
                new("Apellido","text",inputApellido,true,"Apellido"),
                new("Cargo","text",inputCargo,true,"Cargo"),
                new("Area","text",inputArea,true,"Área"),
                new("Correo","text",inputCorreo,true,"Correo"),
                new("Telefono","text",inputTelefono,false,"Teléfono"),
                new("FechaContratacion","date",inputFechaContratacion,true,"Contratación"),
            });
    }
}
