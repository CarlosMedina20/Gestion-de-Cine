using System.Data;
using Microsoft.Data.SqlClient;

namespace GestionCine_WindowsForms;
public partial class FrmVentas : Form
{
    private readonly Sesion sesion=new("diseño","Administrador");
    public FrmVentas()=>InitializeComponent();
    public FrmVentas(Sesion sesion):this()
    {
        this.sesion=sesion;VentanaAdaptable.Preparar(this,980,610);btnRegistrar.Enabled=sesion.PuedeVender;
        cboPago.Items.AddRange(new object[]{"EFECTIVO","TARJETA_CREDITO","TARJETA_DEBITO","TRANSFERENCIA","PAGO_QR","GIFT_CARD"});
        cboPago.SelectedIndex=0;
        btnRegistrar.Click+=(_,_)=>Registrar();
        btnActualizar.Click+=(_,_)=>Cargar();
        cboFuncion.SelectedIndexChanged+=(_,_)=>CargarButacas();
        Cargar();
    }
    private static int? Id(ComboBox combo)=>combo.SelectedValue is int i?i:null;
    private static void Bind(ComboBox combo,string sql,string id,string titulo, params SqlParameter[] parameters)
    {
        var t=Database.Query(sql,parameters);combo.DisplayMember=titulo;combo.ValueMember=id;combo.DataSource=t;combo.SelectedIndex=-1;
    }
    private void Cargar()
    {
        try
        {
            Bind(cboCliente,"SELECT ClienteId,Nombre+' '+Apellido AS Nombre FROM Cliente WHERE Activo=1 ORDER BY Nombre","ClienteId","Nombre");
            Bind(cboEmpleado,"SELECT EmpleadoId,Nombre+' '+Apellido AS Nombre FROM Empleado WHERE Activo=1 ORDER BY Nombre","EmpleadoId","Nombre");
            Bind(cboFuncion,@"SELECT f.FuncionId,p.Titulo+' · '+CONVERT(VARCHAR(10),f.Fecha,120)+' '+CONVERT(VARCHAR(5),f.Hora,108) AS Nombre
                FROM Funcion f JOIN Pelicula p ON p.PeliculaId=f.PeliculaId WHERE f.Activo=1 AND p.Estado='ACTIVA' ORDER BY f.Fecha DESC,f.Hora","FuncionId","Nombre");
            Bind(cboProducto,"SELECT ProductoId,Nombre FROM Producto WHERE Activo=1 ORDER BY Nombre","ProductoId","Nombre");
            dgvVentas.DataSource=Database.Query(@"SELECT v.VentaId,c.Nombre+' '+c.Apellido AS Cliente,v.CantidadBoletos,v.CantidadProducto,
                v.Subtotal,v.Impuesto,v.Total,v.FormaPago,v.FechaVenta FROM Venta v JOIN Cliente c ON c.ClienteId=v.ClienteId ORDER BY v.VentaId DESC");
            lblEstado.Text=$"{dgvVentas.Rows.Count} venta(s) registradas.";
        }
        catch(Exception ex){MessageBox.Show(this,ex.Message,"SQL Server");}
    }
    private void CargarButacas()
    {
        cboButaca.DataSource=null;
        if(Id(cboFuncion) is not int funcion)return;
        try
        {
            Bind(cboButaca,@"SELECT b.ButacaId,b.Fila+'-'+CAST(b.Numero AS VARCHAR(10))+' ('+CAST(b.PrecioExtra AS VARCHAR(20))+')' AS Nombre
                FROM Butaca b JOIN Funcion f ON f.SalaId=b.SalaId
                WHERE f.FuncionId=@f AND b.Activo=1
                  AND NOT EXISTS (SELECT 1 FROM Venta v WHERE v.FuncionId=f.FuncionId AND v.ButacaId=b.ButacaId AND v.CantidadBoletos>0)
                ORDER BY b.Fila,b.Numero","ButacaId","Nombre",new SqlParameter("@f",SqlDbType.Int){Value=funcion});
        }
        catch(Exception ex){MessageBox.Show(this,ex.Message,"Butacas");}
    }
    private void Registrar()
    {
        try
        {
            if(!sesion.PuedeVender)throw new InvalidOperationException("No tenés permiso para vender.");
            if(Id(cboCliente) is not int cliente || Id(cboEmpleado) is not int empleado)
                throw new ArgumentException("Seleccioná un cliente y un empleado activos.");
            int? funcion=Id(cboFuncion),butaca=Id(cboButaca),producto=Id(cboProducto);
            int boletos=(int)numBoletos.Value,cantidad=(int)numCantidad.Value;
            if(boletos+cantidad==0)throw new ArgumentException("Ingresá al menos un boleto o producto.");
            if(boletos>1)throw new ArgumentException("El modelo de datos registra una sola butaca por venta. Hacé una venta por boleto.");
            if(boletos>0 && (funcion is null || butaca is null))throw new ArgumentException("Seleccioná función y butaca para el boleto.");
            if(cantidad>0 && producto is null)throw new ArgumentException("Seleccioná un producto.");
            using var cn=Database.Conexion();cn.Open();
            using var cmd=new SqlCommand("dbo.sp_RegistrarVentaSegura",cn){CommandType=CommandType.StoredProcedure};
            cmd.Parameters.Add("@ClienteId",SqlDbType.Int).Value=cliente;
            cmd.Parameters.Add("@EmpleadoId",SqlDbType.Int).Value=empleado;
            cmd.Parameters.Add("@FuncionId",SqlDbType.Int).Value=(object?)funcion??DBNull.Value;
            cmd.Parameters.Add("@ButacaId",SqlDbType.Int).Value=(object?)butaca??DBNull.Value;
            cmd.Parameters.Add("@ProductoId",SqlDbType.Int).Value=(object?)producto??DBNull.Value;
            cmd.Parameters.Add("@CantidadBoletos",SqlDbType.Int).Value=boletos;
            cmd.Parameters.Add("@CantidadProducto",SqlDbType.Int).Value=cantidad;
            cmd.Parameters.Add("@FormaPago",SqlDbType.VarChar,30).Value=cboPago.Text;
            cmd.Parameters.Add("@ReferenciaPago",SqlDbType.VarChar,100).Value=string.IsNullOrWhiteSpace(txtReferencia.Text)?DBNull.Value:txtReferencia.Text.Trim();
            var total=cmd.Parameters.Add("@TotalCalculado",SqlDbType.Decimal);total.Precision=10;total.Scale=2;total.Direction=ParameterDirection.Output;
            cmd.ExecuteNonQuery();
            MessageBox.Show(this,$"Venta registrada. Total: {total.Value:0.00}","Gestión Cine",MessageBoxButtons.OK,MessageBoxIcon.Information);
            Cargar();
        }
        catch(Exception ex){MessageBox.Show(this,ex.Message,"No se registró la venta",MessageBoxButtons.OK,MessageBoxIcon.Warning);}
    }
}
