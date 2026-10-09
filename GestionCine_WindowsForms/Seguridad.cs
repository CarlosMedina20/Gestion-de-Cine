using System.Security.Cryptography;
using System.Data;
using Microsoft.Data.SqlClient;

namespace GestionCine_WindowsForms;

public sealed record Sesion(string Usuario, string Rol)
{
    public bool PuedeEditar => Rol is "Administrador" or "Registro";
    public bool PuedeVender => Rol is "Administrador" or "Registro";
}

public static class Seguridad
{
    private static (byte[] hash, byte[] salt) Hash(string clave)
    {
        byte[] salt = RandomNumberGenerator.GetBytes(32);
        return (Rfc2898DeriveBytes.Pbkdf2(clave, salt, 100_000, HashAlgorithmName.SHA256, 64), salt);
    }
    public static bool HayUsuariosCine() => Convert.ToInt32(Database.Scalar("SELECT COUNT(*) FROM dbo.UsuariosCine")) > 0;
    public static void CrearAdmin(string clave)
    {
        if (clave.Length < 8) throw new ArgumentException("La clave debe tener al menos 8 caracteres.");
        var (hash, salt) = Hash(clave);
        Database.Execute(@"INSERT INTO dbo.UsuariosCine(Usuario,ClaveHash,ClaveSalt,Rol,Activo)
            SELECT 'admin',@h,@s,'Administrador',1 WHERE NOT EXISTS(SELECT 1 FROM dbo.UsuariosCine)",
            new SqlParameter("@h", SqlDbType.VarBinary, 64) { Value = hash }, new SqlParameter("@s", SqlDbType.VarBinary, 32) { Value = salt });
    }
    public static Sesion? Entrar(string usuario, string clave)
    {
        var t = Database.Query("SELECT Usuario,ClaveHash,ClaveSalt,Rol FROM dbo.UsuariosCine WHERE Usuario=@u AND Activo=1",
            new SqlParameter("@u", SqlDbType.NVarChar, 60) { Value = usuario.Trim() });
        if (t.Rows.Count != 1) return null;
        var r = t.Rows[0];
        byte[] computed = Rfc2898DeriveBytes.Pbkdf2(clave, (byte[])r["ClaveSalt"], 100_000, HashAlgorithmName.SHA256, 64);
        return CryptographicOperations.FixedTimeEquals(computed, (byte[])r["ClaveHash"])
            ? new Sesion((string)r["Usuario"], (string)r["Rol"]) : null;
    }
    public static void CrearUsuario(Sesion sesion, string usuario, string clave, string rol)
    {
        if (sesion.Rol != "Administrador") throw new InvalidOperationException("Solo administración puede crear usuarios.");
        if (string.IsNullOrWhiteSpace(usuario) || clave.Length < 8 || rol is not ("Registro" or "Consulta"))
            throw new ArgumentException("Ingresá usuario, clave de 8 caracteres o más y rol válido.");
        var (hash, salt) = Hash(clave);
        Database.Execute("INSERT INTO dbo.UsuariosCine(Usuario,ClaveHash,ClaveSalt,Rol) VALUES(@u,@h,@s,@r)",
            new SqlParameter("@u", SqlDbType.NVarChar, 60) { Value = usuario.Trim() },
            new SqlParameter("@h", SqlDbType.VarBinary, 64) { Value = hash }, new SqlParameter("@s", SqlDbType.VarBinary, 32) { Value = salt },
            new SqlParameter("@r", SqlDbType.NVarChar, 20) { Value = rol });
    }
}
