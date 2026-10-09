namespace GestionCine_WindowsForms;
public partial class FrmPeliculas : Form
{
    public FrmPeliculas() => InitializeComponent();
    public FrmPeliculas(Sesion sesion) : this()
    {
        VentanaAdaptable.Preparar(this);
        new CrudController(this,sesion,"Pelicula","PeliculaId","Titulo",
            dgvDatos,txtBuscar,chkTodos,lblEstado,btnNuevo,btnGuardar,btnDesactivar,
            new List<Campo>
            {
                new("Titulo","text",inputTitulo,true,"Título"),
                new("DuracionMinutos","int",inputDuracionMinutos,true,"Duración (min)"),
                new("Clasificacion","text",inputClasificacion,true,"Clasificación"),
                new("FechaEstreno","date",inputFechaEstreno,false,"Estreno"),
                new("Director","text",inputDirector,false,"Director"),
                new("GeneroId","lookup:Genero:GeneroId:Nombre",inputGeneroId,true,"Género"),
                new("Estado","enum:ACTIVA|INACTIVA",inputEstado,true,"Estado"),
            });
    }
}
