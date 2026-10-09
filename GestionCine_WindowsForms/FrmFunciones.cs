namespace GestionCine_WindowsForms;
public partial class FrmFunciones : Form
{
    public FrmFunciones() => InitializeComponent();
    public FrmFunciones(Sesion sesion) : this()
    {
        VentanaAdaptable.Preparar(this);
        new CrudController(this,sesion,"Funcion","FuncionId","Fecha",
            dgvDatos,txtBuscar,chkTodos,lblEstado,btnNuevo,btnGuardar,btnDesactivar,
            new List<Campo>
            {
                new("PeliculaId","lookup:Pelicula:PeliculaId:Titulo",inputPeliculaId,true,"Película"),
                new("SalaId","lookup:Sala:SalaId:Nombre",inputSalaId,true,"Sala"),
                new("Fecha","date",inputFecha,true,"Fecha"),
                new("Hora","time",inputHora,true,"Hora"),
                new("Formato","enum:2D|3D|IMAX|4DX",inputFormato,true,"Formato"),
                new("PrecioBase","decimal",inputPrecioBase,true,"Precio base"),
            });
    }
}
