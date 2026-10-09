#nullable enable
namespace GestionCine_WindowsForms;
partial class FrmUsuarios
{
    private System.ComponentModel.IContainer? components;
    private TextBox txtUsuario=null!,txtClave=null!;private ComboBox cboRol=null!;
    private Button btnCrear=null!;private DataGridView dgvUsuarios=null!;
    private FlowLayoutPanel panel=null!;
    protected override void Dispose(bool disposing){if(disposing)components?.Dispose();base.Dispose(disposing);}
    private void InitializeComponent()
    {
        this.components=new System.ComponentModel.Container();SuspendLayout();
        Text="Gestión de usuarios";StartPosition=FormStartPosition.CenterParent;Size=new Size(780,550);MinimumSize=new Size(650,450);Font=new Font("Segoe UI",10);
        this.panel=new FlowLayoutPanel();
        this.panel.Dock=DockStyle.Top;
        this.panel.Height=130;
        this.panel.Padding=new Padding(18);
        this.panel.AutoScroll=true;
        this.panel.WrapContents=true;
        this.txtUsuario=new TextBox();
        this.txtUsuario.Name="txtUsuario";
        this.txtUsuario.PlaceholderText="Usuario";
        this.txtUsuario.Width=170;
        this.txtClave=new TextBox();
        this.txtClave.Name="txtClave";
        this.txtClave.PlaceholderText="Contraseña (8+)";
        this.txtClave.Width=175;
        this.txtClave.UseSystemPasswordChar=true;
        this.cboRol=new ComboBox();
        this.cboRol.Name="cboRol";
        this.cboRol.Width=130;
        this.cboRol.DropDownStyle=ComboBoxStyle.DropDownList;
        this.btnCrear=new Button();
        this.btnCrear.Name="btnCrear";
        this.btnCrear.Text="Crear usuario";
        this.btnCrear.Width=135;
        this.btnCrear.Height=35;
        this.panel.Controls.Add(this.txtUsuario);this.panel.Controls.Add(this.txtClave);this.panel.Controls.Add(this.cboRol);this.panel.Controls.Add(this.btnCrear);
        this.dgvUsuarios=new DataGridView();
        this.dgvUsuarios.Name="dgvUsuarios";
        this.dgvUsuarios.Dock=DockStyle.Fill;
        this.dgvUsuarios.ReadOnly=true;
        this.dgvUsuarios.AutoSizeColumnsMode=DataGridViewAutoSizeColumnsMode.Fill;
        this.dgvUsuarios.AllowUserToAddRows=false;
        Controls.Add(this.dgvUsuarios);Controls.Add(this.panel);        this.btnCrear.FlatStyle=FlatStyle.Flat;
        this.btnCrear.FlatAppearance.BorderSize=0;
        this.btnCrear.BackColor=Color.FromArgb(183,47,64);
        this.btnCrear.ForeColor=Color.White;
        this.btnCrear.Cursor=Cursors.Hand;
        this.dgvUsuarios.BackgroundColor=Color.White;
        this.dgvUsuarios.BorderStyle=BorderStyle.None;
        this.dgvUsuarios.EnableHeadersVisualStyles=false;
        this.dgvUsuarios.ColumnHeadersDefaultCellStyle.BackColor=Color.FromArgb(31,65,91);
        this.dgvUsuarios.ColumnHeadersDefaultCellStyle.ForeColor=Color.White;
        this.dgvUsuarios.DefaultCellStyle.SelectionBackColor=Color.FromArgb(215,230,241);
        this.dgvUsuarios.DefaultCellStyle.SelectionForeColor=Color.FromArgb(19,30,48);
        this.dgvUsuarios.AlternatingRowsDefaultCellStyle.BackColor=Color.FromArgb(244,247,251);
        ResumeLayout(false);
    }
}
