namespace GestionCine_WindowsForms;
internal static class Program
{
    [STAThread]
    static void Main()
    {
        ApplicationConfiguration.Initialize();
        Database.Cargar();
        Application.Run(new FrmLogin(true));
    }
}
