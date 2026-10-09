namespace GestionCine_WindowsForms;
public partial class FrmProductos : Form
{
    public FrmProductos() => InitializeComponent();
    public FrmProductos(Sesion sesion) : this()
    {
        VentanaAdaptable.Preparar(this);
        new CrudController(this,sesion,"Producto","ProductoId","Nombre",
            dgvDatos,txtBuscar,chkTodos,lblEstado,btnNuevo,btnGuardar,btnDesactivar,
            new List<Campo>
            {
                new("Nombre","text",inputNombre,true,"Nombre"),
                new("Categoria","enum:PALOMITAS|BEBIDA|COMIDA|DULCE|COMBO",inputCategoria,true,"Categoría"),
                new("Precio","decimal",inputPrecio,true,"Precio"),
                new("Stock","int",inputStock,true,"Existencias"),
                new("Descripcion","text",inputDescripcion,false,"Descripción"),
            });
    }
}
