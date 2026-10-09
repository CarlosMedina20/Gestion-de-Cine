namespace GestionCine_WindowsForms;
public partial class MainForm : Form
{
    private readonly Sesion sesion=new("diseño","Administrador");
    public MainForm()=>InitializeComponent();
    public MainForm(Sesion sesion):this()
    {
        this.sesion=sesion;VentanaAdaptable.Preparar(this,960,610);
        lblSesion.Text=$"{sesion.Usuario} · {sesion.Rol}";
        var items=new (Button boton, Func<Form> abrir)[]
        {
            (btnPeliculas,()=>new FrmPeliculas(sesion)),(btnClientes,()=>new FrmClientes(sesion)),
            (btnProductos,()=>new FrmProductos(sesion)),(btnFunciones,()=>new FrmFunciones(sesion)),
            (btnSalas,()=>new FrmSalas(sesion)),(btnButacas,()=>new FrmButacas(sesion)),
            (btnEmpleados,()=>new FrmEmpleados(sesion)),(btnGeneros,()=>new FrmGeneros(sesion)),
            (btnVentas,()=>new FrmVentas(sesion))
        };
        foreach(var (boton,abrir) in items) boton.Click+=(_,_)=> {using var f=abrir();f.ShowDialog(this);Refrescar();};
        btnUsuarios.Enabled=sesion.Rol=="Administrador";
        btnUsuarios.Click+=(_,_)=>{using var f=new FrmUsuarios(sesion);f.ShowDialog(this);};
        btnConexion.Click+=(_,_)=>{using var f=new FrmConexion();f.ShowDialog(this);Refrescar();};
        btnSalir.Click+=(_,_)=>Close();
        Activated+=(_,_)=>Refrescar();
        Refrescar();
    }
    private void Refrescar()
    {
        try
        {
            lblResumen.Text=$"Películas activas: {Database.Scalar("SELECT COUNT(*) FROM Pelicula WHERE Estado='ACTIVA'")}    ·    Clientes activos: {Database.Scalar("SELECT COUNT(*) FROM Cliente WHERE Activo=1")}    ·    Ventas: {Database.Scalar("SELECT COUNT(*) FROM Venta")}";
            lblEstado.Text="Conectado a "+Database.Servidor;
        }
        catch(Exception ex){lblEstado.Text="Sin conexión: "+ex.Message;}
    }
}
