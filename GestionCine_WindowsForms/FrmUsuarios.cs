namespace GestionCine_WindowsForms;
public partial class FrmUsuarios : Form
{
    private readonly Sesion sesion=new("diseño","Administrador");
    public FrmUsuarios()=>InitializeComponent();
    public FrmUsuarios(Sesion sesion):this()
    {
        this.sesion=sesion;VentanaAdaptable.Preparar(this,780,540);
        if(sesion.Rol!="Administrador")throw new InvalidOperationException("Solo administradores.");
        cboRol.Items.AddRange(new object[]{"Registro","Consulta"});cboRol.SelectedIndex=0;
        btnCrear.Click+=(_,_)=>{try{Seguridad.CrearUsuario(sesion,txtUsuario.Text,txtClave.Text,cboRol.Text);txtClave.Clear();Cargar();MessageBox.Show(this,"Usuario creado.");}catch(Exception ex){MessageBox.Show(this,ex.Message);}};
        Cargar();
    }
    private void Cargar()
    {
        try{dgvUsuarios.DataSource=Database.Query("SELECT UsuarioId,Usuario,Rol,Activo,FechaCreacion FROM dbo.UsuariosCine ORDER BY UsuarioId");}
        catch(Exception ex){MessageBox.Show(this,ex.Message);}
    }
}
