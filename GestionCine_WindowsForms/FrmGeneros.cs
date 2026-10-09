namespace GestionCine_WindowsForms;
public partial class FrmGeneros : Form
{
    public FrmGeneros() => InitializeComponent();
    public FrmGeneros(Sesion sesion) : this()
    {
        VentanaAdaptable.Preparar(this);
        new CrudController(this,sesion,"Genero","GeneroId","Nombre",
            dgvDatos,txtBuscar,chkTodos,lblEstado,btnNuevo,btnGuardar,btnDesactivar,
            new List<Campo>
            {
                new("Nombre","text",inputNombre,true,"Nombre"),
                new("Descripcion","text",inputDescripcion,false,"Descripción"),
            });
    }
}
