namespace GestionCine_WindowsForms;
public partial class FrmConexion : Form
{
    public FrmConexion()
    {
        InitializeComponent();
        txtServidor.Text=Database.Servidor;
        btnGuardar.Click+=(_,_)=>{
            try
            {
                Database.GuardarServidor(txtServidor.Text);
                if(Database.TestConnection(out var message)){MessageBox.Show(this,message);DialogResult=DialogResult.OK;}
                else MessageBox.Show(this,message,"Revisar conexión");
            }
            catch(Exception ex){MessageBox.Show(this,ex.Message);}
        };
    }
}
