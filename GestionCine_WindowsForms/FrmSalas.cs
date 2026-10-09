namespace GestionCine_WindowsForms;
public partial class FrmSalas : Form
{
    public FrmSalas() => InitializeComponent();
    public FrmSalas(Sesion sesion) : this()
    {
        VentanaAdaptable.Preparar(this);
        new CrudController(this,sesion,"Sala","SalaId","Nombre",
            dgvDatos,txtBuscar,chkTodos,lblEstado,btnNuevo,btnGuardar,btnDesactivar,
            new List<Campo>
            {
                new("NumeroSala","int",inputNumeroSala,true,"Número de sala"),
                new("Nombre","text",inputNombre,true,"Nombre"),
                new("TipoSala","enum:ESTANDAR|VIP|IMAX|3D|4DX",inputTipoSala,true,"Tipo de sala"),
                new("CapacidadTotal","int",inputCapacidadTotal,true,"Capacidad"),
            });
    }
}
