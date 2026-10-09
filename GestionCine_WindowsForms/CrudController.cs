using System.Data;
using Microsoft.Data.SqlClient;

namespace GestionCine_WindowsForms;

public sealed record Campo(string Columna, string Tipo, Control Control, bool Obligatorio, string Etiqueta);
public sealed class CrudController
{
    private readonly Form form;
    private readonly Sesion sesion;
    private readonly string tabla, idColumna, busqueda;
    private readonly DataGridView grid;
    private readonly TextBox buscar;
    private readonly CheckBox todos;
    private readonly Label estado;
    private readonly List<Campo> campos;
    private int? id;
    private bool cambiandoSeleccion;
    public CrudController(Form form, Sesion sesion, string tabla, string idColumna, string busqueda,
        DataGridView grid, TextBox buscar, CheckBox todos, Label estado,
        Button nuevo, Button guardar, Button desactivar, List<Campo> campos)
    {
        this.form=form; this.sesion=sesion; this.tabla=tabla; this.idColumna=idColumna;
        this.busqueda=busqueda; this.grid=grid; this.buscar=buscar; this.todos=todos; this.estado=estado; this.campos=campos;
        nuevo.Enabled=guardar.Enabled=sesion.PuedeEditar;
        desactivar.Enabled=sesion.PuedeEditar && tabla!="Genero";
        todos.Visible=tabla!="Genero";
        nuevo.Click+=(_,_)=>Nuevo();
        guardar.Click+=(_,_)=>Guardar();
        desactivar.Click+=(_,_)=>Desactivar();
        buscar.TextChanged+=(_,_)=>Recargar();
        todos.CheckedChanged+=(_,_)=>Recargar();
        grid.SelectionChanged+=(_,_)=>Seleccionar();
        foreach(var c in campos.Where(x=>x.Tipo.StartsWith("lookup:"))) CargarLookup(c);
        Nuevo(); Recargar();
    }
    private void CargarLookup(Campo c)
    {
        var bits=c.Tipo.Split(':');
        var table=Database.Query($"SELECT {bits[2]}, {bits[3]} FROM dbo.{bits[1]} ORDER BY {bits[3]}");
        var cb=(ComboBox)c.Control;
        cb.DisplayMember=bits[3]; cb.ValueMember=bits[2]; cb.DataSource=table; cb.SelectedIndex=-1;
    }
    private void Recargar()
    {
        try
        {
            string where=tabla=="Genero" || todos.Checked ? "1=1" : tabla=="Pelicula" ? "Estado='ACTIVA'" : "Activo=1";
            grid.DataSource=Database.Query($"SELECT * FROM dbo.{tabla} WHERE {where} AND CONVERT(NVARCHAR(200),{busqueda}) LIKE @texto ORDER BY {idColumna} DESC",
                new SqlParameter("@texto",SqlDbType.NVarChar,202){Value="%"+buscar.Text.Trim()+"%"});
            estado.Text=$"{grid.Rows.Count} registro(s) · {tabla}";
        }
        catch(Exception ex){ estado.Text="No se pudieron cargar los datos."; MessageBox.Show(form,ex.Message,"SQL Server",MessageBoxButtons.OK,MessageBoxIcon.Error); }
    }
    private void Nuevo()
    {
        id=null; cambiandoSeleccion=true; grid.ClearSelection(); grid.CurrentCell=null; cambiandoSeleccion=false;
        foreach(var c in campos)
        {
            switch(c.Control)
            {
                case TextBox tb: tb.Clear(); break;
                case ComboBox cb: cb.SelectedIndex=-1; break;
                case NumericUpDown num: num.Value=0; break;
                case DateTimePicker dt: dt.Value=DateTime.Today; break;
            }
        }
        estado.Text="Nuevo registro · completá los datos.";
    }
    private void Seleccionar()
    {
        if(cambiandoSeleccion || grid.CurrentRow?.DataBoundItem is not DataRowView view)return;
        id=Convert.ToInt32(view.Row[idColumna]);
        foreach(var c in campos)
        {
            object value=view.Row[c.Columna];
            if(value==DBNull.Value)continue;
            switch(c.Control)
            {
                case TextBox tb: tb.Text=Convert.ToString(value); break;
                case ComboBox cb when c.Tipo.StartsWith("lookup:"): cb.SelectedValue=Convert.ToInt32(value); break;
                case ComboBox cb: cb.SelectedItem=Convert.ToString(value); break;
                case NumericUpDown num: num.Value=Math.Clamp(Convert.ToDecimal(value),num.Minimum,num.Maximum); break;
                case DateTimePicker dt when c.Tipo=="time": dt.Value=DateTime.Today.Add((TimeSpan)value); break;
                case DateTimePicker dt: dt.Value=Convert.ToDateTime(value); break;
            }
        }
        estado.Text=$"Editando registro #{id}.";
    }
    private object Valor(Campo c)
    {
        object? value=c.Control switch
        {
            TextBox tb => tb.Text.Trim(),
            ComboBox cb when c.Tipo.StartsWith("lookup:") => cb.SelectedValue is int i ? i : null,
            ComboBox cb => cb.SelectedItem?.ToString(),
            NumericUpDown num when c.Tipo=="int" => Decimal.ToInt32(num.Value),
            NumericUpDown num => num.Value,
            DateTimePicker dt when c.Tipo=="time" => dt.Value.TimeOfDay,
            DateTimePicker dt => dt.Value.Date,
            _ => null
        };
        if(value is null || value is string s && string.IsNullOrWhiteSpace(s))
        {
            if(c.Obligatorio)throw new ArgumentException($"Completá: {c.Etiqueta}.");
            return DBNull.Value;
        }
        return value;
    }
    private void Guardar()
    {
        if(!sesion.PuedeEditar)return;
        try
        {
            foreach(var c in campos)
            {
                if(c.Control is NumericUpDown n && c.Obligatorio && n.Value==0 &&
                   (c.Columna is "DuracionMinutos" or "CapacidadTotal" or "NumeroSala" or "Numero" or "PrecioBase" or "Precio"))
                    throw new ArgumentException($"Ingresá un valor mayor que cero para {c.Etiqueta}.");
            }
            var columns=campos.Select(x=>x.Columna).ToArray();
            var args=campos.Select(c=>new SqlParameter("@"+c.Columna, Valor(c))).ToList();
            if(id.HasValue)
            {
                string sets=string.Join(",",columns.Select(x=>$"{x}=@{x}"));
                args.Add(new SqlParameter("@id",id.Value));
                Database.Execute($"UPDATE dbo.{tabla} SET {sets} WHERE {idColumna}=@id",args.ToArray());
            }
            else
            {
                Database.Execute($"INSERT INTO dbo.{tabla} ({string.Join(",",columns)}) VALUES ({string.Join(",",columns.Select(x=>"@"+x))})",args.ToArray());
            }
            Recargar(); estado.Text="Guardado en SQL Server.";
            MessageBox.Show(form,"Registro guardado correctamente.","Gestión Cine",MessageBoxButtons.OK,MessageBoxIcon.Information);
        }
        catch(Exception ex){MessageBox.Show(form,ex.Message,"No se pudo guardar",MessageBoxButtons.OK,MessageBoxIcon.Warning);}
    }
    private void Desactivar()
    {
        if(!sesion.PuedeEditar || !id.HasValue || tabla=="Genero")return;
        if(MessageBox.Show(form,"¿Desactivar este registro? Permanecerá en SQL Server.","Confirmar",MessageBoxButtons.YesNo,MessageBoxIcon.Question)!=DialogResult.Yes)return;
        try
        {
            string set=tabla=="Pelicula" ? "Estado='INACTIVA'" : "Activo=0";
            Database.Execute($"UPDATE dbo.{tabla} SET {set} WHERE {idColumna}=@id",new SqlParameter("@id",SqlDbType.Int){Value=id.Value});
            id=null; Recargar();
        }
        catch(Exception ex){MessageBox.Show(form,ex.Message,"SQL Server");}
    }
}
