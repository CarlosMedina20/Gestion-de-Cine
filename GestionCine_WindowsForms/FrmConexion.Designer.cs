#nullable enable
namespace GestionCine_WindowsForms;
partial class FrmConexion
{
    private System.ComponentModel.IContainer? components;
    private TextBox txtServidor=null!;
    private Button btnGuardar=null!;
    private Label titulo=null!,etiqueta=null!,ayuda=null!;
    protected override void Dispose(bool disposing){if(disposing)components?.Dispose();base.Dispose(disposing);}
    private void InitializeComponent()
    {
        this.components=new System.ComponentModel.Container();SuspendLayout();
        Text="Configurar SQL Server";StartPosition=FormStartPosition.CenterParent;
        ClientSize=new Size(500,235);FormBorderStyle=FormBorderStyle.FixedDialog;MaximizeBox=false;
        BackColor=Color.White;Font=new Font("Segoe UI",11);
        this.titulo=new Label();
        this.titulo.Text="CONEXIÓN A SQL SERVER";
        this.titulo.Location=new Point(25,22);
        this.titulo.Size=new Size(440,38);
        this.titulo.Font=new Font("Segoe UI",17,FontStyle.Bold);
        this.etiqueta=new Label();
        this.etiqueta.Text="Servidor o instancia SQL Server";
        this.etiqueta.Location=new Point(28,70);
        this.etiqueta.Size=new Size(420,28);
        this.txtServidor=new TextBox();
        this.txtServidor.Name="txtServidor";
        this.txtServidor.Location=new Point(28,105);
        this.txtServidor.Size=new Size(440,32);
        this.ayuda=new Label();
        this.ayuda.Text=@"Ejemplos: .\SQLEXPRESS  ·  EQUIPO\SQLEXPRESS  ·  .";
        this.ayuda.Location=new Point(28,143);
        this.ayuda.Size=new Size(440,26);
        this.btnGuardar=new Button();
        this.btnGuardar.Name="btnGuardar";
        this.btnGuardar.Text="Guardar y probar";
        this.btnGuardar.Location=new Point(265,176);
        this.btnGuardar.Size=new Size(203,40);
        this.btnGuardar.BackColor=Color.FromArgb(183,47,64);
        this.btnGuardar.ForeColor=Color.White;
        this.btnGuardar.FlatStyle=FlatStyle.Flat;
        Controls.Add(this.titulo);Controls.Add(this.etiqueta);Controls.Add(this.txtServidor);Controls.Add(this.ayuda);Controls.Add(this.btnGuardar);        this.btnGuardar.FlatStyle=FlatStyle.Flat;
        this.btnGuardar.FlatAppearance.BorderSize=0;
        this.btnGuardar.BackColor=Color.FromArgb(183,47,64);
        this.btnGuardar.ForeColor=Color.White;
        this.btnGuardar.Cursor=Cursors.Hand;
        ResumeLayout(false);
    }
}
