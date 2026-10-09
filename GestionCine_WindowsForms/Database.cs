using System.Data;
using System.Text.Json;
using Microsoft.Data.SqlClient;

namespace GestionCine_WindowsForms;

public static class Database
{
    private static readonly string ConfigPath = Path.Combine(AppContext.BaseDirectory, "conexion.json");
    public static string Servidor { get; private set; } = @".\SQLEXPRESS";
    public static string BaseDatos => "GestionCineDB";
    public static void Cargar()
    {
        if (!File.Exists(ConfigPath)) return;
        var config = JsonSerializer.Deserialize<Configuracion>(File.ReadAllText(ConfigPath));
        if (!string.IsNullOrWhiteSpace(config?.Servidor)) Servidor = config.Servidor.Trim();
    }
    public static void GuardarServidor(string servidor)
    {
        if (string.IsNullOrWhiteSpace(servidor)) throw new ArgumentException("Escribí la instancia SQL Server.");
        Servidor = servidor.Trim();
        File.WriteAllText(ConfigPath, JsonSerializer.Serialize(new Configuracion { Servidor = Servidor }, new JsonSerializerOptions { WriteIndented = true }));
    }
    public static SqlConnection Conexion() => new(new SqlConnectionStringBuilder
    {
        DataSource = Servidor, InitialCatalog = BaseDatos, IntegratedSecurity = true,
        TrustServerCertificate = true, ConnectTimeout = 5
    }.ConnectionString);
    public static DataTable Query(string sql, params SqlParameter[] parameters)
    {
        using var connection = Conexion();
        using var command = new SqlCommand(sql, connection);
        command.Parameters.AddRange(parameters);
        using var adapter = new SqlDataAdapter(command);
        var table = new DataTable(); adapter.Fill(table); return table;
    }
    public static int Execute(string sql, params SqlParameter[] parameters)
    {
        using var connection = Conexion();
        using var command = new SqlCommand(sql, connection);
        command.Parameters.AddRange(parameters); connection.Open(); return command.ExecuteNonQuery();
    }
    public static object? Scalar(string sql, params SqlParameter[] parameters)
    {
        using var connection = Conexion();
        using var command = new SqlCommand(sql, connection);
        command.Parameters.AddRange(parameters); connection.Open(); return command.ExecuteScalar();
    }
    public static bool TestConnection(out string message)
    {
        try { using var connection = Conexion(); connection.Open(); message = $"Conexión correcta con {connection.Database} en {connection.DataSource}."; return true; }
        catch (Exception ex) { message = ex.Message; return false; }
    }
    private sealed class Configuracion { public string Servidor { get; set; } = @".\SQLEXPRESS"; }
}
