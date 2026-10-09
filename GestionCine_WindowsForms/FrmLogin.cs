namespace GestionCine_WindowsForms;
public partial class FrmLogin : Form
{
    // Visual Studio usa el constructor sin parámetros: solo dibuja controles.
    public FrmLogin() => InitializeComponent();

    // La inicialización de SQL y eventos ocurre únicamente al ejecutar el programa.
    public FrmLogin(bool iniciarAplicacion) : this()
    {
        if (!iniciarAplicacion) return;
        lblServidor.Text="Servidor: "+Database.Servidor;
        try { if(!Seguridad.HayUsuariosCine()) lblMensaje.Text="Primera vez: admin y clave de 8+ caracteres."; }
        catch { lblMensaje.Text="Configurá SQL Server y ejecutá el script 02 si falta."; }
        btnConexion.Click+=(_,_)=> { using var f=new FrmConexion(); f.ShowDialog(this); lblServidor.Text="Servidor: "+Database.Servidor; };
        btnEntrar.Click+=(_,_)=>Entrar();
        AcceptButton=btnEntrar;
        txtClave.UseSystemPasswordChar=true;
        chkClave.CheckedChanged+=(_,_)=>txtClave.UseSystemPasswordChar=!chkClave.Checked;
    }
    private void Entrar()
    {
        try
        {
            if(!Seguridad.HayUsuariosCine())
            {
                if(!string.Equals(txtUsuario.Text.Trim(),"admin",StringComparison.OrdinalIgnoreCase))
                    throw new ArgumentException("Primer acceso: usá el usuario admin.");
                Seguridad.CrearAdmin(txtClave.Text);
            }
            var sesion=Seguridad.Entrar(txtUsuario.Text,txtClave.Text);
            if(sesion is null){ lblMensaje.Text="Usuario o contraseña incorrectos.";return; }
            Hide();
            try { using var main=new MainForm(sesion); main.ShowDialog(this); }
            finally { txtClave.Clear(); Show(); }
        }
        catch(Exception ex){lblMensaje.Text=ex.Message;}
    }
}
