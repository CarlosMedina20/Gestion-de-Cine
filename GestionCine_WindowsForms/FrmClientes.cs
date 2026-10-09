namespace GestionCine_WindowsForms;
public partial class FrmClientes : Form
{
    public FrmClientes() => InitializeComponent();
    public FrmClientes(Sesion sesion) : this()
    {
        VentanaAdaptable.Preparar(this);
        new CrudController(this,sesion,"Cliente","ClienteId","Nombre",
            dgvDatos,txtBuscar,chkTodos,lblEstado,btnNuevo,btnGuardar,btnDesactivar,
            new List<Campo>
            {
                new("Nombre","text",inputNombre,true,"Nombre"),
                new("Apellido","text",inputApellido,true,"Apellido"),
                new("Correo","text",inputCorreo,true,"Correo"),
                new("Telefono","text",inputTelefono,false,"Teléfono"),
                new("FechaNacimiento","date",inputFechaNacimiento,false,"Fecha de nacimiento"),
            });
    }
}
