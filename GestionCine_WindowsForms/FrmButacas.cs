namespace GestionCine_WindowsForms;
public partial class FrmButacas : Form
{
    public FrmButacas() => InitializeComponent();
    public FrmButacas(Sesion sesion) : this()
    {
        VentanaAdaptable.Preparar(this);
        new CrudController(this,sesion,"Butaca","ButacaId","Fila",
            dgvDatos,txtBuscar,chkTodos,lblEstado,btnNuevo,btnGuardar,btnDesactivar,
            new List<Campo>
            {
                new("SalaId","lookup:Sala:SalaId:Nombre",inputSalaId,true,"Sala"),
                new("Fila","text",inputFila,true,"Fila"),
                new("Numero","int",inputNumero,true,"Número"),
                new("TipoButaca","enum:NORMAL|VIP|DISCAPACIDAD|PAREJA",inputTipoButaca,true,"Tipo"),
                new("PrecioExtra","decimal",inputPrecioExtra,true,"Precio extra"),
            });
    }
}
