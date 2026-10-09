using System;

namespace GestionCine_WindowsForms;

public class Cliente
{
    public int ClienteId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Apellido { get; set; } = string.Empty;
    public string Correo { get; set; } = string.Empty;
    public string Telefono { get; set; } = string.Empty;
    public DateTime FechaNacimiento { get; set; }
    public bool Activo { get; set; } = true;
}